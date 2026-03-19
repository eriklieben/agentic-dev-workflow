// opencode plugin — bridges Claude Code hooks (.ps1 scripts) into opencode.
//
// Each hook calls the same PowerShell script that Claude Code uses,
// keeping .claude/hooks/*.ps1 as the single source of truth.
//
// Requires: pwsh (PowerShell Core) on PATH.

import type { Plugin } from "@opencode-ai/plugin"

/** Run a .ps1 hook script with JSON on stdin. Returns stdout text. */
async function runHook(
  $: any,
  dir: string,
  script: string,
  stdinJson?: Record<string, unknown>,
): Promise<string> {
  const path = `${dir}/.claude/hooks/${script}`
  const input = stdinJson ? JSON.stringify(stdinJson) : "{}"
  try {
    const result =
      await $`echo ${input} | pwsh -NoProfile -File ${path}`.quiet().nothrow()
    return result.text().trim()
  } catch {
    return ""
  }
}

/** Check if a tool name matches a Claude Code-style matcher pattern (e.g. "Edit|Write"). */
function matchesTool(toolName: string, matcher: string): boolean {
  if (!matcher) return true
  return matcher.split("|").some((m) => toolName === m)
}

export const HooksPlugin: Plugin = async ({ $, directory }) => {
  return {
    // Claude Code: UserPromptSubmit (matcher: "")
    // Detects wrap-up intent and injects wrap-up instructions.
    "chat.message": async (input, output) => {
      const userText =
        input.parts
          ?.filter((p: any) => p.type === "text")
          .map((p: any) => p.text)
          .join(" ") ?? ""

      if (!userText) return

      const result = await runHook($, directory, "on-prompt-submit.ps1", {
        prompt: userText,
      })

      // If the hook returned text, inject it as additional context
      if (result) {
        output.parts = [
          ...(input.parts ?? []),
          { type: "text", text: result },
        ]
      }
    },

    // Claude Code: PreToolUse (matcher: "Write" for doc-file-warn, "Edit|Write" for suggest-compact)
    "tool.execute.before": async (input, output) => {
      const toolName = input.tool?.name ?? ""

      // on-doc-file-warn.ps1 — matcher: Write
      if (matchesTool(toolName, "Write")) {
        await runHook($, directory, "on-doc-file-warn.ps1", {
          tool_input: input.tool?.args ?? {},
        })
      }

      // on-suggest-compact.ps1 — matcher: Edit|Write
      if (matchesTool(toolName, "Edit|Write")) {
        await runHook($, directory, "on-suggest-compact.ps1", {
          tool_input: input.tool?.args ?? {},
        })
      }
    },

    // Claude Code: PostToolUse (matcher: "Edit|Write", async: true)
    // on-quality-gate.ps1 — runs format/lint on edited files
    "tool.execute.after": async (input, output) => {
      const toolName = input.tool?.name ?? ""

      if (matchesTool(toolName, "Edit|Write")) {
        // Fire and forget (async in Claude Code too)
        runHook($, directory, "on-quality-gate.ps1", {
          tool_input: input.args ?? {},
        })
      }
    },

    // Claude Code: PreCompact (matcher: "")
    // Flushes unsaved session context to daily memory before compaction.
    "experimental.session.compacting": async (input, output) => {
      const result = await runHook($, directory, "on-pre-compact.ps1", {
        cwd: directory,
        trigger: "auto",
      })

      // Inject pre-compaction instructions if the hook returned any
      if (result) {
        output.context = [...(output.context ?? []), result]
      }
    },

    // Claude Code: Stop + SessionEnd
    // cost-track runs on every response stop; session-end runs on session close.
    event: async ({ event }) => {
      // Stop → cost tracking (fire and forget)
      if (
        event.type === "session.status" &&
        (event as any).properties?.status?.type === "idle"
      ) {
        runHook($, directory, "on-cost-track.ps1", {
          usage: (event as any).properties?.usage ?? {},
          model: (event as any).properties?.model ?? "unknown",
        })
      }

      // SessionEnd → write end marker to daily memory
      if (event.type === "session.deleted") {
        await runHook($, directory, "on-session-end.ps1", {
          cwd: directory,
          session_id: (event as any).properties?.id ?? "unknown",
          source: "session.deleted",
        })
      }
    },
  }
}
