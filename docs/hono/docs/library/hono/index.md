# Hono - Web Framework

> Web Standards 기반 초경량, 초고속 서버 프레임워크

@env-setup.md
@middleware.md
@validation.md
@error-handling.md
@rpc.md

---

## 개요

Hono는 Cloudflare Workers, Deno, Bun, Node.js 등 모든 JavaScript 런타임에서 동작하는 서버 프레임워크입니다.

---

## 설치

```bash
# npm
npm install hono

# bun
bun add hono

# yarn
yarn add hono
```

---

## 기본 사용법

### App 생성

```typescript
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

export default app
```

### HTTP 메서드

```typescript
const app = new Hono()

app.get('/', (c) => c.text('GET /'))
app.post('/', (c) => c.text('POST /'))
app.put('/', (c) => c.text('PUT /'))
app.delete('/', (c) => c.text('DELETE /'))
app.patch('/', (c) => c.text('PATCH /'))

// 모든 메서드
app.all('/hello', (c) => c.text('Any Method /hello'))

// 여러 메서드
app.on(['PUT', 'DELETE'], '/post', (c) => c.text('PUT or DELETE /post'))
```

---

## 라우팅

### 기본 라우팅

```typescript
// 정적 경로
app.get('/users', (c) => c.json({ users: [] }))

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
```

### 와일드카드

```typescript
// 와일드카드 매칭
app.get('/wild/*/card', (c) => {
  return c.text('GET /wild/*/card')
})

// 모든 하위 경로
app.get('/api/*', (c) => {
  return c.text('API catch-all')
})
```

### 라우트 그룹화

```typescript
const app = new Hono()

// 서브 라우트
const users = new Hono()
users.get('/', (c) => c.json({ users: [] }))
users.get('/:id', (c) => c.json({ id: c.req.param('id') }))
users.post('/', (c) => c.json({ created: true }, 201))

// 마운트
app.route('/users', users)
```

---

## Context (c)

### Request 정보

```typescript
app.get('/info', (c) => {
  // URL 정보
  const url = c.req.url
  const path = c.req.path
  const method = c.req.method

  // 파라미터
  const id = c.req.param('id')
  const params = c.req.param() // 모든 파라미터

  // 쿼리 스트링
  const page = c.req.query('page')
  const queries = c.req.query() // 모든 쿼리

  // 헤더
  const auth = c.req.header('Authorization')

  return c.json({ url, path, method })
})
```

### Request Body

```typescript
// JSON
app.post('/json', async (c) => {
  const body = await c.req.json()
  return c.json(body)
})

// Form Data
app.post('/form', async (c) => {
  const body = await c.req.parseBody()
  return c.json(body)
})

// Raw Text
app.post('/text', async (c) => {
  const text = await c.req.text()
  return c.text(text)
})
```

### Response 메서드

```typescript
// Text
app.get('/text', (c) => c.text('Hello'))

// JSON
app.get('/json', (c) => c.json({ message: 'Hello' }))

// JSON with status
app.post('/created', (c) => c.json({ id: 1 }, 201))

// HTML
app.get('/html', (c) => c.html('<h1>Hello</h1>'))

// Redirect
app.get('/old', (c) => c.redirect('/new'))

// Not Found
app.get('/404', (c) => c.notFound())
```

---

## 환경 변수 (Bindings)

```typescript
type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
  MY_BUCKET: R2Bucket  // Cloudflare R2
}

const app = new Hono<{ Bindings: Bindings }>()

app.get('/', (c) => {
  const dbUrl = c.env.DATABASE_URL
  const secret = c.env.JWT_SECRET
  return c.json({ connected: true })
})
```

---

## Variables (상태 공유)

```typescript
type Variables = {
  userId: string
  user: { id: string; name: string }
}

const app = new Hono<{ Variables: Variables }>()

// 미들웨어에서 설정
app.use(async (c, next) => {
  c.set('userId', '123')
  await next()
})

// 핸들러에서 사용
app.get('/me', (c) => {
  const userId = c.get('userId')
  return c.json({ userId })
})
```

---

## 관련 문서

- [환경 변수 설정](./env-setup.md) - .env.development, .env.production 설정 ⭐
- [미들웨어](./middleware.md)
- [Zod 검증](./validation.md)
- [에러 처리](./error-handling.md)
- [RPC Client](./rpc.md)
