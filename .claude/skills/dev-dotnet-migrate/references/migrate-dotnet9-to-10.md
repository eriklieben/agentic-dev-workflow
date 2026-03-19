# Migration Guide: .NET 9 → .NET 10

> .NET 9 (STS) → .NET 10 (LTS, released Nov 2025)

## SDK Requirements

- .NET 10 SDK 10.0.100 or later
- Visual Studio 2022 17.14+ or VS Code with C# Dev Kit
- Update `global.json`:
  ```json
  { "sdk": { "version": "10.0.100" } }
  ```

## Target Framework Change

```xml
<!-- Before -->
<TargetFramework>net9.0</TargetFramework>

<!-- After -->
<TargetFramework>net10.0</TargetFramework>
```

## Why Upgrade

.NET 10 is **LTS** (3 years of support). If you're on .NET 9 (STS), you should migrate before .NET 9 goes out of support (May 2026). This is the recommended stable landing zone.

## Key Breaking Changes

### C# 14 Features

| Feature | Impact | Notes |
|---------|--------|-------|
| Extension types | Low | New syntax for extension methods — existing extensions still work |
| `field` keyword | Low | Auto-property backing field access — opt-in |
| `Span` improvements | Low | More `Span<T>` overloads in BCL — behavioral compatible |
| Unbound generic types in `nameof` | Low | `nameof(List<>)` now valid |

### ASP.NET Core 10

| Change | Impact | Action |
|--------|--------|--------|
| Middleware pipeline changes | Medium | Verify custom middleware ordering |
| Enhanced validation (built-in) | Low | New validation attributes — opt-in |
| OpenAPI improvements | Low | Better `MapOpenApi()` defaults |
| Blazor improvements | Medium | Verify Blazor Interactive components if used |
| SignalR Native AOT support | Low | Now supported — opt-in |

### EF Core 10

| Change | Impact | Action |
|--------|--------|--------|
| Query pipeline improvements | Medium | Some queries may translate differently — verify with tests |
| JSON column enhancements | Low | Better `ToJson()` mapping |
| Improved AOT support | Low | Opt-in |
| `ExecuteUpdate` improvements | Low | More expression support |

### Runtime / BCL

| Change | Impact | Action |
|--------|--------|--------|
| Polymorphic serialization defaults | Medium | `System.Text.Json` may serialize differently — verify JSON contracts |
| `ZipArchive` improvements | Low | Better performance, same API |
| Named pipes default changes | Low | Kestrel named pipe transport config |
| Marshal-free interop patterns | Low | New P/Invoke source generators |
| Enhanced OpenTelemetry | Low | Better built-in metrics and traces |

## Step-by-Step Upgrade Commands

```bash
# 1. Create migration branch
git checkout -b migrate/net10

# 2. Update global.json
dotnet new globaljson --sdk-version 10.0.100 --force

# 3. Update target framework in all projects
find . -name "*.csproj" -exec sed -i 's/net9\.0/net10.0/g' {} +

# 4. Update Microsoft packages
dotnet list package --outdated | grep "Microsoft\."
# Update each to 10.x version

# 5. Restore, build, test
dotnet restore
dotnet build 2>&1 | tee migration-build.txt
dotnet test 2>&1 | tee migration-test.txt
```

## Common Migration Failures

### System.Text.Json Polymorphic Serialization

**Error:** JSON output changes shape after upgrade.

**Fix:** Explicitly configure serialization to maintain backward compatibility:
```csharp
[JsonDerivedType(typeof(DerivedType), typeDiscriminator: "derived")]
public class BaseType { }

// Or configure globally:
options.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
```

### EF Core Query Translation Changes

**Error:** Query that worked in EF Core 9 throws or returns different results.

**Fix:** Compare SQL output before/after:
```csharp
// Enable SQL logging
optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
```

If a query now translates to SQL that was previously client-evaluated, the results may differ. Verify with test data.

### Middleware Ordering

**Error:** Custom middleware behaves differently.

**Fix:** Review `Program.cs` middleware pipeline. .NET 10 may change the default order of built-in middleware. Ensure custom middleware is explicitly ordered:
```csharp
app.UseRouting();
app.UseAuthentication();  // explicit order
app.UseAuthorization();   // explicit order
app.MapControllers();
```

## New Features Worth Adopting

| Feature | Benefit | Effort |
|---------|---------|--------|
| Extension types (C# 14) | Cleaner extension syntax | Low |
| `field` keyword (C# 14) | Simpler property validation | Low |
| Enhanced validation | Replace FluentValidation for simple cases | Medium |
| Built-in OpenTelemetry | Better observability without extra packages | Medium |
| SignalR AOT | Smaller deployments for real-time apps | Medium |

## LTS Considerations

Since .NET 10 is LTS:
- Supported until **November 2028**
- You can skip .NET 11 (STS) and wait for .NET 12 (LTS)
- Good baseline for production workloads that need stability
- Security patches guaranteed for 3 years

## Official Documentation

- Breaking changes: `learn.microsoft.com/dotnet/core/compatibility/10.0`
- ASP.NET Core migration: `learn.microsoft.com/aspnet/core/migration/90-to-100`
- EF Core 10: `learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/breaking-changes`
- What's new: `learn.microsoft.com/dotnet/core/whats-new/dotnet-10`
