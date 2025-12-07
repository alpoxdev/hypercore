# TanStack Start - Middleware

Server Function 및 라우트에 공통 로직 적용.

## 기본 패턴

```typescript
// 미들웨어 정의
const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(({ next }) => {
    console.log('Processing request')
    return next()
  })

// 적용
const fn = createServerFn()
  .middleware([loggingMiddleware])
  .handler(async () => ({ message: 'Hello' }))
```

## 인증 미들웨어

```typescript
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })
    return next({ context: { user: session.user } })
  })

// 사용
export const protectedFn = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => ({ user: context.user }))
```

## Zod Validation Middleware

```typescript
const workspaceMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(zodValidator(z.object({ workspaceId: z.string() })))
  .server(({ next, data }) => next())
```

## Global Middleware

```typescript
// src/start.ts
export const startInstance = createStart(() => ({
  requestMiddleware: [globalMiddleware],  // 모든 요청
  functionMiddleware: [loggingMiddleware], // 모든 Server Function
}))
```

## Route-Level

```typescript
export const Route = createFileRoute('/hello')({
  server: {
    middleware: [authMiddleware], // 모든 핸들러
    handlers: { GET: async ({ request }) => new Response('Hello') },
  },
})
```
