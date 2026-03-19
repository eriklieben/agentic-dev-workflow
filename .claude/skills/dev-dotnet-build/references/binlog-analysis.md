# Binary Log (Binlog) Analysis

MSBuild binary logs capture the complete build evaluation — every property, item, target, and task execution with full timing data.

## Generating Binlogs

```bash
# Default binlog (creates msbuild.binlog)
dotnet build /bl

# Named binlog
dotnet build /bl:build.binlog

# Binlog for restore + build
dotnet build /bl:full.binlog

# Binlog for specific project
dotnet build src/MyProject/MyProject.csproj /bl:myproject.binlog

# Binlog for publish
dotnet publish /bl:publish.binlog -c Release
```

### Before/After Comparison

```bash
# Capture baseline
dotnet build /bl:before.binlog

# Apply changes...

# Capture after
dotnet build /bl:after.binlog
```

## Reading Binlogs

### MSBuild Structured Log Viewer (GUI)

The best tool for interactive analysis:

```bash
# Install (Windows/macOS)
dotnet tool install -g MSBuild.StructuredLogger

# Open a binlog
msbuildlog build.binlog
```

The viewer provides:
- Tree view of all targets, tasks, and messages
- Full-text search across all build output
- Property and item evaluation timeline
- Target execution timing
- Error and warning navigation

### Command-Line Analysis

```bash
# Replay binlog to console (shows what happened)
dotnet msbuild build.binlog

# Replay with specific verbosity
dotnet msbuild build.binlog -v:detailed

# Extract specific information
dotnet msbuild build.binlog -v:diagnostic 2>&1 | grep "Property reassignment"
```

### Preprocessed Project

See the fully evaluated project file (all imports resolved, conditions evaluated):

```bash
dotnet msbuild MyProject.csproj -preprocess > evaluated.xml

# This shows exactly what MSBuild sees after all Directory.Build.props,
# SDK imports, and NuGet package targets are merged
```

## What to Look For

### Target Execution Order

In the binlog viewer, check:
- Which targets ran and in what order
- Which targets were skipped (up-to-date)
- Which targets took the most time
- Whether targets ran that shouldn't have

### Property Evaluation

Look for property reassignment — a property set in one file being overwritten by another:

```
Property reassignment: $(OutputPath)="bin\Debug\net9.0\" (previous value: "bin\Debug\") at MyProject.csproj (45,5)
```

This often indicates an import order issue.

### Item Evaluation

Check for unexpected items:
- Duplicate `<Compile>` items (SDK-style projects auto-include *.cs)
- Missing `<Content>` or `<None>` items
- Unexpected `<PackageReference>` from Directory.Build.props

### Up-to-Date Checks

When investigating why a project rebuilds unnecessarily:

```
Project 'MyProject' is not up-to-date. Input file 'src/Generated.cs' is newer than output...
```

This tells you exactly which file triggered the rebuild.

### Task Failures

Tasks show their inputs, outputs, and any errors:

```
Task "Csc" (compiler)
  Parameters:
    Sources: file1.cs, file2.cs, ...
    References: ...
  Output:
    Error CS1002: ; expected (file1.cs, line 42)
```

## Comparing Binlogs

### Manual Comparison

1. Open both binlogs in the structured log viewer
2. Compare target lists — new targets? Missing targets?
3. Compare property values — any changed?
4. Compare timing — any target significantly slower?

### Automated Comparison

```bash
# Extract target timing from binlog
dotnet msbuild before.binlog -v:diagnostic 2>&1 | grep "Target.*ms" > before-targets.txt
dotnet msbuild after.binlog -v:diagnostic 2>&1 | grep "Target.*ms" > after-targets.txt
diff before-targets.txt after-targets.txt
```

## Common Patterns in Binlog Output

### Pattern: Unnecessary Restore

```
Target "Restore" executed (should have been skipped if up-to-date)
```
**Cause:** NuGet assets file is stale or missing.
**Fix:** Ensure `dotnet restore` runs separately, then `dotnet build --no-restore`.

### Pattern: Repeated Compilation

```
Target "CoreCompile" executed for the same project multiple times
```
**Cause:** Multi-targeting or incorrect project reference causing multiple builds.
**Fix:** Check `<TargetFrameworks>` and project reference conditions.

### Pattern: Slow Source Generators

```
Generator 'MyGenerator' execution time: 5234ms
```
**Cause:** Source generator doing too much work on every build.
**Fix:** Check generator for incremental generation support (`IIncrementalGenerator`).

## Binlog Size Management

Binlogs can be large (50MB+ for big solutions):

```bash
# Check size
ls -lh *.binlog

# Delete after analysis
rm -f *.binlog

# Don't commit binlogs
echo "*.binlog" >> .gitignore
```

Add to `.gitignore`:
```
*.binlog
```

## Security Note

Binlogs may contain sensitive information:
- Environment variables (connection strings, API keys)
- File paths (reveals project structure)
- NuGet source credentials

**Never commit binlogs to source control. Never share binlogs from production builds.**
