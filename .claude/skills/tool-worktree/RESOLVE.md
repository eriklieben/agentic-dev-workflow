# Repository Path Resolution

All cross-repo references in `workflow.json` use **repo names**, not paths. This makes them portable across bare+worktree layouts, agentsandbox containers, and normal clones.

## How It Works

`workflow.json` stores repo names:

```json
{
  "docsRepo": "my-docs",
  "workflowRepo": "agentic-workflow"
}
```

To resolve a repo name to an actual path, use the resolver script (`.claude/skills/tool-worktree/scripts/resolve-repo.ps1`):

```powershell
# From any worktree in any layout:
$path = & .claude/skills/tool-worktree/scripts/resolve-repo.ps1 my-docs
```

Or resolve inline when you need a docs path:

```powershell
$docs_root = & .claude/skills/tool-worktree/scripts/resolve-repo.ps1 my-docs
$templates = "$docs_root/templates"
$adr_output = "$docs_root/adr"
```

## Resolution Algorithm

1. Find the git root of the current repo
2. Detect the layout:
   - **bare+worktree**: parent has `.bare/` → collection is grandparent, target gets a worktree suffix
   - **flat** (agentsandbox/normal): collection is parent, target is a direct subdirectory
3. For bare+worktree targets, pick the best worktree:
   - `--branch <name>` if specified and exists
   - Matching current branch name if it exists (e.g., both repos have `feature-xyz`)
   - Default branch (usually `main`)

## Reading workflow.json in Skills

When a skill reads `workflow.json`, resolve paths like this:

```powershell
$config = Get-Content workflow.json | ConvertFrom-Json
$docs_repo = $config.docsRepo

if ($docs_repo -eq ".") {
    $docs_root = "."
} else {
    $docs_root = & .claude/skills/tool-worktree/scripts/resolve-repo.ps1 $docs_repo
}

$templates_dir = "$docs_root/$($config.docs.templates)"
$adr_dir = "$docs_root/$($config.docs.output.adr)"
```

## Layouts Supported

```
LOCAL (bare+worktree):           AGENTSANDBOX (flat):           NORMAL CLONE:
~/Repository/                    /workspace/                  ~/projects/
├── api/                         ├── api/      ← worktree    ├── api/       ← normal .git/
│   ├── .bare/                   ├── docs/     ← worktree    ├── docs/      ← normal .git/
│   ├── main/     ← resolve     └── CLAUDE.md               └── ...
│   └── feature/  ← or this
├── docs/
│   ├── .bare/
│   └── main/     ← found!
```
