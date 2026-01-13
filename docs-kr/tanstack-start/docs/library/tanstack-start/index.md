# TanStack Start

> v1 | Full-stack React Framework

---

<context>

**Purpose:** TanStack Start를 사용한 Full-stack React 애플리케이션 개발 가이드

**Scope:**
- Server Functions (타입 안전 API)
- File-based Routing (TanStack Router)
- Middleware 체계
- SSR + Streaming
- TanStack Query 통합

**Key Features:**
- Type-safe Server Functions
- Zero-config file-based routing
- Built-in middleware system
- First-class SSR support
- Seamless TanStack Query integration
- Multiple deployment targets (Vercel, Cloudflare, Nitro)

**Version:** v1.x

</context>

---

<forbidden>

| 분류 | ❌ 금지 | 이유 |
|------|---------|------|
| **API 라우터** | `/api` 경로에 라우터 생성 | Server Functions 사용 |
| **수동 검증** | handler 내부에서 Zod 수동 검증 | `.inputValidator()` 사용 |
| **수동 인증** | handler 내부에서 세션 체크 | `.middleware()` 사용 |
| **deprecated API** | `.validator()` 메서드 | `.inputValidator()` 사용 (v1) |
| **직접 호출** | 컴포넌트에서 Server Function 직접 호출 | TanStack Query 사용 필수 |
| **환경변수 노출** | loader에서 `process.env` 직접 사용 | Server Function에서만 |
| **헬퍼 export** | 내부 헬퍼 함수 export | Server Function만 export |
| **any 타입** | Server Function 파라미터에 any | 명시적 타입/Zod 스키마 |
| **일반 함수** | 일반 async 함수를 API로 사용 | `createServerFn()` 사용 |

</forbidden>

---

<required>

| 분류 | ✅ 필수 | 상세 |
|------|---------|------|
| **POST/PUT/PATCH** | `.inputValidator()` 사용 | Zod 스키마로 검증 |
| **인증 필요** | `.middleware()` 사용 | authMiddleware 적용 |
| **클라이언트 호출** | TanStack Query 사용 | useQuery/useMutation |
| **Server Function** | `createServerFn()` 사용 | method 명시 (GET/POST/etc) |
| **타입 안전성** | 명시적 return type | TypeScript strict 모드 |
| **파일 구조** | `-functions/` 폴더 사용 | 페이지 전용 함수 분리 |
| **공통 함수** | `@/functions/` 사용 | 재사용 가능한 함수 |
| **환경변수** | Server Function 내부에서만 | 클라이언트 노출 방지 |

</required>

---

<setup>

## 설치

```bash
yarn add @tanstack/react-start @tanstack/react-router vinxi
yarn add -D vite @vitejs/plugin-react vite-tsconfig-paths
```

## 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import tsConfigPaths from 'vite-tsconfig-paths'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  server: { port: 3000 },
  plugins: [tsConfigPaths(), tanstackStart(), viteReact()],
})
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "react-jsx",
    "paths": { "@/*": ["./src/*"] }
  }
}
```

## 환경 변수 검증

```typescript
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  API_SECRET: z.string().min(32),
})

export const env = envSchema.parse(process.env)
```

</setup>

---

<server_functions>

## Server Functions

서버에서만 실행되는 타입 안전한 함수.

### 기본 패턴

| 메서드 | 사용 시점 | inputValidator | middleware |
|--------|----------|---------------|-----------|
| **GET** | 데이터 조회 | ❌ 선택 | ✅ 인증 시 필수 |
| **POST** | 데이터 생성 | ✅ 필수 | ✅ 인증 시 필수 |
| **PUT** | 전체 수정 | ✅ 필수 | ✅ 인증 시 필수 |
| **PATCH** | 부분 수정 | ✅ 필수 | ✅ 인증 시 필수 |
| **DELETE** | 삭제 | ❌ 선택 | ✅ 인증 시 필수 |

### GET: 데이터 조회

```typescript
// ✅ 기본 GET
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany()
  })

// ✅ GET + 인증
export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.user.findUnique({
      where: { id: context.user.id },
    })
  })

