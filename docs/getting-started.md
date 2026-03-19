# Getting Started

## Prerequisites

- [Claude Code](https://code.claude.com) CLI installed
- A git repository you want to work in

## Option A: Standalone (Single Project)

Use agentic-workflow directly as your working directory.

### 1. Clone the repo

```bash
git clone <agentic-workflow-repo-url>
cd agentic-workflow
```

### 2. Fill in your profile

Edit `context/USER.md` with your details — name, role, preferences, tech stack.

### 3. Customize the agent identity

Review `context/SOUL.md`. It defines how the agent behaves. Adjust to match your style.

### 4. Start working

```bash
claude
```

The heartbeat runs automatically when CLAUDE.md is read. It loads your context, creates today's daily memory file, and greets you.

### 5. End a session

Say "wrap up" or run `/meta-wrap-up`. The agent reviews what was done, updates memory, and distills learnings.

---

## Option B: Install into an Existing Project

Use `/meta-bootstrap` to install the workflow into any project, connecting it to a shared documentation repo.

### 1. Set up the repos

```
~/repos/
├── agentic-workflow/       # Clone this repo
├── my-project/           # Your existing project
└── my-docs/              # Documentation repo (existing or new)
```

### 2. Run bootstrap

Start Claude Code in the `agentic-workflow/` directory, then run:

```
/meta-bootstrap ~/repos/my-project --docs-repo ~/repos/my-docs
```

The bootstrap will:

1. Create `workflow.json` in your project (links to docs repo)
2. Create `context/` directory with SOUL.md, USER.md template, MEMORY.md
3. Copy templates to the docs repo
4. Install all workflow skills into `.claude/skills/`
5. Add the heartbeat section to your project's CLAUDE.md
6. Update `.gitignore` for personal context files

### 3. Verify .gitignore

The bootstrap adds these entries to `.gitignore` — verify they're present:

```gitignore
# Agent workflow — personal context (don't commit)
context/USER.md
context/MEMORY.md
context/memory/
```

`context/SOUL.md` is intentionally **not** gitignored — it's shareable project config, not personal data.

### 4. Fill in your profile

```bash
cd ~/repos/my-project
# Edit context/USER.md
```

### 5. Start working

```bash
cd ~/repos/my-project
claude
```

The heartbeat runs, loads context, reads `workflow.json`, and you're ready.

---

## Option C: Bootstrap Documentation for Existing Code

If your project already has a large codebase but little documentation:

```
/doc-init
```

This analyzes your code, git history, dependencies, and domain model, then generates:

- C4 architecture diagrams (system context, containers, components)
- Project evolution timeline (phases, decisions, dependency changes)
- Inferred ADRs from architectural choices found in code
- Domain model reference
- API endpoint reference
- Developer onboarding guide

All generated docs are marked as **drafts** for review. See [Doc Init](skills-reference.md#doc-init) for details.

---

## What Happens at Session Start

When you open Claude Code in a bootstrapped project, the heartbeat runs automatically:

```
1. Read context/SOUL.md          → Agent identity and behavior rules
2. Read context/USER.md          → Your profile and preferences
3. Read context/MEMORY.md        → Long-term curated knowledge
4. Read today's daily memory     → What happened earlier today
5. Read yesterday's daily memory → What happened yesterday
6. Read workflow.json            → Where the docs repo lives
7. Check freshness              → Flag stale files (>30 days old)
8. Greet you                    → Brief greeting with relevant context
```

If the heartbeat didn't run (e.g., first time, CLAUDE.md not yet read), invoke it manually:

```
/meta-heartbeat
```

## What Happens at Session End

Say "wrap up" or run `/meta-wrap-up`:

```
1. Review deliverables          → git status, changed files
2. Update daily memory          → Goal, work done, decisions, learnings, open items
3. Documentation check          → Suggest ADRs for decisions, C4 updates for architecture changes
4. Distill to long-term memory  → Move important insights to MEMORY.md
5. Collect feedback             → "Anything to do differently next time?"
6. Commit (if requested)        → Clean commit message, no AI branding
7. Summary                      → What was done, what's left
```

## Generating Documents

Use the `doc-*` skills to generate documents from templates:

```
/doc-prd "User authentication feature"      → Product Requirements Document
/doc-rfc "Migrate from REST to gRPC"        → Request for Comments
/doc-design "Payment processing system"     → Design Document
/doc-adr "Use PostgreSQL over CosmosDB"     → Architecture Decision Record
/viz-c4-diagram "Payment system" container  → C4 Container Diagram
/doc-runbook "Database failover"            → Operational Runbook
/doc-postmortem "2026-03-15 API outage"     → Blameless Post-Mortem
/doc-spike "Evaluate message queue options" → Spike Report
```

Each skill reads `workflow.json` to determine where templates live and where to output the generated document. If `workflow.json` doesn't exist, it falls back to local `templates/` and `docs/` directories.

## Upgrading

After pulling a new version of agentic-workflow:

```bash
cd ~/repos/agentic-workflow && git pull
```

Then in any bootstrapped project:

```
/meta-upgrade
```

This compares your installed skills against the source repo, shows what changed (new skills, updates), and lets you selectively apply upgrades.

## Directory Structure

After bootstrapping, your project looks like:

```
my-project/
├── CLAUDE.md                     # Your existing CLAUDE.md + heartbeat section
├── workflow.json                 # Points to docs repo and agentic-workflow
├── context/
│   ├── SOUL.md                   # Agent identity (shareable)
│   ├── USER.md                   # Your profile (gitignored)
│   ├── MEMORY.md                 # Long-term knowledge (gitignored)
│   └── memory/                   # Daily session logs (gitignored)
│       ├── 2026-03-16.md
│       └── archive/
├── .claude/
│   └── skills/
│       ├── meta-heartbeat/       # Session start
│       ├── meta-wrap-up/         # Session end
│       ├── meta-upgrade/         # Sync from agentic-workflow
│       ├── doc-prd/              # Document generation
│       ├── doc-adr/              #   ...
│       ├── viz-c4-diagram/       #   ...
│       └── your-custom-skill/    # Project-specific skills (untouched by upgrade)
└── src/                          # Your actual code
```

## Next Steps

- [Architecture](architecture.md) — understand the three-layer context loading
- [Context Files](context-files.md) — learn what goes in SOUL.md, USER.md, MEMORY.md
- [Skills System](skills-system.md) — understand skill structure and naming
- [Multi-Repo Setup](multi-repo-setup.md) — connect multiple projects to one docs repo
- [Daily Workflow](daily-workflow.md) — day-to-day usage tips
