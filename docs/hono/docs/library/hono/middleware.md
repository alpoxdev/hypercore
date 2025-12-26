# Hono 미들웨어

> 요청/응답 처리 파이프라인

---

## 기본 사용법

```typescript
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

const app = new Hono()

app.use(logger())           // 모든 라우트
app.use('/api/*', cors())   // 특정 경로
```

### 실행 순서

```typescript
app.use(async (c, next) => {
  console.log('1. 요청 전')
  await next()
  console.log('4. 응답 후')
})

app.use(async (c, next) => {
  console.log('2. 요청 전')
  await next()
  console.log('3. 응답 후')
})
// 출력: 1 → 2 → handler → 3 → 4
```

---

## 커스텀 미들웨어

```typescript
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Env = {
  Variables: { userId: string }
}

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new HTTPException(401, { message: 'Unauthorized' })
  }

  const payload = await verifyJWT(token)
  c.set('userId', payload.sub)
  await next()
})

// 사용
app.get('/me', authMiddleware, (c) => {
  return c.json({ userId: c.get('userId') })
})
```

---

## 내장 미들웨어

### Logger

```typescript
import { logger } from 'hono/logger'
app.use(logger())
```

### CORS

```typescript
import { cors } from 'hono/cors'

app.use('/api/*', cors({
  origin: ['https://example.com'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}))
```

### Bearer Auth

```typescript
import { bearerAuth } from 'hono/bearer-auth'

app.use('/api/*', bearerAuth({
  verifyToken: async (token) => token === 'valid-token',
}))
```

### Secure Headers

```typescript
import { secureHeaders } from 'hono/secure-headers'
app.use(secureHeaders())
```

### Request ID

```typescript
import { requestId } from 'hono/request-id'

app.use('*', requestId())

app.get('/', (c) => {
  return c.text(`Request ID: ${c.get('requestId')}`)
})
```

### Compress

```typescript
import { compress } from 'hono/compress'
app.use(compress())
```

---

## 타입 안전 미들웨어

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
  const db = c.get('db')      // Database 타입
  const user = c.get('user')  // User | null 타입
  return c.json({ users: [] })
})
```

---

## 관련 문서

- [기본 사용법](./index.md)
- [에러 처리](./error-handling.md)