// ✅ GET + Query Params (선택적 검증)
export const getUserById = createServerFn({ method: 'GET' })
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }) => {
    return prisma.user.findUnique({
      where: { id: data.id },
    })
  })
```

### POST: 데이터 생성

```typescript
// ✅ POST + inputValidator 필수
const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
  age: z.number().int().min(0).optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    // data는 자동으로 검증됨
    return prisma.user.create({ data })
  })

// ✅ POST + inputValidator + 인증
export const createPost = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(z.object({
    title: z.string().min(1).max(200),
    content: z.string().min(1),
  }))
  .handler(async ({ data, context }) => {
    return prisma.post.create({
      data: {
        ...data,
        authorId: context.user.id,
      },
    })
  })

// ❌ inputValidator 없이 POST (금지)
export const badCreate = createServerFn({ method: 'POST' })
  .handler(async ({ data }) => {
    // data 타입 불안전, 검증 없음
    return prisma.user.create({ data })
  })
```

### PUT/PATCH: 데이터 수정

```typescript
// ✅ PUT (전체 수정) + inputValidator 필수
const updateUserSchema = z.object({
  id: z.string(),
  email: z.email(),
  name: z.string().min(1).max(100),
})

export const updateUser = createServerFn({ method: 'PUT' })
  .middleware([authMiddleware])
  .inputValidator(updateUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.update({
      where: { id: data.id },
      data: { email: data.email, name: data.name },
    })
  })

// ✅ PATCH (부분 수정) + inputValidator 필수
const patchUserSchema = z.object({
  id: z.string(),
  name: z.string().min(1).max(100).optional(),
  age: z.number().int().min(0).optional(),
})

export const patchUser = createServerFn({ method: 'PATCH' })
  .middleware([authMiddleware])
  .inputValidator(patchUserSchema)
  .handler(async ({ data }) => {
    const { id, ...updateData } = data
    return prisma.user.update({
      where: { id },
      data: updateData,
    })
  })
```

### DELETE: 데이터 삭제

```typescript
// ✅ DELETE + 인증
export const deletePost = createServerFn({ method: 'DELETE' })
  .middleware([authMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data, context }) => {
    // 권한 체크
    const post = await prisma.post.findUnique({
      where: { id: data.id },
    })

    if (post?.authorId !== context.user.id) {
      throw new Error('Unauthorized')
    }

    return prisma.post.delete({
      where: { id: data.id },
    })
  })
```

### 클라이언트에서 호출 (TanStack Query 필수)

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

// ✅ useQuery (조회)
const UsersPage = (): JSX.Element => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}

// ✅ useMutation (생성/수정/삭제)
const CreateUserForm = (): JSX.Element => {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      // 캐시 무효화 → 자동 리페치
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    mutation.mutate({
      email: formData.get('email') as string,
      name: formData.get('name') as string,
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" required />
      <input name="name" required />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating...' : 'Create'}
      </button>
      {mutation.error && <p>Error: {mutation.error.message}</p>}
    </form>
  )
}

// ❌ 직접 호출 금지 (캐싱 없음, 동기화 안됨)
const BadComponent = (): JSX.Element => {
  const [users, setUsers] = useState([])

  useEffect(() => {
    getUsers().then(setUsers) // ❌ 직접 호출
  }, [])

  return <div>{/* ... */}</div>
}
```

### 함수 분리 규칙

```typescript
// ❌ 잘못된 구조: 헬퍼 함수 export
export const validateUserData = async (email: string) => {
  const exists = await prisma.user.findUnique({ where: { email } })
  if (exists) throw new Error('Email already exists')
}

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    await validateUserData(data.email) // ❌ export된 헬퍼 사용
    return prisma.user.create({ data })
  })

// ✅ 올바른 구조: 헬퍼는 export 금지
const validateUserData = async (email: string) => {
  const exists = await prisma.user.findUnique({ where: { email } })
  if (exists) throw new Error('Email already exists')
}

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    await validateUserData(data.email) // ✅ 내부 헬퍼만 사용
    return prisma.user.create({ data })
  })

// index.ts: Server Function만 export
export { getUsers, createUser, updateUser } from './user-functions'
// ❌ export { validateUserData } 금지
```

