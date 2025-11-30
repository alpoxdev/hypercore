# Architecture

TanStack Start 애플리케이션의 기술 아키텍처 가이드입니다.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser)                         │
│                                                                  │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  React Router  │───▶│ TanStack Query │───▶│    React UI   │  │
│  │  (Navigation)  │◀───│   (Caching)    │◀───│  (Components) │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
│                                │                                 │
└────────────────────────────────┼─────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TanStack Start Server                         │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Server Functions                         │ │
│  │   - createServerFn({ method: 'GET' })  → Queries           │ │
│  │   - createServerFn({ method: 'POST' }) → Mutations         │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│                               │                                  │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Services Layer                           │ │
│  │   - Zod Validation                                          │ │
│  │   - Business Logic                                          │ │
│  │   - Data Transformation                                     │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│                               │                                  │
└───────────────────────────────┼──────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│                                                                  │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │    Redis      │  │
│  │   (ORM)        │    │   (Primary)    │    │   (Cache)     │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
my-app/
├── src/
│   ├── routes/                     # 파일 기반 라우팅
│   │   ├── __root.tsx              # Root layout
│   │   ├── index.tsx               # Home (/)
│   │   └── users/
│   │       ├── index.tsx           # /users
│   │       ├── $id.tsx             # /users/:id
│   │       ├── route.tsx           # route 설정 (선택)
│   │       ├── -components/        # 페이지 전용 컴포넌트
│   │       │   └── user-card.tsx
│   │       ├── -sections/          # 섹션 분리
│   │       │   ├── user-list-section.tsx
│   │       │   └── user-filter-section.tsx
│   │       └── -hooks/             # 페이지 전용 훅
│   │           └── use-users.ts
│   ├── components/                 # 공통 컴포넌트
│   │   └── ui/
│   │       ├── button.tsx
│   │       ├── input.tsx
│   │       └── modal.tsx
│   ├── database/                   # 데이터베이스 관련
│   │   ├── prisma.ts               # Prisma Client 싱글톤
│   │   └── seed.ts                 # 시드 데이터 (선택)
│   ├── services/                   # 도메인별 서비스 레이어
│   │   ├── user/
│   │   │   ├── index.ts            # 진입점 (re-export)
│   │   │   ├── schemas.ts          # Zod 스키마
│   │   │   ├── queries.ts          # GET 요청
│   │   │   └── mutations.ts        # POST 요청
│   │   ├── auth/
│   │   │   ├── index.ts
│   │   │   ├── schemas.ts
│   │   │   ├── queries.ts
│   │   │   └── mutations.ts
│   │   └── post/
│   │       ├── index.ts
│   │       ├── schemas.ts
│   │       ├── queries.ts
│   │       └── mutations.ts
│   ├── lib/                        # 공통 유틸리티
│   │   ├── query-client.ts
│   │   └── utils.ts
│   ├── hooks/                      # 공통 훅
│   │   └── use-auth.ts
│   ├── types/                      # 타입 정의
│   │   └── index.ts
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

## Layer Architecture

### 1. Routes Layer (Presentation)

파일 기반 라우팅으로 페이지를 구성합니다.

```
routes/<route-name>/
├── index.tsx              # 페이지 컴포넌트
├── route.tsx              # route 설정 (loader, beforeLoad)
├── -components/           # 페이지 전용 컴포넌트
├── -sections/             # 섹션 분리 (복잡한 경우)
└── -hooks/                # 페이지 전용 훅
```

**특징**:
- `-` 접두사 폴더는 라우트에서 제외
- 페이지별로 컴포넌트, 섹션, 훅을 분리
- Section은 UI 영역 단위, Component는 재사용 단위

```tsx
// routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { UserListSection } from './-sections/user-list-section'
import { UserFilterSection } from './-sections/user-filter-section'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})

const UsersPage = (): JSX.Element => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <UserFilterSection />
      <UserListSection />
    </div>
  )
}
```

### 2. Services Layer (Business Logic)

도메인별로 서비스를 구성합니다.

```
services/<domain>/
├── index.ts            # 진입점 (re-export)
├── schemas.ts          # Zod 스키마
├── queries.ts          # GET 요청 (읽기)
└── mutations.ts        # POST 요청 (쓰기)
```

**Schemas** - 입력 검증:

```typescript
// services/user/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
```

**Queries** - 읽기 작업:

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
```

**Mutations** - 쓰기 작업:

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

### 3. Database Layer (Data Access)

Prisma를 통한 데이터 액세스를 담당합니다.

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

## Data Flow

### Query Flow (읽기)

```
1. User navigates to page
   │
2. Page Hook calls useQuery
   │
   ▼
┌─────────────────┐
│  TanStack Query │ ◀── Cache check
└────────┬────────┘
         │ Cache miss
         ▼
