# Hono 에러 처리

> HTTPException과 onError를 사용한 체계적인 에러 관리

---

## HTTPException

### 기본 사용

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

app.get('/users/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})
```

### HTTPException 옵션

```typescript
throw new HTTPException(400, {
  message: 'Invalid request',        // 에러 메시지
  cause: originalError,              // 원인 에러
})
```

### 일반적인 HTTP 상태 코드

```typescript
// 400 Bad Request - 잘못된 요청
throw new HTTPException(400, { message: 'Invalid input' })

// 401 Unauthorized - 인증 필요
throw new HTTPException(401, { message: 'Authentication required' })

// 403 Forbidden - 권한 없음
throw new HTTPException(403, { message: 'Access denied' })

// 404 Not Found - 리소스 없음
throw new HTTPException(404, { message: 'Resource not found' })

// 409 Conflict - 충돌
throw new HTTPException(409, { message: 'Resource already exists' })

// 422 Unprocessable Entity - 검증 실패
throw new HTTPException(422, { message: 'Validation failed' })

// 429 Too Many Requests - 요청 제한 초과
throw new HTTPException(429, { message: 'Rate limit exceeded' })

// 500 Internal Server Error - 서버 에러
throw new HTTPException(500, { message: 'Internal server error' })
```

---

## 글로벌 에러 핸들러

### onError

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

app.onError((err, c) => {
  console.error(`${err}`)

  // HTTPException 처리
  if (err instanceof HTTPException) {
    return c.json(
      {
        error: err.message,
        status: err.status,
      },
      err.status
    )
  }

  // 기타 에러
  return c.json(
    {
      error: 'Internal Server Error',
      message: err.message,
    },
    500
  )
})
```

### 상세 에러 응답

```typescript
app.onError((err, c) => {
  const requestId = c.get('requestId')

  // HTTPException
  if (err instanceof HTTPException) {
    return c.json(
      {
        success: false,
        error: {
          code: err.status,
          message: err.message,
          requestId,
        },
      },
      err.status
    )
  }

  // Zod 검증 에러 (이미 zValidator에서 처리된 경우)
  if (err.name === 'ZodError') {
    return c.json(
      {
        success: false,
        error: {
          code: 400,
          message: 'Validation failed',
          details: err.flatten(),
          requestId,
        },
      },
      400
    )
  }

  // 개발 환경에서만 스택 트레이스 포함
  const isDev = c.env.NODE_ENV === 'development'

  return c.json(
    {
      success: false,
      error: {
        code: 500,
        message: 'Internal Server Error',
        ...(isDev && { stack: err.stack }),
        requestId,
      },
    },
    500
  )
})
```

---

## 404 핸들러

### notFound

```typescript
app.notFound((c) => {
  return c.json(
    {
      error: 'Not Found',
      path: c.req.path,
      method: c.req.method,
    },
    404
  )
})
```

---

## 라우트별 에러 핸들러

```typescript
const api = new Hono()

// API 전용 에러 핸들러 (우선순위 높음)
api.onError((err, c) => {
  console.log('API-specific error handler')

  if (err instanceof HTTPException) {
    return c.json({ apiError: err.message }, err.status)
  }

  return c.json({ apiError: err.message }, 500)
})

api.get('/error', () => {
  throw new Error('API error')
})

app.route('/api', api)
```

---

## 미들웨어에서 에러 접근

### c.error 사용

```typescript
app.use(async (c, next) => {
  await next()

  // 핸들러에서 발생한 에러 접근
  if (c.error) {
    // 로깅, 모니터링 등
    console.error('Error occurred:', c.error)
  }
})
```

---

## 커스텀 에러 클래스

### errors.ts

```typescript
import { HTTPException } from 'hono/http-exception'

export class NotFoundError extends HTTPException {
  constructor(resource: string) {
    super(404, { message: `${resource} not found` })
  }
}

export class UnauthorizedError extends HTTPException {
  constructor(message = 'Unauthorized') {
    super(401, { message })
  }
}

export class ForbiddenError extends HTTPException {
  constructor(message = 'Access denied') {
    super(403, { message })
  }
}

export class ValidationError extends HTTPException {
  constructor(message: string, public details?: unknown) {
    super(422, { message })
  }
}

export class ConflictError extends HTTPException {
  constructor(resource: string) {
    super(409, { message: `${resource} already exists` })
  }
}
```

### 사용

```typescript
import { NotFoundError, ConflictError } from '@/lib/errors'

app.get('/users/:id', async (c) => {
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new NotFoundError('User')
  }

  return c.json({ user })
})

app.post('/users', async (c) => {
  const data = c.req.valid('json')
  const existing = await prisma.user.findUnique({
    where: { email: data.email },
  })

  if (existing) {
    throw new ConflictError('User with this email')
  }

  const user = await prisma.user.create({ data })
  return c.json({ user }, 201)
})
```

---

## 스트리밍 에러 처리

```typescript
import { stream } from 'hono/streaming'

app.get('/stream', (c) => {
  return stream(
    c,
    async (stream) => {
      stream.onAbort(() => {
        console.log('Stream aborted')
      })

      await stream.write(new Uint8Array([0x48, 0x65, 0x6c, 0x6c, 0x6f]))
    },
    // 에러 핸들러 (선택적)
    (err, stream) => {
      stream.writeln('An error occurred!')
      console.error(err)
    }
  )
})
```

---

## 완전한 에러 처리 설정

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { logger } from 'hono/logger'
import { requestId } from 'hono/request-id'

type Env = {
  Bindings: {
    NODE_ENV: string
  }
  Variables: {
    requestId: string
  }
}

const app = new Hono<Env>()

// 미들웨어
app.use(logger())
app.use(requestId())

// 글로벌 에러 핸들러
app.onError((err, c) => {
  const reqId = c.get('requestId')
  const isDev = c.env.NODE_ENV === 'development'

  console.error(`[${reqId}] Error:`, err)

  if (err instanceof HTTPException) {
    return c.json(
      {
        success: false,
        error: {
          status: err.status,
          message: err.message,
          requestId: reqId,
        },
      },
      err.status
    )
  }

  return c.json(
    {
      success: false,
      error: {
        status: 500,
        message: 'Internal Server Error',
        requestId: reqId,
        ...(isDev && { stack: err.stack }),
      },
    },
    500
  )
})

// 404 핸들러
app.notFound((c) => {
  return c.json(
    {
      success: false,
      error: {
        status: 404,
        message: 'Not Found',
        path: c.req.path,
      },
    },
    404
  )
})

export default app
```

---

## 관련 문서

- [기본 사용법](./index.md)
- [미들웨어](./middleware.md)
- [Zod 검증](./validation.md)
