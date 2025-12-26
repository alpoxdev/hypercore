# Hono - Web Framework

> Web Standards 기반 초경량 서버 프레임워크

@env-setup.md
@middleware.md
@validation.md
@error-handling.md
@rpc.md

---

## 설치

```bash
npm install hono
```

---

## 기본 사용법

```typescript
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => c.text('Hello Hono!'))
app.post('/', (c) => c.text('POST /'))

// 동적 파라미터
app.get('/users/:id', (c) => {
  const id = c.req.param('id')
  return c.json({ id })
})

// 여러 파라미터
app.get('/posts/:postId/comments/:commentId', (c) => {
  const { postId, commentId } = c.req.param()
  return c.json({ postId, commentId })
})

export default app
```

---

## 라우트 그룹화

```typescript
const app = new Hono()

const users = new Hono()
users.get('/', (c) => c.json({ users: [] }))
users.get('/:id', (c) => c.json({ id: c.req.param('id') }))
users.post('/', (c) => c.json({ created: true }, 201))

app.route('/users', users)
```

---

## Context (c)

### Request

```typescript
app.get('/info', (c) => {
  const url = c.req.url
  const path = c.req.path
  const method = c.req.method
  const id = c.req.param('id')
  const page = c.req.query('page')
  const auth = c.req.header('Authorization')
  return c.json({ url, path, method })
})
```

### Request Body

```typescript
app.post('/json', async (c) => {
  const body = await c.req.json()
  return c.json(body)
})

app.post('/form', async (c) => {
  const body = await c.req.parseBody()
  return c.json(body)
})
```

### Response

```typescript
c.text('Hello')                    // Text
c.json({ message: 'Hello' })       // JSON
c.json({ id: 1 }, 201)             // JSON + status
c.html('<h1>Hello</h1>')           // HTML
c.redirect('/new')                 // Redirect
c.notFound()                       // 404
```

---

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

// 환경 변수 접근
app.get('/', (c) => {
  const dbUrl = c.env.DATABASE_URL
  return c.json({ connected: true })
})

// Variables 설정/사용
app.use(async (c, next) => {
  c.set('userId', '123')
  await next()
})

app.get('/me', (c) => {
  const userId = c.get('userId')
  return c.json({ userId })
})
```

---

## 관련 문서

- [환경 변수 설정](./env-setup.md)
- [미들웨어](./middleware.md)
- [Zod 검증](./validation.md)
- [에러 처리](./error-handling.md)
- [RPC Client](./rpc.md)
