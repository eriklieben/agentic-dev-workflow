# Changelog: meta-bootstrap

## 1.7.0 — 2026-03-23

- Added `playwright-cli/` skill to Step 5c — installed alongside Aspire skills when AppHost detected
- Runs `playwright-cli install` to create `.playwright/cli.config.json` in target project
- Updated summary checklist to include playwright-cli

## 1.6.0 — 2026-03-23

- **Breaking:** Removed Aspire MCP server configuration (Step 5c)
- Replaced MCP setup with Aspire skill installation: copies `aspire/`, `dev-watch/`, `dev-perf/` skill dirs when AppHost detected
- No session restart needed — CLI-based skills work immediately
- Updated summary to reflect skill installation instead of MCP configuration

## 1.5.0 — 2026-03-19

- Add opencode plugin copy to Step 5b (`.opencode/plugins/hooks.ts` + `package.json`)
- Add AGENTS.md symlink creation in Step 7b for opencode compatibility
- Add `dev-commit` to project type table (all types including docs)

## 1.4.0 — 2026-03-19

- Filter dev-* skills by project type (api/frontend/library/docs) — prevents installing frontend skills in backend-only projects
- Hooks merge into `settings.local.json` instead of `settings.json` — hooks are environment-specific and should be gitignored
- Contributed from dotnet.community.api bootstrap experience

## 1.3.0 — 2026-03-19

- Conditional .NET skill detection: EF Core (grep csproj), MSBuild complexity (3+ projects or Directory.Build.props)
- Auto-install dev-dotnet-migrate for all .NET projects
- Auto-install dev-dotnet-efcore when EF Core detected
- Auto-install dev-dotnet-build when MSBuild complexity detected
- Conditional agent installation (dotnet-build-resolver, dotnet-perf-analyst)

## 1.2.0 — 2026-03-17

- USER.md resolution: check target project first, then main worktree (for bare+worktree repos where USER.md is gitignored), then workflow repo, then create from template

## 1.1.0 — 2026-03-17

- Added version tracking fields to catalog entries during bootstrap
- Populates version, installed_from, installed_version, installed_date

## 1.0.0 — 2026-03-17

- Initial versioned release
