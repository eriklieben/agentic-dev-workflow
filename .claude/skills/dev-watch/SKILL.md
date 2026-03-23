---
version: 2.1.0
name: dev-watch
description: "Unified start/watch/test workflow for Aspire apps. ALWAYS use this skill when the user says: 'start it for testing', 'start and watch', 'run the app', 'start the apphost', 'watch the app', 'monitor for errors', 'keep an eye on logs', 'start the app and watch it', 'rebuild and check', 'anything weird in the logs?', 'babysit the app', or wants ongoing telemetry monitoring while they work. This skill starts the AppHost, discovers all resources, waits for health, then continuously monitors for errors and regressions."
user-invocable: true
argument-hint: "[resource] [--rebuild] [--baseline] [--isolated]"
---

# Dev Watch — Unified Start/Watch/Test Workflow

The single "start it for testing" entry point. Starts the Aspire AppHost, discovers all resources, waits for everything to be healthy, then continuously monitors telemetry for unexpected issues. Alerts you when something looks wrong so you can keep coding with confidence.

For full Aspire CLI reference, see `.claude/skills/aspire/SKILL.md`.

## When to Use

- Starting the app for manual testing or development
- After making code changes and wanting to verify nothing broke
- When you want background monitoring while continuing to work
- After a deploy to staging and wanting to watch for regressions
- When debugging intermittent issues that need observation over time

## Prerequisites

- Aspire CLI 13.2+ at `~/.dotnet/tools/aspire`
- AppHost project in the workspace (will be auto-discovered)

## Instructions for Claude

### Phase 1: Start & Discover

**Step 1 — Find the AppHost:**

If not specified by the user, discover it:

```bash
find . -name "*.AppHost.csproj" -not -path "*/bin/*" -not -path "*/obj/*" | head -5
```

Also check `workflow.json` if available for project configuration.

**Step 2 — Check if already running:**

```bash
~/.dotnet/tools/aspire ps --format Json
```

**Step 3 — Start the AppHost:**

If no AppHost is running (or user wants a fresh start):

```bash
cd <apphost-directory>
~/.dotnet/tools/aspire start
```

Use `--isolated` flag when working in git worktrees to avoid port conflicts:

```bash
~/.dotnet/tools/aspire start --isolated
```

**Step 4 — Discover all resources:**

```bash
~/.dotnet/tools/aspire describe --format Json
```

Parse the JSON output to build a resource inventory:
- Resource names
- Resource types (from `resourceType` field)
- URLs/endpoints
- Current health status

**Step 5 — Extract dashboard URL:**

The dashboard URL is in the `aspire describe` output or shown during `aspire start`. Display it for the user.

**Step 6 — Wait for ALL resources to become healthy:**

Loop over each discovered resource and wait:

```bash
~/.dotnet/tools/aspire wait <resource-name> --status healthy
```

If any resource fails to become healthy within 60 seconds, check its console logs:

```bash
~/.dotnet/tools/aspire logs <failed-resource> --format Json -n 30
```

Report the failure and stop — don't continue monitoring a broken app.

**Step 7 — Present status table:**

```
RESOURCE STATUS
═══════════════════════════════════════════════════
Name          Type        URL                       Health
──────────────────────────────────────────────────
api           project     http://localhost:5139      Healthy
web           npm         http://localhost:4200      Healthy
redis         container   localhost:6379             Healthy
postgres      container   localhost:5432             Healthy
═══════════════════════════════════════════════════
Dashboard: https://localhost:17145

All resources healthy. Go test — I'm watching.
```

**Step 8 — Open the frontend (if Playwright CLI is available):**

If a `playwright-cli` skill is installed (`.claude/skills/playwright-cli/SKILL.md` exists), open the frontend resource in a browser to verify the UI is rendering:

```bash
playwright-cli open <web-url> --browser=msedge --headed
playwright-cli snapshot
```

Read the snapshot to confirm the page loaded correctly. If there are immediate console errors:

```bash
playwright-cli console
```

Report any errors. This catches frontend build failures, missing providers, or broken lazy routes that Aspire health checks don't cover.

If the user asked you to test a specific feature, use `playwright-cli fill`, `click`, and `snapshot` to interact with the UI and verify it works. Check `playwright-cli console` and `aspire otel logs` after each interaction for errors on both sides.

**If `--rebuild` flag is set** (or user asks to rebuild), rebuild after start:

```bash
~/.dotnet/tools/aspire resource <resource> rebuild
~/.dotnet/tools/aspire wait <resource> --status healthy
```

### Phase 2: Capture Baseline

Before watching for anomalies, establish what "normal" looks like for ALL discovered resources.

**For each .NET project resource** (api, worker, etc.):

```bash
# Recent errors (should ideally be empty)
~/.dotnet/tools/aspire otel logs <resource> --format Json --severity Error -n 10

# Recent traces with errors
~/.dotnet/tools/aspire otel traces <resource> --format Json --has-error -n 5

# Recent normal traces (for timing baseline)
~/.dotnet/tools/aspire otel traces <resource> --format Json -n 10
```

**For each frontend/npm resource** (web, site, etc.):

```bash
# Console logs — check for build completion
~/.dotnet/tools/aspire logs <resource> --format Json -n 30
```

Scan for build completion indicators and any pre-existing errors.

**For infrastructure resources** (redis, postgres, etc.):

