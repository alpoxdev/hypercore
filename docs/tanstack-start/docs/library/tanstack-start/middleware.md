# TanStack Start - Middleware

Apply common logic to Server Functions and routes.

## Basic Pattern

```typescript
// Middleware definition
const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(({ next }) => {
    console.log('Processing request')
    return next()
  })

// Apply
const fn = createServerFn()
  .middleware([loggingMiddleware])
  .handler(async () => ({ message: 'Hello' }))
```

## Auth Middleware

```typescript
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })
    return next({ context: { user: session.user } })
  })

// Usage
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
  requestMiddleware: [globalMiddleware],  // All requests
  functionMiddleware: [loggingMiddleware], // All Server Functions
}))
```

## Route-Level

```typescript
export const Route = createFileRoute('/hello')({
  server: {
    middleware: [authMiddleware], // All handlers
    handlers: { GET: async ({ request }) => new Response('Hello') },
  },
})
```
