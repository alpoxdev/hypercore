# Testing and RPC

> Protect typed clients and tests from route-shape regressions

---

## Core Rule

- If the app uses `testClient()` or `hc`, preserve route type inference
- Export `AppType` when `hc` or a shared RPC/client contract depends on the app
- In larger apps, keep sub-app composition typed all the way to the exported surface
- Keep explicit response statuses so typed RPC and generated OpenAPI docs agree

## Example

```ts
export const app = new Hono()
  .get('/search', (c) => {
    const query = c.req.query('q')
    return c.json({ query })
  })

export type AppType = typeof app
```

## Large-App Contract Pattern

```ts
// app.ts
export const app = createApp()
  .route('/users', usersApp)
  .route('/billing', billingApp)

export type AppType = typeof app
```

```ts
// client.ts
import { hc } from 'hono/client'

import type { AppType } from './app'

export const client = hc<AppType>('/api')
```

Use `app.request()` for request/response behavior tests, `testClient()` for typed server-side ergonomics, and `hc<AppType>()` for shared client-contract checks.

## Non-Compliance Signatures

- Route registration uses detached mutation that erases chained route types
- `AppType` is exported from a partial sub-app when consumers expect the full API
- Response helpers omit explicit statuses for routes with multiple success or error variants
- Frontend typed clients import route internals instead of the exported app type
- Generated OpenAPI response schemas disagree with RPC-inferred response variants
- Public clients depend on 404 shape but no `app.notFound()` or explicit JSON response contract is tested

## Review Checklist

- Route types still flow through the exported app
- `testClient()` remains useful after refactors
- `hc<AppType>` or sub-app clients still infer correctly
- `AppType` is exported for RPC/client consumers, not merely because a test exists
- Detached registration did not silently erase route typing
- Request-level tests cover changed behavior with `app.request()` or the runtime adapter's equivalent
- Typed client or OpenAPI contract checks are updated when public route shapes change