### 보안: 환경 변수

```typescript
// ❌ loader에서 환경변수 직접 사용 (클라이언트 노출)
export const Route = createFileRoute('/config')({
  loader: () => {
    const secret = process.env.API_SECRET // ❌ 클라이언트에 노출됨!
    return { secret }
  },
  component: ConfigPage,
})

// ✅ Server Function에서만 사용
const getConfig = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => {
    const secret = process.env.API_SECRET // ✅ 서버에서만 실행
    return { secret }
  })

export const Route = createFileRoute('/config')({
  loader: async () => {
    const config = await getConfig()
    return config
  },
  component: ConfigPage,
})
```

</server_functions>

---

<middleware>

## Middleware

Server Function 및 라우트에 공통 로직 적용.

### 기본 패턴

```typescript
// 미들웨어 정의
const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(({ next }) => {
    console.log('Processing request')
    return next()
  })

// Server Function에 적용
const fn = createServerFn({ method: 'GET' })
  .middleware([loggingMiddleware])
  .handler(async () => ({ message: 'Hello' }))
```

### 인증 미들웨어

```typescript
// 세션 기반 인증
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session?.user) {
      throw redirect({ to: '/login' })
    }
    return next({ context: { user: session.user } })
  })

// Server Function에 적용
export const getMyPosts = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.post.findMany({
      where: { authorId: context.user.id },
    })
  })

// 권한 체크 미들웨어
const adminMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session?.user || session.user.role !== 'ADMIN') {
      throw new Error('Forbidden: Admin only')
    }
    return next({ context: { user: session.user } })
  })

// 적용
export const deleteAnyPost = createServerFn({ method: 'DELETE' })
  .middleware([adminMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }) => {
    return prisma.post.delete({ where: { id: data.id } })
  })
```

### Zod Validation Middleware

```typescript
// 재사용 가능한 검증 미들웨어
const workspaceMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(z.object({ workspaceId: z.string() }))
  .server(async ({ next, data }) => {
    const workspace = await prisma.workspace.findUnique({
      where: { id: data.workspaceId },
    })

    if (!workspace) {
      throw new Error('Workspace not found')
    }

    return next({ context: { workspace } })
  })

// 적용
export const getWorkspaceData = createServerFn({ method: 'GET' })
  .middleware([authMiddleware, workspaceMiddleware])
  .handler(async ({ context }) => {
    return {
      user: context.user,
      workspace: context.workspace,
    }
  })
```

### 미들웨어 체이닝

```typescript
// 여러 미들웨어 조합
export const protectedWorkspaceFn = createServerFn({ method: 'POST' })
  .middleware([
    loggingMiddleware,      // 1. 로깅
    authMiddleware,          // 2. 인증
    workspaceMiddleware,     // 3. Workspace 검증
  ])
  .inputValidator(taskSchema)
  .handler(async ({ data, context }) => {
    return prisma.task.create({
      data: {
        ...data,
        workspaceId: context.workspace.id,
        createdById: context.user.id,
      },
    })
  })
```

### Global Middleware

```typescript
// src/start.ts
export const startInstance = createStart(() => ({
  requestMiddleware: [corsMiddleware],     // 모든 요청
  functionMiddleware: [loggingMiddleware], // 모든 Server Function
}))
```

### Route-Level Middleware

```typescript
// 특정 라우트에만 적용
export const Route = createFileRoute('/admin/dashboard')({
  server: {
    middleware: [adminMiddleware], // 이 라우트의 모든 핸들러에 적용
    handlers: {
      GET: async () => new Response('Admin Dashboard'),
    },
  },
})
```

</middleware>

---

<routing>

## Routing

File-based routing with TanStack Router.

### 파일 구조 → URL 매핑

| 파일 경로 | URL | 설명 |
|----------|-----|------|
| `routes/index.tsx` | `/` | 홈 페이지 |
| `routes/about.tsx` | `/about` | 정적 라우트 |
| `routes/users/$id.tsx` | `/users/:id` | 동적 파라미터 |
| `routes/users/index.tsx` | `/users` | 사용자 목록 |
| `routes/$.tsx` | `/*` | Catch-all (404) |
| `routes/__root.tsx` | - | Root layout |

