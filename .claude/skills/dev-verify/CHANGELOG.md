# Changelog: dev-verify

## 1.1.0 — 2026-03-18

- Added inline fix menu after verification report
- Issues presented as numbered list, user picks which to fix
- Fix→re-verify cycle repeats until clean or user skips
- --fix flag auto-fixes all without menu

## 1.0.0 — 2026-03-18

- Initial release: unified entry point for backend and frontend verification
- Auto-detects .NET and Angular from project files
- Supports filtering by stack (dotnet/angular)
