# EF Core Query Optimization — Deep Reference

Detailed patterns for optimizing EF Core queries with code examples.

## SQL Logging Setup

### Development Configuration

```csharp
// In DbContext.OnConfiguring or Startup
optionsBuilder
    .UseNpgsql(connectionString)
    .LogTo(Console.WriteLine, new[] { DbLoggerCategory.Database.Command.Name }, LogLevel.Information)
    .EnableSensitiveDataLogging()   // Shows actual parameter values
    .EnableDetailedErrors();        // More helpful error messages
```

### Structured Logging (Serilog)

```csharp
optionsBuilder
    .UseNpgsql(connectionString)
    .LogTo(
        message => Log.Logger.Information(message),
        new[] { DbLoggerCategory.Database.Command.Name },
        LogLevel.Information);
```

### Query Tags

Add identifiers to queries for tracing:

```csharp
var orders = await db.Orders
    .TagWith("GetActiveOrders - OrderService.cs:42")
    .Where(o => o.Status == OrderStatus.Active)
    .ToListAsync();

// SQL output will include:
// -- GetActiveOrders - OrderService.cs:42
// SELECT ...
```

## N+1 Detection Patterns

### Pattern 1: Lazy Loading in a Loop

```csharp
// BAD — 1 query for orders + N queries for items
var orders = await db.Orders.ToListAsync();
foreach (var order in orders)
{
    Console.WriteLine($"Order {order.Id}: {order.Items.Count} items");
    //                                     ^^^^^^^^^^^ lazy load!
}

// GOOD — 1 query with join
var orders = await db.Orders
    .Include(o => o.Items)
    .ToListAsync();

// BEST — project only what you need
var orderSummaries = await db.Orders
    .Select(o => new { o.Id, ItemCount = o.Items.Count })
    .ToListAsync();
```

### Pattern 2: Navigation Property in Select

```csharp
// BAD — may trigger lazy loading per row
var data = await db.Orders
    .Select(o => new { o.Id, CustomerName = o.Customer.Name })
    .ToListAsync();
// This is actually OK — EF Core translates to a JOIN in the query

// ACTUALLY BAD — calling a method that accesses navigation
var data = await db.Orders
    .AsEnumerable()  // Switches to client evaluation!
    .Select(o => new { o.Id, CustomerName = o.Customer.Name })
    .ToList();
// Now Customer.Name triggers lazy loading per row
```

### Pattern 3: Find in a Loop

```csharp
// BAD — N queries
foreach (var id in orderIds)
{
    var order = await db.Orders.FindAsync(id);
    results.Add(order);
}

// GOOD — 1 query with IN clause
var orders = await db.Orders
    .Where(o => orderIds.Contains(o.Id))
    .ToListAsync();
```

## Split Queries

### When to Use

Use `AsSplitQuery()` when you have multiple `Include()` calls that would create a cartesian product:

```csharp
// Without split: 1 query with potentially huge cartesian product
// If Order has 10 Items and 5 History entries → 50 rows returned
var order = await db.Orders
    .Include(o => o.Items)
    .Include(o => o.History)
    .FirstOrDefaultAsync(o => o.Id == id);

// With split: 3 separate queries (1 per entity type)
var order = await db.Orders
    .Include(o => o.Items)
    .Include(o => o.History)
    .AsSplitQuery()
    .FirstOrDefaultAsync(o => o.Id == id);
```

### When NOT to Use