### 기본 라우트

```tsx
// routes/about.tsx
export const Route = createFileRoute('/about')({
  component: AboutPage,
})

const AboutPage = (): JSX.Element => {
  return <div>About Page</div>
}
```

### Loader: 데이터 사전 로드

```tsx
// routes/posts/index.tsx
export const Route = createFileRoute('/posts')({
  component: PostsPage,
  loader: async () => {
    const posts = await getPosts()
    return { posts }
  },
})

const PostsPage = (): JSX.Element => {
  const { posts } = Route.useLoaderData()

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### 동적 라우트

```tsx
// routes/users/$id.tsx
export const Route = createFileRoute('/users/$id')({
  loader: async ({ params }) => {
    const user = await getUserById(params.id)
    return { user }
  },
  component: UserPage,
})

const UserPage = (): JSX.Element => {
  const { user } = Route.useLoaderData()

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

### SSR 옵션

| 옵션 | 동작 | 사용 시점 |
|------|------|----------|
| `ssr: true` | 전체 SSR (기본값) | 일반 페이지 |
| `ssr: false` | 클라이언트만 렌더링 | 인증 필요 페이지 |
| `ssr: 'data-only'` | 데이터만 서버에서 로드 | 데이터 + 클라이언트 렌더링 |

```tsx
// ssr 옵션 예시
export const Route = createFileRoute('/dashboard')({
  ssr: false, // 클라이언트에서만 렌더링
  component: DashboardPage,
})
```

### beforeLoad: 라우트 접근 전 체크

```tsx
// routes/dashboard.tsx
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async () => {
    const user = await getCurrentUser()
    if (!user) {
      throw redirect({ to: '/login' })
    }
    return { user }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { user } = Route.useRouteContext()
  return <h1>Welcome, {user.name}!</h1>
}
```

### Server Routes (API 엔드포인트)

```tsx
// routes/api/hello.tsx
export const Route = createFileRoute('/api/hello')({
  server: {
    handlers: {
      GET: async () => {
        return new Response('Hello World')
      },
      POST: async ({ request }) => {
        const body = await request.json()
        return Response.json({ name: body.name })
      },
    },
  },
})
```

### Catch-all Route (404)

```tsx
// routes/$.tsx
export const Route = createFileRoute('/$')({
  component: NotFoundPage,
})

const NotFoundPage = (): JSX.Element => {
  return (
    <div>
      <h1>404 - Page Not Found</h1>
      <a href="/">Go Home</a>
    </div>
  )
}
```

</routing>

---

<auth_patterns>

## 인증 패턴

Better Auth 통합 및 인증 패턴.

### Better Auth 설정

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from '@/database/prisma'

export const auth = betterAuth({
  database: prismaAdapter(prisma),
  emailAndPassword: { enabled: true },
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7일
    updateAge: 60 * 60 * 24,      // 1일마다 갱신
  },
})

export type Session = typeof auth.$Infer.Session
```

### 인증 Server Functions

```typescript
// functions/auth.ts

// 로그인
const loginSchema = z.object({
  email: z.email(),
  password: z.string().min(8),
})

export const login = createServerFn({ method: 'POST' })
  .inputValidator(loginSchema)
  .handler(async ({ data, request }) => {
    const result = await auth.api.signInEmail({
      email: data.email,
      password: data.password,
      headers: request.headers,
    })

    if (!result.user) {
      throw new Error('Invalid credentials')
    }

    throw redirect({ to: '/dashboard' })
  })

// 로그아웃
export const logout = createServerFn({ method: 'POST' })
  .handler(async ({ request }) => {
    await auth.api.signOut({ headers: request.headers })
    throw redirect({ to: '/' })
  })

// 현재 사용자
export const getCurrentUser = createServerFn({ method: 'GET' })
  .handler(async ({ request }) => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })
    return session?.user ?? null
  })

// 회원가입
const registerSchema = z.object({
  email: z.email(),
  password: z.string().min(8),
  name: z.string().min(1),
})

