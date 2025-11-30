# Hono 미들웨어

> 요청/응답 처리 파이프라인

---

## 미들웨어 기본

### 미들웨어 등록

```typescript
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

const app = new Hono()

// 모든 라우트에 적용
app.use(logger())
app.use(cors())

// 특정 경로에 적용
app.use('/api/*', cors())

// 특정 메서드 + 경로
app.post('/api/*', someMiddleware())
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

## 커스텀 미들웨어 작성

### createMiddleware 사용

```typescript
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type Env = {
  Variables: {
    userId: string
  }
}

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    throw new HTTPException(401, { message: 'Unauthorized' })
  }

  // 토큰 검증 (예시)
  const payload = await verifyJWT(token)
  c.set('userId', payload.sub)

  await next()
})
```

### 사용

```typescript
// 특정 라우트에 적용
app.get('/me', authMiddleware, (c) => {
  const userId = c.get('userId')
  return c.json({ userId })
})

// 그룹에 적용
const api = new Hono()
api.use(authMiddleware)
api.get('/profile', (c) => c.json({ id: c.get('userId') }))

app.route('/api', api)
```

---

## 내장 미들웨어

### Logger

```typescript
import { logger } from 'hono/logger'

app.use(logger())

// 커스텀 로거
app.use(logger((message, ...rest) => {
  console.log(message, ...rest)
}))
```

### CORS

```typescript
import { cors } from 'hono/cors'

// 기본
app.use('/api/*', cors())

// 설정
app.use('/api/*', cors({
  origin: 'https://example.com',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400,
}))

// 여러 origin
app.use('/api/*', cors({
  origin: ['https://example.com', 'https://app.example.com'],
}))
```

### Basic Auth

```typescript
import { basicAuth } from 'hono/basic-auth'

app.use(
  '/admin/*',
  basicAuth({
    username: 'admin',
    password: 'secret',
  })
)

// 여러 사용자
app.use(
  '/admin/*',
  basicAuth({
    username: 'admin1',
    password: 'secret1',
  }, {
    username: 'admin2',
    password: 'secret2',
  })
)

// 커스텀 검증
app.use(
  '/admin/*',
  basicAuth({
    verifyUser: async (username, password, c) => {
      return username === 'admin' && password === 'secret'
    },
  })
)
```

### Bearer Auth

```typescript
import { bearerAuth } from 'hono/bearer-auth'

app.use(
  '/api/*',
  bearerAuth({
    token: 'my-secret-token',
  })
)

// 커스텀 검증
app.use(
  '/api/*',
  bearerAuth({
    verifyToken: async (token, c) => {
      return token === 'valid-token'
    },
  })
)
```

### ETag

```typescript
import { etag } from 'hono/etag'

app.use('/static/*', etag())
```

### Compress

```typescript
import { compress } from 'hono/compress'

app.use(compress())
```

### Secure Headers

```typescript
import { secureHeaders } from 'hono/secure-headers'

app.use(secureHeaders())

// 설정
app.use(secureHeaders({
  xFrameOptions: 'DENY',
  xXssProtection: '1',
}))
```

### Request ID

```typescript
import { requestId } from 'hono/request-id'

app.use('*', requestId())

app.get('/', (c) => {
  const id = c.get('requestId')
  return c.text(`Request ID: ${id}`)
})
```

### Timing

```typescript
import { timing, startTime, endTime } from 'hono/timing'

app.use(timing())

app.get('/', async (c) => {
  startTime(c, 'db')
  await db.query()
  endTime(c, 'db')

  return c.json({ data: [] })
})
```

---

## 미들웨어 조합

```typescript
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { secureHeaders } from 'hono/secure-headers'
import { requestId } from 'hono/request-id'

const app = new Hono()

// 공통 미들웨어
app.use(logger())
app.use(requestId())
app.use(secureHeaders())

// API 전용
app.use('/api/*', cors())

// 인증 필요
app.use('/api/protected/*', authMiddleware)

// 라우트
app.get('/api/public', (c) => c.json({ public: true }))
app.get('/api/protected/data', (c) => c.json({ secret: 'data' }))
```

---

## 타입 안전 미들웨어

```typescript
import { Hono } from 'hono'
import { createMiddleware } from 'hono/factory'

// 환경 타입 정의
type Env = {
  Bindings: {
    DATABASE_URL: string
  }
  Variables: {
    db: Database
    user: User | null
  }
}

// 타입 안전 미들웨어
const dbMiddleware = createMiddleware<Env>(async (c, next) => {
  const db = new Database(c.env.DATABASE_URL)
  c.set('db', db)
  await next()
})

const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const token = c.req.header('Authorization')
  const user = token ? await verifyToken(token) : null
  c.set('user', user)
  await next()
})

// App에서 사용
const app = new Hono<Env>()

app.use(dbMiddleware)
app.use(authMiddleware)

app.get('/users', (c) => {
  const db = c.get('db')       // Database 타입
  const user = c.get('user')   // User | null 타입
  return c.json({ users: [] })
})
```

---

## 관련 문서

- [기본 사용법](./index.md)
- [Zod 검증](./validation.md)
- [에러 처리](./error-handling.md)
