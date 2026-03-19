# Authentication & Service Worker Security Patterns

Code examples and detailed patterns for Angular frontend security. Referenced from SKILL.md sections 4 and 10.

## Cookie-Based Sessions

```typescript
// Preferred: cookie-based sessions with __Host- prefix
// The server sets the cookie; Angular just sends requests with credentials

// Use __Host-auth prefix for maximum cookie security:
//   __Host-auth=<session>; Secure; HttpOnly; SameSite=Strict; Path=/
//
// The __Host- prefix enforces:
//   - Secure flag (HTTPS only)
//   - No Domain attribute (bound to exact origin)
//   - Path must be /
//
// Angular does NOT touch the cookie — it's HttpOnly.
// Just ensure withCredentials is set for cross-origin API calls:

@Component({
  standalone: true,
  template: `...`
})
export class AuthAwareComponent {
  private readonly http = inject(HttpClient);

  fetchProtectedData() {
    // Cookies are sent automatically for same-origin requests
    return this.http.get('/api/data');
  }
}
```

## OAuth2 with PKCE

```typescript
// OAuth2 + PKCE flow (GitHub, Google, Microsoft)
// PKCE prevents authorization code interception — mandatory for SPAs

@Component({
  standalone: true,
  imports: [RouterLink],
  template: `
    <button (click)="login()">Sign in with GitHub</button>
  `
})
export class LoginComponent {
  private readonly authService = inject(AuthService);

  login() {
    // AuthService generates code_verifier + code_challenge
    // Redirects to provider's /authorize endpoint with:
    //   response_type=code
    //   code_challenge=<sha256(verifier)>
    //   code_challenge_method=S256
    //
    // On callback, server exchanges code + verifier for tokens
    // Tokens stay server-side; client gets a session cookie
    this.authService.initiateOAuthFlow('github');
  }
}
```

**Security notes for PKCE:**
- `code_verifier` generated with cryptographically secure random bytes
- `code_verifier` stored only in memory or `sessionStorage` (not `localStorage`)
- `code_challenge_method` is always `S256` (never `plain`)
- Token exchange happens server-side — tokens never reach the browser

## Route Guards (Functional)

```typescript
// Modern functional guard — no classes needed
export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  return auth.isAuthenticated()
    ? true
    : inject(Router).createUrlTree(['/login']);
};

// Role-based guard
export const roleGuard = (requiredRole: string): CanActivateFn => {
  return (route, state) => {
    const auth = inject(AuthService);
    return auth.hasRole(requiredRole)
      ? true
      : inject(Router).createUrlTree(['/unauthorized']);
  };
};

// Usage in routes
export const routes: Routes = [
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [authGuard, roleGuard('Admin')]
  }
];
```

## HTTP Interceptors (Functional)

```typescript
// Error interceptor — handle 401, 429, etc.
export const httpErrorInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401) {
        inject(AuthService).logout();
        inject(Router).navigateByUrl('/login');
      }
      if (error.status === 429) {
        // Rate limited — don't retry automatically, inform the user
        inject(NotificationService).warn('Too many requests. Please wait.');
      }
      return throwError(() => error);
    })
  );
};

// Register in app config
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([httpErrorInterceptor])
    )
  ]
};
```

## Service Worker — ngsw-config.json Data Groups

```json
{
  "dataGroups": [
    {
      "name": "auth-endpoints",
      "urls": ["/api/auth/**", "/api/session/**"],
      "cacheConfig": {
        "strategy": "freshness",
        "maxSize": 0,
        "maxAge": "0u",
        "timeout": "5s"
      }
    },
    {
      "name": "feature-flags",
      "urls": ["/api/features"],
      "cacheConfig": {
        "strategy": "performance",
        "maxSize": 5,
        "maxAge": "1h",
        "timeout": "3s"
      }
    }
  ]
}
```

**Key rules:**
- **Freshness** for auth endpoints — never serve cached auth responses
- **Performance** for stable data (feature flags, public config) — reduces latency
- **Never cache** sensitive user data (PII, tokens, payment info) in the Service Worker
- **`maxAge: "0u"`** effectively prevents caching for endpoints that must always be fresh
