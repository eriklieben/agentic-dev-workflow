# Agentic Workflow

A portable, file-based workflow system for AI coding agents. Gives your agent persistent memory, session rituals, document generation skills, and multi-repo documentation support — with deep integrations for C#/.NET and Angular/TypeScript development.

## What It Does

### Framework (stack-agnostic)

- **Session continuity** — the heartbeat pattern loads context at session start, saves learnings at session end
- **Persistent memory** — daily notes get distilled into long-term curated knowledge
- **Document generation** — generate PRDs, RFCs, ADRs, design docs, C4 diagrams, runbooks, post-mortems, and spike reports from templates
- **Codebase documentation** — analyze an existing codebase and bootstrap a full documentation set
- **Multi-repo support** — multiple projects share a single documentation repo
- **Skill management** — adopt, catalog, and upgrade skills across projects
- **Cross-platform hooks** — PowerShell (.ps1) for session automation, quality gates, and cost tracking (EUR)

### Stack Adaptations (C#/.NET + Angular/TypeScript)

> **Note:** These are opinionated preferences that work for me, but may not be suitable for you or every project you run. Adjust them to fit your stack and conventions.

Development skills auto-detect your stack and delegate to the right sub-skill:

- **Verification** — `dotnet build` / Roslyn analyzers / `dotnet format` / xUnit + coverage / `ng build` / ESLint / Vitest
- **ErikLieben.\* NuGet packages** — adopted for domain building blocks (event sourcing, strongly typed IDs, specifications, etc.)
- **Aspire integration** — resource health checks via MCP, performance profiling via distributed traces, span pattern analysis for N+1 detection
- **TDD** — RED→GREEN→REFACTOR loops adapted for xUnit/NSubstitute/Testcontainers (.NET) and Vitest/Testing Library/Playwright (Angular)
- **Security** — OWASP Top 10:2025 checklists adapted for ASP.NET Core and Angular
- **Dependencies** — risk-aware NuGet and npm updates with breaking change detection

## Quick Start

### Use standalone (single project)

1. Clone this repo alongside your project
2. Start Claude Code in `agentic-dev-workflow/`
3. Fill in `context/USER.md` with your details
4. The heartbeat runs automatically — you're ready to go

### Install into an existing project

```
/meta-bootstrap ../my-project --docs-repo ../my-docs
```

This copies skills, creates context files, configures `workflow.json`, and adds the heartbeat to your project's CLAUDE.md. See [Getting Started](docs/getting-started.md).

## Skills

| Skill | Command | What it does |
|-------|---------|-------------|
| **Heartbeat** | `/meta-heartbeat` | Session startup — loads context, creates daily memory |
| **Wrap-up** | `/meta-wrap-up` | Session end — reviews work, distills learnings, prompts for docs |
| **Bootstrap** | `/meta-bootstrap` | Install workflow into a project |
| **Upgrade** | `/meta-upgrade` | Sync skills/templates after pulling new agentic-dev-workflow version |
| **Adopt Skill** | `/meta-adopt-skill` | Review and install an external skill |
| **Skill Catalog** | `/meta-skill-catalog` | Audit and manage installed skills |
| **Continuous Learning** | `/meta-continuous-learning` | Extract reusable patterns from sessions into skills/rules |
| **Contribute Back** | `/meta-contribute-back` | Push universal skill learnings back to agentic-dev-workflow via git branch |
| **Merge Contributions** | `/meta-merge-contributions` | Review and merge contribution branches with version bumps |
| **Commit** | *(auto)* | Conventional commit messages — Angular/Conventional Commits spec |
| **Verify** | `/dev-verify [dotnet\|angular]` | Post-change verification — auto-detects .NET and Angular |
| **TDD** | `/dev-tdd [dotnet\|angular]` | Test-driven development — auto-detects stack from context |
| **Perf Profile** | `/dev-perf` | Performance profiling via Aspire distributed traces |
| **Search First** | `/dev-search-first` | Research existing solutions before writing custom code |
| **Blueprint** | `/dev-blueprint` | Multi-session construction plans with dependency graphs |
| **Iterative Retrieval** | *(agent-only)* | Progressive context refinement for sub-agents |
| **Security** | `/dev-security [dotnet\|angular]` | Security review — auto-detects .NET and Angular |
| **Dependencies** | `/dev-dependency [nuget\|npm]` | Audit and update packages — auto-detects NuGet and npm |
| **.NET Build** | *(auto)* | MSBuild diagnosis — binlog analysis, incremental builds, antipatterns |
| **.NET EF Core** | *(auto)* | EF Core optimization — N+1 detection, query splitting, migrations |
| **.NET Migrate** | `/dev-dotnet-migrate` | .NET version migration — 8→9, 9→10, 10→11, nullable, AOT |
| **Doc Init** | `/doc-init` | Bootstrap documentation from existing codebase |
| **PRD** | `/doc-prd` | Generate Product Requirements Document |
| **RFC** | `/doc-rfc` | Generate Request for Comments |
| **Design Doc** | `/doc-design` | Generate technical design document |
| **ADR** | `/doc-adr` | Generate Architecture Decision Record (MADR) |
| **C4 Diagram** | `/viz-c4-diagram` | Generate C4 architecture diagrams (Mermaid) |
| **Runbook** | `/doc-runbook` | Generate operational runbook |
| **Post-Mortem** | `/doc-postmortem` | Generate blameless incident post-mortem |
| **Spike** | `/doc-spike` | Generate research/spike report |
| **VitePress** | `/tool-vitepress` | Render docs as browsable site |
| **UX Study** | `/tool-ux-study` | Run think-aloud usability study with AI testers |
| **Worktree** | `/tool-worktree` | Manage bare + worktree repos, sync branches with main |
| **Agentsandbox Merge** | `/tool-agentsandbox-merge` | Merge agentsandbox session work back into target branch |