- When consistency between includes matters (split queries aren't atomic)
- When there's only 1 Include (no cartesian risk)
- When the data set is small

### Global Configuration

```csharp
optionsBuilder.UseNpgsql(connectionString, o =>
{
    o.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
});
```

Then opt-out per query: `.AsSingleQuery()`

## Compiled Queries

### Sync

```csharp
private static readonly Func<AppDbContext, int, Order?> GetOrderById =
    EF.CompileQuery((AppDbContext db, int id) =>
        db.Orders
            .Include(o => o.Items)
            .FirstOrDefault(o => o.Id == id));
```

### Async

```csharp
private static readonly Func<AppDbContext, int, Task<Order?>> GetOrderByIdAsync =
    EF.CompileAsyncQuery((AppDbContext db, int id) =>
        db.Orders
            .Include(o => o.Items)
            .FirstOrDefault(o => o.Id == id));
```

### When Worth the Complexity

- High-frequency queries (>100 calls/sec)
- Parameterized queries with stable shape
- API endpoints with consistent query patterns

### Limitations

- Can't use `Contains` (translates to SQL `IN` with variable parameters)
- Can't use dynamic includes
- Can't use `IQueryable` composition after compilation
- Maximum 8 parameters

## Pagination Patterns

### Offset Pagination (Simple but Slow at Scale)

```csharp
// Page 1000 = SKIP 999 * 20 rows = database reads and discards 19,980 rows
var page = await db.Orders
    .OrderBy(o => o.CreatedAt)
    .Skip((pageNumber - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

### Keyset Pagination (Fast at Any Scale)

```csharp
// Uses an index seek — O(1) regardless of page number
var page = await db.Orders
    .Where(o => o.CreatedAt > lastSeenDate ||
               (o.CreatedAt == lastSeenDate && o.Id > lastSeenId))
    .OrderBy(o => o.CreatedAt)
    .ThenBy(o => o.Id)
    .Take(pageSize)
    .ToListAsync();

// Return cursor for next page
var cursor = new { LastDate = page.Last().CreatedAt, LastId = page.Last().Id };
```

### Keyset with Descending Order

```csharp
var page = await db.Orders
    .Where(o => o.CreatedAt < lastSeenDate ||
               (o.CreatedAt == lastSeenDate && o.Id < lastSeenId))
    .OrderByDescending(o => o.CreatedAt)
    .ThenByDescending(o => o.Id)
    .Take(pageSize)
    .ToListAsync();
```

## Bulk Operations

### ExecuteUpdate (EF Core 7+)

```csharp
// Single SQL UPDATE — no entity loading
var affected = await db.Products
    .Where(p => p.CategoryId == categoryId)
    .ExecuteUpdateAsync(setters => setters
        .SetProperty(p => p.Price, p => p.Price * 1.10m)
        .SetProperty(p => p.UpdatedAt, DateTime.UtcNow));
```

### ExecuteDelete (EF Core 7+)

```csharp
// Single SQL DELETE — no entity loading
var deleted = await db.AuditLogs
    .Where(l => l.CreatedAt < DateTime.UtcNow.AddYears(-1))
    .ExecuteDeleteAsync();
```

### When to Drop to Raw SQL

- Complex multi-table updates with joins
- Database-specific features (PostgreSQL `ON CONFLICT`, SQL Server `MERGE`)
- Performance-critical batch operations
- Complex aggregation reports

```csharp
await db.Database.ExecuteSqlAsync($"""
    UPDATE products p
    SET price = price * {multiplier}
    FROM categories c
    WHERE p.category_id = c.id
    AND c.name = {categoryName}
""");
```

## Index Optimization

### Basic Index

```csharp
modelBuilder.Entity<Order>()
    .HasIndex(o => o.CustomerId);
```

### Composite Index

```csharp
// Column order matters — put high-selectivity columns first
modelBuilder.Entity<Order>()
    .HasIndex(o => new { o.Status, o.CreatedAt });
```

### Unique Index

```csharp
modelBuilder.Entity<User>()
    .HasIndex(u => u.Email)
    .IsUnique();
```

### Filtered Index

```csharp
// Only index active orders — smaller index, faster lookups
modelBuilder.Entity<Order>()
    .HasIndex(o => o.CustomerId)
    .HasFilter("[Status] != 'Cancelled'");
```

### Include Columns (covering index)

```csharp
// Include columns in the index to avoid key lookups
modelBuilder.Entity<Order>()
    .HasIndex(o => o.CustomerId)
    .IncludeProperties(o => new { o.Total, o.CreatedAt });
```

## Global Query Filters

### Soft Delete

```csharp
modelBuilder.Entity<Order>().HasQueryFilter(o => !o.IsDeleted);

// All queries automatically exclude deleted:
var orders = await db.Orders.ToListAsync(); // WHERE IsDeleted = false

// Bypass when needed:
var allOrders = await db.Orders.IgnoreQueryFilters().ToListAsync();
```

### Multi-Tenant

```csharp
modelBuilder.Entity<Order>().HasQueryFilter(o => o.TenantId == _tenantId);
```

### Performance Considerations

- Filters add a WHERE clause to every query on that entity
- Ensure filtered columns are indexed
- Complex filters can prevent index usage — keep them simple
- `IgnoreQueryFilters()` removes ALL filters, not just one

## Benchmarking EF Queries

```csharp
[MemoryDiagnoser]
public class QueryBenchmarks
{
    private AppDbContext _db;

    [GlobalSetup]
    public void Setup()
    {
        _db = new AppDbContext(/* options */);
    }

    [Benchmark(Baseline = true)]
    public async Task<List<Order>> WithoutProjection()
    {
        return await _db.Orders
            .Where(o => o.Status == OrderStatus.Active)
            .ToListAsync();
    }

    [Benchmark]
    public async Task<List<OrderSummary>> WithProjection()
    {
        return await _db.Orders
            .Where(o => o.Status == OrderStatus.Active)
            .Select(o => new OrderSummary { Id = o.Id, Total = o.Total })
            .ToListAsync();
    }

    [GlobalCleanup]
    public void Cleanup() => _db.Dispose();
}
```

Run with:
```bash
dotnet run -c Release -- --filter *QueryBenchmarks*
```
