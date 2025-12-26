# Service Layer

도메인별 SDK/서비스 레이어 구조.

## 폴더 구조

```
services/
├── user/
│   ├── index.ts            # 진입점 (re-export)
│   ├── schemas.ts          # Zod 스키마
│   ├── queries.ts          # GET 요청 (읽기)
│   └── mutations.ts        # POST 요청 (쓰기)
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

## Queries 파일

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

## Mutations 파일

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

## 사용 예시

```typescript
// routes/users/-hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/services/user'
```

## Database 폴더

```
database/
├── prisma.ts               # Prisma Client 싱글톤
└── seed.ts                 # 시드 스크립트 (선택)
```

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
