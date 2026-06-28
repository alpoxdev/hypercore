# Handlers

> Keep extracted handlers type-safe and composition-friendly

---

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
