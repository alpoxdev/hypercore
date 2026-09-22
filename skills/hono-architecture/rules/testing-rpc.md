# Testing and RPC

> Protect typed clients and tests from route-shape regressions

---
## Stable Hono 4.13 Baseline

Hono RPC requires TypeScript `strict` on both server and client. Producer and consumer Hono versions must match; version skew can cause excessively deep type instantiation. Large contracts may also degrade editor performance.

- Export `AppType` from the final chained route value, not a later mutated app or partial child.
- Compile and consume declarations or use project references across package boundaries; do not deep-import server implementation.
- Use `ApplyGlobalResponse` for shared global error response typing.
- Use `parseResponse()`, `InferRequestType`, and `InferResponseType` where they make client contracts observable.
- Remember that `hc` does not URL-encode path parameter values automatically; encode values or use an explicitly tested regexp route when slashes are allowed.
- Use `app.request()` for behavior, `testClient()` for server-side typed ergonomics, and a real `hc` boundary test only when client serialization/base URL behavior matters.
- Pass runtime bindings as the third argument to `app.request()` and test adapter-specific behavior separately.

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

## Sources

> No external sources were used in this file. Official Hono behavior is delegated to `references/official/hono-docs.md` (last verified 2026-08-04). Repository-local links checked 2026-09-21.
