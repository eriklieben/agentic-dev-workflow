# Nullable Reference Type Adoption Guide

Incrementally adopt `<Nullable>enable</Nullable>` across a .NET codebase without drowning in warnings.

## Why Enable Nullable

- Compiler catches null dereference bugs at build time
- Self-documenting APIs — signatures express nullability intent
- Eliminates entire categories of `NullReferenceException`
- Modern .NET ecosystem expects nullable-aware libraries

## Adoption Strategy

### Phase 1: Warnings Only (low risk)

Enable nullable as warnings-only across the solution:

```xml
<!-- Directory.Build.props -->
<PropertyGroup>
  <Nullable>warnings</Nullable>
</PropertyGroup>
```

This surfaces warnings without treating them as errors. Build still succeeds. Use this phase to understand the scope.

```bash
# Count warnings to gauge effort
dotnet build 2>&1 | grep -c "CS86"
```

### Phase 2: File-by-File Adoption

Add `#nullable enable` to individual files as you touch them:

```csharp
#nullable enable

namespace MyApp.Services;

public class UserService
{
    // Now nullable-aware — compiler checks null safety
    public User? FindById(string id) { ... }
}
```

**Priority order:**
1. New files — always start nullable-enabled
2. Domain models — most impactful, defines contracts
3. Service interfaces — API boundaries
4. Implementations — follow interfaces
5. Infrastructure — database, external integrations
6. Tests — last priority

### Phase 3: Project-by-Project

Once most files in a project have `#nullable enable`, flip the project:

```xml
<PropertyGroup>
  <Nullable>enable</Nullable>
</PropertyGroup>
```

Remove individual `#nullable enable` pragmas from files in that project.

### Phase 4: Solution-Wide

Once all projects are nullable-enabled:

```xml
<!-- Directory.Build.props -->
<PropertyGroup>
  <Nullable>enable</Nullable>
</PropertyGroup>
```

Remove per-project settings.

## Common Nullable Patterns

### Constructor-Initialized Properties

```csharp
public class User
{
    // Required — compiler ensures initialization
    public required string Name { get; init; }

    // Or via constructor
    public string Email { get; }

    public User(string email)
    {
        Email = email;
    }
}
```

### EF Core Navigation Properties

EF Core initializes navigation properties via reflection, so the compiler can't verify them. Use the `null!` pattern:

```csharp
public class Order
{
    public int Id { get; set; }

    // EF Core initializes this — null! suppresses the warning
    public Customer Customer { get; set; } = null!;

    // Collections are never null in EF Core
    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
}
```

### Null-Forgiving Operator (`null!`)

Use sparingly and only when you **know** the value won't be null but the compiler can't prove it:

```csharp
// OK — EF Core guarantees initialization
public DbSet<User> Users { get; set; } = null!;

// OK — test setup guarantees initialization
private UserService _sut = null!;

[SetUp]
public void Setup() => _sut = new UserService();

// BAD — hiding a real bug
string name = GetName()!; // Don't do this — handle the null
```

### Nullability Attributes

```csharp
using System.Diagnostics.CodeAnalysis;

// Return is not null when method returns true
public bool TryGetValue(string key, [NotNullWhen(true)] out string? value)

// Parameter is guaranteed not null after the call
public void EnsureInitialized([NotNull] ref string? field)

// Member is guaranteed not null after this method
[MemberNotNull(nameof(_connection))]
private void EnsureConnected() { ... }

// Method may return null even though return type is non-nullable
[return: MaybeNull]
public T Find<T>(int id) where T : class

// Parameter allows null despite non-nullable type (for backwards compat)
public void Process([AllowNull] string value)
```

### Nullable in Generics

```csharp
// Constrain to non-nullable
public class Repository<T> where T : class  // T is non-nullable reference type
{
    public T? FindById(int id);  // Can return null
}

// Unconstrained generic — use default!
public T GetOrDefault<T>(string key)
{
    return _cache.TryGetValue(key, out var value) ? (T)value : default!;
}
```

## Common Warnings and Fixes

### CS8600 — Converting null literal to non-nullable type

```csharp
// Warning:
string name = null;  // CS8600

// Fix:
string? name = null;  // Mark as nullable
```

### CS8602 — Dereference of a possibly null reference

```csharp
// Warning:
string? name = GetName();
int length = name.Length;  // CS8602

// Fix — null check:
int length = name?.Length ?? 0;

// Fix — guard clause:
if (name is null) throw new ArgumentNullException(nameof(name));
int length = name.Length;  // Safe after null check
```

### CS8603 — Possible null reference return

```csharp
// Warning:
public string GetName()
{
    return _names.FirstOrDefault();  // CS8603 — may return null
}

// Fix — change return type:
public string? GetName() { ... }

// Fix — provide default:
public string GetName() => _names.FirstOrDefault() ?? string.Empty;
```

### CS8618 — Non-nullable property not initialized

```csharp
// Warning:
public class Config
{
    public string ConnectionString { get; set; }  // CS8618
}

// Fix — required:
public required string ConnectionString { get; set; }

// Fix — default value:
public string ConnectionString { get; set; } = string.Empty;

// Fix — nullable if truly optional:
public string? ConnectionString { get; set; }
```

## Testing Strategy

1. **Don't fix all warnings at once** — work file-by-file
2. **Run tests after each file** — nullable changes can reveal bugs
3. **Focus on public API first** — internal code can follow later
4. **Use `#nullable disable` temporarily** for files you can't fix yet
5. **Track progress:** `dotnet build 2>&1 | grep -c "CS86"` should decrease over time

## Integration with Code Analysis

Enable complementary analyzers:

```xml
<PropertyGroup>
  <Nullable>enable</Nullable>
  <AnalysisLevel>latest</AnalysisLevel>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
</PropertyGroup>
```

Relevant rules:
- **CA1062** — Validate arguments of public methods (redundant when nullable is enabled)
- **IDE0240** — Nullable directive is redundant (cleanup after project-wide enable)
- **IDE0241** — Nullable directive is unnecessary
