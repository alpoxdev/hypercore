# Handlers

> Keep extracted handlers type-safe and composition-friendly

---
## Stable Hono 4.13 Baseline

`createFactory<Env>()`, `factory.createApp()`, `factory.createHandlers()`, and `createMiddleware()` are official type-preserving helpers. Use one factory per compatible `Env` surface instead of restating bindings and variables in every file.

- `createHandlers()` returns a handler tuple; spread it into the route call.
- Keep validator middleware and the handler in the same typed chain when the handler reads `c.req.valid()`.
- Return a `Response` on every terminal branch and use literal status arguments when RPC clients need status unions.
- Pass transport-neutral primitives to services; do not pass `Context` through domain or repository layers.
- Do not annotate handlers with a broad `Context` type that erases route input, output, or variable inference.

## Core Rule

- Inline handlers are acceptable for small routes
- Once handlers are extracted, preserve typing with `createFactory()` / `factory.createHandlers()`
- Prefer `factory.createApp()` when a feature module needs its own typed sub-app or shared factory options
- Keep handler files focused on transport orchestration, not domain persistence

## Preferred Pattern

```ts
import { createFactory } from 'hono/factory'

import type { AppEnv } from '@/lib/types'

const factory = createFactory<AppEnv>()

const listUsers = factory.createHandlers(async (c) => {
  return c.json({ users: [] })
})

export const usersApp = factory.createApp().get('/', ...listUsers)
```

## Review Checklist

- Extracted handlers keep context typing
- Extracted handlers preserve `c`, `c.req`, and `c.var` typing
- Handler modules do not duplicate `Env` / `Bindings` / `Variables` definitions unnecessarily
- `Variables` and `Bindings` are not implicit
- Handlers are not giant controller objects
- Services own business logic

## Sources

> No external sources were used in this file. Official Hono behavior is delegated to `references/official/hono-docs.md` (last verified 2026-08-04). Repository-local links checked 2026-09-21.