## How It Works

```
┌─ SESSION START ─────────────────────────────────────────┐
│  Heartbeat loads: SOUL → USER → MEMORY → daily files    │
│  Reads workflow.json → knows where docs repo lives      │
│  Greets you with context from recent sessions           │
├─────────────────────────────────────────────────────────┤
│  WORK                                                    │
│  Use doc-* skills to generate docs → output to docs repo │
│  Decisions and learnings logged to daily memory          │
├─────────────────────────────────────────────────────────┤
│  WRAP-UP                                                 │
│  Reviews deliverables → distills learnings               │
│  Prompts: "Any decisions that need an ADR?"              │
│  Prompts: "Architecture changed — update C4 diagrams?"   │
└─────────────────────────────────────────────────────────┘
```

## Multi-Repo Architecture

Multiple projects can share a single documentation repo:

```
~/repos/
├── agentic-dev-workflow/          # This repo (source of truth for skills + templates)
├── my-api/                  # Project A
│   ├── workflow.json        #   → points to docs repo
│   └── .claude/skills/      #   → adopted skills
├── my-frontend/             # Project B
│   ├── workflow.json        #   → points to same docs repo
│   └── .claude/skills/      #   → adopted skills
└── my-docs/                 # Shared documentation repo
    ├── templates/           #   → document templates
    ├── adr/                 #   → Architecture Decision Records
    ├── architecture/        #   → C4 diagrams
    ├── rfc/                 #   → RFCs
    └── .vitepress/          #   → renders as browsable site
```

## Hooks

Hooks automate session management — no manual `/meta-wrap-up` needed. Each hook has a `.ps1` (PowerShell Core) script for cross-platform support.

| Hook | Event | What it does |
|------|-------|-------------|
| `on-prompt-submit` | User sends message | Detects "bye", "exit", "done" etc. → auto-triggers wrap-up |
| `on-pre-compact` | Context window full | Flushes unsaved session context to daily memory |
| `on-session-end` | Session closes | Writes end marker, updates session count |
| `on-suggest-compact` | Before Edit/Write | Counts tool calls, suggests `/compact` at logical intervals |
| `on-doc-file-warn` | Before Write | Warns about .md files in non-standard locations |
| `on-quality-gate` | After Edit/Write | Runs format/lint checks on edited .cs/.ts/.scss files (async) |
| `on-cost-track` | After each response | Logs token usage + estimated cost in EUR to `~/.claude/metrics/` |

Just type "bye" or "done" and the wrap-up runs automatically.

Hooks support three profiles (`minimal`/`standard`/`strict`) controlled by `AW_HOOK_PROFILE`. See [Hooks](docs/hooks.md).

## AgentSandbox

AgentSandbox (`asb`) is a shell function (not included in this repo — lives in personal dotfiles) that launches Claude Code inside a sandboxed rootless Podman container with `--dangerously-skip-permissions`. Each session gets its own isolated workspace, dedicated podman service, and optional network proxy with secret substitution.

```bash
asb my-experiment       # new session — creates worktrees, launches container
asb -r my-experiment    # resume a stopped session (fresh container, same worktrees)
asb -r                  # list all sessions (running + stopped)
asbs                    # sync: fetch + merge main into current asb branch
asbc                    # cleanup: interactive fzf-based worktree removal
asbl                    # log: view session history
```

**On startup**, AgentSandbox:

1. Creates a task directory at `~/Repository/agentsandbox/<session>/`
2. Creates git worktrees for the current repo on an `asb/<branch>-<session>` branch
3. Processes `workspace.json` — creates worktrees for additional repos, copies references, configures tmux tabs
4. Starts a dedicated per-session podman service with isolated storage, network, and socket
5. Starts the network proxy (if `~/.config/agentsandbox/proxy-secrets.json` exists) — mitmproxy + WireGuard tunnel + kill-switch
6. Starts a repo request watcher — monitors `.requests/` for Claude to ask for access to additional repos
7. Launches the container — rootless podman, `--cap-drop=ALL`, `--security-opt=no-new-privileges`, 8GB RAM, 4 CPUs

