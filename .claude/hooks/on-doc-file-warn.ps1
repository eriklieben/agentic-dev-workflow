# Hook: PreToolUse (Write)
# Warns when Claude tries to create non-standard documentation files.
# Prevents repo clutter from random .md files outside known locations.
# Exit 0 always (warns only, never blocks).

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "doc-file-warn" "standard,strict")) { exit 0 }

$Input = $input | Out-String
$json = $Input | ConvertFrom-Json
$filePath = if ($json.tool_input.file_path) { $json.tool_input.file_path } else { "" }

# Skip if no file path or not a markdown/text file
if (-not $filePath) { exit 0 }
if ($filePath -notmatch '\.(md|txt)$') { exit 0 }

$baseName = Split-Path -Leaf $filePath

# Allow known standard files
$standardFiles = @(
    "README.md", "CLAUDE.md", "AGENTS.md", "CONTRIBUTING.md", "CHANGELOG.md", "LICENSE.md",
    "SKILL.md", "MEMORY.md", "SOUL.md", "USER.md"
)
if ($standardFiles -contains $baseName) { exit 0 }
if ($baseName -match '\.plan\.md$') { exit 0 }

# Allow files in known doc locations
$allowedPaths = @("docs/", "templates/", "context/", ".claude/commands/", ".claude/plans/", ".claude/skills/",
                   "memory/", "adr/", "architecture/", "reference/", "guides/")
foreach ($allowed in $allowedPaths) {
    if ($filePath -match [regex]::Escape($allowed)) { exit 0 }
}

# Warn about non-standard location
[Console]::Error.WriteLine("[DocFileWarning] Non-standard documentation file: $filePath")
[Console]::Error.WriteLine("[DocFileWarning] Consider placing in docs/, context/, or .claude/ instead")

exit 0
