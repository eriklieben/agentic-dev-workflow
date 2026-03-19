# workflow.json Specification

The `workflow.json` file lives in each project root and tells skills where to find
templates and where to output generated documents.

## Schema

```json
{
  "docsRepo": "my-docs",
  "workflowRepo": "agentic-workflow",
  "project": {
    "name": "my-api",
    "type": "api"
  },
  "docs": {
    "templates": "templates",
    "output": {
      "adr": "adr",
      "rfc": "rfc",
      "design": "design",
      "prd": "prd",
      "runbook": "runbooks",
      "postmortem": "postmortems",
      "spike": "spikes",
      "architecture": "architecture"
    }
  }
}
```

## Field Reference

| Field | Required | Description |
|-------|---------|-------------|
| `docsRepo` | Yes | Repo name (resolved at runtime) or `"."` if this IS the docs repo |
| `workflowRepo` | No | Repo name for the agentic-workflow repo (for updates) |
| `project.name` | Yes | Human-readable project name |
| `project.type` | Yes | One of: `api`, `frontend`, `library`, `docs`, `infra` |
| `docs.templates` | No | Subdirectory within docs repo for templates (default: `templates`) |
| `docs.output.*` | No | Subdirectories within docs repo for output (defaults shown above) |

## Path Resolution

Repo names are resolved at runtime by the `resolve-repo` script (`.claude/skills/tool-worktree/scripts/resolve-repo.ps1`), which supports three layouts:

| Layout | How it finds siblings |
|--------|----------------------|
| **bare+worktree** | Up past worktree dir, up past `.bare/` root, find sibling by name, pick best worktree |
| **agentsandbox** | Repos are flat siblings under `/workspace/` |
| **normal clone** | Repos are siblings in the same parent directory |

```powershell
# Resolve a repo name to a path:
$docsRepo = (Get-Content workflow.json | ConvertFrom-Json).docsRepo
$docs_root = & .claude/skills/tool-worktree/scripts/resolve-repo.ps1 $docsRepo

# Then use output subdirs from workflow.json:
$adr_dir = "$docs_root/$((Get-Content workflow.json | ConvertFrom-Json).docs.output.adr)"
```

For bare+worktree repos, the resolver prefers a matching branch name (e.g., if you're on
`feature-xyz` in the API repo, it looks for `feature-xyz` in the docs repo first, then
falls back to `main`).

## How Skills Use It

Every `doc-*` skill follows this pattern:

1. Read `workflow.json` from the current project root
2. If `docsRepo` is `"."`, use local paths
3. Otherwise, resolve the repo name via `pwsh .claude/skills/tool-worktree/scripts/resolve-repo.ps1`
4. Read the template from `<resolved>/<templates-subdir>/<type>.md`
5. Write the generated document to `<resolved>/<output-subdir>/<slug>.md`

If `workflow.json` doesn't exist (standalone workflow repo), skills fall back to
local paths: `templates/` for input, `docs/` for output.
