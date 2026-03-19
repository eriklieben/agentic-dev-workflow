# Directory.Build.props/targets Organization

Guide to organizing MSBuild property and target hierarchy in .NET solutions.

## Overview

| File | Evaluated | Purpose |
|------|-----------|---------|
| `Directory.Build.props` | **Before** SDK imports | Properties, defaults, package references |
| `Directory.Build.targets` | **After** SDK imports | Custom targets, build logic, computed properties |
| `Directory.Packages.props` | During restore | Central Package Management (version pinning) |

## How Discovery Works

MSBuild walks **up** from the project directory looking for `Directory.Build.props`. It uses the **first one found** and stops.

```
repo/
├── Directory.Build.props          ← Found for ALL projects
├── src/
│   ├── Directory.Build.props      ← Found for src/ projects (hides root!)
│   ├── Api/Api.csproj
│   └── Domain/Domain.csproj
└── test/
    ├── Directory.Build.props      ← Found for test/ projects (hides root!)
    └── Api.Tests/Api.Tests.csproj
```

**Important:** Nested files **hide** parent files. To chain them, explicitly import the parent.

## Chaining Nested Files

```xml
<!-- src/Directory.Build.props -->
<Project>
  <!-- Import parent first -->
  <Import Project="$([MSBuild]::GetPathOfFileAbove('Directory.Build.props', '$(MSBuildThisFileDirectory)../'))" />

  <!-- Then add src-specific settings -->
  <PropertyGroup>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

## Recommended Organization

### Root Directory.Build.props

Company/solution-wide defaults that apply to every project:

```xml
<Project>
  <PropertyGroup>
    <!-- Code quality -->
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <AnalysisLevel>latest-recommended</AnalysisLevel>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>

    <!-- Nullable (enable everywhere) -->
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>

    <!-- Consistent output -->
    <LangVersion>latest</LangVersion>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>

    <!-- Assembly metadata -->
    <Company>MyCompany</Company>
    <Copyright>Copyright © MyCompany 2026</Copyright>
  </PropertyGroup>
</Project>
```

### src/Directory.Build.props

Production project settings:

```xml
<Project>
  <!-- Chain parent -->
  <Import Project="$([MSBuild]::GetPathOfFileAbove('Directory.Build.props', '$(MSBuildThisFileDirectory)../'))" />

  <PropertyGroup>
    <!-- Documentation for public APIs -->
    <GenerateDocumentationFile>true</GenerateDocumentationFile>

    <!-- Deterministic builds for reproducibility -->
    <Deterministic>true</Deterministic>
    <ContinuousIntegrationBuild Condition="'$(CI)' == 'true'">true</ContinuousIntegrationBuild>
  </PropertyGroup>
</Project>
```

### test/Directory.Build.props

Test project settings:

```xml
<Project>
  <!-- Chain parent -->
  <Import Project="$([MSBuild]::GetPathOfFileAbove('Directory.Build.props', '$(MSBuildThisFileDirectory)../'))" />

  <PropertyGroup>
    <!-- Tests are never packaged or published -->
    <IsPackable>false</IsPackable>
    <IsPublishable>false</IsPublishable>

    <!-- Don't require XML docs in tests -->
    <GenerateDocumentationFile>false</GenerateDocumentationFile>

    <!-- Allow some warnings in tests (test helpers, etc.) -->
    <NoWarn>$(NoWarn);CS1591</NoWarn>
  </PropertyGroup>

  <ItemGroup>
    <!-- Common test dependencies for all test projects -->
    <PackageReference Include="Microsoft.NET.Test.Sdk" />
    <PackageReference Include="coverlet.collector">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
```

### Root Directory.Build.targets

Build logic that needs access to evaluated SDK properties:

```xml
<Project>
  <!-- Computed properties that depend on SDK-set values -->
  <PropertyGroup>
    <DocumentationFile Condition="'$(GenerateDocumentationFile)' == 'true'">$(OutputPath)$(AssemblyName).xml</DocumentationFile>
  </PropertyGroup>

  <!-- Custom targets -->
  <Target Name="ValidatePackageVersions" BeforeTargets="Build"
          Condition="'$(IsPackable)' == 'true'">
    <Error Text="Version must be set for packable projects"
           Condition="'$(Version)' == ''" />
  </Target>
