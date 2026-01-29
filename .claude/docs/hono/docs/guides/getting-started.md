# Getting Started

> Quick start for Hono projects

<instructions>
@conventions.md
@env-setup.md
@../library/hono/index.md
</instructions>

---

<prerequisites>

| Requirement | Version |
|-------------|---------|
| Node.js | 18+ |
| Package Manager | npm / yarn / pnpm |

</prerequisites>

---

<installation>

## Create Project

```bash
# npm
npm create hono@latest my-app

# Select template
? Which template do you want to use?
❯ cloudflare-workers
  nodejs
  bun
  deno

cd my-app
npm install
```

## Required Packages

```bash
# Validation (Zod 4.x)
npm install zod @hono/zod-validator

# Database (Prisma 7.x)
npm install @prisma/client@7
npm install -D prisma@7

# Environment Variables
npm install @t3-oss/env-core
```

</installation>

---

<project_setup>

## Project Structure

```
src/
├── index.ts           # App entry point
├── routes/
│   ├── index.ts       # Root routes
│   ├── users.ts       # /users/*
│   └── posts.ts       # /posts/*
├── middleware/
│   ├── auth.ts
│   └── logger.ts
├── services/
│   ├── user.ts
│   └── post.ts
├── lib/
│   ├── prisma.ts
│   └── env.ts
└── types/
    └── index.ts
```

## App Configuration

```typescript
// src/index.ts
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { HTTPException } from 'hono/http-exception'

import users from './routes/users'
import posts from './routes/posts'

type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
}

const app = new Hono<{ Bindings: Bindings }>()

// Middleware
app.use('*', logger())
app.use('*', cors())

// Routes
app.route('/users', users)
app.route('/posts', posts)

// Error handler
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => c.json({ error: 'Not Found' }, 404))

export default app
```

## Route Example

```typescript
// src/routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'

const users = new Hono()

// GET /users
users.get('/', async (c) => {
  const users = [
    { id: '1', name: 'Alice' },
    { id: '2', name: 'Bob' },
  ]
  return c.json({ users })
})

// GET /users/:id
users.get('/:id', async (c) => {
  const id = c.req.param('id')
  const user = { id, name: 'Alice' }

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})

// POST /users
const createUserSchema = z.object({
  name: z.string().min(1).trim(),
  email: z.email(),
})

users.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  const user = { id: '3', ...data }

  return c.json({ user }, 201)
})

export default users
```

## Middleware Example

```typescript
// src/middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Variables = {
  userId: string
}

export const authMiddleware = createMiddleware<{ Variables: Variables }>(
  async (c, next) => {
    const token = c.req.header('Authorization')?.replace('Bearer ', '')

    if (!token) {
      throw new HTTPException(401, { message: 'Unauthorized' })
    }

    // JWT verification logic
    // const decoded = await verifyJWT(token)

    c.set('userId', 'user-id')
    await next()
  }
)
```

</project_setup>

---

<commands>

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm start` | Run production server |
| `npm run deploy` | Deploy (Cloudflare Workers, etc.) |

</commands>

---

<next_steps>

| Document | Content |
|----------|---------|
| [conventions.md](./conventions.md) | Code conventions, file naming rules |
| [env-setup.md](./env-setup.md) | Environment variable setup |
| [../library/hono/](../library/hono/) | Detailed Hono API guide |
| [../library/prisma/](../library/prisma/) | Prisma ORM usage |
| [../deployment/](../deployment/) | Deployment guides |

</next_steps>

---

<sources>

- [Hono Documentation](https://hono.dev/)
- [Hono Getting Started](https://hono.dev/getting-started/basic)
- [Hono Examples](https://github.com/honojs/hono/tree/main/examples)

</sources>
