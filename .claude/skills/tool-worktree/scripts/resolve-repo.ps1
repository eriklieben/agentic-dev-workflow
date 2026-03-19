# resolve-repo.ps1 — find a sibling repository by name
#
# Works in all layouts:
#   bare+worktree:  ~/Repository/api/main/  → ~/Repository/docs/main/
#   agentsandbox:      /workspace/api/          → /workspace/docs/
#   normal clone:   ~/projects/api/          → ~/projects/docs/
#
# Usage:
#   resolve-repo.ps1 <repo-name> [-Branch <branch>]
#   resolve-repo.ps1 my-docs
#   resolve-repo.ps1 my-docs -Branch feature-xyz
#
# Prints the resolved path to stdout. Exits 1 if not found.

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$RepoName,

    [Parameter()]
    [string]$Branch = ""
)

$ErrorActionPreference = "Stop"

# Step 1: Find the git root of the current repo
try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0) { throw }
} catch {
    Write-Error "resolve-repo: not in a git repository"
    exit 1
}

# Step 2: Detect layout
$bareIndicator = Join-Path (Split-Path $gitRoot -Parent) ".bare"

if (Test-Path $bareIndicator -PathType Container) {
    # bare+worktree: gitRoot = ~/Repository/api/main
    # bareRoot = ~/Repository/api
    # collection = ~/Repository
    $bareRoot = (Resolve-Path (Split-Path $gitRoot -Parent)).Path
    $collection = (Resolve-Path (Split-Path $bareRoot -Parent)).Path
    $currentBranch = Split-Path $gitRoot -Leaf

    $targetBare = Join-Path $collection $RepoName

    $targetHasBare = Test-Path (Join-Path $targetBare ".bare") -PathType Container
    $targetHasGit = Test-Path (Join-Path $targetBare ".git")

    if (-not $targetHasBare -and -not $targetHasGit) {
        Write-Error "resolve-repo: $RepoName not found at $targetBare"
        exit 1
    }

    if ($targetHasBare) {
        # Target is also bare+worktree — find the best worktree
        # Priority: preferred branch > matching current branch > default branch
        if ($Branch -and (Test-Path (Join-Path $targetBare $Branch) -PathType Container)) {
            Write-Output (Join-Path $targetBare $Branch)
        } elseif ($currentBranch -and (Test-Path (Join-Path $targetBare $currentBranch) -PathType Container)) {
            Write-Output (Join-Path $targetBare $currentBranch)
        } else {
            # Find the default branch worktree
            $defaultBranch = $null
            try {
                $remoteInfo = git -C $targetBare remote show origin 2>$null
                $headLine = $remoteInfo | Select-String "HEAD branch:"
                if ($headLine) {
                    $defaultBranch = ($headLine -replace '.*HEAD branch:\s*', '').Trim()
                }
            } catch {}
            if (-not $defaultBranch) { $defaultBranch = "main" }

            if (Test-Path (Join-Path $targetBare $defaultBranch) -PathType Container) {
                Write-Output (Join-Path $targetBare $defaultBranch)
            } else {
                # Fall back to first worktree found
                $firstWt = $null
                try {
                    $worktreeOutput = git -C $targetBare worktree list --porcelain 2>$null
                    $worktreeLine = $worktreeOutput | Select-String "^worktree " | Select-Object -First 1
                    if ($worktreeLine) {
                        $firstWt = ($worktreeLine -replace '^worktree\s+', '').Trim()
                    }
                } catch {}

                if ($firstWt) {
                    Write-Output $firstWt
                } else {
                    Write-Error "resolve-repo: no worktree found for $RepoName"
                    exit 1
                }
            }
        }
    } else {
        # Target is a normal clone
        Write-Output $targetBare
    }
} else {
    # flat layout (agentsandbox or normal clone)
    # gitRoot = /workspace/api or ~/projects/api
    # collection = /workspace or ~/projects
    $collection = (Resolve-Path (Split-Path $gitRoot -Parent)).Path

    $target = Join-Path $collection $RepoName

    if (Test-Path $target -PathType Container) {
        Write-Output $target
    } else {
        Write-Error "resolve-repo: $RepoName not found at $target"
        exit 1
    }
}
