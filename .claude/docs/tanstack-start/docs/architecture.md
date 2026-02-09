# Architecture

> TanStack Start 애플리케이션 아키텍처

<instructions>
@../guides/conventions.md
@../guides/routes.md
@../guides/services.md
@../guides/hooks.md
</instructions>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **라우트** | Flat 파일 라우트 (`routes/users.tsx`) |
| **Route Export** | `export const IndexRoute`, `const Route` (export 안함) |
| **API** | `/api` 라우터 생성 (Server Functions 사용) |
| **레이어** | Features 건너뛰기, Routes에서 직접 DB 접근 |
| **검증** | Handler 내부 수동 검증, 인증 로직 분산 |
| **Barrel Export** | `functions/index.ts` 생성 (Tree Shaking 실패) |
| **폴더 구조** | `lib/db`, `lib/store` (→ `database/`, `stores/` 사용) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **라우트 구조** | 페이지마다 폴더 생성 (`routes/users/index.tsx`) |
| **Route Export** | `export const Route = createFileRoute(...)` 필수 |
| **계층 구조** | Routes → Server Functions → Features → Database |
| **Route Group** | 목록 → `(main)/`, 생성/편집 → 외부 |
| **페이지 분리** | 100줄+ → `-components`, 200줄+ → `-sections` |
| **컴포넌트 분리** | 로직 있는 컴포넌트 → `-components/-hooks/`로 훅 분리 |
| **beforeLoad** | 인증 체크, Context 전달, 리다이렉트 |
| **loader** | 데이터 로딩 (beforeLoad 완료 후 병렬 실행) |
| **Server Fn** | `createServerFn` 기본 사용 |
| **검증** | `inputValidator` (POST/PUT/PATCH), Zod 스키마 |
| **인증** | `middleware` (authMiddleware) |
| **에러 처리** | `errorComponent` (라우트), `notFoundComponent` (404) |
| **타입 안전** | TypeScript strict, Prisma 타입 |

</required>

---

<system_overview>

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser)                         │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  React Router  │───▶│ TanStack Query │───▶│    React UI   │  │
│  │  (Navigation)  │◀───│   (Caching)    │◀───│  (Components) │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
│  ┌─────────────────────────────┴─────────────────────────────┐  │
│  │              State: TanStack Query + Zustand               │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TanStack Start Server                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Security: CSP | Rate Limit | CORS              │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Server Functions                         │ │
│  │      routes/-functions/ (페이지) | functions/ (글로벌)      │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │     Features (내부 도메인)  |  Services (외부 SDK)          │ │
│  │     Prisma 쿼리, 스키마     |  Stripe, S3, SendGrid        │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │         Caching: Redis (분산) | Query (로컬) | CDN          │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │         Monitoring: Sentry (에러) | OpenTelemetry           │ │
│  └────────────────────────────┬───────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │    Redis      │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

</system_overview>

---

<folder_structure>

## Folder Structure

```
src/
├── routes/           # 라우팅 (파일 기반)
├── components/       # UI 컴포넌트
│   ├── ui/          # shadcn/ui
│   ├── layout/      # Header, Sidebar, Footer
│   └── shared/      # 공용 컴포넌트
├── features/         # 내부 도메인 (DB 레이어)
│   └── <domain>/
│       ├── schemas.ts
│       ├── queries.ts
│       └── mutations.ts
├── services/         # 외부 SDK 연동
│   ├── stripe/
│   ├── sendgrid/
│   ├── s3/
│   └── openai/
├── functions/        # 글로벌 Server Functions
│   └── middlewares/
├── database/         # Prisma Client
├── stores/           # Zustand 스토어
├── hooks/            # 글로벌 훅
├── types/            # 전역 타입
├── env/              # 환경 변수 검증 (t3-env)
├── styles/           # CSS
├── config/           # 설정
│   ├── auth.ts
│   ├── query-client.ts
│   └── sentry.ts
└── lib/              # 유틸리티
    ├── utils/
    ├── constants/
    └── validators/
```

### 폴더 역할

