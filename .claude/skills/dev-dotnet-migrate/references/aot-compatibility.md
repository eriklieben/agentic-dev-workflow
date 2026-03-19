# Native AOT Compatibility Guide

Prepare a .NET project for Native AOT (Ahead-of-Time) compilation — smaller binaries, faster startup, no JIT dependency.

## When to Consider AOT

**Good candidates:**
- Microservices with cold-start requirements (serverless, containers)
- CLI tools and utilities
- gRPC services
- Minimal API services with simple dependency graphs

**Poor candidates:**
- MVC / Razor Pages applications (not supported)
- Blazor Server apps (limited support)
- Apps with heavy reflection usage (EF Core migrations, AutoMapper)
- Plugin systems that load assemblies dynamically

## AOT Readiness Checklist

### Project Configuration

```xml
<PropertyGroup>
  <!-- Enable AOT publishing -->
  <PublishAot>true</PublishAot>

  <!-- For libraries: mark as AOT-compatible -->
  <IsAotCompatible>true</IsAotCompatible>

  <!-- Show all trimming/AOT warnings (don't suppress them) -->
  <SuppressTrimAnalysisWarnings>false</SuppressTrimAnalysisWarnings>

  <!-- Enable single-file for smaller output -->
  <PublishSingleFile>true</PublishSingleFile>
</PropertyGroup>
```

### Check for Warnings

```bash
# Build with AOT analysis enabled
dotnet publish -r linux-x64 -c Release 2>&1 | tee aot-warnings.txt

# Count warnings
grep -c "warning IL" aot-warnings.txt
```

## Code Patterns That Break AOT

### 1. Runtime Reflection

```csharp
// BREAKS AOT — type might be trimmed away
var type = Type.GetType("MyApp.Services.UserService");
var instance = Activator.CreateInstance(type);

// AOT-SAFE — static reference keeps the type
var instance = new UserService();
```

### 2. System.Reflection.Emit

```csharp
// BREAKS AOT — no runtime code generation
var dynamicMethod = new DynamicMethod("Add", typeof(int), new[] { typeof(int), typeof(int) });

// AOT-SAFE — use source generators instead
[GeneratedRegex(@"\d+")]
private static partial Regex NumberPattern();
```

### 3. System.Text.Json Without Source Generators

```csharp
// BREAKS AOT — uses reflection for serialization
var json = JsonSerializer.Serialize(obj);

// AOT-SAFE — use source generators
var json = JsonSerializer.Serialize(obj, AppJsonContext.Default.MyType);

[JsonSerializable(typeof(MyType))]
[JsonSerializable(typeof(List<MyType>))]
internal partial class AppJsonContext : JsonSerializerContext { }
```

### 4. Dynamic Assembly Loading

```csharp
// BREAKS AOT — assemblies aren't available at runtime
var assembly = Assembly.LoadFrom("plugin.dll");

// AOT-SAFE — reference types statically or use compile-time composition
```

### 5. Castle.Core / Dynamic Proxies

```csharp
// BREAKS AOT — generates proxy types at runtime (Moq, NSubstitute in tests)
var mock = new Mock<IService>();

// AOT-SAFE alternative for tests — use manual fakes or source-generated mocks
// For production: use compile-time decorators
```

### 6. Unguarded Activator.CreateInstance

```csharp
// BREAKS AOT — type might be trimmed
var service = Activator.CreateInstance(serviceType);

// AOT-SAFE — explicit factory
var service = serviceType switch
{
    _ when serviceType == typeof(UserService) => new UserService(),
    _ when serviceType == typeof(OrderService) => new OrderService(),
    _ => throw new InvalidOperationException($"Unknown service: {serviceType}")
};
```

## Trimming Attributes

Use these attributes to guide the trimmer and AOT compiler:

### `[DynamicallyAccessedMembers]`

Tell the trimmer which members are accessed dynamically:

```csharp
public T CreateInstance<[DynamicallyAccessedMembers(DynamicallyAccessedMemberTypes.PublicConstructors)] T>()
    where T : class
{
    return Activator.CreateInstance<T>();  // Safe — trimmer preserves constructors
}
```

### `[RequiresUnreferencedCode]`

Mark methods that aren't trim-safe:

```csharp
[RequiresUnreferencedCode("Uses reflection to discover handlers")]
public void RegisterHandlers()
{
    var handlerTypes = Assembly.GetExecutingAssembly()
        .GetTypes()
        .Where(t => t.IsAssignableTo(typeof(IHandler)));
}
```

### `[RequiresDynamicCode]`

Mark methods that generate code at runtime:

```csharp
[RequiresDynamicCode("Creates generic types at runtime")]
public object CreateRepository(Type entityType)
{
    var repoType = typeof(Repository<>).MakeGenericType(entityType);
    return Activator.CreateInstance(repoType)!;
}
```

### `[UnconditionalSuppressMessage]`

Suppress warnings when you've verified the code is safe:

```csharp
[UnconditionalSuppressMessage("Trimming", "IL2026",
    Justification = "All handler types are referenced in DI registration")]
public void RegisterHandlers() { ... }
```

## ASP.NET Core AOT Support

| Feature | AOT Support | Notes |
|---------|-------------|-------|
| Minimal APIs | Full | Primary AOT scenario |
| gRPC | Full | Excellent AOT candidate |
| MVC / Controllers | **Not supported** | Use Minimal APIs instead |
| Razor Pages | **Not supported** | Use Blazor WASM or static generation |
| Blazor Server | **Limited** | Experimental |
| Blazor WebAssembly | Partial | AOT compilation available |
| SignalR | Full (.NET 10+) | Not supported before .NET 10 |

### Minimal API AOT Template

```bash
dotnet new webapiaot -n MyAotService
```

This creates a project pre-configured for AOT with:
- `PublishAot` enabled
- JSON source generators configured
- Slim service registration

## DI Container Compatibility

Standard `Microsoft.Extensions.DependencyInjection` works with AOT when:
- All registrations use concrete types (not `Type` objects)
- No `Assembly.GetTypes()` scanning
- No dynamic generic type construction

For verified AOT-safe DI, consider:
- **Jab** — compile-time DI container (source generator)
- **Pure DI** — manual composition root, no container

## Testing AOT Builds

### Build and Verify

```bash
# Publish AOT binary
dotnet publish -r linux-x64 -c Release -o ./publish

# Check binary size
ls -lh ./publish/MyApp

# Run and verify
./publish/MyApp

# Measure startup time
time ./publish/MyApp --help
```

### Integration Tests Against AOT Binary

```bash
# Start the AOT binary
./publish/MyApp &
APP_PID=$!

# Wait for startup
sleep 2

# Run HTTP tests
curl -f http://localhost:5000/health || echo "FAILED"

# Cleanup
kill $APP_PID
```

### Compare JIT vs AOT

| Metric | JIT | AOT |
|--------|-----|-----|
| Binary size | ~100MB (with runtime) | ~10-30MB (self-contained) |
| Startup time | 200-500ms | 10-50ms |
| Peak throughput | Higher (JIT optimizes hot paths) | Slightly lower |
| Memory | Higher (JIT compiler overhead) | Lower |
| Deployment | Needs .NET runtime or self-contained | Always self-contained |

## Incremental AOT Adoption

1. **Start with trimming:** `<PublishTrimmed>true</PublishTrimmed>` — fixes most warnings
2. **Add source generators:** `JsonSerializerContext`, `LoggerMessage`, `GeneratedRegex`
3. **Enable AOT analysis:** `<IsAotCompatible>true</IsAotCompatible>` — see warnings without publishing
4. **Fix warnings** project by project
5. **Test AOT publish** — `dotnet publish -r linux-x64 -c Release`
6. **Benchmark** — compare startup, memory, throughput
