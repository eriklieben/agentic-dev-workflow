# Hook: SessionEnd
# Lightweight cleanup when a session terminates.
# Cannot interact with Claude — runs after session is already closing.
# Default timeout: 1.5s (keep this fast).

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "session-end" "minimal,standard,strict")) { exit 0 }

$Input = $input | Out-String
$json = $Input | ConvertFrom-Json
$cwd = if ($json.cwd) { $json.cwd } else { "" }
$sessionId = if ($json.session_id) { $json.session_id } else { "unknown" }
$exitReason = if ($json.source) { $json.source } else { "unknown" }

# Only act if we're in a workflow-enabled project
if (-not (Test-Path (Join-Path $cwd "context/memory"))) { exit 0 }

$dailyFile = Join-Path $cwd "context/memory/$(Get-Date -Format 'yyyy-MM-dd').md"
$stateFile = Join-Path $cwd "context/memory/heartbeat-state.json"

# Calculate session cost from metrics (if available)
$costSummary = ""
$metricsFile = Join-Path $HOME ".claude/metrics/costs.jsonl"
if (Test-Path $metricsFile) {
    try {
        $entries = Get-Content $metricsFile | ForEach-Object { $_ | ConvertFrom-Json } |
            Where-Object { $_.session_id -eq $sessionId }
        if ($entries) {
            $totalCost = ($entries | Measure-Object -Property estimated_cost_eur -Sum).Sum
            $totalInput = ($entries | Measure-Object -Property input_tokens -Sum).Sum
            $totalOutput = ($entries | Measure-Object -Property output_tokens -Sum).Sum
            if ($totalCost -gt 0) {
                $costFormatted = $totalCost.ToString("F2")
                $inputK = [math]::Round($totalInput / 1000)
                $outputK = [math]::Round($totalOutput / 1000)
                $costSummary = " | cost: EUR${costFormatted} (${inputK}K in / ${outputK}K out)"
            }
        }
    } catch {
        # Silently skip cost calculation on error
    }
}

# Append session end marker to daily file if it exists
if (Test-Path $dailyFile) {
    $time = Get-Date -Format 'HH:mm'
    Add-Content -Path $dailyFile -Value ""
    Add-Content -Path $dailyFile -Value "---"
    Add-Content -Path $dailyFile -Value "_Session ended at $time (reason: $exitReason)${costSummary}_"
}

# Update session count in heartbeat state
if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json
        $currentCount = if ($state.sessionCount) { [int]$state.sessionCount } else { 0 }
        $state.sessionCount = $currentCount + 1
        $state | ConvertTo-Json -Depth 10 | Set-Content $stateFile
    } catch {
        # Silently skip on error
    }
}

exit 0
