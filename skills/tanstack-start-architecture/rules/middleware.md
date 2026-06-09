# Middleware

> Middleware rules for validation, context propagation, and safe client-to-server data transfer

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Request middleware uses `createMiddleware()` by default | Official | Do not force function-only syntax for request middleware |
| Server function middleware uses `createMiddleware({ type: 'function' })` | Official | Block wrong middleware type when `.client(...)`, `.inputValidator(...)`, or server-function-only behavior is used |
| Server function middleware validation uses `.inputValidator(...)` | Official | Keep middleware and server-function validation chains conceptually separate |
| `sendContext` is explicit and not automatic | Official | Validate before trust |
| Validate client-provided context server-side | Safety policy | Block unvalidated trust |
| Centralize shared auth/logging/tenant logic | Hypercore convention | Warn/fix in touched code |

---

## Core Rule

Middleware is not just for auth. It is the boundary where request context, validation, logging, and server-safe data propagation must be made explicit.

TanStack Start has two middleware types:

- Request middleware: `createMiddleware()` or `createMiddleware({ type: 'request' })`. It runs for server requests, server routes, SSR, and server functions and only has `.server(...)`.
- Server function middleware: `createMiddleware({ type: 'function' })`. It is for `createServerFn` middleware chains and may use `.client(...)`, `.server(...)`, and `.inputValidator(...)`.

---

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Request middleware written with function-only behavior? | BLOCKED. Use `createMiddleware({ type: 'function' })` |
| Server function middleware validation written as `.validator(...)`? | BLOCKED. Middleware uses `.inputValidator(...)`; server functions also use `.inputValidator(...)` on their own chain |
| Dynamic data sent from client via `sendContext` and used on the server without validation? | BLOCKED |
| Middleware mutates context implicitly instead of returning `next({ context: ... })`? | BLOCKED |
| Shared auth/logging/tenant logic duplicated across handlers instead of middleware? | WARNING. Prefer middleware |

---

## Approved Patterns

- Use `.inputValidator(...)` on server function middleware when the middleware owns data transformation or validation
- Do not conflate middleware `.inputValidator(...)` with server-function `.inputValidator(...)`; they share a method name but belong to separate APIs
- Use `next({ context: { ... } })` to extend context
- Use client middleware `sendContext` only for data that is actually needed on the server
- Validate client-provided `sendContext` on the server before trusting it
- Use `createStart(() => ({ requestMiddleware: [...] }))` in `src/start.ts` for global request middleware

---

## `sendContext` Security Rule

Client context is not automatically trusted.

Wrong:

```ts
const requestLogger = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    return next({
      sendContext: {
        workspaceId: context.workspaceId,
      },
    })
  })
  .server(async ({ next, context }) => {
    useWorkspace(context.workspaceId)
    return next()
  })
```

Right:

```ts
const requestLogger = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    return next({
      sendContext: {
        workspaceId: context.workspaceId,
      },
    })
  })
  .server(async ({ next, context }) => {
    const workspaceId = zodValidator(z.string()).parse(context.workspaceId)
    useWorkspace(workspaceId)
    return next()
  })
```

---

## Review Checklist

- Request middleware uses `createMiddleware()` unless function-only features are needed
- Server function middleware uses `createMiddleware({ type: 'function' })`
- Server function middleware uses `.inputValidator(...)` for middleware-owned data validation
- Shared request logic is centralized in middleware
- `sendContext` is minimal and validated on the server
- Context extension is explicit and typed
