# Hono

> Web Standards 기반 초경량 프레임워크

<references>
@middleware.md
@validation.md
@error-handling.md
@rpc.md
</references>

---

<setup>
```bash
npm install hono
```
</setup>

---

<quick_patterns>

## 라우트

```typescript
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => c.text('Hello'))
app.post('/', (c) => c.text('POST /'))
app.get('/users/:id', (c) => c.json({ id: c.req.param('id') }))
app.get('/posts/:postId/comments/:commentId', (c) => {
  const { postId, commentId } = c.req.param()
  return c.json({ postId, commentId })
})

export default app
```

## 라우트 그룹

```typescript
const users = new Hono()
users.get('/', (c) => c.json({ users: [] }))
users.get('/:id', (c) => c.json({ id: c.req.param('id') }))
users.post('/', (c) => c.json({ created: true }, 201))

app.route('/users', users)
```

## Context

```typescript
// Request
app.get('/info', (c) => {
  const url = c.req.url
  const path = c.req.path
  const method = c.req.method
  const id = c.req.param('id')
  const page = c.req.query('page')
  const auth = c.req.header('Authorization')
  return c.json({ url, path, method })
})

// Body
app.post('/json', async (c) => {
  const body = await c.req.json()
  return c.json(body)
})

app.post('/form', async (c) => {
  const body = await c.req.parseBody()
  return c.json(body)
})

// Response
c.text('Hello')
c.json({ message: 'Hello' })
c.json({ id: 1 }, 201)
c.html('<h1>Hello</h1>')
c.redirect('/new')
c.notFound()
```

## Bindings & Variables

```typescript
type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
}

type Variables = {
  userId: string
  user: { id: string; name: string }
}

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// 환경 변수
app.get('/', (c) => {
  const dbUrl = c.env.DATABASE_URL
  return c.json({ connected: true })
})

// Variables
app.use(async (c, next) => {
  c.set('userId', '123')
  await next()
})

app.get('/me', (c) => {
  const userId = c.get('userId')
  return c.json({ userId })
})
```

</quick_patterns>
