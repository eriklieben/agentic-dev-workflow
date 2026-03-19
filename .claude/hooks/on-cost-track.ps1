# Hook: Stop
# Tracks token usage and estimated cost per response.
# Appends to ~/.claude/metrics/costs.jsonl as JSONL.
#
# Costs are estimated directly in EUR.
# Pricing source: https://docs.anthropic.com/en/docs/about-claude/pricing
#
# To get today's session cost summary (PowerShell):
#   Get-Content ~/.claude/metrics/costs.jsonl | ForEach-Object { $_ | ConvertFrom-Json } |
#     Where-Object { $_.timestamp -like "$(Get-Date -Format 'yyyy-MM-dd')*" } |
#     Measure-Object -Property estimated_cost_eur -Sum |
#     Select-Object Sum, Count

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "cost-track" "minimal,standard,strict")) { exit 0 }

$Input = $input | Out-String
$json = $Input | ConvertFrom-Json

# Parse token usage from stdin JSON
$inputTokens = 0
$outputTokens = 0
if ($json.usage.input_tokens) { $inputTokens = [long]$json.usage.input_tokens }
elseif ($json.token_usage.input_tokens) { $inputTokens = [long]$json.token_usage.input_tokens }
if ($json.usage.output_tokens) { $outputTokens = [long]$json.usage.output_tokens }
elseif ($json.token_usage.output_tokens) { $outputTokens = [long]$json.token_usage.output_tokens }

$model = if ($json.model) { $json.model } else { "unknown" }
$sessionId = if ($env:CLAUDE_SESSION_ID) { $env:CLAUDE_SESSION_ID } else { "default" }

# Skip if no meaningful usage data
if ($inputTokens -eq 0 -and $outputTokens -eq 0) { exit 0 }

# Estimate cost directly in EUR (per 1M tokens)
# Haiku 4.5: €0.92/€4.60, Sonnet 4.5/4.6: €2.76/€13.80, Opus 4.6: €4.60/€23.00
# Based on USD pricing * 0.92 EUR/USD
# Source: https://docs.anthropic.com/en/docs/about-claude/pricing
$inRate = 2.76; $outRate = 13.80  # default to sonnet rates
if ($model -match 'haiku') { $inRate = 0.92; $outRate = 4.60 }
elseif ($model -match 'opus') { $inRate = 4.60; $outRate = 23.00 }

# Calculate cost in EUR
$costEur = ($inputTokens / 1000000.0) * $inRate + ($outputTokens / 1000000.0) * $outRate
$costEurStr = $costEur.ToString("F6")

# Ensure metrics directory exists
$metricsDir = Join-Path $HOME ".claude/metrics"
if (-not (Test-Path $metricsDir)) { New-Item -ItemType Directory -Path $metricsDir -Force | Out-Null }

# Append as JSONL
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$line = "{`"timestamp`":`"$timestamp`",`"session_id`":`"$sessionId`",`"model`":`"$model`",`"input_tokens`":$inputTokens,`"output_tokens`":$outputTokens,`"estimated_cost_eur`":$costEurStr}"
Add-Content -Path (Join-Path $metricsDir "costs.jsonl") -Value $line

exit 0
