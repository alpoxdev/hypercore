# Code Conventions

> Code writing rules for Hono projects

---

<naming>

## File Naming

| Type | Rule | Example |
|------|------|---------|
| **General Files** | kebab-case | `user-service.ts`, `auth-middleware.ts` |
| **Route Files** | kebab-case | `users.ts`, `posts.ts` |
| **Type Files** | kebab-case | `user-types.ts`, `api-types.ts` |

</naming>

---

<typescript>

## TypeScript Rules

| Rule | Description | Example |
|------|-------------|---------|
| **Function Declaration** | const functions, explicit return types | `const fn = (): ReturnType => {}` |
| **Type Definition** | interface (objects), type (unions) | `interface User {}`, `type Status = 'a' \| 'b'` |
| **No any** | Use unknown instead | `const data: unknown = JSON.parse(str)` |
| **Import Types** | Separate type imports | `import type { User } from '@/types'` |

## Patterns

```typescript
// ✅ const function with explicit type
const getUserById = async (id: string): Promise<User | null> => {
  return prisma.user.findUnique({ where: { id } })
}

// ✅ Even simple functions should have explicit types
const formatDate = (date: Date): string => {
  return date.toISOString()
}

// ✅ No any → use unknown
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}

// ❌ Don't use any
const badParse = (data: string): any => {  // ❌
  return JSON.parse(data)
}

// ❌ Don't use function keyword
function badFunction() {  // ❌
  return 'use const arrow function'
}
```

</typescript>

---

<imports>

## Import Order

```typescript
// 1. External libraries
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

// 2. Internal modules
import { authMiddleware } from './middleware/auth'
import { prisma } from './lib/prisma'
import { env } from './lib/env'

// 3. Type imports
import type { User } from './types'
import type { Context } from 'hono'
```

</imports>

---

<comments>

## Korean Comments (Per Code Block)

```typescript
// ✅ Comments per code block
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Retrieve users
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
users.get('/', async (c) => {
  const users = await prisma.user.findMany()
  return c.json({ users })
})

users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })
  if (!user) throw new HTTPException(404, { message: 'User not found' })
  return c.json({ user })
})

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Create/Update users
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
users.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  const user = await prisma.user.create({ data })
  return c.json({ user }, 201)
})
```

```typescript
// ❌ Granular comments (prohibited)
users.get('/', async (c) => {  // Retrieve user list
  const users = await prisma.user.findMany()  // Query from DB
  return c.json({ users })  // Return JSON
})
```

</comments>

---

<error_handling>

## Error Handling Patterns

### Using HTTPException

```typescript
import { HTTPException } from 'hono/http-exception'

// ✅ Use HTTPException
users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})

// ❌ Don't use generic Error
users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new Error('User not found')  // ❌
  }

  return c.json({ user })
})
```

### Global Error Handler

```typescript
// src/index.ts
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json(
      {
        error: err.message,
        status: err.status,
      },
      err.status
    )
  }

  console.error('Unexpected error:', err)
  return c.json(
    {
      error: 'Internal Server Error',
      status: 500,
    },
    500
  )
})

app.notFound((c) => {
  return c.json(
    {
      error: 'Not Found',
      status: 404,
    },
    404
  )
})
```

### Custom Error Classes

```typescript
// lib/errors.ts
import { HTTPException } from 'hono/http-exception'

export class NotFoundError extends HTTPException {
  constructor(resource: string) {
    super(404, { message: `${resource} not found` })
  }
}

export class ValidationError extends HTTPException {
  constructor(message: string) {
    super(400, { message })
  }
}

export class UnauthorizedError extends HTTPException {
  constructor() {
    super(401, { message: 'Unauthorized' })
  }
}

// Usage
import { NotFoundError } from '@/lib/errors'

users.get('/:id', async (c) => {
  const user = await prisma.user.findUnique({ where: { id } })
  if (!user) throw new NotFoundError('User')
  return c.json({ user })
})
```

</error_handling>

---

<validation>

## Validation Patterns

### Using zValidator

```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

// ✅ Use zValidator
const createUserSchema = z.object({
  name: z.string().min(1).trim(),
  email: z.email(),
  age: z.number().int().min(18).optional(),
})

users.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')  // Type-safe
  const user = await prisma.user.create({ data })
  return c.json({ user }, 201)
})

// ❌ Don't manually validate
users.post('/', async (c) => {
  const body = await c.req.json()

  if (!body.name || !body.email) {  // ❌
    return c.json({ error: 'Invalid input' }, 400)
  }

  const user = await prisma.user.create({ data: body })
  return c.json({ user }, 201)
})
```

### Multiple Validators

```typescript
// Query Params
users.get('/', zValidator('query', z.object({ page: z.string() })), (c) => {
  const { page } = c.req.valid('query')
  return c.json({ page })
})

// Path Params
users.get('/:id', zValidator('param', z.object({ id: z.string() })), (c) => {
  const { id } = c.req.valid('param')
  return c.json({ id })
})

// JSON Body
users.post('/', zValidator('json', createUserSchema), (c) => {
  const data = c.req.valid('json')
  return c.json({ data }, 201)
})
```

</validation>

---

<examples>

## File Naming Examples

| Type | ❌ Incorrect | ✅ Correct |
|------|-------------|-----------|
| Route | `Users.ts` | `users.ts` |
| Service | `userService.ts` | `user-service.ts` |
| Middleware | `authMiddleware.ts` | `auth-middleware.ts` |
| Utility | `formatUtils.ts` | `format-utils.ts` |
| Type | `UserTypes.ts` | `user-types.ts` |

## Directory Structure

```
src/
├── routes/
│   ├── users.ts           # /users/*
│   ├── posts.ts           # /posts/*
│   └── auth.ts            # /auth/*
├── middleware/
│   ├── auth.ts            # Authentication middleware
│   ├── logger.ts          # Logging middleware
│   └── cors.ts            # CORS middleware
├── services/
│   ├── user-service.ts    # User business logic
│   └── post-service.ts    # Post business logic
├── lib/
│   ├── prisma.ts          # Prisma client
│   ├── env.ts             # Environment variables
│   └── errors.ts          # Custom errors
└── types/
    ├── user-types.ts      # User types
    └── api-types.ts       # API types
```

</examples>

---

<sources>

- [Hono Best Practices](https://hono.dev/guides/best-practices)
- [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)

</sources>
