# Hook: PreToolUse (Edit|Write)
# Counts tool calls and suggests manual compaction at logical intervals.
# Why: auto-compact happens at arbitrary points, often mid-task.
# Strategic compaction preserves context through logical phases.
#
# Configure threshold: AW_COMPACT_THRESHOLD (default: 50)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "suggest-compact" "standard,strict")) { exit 0 }

$Input = $input | Out-String

$threshold = if ($env:AW_COMPACT_THRESHOLD) { [int]$env:AW_COMPACT_THRESHOLD } else { 50 }
$sessionId = if ($env:CLAUDE_SESSION_ID) { $env:CLAUDE_SESSION_ID } else { "default" }
# Sanitize session ID for use as filename
$sessionId = $sessionId -replace '[^a-zA-Z0-9_-]', ''
$counterFile = Join-Path ([System.IO.Path]::GetTempPath()) "aw-tool-count-$sessionId"

# Read or initialize counter
$count = 1
if (Test-Path $counterFile) {
    $raw = Get-Content $counterFile -ErrorAction SilentlyContinue
    if ($raw -match '^\d+$') { $count = [int]$raw + 1 }
}

Set-Content -Path $counterFile -Value $count

# Suggest compact at threshold
if ($count -eq $threshold) {
    [Console]::Error.WriteLine("[StrategicCompact] $threshold tool calls reached — consider /compact if transitioning phases")
}

# Suggest at regular intervals after threshold (every 25 calls)
if ($count -gt $threshold) {
    $past = $count - $threshold
    if (($past % 25) -eq 0) {
        [Console]::Error.WriteLine("[StrategicCompact] $count tool calls — good checkpoint for /compact if context is stale")
    }
}

exit 0
