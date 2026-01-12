# Server Functions

> TanStack Start Data Layer (Server Functions)

<instructions>
@../library/tanstack-start/index.md
</instructions>

---

<api_naming>

## API Names (Important)

| ✅ Correct API | ❌ Incorrect API | Description |
|----------------|------------------|-------------|
| `.inputValidator()` | ~~`.validator()`~~ | TanStack Start only supports `inputValidator` |
| `.middleware()` | - | Middleware chaining |
| `.handler()` | - | Final handler function |

**Note:** `validator` does not exist. Always use `inputValidator`.

</api_naming>

---

<folder_structure>

## Service Folder Structure

```
services/
├── user/
│   ├── index.ts         # Entry point (re-export)
│   ├── schemas.ts       # Zod schemas
│   ├── queries.ts       # GET (read)
│   └── mutations.ts     # POST (write)
├── auth/
│   ├── index.ts
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
└── post/
    ├── index.ts
    ├── schemas.ts
    ├── queries.ts
    └── mutations.ts
```

| File | Purpose |
|------|---------|
| `index.ts` | Re-export all functions |
| `schemas.ts` | Zod validation schemas |
| `queries.ts` | GET requests (read) |
| `mutations.ts` | POST/PUT/DELETE (write) |

</folder_structure>

---

<patterns>

## Schemas File

```typescript
// services/user/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
})

export const updateUserSchema = z.object({
  id: z.string(),
  email: z.email().optional(),
  name: z.string().min(1).max(100).trim().optional(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

## Queries File (GET)

```typescript
// services/user/queries.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
    })
  })

export const getUserById = createServerFn({ method: 'GET' })
  .handler(async ({ data: id }: { data: string }) => {
    const user = await prisma.user.findUnique({ where: { id } })
    if (!user) throw new Error('User not found')
    return user
  })

export const getUserByEmail = createServerFn({ method: 'GET' })
  .handler(async ({ data: email }: { data: string }) => {
    return prisma.user.findUnique({ where: { email } })
  })
```

## Mutations File (POST)

```typescript
// services/user/mutations.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'
import { createUserSchema, updateUserSchema } from './schemas'

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })

export const updateUser = createServerFn({ method: 'POST' })
  .inputValidator(updateUserSchema)
  .handler(async ({ data }) => {
    const { id, ...updateData } = data
    return prisma.user.update({ where: { id }, data: updateData })
  })

export const deleteUser = createServerFn({ method: 'POST' })
  .handler(async ({ data: id }: { data: string }) => {
    return prisma.user.delete({ where: { id } })
  })
```

## Entry Point File

```typescript
// services/user/index.ts
export * from './schemas'
export * from './queries'
export * from './mutations'
```

## Database File

```typescript
// database/prisma.ts
import { PrismaClient } from '../../generated/prisma'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

</patterns>

---

<middleware>

## Middleware Pattern

```typescript
// middleware/auth.ts
import { createMiddleware } from '@tanstack/react-start'
import { z } from 'zod'

export const authMiddleware = createMiddleware()
  .middleware(async ({ next }) => {
    const session = await getSession()
    if (!session) {
      throw new Error('Unauthorized')
    }
    return next({ context: { userId: session.userId } })
  })

// Server Function with Middleware
export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.user.findUnique({
      where: { id: context.userId },
    })
  })
```

## Middleware with inputValidator

```typescript
// middleware/role-check.ts
import { createMiddleware } from '@tanstack/react-start'
import { z } from 'zod'

const roleSchema = z.object({
  requiredRole: z.enum(['USER', 'ADMIN']),
})

export const roleMiddleware = createMiddleware()
  .inputValidator(roleSchema)
  .middleware(async ({ data, next }) => {
    const session = await getSession()
    if (session.role !== data.requiredRole) {
      throw new Error('Forbidden')
    }
    return next()
  })

// Usage
export const deleteUser = createServerFn({ method: 'POST' })
  .middleware([
    roleMiddleware.init({ requiredRole: 'ADMIN' }),
  ])
  .handler(async ({ data: id }) => {
    return prisma.user.delete({ where: { id } })
  })
```

</patterns>

---

<usage>

## TanStack Query Integration

```typescript
// routes/users/-hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/services/user'

export const useUsers = () => {
  const queryClient = useQueryClient()

  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  return {
    users,
    isLoading,
    createUser: createMutation.mutate,
    deleteUser: deleteMutation.mutate,
    isCreating: createMutation.isPending,
    isDeleting: deleteMutation.isPending,
  }
}
```

## Form Integration

```tsx
// routes/users/-components/create-user-form.tsx
import { useUsers } from '../-hooks/use-users'
import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

export const CreateUserForm = (): JSX.Element => {
  const { createUser, isCreating } = useUsers()
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    createUser(
      { data: { email, name } },
      {
        onSuccess: () => {
          setEmail('')
          setName('')
        },
      }
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      <Input
        type="text"
        placeholder="Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        required
      />
      <Button type="submit" disabled={isCreating}>
        {isCreating ? 'Creating...' : 'Create User'}
      </Button>
    </form>
  )
}
```

</usage>

---

<method_chaining>

## Method Chaining Order

```typescript
// ✅ Correct order
createServerFn({ method: 'POST' })
  .middleware([authMiddleware])      // 1. middleware (optional)
  .inputValidator(createUserSchema)  // 2. inputValidator (optional)
  .handler(async ({ data }) => {})   // 3. handler (required)

// ❌ Wrong order (TypeScript error)
createServerFn({ method: 'POST' })
  .handler(async () => {})           // ❌ handler first
  .inputValidator(schema)            // ❌ inputValidator after

// ❌ Wrong API name (does not exist)
createServerFn({ method: 'POST' })
  .validator(schema)                 // ❌ validator doesn't exist! Use inputValidator
  .handler(async ({ data }) => {})
```

</method_chaining>

---

<best_practices>

| Principle | Description |
|-----------|-------------|
| **File Separation** | Separate schemas, queries, mutations required |
| **Entry Point** | Re-export all functions in index.ts |
| **Validation** | inputValidator required for POST/PUT/DELETE |
| **Middleware** | Use middleware for auth/permissions |
| **TanStack Query** | Never call directly from client, use Query/Mutation |
| **Error Handling** | Throw clear error messages |

</best_practices>

---

<sources>

- [TanStack Start Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
- [TanStack Start Middleware](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)
- [TanStack Query Integration](https://tanstack.com/router/latest/docs/framework/react/guide/external-data-loading)

</sources>
