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
| **레이어** | Service Layer 건너뛰기, Routes에서 직접 DB 접근 |
| **검증** | Handler 내부 수동 검증, 인증 로직 분산 |
| **Barrel Export** | `functions/index.ts` 생성 (Tree Shaking 실패, 서버 라이브러리 Client 오염) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **라우트 구조** | 페이지마다 폴더 생성 (`routes/users/index.tsx`) |
| **Route Export** | `export const Route = createFileRoute(...)` 필수 |
| **계층 구조** | Routes → Server Functions → Services → Database |
| **Route Group** | 목록 → `(main)/`, 생성/편집 → 외부 |
| **페이지 분리** | 100줄+ → `-components`, 200줄+ → `-sections` |
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
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TanStack Start Server                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Server Functions                         │ │
│  │   routes/-functions/ → 페이지 전용 | functions/ → 글로벌   │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Services Layer                           │ │
│  │   Zod Validation | Business Logic | Data Transformation    │ │
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

<route_export_rule>

## Route Export 규칙

> ⚠️ **`export const Route` 필수**
>
> TanStack Router는 모든 라우트 파일에서 **정확히 `Route`라는 이름**으로 내보내야 합니다.
>
> `tsr generate` 및 `tsr watch` 명령어가 자동으로 경로를 생성하고 업데이트합니다.

| ❌ 금지 | ✅ 필수 |
|--------|--------|
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `export const IndexRoute = ...` | `export const Route = ...` |
| `export default createFileRoute(...)` | `export const Route = createFileRoute(...)` |

```typescript
// ❌ 금지: export 없음
const Route = createFileRoute('/users')({
  component: UsersPage,
})

// ❌ 금지: 다른 이름
export const UsersRoute = createFileRoute('/users')({
  component: UsersPage,
})

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
> 모든 페이지는 **반드시 폴더 구조**로 만들어야 합니다. Flat 파일 방식(`routes/users.tsx`)은 금지됩니다.
>
> **이유:** -components/, -functions/, -hooks/ 등 페이지 전용 리소스를 체계적으로 관리하기 위함입니다.
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
│   ├── -sections/         # UI 섹션 분리 (200줄+ 페이지)
│   ├── -tabs/             # 탭 콘텐츠 분리
│   ├── -hooks/            # 페이지 전용 훅
│   └── -utils/            # 상수, 헬퍼
├── new/                   # 생성 페이지 (route group 외부)
│   └── index.tsx
├── route.tsx              # route 설정 (loader, beforeLoad)
└── -functions/            # 페이지 전용 서버 함수
```

