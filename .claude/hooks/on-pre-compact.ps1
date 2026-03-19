# Hook: PreCompact
# Before context compaction, flush any unsaved session notes to the daily memory file.
# This prevents losing context that hasn't been written to disk yet.

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "pre-compact" "minimal,standard,strict")) { exit 0 }

$Input = $input | Out-String
$json = $Input | ConvertFrom-Json
$cwd = if ($json.cwd) { $json.cwd } else { "" }
$trigger = if ($json.trigger) { $json.trigger } else { "auto" }

$dailyFile = Join-Path $cwd "context/memory/$(Get-Date -Format 'yyyy-MM-dd').md"

# Only act if we're in a workflow-enabled project
if (-not (Test-Path (Join-Path $cwd "context/memory"))) { exit 0 }

# Inject instructions for Claude to save context before compaction
$time = Get-Date -Format 'HH:mm'
@"
[PRE-COMPACTION] Context window is about to be compressed ($trigger).
Before compaction happens, ensure any important unsaved session context is written to disk:
1. Update $dailyFile with current session progress (goal, work done, decisions, open items)
2. If significant learnings were made, update context/MEMORY.md
3. Note in the daily file: "--- Context compacted at $time ---"
This prevents losing unwritten context during compaction.
"@

exit 0
