# Changelog: dev-watch

## 2.1.0 — 2026-03-23

- Phase 1 Step 8: opens frontend via Playwright CLI after all resources healthy (if playwright-cli skill installed)
- Takes a snapshot to verify UI renders, checks `playwright-cli console` for immediate errors
- Supports interactive testing: fill, click, snapshot to verify features work
- Phase 4: writes structured testing story to daily memory for future E2E test generation
- Testing story format captures navigation, actions, expected/actual results, errors found

## 2.0.0 — 2026-03-23

**Major:** Unified start/watch/test workflow — the single "start it for testing" entry point.

- Phase 1 now auto-discovers AppHost project and starts it (no longer assumes already running)
- Discovers ALL resources via `aspire describe --format Json` (names, types, URLs, health)
- Extracts and displays dashboard URL
- Waits for ALL resources to become healthy (not just `api`)
- Presents resource status table with types and URLs
- Phase 2 captures baseline for ALL discovered resources, not just `api`
- Resource-type-aware monitoring:
  - .NET projects: otel logs (Error), otel traces (has-error), health
  - Frontend/npm: console log scanning for TS errors, NG errors, build failures
  - Infrastructure: health status only
- Auto-detects resource types from `aspire describe` `resourceType` field
- Added `--isolated` flag for worktree environments
- Updated triggers: "start it for testing", "start and watch", "run the app", "start the apphost"
- Cross-reference to `.claude/skills/aspire/SKILL.md` for full CLI reference

## 1.0.0 — 2026-03-23

- Initial release
- Phases: rebuild & restart, baseline capture, monitor loop, summary
- Monitors otel logs (error + warning), health status, and trace performance
- Integrates with dev-perf for trace investigation
- Uses Aspire CLI 13.2+ (no MCP dependency)