| 패턴 | 위치 | 용도 |
|------|------|------|
| **Route Group** | `(main)/` | 목록 페이지, URL에 미포함 |
| **-components/** | 100-200줄 | 페이지 전용 컴포넌트 분리 |
| **-sections/** | 200줄+ | 논리적 섹션 분리 |
| **-tabs/** | 탭 UI | 탭 콘텐츠 분리 |
| **route.tsx** | 레이아웃 | 하위 경로 공통 레이아웃 |

#### Layout Routes 패턴

> ⚠️ **route.tsx로 레이아웃 구성**
>
> `route.tsx`는 하위 경로의 공통 레이아웃 역할을 합니다.
> `index.tsx`는 Route Group `()`으로 묶어야 합니다.
>
> **필수:** `route.tsx`는 반드시 `component`를 export해야 합니다.
>
> | ❌ 금지 | ✅ 필수 |
> |--------|--------|
> | `export const Route = createFileRoute(...)({})` | `export const Route = createFileRoute(...)({ component: ... })` |

```
routes/
├── (auth)/
│   ├── route.tsx           # 레이아웃 (<Outlet />)
│   ├── (main)/
│   │   └── index.tsx       # /auth (목록/메인)
│   ├── login/
│   │   └── index.tsx       # /auth/login
│   └── register/
│       └── index.tsx       # /auth/register
```

```typescript
// ❌ 금지: component 없음
export const Route = createFileRoute('/(auth)')({
  beforeLoad: async () => ({ user: await getUser() }),
})

// ✅ 필수: component 반드시 포함
// routes/(auth)/route.tsx - 레이아웃
export const Route = createFileRoute('/(auth)')({
  component: () => (
    <div className="auth-container">
      <Outlet />
    </div>
  ),
})

// routes/(auth)/(main)/index.tsx - 메인 페이지
export const Route = createFileRoute('/(auth)/')({
  component: AuthMainPage,
})

// routes/(auth)/login/index.tsx
export const Route = createFileRoute('/(auth)/login')({
  component: LoginPage,
})
```

### 2. Services Layer

```
services/<domain>/
├── index.ts            # 진입점 (re-export)
├── schemas.ts          # Zod 스키마
├── queries.ts          # GET 요청
└── mutations.ts        # POST/PUT/PATCH
```

### 3. Server Functions Layer

```
functions/                    # 글로벌 (재사용)
├── <function-name>.ts        # 파일당 하나
└── middlewares/
    └── <middleware-name>.ts

routes/<route>/-functions/    # 페이지 전용
└── <function-name>.ts
```

> ⚠️ **`functions/index.ts` 생성 금지**
>
> `functions/` 폴더에 `index.ts` (barrel export) 파일을 만들지 마세요.
>
> **문제점:**
> 1. **Tree Shaking 실패** - 번들러가 사용하지 않는 함수도 포함
> 2. **Client 번들 오염** - `pg`, `prisma` 등 서버 전용 라이브러리가 클라이언트에 import되어 빌드 에러 발생
>
> ```typescript
> // ❌ functions/index.ts 만들지 말 것
> export * from './get-users'
> export * from './create-post'  // pg import → 클라이언트 빌드 실패
>
> // ✅ 개별 파일에서 직접 import
> import { getUsers } from '@/functions/get-users'
> import { createPost } from '@/functions/create-post'
> ```

### 4. Database Layer

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
| **블로킹** | 모든 loader 차단 | 다른 loader와 병렬 |
| **성능 영향** | ⚠️ 높음 | ✅ 낮음 |

```
1. Parent beforeLoad (순차) ──┐
2. Child beforeLoad (순차)  ──┼→ 완료 후
3. All loaders (병렬) ────────┘
```

### 코드 패턴

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

| ❌ 금지 | ✅ 권장 |
|--------|--------|
| beforeLoad에서 데이터 로딩 | loader에서 데이터 로딩 |
| loader 차단 | 병렬 실행 |

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

// 2. 확장: Context 확장
beforeLoad: async ({ context }) => ({
  ...context,
  permissions: await getPermissions(context.user.id),
})

// 3. 사용: Component
const { user, permissions } = useRouteContext({ from: '/dashboard' })

// 4. 사용: Loader
loader: async ({ context }) => {
  if (!context.permissions.includes('users:read')) {
    throw new Error('Unauthorized')
  }
  return { users: await getUsers() }
}
```

</context_management>

---

<data_flow>

## Data Flow

### Query Flow (읽기)

```
Page → useQuery → Server Function → Prisma → Database
          ↑
    TanStack Query (Cache)
```

```typescript
// Page
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: getUsers,
})

// Server Function
export const getUsers = createServerFn()
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())
```

### Mutation Flow (쓰기)

```
Form → useMutation → Server Function
                          ↓
                    inputValidator
                          ↓
                    Prisma → Database
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

| 타입 | 실행 위치 | 사용 시나리오 |
|------|----------|-------------|
| **createServerFn** | 서버 | DB 접근, 비밀키, 서버 로직 (기본) |
| createClientOnlyFn | 클라이언트 | localStorage, window |
| createIsomorphicFn | 양쪽 | 환경별 구현 |

**기본 규칙**: 별도 요청 없으면 `createServerFn` 사용

### Middleware 패턴

```typescript
// 1. authMiddleware
export const authMiddleware = createMiddleware()
  .server(async ({ next, context }) => {
    const session = await getSession()
    if (!session?.user) throw new Error('Unauthorized')
    return next({ context: { ...context, user: session.user } })
  })

// 2. 사용
export const createPost = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
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

// Loader 에러
loader: async () => {
  try {
    return { users: await getUsers() }
  } catch (error) {
    throw new Error('데이터 로딩 실패')
  }
}

// Server Function 에러
.handler(async ({ data }) => {
  try {
    return await prisma.user.create({ data })
  } catch (error) {
    if (error.code === 'P2002') {
      throw new Error('이미 존재하는 이메일')
    }
    throw new Error('사용자 생성 실패')
  }
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
| ORM | Prisma | 7.x |
| Validation | Zod | 4.x |
| Database | PostgreSQL | - |
| UI | React 18+ | - |

</tech_stack>
