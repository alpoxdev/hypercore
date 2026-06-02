# Server Routes

> TanStack Start server routes are official HTTP endpoints; hypercore reserves them for actual HTTP semantics.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Server routes defined with `createFileRoute(... )({ server })` | Official | Allowed |
| Server routes for webhooks/files/health/auth/public machine endpoints | Official + Hypercore convention | Allowed with justification |
| Internal app RPC implemented as server route | Hypercore convention | Prefer server function |
| Unvalidated request body in server route | Safety policy | Validate before trust |

## Allowed Uses

Use server routes when the endpoint has HTTP semantics that are not just app-internal RPC:

- Third-party webhooks.
- Auth provider callbacks or required auth endpoints.
- Health/readiness endpoints.
- File upload/download or wildcard HTTP handlers.
- `robots.txt`, `sitemap.xml`, LLMO/metadata endpoints.
- Public machine-readable resources.

## Prefer Server Functions For

- App reads/mutations consumed by React components or route loaders.
- Internal RPC that benefits from end-to-end typing and Start server function middleware.
- Operations that should share TanStack Query invalidation patterns.

## Validation Checklist

- [ ] Every new server route states its HTTP justification.
- [ ] Request bodies, params, headers, and client-sent context are validated before trust.
- [ ] Internal app RPC uses server functions unless the user explicitly requested HTTP endpoints.
- [ ] Server route middleware is applied at route or handler level where needed.