| 폴더 | 역할 | 예시 |
|------|------|------|
| **features/** | 내부 도메인, Prisma 쿼리 | users, projects, billing |
| **services/** | 외부 SDK 래퍼 | Stripe, SendGrid, S3, OpenAI |
| **functions/** | Server Functions | API 레이어 |
| **database/** | Prisma Client | 싱글톤 인스턴스 |
| **stores/** | Zustand 스토어 | 클라이언트 전역 상태 |
| **config/** | 설정 파일 | auth, query-client, sentry |
| **lib/** | 유틸리티 | utils, constants, validators |

</folder_structure>

---

<route_export_rule>

## Route Export 규칙

> ⚠️ **`export const Route` 필수**
>
> TanStack Router는 모든 라우트 파일에서 **정확히 `Route`라는 이름**으로 내보내야 합니다.

| ❌ 금지 | ✅ 필수 |
|--------|--------|
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `export const IndexRoute = ...` | `export const Route = ...` |
| `export default createFileRoute(...)` | `export const Route = createFileRoute(...)` |

```typescript
// ✅ 필수: 정확히 'Route' 이름으로 export
export const Route = createFileRoute('/users')({
  component: UsersPage,
})
```

</route_export_rule>

---

<layers>

## Layer Architecture

### 1. Routes Layer

> ⚠️ **페이지마다 폴더 생성 필수**
>
> | ❌ 금지 | ✅ 필수 |
> |--------|--------|
> | `routes/users.tsx` | `routes/users/index.tsx` |
> | `routes/posts.tsx` | `routes/posts/(main)/index.tsx` |

```
routes/<route-name>/
├── (main)/                # route group (목록 페이지)
│   ├── index.tsx          # 페이지 컴포넌트
│   ├── -components/       # 페이지 전용 컴포넌트
│   ├── -sections/         # UI 섹션 분리 (200줄+)
│   ├── -hooks/            # 페이지 전용 훅
│   └── -utils/            # 상수, 헬퍼
├── new/                   # 생성 페이지
│   └── index.tsx
├── route.tsx              # 레이아웃 (loader, beforeLoad)
└── -functions/            # 페이지 전용 서버 함수
```

| 패턴 | 용도 |
|------|------|
| **Route Group `()`** | URL 미포함, 레이아웃 공유 |
| **-components/** | 페이지 전용 컴포넌트 (100줄+) |
| **-sections/** | 논리적 섹션 분리 (200줄+) |
| **route.tsx** | 하위 경로 공통 레이아웃 |

#### Component + Hook 분리

> 컴포넌트에 로직(서버 연동, 상태 관리)이 있으면 폴더로 묶고 훅 분리

```
-components/
├── user-card/
│   ├── index.tsx              # UI만
│   └── -hooks/
│       └── use-user-card.ts   # 서버 연동, 상태 로직
└── user-form/
    ├── index.tsx              # UI만
    └── -hooks/
        └── use-user-form.ts   # 폼 로직, mutation
```

```typescript
// -components/user-form/-hooks/use-user-form.ts
export function useUserForm(userId?: string) {
  const queryClient = useQueryClient()

  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser(userId!),
    enabled: !!userId,
  })

  const mutation = useMutation({
    mutationFn: userId ? updateUser : createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  return { user, mutation, isLoading: mutation.isPending }
}

// -components/user-form/index.tsx
export function UserForm({ userId }: Props) {
  const { user, mutation, isLoading } = useUserForm(userId)

  return (
    <form onSubmit={(e) => mutation.mutate(formData)}>
      {/* UI만 */}
    </form>
  )
}
```

| 분리 기준 | 컴포넌트 (`index.tsx`) | 훅 (`-hooks/`) |
|----------|----------------------|----------------|
| **역할** | UI 렌더링 | 로직 처리 |
| **내용** | JSX, 스타일 | useQuery, useMutation, 상태 |

### 2. Features Layer

> 내부 도메인 로직, Prisma 쿼리

```
features/<domain>/
├── schemas.ts          # Zod 스키마
├── queries.ts          # TanStack Query 옵션
└── mutations.ts        # useMutation 옵션
```

```typescript
// features/users/schemas.ts
export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

// features/users/queries.ts
export const userQueryOptions = queryOptions({
  queryKey: ['users'],
  queryFn: getUsers,
  staleTime: 5 * 60 * 1000,
})
```

### 3. Services Layer

> 외부 SDK 연동

```
services/<provider>/
├── client.ts           # SDK 클라이언트
├── types.ts            # 타입 정의
└── utils.ts            # 헬퍼 함수
```

```typescript
// services/stripe/client.ts
import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

// services/stripe/utils.ts
export async function createCheckoutSession(priceId: string) {
  return stripe.checkout.sessions.create({
    mode: 'subscription',
    line_items: [{ price: priceId, quantity: 1 }],
  })
}
```

### 4. Server Functions Layer

```
functions/                    # 글로벌
├── <function-name>.ts
└── middlewares/
    ├── auth.ts
    └── logging.ts

routes/<route>/-functions/    # 페이지 전용
└── <function-name>.ts
```

> ⚠️ **`functions/index.ts` 생성 금지** - Tree Shaking 실패, Client 번들 오염

```typescript
// ✅ 개별 파일에서 직접 import
import { getUsers } from '@/functions/get-users'
import { createPost } from '@/functions/create-post'
```

### 5. State Management Layer

| 상태 유형 | 도구 | 사용 |
|----------|------|------|
| **서버 상태** | TanStack Query | API 데이터, 캐싱 (80%) |
| **클라이언트 상태** | Zustand | UI 상태, 설정 (20%) |

```typescript
// stores/app.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export const useAppStore = create(
  persist(
    (set) => ({
      theme: 'dark' as 'light' | 'dark',
      sidebarOpen: true,
      setTheme: (theme) => set({ theme }),
    }),
    { name: 'app-store' }
  )
)
```

### 6. Database Layer

```typescript
// database/prisma.ts
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

