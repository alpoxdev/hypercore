# Hono 에러 처리

> HTTPException과 onError로 체계적 에러 관리

<patterns>

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

## 글로벌 핸들러

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

## 상세 응답

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

## 커스텀 에러 클래스

```typescript
// lib/errors.ts
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

```typescript
// 사용
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

</patterns>

---

<status_codes>

| 코드 | 사용 |
|-----|------|
| 400 | Invalid input |
| 401 | Unauthorized (인증 필요) |
| 403 | Access denied (권한 없음) |
| 404 | Not found |
| 409 | Already exists (충돌) |
| 422 | Validation failed |
| 429 | Rate limit exceeded |

</status_codes>
