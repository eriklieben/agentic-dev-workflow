# Multi-Repo Setup

How to connect multiple projects to a shared documentation repository.

## Why Multi-Repo?

Most teams have multiple codebases but one set of documentation:

- **Architecture decisions** apply across projects (ADRs)
- **C4 diagrams** show how systems interact
- **Runbooks** reference multiple services
- **A single docs site** is easier to navigate than docs scattered across repos

## Architecture

```
agentic-workflow/              ← Source of truth for skills + templates
    ├── .claude/skills/      ← Master copies of all skills
    └── templates/           ← Master copies of all templates

my-api/                      ← Project A
    ├── workflow.json        ← Points to docs repo + agentic-workflow
    ├── context/             ← Personal context (gitignored)
    └── .claude/skills/      ← Adopted copies of workflow skills
                                + project-specific skills

my-frontend/                 ← Project B
    ├── workflow.json        ← Points to same docs repo
    ├── context/             ← Personal context (gitignored)
    └── .claude/skills/      ← Adopted copies of workflow skills
                                + project-specific skills (playwright, etc.)

my-docs/                     ← Shared documentation repo
    ├── templates/           ← Document templates (copied from agentic-workflow)
    ├── adr/                 ← Architecture Decision Records
    ├── rfc/                 ← Requests for Comments
    ├── design/              ← Design Documents
    ├── architecture/        ← C4 diagrams, evolution timeline
    ├── reference/           ← Domain model, API endpoints
    ├── runbooks/            ← Operational procedures
    ├── postmortems/         ← Incident reports
    ├── spikes/              ← Research reports
    ├── prd/                 ← Product Requirements Documents
    └── .vitepress/          ← Renders everything as a browsable site
```

## Setup

### 1. Bootstrap each project

From agentic-workflow, run bootstrap for each project:

```
/meta-bootstrap ~/repos/my-api --docs-repo ~/repos/my-docs
/meta-bootstrap ~/repos/my-frontend --docs-repo ~/repos/my-docs
```

### 2. Review workflow.json

Each project gets a `workflow.json` that looks like:

```json
{
  "docsRepo": "../my-docs",
  "workflowRepo": "../agentic-workflow",
  "project": {
    "name": "my-api",
    "type": "api"
  },
  "docs": {
    "templates": "../my-docs/templates",
    "output": {
      "adr": "../my-docs/adr",
      "rfc": "../my-docs/rfc",
      "design": "../my-docs/design",
      "prd": "../my-docs/prd",
      "runbook": "../my-docs/runbooks",
      "postmortem": "../my-docs/postmortems",
      "spike": "../my-docs/spikes",
      "architecture": "../my-docs/architecture"
    }
  }
}
```

Paths are **relative to the project root**.

### 3. Templates go to the docs repo

The bootstrap copies templates from `agentic-workflow/templates/` to `my-docs/templates/`. If the docs repo already has templates, bootstrap compares and reports differences.

## How Documents Flow

```
Working in my-api/                     Output goes to my-docs/
──────────────────                     ──────────────────────
/doc-adr "Use PostgreSQL"         →    my-docs/adr/0012-use-postgresql.md
/viz-c4-diagram "API" container   →    my-docs/architecture/api-c4.md
/doc-runbook "DB failover"        →    my-docs/runbooks/db-failover.md

Working in my-frontend/
──────────────────────
/doc-adr "Use Angular over React" →    my-docs/adr/0013-use-angular.md
/doc-design "Design system"       →    my-docs/design/design-system.md
```

Both projects write to the same docs repo. ADR numbers auto-increment across all projects.

## Committing Across Repos

When you run `/meta-wrap-up` and choose to commit:

- Changes **in the project repo** (code, context files, skills) → committed to the project repo
- Changes **in the docs repo** (generated documents) → committed to the docs repo separately

The wrap-up handles this by detecting which files belong to which repo.

## Upgrading All Projects

When agentic-workflow gets new skills or template updates:

```bash
# Pull latest
cd ~/repos/agentic-workflow && git pull

# Upgrade each project
cd ~/repos/my-api && claude -c "/meta-upgrade"
cd ~/repos/my-frontend && claude -c "/meta-upgrade"
```

The upgrade skill compares installed skills against the source and offers selective updates. Project-specific skills are never touched.

## Context Independence

Each project has its own independent context:

| File | Shared? | Notes |
|------|---------|-------|
| `workflow.json` | No | Project-specific paths and config |
| `context/SOUL.md` | No | Can be customized per project |
| `context/USER.md` | No | Personal, gitignored |
| `context/MEMORY.md` | No | Per-project learnings, gitignored |
| `context/memory/*.md` | No | Per-project daily logs, gitignored |
| `.claude/skills/` | Partially | Workflow skills are copies; project skills are unique |
| Templates | Yes | Live in the shared docs repo |
| Generated docs | Yes | Live in the shared docs repo |

## Adding a New Project

1. Run `/meta-bootstrap` from agentic-workflow
2. Fill in `context/USER.md`
3. Optionally customize `context/SOUL.md` for this project's tech stack
4. Start a session — the heartbeat loads everything automatically

## Removing a Project

1. Delete the project's `context/`, `workflow.json`, and workflow skills from `.claude/skills/`
2. Documents already in the docs repo stay (they're shared knowledge)