┌─────────────────┐
│  Server Function│ ← getUsers()
│  (method: GET)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Prisma Query   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Database     │
└─────────────────┘
```

### Mutation Flow (쓰기)

```
1. User submits form
   │
2. Page Hook calls useMutation
   │
   ▼
┌─────────────────┐
│  useMutation    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Server Function│ ← createUser()
│  (method: POST) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Zod Validation │ ← Schema check
└────────┬────────┘
         │ Valid
         ▼
┌─────────────────┐
│  Prisma Mutation│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Database     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Cache Invalidate│ ← invalidateQueries
└─────────────────┘
```

## Component Patterns

### Page Hook Pattern

```typescript
// routes/users/-hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/services/user'

export const useUsers = () => {
  const queryClient = useQueryClient()

  const { data: users, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  return {
    users,
    isLoading,
    error,
    createUser: createMutation.mutate,
    isCreating: createMutation.isPending,
  }
}
```

### Section Pattern

```tsx
// routes/users/-sections/user-list-section.tsx
import { useUsers } from '../-hooks/use-users'
import { UserCard } from '../-components/user-card'

export const UserListSection = (): JSX.Element => {
  const { users, isLoading, error } = useUsers()

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {users?.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  )
}
```

## Technology Stack

### Core Framework

| Technology | Purpose | Version |
|------------|---------|---------|
| TanStack Start | Full-stack Framework | latest |
| TanStack Router | File-based Routing | latest |
| TanStack Query | Data Fetching & Caching | latest |
| React | UI Library | 18+ |

### Backend

| Technology | Purpose | Version |
|------------|---------|---------|
| Prisma | ORM | 7.x |
| Zod | Validation | 4.x |
| Nitro | Server Runtime | latest |

### Database

| Technology | Purpose |
|------------|---------|
| PostgreSQL | Primary Database |
| Redis | Caching (선택) |

## TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*", "*.config.ts"]
}
```

## Deployment Architecture

### Vercel

```
┌─────────────────────────────────────┐
│           Vercel Platform           │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │   Edge      │  │  Serverless │  │
│  │  Functions  │  │  Functions  │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
            ┌───────────────┐
            │   Database    │
            │  (Neon/Supabase) │
            └───────────────┘
```

### Railway / Cloudflare

```
┌─────────────────────────────────────┐
│         Platform (Railway/CF)       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │     Node.js / Workers       │   │
│  │     (Full-stack Server)     │   │
│  └─────────────────────────────┘   │
│                                     │
└───────────────────┬─────────────────┘
                    │
                    ▼
            ┌───────────────┐
            │   Database    │
            │  (PostgreSQL) │
            └───────────────┘
```

## Documentation Structure

```
docs/
├── guides/                     # 개발 가이드
│   ├── getting-started.md      # 시작 가이드
│   ├── best-practices.md       # 모범 사례
│   └── project-templates.md    # 템플릿
├── library/                    # 라이브러리 레퍼런스
│   ├── tanstack-start/         # TanStack Start
│   ├── tanstack-query/         # TanStack Query
│   ├── prisma/                 # Prisma
│   ├── zod/                    # Zod
│   └── better-auth/            # Better Auth
├── deployment/                 # 배포 가이드
│   ├── nitro.md                # Nitro 설정
│   ├── vercel.md               # Vercel 배포
│   ├── cloudflare.md           # Cloudflare 배포
│   └── railway.md              # Railway 배포
└── architecture/               # 아키텍처
    └── architecture.md         # 시스템 아키텍처
```

## Security Considerations

### Input Validation

모든 서버 함수에서 Zod를 통한 입력 검증:

```typescript
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)  // 자동 검증
  .handler(async ({ data }) => {
    // data는 이미 검증됨
  })
```

### Environment Variables

```typescript
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.url(),
  API_SECRET: z.string().min(32),
})

export const env = envSchema.parse(process.env)
```

### Authentication

Better Auth를 통한 인증 관리:

```typescript
// services/auth/index.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: { enabled: true },
})
```

## Performance Considerations

### Caching Strategy

```typescript
// TanStack Query 캐싱
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
  staleTime: 60 * 1000,      // 1분간 fresh
  gcTime: 5 * 60 * 1000,     // 5분간 캐시 유지
})
```

### Database Optimization

```typescript
// Prisma 쿼리 최적화
const users = await prisma.user.findMany({
  select: {                    // 필요한 필드만 선택
    id: true,
    name: true,
    email: true,
  },
  take: 20,                    // 페이지네이션
  skip: (page - 1) * 20,
})
```

## Related Documentation

- [Getting Started](../guides/getting-started.md) - 프로젝트 시작 가이드
- [Best Practices](../guides/best-practices.md) - 개발 모범 사례
- [Project Templates](../guides/project-templates.md) - 프로젝트 템플릿
- [Deployment](../deployment/index.md) - 배포 가이드
