# HTTP And Headers

> Server route, webhook, header, CSP, CORS, and rate-limit rules for TanStack Start apps

## Server Route Policy

- Review `src/start.ts` first when the app needs global request middleware for auth, CSP, logging, shared request context, or security headers.

- Prefer `createServerFn` for internal app RPC.
- Use server routes when HTTP semantics are genuinely required:
  - auth callback / required auth endpoints
  - webhooks
  - health/readiness
  - public machine-readable endpoints
  - asset-like endpoints such as `robots.txt`, feeds, or verification files

If the route is just internal mutation/data RPC in disguise, move it back to Server Functions.

## Browser-Facing Headers

Use explicit response headers where security behavior matters:

- `Cache-Control` for auth/session or sensitive responses
- `Content-Type` for machine-readable endpoints
- cookie attributes that match the security model
- `X-Content-Type-Options: nosniff` where applicable
- `Referrer-Policy` and `Permissions-Policy` where the product requires them

## CSP Guidance

- Prefer a deliberate CSP over no CSP when the app ships sensitive authenticated UI.
- Avoid `unsafe-inline` and `unsafe-eval` unless there is a verified product requirement.
- If inline scripts or styles are unavoidable, prefer nonce- or hash-based allowance over broad wildcards.
- Do not copy a production CSP blindly into local/dev assumptions without checking TanStack/Vite asset behavior.

## CORS And Trusted Origins

- Default to same-origin unless there is a real cross-origin requirement.
- If cross-origin access is needed, allowlist exact origins and methods.
- Keep auth/trusted-origin configuration aligned across auth library settings and route-level behavior.
- Never use `*` on credentialed/authenticated endpoints.

## Webhooks And External Callbacks

- Verify signatures before trusting payload contents.
- Apply replay protection when the provider supports timestamps or event ids.
- Return clear status codes for invalid signatures, stale payloads, and processing failures.
- Rate limit or queue heavy webhook side effects to avoid trivial abuse or retry storms.

## Rate Limiting And Abuse Controls

- Add rate limiting to login, password reset, email verify, magic link, invite, and other abuse-prone endpoints.
- Protect public search, upload, and integration endpoints when they can amplify cost.
- If the auth provider relies on client IP for rate limiting, verify trusted proxy / forwarded header handling instead of trusting raw headers blindly.
- Prefer server-side logging/auditing for repeated auth failures and suspicious origin misuse.

## Review Checklist

- Server routes are used only where HTTP semantics are real
- Sensitive responses set explicit security-relevant headers
- CSP policy is deliberate and not copy-pasted blindly
- Cross-origin behavior is explicit and minimal
- Webhooks verify signatures before trusting payloads
- Abuse-prone endpoints have rate limiting or equivalent protection
