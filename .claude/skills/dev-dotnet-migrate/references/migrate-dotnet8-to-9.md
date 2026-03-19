# Migration Guide: .NET 8 → .NET 9

> .NET 8 (LTS) → .NET 9 (STS, released Nov 2024)

## SDK Requirements

- .NET 9 SDK 9.0.100 or later
- Visual Studio 2022 17.12+ or VS Code with C# Dev Kit
- Update `global.json`:
  ```json
  { "sdk": { "version": "9.0.100" } }
  ```

## Target Framework Change

```xml
<!-- Before -->
<TargetFramework>net8.0</TargetFramework>

<!-- After -->
<TargetFramework>net9.0</TargetFramework>
```

## Key Breaking Changes

### ASP.NET Core

| Change | Impact | Action |
|--------|--------|--------|
| `MapGroup` empty prefix behavior | Medium | Groups with empty string prefix now match differently — verify route tests |
| Static asset delivery (`MapStaticAssets`) | Low | Replaces `UseStaticFiles()` for better compression/caching — opt-in |
| Built-in OpenAPI via `MapOpenApi()` | Low | Can replace Swashbuckle — evaluate during migration |
| Kestrel HTTP/3 enabled by default | Low | Verify firewall/proxy config if HTTP/3 was previously disabled |
| `HybridCache` replaces `IDistributedCache` patterns | Low | Opt-in — evaluate for cache-heavy services |

### EF Core 9

| Change | Impact | Action |
|--------|--------|--------|
| Discriminator column uses `$type` by default | **High** | Existing TPH hierarchies need explicit configuration or migration |
| Auto-compiled queries | Low | Performance improvement, but verify query behavior |
| `ExecuteUpdate`/`ExecuteDelete` improvements | Low | No breaking change, new capabilities |
| LINQ translation improvements | Medium | Some client-evaluated queries may now translate — verify output |

### Runtime / BCL

| Change | Impact | Action |
|--------|--------|--------|
| `System.Text.Json` source gen improvements | Low | Re-run source generators if using `JsonSerializerContext` |
| `TimeProvider` is now non-abstract | Low | Custom implementations still work |
| `SearchValues<string>` available | Low | New API, opt-in |
| `Lock` type (`System.Threading.Lock`) | Low | New type, opt-in — more efficient than `object` locks |

### C# 13 Features (opt-in)

- `params` collections (not just arrays)
- `Lock` type support
- `ref struct` interface implementations
- Implicit indexer access in object initializers

## Step-by-Step Upgrade Commands

```bash
# 1. Update global.json
dotnet new globaljson --sdk-version 9.0.100 --force

# 2. Update target framework in all projects
find . -name "*.csproj" -exec sed -i 's/net8\.0/net9.0/g' {} +

# 3. Update Microsoft packages
dotnet list package --outdated | grep "Microsoft\."
# Then update each:
dotnet add <project> package <PackageName> --version <9.x.x>

# 4. Restore and build
dotnet restore
dotnet build 2>&1 | tee migration-build.txt

# 5. Run tests
dotnet test 2>&1 | tee migration-test.txt
```

## Common Migration Failures

### EF Core Discriminator Change

**Error:** Data doesn't deserialize correctly after upgrade.

**Fix:** Explicitly configure the old discriminator value:
```csharp
modelBuilder.Entity<BaseType>()
    .HasDiscriminator<string>("Discriminator")  // keep old column name
    .HasValue<DerivedType>("DerivedType");
```

Or create a migration to rename the column:
```bash
dotnet ef migrations add UpdateDiscriminatorColumn
```

### Package Version Mismatch

**Error:** `Microsoft.AspNetCore.* 8.x` mixed with `net9.0` target.

**Fix:** Update ALL Microsoft packages to 9.x versions. Use:
```bash
dotnet list package --outdated --highest-minor
```

### Nullable Warning Tsunami

If upgrading from a project that suppressed nullable warnings, .NET 9 analyzers may surface new warnings.

**Fix:** Address incrementally or temporarily suppress:
```xml
<NoWarn>$(NoWarn);CS8600;CS8602;CS8603</NoWarn>
```

## New Features Worth Adopting

| Feature | Benefit | Effort |
|---------|---------|--------|
| `MapOpenApi()` | Replace Swashbuckle, native OpenAPI | Medium |
| `HybridCache` | Simpler distributed caching | Medium |
| `Lock` type | Better performance than `lock(obj)` | Low |
| `params` collections | Cleaner APIs | Low |
| `TypedResults` improvements | Better minimal API responses | Low |

## Official Documentation

- Breaking changes: `learn.microsoft.com/dotnet/core/compatibility/9.0`
- ASP.NET Core migration: `learn.microsoft.com/aspnet/core/migration/80-to-90`
- EF Core 9 changes: `learn.microsoft.com/ef/core/what-is-new/ef-core-9.0/breaking-changes`
