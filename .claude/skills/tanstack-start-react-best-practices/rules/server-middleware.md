---
title: Use Middleware for Cross-Cutting Concerns
impact: HIGH
impactDescription: centralizes auth, logging, validation
tags: server, middleware, createMiddleware, authentication, tanstack-start
---

## 크로스 커팅 관심사에 Middleware 사용

`createMiddleware()`로 인증, 로깅, 에러 처리 등 공통 로직을 중앙화합니다. 각 Server Function에 반복 코드를 작성하지 마세요.

**❌ 잘못된 예시 (모든 Server Function에 인증 로직 반복):**

```typescript
import { createServerFn } from '@tanstack/react-start'

const getTodos = createServerFn().handler(async () => {
  const session = await getSession()
  if (!session?.user) throw new Error('Unauthorized')
  return await db.todo.findMany({ where: { userId: session.user.id } })
})

const createTodo = createServerFn({ method: 'POST' })
  .handler(async (data) => {
    const session = await getSession()
    if (!session?.user) throw new Error('Unauthorized')
    return await db.todo.create({ data: { ...data, userId: session.user.id } })
  })
```

**✅ 올바른 예시 (Middleware로 인증 중앙화):**

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createMiddleware } from '@tanstack/react-start'

// 인증 미들웨어 정의 (재사용 가능)
const authMiddleware = createMiddleware()
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session?.user) {
      throw redirect({ to: '/login' })
    }
    return next({ context: { user: session.user } })
  })

// Server Functions에 미들웨어 적용
const getTodos = createServerFn()
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return await db.todo.findMany({ where: { userId: context.user.id } })
  })

const createTodo = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator((d: unknown) => TodoSchema.parse(d))
  .handler(async ({ data, context }) => {
    return await db.todo.create({ data: { ...data, userId: context.user.id } })
  })
```

**미들웨어 체이닝:**

```typescript
const loggingMiddleware = createMiddleware()
  .server(async ({ next }) => {
    const start = Date.now()
    const result = await next()
    console.log(`Duration: ${Date.now() - start}ms`)
    return result
  })

// 여러 미들웨어 조합 (배열 순서대로 실행)
const protectedAction = createServerFn({ method: 'POST' })
  .middleware([loggingMiddleware, authMiddleware])
  .handler(async ({ context }) => { /* ... */ })
```

**실행 순서:** inputValidator → middleware (배열 순서) → handler

**주의사항:**
- 미들웨어 코드가 클라이언트 번들에 포함될 수 있으므로, DB 연결/API 키 등 민감 정보는 handler 내에서만 사용
- `redirect()` 사용 시 직렬화 에러가 발생할 수 있으므로 `throw redirect()` 패턴 사용

참고: [Middleware Guide](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)
