# Server Functions

> TanStack Start data layer (Server Functions)

---

## API Names (Critical)

| Correct API | Wrong API | Description |
|-------------|-----------|-------------|
| `.inputValidator()` | ~~`.validator()`~~ | TanStack Start only supports `inputValidator` |
| `.middleware()` | - | Middleware chaining |
| `.handler()` | - | Final handler function |
| `zodValidator()` | - | Zod adapter from `@tanstack/zod-adapter` |
| `useServerFn()` | - | Client-side hook for server function calls |

**CRITICAL: `.validator()` does NOT exist in TanStack Start.** Using `.validator()` will cause a runtime error. The ONLY correct API is `.inputValidator()`. There is no alternative, no fallback, no alias.

---

## inputValidator accepts Zod objects directly

`inputValidator` takes a Zod schema — including inline `z.object()` — directly. No adapter wrapper is required:

```typescript
// ✅ Inline z.object() — simplest pattern, works out of the box
createServerFn({ method: 'POST' })
  .inputValidator(z.object({
    email: z.email(),
    name: z.string().min(1),
  }))
  .handler(async ({ data }) => {
    // data is typed as { email: string; name: string }
  })

// ✅ Named Zod schema — also direct, no adapter needed
createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {})

// ✅ With zodValidator adapter — optional, for explicit type narrowing
createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => {})

// ❌ WRONG — .validator() does NOT exist
createServerFn({ method: 'POST' })
  .validator(z.object({ name: z.string() }))  // Runtime error!
```

> **You do NOT need `zodValidator()` to use Zod schemas with `inputValidator`.** Passing `z.object()` directly works. The `zodValidator()` adapter is optional and only needed when you want explicit type narrowing from `@tanstack/zod-adapter`.

---

## Service Folder Structure

```
services/
├── user/
│   ├── index.ts         # Entry point (re-export)
│   ├── schemas.ts       # Zod schemas
│   ├── queries.ts       # GET (read)
│   └── mutations.ts     # POST (write)
```

| File | Purpose |
|------|---------|
| `index.ts` | Re-export all functions |
| `schemas.ts` | Zod validation schemas |
| `queries.ts` | GET requests (read) |
| `mutations.ts` | POST/PUT/DELETE (write) |

---

## Schema Pattern

```typescript
// services/user/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
```

## Query Pattern (GET)

> `createServerFn()` without `method` option defaults to `GET`.

```typescript
// services/user/queries.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany({ orderBy: { createdAt: 'desc' } })
  })

export const getUserById = createServerFn({ method: 'GET' })
  .handler(async ({ data: id }: { data: string }) => {
    const user = await prisma.user.findUnique({ where: { id } })
    if (!user) throw new Error('User not found')
    return user
  })
```

## Mutation Pattern (POST)

```typescript
// services/user/mutations.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'
import { createUserSchema } from './schemas'

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

---

## zodValidator Adapter Pattern

> For explicit validation with `@tanstack/zod-adapter`

```typescript
import { createServerFn } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const UserSchema = z.object({
  name: z.string().min(1),
  age: z.number().min(0),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(UserSchema))
  .handler(async ({ data }) => {
    // data is fully typed and validated
    return prisma.user.create({ data })
  })
```

> Both direct Zod schema (`inputValidator(schema)`) and adapter (`inputValidator(zodValidator(schema))`) are supported. The adapter provides explicit type narrowing.

---

## useServerFn Hook (Client-side)

> Official hook for calling server functions in React components

```typescript
import { useServerFn } from '@tanstack/react-start'
import { useQuery } from '@tanstack/react-query'
import { getUsers } from './-functions/get-users'

const UserList = (): JSX.Element => {
  const getServerUsers = useServerFn(getUsers)

  const { data } = useQuery({
    queryKey: ['users'],
    queryFn: () => getServerUsers(),
  })

  return <div>{/* render users */}</div>
}
```

| Pattern | When to Use |
|---------|-------------|
| Direct call in loader | `loader: () => getUsers()` (server-side) |
| `useServerFn` + `useQuery` | Client-side data fetching in components |
| `useServerFn` + `useMutation` | Client-side mutations in components |

---

## Middleware Pattern

```typescript
// functions/middlewares/auth.ts
import { createMiddleware } from '@tanstack/react-start'

export const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw new Error('Unauthorized')
    return next({ context: { userId: session.userId } })
  })

// Usage
export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.user.findUnique({ where: { id: context.userId } })
  })
```

---

## Method Chaining Order (Required)

```typescript
// Pattern A: middleware first
createServerFn({ method: 'POST' })
  .middleware([authMiddleware])      // 1. middleware
  .inputValidator(createUserSchema)  // 2. inputValidator
  .handler(async ({ data }) => {})   // 3. handler (always last)

// Pattern B: inputValidator first (also valid)
createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))  // 1. inputValidator
  .middleware([authMiddleware])                     // 2. middleware
  .handler(async ({ data, context }) => {})        // 3. handler (always last)

// Wrong order (TypeScript error)
createServerFn({ method: 'POST' })
  .handler(async () => {})           // handler first -> error
  .inputValidator(schema)

// Wrong API name (does not exist)
createServerFn({ method: 'POST' })
  .validator(schema)                 // validator doesn't exist! Use inputValidator
```

> Both orders are valid. `handler` must ALWAYS be last.

---

## Best Practices

| Principle | Description |
|-----------|-------------|
| **File separation** | Separate schemas, queries, mutations required |
| **Entry point** | Re-export all functions from index.ts |
| **Validation** | POST/PUT/DELETE must use inputValidator |
| **Middleware** | Use middleware for auth/permissions |
| **TanStack Query** | Direct client calls forbidden, use Query/Mutation |
| **zodValidator** | Use `@tanstack/zod-adapter` for explicit validation |
| **useServerFn** | Use in components for type-safe server function calls |
