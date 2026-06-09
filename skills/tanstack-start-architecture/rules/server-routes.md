# Server Routes

> TanStack Start server routes are official HTTP endpoints; hypercore reserves them for actual HTTP semantics.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Server routes defined with `createFileRoute(... )({ server })` | Official | Allowed |
| Simple handlers use `server.handlers`; composed handlers use `createHandlers` | Official | Use the current handler shape |
| Route-level middleware can be declared with `server.middleware` | Official | Apply when all handlers share request behavior |
| Server routes for webhooks/files/health/auth/public machine endpoints | Official + Hypercore convention | Allowed with justification |
| Duplicate route path + HTTP method handlers | Official | Block collisions |
| Internal app RPC implemented as server route | Hypercore convention | Prefer server function |
| Unvalidated request body in server route | Safety policy | Validate before trust |

## Current Server Route Shape

Server routes follow TanStack Router file-route conventions. A route becomes an API route when `createFileRoute(...)(...)` includes a `server` property.

Simple handlers use a `server.handlers` object:

```ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/hello')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        return new Response('Hello, World! from ' + request.url)
      },
    },
  },
})
```

When handlers need middleware composition, use the `createHandlers` function form documented by the current server-routes guide. Use `server.middleware` when the same route-level middleware applies to all handlers.

Do not create duplicate methods for the same resolved route path. File-route variants such as `users.ts` and `users.index.ts` can resolve to the same API route; duplicate HTTP methods are invalid. wildcard/splat server routes use the trailing `$` convention, such as `routes/file/$.ts`.

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
- [ ] Simple server routes use a `server.handlers` object; composed handlers use the current `createHandlers` function form.
- [ ] `server.middleware` is used only for route-level behavior shared by all handlers.
- [ ] Duplicate route path + HTTP method collisions were checked.
- [ ] Wildcard/splat routes use the trailing `$` file-route convention when needed.
- [ ] Request bodies, params, headers, and client-sent context are validated before trust.
- [ ] Internal app RPC uses server functions unless the user explicitly requested HTTP endpoints.
- [ ] Server route middleware is applied at route or handler level where needed.
