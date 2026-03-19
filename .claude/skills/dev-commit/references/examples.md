# Commit Message Examples

## Anatomy

```
<type>[optional scope]: <description>  <- title (under 72 chars)
                                       <- blank line
[optional body explaining why]         <- body (optional)
                                       <- blank line
[optional footer(s)]                   <- footer (optional)
```

## Good vs Bad

### New Feature

```
# BAD — missing type, capitalized, no details
Add user authentication

# GOOD
feat: add user authentication system
```

### Bug Fix

```
# BAD — capitalized type + description, period
Fix: Resolve database connection timeout.

# GOOD
fix: resolve database connection timeout
```

### Documentation

```
# BAD — missing type, wrong tense
updated the api docs

# GOOD
docs(api): update endpoint documentation
```

### Too Long

```
# BAD — 120 chars, too much in title
feat: Add user authentication system with OAuth2 integration, JWT tokens, refresh mechanism, and comprehensive error handling

# GOOD — details in body
feat: add user authentication with oauth2

Implements JWT token-based authentication with refresh mechanism.
Includes comprehensive error handling for edge cases.
```

## Feature Examples

```
feat: add export to csv functionality
feat(reports): add export to csv functionality
feat(ui): add dark mode toggle
feat(api): add user profile endpoint
```

With body:
```
feat(api): add user profile endpoint

GET /api/users/:id returns user profile data.
Includes avatar URL, bio, and public stats.
```

## Bug Fix Examples

```
fix: resolve database connection timeout
fix(auth): prevent token expiration edge case
fix: correct email validation regex
fix(forms): prevent submission with invalid data
```

With explanation:
```
fix: handle null values in user profile

Prevents crash when optional profile fields are missing.
Adds fallback values for display.
```

## Refactoring Examples

```
refactor: extract validation logic to separate module
refactor(auth): simplify token refresh logic
refactor(db): optimize query performance
```

## Multi-line Examples

With body:
```
feat: add rate limiting to api endpoints

Implements token bucket algorithm with 100 req/min limit.
Returns 429 status with Retry-After header when exceeded.
Configurable via RATE_LIMIT_MAX env variable.
```

With footer:
```
fix: resolve memory leak in websocket connections

Properly cleans up event listeners on disconnect.
Reduces memory usage by ~40% under load.

Closes #1234
```

## Breaking Changes

```
feat!: change api response format to include metadata

BREAKING CHANGE: API responses now return {data, metadata} instead of raw data
```

```
refactor!: restructure database schema

BREAKING CHANGE: User table column names have changed.
Run migration to update.
```

## Anti-Patterns

```
# Vague
fix: fix bug
feat: update code
chore: changes

# Wrong capitalization
Fix: resolve issue
feat: Add feature
FEAT: add feature

# Wrong tense
feat: added feature
fix: fixing bug
docs: updating readme

# Period at end
feat: add feature.
fix: resolve bug.

# Too long
feat: add comprehensive user authentication system with oauth2 integration and jwt token support including refresh tokens

# Missing type
add user authentication
resolve database timeout

# WIP messages
wip: working on feature
temp: temporary fix
```
