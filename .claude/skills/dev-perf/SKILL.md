---
version: 2.0.0
name: dev-perf
description: "ALWAYS use this skill when investigating API performance, endpoint latency, or trace analysis. This skill provides the exact Aspire CLI commands and span pattern knowledge needed to diagnose N+1 queries, excessive storage reads, duplicate aggregate rehydration, and missing projections. You MUST consult this skill whenever the user mentions: slow endpoints, high latency, too many spans, N+1 patterns, storage reads, trace analysis, span counts, projection vs factory performance, before/after performance comparison, profiling requests, or asks 'why is this slow'. Even if you think you can handle it directly, this skill contains project-specific trace patterns and CLI commands you don't know without it."
user-invocable: true
argument-hint: "[endpoint-or-url]"
---

# Performance Profiling

Investigate and resolve performance issues using .NET Aspire distributed tracing. Analyzes trace span patterns to identify N+1 queries, excessive aggregate rehydration, and missing projections.

## When to Use

- An endpoint feels slow or returns high latency
- You suspect N+1 database/storage reads
- After adding new data access code and want to verify efficiency
- Comparing before/after performance of an optimization

## Prerequisites

- Aspire AppHost running (all resources healthy)
- Aspire CLI 13.2+ — use `~/.dotnet/tools/aspire` (13.1.1 at `~/.aspire/bin/` may shadow it on PATH)

## Instructions for Claude

### Phase 1: Verify Environment

Check the Aspire CLI and running AppHost:

```bash
~/.dotnet/tools/aspire ps --format Json
```

Optionally run `~/.dotnet/tools/aspire doctor` (note: `--format Json` is not supported for doctor — it renders a terminal UI).

If no AppHost is running, tell the user and stop.

List resources and confirm the target (usually `api`) is Running/Healthy:

```bash
~/.dotnet/tools/aspire describe --format Json
```

If unhealthy, check console logs:

```bash
~/.dotnet/tools/aspire logs <resource> --format Json -n 50
```

### Phase 2: Generate Traces

If the user provided a specific endpoint or URL, exercise it to generate a trace:

```bash
# Login (if auth required) and hit the endpoint
curl -s -c /tmp/perf-cookies.txt -X POST 'http://localhost:5132/api/auth/dev-login' \
  -H 'Content-Type: application/json' -d '{"isAdmin":true}'

curl -s -b /tmp/perf-cookies.txt -D /tmp/perf-headers.txt \
  'http://localhost:5132/api/<endpoint>' \
  -o /dev/null -w "Status: %{http_code}, Time: %{time_total}s\n"
```

Extract the trace ID from the response headers:

```bash
grep -i traceparent /tmp/perf-headers.txt
# Format: 00-{traceId}-{spanId}-{flags}
```

If no specific endpoint was given, list recent traces and pick the slowest:

```bash
~/.dotnet/tools/aspire otel traces api --format Json -n 10
```

### Phase 3: Analyze Trace

Drill into the trace — spans and logs separately:

```bash
~/.dotnet/tools/aspire otel spans api --trace-id <trace-id> --format Json
~/.dotnet/tools/aspire otel logs api --trace-id <trace-id> --format Json
```

Count and categorize the spans. See [trace-patterns.md](trace-patterns.md) for the pattern reference.

**Key metrics to extract:**
- Total span count
- Total duration
- Number of storage reads (blob GET/HEAD operations)
- Number of unique aggregates loaded
- Number of projection reads

### Phase 4: Diagnose

Map spans back to code. Common patterns to look for:

| Span pattern | Diagnosis | Fix |
|---|---|---|
| 3 spans per aggregate (HEAD + GET doc + GET events) | Aggregate rehydration | Use projection if only reading |
| Same aggregate loaded multiple times | Duplicate rehydration | Cache or restructure the call chain |
| 30+ spans for a single request | N+1 — loading aggregates in a loop | Replace with projection or batch query |
| Many `GetAll*` or `GetBy*` factory calls | Iterating all streams | Add a projection with an index |
| 2 spans (HEAD + GET on `projections/*.json`) | Projection read (efficient) | This is good — no action needed |
| 1 span (`GET tags/document/*.json`) | Tag-based lookup (efficient) | This is good — no action needed |

Read the relevant endpoint code to confirm which calls produce the excess spans.

### Phase 5: Recommend

Present findings to the user:

```
PERFORMANCE ANALYSIS — {endpoint}
==================================

Request:    {method} {url}
Duration:   {time}s
Spans:      {count} ({breakdown})

Diagnosis:
  {description of the bottleneck}

Bottleneck Code:
  {file}:{line} — {description of the problematic call}

Recommendation:
  {specific fix — e.g., "Replace factory.GetByXAsync() with projection lookup"}

Expected Improvement:
  Spans: {current} → ~{expected}
  Reason: {why this reduces spans}
```

### Phase 6: Verify Fix (if user applies the fix)

After code changes:

1. Restart the resource and wait for healthy state:
   ```bash
   ~/.dotnet/tools/aspire resource api restart
   ~/.dotnet/tools/aspire wait api --status healthy
   ```

2. Re-exercise the same endpoint (Phase 2).

3. Pull the new trace and compare:
   ```
   Before: {X} spans, {Y}s
   After:  {X} spans, {Y}s
   Improvement: {reduction}
   ```

4. If spans are still high, repeat from Phase 3.

## Flags

| Flag | Behavior |
|---|---|
| (no flag) | Full profiling workflow — trace, analyze, recommend |
| `--compare` | Re-run a previous trace comparison after a fix |

## Alternative: Browser-Driven Trace Generation

If you need to exercise the full frontend→API flow (e.g., to catch middleware, auth, or CORS spans that don't fire from curl), use playwright-cli to drive a real browser session:

```bash
playwright-cli open <frontend-url>
# Navigate to login page and authenticate if needed
playwright-cli goto <frontend-url>/<target-page>
playwright-cli close
```

Then pull the trace from Aspire as in Phase 3.

## Tips

- **zsh URL quoting**: Always single-quote URLs with `?` in curl to avoid zsh glob expansion:
  ```bash
  curl -s -b /tmp/perf-cookies.txt 'http://localhost:5132/api/events?distance=50'
  ```

## Supporting Files

- [trace-patterns.md](trace-patterns.md) — Detailed span pattern reference for event sourcing projects
