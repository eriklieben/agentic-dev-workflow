# Changelog: dev-perf

## 2.0.0 — 2026-03-23

**Breaking:** Migrated from Aspire MCP tools to Aspire CLI 13.2+.

- Replaced all `mcp__aspire__*` tool calls with direct CLI commands
- Phase 1 now uses `aspire doctor`, `aspire ps`, and `aspire describe`
- Phase 2 uses `aspire otel traces` with `--has-error` and `-n` filters
- Phase 3 uses separate `aspire otel spans` and `aspire otel logs` (replaces combined `list_trace_structured_logs`)
- Phase 6 uses `aspire resource restart` + `aspire wait --status healthy` (replaces `execute_resource_command` + manual polling)
- Prerequisite changed: requires Aspire CLI 13.2+ instead of MCP server
- Documents `~/.dotnet/tools/aspire` path explicitly until PATH order is resolved

See [docs/spikes/aspire-mcp-vs-cli.md](../../../docs/spikes/aspire-mcp-vs-cli.md) for the comparison analysis.

## 1.1.0 — 2026-03-21

- Added browser-driven trace generation section for full frontend→API flow profiling (contributed from dotnet-community-api)
- Added zsh URL quoting tip to avoid glob expansion in curl commands (contributed from dotnet-community-api)

## 1.0.0 — 2026-03-19

- Initial versioned release