Health status only (from `aspire describe` output).

Record the baseline state per resource:
- Number of error logs (ideally 0)
- Error trace count
- Typical trace durations (min/max/avg from the last 10)
- Resource health status

If `--baseline` flag is set, exercise key endpoints to generate fresh traces:

```bash
# Hit the main endpoints to establish timing baselines
# Adjust URLs to match the project
curl -sk 'http://localhost:5139/api/<endpoint1>' -o /dev/null -w "%{time_total}"
curl -sk 'http://localhost:5139/api/<endpoint2>' -o /dev/null -w "%{time_total}"
```

Tell the user what the baseline looks like. If there are pre-existing errors, flag them so they know.

### Phase 3: Monitor Loop

Run periodic checks across ALL resources. Default interval: every 60 seconds. Resource-type-aware monitoring:

#### .NET Project Resources (api, worker, etc.)

**Check 1: New errors**

```bash
~/.dotnet/tools/aspire otel logs <resource> --format Json --severity Error -n 5
```

Compare against baseline. If new errors appeared since last check, alert immediately with:
- Error severity and message
- Trace ID (for correlation)
- Timestamp
- Suggestion: "Want me to investigate this with `/dev-perf` or dig into the trace?"

**Check 2: Performance regression (every 3rd cycle)**

```bash
~/.dotnet/tools/aspire otel traces <resource> --format Json -n 5
```

Compare recent trace durations against baseline. Flag if:
- Any trace is >2x the baseline average duration
- Span count increased significantly (possible new N+1)
- New error traces appeared

**Check 3: Warning-level logs (every 3rd cycle)**

```bash
~/.dotnet/tools/aspire otel logs <resource> --format Json --severity Warning -n 10
```

Flag new warnings that weren't in the baseline.

#### Frontend/npm Resources (web, site, etc.)

**Check: Console log scanning**

```bash
~/.dotnet/tools/aspire logs <resource> --format Json -n 30
```

Scan for error patterns:
- `TS\d{4}` — TypeScript compilation errors
- `NG0\d{3,4}` — Angular runtime errors
- `ERROR in` — Webpack/esbuild build errors
- `Module not found` — Missing dependencies
- `ELIFECYCLE` — npm script failures
- `ExpressionChangedAfterItHasBeenCheckedError` — Change detection issues

#### Infrastructure Resources (redis, postgres, etc.)

**Check: Health status**

```bash
~/.dotnet/tools/aspire describe --format Json
```

If any resource changed from Healthy to Unhealthy/Degraded, alert immediately.

#### Auto-Detection of Resource Types

Use the `resourceType` field from `aspire describe` output to classify resources:
- `project` with .NET project path → .NET project monitoring
- `npm` or resource with npm/node indicators → Frontend monitoring
- `container` → Infrastructure monitoring
- `executable` → Check console logs only

### Alert Format

When something unexpected is found, report concisely:

```
⚠ DEV-WATCH ALERT
━━━━━━━━━━━━━━━━━
Resource: api
What:     New error — InvalidOperationException
When:     18:23:07 (2 minutes ago)
Trace:    abc123def456
Severity: Error
Message:  "Connection pool exhausted"
━━━━━━━━━━━━━━━━━
Action: Want me to investigate? I can run /dev-perf on the affected trace.
```

### Phase 4: Summary on Exit

When the user says to stop watching, or the session ends, provide a summary:

```
DEV-WATCH SESSION SUMMARY
═════════════════════════
Duration:    45 minutes (12 check cycles)
Resources:   4 monitored (api, web, redis, postgres)
Errors:      2 new (both InvalidOperationException in api)
Warnings:    0 new
Health:      All resources stayed healthy
Performance: No regressions detected
Baseline:    api avg 45ms → current avg 48ms (within normal)
```

**Testing story for memory:**

If you tested specific features during this session (via Playwright or curl), write a testing story to the daily memory file. This captures what was tested and can later be used to generate E2E tests:

```markdown
## [Feature name] — manual test (YYYY-MM-DD)
- Navigated to [page/route]
- [Actions taken: filled fields, clicked buttons, etc.]
- Expected: [what should have happened]
- Actual: [what happened — error or success]
- Errors found: [description + how fixed, or "none"]
- Final state: [working/broken, console errors, API errors]
```

This turns every testing session into future E2E test material. The steps, selectors, and expected outcomes are already captured — translating to a Playwright E2E test later is straightforward.

## Flags

| Flag | Behavior |
|---|---|
| (no flag) | Start app (if needed), then monitor all resources |
| `--rebuild` | Rebuild specified resource before monitoring |
| `--baseline` | Exercise endpoints to generate fresh timing baselines |
| `--isolated` | Use `aspire start --isolated` (for worktrees) |
| `resource` | Target a specific resource for rebuild (monitoring covers all) |

## Integration with Other Skills

- When an error is found, suggest `/dev-perf <trace-id>` for trace analysis
- When health degrades, suggest checking console logs
- When performance regresses, suggest `/dev-perf --compare`
- For full Aspire CLI reference, see `.claude/skills/aspire/SKILL.md`

## Tips

- This works best when run in the background while you code in another session
- The first check after rebuild might show cold-start noise (projection cache warming) — don't panic on the first slow trace
- For event sourcing projects, see [trace-patterns.md](../dev-perf/trace-patterns.md) for what's normal vs concerning