</Project>
```

### Directory.Packages.props (CPM)

Central Package Management — single location for all NuGet versions:

```xml
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
    <CentralPackageTransitivePinningEnabled>true</CentralPackageTransitivePinningEnabled>
  </PropertyGroup>

  <ItemGroup>
    <!-- Framework -->
    <PackageVersion Include="Microsoft.AspNetCore.OpenApi" Version="9.0.0" />
    <PackageVersion Include="Microsoft.EntityFrameworkCore" Version="9.0.0" />

    <!-- Logging -->
    <PackageVersion Include="Serilog" Version="3.1.1" />
    <PackageVersion Include="Serilog.Sinks.Console" Version="5.0.1" />

    <!-- Testing -->
    <PackageVersion Include="xunit" Version="2.9.0" />
    <PackageVersion Include="xunit.runner.visualstudio" Version="2.8.2" />
    <PackageVersion Include="Microsoft.NET.Test.Sdk" Version="17.11.0" />
  </ItemGroup>
</Project>
```

Individual `.csproj` files then reference packages without versions:
```xml
<PackageReference Include="Serilog" />
```

## Props vs Targets: Decision Guide

| Put in **Props** | Put in **Targets** |
|-------------------|-------------------|
| Property declarations | Custom build targets |
| Item includes (static) | Computed properties (need SDK values) |
| Package references | File copy/generation tasks |
| Analyzer references | Validation targets |
| Metadata defaults | Post-build actions |

**Rule of thumb:** If it sets a value → props. If it does work → targets.

## Large Solution Patterns (10+ projects)

### Layered Organization

```
repo/
├── Directory.Build.props          ← Global: code quality, nullable, CPM
├── Directory.Build.targets        ← Global: validation targets
├── Directory.Packages.props       ← Global: NuGet version pins
├── src/
│   ├── Directory.Build.props      ← Prod: docs, deterministic builds
│   ├── Api/
│   ├── Domain/
│   ├── Application/
│   └── Infrastructure/
├── test/
│   ├── Directory.Build.props      ← Test: IsPackable=false, test deps
│   ├── Unit/
│   ├── Integration/
│   └── Architecture/
└── tools/
    ├── Directory.Build.props      ← Tools: OutputType=Exe, IsPackable=false
    └── CodeGen/
```

### Shared Props Files

For settings that apply to a subset of projects (not a whole directory):

```xml
<!-- build/aspire.props -->
<Project>
  <ItemGroup>
    <PackageReference Include="Aspire.Hosting" />
    <PackageReference Include="Aspire.Hosting.AppHost" />
  </ItemGroup>
</Project>

<!-- Only import where needed -->
<!-- src/AppHost/AppHost.csproj -->
<Import Project="$(MSBuildThisFileDirectory)../../build/aspire.props" />
```

### Conditional Settings

```xml
<!-- Directory.Build.props -->
<PropertyGroup Condition="'$(Configuration)' == 'Release'">
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
</PropertyGroup>

<PropertyGroup Condition="'$(CI)' == 'true'">
  <ContinuousIntegrationBuild>true</ContinuousIntegrationBuild>
  <Deterministic>true</Deterministic>
</PropertyGroup>
```

## Common Mistakes

1. **Setting SDK properties in targets** — Properties like `TargetFramework` must be in props (before SDK evaluation)
2. **Forgetting to chain** — Nested Directory.Build.props hides parent without explicit import
3. **Package references in targets** — Put `<PackageReference>` in props, not targets
4. **Heavy logic in props** — Props should declare, not compute. Use targets for logic
5. **Not using CPM in large solutions** — Version drift across 10+ projects is painful

## Debugging

```bash
# See the full evaluated project (all imports resolved)
dotnet msbuild MyProject.csproj -preprocess > evaluated.xml

# See which Directory.Build files are found
dotnet msbuild MyProject.csproj -v:diag 2>&1 | grep "Directory.Build"

# See property values
dotnet msbuild MyProject.csproj -getProperty:OutputPath
dotnet msbuild MyProject.csproj -getProperty:TargetFramework
```
