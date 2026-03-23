# Changelog: dev-security-frontend

## 1.3.0 — 2026-03-23

- **Breaking:** Migrated Aspire runtime security checks from MCP tools to Aspire CLI 13.2+
- Replaced `mcp__aspire__list_console_logs` with `aspire logs site --format Json -n 50`
- Replaced `mcp__aspire__list_structured_logs` with `aspire otel logs api --format Json --severity Error -n 20`
- Prerequisite: Aspire CLI 13.2+ (no longer requires MCP server)

## 1.2.0 — 2026-03-18

- Aligned pre-deployment checklist with OWASP Top 10:2025 categories
- Added Supply Chain Security section (A03:2025)
- Added Exceptional Condition Handling section (A10:2025)
- Removed external source references

## 1.1.0 — 2026-03-18

- Marked as sub-skill invoked via /dev-security

## 1.0.0 — 2026-03-17

- Initial versioned release
