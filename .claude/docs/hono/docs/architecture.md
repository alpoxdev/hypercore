# Hono Server Architecture

> Layer-based architecture

---

## System Overview

```
Client → Middleware → Routes → Validation → Services → Database
```

---

## Project Structure

```
src/
├── index.ts            # Entry point
├── routes/             # Route modules
├── middleware/         # Custom middleware
├── validators/         # Zod schemas
├── services/           # Business logic
│   └── user/
│       ├── queries.ts  # Read operations
│       └── mutations.ts # Create/Update/Delete
├── database/           # Prisma Client
├── types/              # Type definitions
└── lib/                # Utilities
```

---

## Entry Point

```typescript
// src/index.ts
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { HTTPException } from 'hono/http-exception'
import { users } from './routes/users'

type Bindings = { DATABASE_URL: string; JWT_SECRET: string }
type Variables = { userId: string }

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

app.use(logger())
app.use('/api/*', cors())

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => c.json({ error: 'Not Found' }, 404))

app.route('/api/users', users)
app.get('/health', (c) => c.json({ status: 'ok' }))

export default app
```

---

## Routes Layer

```typescript
// routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { authMiddleware } from '@/middleware/auth'
import { createUserSchema, userIdSchema } from '@/validators/user'
import { getUsers, createUser } from '@/services/user'

const users = new Hono()

users.get('/', zValidator('query', paginationSchema), async (c) => {
  const { page, limit } = c.req.valid('query')
  return c.json(await getUsers({ page, limit }))
})

users.post('/', authMiddleware, zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  return c.json({ user: await createUser(data) }, 201)
})

export { users }
```

---

## Middleware Layer

```typescript
// middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Env = {
  Bindings: { JWT_SECRET: string }
  Variables: { userId: string }
}

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  if (!token) throw new HTTPException(401, { message: 'Unauthorized' })

  const payload = await verifyToken(token, c.env.JWT_SECRET)
  c.set('userId', payload.sub)
  await next()
})
```

---

## Validators Layer

```typescript
// validators/user.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),              // Zod v4
  name: z.string().min(1).trim(),
  password: z.string().min(8),
})

export const paginationSchema = z.object({
  page: z.coerce.number().positive().default(1),
  limit: z.coerce.number().max(100).default(10),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
```

---

## Services Layer

### Queries

```typescript
// services/user/queries.ts
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'

export const getUsers = async ({ page, limit }) => {
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      skip: (page - 1) * limit,
      take: limit,
      select: { id: true, email: true, name: true },
    }),
    prisma.user.count(),
  ])
  return { users, pagination: { page, limit, total } }
}

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({ where: { id } })
  if (!user) throw new HTTPException(404, { message: 'User not found' })
  return user
}
```

### Mutations

```typescript
// services/user/mutations.ts
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'

export const createUser = async (data: CreateUserInput) => {
  const existing = await prisma.user.findUnique({ where: { email: data.email } })
  if (existing) throw new HTTPException(409, { message: 'Email already exists' })

  return prisma.user.create({
    data: { ...data, password: await hashPassword(data.password) },
    select: { id: true, email: true, name: true },
  })
}
```

---

## Database Layer

```typescript
// database/prisma.ts
import { PrismaClient } from '../../prisma/generated/client'

const globalForPrisma = globalThis as { prisma?: PrismaClient }

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

---

## RPC Pattern

```typescript
// server
const app = new Hono()
  .route('/api/users', users)

export type AppType = typeof app

// client
import { hc } from 'hono/client'
import type { AppType } from './server'

const client = hc<AppType>('http://localhost:8787')

const res = await client.api.users.$get({ query: { page: '1' } })
const data = await res.json()
```

---

## Tech Stack

| Category | Technology | Version |
|----------|------------|---------|
| Framework | Hono | latest |
| Validation | Zod | **4.x** |
| ORM | Prisma | **7.x** |
| Runtime | Cloudflare Workers, Node.js, Bun | - |

---

## Pattern Summary

| Layer | Responsibility | Files |
|-------|----------------|-------|
| Routes | HTTP routing | `routes/*.ts` |
| Middleware | Request/Response handling | `middleware/*.ts` |
| Validators | Input validation | `validators/*.ts` |
| Services | Business logic | `services/*/*.ts` |
| Database | Data access | `database/prisma.ts` |

---

## Related Documentation

- [Hono](../library/hono/index.md)
- [Prisma](../library/prisma/index.md)
- [Cloudflare Deployment](../deployment/cloudflare.md)
