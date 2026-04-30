# Middleware

> Middleware rules for validation, context propagation, and safe client-to-server data transfer

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Function middleware uses `createMiddleware({ type: 'function' })` | Official | Block wrong middleware type |
| `sendContext` is explicit and not automatic | Official | Validate before trust |
| Validate client-provided context server-side | Safety policy | Block unvalidated trust |
| Centralize shared auth/logging/tenant logic | Hypercore convention | Warn/fix in touched code |

---

## Core Rule

Middleware is not just for auth. It is the boundary where request context, validation, logging, and server-safe data propagation must be made explicit.

---

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Middleware created without `{ type: 'function' }` for server functions? | BLOCKED |
| Dynamic data sent from client via `sendContext` and used on the server without validation? | BLOCKED |
| Middleware mutates context implicitly instead of returning `next({ context: ... })`? | BLOCKED |
| Shared auth/logging/tenant logic duplicated across handlers instead of middleware? | WARNING. Prefer middleware |

---

## Approved Patterns

- Use `.inputValidator()` on middleware when the middleware owns data validation
- Use `next({ context: { ... } })` to extend context
- Use client middleware `sendContext` only for data that is actually needed on the server
- Validate client-provided `sendContext` on the server before trusting it

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

- Middleware uses `{ type: 'function' }`
- Shared request logic is centralized in middleware
- `sendContext` is minimal and validated on the server
- Context extension is explicit and typed