export const register = createServerFn({ method: 'POST' })
  .inputValidator(registerSchema)
  .handler(async ({ data, request }) => {
    const result = await auth.api.signUpEmail({
      email: data.email,
      password: data.password,
      name: data.name,
      headers: request.headers,
    })

    if (!result.user) {
      throw new Error('Registration failed')
    }

    throw redirect({ to: '/dashboard' })
  })
```

### 인증 미들웨어

```typescript
// middleware/auth.ts
export const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (!session?.user) {
      throw redirect({ to: '/login' })
    }

    return next({ context: { user: session.user } })
  })
```

### 보호된 Server Function

```typescript
// functions/posts.ts
export const getMyPosts = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.post.findMany({
      where: { authorId: context.user.id },
    })
  })

export const createPost = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(z.object({
    title: z.string().min(1),
    content: z.string().min(1),
  }))
  .handler(async ({ data, context }) => {
    return prisma.post.create({
      data: {
        ...data,
        authorId: context.user.id,
      },
    })
  })
```

### 보호된 라우트

```tsx
// routes/dashboard.tsx
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async () => {
    const user = await getCurrentUser()
    if (!user) {
      throw redirect({ to: '/login' })
    }
    return { user }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { user } = Route.useRouteContext()

  return (
    <div>
      <h1>Welcome, {user.name}!</h1>
    </div>
  )
}
```

### 로그인 폼 (TanStack Query)

```tsx
// routes/login.tsx
const LoginPage = (): JSX.Element => {
  const mutation = useMutation({
    mutationFn: login,
  })

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    mutation.mutate({
      email: formData.get('email') as string,
      password: formData.get('password') as string,
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" required />
      <input name="password" type="password" required />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Logging in...' : 'Login'}
      </button>
      {mutation.error && <p>Error: {mutation.error.message}</p>}
    </form>
  )
}
```

</auth_patterns>

---

<file_structure>

## 파일 구조

### 디렉터리 레이아웃

```
src/
├── routes/                 # File-based routes
│   ├── __root.tsx         # Root layout (모든 라우트의 부모)
│   ├── index.tsx          # / (홈)
│   ├── about.tsx          # /about
│   ├── users/
│   │   ├── index.tsx      # /users
│   │   ├── $id.tsx        # /users/:id
│   │   ├── -components/   # 페이지 전용 컴포넌트 (필수)
│   │   │   └── user-card.tsx
│   │   ├── -hooks/        # 페이지 전용 Custom Hooks (필수)
│   │   │   └── use-user-data.ts
│   │   └── -functions/    # 페이지 전용 Server Functions (필수)
│   │       └── user-mutations.ts
│   └── dashboard/
│       ├── index.tsx
│       ├── -components/
│       ├── -hooks/
│       └── -functions/
│
├── functions/             # 공통 Server Functions
│   ├── auth.ts
│   ├── posts.ts
│   └── users.ts
│
├── middleware/            # 공통 Middleware
│   ├── auth.ts
│   └── logging.ts
│
├── components/            # 공통 컴포넌트
│   └── ui/
│       ├── button.tsx
│       └── input.tsx
│
├── lib/                   # 유틸리티
│   ├── env.ts
│   └── utils.ts
│
└── database/              # Prisma
    └── prisma.ts
```

### 파일 분리 규칙

| 위치 | 사용 시점 | 예시 |
|------|----------|------|
| `routes/[path]/-components/` | 해당 페이지에서만 사용 | `user-card.tsx` |
| `routes/[path]/-hooks/` | 해당 페이지 전용 Hook | `use-user-data.ts` |
| `routes/[path]/-functions/` | 해당 페이지 전용 Server Function | `user-mutations.ts` |
| `@/functions/` | 여러 페이지에서 재사용 | `auth.ts`, `posts.ts` |
| `@/components/` | 공통 UI 컴포넌트 | `button.tsx`, `input.tsx` |
| `@/middleware/` | 공통 미들웨어 | `auth.ts`, `logging.ts` |

### 필수 규칙

✅ **페이지당 `-components/`, `-hooks/`, `-functions/` 폴더 필수**
- Custom Hook은 페이지 크기와 무관하게 **반드시** `-hooks/` 폴더에 분리
- 줄 수 무관: 10줄이든 100줄이든 분리 필수

✅ **공통 함수 → `@/functions/`**
- 여러 페이지에서 사용하는 Server Function

✅ **라우트 전용 → `routes/[경로]/-functions/`**
- 해당 라우트에서만 사용하는 Server Function

❌ **index.ts에서 내부 헬퍼 함수 export 금지**
- Server Function만 export

</file_structure>

---

<dos_donts>

## Do's & Don'ts

### Server Functions

| ✅ Do | ❌ Don't |
|-------|----------|
| `createServerFn({ method: 'POST' })` 사용 | 일반 async 함수를 API로 사용 |
| POST/PUT/PATCH에 `.inputValidator()` 필수 | handler 내부에서 수동 검증 |
| 인증 필요 시 `.middleware([authMiddleware])` | handler 내부에서 세션 체크 |
| `.inputValidator(zodSchema)` 사용 (v1) | `.validator()` 사용 (deprecated) |
| 명시적 return type 선언 | any 타입 사용 |
| 내부 헬퍼는 export 금지 | 헬퍼 함수 export |
| Server Function에서만 `process.env` 사용 | loader에서 환경변수 직접 사용 |

### 예시: Server Functions

```typescript
// ✅ 올바른 패턴
const schema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(schema)
  .handler(async ({ data, context }): Promise<User> => {
    return prisma.user.create({
      data: {
        ...data,
        createdBy: context.user.id,
      },
    })
  })

// ❌ 잘못된 패턴
export const badCreate = async (data: any) => { // ❌ createServerFn 없음, any 타입
  // ❌ 수동 검증
  if (!data.email || !data.name) {
    throw new Error('Invalid data')
  }

  // ❌ 수동 인증 체크
  const session = await getSession()
  if (!session) {
    throw new Error('Unauthorized')
  }

  return prisma.user.create({ data })
}
```

### 클라이언트 호출

| ✅ Do | ❌ Don't |
|-------|----------|
| TanStack Query 사용 (`useQuery`/`useMutation`) | Server Function 직접 호출 |
| `queryClient.invalidateQueries()` 로 동기화 | 수동 상태 관리 |
| `isLoading`, `error` 상태 활용 | try-catch로 에러 처리 |
| `queryKey`로 캐싱 관리 | useEffect + useState |

### 예시: 클라이언트 호출

```tsx
// ✅ 올바른 패턴 (useQuery)
const UsersPage = (): JSX.Element => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return <ul>{data?.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

// ✅ 올바른 패턴 (useMutation)
const CreateForm = (): JSX.Element => {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      const formData = new FormData(e.currentTarget)
      mutation.mutate({
        email: formData.get('email') as string,
        name: formData.get('name') as string,
      })
    }}>
      <input name="email" type="email" />
      <input name="name" />
      <button type="submit">Create</button>
    </form>
  )
}

