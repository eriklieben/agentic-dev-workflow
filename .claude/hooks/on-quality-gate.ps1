# Hook: PostToolUse (Edit|Write)
# Lightweight quality gate — runs format/lint checks on just the edited file.
# Async, never blocks. Reports issues via stderr.
#
# Supports:
#   .cs files  → dotnet format --include <file> --verify-no-changes
#   .ts files  → npx eslint <file> (if eslint config exists)
#   .scss/.css → npx stylelint <file> (if stylelint config exists)
#
# Control:
#   AW_QUALITY_GATE_FIX=true  → auto-fix instead of check-only
#   AW_QUALITY_GATE=off       → disable entirely (lighter than AW_DISABLED_HOOKS)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "quality-gate" "standard,strict")) { exit 0 }

# Quick kill switch
if ($env:AW_QUALITY_GATE -eq 'off') { exit 0 }

$Input = $input | Out-String
$json = $Input | ConvertFrom-Json
$filePath = if ($json.tool_input.file_path) { $json.tool_input.file_path } else { "" }

# Skip if no file path
if (-not $filePath) { exit 0 }

# Skip test files, generated files, config files
$skipPatterns = @('Tests.cs$', 'Test.cs$', '\.spec\.ts$', '\.test\.ts$',
                  '[/\\]bin[/\\]', '[/\\]obj[/\\]', '[/\\]node_modules[/\\]', '[/\\]dist[/\\]',
                  '[/\\]\.claude[/\\]', '[/\\]context[/\\]', '[/\\]docs[/\\]',
                  '\.(json|md|txt|yml|yaml)$')
foreach ($pattern in $skipPatterns) {
    if ($filePath -match $pattern) { exit 0 }
}

$fixMode = $env:AW_QUALITY_GATE_FIX -eq 'true'

# --- C# files ---
if ($filePath -match '\.cs$') {
    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { exit 0 }

    # Find nearest .sln or .csproj by walking up
    $dir = Split-Path $filePath -Parent
    $projectRoot = $null
    while ($dir -and $dir -ne [System.IO.Path]::GetPathRoot($dir)) {
        if ((Get-ChildItem -Path $dir -Filter '*.sln' -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Path $dir -Filter '*.csproj' -ErrorAction SilentlyContinue)) {
            $projectRoot = $dir
            break
        }
        $dir = Split-Path $dir -Parent
    }

    if (-not $projectRoot) { exit 0 }

    $relPath = [System.IO.Path]::GetRelativePath($projectRoot, $filePath)
    if (-not $relPath) { exit 0 }

    if ($fixMode) {
        $output = & dotnet format $projectRoot --include $relPath --verbosity quiet 2>&1
        if ($LASTEXITCODE -ne 0) {
            [Console]::Error.WriteLine("[QualityGate] dotnet format --fix failed for $relPath")
        }
    } else {
        $output = & dotnet format $projectRoot --include $relPath --verify-no-changes --verbosity quiet 2>&1
        if ($output) {
            [Console]::Error.WriteLine("[QualityGate] Format issues in ${relPath}:")
            $output | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine($_) }
            [Console]::Error.WriteLine("[QualityGate] Run 'dotnet format' or use --fix to auto-fix")
        }
    }

    exit 0
}

# --- TypeScript files ---
if ($filePath -match '\.ts$') {
    $dir = Split-Path $filePath -Parent
    $hasEslint = $false
    $checkDir = $dir
    while ($checkDir -and $checkDir -ne [System.IO.Path]::GetPathRoot($checkDir)) {
        $eslintConfigs = @('.eslintrc.json', '.eslintrc.js', '.eslintrc.yml', 'eslint.config.js', 'eslint.config.mjs')
        foreach ($config in $eslintConfigs) {
            if (Test-Path (Join-Path $checkDir $config)) { $hasEslint = $true; break }
        }
        if ($hasEslint) { break }
        $checkDir = Split-Path $checkDir -Parent
    }

    if (-not $hasEslint) { exit 0 }
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { exit 0 }

    if ($fixMode) {
        & npx eslint --fix $filePath 2>&1 | Select-Object -First 10 | ForEach-Object { [Console]::Error.WriteLine($_) }
    } else {
        $output = & npx eslint --max-warnings 0 $filePath 2>&1
        $issues = $output | Where-Object { $_ -match 'error|warning' } | Select-Object -First 5
        if ($issues) {
            $baseName = Split-Path -Leaf $filePath
            [Console]::Error.WriteLine("[QualityGate] Lint issues in ${baseName}:")
            $issues | ForEach-Object { [Console]::Error.WriteLine($_) }
        }
    }

    exit 0
}

# --- SCSS/CSS files ---
if ($filePath -match '\.(scss|css)$') {
    $dir = Split-Path $filePath -Parent
    $hasStylelint = $false
    $checkDir = $dir
    while ($checkDir -and $checkDir -ne [System.IO.Path]::GetPathRoot($checkDir)) {
        $stylelintConfigs = @('.stylelintrc', '.stylelintrc.json', 'stylelint.config.js')
        foreach ($config in $stylelintConfigs) {
            if (Test-Path (Join-Path $checkDir $config)) { $hasStylelint = $true; break }
        }
        if ($hasStylelint) { break }
        $checkDir = Split-Path $checkDir -Parent
    }

    if (-not $hasStylelint) { exit 0 }
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { exit 0 }

    if ($fixMode) {
        & npx stylelint --fix $filePath 2>&1 | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine($_) }
    } else {
        $output = & npx stylelint $filePath 2>&1
        if ($output) {
            $baseName = Split-Path -Leaf $filePath
            [Console]::Error.WriteLine("[QualityGate] Style issues in ${baseName}:")
            $output | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine($_) }
        }
    }

    exit 0
}

# Unknown file type — skip silently
exit 0
