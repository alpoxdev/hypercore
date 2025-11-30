# TanStack Start - Middleware

> **상위 문서**: [TanStack Start](./index.md)

미들웨어는 Server Function 및 라우트 핸들러에 공통 로직을 적용합니다.

## Server Function Middleware

```typescript
import { createMiddleware, createServerFn } from '@tanstack/react-start'

// 미들웨어 정의
const loggingMiddleware = createMiddleware({ type: 'function' })
  .client(() => {
    console.log('Client: Server function called')
  })
  .server(({ next }) => {
    console.log('Server: Processing request')
    return next()
  })

// 미들웨어 적용
const fn = createServerFn()
  .middleware([loggingMiddleware])
  .handler(async () => {
    return { message: 'Hello' }
  })
```

## Zod Validation Middleware

```typescript
import { createMiddleware } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/react-start/validators'
import { z } from 'zod'

const mySchema = z.object({
  workspaceId: z.string(),
})

const workspaceMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(zodValidator(mySchema))
  .server(({ next, data }) => {
    console.log('Workspace ID:', data.workspaceId)
    return next()
  })
```

## Global Request Middleware

```typescript
// src/start.ts
import { createStart, createMiddleware } from '@tanstack/react-start'

const myGlobalMiddleware = createMiddleware().server(({ next }) => {
  console.log('Global middleware running')
  return next()
})

export const startInstance = createStart(() => {
  return {
    requestMiddleware: [myGlobalMiddleware],
  }
})
```

## Global Server Function Middleware

```typescript
// src/start.ts
import { createStart } from '@tanstack/react-start'
import { loggingMiddleware } from './middleware'

export const startInstance = createStart(() => {
  return {
    functionMiddleware: [loggingMiddleware],
  }
})
```

## Route-Level Middleware

```typescript
export const Route = createFileRoute('/hello')({
  server: {
    middleware: [authMiddleware, loggerMiddleware], // 모든 핸들러에 적용
    handlers: {
      GET: async ({ request }) => {
        return new Response('Hello, World! from ' + request.url)
      },
      POST: async ({ request }) => {
        const body = await request.json()
        return new Response(`Hello, ${body.name}!`)
      },
    },
  },
})
```

## Handler-Specific Middleware

```typescript
export const Route = createFileRoute('/hello')({
  server: {
    handlers: ({ createHandlers }) =>
      createHandlers({
        GET: {
          middleware: [loggerMiddleware], // GET에만 적용
          handler: async ({ request }) => {
            return new Response('Hello, World! from ' + request.url)
          },
        },
      }),
  },
})
```

## 인증 미들웨어 예시

```typescript
import { createMiddleware } from '@tanstack/react-start'
import { redirect } from '@tanstack/react-router'

const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()

    if (!session) {
      throw redirect({ to: '/login' })
    }

    return next({ context: { user: session.user } })
  })

// 사용
export const protectedFn = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    // context.user 사용 가능
    return { user: context.user }
  })
```
