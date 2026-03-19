# Hooks

Agentic-workflow uses Claude Code hooks to automate session management. Hooks are scripts that run in response to specific events in the Claude Code lifecycle. Each hook has a `.ps1` (PowerShell Core) script for cross-platform support.

## Installed Hooks

### on-prompt-submit (UserPromptSubmit)

**What it does:** Detects wrap-up intent in user messages and automatically injects wrap-up instructions into Claude's context.

**Trigger phrases:**

| Category | Phrases |
|----------|---------|
| **Exit** | `bye`, `goodbye`, `exit`, `/exit`, `quit`, `/quit` |
| **Done** | `done`, `done for today`, `that's it`, `i'm done` |
| **Wrap up** | `wrap up`, `wrap-up`, `wrapup`, `wrap it up` |
| **Session** | `end session`, `close session`, `session done` |
| **Farewell** | `leaving`, `signing off`, `logging off`, `heading out` |
| **Complete** | `we're done`, `all done`, `that's all` |

**How it works:** When the user types any of these phrases, the hook injects the full wrap-up instructions into Claude's context. Claude then automatically runs the wrap-up workflow — reviewing deliverables, updating daily memory, checking for documentation gaps, and presenting a summary. The user doesn't need to remember to type `/meta-wrap-up`.

**If the user types something else:** The hook does nothing — zero overhead on normal messages.

### on-pre-compact (PreCompact)

**What it does:** Before Claude's context window gets compressed, injects instructions to save any unsaved session context to the daily memory file.

**Why this matters:** During long sessions, Claude accumulates context (decisions made, things learned, work in progress) that only exists in the conversation. When the context window fills up, Claude Code compresses older messages. Without this hook, unsaved context could be lost.

**How it works:** The hook fires before compaction (whether automatic or manual via `/compact`) and injects: "Save your current session context to the daily memory file before compaction happens."

### on-session-end (SessionEnd)

**What it does:** Lightweight cleanup when a session terminates. This hook runs *after* Claude is already closing — it cannot interact with Claude or the user.

**Actions:**
- Appends a session end marker to today's daily memory file (timestamp + exit reason + session cost in EUR)
- Increments the session count in `heartbeat-state.json`

**Exit reasons tracked:** `clear` (user ran /clear), `prompt_input_exit` (Ctrl+C), `logout`, `other`

### on-suggest-compact (PreToolUse — Edit|Write)

**What it does:** Counts tool calls and suggests manual compaction at logical intervals instead of letting auto-compact happen mid-task.

**Why this matters:** Auto-compact triggers at arbitrary points, often in the middle of a task. Strategic compaction after completing a milestone preserves context through logical phases.

**How it works:** Increments a counter (stored in `/tmp/`) on every Edit/Write tool call. At 50 calls (configurable via `AW_COMPACT_THRESHOLD`), it prints a suggestion to stderr. Repeats every 25 calls after that.

**Adapted from:** everything-claude-code (affaanmustafa)

### on-doc-file-warn (PreToolUse — Write)

**What it does:** Warns when Claude tries to create markdown files in non-standard locations. Prevents repo clutter.

**Allowed locations:** `docs/`, `context/`, `.claude/`, `templates/`, `adr/`, `architecture/`, `reference/`, `guides/`, plus standard files like `README.md`, `CLAUDE.md`, `SKILL.md`, etc.

**How it works:** Never blocks — only warns via stderr. If a Write targets a `.md` or `.txt` file outside known locations, it suggests placing it in `docs/` or `context/` instead.

**Adapted from:** everything-claude-code (affaanmustafa)

### on-quality-gate (PostToolUse — Edit|Write)

**What it does:** Runs lightweight format/lint checks on just the edited file after every Edit or Write. Catches issues as you go instead of at the end.

**Supported file types:**

| Extension | Tool | Check |
|-----------|------|-------|
| `.cs` | `dotnet format --include <file> --verify-no-changes` | Code formatting against `.editorconfig` |
| `.ts` | `npx eslint <file>` | Lint rules (requires eslint config) |
| `.scss`/`.css` | `npx stylelint <file>` | Style rules (requires stylelint config) |

