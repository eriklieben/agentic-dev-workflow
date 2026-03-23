# Changelog: dev-tdd-backend

## 1.2.0 — 2026-03-23

- **Breaking:** Migrated Aspire runtime verification from MCP tools to Aspire CLI 13.2+
- Replaced `mcp__aspire__execute_resource_command` with `aspire resource api restart` + `aspire wait api --status healthy`
- Replaced `mcp__aspire__list_console_logs` with `aspire logs api --format Json -n 50`
- Prerequisite: Aspire CLI 13.2+ (no longer requires MCP server)

## 1.0.0 — 2026-03-17

- Initial versioned release