</layers>

---

<route_lifecycle>

## Route Lifecycle

### beforeLoad vs loader

| 항목 | beforeLoad | loader |
|------|-----------|--------|
| **실행 순서** | 순차 (outermost → innermost) | 병렬 (beforeLoad 완료 후) |
| **용도** | 인증, Context 전달, 리다이렉트 | 데이터 로딩 |
| **성능 영향** | ⚠️ 높음 (블로킹) | ✅ 낮음 (병렬) |

```typescript
// ✅ beforeLoad: 인증 & Context
beforeLoad: async () => {
  const user = await getUser()
  if (!user) throw redirect({ to: '/login' })
  return { user }
}

// ✅ loader: 데이터 로딩
loader: async () => {
  const [users, roles] = await Promise.all([
    getUsers(),
    getRoles(),
  ])
  return { users, roles }
}
```

</route_lifecycle>

---

<context_management>

## Context Management

| 단계 | 파일 | 작업 |
|------|------|------|
| **생성** | `__root.tsx` | `createRootRouteWithContext` |
| **확장** | `route.tsx` | `beforeLoad` Context 확장 |
| **사용** | `component` | `useRouteContext()` |

```typescript
// 1. Root: Context 정의
interface RouterContext {
  user: User | null
}

export const Route = createRootRouteWithContext<RouterContext>()({
  beforeLoad: async () => ({ user: await getUser() }),
})

// 2. 확장
beforeLoad: async ({ context }) => ({
  ...context,
  permissions: await getPermissions(context.user.id),
})

// 3. 사용
const { user, permissions } = useRouteContext({ from: '/dashboard' })
```

</context_management>

---

<data_flow>

## Data Flow

### Query Flow (읽기)

```
Page → useQuery → Server Function → Features → Prisma → Database
          ↑
    TanStack Query (Cache)
```

```typescript
// Page
const { data } = useQuery(userQueryOptions)

// Server Function
export const getUsers = createServerFn()
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())
```

### Mutation Flow (쓰기)

```
Form → useMutation → Server Function → inputValidator → Features → Database
                                                             ↓
                                                    invalidateQueries
```

```typescript
// Page
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
  },
})

// Server Function
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

</data_flow>

---

<server_functions_advanced>

## Server Functions (Advanced)

### Server Functions 타입

| 타입 | 실행 위치 | 사용 |
|------|----------|------|
| **createServerFn** | 서버 | DB 접근, 비밀키 (기본) |
| createClientOnlyFn | 클라이언트 | localStorage, window |
| createIsomorphicFn | 양쪽 | 환경별 구현 |

### Middleware 패턴

```typescript
// functions/middlewares/auth.ts
export const authMiddleware = createMiddleware()
  .server(async ({ next, context }) => {
    const session = await getSession()
    if (!session?.user) throw new Error('Unauthorized')
    return next({ context: { ...context, user: session.user } })
  })

// functions/middlewares/logging.ts
export const loggingMiddleware = createMiddleware()
  .server(async ({ next }) => {
    const start = Date.now()
    const traceId = crypto.randomUUID()
    const result = await next({ context: { traceId } })
    console.log({ traceId, duration: Date.now() - start })
    return result
  })

// 사용
export const createPost = createServerFn({ method: 'POST' })
  .middleware([loggingMiddleware, authMiddleware])
  .inputValidator(createPostSchema)
  .handler(async ({ data, context }) => {
    return prisma.post.create({
      data: { ...data, authorId: context.user.id },
    })
  })
```

**실행 순서**: Middleware → inputValidator → handler

</server_functions_advanced>

---

<error_handling>

## Error Handling

| 컴포넌트 | 처리 범위 | 위치 | 필수 |
|---------|----------|------|-----|
| **errorComponent** | 라우트 에러 | 각 route | ✅ |
| **notFoundComponent** | 404 | __root.tsx | ✅ |
| **pendingComponent** | 로딩 | 각 route | 선택 |

```typescript
// __root.tsx
export const Route = createRootRoute({
  errorComponent: ({ error }) => <div>{error.message}</div>,
  notFoundComponent: () => <div>404 Not Found</div>,
})

// Route 레벨
export const Route = createFileRoute('/dashboard')({
  errorComponent: ({ error }) => <div>{error.message}</div>,
})
```

</error_handling>

---

<tech_stack>

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | TanStack Start | latest |
| Router | TanStack Router | latest |
| Data | TanStack Query | latest |
| State | Zustand | latest |
| ORM | Prisma | 7.x |
| Validation | Zod | 4.x |
| Database | PostgreSQL | - |
| Cache | Redis | - |
| Monitoring | Sentry | latest |
| UI | React 19+ | - |

</tech_stack>
