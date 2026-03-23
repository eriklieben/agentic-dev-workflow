# Changelog: dev-tdd-frontend

## 1.2.0 — 2026-03-23

- **Breaking:** Migrated Aspire runtime verification from MCP tools to Aspire CLI 13.2+
- Replaced `mcp__aspire__list_console_logs` with `aspire logs site --format Json -n 50`
- Replaced `mcp__aspire__list_structured_logs` with `aspire otel logs api --format Json --severity Error -n 20`
- Prerequisite: Aspire CLI 13.2+ (no longer requires MCP server)

## 1.0.0 — 2026-03-17

- Initial versioned release
