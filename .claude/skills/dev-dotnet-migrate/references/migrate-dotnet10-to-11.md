# Migration Guide: .NET 10 → .NET 11

> .NET 10 (LTS) → .NET 11 (STS, expected Nov 2026)

**Status:** .NET 11 is in preview. This guide covers known/planned changes and will be updated as .NET 11 reaches GA.

## SDK Requirements

- .NET 11 SDK 11.0.100-preview or later
- Visual Studio 2022 17.16+ (preview) or VS Code with C# Dev Kit
- Update `global.json`:
  ```json
  {
    "sdk": {
      "version": "11.0.100-preview.1",
      "allowPrerelease": true
    }
  }
  ```

## Target Framework Change

```xml
<!-- Before -->
<TargetFramework>net10.0</TargetFramework>

<!-- After -->
<TargetFramework>net11.0</TargetFramework>
```

## Why Wait (or Not)

.NET 11 is an **STS release** (18 months of support). If you're on .NET 10 (LTS, supported until Nov 2028), there's no urgency. Upgrade for:
- C# 15 features you need
- Performance improvements that matter to your workload
- New framework features (ASP.NET Core, EF Core 11)

## Expected Changes

### C# 15 Features (planned)

- Further extension type refinements
- Improved pattern matching
- Additional language-level performance features
- *Check `github.com/dotnet/csharplang` for latest proposals*

### ASP.NET Core 11 (expected)

- Continued minimal API improvements
- Enhanced Blazor capabilities
- OpenAPI refinements
- Performance and AOT improvements

### EF Core 11 (expected)

- Query translation improvements
- Better AOT support
- Enhanced JSON column capabilities
- Migration tooling improvements

### Runtime (expected)

- GC improvements
- JIT compilation enhancements
- Better ARM64 performance
- Reduced memory footprint

## Preparation Steps

### Try Preview SDK

```bash
# Install preview SDK (side-by-side with stable)
# Download from dotnet.microsoft.com/download/dotnet/11.0

# Pin to preview in a test branch
dotnet new globaljson --sdk-version 11.0.100-preview.1 --force

# Enable preview language features
```

```xml
<PropertyGroup>
  <LangVersion>preview</LangVersion>
</PropertyGroup>
```

### Monitor Breaking Changes

Track these repos for breaking change announcements:
- `github.com/dotnet/runtime` — runtime and BCL changes
- `github.com/dotnet/aspnetcore` — ASP.NET Core changes
- `github.com/dotnet/efcore` — EF Core changes
- `github.com/dotnet/csharplang` — C# language changes

### Pre-Migration Checklist

```
[ ] Project successfully targets .NET 10 with all tests passing
[ ] All dependencies checked for .NET 11 preview support
[ ] No reliance on APIs marked [Obsolete] in .NET 10
[ ] CI pipeline can handle preview SDK installation
[ ] Team aligned on STS support timeline (18 months)
```

## Step-by-Step Upgrade (when GA)

```bash
# 1. Create migration branch
git checkout -b migrate/net11

# 2. Update global.json
dotnet new globaljson --sdk-version 11.0.100 --force

# 3. Update target framework
find . -name "*.csproj" -exec sed -i 's/net10\.0/net11.0/g' {} +

# 4. Update packages
dotnet list package --outdated | grep "Microsoft\."
# Update each to 11.x version

# 5. Build and test
dotnet restore
dotnet build 2>&1 | tee migration-build.txt
dotnet test 2>&1 | tee migration-test.txt
```

## Official Documentation

- Preview downloads: `dotnet.microsoft.com/download/dotnet/11.0`
- Breaking changes (when available): `learn.microsoft.com/dotnet/core/compatibility/11.0`
- What's new: `learn.microsoft.com/dotnet/core/whats-new/dotnet-11`

---

*This file will be updated as .NET 11 approaches GA. Last reviewed: 2026-03-19.*
