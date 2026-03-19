# Trace Span Patterns

Reference for interpreting Aspire distributed trace spans in event sourcing projects using `EventSourcing` with Azure Blob Storage.

## Storage Span Patterns

### Single Aggregate Rehydration (3 spans)

Loading one aggregate from the event store produces:

1. `HEAD` on `object-document-store/{aggregate}/{id}.json` — check if document exists
2. `GET` on `object-document-store/{aggregate}/{id}.json` — read the aggregate snapshot
3. `GET` on `{aggregate}/{id}-0000000000.json` — read the event stream

**Cost:** 3 blob reads per aggregate. Acceptable for single loads, problematic in loops.

### Tag-Based Document Lookup (1 span)

```
GET {aggregate}/tags/document/{tag}.json
```

Reads a pre-indexed document by tag. Single span, very efficient. Use when you only need the document data without full aggregate replay.

### Projection Read (2 spans)

```
HEAD projections/{name}.json
GET  projections/{name}.json
```

Projections are read models storing pre-computed query results. Two spans on first load, then cached in-memory for the process lifetime. Subsequent requests are free.

### Projection with Checkpoint (3 spans)

```
HEAD projections/{name}.json
GET  projections/{name}.json
GET  projections/{name}-checkpoint.json
```

Projections with external checkpoints include an extra span for the checkpoint file.

## Red Flags

| Pattern | Span Count | Meaning | Action |
|---------|-----------|---------|--------|
| 30+ spans on a single request | High | N+1 aggregate rehydration — loading aggregates in a loop | Replace with projection lookup |
| Same aggregate HEAD+GET+GET repeated | 3× per duplicate | Same aggregate loaded multiple times in one request | Cache the result or restructure |
| Many `GetObjectIdsAsync` calls | Varies | Iterating all blob keys (extremely expensive at scale) | Never use in endpoints — use projections |
| Multiple `GetAll*` or `GetBy*` factory calls | 3× per result | Factory iteration loading each aggregate individually | Add a projection with an index |
| `PUT` on `projections/*.json` returning 409 | 1 | Benign container creation race condition | Ignore — not a real error |

## Efficient vs. Inefficient Patterns

### Inefficient: Factory Iteration
```csharp
// Bad: 3 spans per venue, N venues = 3N spans
var venues = await venueFactory.GetByCompanyIdAsync(companyId);
```

### Efficient: Projection Lookup
```csharp
// Good: 2 spans total (cached after first load)
var venues = await venueListProjection.GetByCompanyId(companyId);
```

### Efficient: Tag-Based Lookup
```csharp
// Good: 1 span, reads pre-indexed document
var doc = await _documentFactory.GetFirstByObjectDocumentTag<MyDocument>(tagValue);
```

### Adding Projection Indexes

If you need to query projection entries by a non-primary field, add an index:

```csharp
// In the projection class
public Dictionary<string, List<string>> EmployeeIndex { get; set; } = new();

// In the event handler
public void When(EmployeeAddedToCompany @event)
{
    if (!EmployeeIndex.ContainsKey(@event.UserId))
        EmployeeIndex[@event.UserId] = new List<string>();
    EmployeeIndex[@event.UserId].Add(@event.CompanyId);
}
```

## Projection Caching Behavior

Projections are cached in-memory after first load per process lifetime:
- **First request:** Pays full cost (2-3 spans for blob read)
- **Subsequent requests:** Zero spans (served from memory)
- **After restart:** Cache is cold, first request pays again

When comparing traces, always compare second requests (warm cache) for accurate span counts. The first request after a restart will always be slower.

## Interpreting Trace Duration

| Duration | Typical Cause |
|----------|---------------|
| < 50ms | Projection hit (cached) or simple in-memory operation |
| 50-200ms | 1-3 blob reads (single aggregate or projection cold load) |
| 200-500ms | Multiple aggregate loads or cold projection + aggregate |
| 500ms+ | N+1 pattern, many blob reads, or external service call |
| 1s+ | Serious issue — likely iterating streams or loading many aggregates |