**Inside the container**, the entrypoint configures git, installs proxy CA certs, sets up Aspire MCP, starts socat port-forwarding for DCP containers, and launches tmux with a Claude tab and a shell tab. On exit, uncommitted changes are auto-committed to the worktree branch.

### workspace.json

A `workspace.json` in the primary repo defines multi-repo projects:

```json
{
  "workspaces": [
    { "repo": "my-project.site" },
    { "repo": "my-project.shared" }
  ],
  "references": ["~/Documents/api-spec.md"],
  "tabs": [
    { "name": "apphost", "dir": "my-project.api", "cmd": "dotnet run" },
    { "name": "site", "dir": "my-project.site", "cmd": "pnpm dev" }
  ]
}
```

- **workspaces** — additional repos get worktrees mounted as siblings under `/workspace/`
- **references** — files copied as read-only snapshots into `.references/`
- **tabs** — additional tmux windows inside the container

### Repo request pattern

During a session, Claude can request access to repos it wasn't started with by writing to `/workspace/.requests/`. The host-side watcher shows a prompt: **Workspace** (read-write worktree), **Reference** (read-only snapshot), or **Deny**.

### Network proxy + secret substitution

When `proxy-secrets.json` exists, sessions run through a 3-container architecture:

```
asb-proxy-<session>   mitmproxy (WireGuard server + secret substitution addon)
        ▲ WireGuard tunnel
asb-guard-<session>   boringtun (WireGuard client + policy routing kill-switch)
        │ shared network namespace
asb-<session>         Claude Code (cap-drop=ALL, no direct internet)
```

Real API keys never enter the container. The proxy generates placeholder env vars that Claude uses; when a request goes to an allowed host, the proxy swaps the placeholder with the real key. Requests to non-allowed hosts with placeholders get blocked with a 403. If the tunnel drops, the kill-switch silently drops all traffic (policy routing, no kernel modules needed).

### Security layers

| Layer | What it does |
|-------|-------------|
| Rootless podman + `--cap-drop=ALL` | Unprivileged user namespace, no capabilities |
| `--security-opt=no-new-privileges` | No privilege escalation |
| Task-scoped mount | Only the task dir is visible, not home or working directory |
| Security guard hook | PreToolUse hook blocks env reading, container CLI, restricted egress |
| Network proxy (optional) | WireGuard tunnel + secret placeholders + network allowlist |
| Kill-switch (optional) | Policy routing — if tunnel drops, all traffic dropped |
| Repo allowlist | Watcher only approves paths under allowed directories |

When done, use `/tool-agentsandbox-merge` from your main branch to review and merge the work back.

This pairs with the bare + worktree repo layout managed by `/tool-worktree`.

## Compatibility

Built for **Claude Code** but also works with **[opencode](https://opencode.ai)**:

| Feature | Claude Code | opencode | How |
|---------|-------------|----------|-----|
| Instructions | `CLAUDE.md` (native) | `AGENTS.md` → symlink to `CLAUDE.md` | Shared file |
| Skills | `.claude/skills/` (native) | Scans `.claude/skills/` automatically | Same SKILL.md standard |
| Skills (other tools) | — | `.agents/skills/` (Codex CLI, Cursor) | Symlink to `.claude/skills/` |
| Hooks | `settings.json` → `.ps1` scripts | `.opencode/plugins/hooks.ts` → same `.ps1` scripts | JS wrapper calls PowerShell |

Both tools run the **same PowerShell hook scripts** — Claude Code calls them directly, opencode calls them through a thin TypeScript plugin that bridges events to `pwsh` invocations.

### Requirements

- **PowerShell Core** (`pwsh`) on PATH — required for hooks in both tools
- **Bun** — required by opencode (runs the TypeScript plugin natively)

### Windows symlinks

`AGENTS.md` is a symlink to `CLAUDE.md`. On Linux/macOS this works automatically. On Windows:

```
git config core.symlinks true
```

(Requires Developer Mode enabled in Windows Settings.)

## Documentation

- [Getting Started](docs/getting-started.md) — first-time setup and bootstrapping
- [Architecture](docs/architecture.md) — directory structure, context loading, token budgets
- [Context Files](docs/context-files.md) — SOUL.md, USER.md, MEMORY.md explained
- [Skills System](docs/skills-system.md) — skill structure, naming, frontmatter
- [Skill Adoption](docs/skill-adoption.md) — evaluating and installing external skills
- [Hooks](docs/hooks.md) — automatic session management via Claude Code hooks
- [Daily Workflow](docs/daily-workflow.md) — day-to-day usage
- [Multi-Repo Setup](docs/multi-repo-setup.md) — connecting projects to a docs repo
- [Sources](docs/sources.md) — research and references
