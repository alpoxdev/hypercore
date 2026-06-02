# Code Conventions

> Hono project coding rules

---

## File Naming

> camelCase filenames are forbidden. Keep all filenames in kebab-case.

| Type | Rule | Example |
|------|------|---------|
| General files | kebab-case | `create-app.ts`, `request-id.ts` |
| Route folders | kebab-case | `routes/user-profile/` |
| Handler files | kebab-case | `handlers.ts`, `list-users.ts` |
| Schema files | kebab-case | `schemas.ts`, `user-payload.ts` |
| Middleware | kebab-case | `auth.ts`, `request-id.ts` |

---

## TypeScript Rules

| Rule | Description | Example |
|------|-------------|---------|
| Function style | const arrow function, explicit return type | `const handler = (c: Context): Response => {}` |
| No any | Use unknown or concrete types | `const payload: unknown = await c.req.json()` |
| Type imports | Separate type imports | `import type { Context } from 'hono'` |
| App generics | Type `Bindings` and `Variables` when used | `new Hono<AppEnv>()` |

---

## Import Order

```ts
import { Hono } from 'hono'
import { createFactory } from 'hono/factory'
import { zValidator } from '@hono/zod-validator'

import { createApp } from '@/lib/create-app'
import { authMiddleware } from '@/middlewares/auth'
import { createUser } from '@/services/users/create-user'

import { userSchema } from './schemas'

import type { AppEnv } from '@/lib/types'
```

---

## Comment Style

- Prefer short block comments only where a code group needs orientation
- Do not add line-by-line narration
- Keep comments durable and architecture-oriented

