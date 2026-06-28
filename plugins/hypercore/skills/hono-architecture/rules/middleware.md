# Middleware

> Middleware rules for request boundaries and shared concerns

---

## Core Rule

Middleware is where request-wide concerns become explicit: auth, request IDs, CORS, logging, and context enrichment.

Extract reusable middleware with typed helpers such as `createMiddleware()` when the middleware sets variables or depends on bindings.

## Non-Negotiable Rules

| Check | Rule |
|------|------|
| Middleware order assumed incorrectly | BLOCKED |
| Shared request concern duplicated in handlers | WARNING |
| `c.set()` values used without typed `Variables` | BLOCKED |
| Cross-request state assumed via `Context` | BLOCKED |
| Global `ContextVariableMap` used for values not guaranteed by app-wide middleware | BLOCKED |

## Typed Middleware Pattern

```ts
import { createMiddleware } from 'hono/factory'

import type { AppEnv } from '@/lib/types'

export const authMiddleware = createMiddleware<AppEnv>(async (c, next) => {
  const user = await resolveUser(c.req)
  c.set('user', user)
  await next()
})
```

## Review Checklist

- Registration order is intentional
- Shared concerns are centralized
- Context variables are typed
- Middleware does not become a hidden business-logic layer
- Request-scoped context values are set before handlers that read them
