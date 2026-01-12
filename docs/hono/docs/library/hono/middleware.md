# Hono Middleware

> Request/Response processing pipeline

<patterns>

## Basic Usage

```typescript
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

const app = new Hono()

app.use(logger())           // All routes
app.use('/api/*', cors())   // Specific path

// Execution order
app.use(async (c, next) => {
  console.log('1. Before request')
  await next()
  console.log('4. After response')
})

app.use(async (c, next) => {
  console.log('2. Before request')
  await next()
  console.log('3. After response')
})
// Output: 1 → 2 → handler → 3 → 4
```

## Custom Middleware

```typescript
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Env = { Variables: { userId: string } }

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new HTTPException(401, { message: 'Unauthorized' })
  }

  const payload = await verifyJWT(token)
  c.set('userId', payload.sub)
  await next()
})

// Usage
app.get('/me', authMiddleware, (c) => {
  return c.json({ userId: c.get('userId') })
})
```

## Type-safe Middleware

```typescript
import { Hono } from 'hono'
import { createMiddleware } from 'hono/factory'

type Env = {
  Bindings: { DATABASE_URL: string }
  Variables: { db: Database; user: User | null }
}

const dbMiddleware = createMiddleware<Env>(async (c, next) => {
  c.set('db', new Database(c.env.DATABASE_URL))
  await next()
})

const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')
  c.set('user', token ? await verifyToken(token) : null)
  await next()
})

const app = new Hono<Env>()
app.use(dbMiddleware)
app.use(authMiddleware)

app.get('/users', (c) => {
  const db = c.get('db')      // Database type
  const user = c.get('user')  // User | null type
  return c.json({ users: [] })
})
```

</patterns>

---

<builtin>

| Middleware | Usage |
|------------|-------|
| **logger** | `app.use(logger())` |
| **cors** | `app.use('/api/*', cors({ origin: ['https://example.com'] }))` |
| **bearerAuth** | `app.use('/api/*', bearerAuth({ verifyToken: async (t) => t === 'valid' }))` |
| **secureHeaders** | `app.use(secureHeaders())` |
| **requestId** | `app.use(requestId())` → `c.get('requestId')` |
| **compress** | `app.use(compress())` |

</builtin>
