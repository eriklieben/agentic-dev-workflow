# MSBuild Antipatterns

15+ common MSBuild mistakes in .NET projects. For each: what it looks like, why it's bad, how to fix it.

---

## 1. Hardcoded Paths Instead of MSBuild Properties

**Bad:**
```xml
<Reference Include="C:\Users\dev\libs\MyLib.dll" />
<Content Include="C:\shared\config.json" />
```

**Why it's bad:** Breaks on other machines, CI, and different OS.

**Fix:**
```xml
<Reference Include="$(SolutionDir)libs\MyLib.dll" />
<!-- Or better: use a NuGet package -->
<PackageReference Include="MyLib" Version="1.0.0" />
```

---

## 2. Using $(SolutionDir) in .csproj Files

**Bad:**
```xml
<Import Project="$(SolutionDir)build\Common.props" />
```

**Why it's bad:** `$(SolutionDir)` is only set when building via a `.sln` file. Building a single project (`dotnet build MyProject.csproj`) leaves it empty.

**Fix:**
```xml
<!-- Use MSBuildThisFileDirectory for relative paths -->
<Import Project="$(MSBuildThisFileDirectory)..\build\Common.props" />

<!-- Or use Directory.Build.props which is auto-imported -->
```

---

## 3. Duplicate PackageReference Versions Across Projects

**Bad:**
```xml
<!-- Project A -->
<PackageReference Include="Serilog" Version="3.1.1" />

<!-- Project B -->
<PackageReference Include="Serilog" Version="3.0.0" />
```

**Why it's bad:** Version drift causes runtime errors. Hard to audit and update.

**Fix:** Use Central Package Management (CPM):
```xml
<!-- Directory.Packages.props -->
<ItemGroup>
  <PackageVersion Include="Serilog" Version="3.1.1" />
</ItemGroup>

<!-- *.csproj — no version needed -->
<PackageReference Include="Serilog" />
```

---

## 4. Missing PrivateAssets on Analyzer Packages

**Bad:**
```xml
<PackageReference Include="StyleCop.Analyzers" Version="1.2.0" />
```

**Why it's bad:** Analyzer package gets included in published output and transitively flows to consuming projects.

**Fix:**
```xml
<PackageReference Include="StyleCop.Analyzers" Version="1.2.0">
  <PrivateAssets>all</PrivateAssets>
  <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
</PackageReference>
```

---

## 5. Explicit Compile Include in SDK-Style Projects

**Bad:**
```xml
<ItemGroup>
  <Compile Include="**\*.cs" />
</ItemGroup>
```

**Why it's bad:** SDK-style projects automatically include all `*.cs` files. This creates duplicate items, causing CS2002 warnings or build failures.

**Fix:** Remove the explicit include. SDK handles it. Only add `<Compile>` for files outside the project directory or to exclude specific files:
```xml
<ItemGroup>
  <Compile Remove="Legacy\**" />
</ItemGroup>
```

---

## 6. Setting OutputPath Without Configuration

**Bad:**
```xml
<PropertyGroup>
  <OutputPath>build\output</OutputPath>
</PropertyGroup>
```

**Why it's bad:** Debug and Release builds overwrite each other.

**Fix:**
```xml
<PropertyGroup>
  <OutputPath>build\output\$(Configuration)\$(TargetFramework)</OutputPath>
</PropertyGroup>
```