// ❌ 잘못된 패턴
const BadComponent = (): JSX.Element => {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setLoading(true)
    getUsers() // ❌ 직접 호출 (캐싱 없음)
      .then(setUsers)
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  return <div>{/* ... */}</div>
}
```

### Middleware

| ✅ Do | ❌ Don't |
|-------|----------|
| 인증/권한 체크를 미들웨어로 분리 | handler 내부에서 체크 |
| `context`로 데이터 전달 | 전역 변수 사용 |
| 여러 미들웨어 체이닝 가능 | 하나의 미들웨어에 모든 로직 |

### 예시: Middleware

```typescript
// ✅ 올바른 패턴
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })
    return next({ context: { user: session.user } })
  })

export const fn = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return { user: context.user }
  })

// ❌ 잘못된 패턴
export const badFn = createServerFn({ method: 'GET' })
  .handler(async () => {
    // ❌ handler 내부에서 인증 체크
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })

    return { user: session.user }
  })
```

### 파일 구조

| ✅ Do | ❌ Don't |
|-------|----------|
| 페이지 전용: `routes/[path]/-functions/` | 모든 함수를 `@/functions/`에 |
| 공통 함수: `@/functions/` | 라우트 파일에 함수 직접 작성 |
| Custom Hook: `-hooks/` 폴더에 분리 (필수) | 라우트 파일에 Hook 작성 |

### 예시: 파일 구조

```typescript
// ✅ 올바른 구조
// routes/users/-functions/user-mutations.ts
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(schema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// routes/users/-hooks/use-user-form.ts
export const useUserForm = () => {
  const mutation = useMutation({ mutationFn: createUser })
  return { mutation }
}

// routes/users/index.tsx
import { useUserForm } from './-hooks/use-user-form'
import { createUser } from './-functions/user-mutations'

// ❌ 잘못된 구조
// routes/users/index.tsx (모든 로직이 한 파일에)
const createUser = createServerFn({ method: 'POST' })
  .inputValidator(schema)
  .handler(async ({ data }) => prisma.user.create({ data }))

const useUserForm = () => {
  const mutation = useMutation({ mutationFn: createUser })
  return { mutation }
}

export const Route = createFileRoute('/users')({
  component: UsersPage,
})
```

### 환경 변수

| ✅ Do | ❌ Don't |
|-------|----------|
| Server Function에서만 `process.env` 사용 | loader에서 직접 사용 |
| Zod로 환경 변수 검증 | 검증 없이 사용 |

### 예시: 환경 변수

```typescript
// ✅ 올바른 패턴
// lib/env.ts
const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_SECRET: z.string().min(32),
})

