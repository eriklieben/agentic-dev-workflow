# Changelog: dev-tdd

## 1.1.0 — 2026-03-18

- Added test case planning step with user approval before writing
- Added RED→GREEN→REFACTOR loop with progress display
- Added coverage check after planned tests complete
- Added coverage loop: proposes additional tests for uncovered paths, repeats until 80%+
- Added --target flag to override coverage threshold

## 1.0.0 — 2026-03-18

- Initial release: unified entry point for backend and frontend TDD
- Auto-detects stack from project files and feature context
- Asks user when both stacks detected and no filter given
