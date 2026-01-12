# Server Functions

> TanStack Start 데이터 레이어 (Server Functions)

<instructions>
@../library/tanstack-start/index.md
</instructions>

---

<api_naming>

## API 이름 (중요)

| ✅ 올바른 API | ❌ 잘못된 API | 설명 |
|-------------|-------------|------|
| `.inputValidator()` | ~~`.validator()`~~ | TanStack Start는 `inputValidator`만 지원 |
| `.middleware()` | - | Middleware 체이닝 |
| `.handler()` | - | 최종 handler 함수 |

**주의:** `validator`는 존재하지 않는 API입니다. 반드시 `inputValidator`를 사용하세요.

</api_naming>

---

<folder_structure>

## 서비스 폴더 구조

```
services/
├── user/
│   ├── index.ts         # 진입점 (re-export)
│   ├── schemas.ts       # Zod 스키마
│   ├── queries.ts       # GET (읽기)
│   └── mutations.ts     # POST (쓰기)
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

| 파일 | 용도 |
|------|------|
| `index.ts` | 모든 함수 re-export |
| `schemas.ts` | Zod 검증 스키마 |
| `queries.ts` | GET 요청 (읽기) |
| `mutations.ts` | POST/PUT/DELETE (쓰기) |

</folder_structure>

---

<patterns>

## Schemas 파일

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

## Queries 파일 (GET)

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

## Mutations 파일 (POST)

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

## 진입점 파일

```typescript
// services/user/index.ts
export * from './schemas'
export * from './queries'
export * from './mutations'
```

## Database 파일

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

## Middleware 패턴

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

## TanStack Query 연동

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

## Form 연동

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

## Method Chaining 순서

```typescript
// ✅ 올바른 순서
createServerFn({ method: 'POST' })
  .middleware([authMiddleware])      // 1. middleware (선택)
  .inputValidator(createUserSchema)  // 2. inputValidator (선택)
  .handler(async ({ data }) => {})   // 3. handler (필수)

// ❌ 잘못된 순서 (TypeScript 에러)
createServerFn({ method: 'POST' })
  .handler(async () => {})           // ❌ handler가 먼저
  .inputValidator(schema)            // ❌ inputValidator가 나중에

// ❌ 잘못된 API 이름 (존재하지 않음)
createServerFn({ method: 'POST' })
  .validator(schema)                 // ❌ validator는 없음! inputValidator 사용
  .handler(async ({ data }) => {})
```

</method_chaining>

---

<best_practices>

| 원칙 | 설명 |
|------|------|
| **파일 분리** | schemas, queries, mutations 분리 필수 |
| **진입점** | index.ts에서 모든 함수 re-export |
| **Validation** | POST/PUT/DELETE는 inputValidator 필수 |
| **Middleware** | 인증/권한은 middleware 사용 |
| **TanStack Query** | 클라이언트에서 직접 호출 금지, Query/Mutation 사용 |
| **에러 처리** | 명확한 에러 메시지 throw |

</best_practices>

---

<sources>

- [TanStack Start Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
- [TanStack Start Middleware](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)
- [TanStack Query Integration](https://tanstack.com/router/latest/docs/framework/react/guide/external-data-loading)

</sources>