export const env = envSchema.parse(process.env)

// functions/config.ts
const getConfig = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => {
    return {
      secret: env.API_SECRET, // ✅ 서버에서만 실행
    }
  })

// ❌ 잘못된 패턴
export const Route = createFileRoute('/config')({
  loader: () => {
    const secret = process.env.API_SECRET // ❌ 클라이언트에 노출됨!
    return { secret }
  },
})
```

</dos_donts>

---

<quick_reference>

## Quick Reference

### GET: 데이터 조회

```typescript
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany())

export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => context.user)
```

### POST: 데이터 생성 (inputValidator 필수)

```typescript
const schema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(schema)
  .handler(async ({ data, context }) => {
    return prisma.user.create({
      data: { ...data, createdBy: context.user.id },
    })
  })
```

### PUT/PATCH: 데이터 수정 (inputValidator 필수)

```typescript
export const updateUser = createServerFn({ method: 'PUT' })
  .middleware([authMiddleware])
  .inputValidator(z.object({ id: z.string(), name: z.string() }))
  .handler(async ({ data }) => {
    return prisma.user.update({
      where: { id: data.id },
      data: { name: data.name },
    })
  })
```

### DELETE: 데이터 삭제

```typescript
export const deletePost = createServerFn({ method: 'DELETE' })
  .middleware([authMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }) => {
    return prisma.post.delete({ where: { id: data.id } })
  })
```

### Loader: 데이터 사전 로드

```typescript
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => {
    const users = await getUsers()
    return { users }
  },
})

const UsersPage = (): JSX.Element => {
  const { users } = Route.useLoaderData()
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}
```

### TanStack Query: useQuery

```typescript
const { data, isLoading, error } = useQuery({
  queryKey: ['posts'],
  queryFn: () => getPosts(),
})
```

### TanStack Query: useMutation

```typescript
const queryClient = useQueryClient()

const mutation = useMutation({
  mutationFn: createPost,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
})

mutation.mutate({ title: 'New Post', content: 'Content' })
```

### 인증 미들웨어

```typescript
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })
    return next({ context: { user: session.user } })
  })
```

### 보호된 라우트

```typescript
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async () => {
    const user = await getCurrentUser()
    if (!user) throw redirect({ to: '/login' })
    return { user }
  },
  component: DashboardPage,
})
```

</quick_reference>

---

<version_info>

**Version:** v1.x

**Key Changes in v1:**
- `.inputValidator()` (v1) replaces `.validator()` (deprecated)
- Enhanced middleware system with context passing
- Improved type safety for Server Functions
- Better TanStack Query integration

</version_info>
