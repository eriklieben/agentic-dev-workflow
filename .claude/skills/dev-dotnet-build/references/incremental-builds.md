# Fixing Broken Incremental Builds

When `dotnet build` rebuilds everything on every run (even without code changes), incremental builds are broken. A working incremental build should complete in under 1 second on the second run.

## How Incremental Builds Work

MSBuild uses **inputs and outputs** to determine if a target needs to run:

```xml
<Target Name="GenerateCode"
        Inputs="@(Schema)"
        Outputs="@(Schema->'%(Filename).Generated.cs')">
  <!-- Only runs when inputs are newer than outputs -->
</Target>
```

If all outputs are newer than all inputs, the target is **skipped**. This is the up-to-date check.

## Testing Incrementality

```bash
# Build once (full build)
dotnet build
echo "Exit code: $?"

# Build again immediately (should be near-instant)
time dotnet build --no-restore
# Expected: < 1 second for a well-configured project
# If it takes 5+ seconds, incremental builds are broken
```

## Diagnosing with Verbosity

```bash
# Performance summary shows target timing
dotnet build /clp:PerformanceSummary 2>&1 | tail -40

# Diagnostic verbosity shows up-to-date check details
dotnet build -v:diag 2>&1 | grep -i "not up.to.date\|is up.to.date\|skipping target"
```

## Common Causes and Fixes

### 1. Custom Targets Without Inputs/Outputs

**Problem:**
```xml
<!-- This runs EVERY build because MSBuild can't determine if it's up-to-date -->
<Target Name="CopyConfig" AfterTargets="Build">
  <Copy SourceFiles="config.json" DestinationFolder="$(OutputPath)" />
</Target>
```

**Fix:**
```xml
<Target Name="CopyConfig" AfterTargets="Build"
        Inputs="config.json"
        Outputs="$(OutputPath)config.json">
  <Copy SourceFiles="config.json" DestinationFolder="$(OutputPath)" />
</Target>
```

### 2. Targets That Always Run

**Problem:**
```xml
<!-- No Inputs/Outputs = always runs -->
<Target Name="PrintVersion" BeforeTargets="Build">
  <Message Text="Building version $(Version)" Importance="high" />
</Target>
```

**Fix:** If the target has no side effects, add `Condition` to limit execution:
```xml
<Target Name="PrintVersion" BeforeTargets="Build"
        Condition="'$(BuildingInsideVisualStudio)' != 'true'">
  <Message Text="Building version $(Version)" Importance="high" />
</Target>
```

Or add token inputs/outputs:
```xml
<Target Name="PrintVersion" BeforeTargets="Build"
        Inputs="$(MSBuildProjectFile)"
        Outputs="$(IntermediateOutputPath)version.marker">
  <Message Text="Building version $(Version)" Importance="high" />
  <Touch Files="$(IntermediateOutputPath)version.marker" AlwaysCreate="true" />
</Target>
```

### 3. Code Generation Changing Timestamps

**Problem:** A source generator or pre-build step writes files on every build, even when content hasn't changed. This makes inputs newer than outputs, triggering a rebuild.

**Fix:** Write to a temporary file first, then compare:
```xml
<Target Name="GenerateVersion" BeforeTargets="CoreCompile"
        Inputs="$(MSBuildProjectFile)"
        Outputs="$(IntermediateOutputPath)Version.g.cs">
  <WriteLinesToFile File="$(IntermediateOutputPath)Version.g.cs.tmp"
                    Lines="namespace MyApp { static class Version { public const string Value = &quot;$(Version)&quot;%3B } }"
                    Overwrite="true" />
  <!-- Only copy if content changed (preserves timestamp otherwise) -->
  <Copy SourceFiles="$(IntermediateOutputPath)Version.g.cs.tmp"
        DestinationFiles="$(IntermediateOutputPath)Version.g.cs"
        SkipUnchangedFiles="true" />
</Target>
```

### 4. BeforeBuild/AfterBuild Without Incrementality

**Problem:**
```xml
<Target Name="BeforeBuild">
  <Exec Command="npm run build" WorkingDirectory="$(ProjectDir)ClientApp" />
</Target>
```

**Fix:** Add proper inputs/outputs:
```xml
<Target Name="BeforeBuild"
        Inputs="@(ClientAppSource)"
        Outputs="$(ProjectDir)ClientApp\dist\.buildmarker">
  <Exec Command="npm run build" WorkingDirectory="$(ProjectDir)ClientApp" />
  <Touch Files="$(ProjectDir)ClientApp\dist\.buildmarker" AlwaysCreate="true" />
</Target>

<ItemGroup>
  <ClientAppSource Include="$(ProjectDir)ClientApp\src\**\*" />
</ItemGroup>
```

### 5. NuGet Restore Triggering Rebuilds

**Problem:** `dotnet build` runs restore implicitly, which can update `project.assets.json` and trigger recompilation.

**Fix:** Separate restore from build:
```bash
dotnet restore
dotnet build --no-restore
```

In CI:
```yaml
- run: dotnet restore
- run: dotnet build --no-restore
- run: dotnet test --no-build
```

### 6. Output Directory Conflicts

**Problem:** Multiple projects writing to the same output directory causes files to appear "newer" than expected.

**Fix:** Ensure each project has a unique output path (default in SDK-style projects). Don't set shared `OutputPath`:
```xml
<!-- BAD -->
<OutputPath>..\..\build\</OutputPath>

<!-- GOOD — use defaults or project-specific paths -->
<OutputPath>bin\$(Configuration)\$(TargetFramework)\</OutputPath>
```

### 7. Glob Patterns Picking Up Generated Files

**Problem:** Default `<Compile Include="**/*.cs" />` picks up generated files in `obj/` or `bin/`, which change on every build.

**Fix:** SDK-style projects exclude `bin/` and `obj/` by default. If using custom globs:
```xml
<Compile Include="**/*.cs" Exclude="bin/**;obj/**" />
```

## Advanced: Up-to-Date Check in Visual Studio

Visual Studio has its own fast up-to-date check (FUTDC) separate from MSBuild. Enable diagnostic output:

1. Tools → Options → Projects and Solutions → .NET Core
2. Set "Up to date check" log level to "Verbose"
3. Check Output window → "Build" for up-to-date messages

## Performance Benchmarking

```bash
# Measure full build time
time dotnet build --no-restore 2>&1 | tail -5

# Measure incremental (no-op) build time
time dotnet build --no-restore 2>&1 | tail -5

# Target: incremental should be <10% of full build time
```

| Solution size | Expected full build | Expected incremental |
|--------------|--------------------|--------------------|
| Small (1-5 projects) | 2-10s | <1s |
| Medium (5-20 projects) | 10-30s | 1-3s |
| Large (20+ projects) | 30-120s | 3-10s |
