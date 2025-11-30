# Getting Started

TanStack Start 프로젝트 시작 가이드입니다.

## Prerequisites

- Node.js 18+
- Yarn
- Claude Code CLI

## Project Setup

### 1. Create TanStack Start Project

```bash
npx create-tsrouter-app@latest my-app --template start
cd my-app
```

### 2. Install Dependencies

```bash
yarn install
```

### 3. Add Essential Packages

```bash
# Database (Prisma 7.x)
yarn add @prisma/client@7
yarn add -D prisma@7

# Validation (Zod 4.x)
yarn add zod

# TanStack Query
yarn add @tanstack/react-query

# UI (optional)
yarn add tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 4. Initialize Prisma

```bash
npx prisma init
```

## Project Structure

```
my-app/
├── app/
│   ├── routes/
│   │   ├── __root.tsx
│   │   ├── index.tsx
│   │   └── users/
│   │       ├── index.tsx
│   │       ├── route.tsx           # 필요시 route 설정
│   │       ├── -components/        # 페이지 전용 컴포넌트
│   │       │   └── user-card.tsx
│   │       ├── -sections/          # 섹션 분리 (복잡한 경우)
│   │       │   ├── user-list-section.tsx
│   │       │   └── user-filter-section.tsx
│   │       └── -hooks/             # 페이지 전용 훅
│   │           ├── use-users.ts
│   │           └── use-user-filter.ts
│   ├── components/                 # 공통 컴포넌트
│   │   └── ui/
│   │       ├── button.tsx
│   │       └── input.tsx
│   ├── database/                   # 데이터베이스 관련
│   │   └── prisma.ts               # Prisma Client 인스턴스
│   ├── services/                   # 도메인별 SDK/서비스 레이어
│   │   ├── user/
│   │   │   ├── index.ts            # 진입점 (re-export)
│   │   │   ├── schemas.ts          # Zod 스키마
│   │   │   ├── queries.ts          # GET 요청
│   │   │   └── mutations.ts        # POST 요청
│   │   └── auth/
│   │       ├── index.ts
│   │       ├── schemas.ts
│   │       ├── queries.ts
│   │       └── mutations.ts
│   ├── lib/                        # 공통 유틸리티
│   │   ├── query-client.ts
│   │   └── utils.ts
│   └── styles/
│       └── app.css
├── generated/
│   └── prisma/                     # Prisma Client 출력
├── prisma/
│   └── schema.prisma
├── app.config.ts
├── package.json
└── tsconfig.json
```

## Route Folder Convention

TanStack Start에서 `-` 접두사는 라우트에서 제외됩니다:

```
routes/users/
├── index.tsx              # /users 페이지
├── route.tsx              # route 설정 (loader, beforeLoad 등)
├── -components/           # ❌ 라우트 아님, 컴포넌트 폴더
│   └── user-card.tsx
├── -sections/             # ❌ 라우트 아님, 섹션 폴더
│   └── user-list-section.tsx
└── -hooks/                # ❌ 라우트 아님, 훅 폴더
    └── use-users.ts
```

## Core Configuration

### app.config.ts

```typescript
import { defineConfig } from '@tanstack/react-start/config'

export default defineConfig({
  server: {
    preset: 'node-server',
  },
})
```

### Root Route

```tsx
// app/routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/router-devtools'

export const Route = createRootRoute({
  component: RootComponent,
})

const RootComponent = (): JSX.Element => {
  return (
    <>
      <div className="min-h-screen">
        <nav className="border-b p-4">
          <a href="/" className="font-bold">My App</a>
        </nav>
        <main className="container mx-auto p-4">
          <Outlet />
        </main>
      </div>
      <TanStackRouterDevtools />
    </>
  )
}
```

### Home Route

```tsx
// app/routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: HomePage,
})

const HomePage = (): JSX.Element => {
  return (
    <div>
      <h1 className="text-2xl font-bold">Welcome</h1>
    </div>
  )
}
```

## Services Setup

### Database Setup

```typescript
// app/database/prisma.ts
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

### Query Client

```typescript
// app/lib/query-client.ts
import { QueryClient } from '@tanstack/react-query'

export const createQueryClient = (): QueryClient => {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,
        retry: 1,
      },
    },
  })
}
```

### User Service (도메인 폴더 구조)

```typescript
// app/services/user/schemas.ts
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

```typescript
// app/services/user/queries.ts
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
```

```typescript
// app/services/user/mutations.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'
import { createUserSchema, updateUserSchema } from './schemas'

export const createUser = createServerFn({ method: 'POST' })
  .validator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })

export const updateUser = createServerFn({ method: 'POST' })
  .validator(updateUserSchema)
  .handler(async ({ data }) => {
    const { id, ...updateData } = data
    return prisma.user.update({ where: { id }, data: updateData })
  })

export const deleteUser = createServerFn({ method: 'POST' })
  .handler(async ({ data: id }: { data: string }) => {
    return prisma.user.delete({ where: { id } })
  })
```

```typescript
// app/services/user/index.ts
export * from './schemas'
export * from './queries'
export * from './mutations'
```

## Development Commands

| Command | Description |
|---------|-------------|
| `yarn dev` | Start development server |
| `yarn build` | Build for production |
| `yarn start` | Start production server |
| `yarn test` | Run tests |
| `yarn lint` | Check code quality |

## Next Steps

- [Best Practices](./best-practices.md) - 개발 모범 사례
- [Project Templates](./project-templates.md) - 프로젝트 템플릿
