# Server Routes

> Rules for when HTTP endpoints are allowed instead of Server Functions

---

## Default Policy

For normal app features, prefer TanStack Start `createServerFn`.

Use server routes only when an actual HTTP endpoint is required.

---

## Allowed Uses

| Case | Allowed |
|------|---------|
| `better-auth` required endpoints | YES |
| Webhooks from third-party providers | YES |
| Health/readiness endpoints | YES |
| `sitemap.xml`, `robots.txt`, feeds, verification files | YES |
| Machine-readable public endpoints explicitly needed for integrations/SEO/LLMO | YES |
| Internal app RPC/data mutations that only your app consumes | NO. Use Server Functions |

---

## Route Design Rules

- Keep app-internal business RPC in Server Functions
- Keep server routes narrow, protocol-oriented, and HTTP-native
- Prefer route-level middleware for shared auth/logging and handler-level middleware for method-specific validation
- Return real `Response` objects with explicit headers/status when behavior matters
- Use dynamic route params and splats only when the endpoint shape requires them

---

## Middleware And Context

- Server routes may use route-level and handler-level middleware
- Middleware may enrich `context`
- Treat request body, headers, query params, and any client-provided context as untrusted input

---

## Review Checklist

- The endpoint truly needs HTTP semantics
- The endpoint is not just internal app RPC in disguise
- Auth/validation/logging middleware is attached where needed
- Response headers and status codes are explicit when caching, auth, or content type matter
