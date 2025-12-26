# Hono 에러 처리

> HTTPException과 onError를 사용한 체계적인 에러 관리

---

## HTTPException

```typescript
import { HTTPException } from 'hono/http-exception'

app.get('/users/:id', async (c) => {
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})
```

### 일반적인 상태 코드

```typescript
throw new HTTPException(400, { message: 'Invalid input' })      // Bad Request
throw new HTTPException(401, { message: 'Unauthorized' })       // 인증 필요
throw new HTTPException(403, { message: 'Access denied' })      // 권한 없음
throw new HTTPException(404, { message: 'Not found' })          // 리소스 없음
throw new HTTPException(409, { message: 'Already exists' })     // 충돌
throw new HTTPException(422, { message: 'Validation failed' })  // 검증 실패
throw new HTTPException(429, { message: 'Rate limit exceeded' })// 요청 제한
```

---

## 글로벌 에러 핸들러

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

app.onError((err, c) => {
  console.error(err)

  if (err instanceof HTTPException) {
    return c.json({ error: err.message, status: err.status }, err.status)
  }

  return c.json({ error: 'Internal Server Error' }, 500)
})

app.notFound((c) => {
  return c.json({ error: 'Not Found', path: c.req.path }, 404)
})
```

---

## 상세 에러 응답

```typescript
app.onError((err, c) => {
  const requestId = c.get('requestId')
  const isDev = c.env.NODE_ENV === 'development'

  if (err instanceof HTTPException) {
    return c.json({
      success: false,
      error: { status: err.status, message: err.message, requestId },
    }, err.status)
  }

  return c.json({
    success: false,
    error: {
      status: 500,
      message: 'Internal Server Error',
      requestId,
      ...(isDev && { stack: err.stack }),
    },
  }, 500)
})
```

---

## 커스텀 에러 클래스

### lib/errors.ts

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
  if (!user) throw new NotFoundError('User')
  return c.json({ user })
})

app.post('/users', async (c) => {
  const existing = await prisma.user.findUnique({ where: { email } })
  if (existing) throw new ConflictError('User with this email')
  // ...
})
```

---

## 관련 문서

- [기본 사용법](./index.md)
- [미들웨어](./middleware.md)
