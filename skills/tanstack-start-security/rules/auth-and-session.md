# Auth And Session Rules

> Authentication, authorization, cookie, and browser-request safety rules for TanStack Start

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Protected page has no route guard or server-side session check? | BLOCKED |
| Mutation trusts `userId`, `role`, or tenant scope from client input? | BLOCKED. Derive identity from session/context on the server |
| Auth-required server function has no session/authz enforcement? | BLOCKED |
| Cookie config is ambiguous across environments? | BLOCKED until the intent is explicit |
| State-changing browser endpoint has no origin / CSRF posture? | BLOCKED |

## Route Protection

- Use route `beforeLoad` for page-level access control and redirects.
- Use server-side session validation inside `createServerFn` handlers for protected data access and mutations.
- Treat `beforeLoad` as routing protection, not as a replacement for server-side authorization.
- Authentication alone is insufficient. Check authorization scope as close to the protected action as possible.
- Never assume a client-side redirect or hidden UI is real protection.
- Distinguish authentication failure (`401 Unauthorized` — caller must sign in or refresh credentials) from authorization failure (`403 Forbidden` — caller is signed in but lacks scope/permission). Returning the wrong code leaks scope information or breaks legitimate retry flows.

## Session Derivation

- Read session state on the server from request headers/cookies, not from client-submitted identity fields.
- For TanStack Start auth helpers, prefer server-side helpers that obtain request headers and resolve the session there. With Better Auth this typically looks like `auth.api.getSession({ headers: getRequestHeaders() })` invoked inside `createServerFn` / route `beforeLoad`, never on the client.
- Treat user id, org id, role, and feature flags from the browser as untrusted unless re-derived on the server.
- Do not store session tokens, API keys, or other auth-bearing values in `localStorage` or `sessionStorage`. Keep them in `HttpOnly` server-issued cookies. `localStorage` is reachable from any in-page script and is not a security boundary.

## Better Auth Notes

If the app uses Better Auth:

- use the TanStack Start cookies integration when relevant
- keep `tanstackStartCookies()` last in the Better Auth plugin array
- define `trustedOrigins` deliberately for cross-origin auth flows
- only enable cross-subdomain cookies when the deployment model actually requires them
- do not set `disableCSRFCheck: true` unless the user explicitly accepts the risk and the request path is not browser-exposed

## Cookie Rules

- Session cookies should be `HttpOnly` and `Secure` in production
- choose `SameSite` intentionally instead of relying on accidental defaults
- set cookie `domain` only when cross-subdomain sharing is required
- document environment differences for local dev vs production
- do not expose session-bearing values to client-side JavaScript unless that exposure is explicitly intended and low-risk

## CSRF / Browser Mutation Safety

- Any browser-reachable, state-changing endpoint needs an explicit posture:
  - same-origin only plus origin verification
  - trusted origin allowlist
  - CSRF token or equivalent framework/library protection
- Do not assume `POST` alone is CSRF-safe.
- If using a third-party auth stack, follow its anti-CSRF and trusted-origin requirements exactly.

## Review Checklist

- Protected routes redirect or deny access before privileged UI/data is used
- Protected mutations derive identity and authorization from the server session
- Cookie settings are explicit and environment-aware
- Cross-origin auth flows are allowlisted intentionally
- CSRF / origin checks exist for browser-triggered state changes
- Better Auth security overrides are justified explicitly instead of relaxed casually
