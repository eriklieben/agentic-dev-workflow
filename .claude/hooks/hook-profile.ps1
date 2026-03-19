# Shared hook profile control.
# Dot-source this from any hook to get profile-based enable/disable.
#
# Profiles:
#   minimal  — session lifecycle + cost tracking (prompt-submit, pre-compact, session-end, cost-track)
#   standard — lifecycle + quality guards (doc-file-warn, suggest-compact, quality-gate) (default)
#   strict   — everything
#
# Control via environment:
#   AW_HOOK_PROFILE=minimal|standard|strict  (default: standard)
#   AW_DISABLED_HOOKS=comma,separated,ids    (disable specific hooks by id)
#
# Usage in hook scripts:
#   . "$PSScriptRoot/hook-profile.ps1"
#   if (-not (Test-HookEnabled "suggest-compact" "standard,strict")) { exit 0 }

$script:AwHookProfile = if ($env:AW_HOOK_PROFILE) { $env:AW_HOOK_PROFILE } else { "standard" }

function Test-HookEnabled {
    param(
        [string]$HookId,
        [string]$AllowedProfiles = "standard,strict"
    )

    # Check if explicitly disabled
    if ($env:AW_DISABLED_HOOKS) {
        $disabled = $env:AW_DISABLED_HOOKS -split ','
        if ($disabled -contains $HookId) { return $false }
    }

    # Check if current profile is in the allowed list
    $allowed = $AllowedProfiles -split ','
    if ($allowed -contains $script:AwHookProfile) { return $true }

    return $false
}