Or just use the SDK defaults (`bin\$(Configuration)\$(TargetFramework)\`).

---

## 7. Importing Targets in Wrong Order

**Bad:**
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
  </PropertyGroup>

  <!-- This import happens AFTER the SDK, so SDK already evaluated defaults -->
  <Import Project="custom.props" />
</Project>
```

**Why it's bad:** SDK-style projects have implicit imports at the top and bottom. Properties in `custom.props` may be evaluated too late to affect SDK behavior.

**Fix:** Use `Directory.Build.props` (imported before SDK) for properties, `Directory.Build.targets` (imported after SDK) for targets:
```xml
<!-- Directory.Build.props — evaluated BEFORE SDK -->
<Project>
  <Import Project="custom.props" />
</Project>
```

---

## 8. Using `<Reference>` for NuGet Packages

**Bad:**
```xml
<Reference Include="Newtonsoft.Json">
  <HintPath>..\packages\Newtonsoft.Json.13.0.3\lib\net8.0\Newtonsoft.Json.dll</HintPath>
</Reference>
```

**Why it's bad:** Old packages.config style. No transitive dependency resolution. No vulnerability scanning.

**Fix:**
```xml
<PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
```

---

## 9. Copy Tasks Without Proper Inputs/Outputs

**Bad:**
```xml
<Target Name="CopyAssets" BeforeTargets="Build">
  <Copy SourceFiles="@(Assets)" DestinationFolder="$(OutputPath)assets" />
</Target>
```

**Why it's bad:** Runs on every build, breaking incremental builds.

**Fix:**
```xml
<Target Name="CopyAssets" BeforeTargets="Build"
        Inputs="@(Assets)"
        Outputs="@(Assets->'$(OutputPath)assets\%(Filename)%(Extension)')">
  <Copy SourceFiles="@(Assets)" DestinationFolder="$(OutputPath)assets" SkipUnchangedFiles="true" />
</Target>
```

---

## 10. Inconsistent TreatWarningsAsErrors

**Bad:**
```xml
<!-- Some projects have it, others don't -->
<!-- ProjectA.csproj -->
<TreatWarningsAsErrors>true</TreatWarningsAsErrors>

<!-- ProjectB.csproj — missing! -->
```

**Why it's bad:** Warnings accumulate in projects without the setting. Quality is inconsistent.

**Fix:** Set globally in `Directory.Build.props`:
```xml
<PropertyGroup>
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
</PropertyGroup>
```

---

## 11. Missing IsPackable on Test Projects

**Bad:**
```xml
<!-- Tests.csproj — no IsPackable setting -->
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="xunit" Version="2.9.0" />
  </ItemGroup>
</Project>
```

**Why it's bad:** `dotnet pack` at the solution level creates NuGet packages for test projects.

**Fix:** In `test/Directory.Build.props`:
```xml
<PropertyGroup>
  <IsPackable>false</IsPackable>
  <IsPublishable>false</IsPublishable>
</PropertyGroup>
```

---

## 12. Absolute Paths in Directory.Build.props

**Bad:**
```xml
<!-- Directory.Build.props -->
<PropertyGroup>
  <ToolsPath>C:\tools\analyzers</ToolsPath>
</PropertyGroup>
```

**Why it's bad:** Breaks on other machines, CI, different OS.

**Fix:**
```xml
<PropertyGroup>
  <ToolsPath>$(MSBuildThisFileDirectory)tools\analyzers</ToolsPath>
</PropertyGroup>
```

---

## 13. Circular Project References

**Bad:**
```
ProjectA → ProjectB → ProjectC → ProjectA  (cycle!)
```

**Error:** `MSB4006: There is a circular dependency in the target dependency graph`

**Fix:** Introduce an abstraction layer:
```
ProjectA → ProjectB → ProjectC
ProjectA → Shared.Contracts  ← ProjectC
```

Extract shared interfaces/models into a separate project that both reference.

---

## 14. Redundant Properties Already Set by SDK

**Bad:**
```xml
<PropertyGroup>
  <RootNamespace>MyProject</RootNamespace>  <!-- Same as assembly name -->
  <AssemblyName>MyProject</AssemblyName>    <!-- Same as project file name -->
  <OutputType>Library</OutputType>          <!-- Default for class libraries -->
  <GenerateAssemblyInfo>true</GenerateAssemblyInfo>  <!-- Default is true -->
</PropertyGroup>
```

**Why it's bad:** Noise. Makes it harder to spot the properties that actually differ from defaults.

**Fix:** Only set properties that differ from SDK defaults:
```xml
<PropertyGroup>
  <TargetFramework>net9.0</TargetFramework>
  <!-- Only what's needed. SDK handles the rest. -->
</PropertyGroup>
```

---

## 15. Not Using TargetFrameworks (Plural) for Multi-Targeting

**Bad:** Creating separate projects for different target frameworks.

**Fix:**
```xml
<PropertyGroup>
  <TargetFrameworks>net8.0;net9.0</TargetFrameworks>
</PropertyGroup>

<!-- Conditional code -->
#if NET9_0_OR_GREATER
    // Use .NET 9 features
#else
    // Fallback
#endif
```

---

## 16. Build Property Ordering Issues

**Bad:**
```xml
<!-- Directory.Build.props -->
<PropertyGroup>
  <MyCustomPath>$(OutputPath)custom\</MyCustomPath>
  <!-- OutputPath hasn't been set yet! It's set by the SDK after this file. -->
</PropertyGroup>
```

**Why it's bad:** `$(OutputPath)` is empty at this point because the SDK hasn't set it yet.

**Fix:** Set it in `Directory.Build.targets` (evaluated after SDK):
```xml
<!-- Directory.Build.targets -->
<PropertyGroup>
  <MyCustomPath>$(OutputPath)custom\</MyCustomPath>
</PropertyGroup>
```

Or use it in a target that runs after evaluation:
```xml
<Target Name="SetCustomPath" BeforeTargets="Build">
  <PropertyGroup>
    <MyCustomPath>$(OutputPath)custom\</MyCustomPath>
  </PropertyGroup>
</Target>
```

---

## Quick Reference

| # | Antipattern | Severity | Fix |
|---|------------|----------|-----|
| 1 | Hardcoded paths | High | Use MSBuild properties |
| 2 | $(SolutionDir) in csproj | Medium | Use $(MSBuildThisFileDirectory) |
| 3 | Duplicate versions | High | Central Package Management |
| 4 | Missing PrivateAssets | Low | Add to analyzer packages |
| 5 | Explicit Compile Include | Medium | Remove (SDK auto-includes) |
| 6 | OutputPath without config | Medium | Include $(Configuration) |
| 7 | Wrong import order | High | Use Directory.Build.props/targets |
| 8 | `<Reference>` for NuGet | High | Use `<PackageReference>` |
| 9 | Copy without inputs/outputs | Medium | Add Inputs/Outputs attributes |
| 10 | Inconsistent warnings-as-errors | Medium | Set in Directory.Build.props |
| 11 | Missing IsPackable on tests | Low | Set in test/Directory.Build.props |
| 12 | Absolute paths | High | Use $(MSBuildThisFileDirectory) |
| 13 | Circular references | High | Extract shared contracts |
| 14 | Redundant SDK properties | Low | Remove defaults |
| 15 | Separate projects for TFMs | Medium | Use TargetFrameworks (plural) |
| 16 | Property ordering | High | Props vs targets timing |