**Skips:** Test files (`*Tests.cs`, `*.spec.ts`), generated directories (`bin/`, `obj/`, `node_modules/`, `dist/`), config files (`.json`, `.md`, `.yml`), and workflow files (`.claude/`, `context/`, `docs/`).

**How it works:** Runs asynchronously (30s timeout), never blocks. Reports issues via stderr only. Auto-detects project root by walking up to find `.sln`/`.csproj` (C#) or eslint config (TypeScript).

**Control:**
- `AW_QUALITY_GATE_FIX=true` — auto-fix instead of check-only
- `AW_QUALITY_GATE=off` — disable the hook entirely (lighter than `AW_DISABLED_HOOKS`)

**Adapted from:** everything-claude-code quality-gate pattern (affaanmustafa)

### on-cost-track (Stop)

**What it does:** Tracks token usage and estimated cost in EUR per response, appending to `~/.claude/metrics/costs.jsonl`.

**How it works:** Runs asynchronously after each Claude response. Parses token counts from stdin, estimates cost using per-model USD rates, converts to EUR, and appends a JSONL line with timestamp, session ID, model, tokens, and cost.

**Pricing** (per 1M tokens, [source](https://docs.anthropic.com/en/docs/about-claude/pricing)):

| Model | Input | Output |
|-------|-------|--------|
| Haiku 4.5 | $1.00 | $5.00 |
| Sonnet 4.5/4.6 | $3.00 | $15.00 |
| Opus 4.6 | $5.00 | $25.00 |

**EUR conversion:** Configurable via `AW_EUR_RATE` (default: `0.92`). Set `export AW_EUR_RATE=0.95` to override.

**Metrics location:** `~/.claude/metrics/costs.jsonl` — query with `jq` or import into a spreadsheet.

**Query today's spend:**
```bash
jq -s '[.[] | select(.timestamp | startswith("'$(date -u +%Y-%m-%d)'"))] | {total_eur: (map(.estimated_cost_eur) | add), input_tokens: (map(.input_tokens) | add), output_tokens: (map(.output_tokens) | add)}' ~/.claude/metrics/costs.jsonl
```

## Hook Profiles

All hooks support profile-based enable/disable via the `AW_HOOK_PROFILE` environment variable:

| Profile | What runs | Use when |
|---------|-----------|----------|
| `minimal` | Session lifecycle only (prompt-submit, pre-compact, session-end, cost-track) | Fast sessions, minimal overhead |
| `standard` | Lifecycle + quality guards (doc-file-warn, suggest-compact, quality-gate) | **Default** — everyday development |
| `strict` | Everything | Long sessions, exploratory work |

**Disable specific hooks** with `AW_DISABLED_HOOKS`:

```bash
# Disable compact suggestions and doc warnings
export AW_DISABLED_HOOKS="suggest-compact,doc-file-warn"
```

**Hook profile assignments:**

| Hook | minimal | standard | strict |
|------|---------|----------|--------|
| on-prompt-submit | yes | yes | yes |
| on-pre-compact | yes | yes | yes |
| on-session-end | yes | yes | yes |
| on-cost-track | yes | yes | yes |
| on-suggest-compact | — | yes | yes |
| on-doc-file-warn | — | yes | yes |
| on-quality-gate | — | yes | yes |

## How Hooks Fit Into the Session Lifecycle

```
┌─ User opens Claude Code ──────────────────────────────────┐
│  CLAUDE.md loads → heartbeat runs automatically            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  User works normally                                       │
│  ↓                                                         │
│  [on-prompt-submit watches every message — zero cost]      │
│  [on-doc-file-warn guards Write — warns on clutter]       │
│  [on-suggest-compact counts Edit|Write — nudges]          │
│  [on-quality-gate checks edited .cs/.ts — async]          │
│                                                            │
│  Context window fills up →                                 │
│  [on-pre-compact] → "Save context before compaction"       │
│  ↓                                                         │
│  Work continues with saved context                         │
│                                                            │
│  User types "bye" or "done" →                              │
│  [on-prompt-submit] → Injects wrap-up instructions         │
│  ↓                                                         │
│  Claude runs full wrap-up (memory, docs check, summary)    │
│  ↓                                                         │
│  After each Claude response →                              │
│  [on-cost-track] → Logs tokens + cost in EUR (async)       │
│                                                            │
│  User exits (Ctrl+C or closes terminal) →                  │
│  [on-session-end] → Writes end marker + cost, updates count│
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Configuration

### Claude Code

Hooks are configured in your project's `.claude/settings.local.json`. The bootstrap merges hook entries from `.claude/hooks/settings-hooks.json` automatically.

### opencode

Hooks run via the plugin at `.opencode/plugins/hooks.ts`. This plugin bridges opencode events to the same `.ps1` scripts — no separate configuration needed. The plugin is auto-discovered by opencode at startup and requires `@opencode-ai/plugin` (installed via `.opencode/package.json`).

**Event mapping:**

| Claude Code Event | opencode Event | Hook Script |
|---|---|---|
| `UserPromptSubmit` | `chat.message` | on-prompt-submit.ps1 |
| `PreToolUse` | `tool.execute.before` | on-doc-file-warn.ps1, on-suggest-compact.ps1 |
| `PostToolUse` | `tool.execute.after` | on-quality-gate.ps1 |
| `PreCompact` | `experimental.session.compacting` | on-pre-compact.ps1 |
| `Stop` | `event` → `session.status` (idle) | on-cost-track.ps1 |
| `SessionEnd` | `event` → `session.deleted` | on-session-end.ps1 |

The opencode plugin preserves Claude Code's matcher behavior (e.g. `Edit|Write` filtering) in JavaScript rather than config.

### Shared architecture

Both tools call the same `.ps1` scripts in `.claude/hooks/`. The scripts are the single source of truth — edit them once, both tools pick up the change.

```
.claude/hooks/*.ps1          ← source of truth (PowerShell scripts)
       ↑                          ↑
settings.local.json          .opencode/plugins/hooks.ts
(Claude Code config)         (opencode JS wrapper)
```

**Cross-platform:** Each hook has a `.ps1` (PowerShell Core) script. Requires `pwsh` on PATH.

The hook events used:

| Event | Hooks | When it fires |
|-------|-------|---------------|
| `UserPromptSubmit` | on-prompt-submit | Every user message |
| `PreToolUse` | on-doc-file-warn, on-suggest-compact | Before Write or Edit tool calls |
| `PostToolUse` | on-quality-gate | After Edit or Write tool calls |
| `PreCompact` | on-pre-compact | Before context window compression |
| `Stop` | on-cost-track | After each Claude response |
| `SessionEnd` | on-session-end | When session terminates |

## Adding Custom Trigger Phrases

Edit `.claude/hooks/on-prompt-submit.ps1` and add phrases to the `$wrapUpPhrases` array:

```powershell
$wrapUpPhrases = @(
    # ... existing phrases ...
    "my custom phrase", "another phrase"
)
```

## Disabling Hooks

Three ways to disable hooks, from lightest to heaviest:

1. **Environment variable** (temporary): `export AW_DISABLED_HOOKS="suggest-compact,doc-file-warn"`
2. **Profile** (session-wide): `export AW_HOOK_PROFILE=minimal` — only lifecycle hooks run
3. **Remove from config** (permanent): Remove the entry from `settings-hooks.json`

The script files can stay on disk — they only run when configured and enabled by the active profile.

## Limitations

- **SessionEnd has a 1.5s default timeout** — keep cleanup fast
- **SessionEnd cannot interact with Claude** — it runs after the session is closing
- **UserPromptSubmit fires on every message** — the script must be fast (exits immediately for non-matching messages)
- **Hooks cannot invoke skills directly** — they inject context text that Claude then acts on
- **PreCompact cannot prevent compaction** — it can only instruct Claude to save context first

