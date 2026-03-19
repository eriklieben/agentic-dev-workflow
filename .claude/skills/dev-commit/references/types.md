# Commit Types — Detailed Reference

Based on [Angular commit message guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md)
and the [Conventional Commits](https://www.conventionalcommits.org/) specification.

## Angular Types (Core)

### `feat:` — New Feature

Use when adding completely new functionality.

```
feat: add user authentication system
feat: add dark mode toggle
feat(api): add payment processing endpoint
feat: add export to csv functionality
```

### `fix:` — Bug Fix

Use when correcting incorrect behavior.

```
fix: resolve database connection timeout
fix: correct validation logic for email fields
fix(auth): prevent token expiration edge case
fix: handle null values in user profile
```

### `docs:` — Documentation

Use when changing documentation only. Body is optional for this type.

```
docs: update installation instructions
docs(api): add examples for webhook endpoints
docs: fix typo in contributing guide
```

### `refactor:` — Code Refactoring

Use when restructuring code without changing behavior.

```
refactor: extract validation logic to separate module
refactor: simplify database query logic
refactor(auth): reorganize authentication flow
```

### `perf:` — Performance Improvements

Use when optimizing performance.

```
perf: optimize image loading
perf: reduce api response time
perf: implement lazy loading for components
```

### `test:` — Test Changes

Use when adding or modifying tests.

```
test: add unit tests for user service
test(e2e): add checkout flow tests
test: fix flaky integration test
```

### `build:` — Build System and Dependencies

Use when changing build configuration or updating dependencies.

```
build: update webpack config for production
build: configure turborepo for better caching
build: add msbuild binlog output to CI
build: update aspire sdk to 13.1.2
```

### `ci:` — CI Configuration

Use when modifying CI/CD pipelines.

```
ci: optimize release workflow dependencies
ci: add caching for npm dependencies
ci: update node version in workflow
```

## Extended Types (Conventional Commits)

These types are not part of Angular's core spec but are widely used.

### `chore:` — Maintenance

Use for tooling and housekeeping that doesn't fit other types.

```
chore: update build script for monorepo
chore: configure prettier for typescript
chore: add npm script for local development
```

### `style:` — Code Style

Use for formatting changes that don't affect logic.

```
style: format code with prettier
style: fix eslint warnings
style: adjust indentation
```

## Reverts

Reverts use the `revert:` prefix followed by the original commit header.
The body must include the SHA of the reverted commit.

```
revert: feat: add dark mode toggle

This reverts commit abc1234.
Reason: broke mobile layout on small screens.
```

## Breaking Changes and Deprecations

Any type can be a breaking change by adding `!` after the type:

```
feat!: change api response format to include metadata

BREAKING CHANGE: API responses now return {data, metadata} instead of raw data.
Migration: update client code to read response.data instead of response directly.
```

Deprecations use the `DEPRECATED:` footer:

```
refactor(auth): switch to new token format

DEPRECATED: the old /auth/token endpoint will be removed in v3.
Use /auth/v2/token instead. See migration guide at docs/auth-migration.md.
```

## Scopes

Scopes provide context about which area of the codebase changed.
Keep them short and consistent within a project.

```
feat(api): add user endpoint
fix(auth): resolve token refresh issue
docs(readme): update installation steps
test(e2e): add checkout flow tests
refactor(db): optimize query performance
```
