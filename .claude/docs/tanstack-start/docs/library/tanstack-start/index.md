# TanStack Start Documentation

<context>

**목적**: TanStack Start 애플리케이션 개발을 위한 AI Agent 최적화 문서

**버전**: v1.x (RC, ~v1.159.x)

**핵심 특징**:
- Type-safe, full-stack React framework
- File-based routing with Vite-powered build
- Server Functions로 type-safe API 구축
- Built-in SWR caching (staleTime, gcTime, shouldReload)
- Streaming SSR 지원
- TanStack Query 통합
- Multiple deployment targets (Cloudflare, Netlify, Vercel, Railway, Node, Bun)
- React Server Components 지원 예정 (non-breaking v1.x addition)

**주요 패키지 변경사항**:
- `@tanstack/start` → `@tanstack/react-start` (v1.121.0+)
- Build system: Vinxi → Vite
- `.validator()` → `.inputValidator()` (deprecated)
- `createAPIFileRoute()` → `createServerFileRoute()` with `.methods()`

**런타임 요구사항**:
| 패키지 | 버전 |
|--------|------|
| Node.js | >=22.12.0 |
| React | 18+ or 19+ |
| Vite | 7+ |
| TypeScript | 5.x |

</context>

---

<forbidden>

| 패턴 | 이유 |
|------|------|
| `@tanstack/start` 패키지 사용 | v1.121.0+부터 `@tanstack/react-start`로 변경됨 |
| `.validator()` 사용 | Deprecated. `.inputValidator()` 사용 필수 |
| `createAPIFileRoute()` 사용 | Deprecated. `createServerFileRoute().methods()` 사용 |
| Vinxi config 참조 | Vite로 마이그레이션됨 |
| Server Function 내 `import.meta.env` | 클라이언트 전용. `process.env` 사용 |
| Client에서 `process.env` | 서버 전용. `import.meta.env.VITE_*` 사용 |
| `tsconfig.json`에 `verbatimModuleSyntax: true` | TanStack Start와 호환성 문제 발생 |
| Server Function에 민감 정보 직접 노출 | 클라이언트 번들에 포함됨. Helper function 분리 필수 |
| `any` 타입 사용 | Type safety 상실. `unknown` 또는 명시적 타입 사용 |
| Middleware 없이 인증 로직 | 보안 취약. `createMiddleware` 사용 필수 |
| Route 파일에 비즈니스 로직 | 관심사 분리. `-functions/` 디렉토리 사용 |
| `gcTime: 0` 남발 | 캐시 무효화. 필요한 경우만 사용 |

</forbidden>

---

<required>

| 패턴 | 세부사항 |
|------|----------|
| `@tanstack/react-start` 패키지 | v1.121.0+ 필수 패키지명 |
| `.inputValidator()` | POST/PUT/PATCH/DELETE Server Function에 필수 |
| Zod schema 검증 | 모든 입력값 검증 (`z.email()`, `z.url()` 등) |
| Middleware로 인증 처리 | `createMiddleware`로 auth 로직 중앙화 |
| Helper functions 분리 | Server Function 외부에 민감 로직 격리 |
| 명시적 return type | 모든 함수에 타입 명시 |
| `strictNullChecks: true` | TypeScript config에 권장 |
| Server Routes는 `createServerFileRoute()` | API 엔드포인트용 새 API |
| Environment variables 분리 | Server: `process.env`, Client: `import.meta.env.VITE_*` |
| TanStack Query로 Server Function 호출 | `useSuspenseQuery`, `useMutation` 사용 |
| `-components/`, `-hooks/`, `-functions/` 컨벤션 | 파일 구조화 규칙 |
| `beforeLoad`로 인증 가드 | Route-level 접근 제어 |

</required>

---

<setup>

## 설치

```bash
# New project
npm create @tanstack/start@latest

# Dependencies
npm install @tanstack/react-start@latest @tanstack/react-router@latest
npm install -D @tanstack/router-plugin vite typescript
```

## vite.config.ts

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackRouterPlugin } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    tanstackRouterPlugin(),
    react(),
  ],
  server: {
    port: 3000,
  },
})
```

## tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": false,
    "strictNullChecks": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["app/**/*"],
  "exclude": ["node_modules"]
}
```

**주의**: `verbatimModuleSyntax: true` 사용 금지 (호환성 문제)

## Environment Variables

### Server-only (.env)

```bash
# Server-only (process.env)
DATABASE_URL="postgresql://..."
AUTH_SECRET="secret-key"
STRIPE_SECRET_KEY="sk_test_..."
```

### Client-exposed (.env)

```bash
# Client-exposed (import.meta.env.VITE_*)
VITE_API_URL="https://api.example.com"
VITE_PUBLIC_KEY="pk_test_..."
```

### 사용 예시

```typescript
// ✅ Server Function
export const getSecretData = createServerFn({ method: 'GET' }).handler(
  async () => {
    const secret = process.env.AUTH_SECRET // OK
    return { data: 'protected' }
  }
)

// ✅ Client Component
function App() {
  const apiUrl = import.meta.env.VITE_API_URL // OK
  return <div>{apiUrl}</div>
}

// ❌ Wrong
export const wrongFn = createServerFn({ method: 'GET' }).handler(async () => {
  const key = import.meta.env.VITE_SECRET // ❌ 서버에서 import.meta.env 사용 금지
  return key
})
```

### Validation (app/env.ts)

```typescript
import { z } from 'zod'

const serverEnvSchema = z.object({
  DATABASE_URL: z.string().url(),
  AUTH_SECRET: z.string().min(32),
  NODE_ENV: z.enum(['development', 'production', 'test']),
})

const clientEnvSchema = z.object({
  VITE_API_URL: z.string().url(),
})

export const serverEnv = serverEnvSchema.parse(process.env)

export const clientEnv = clientEnvSchema.parse(import.meta.env)
```

</setup>

---

<server_functions>

## Server Functions 개요

Server Functions는 type-safe한 API 엔드포인트를 생성하는 TanStack Start의 핵심 기능입니다.

**주요 특징**:
- Type-safe client-server communication
- Automatic serialization/deserialization
- Middleware support
- Input validation with Zod
- Method-based routing (GET, POST, PUT, PATCH, DELETE)

## createServerFn 패턴

### GET (Query)

```typescript
// app/functions/users.ts
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

const getUserSchema = z.object({
  id: z.string().uuid(),
})

export const getUser = createServerFn({ method: 'GET' })
  .inputValidator(getUserSchema)
  .handler(async ({ data }) => {
    const user = await db.user.findUnique({ where: { id: data.id } })
    if (!user) throw new Error('User not found')
    return user
  })
```

### POST (Create)

```typescript
// app/functions/users.ts
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(2),
  website: z.url().optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .middleware([authMiddleware])
  .handler(async ({ data, context }) => {
    const user = await db.user.create({
      data: {
        ...data,
        createdBy: context.user.id,
      },
    })
    return user
  })
```

### PUT/PATCH (Update)

```typescript
// app/functions/users.ts
const updateUserSchema = z.object({
  id: z.string().uuid(),
  email: z.email().optional(),
  name: z.string().min(2).optional(),
})

export const updateUser = createServerFn({ method: 'PUT' })
  .inputValidator(updateUserSchema)
  .middleware([authMiddleware])
  .handler(async ({ data, context }) => {
    const { id, ...updates } = data

    // Authorization check
    if (context.user.id !== id && context.user.role !== 'admin') {
      throw new Error('Unauthorized')
    }

    const user = await db.user.update({
      where: { id },
      data: updates,
    })
    return user
  })
```

### DELETE

```typescript
// app/functions/users.ts
const deleteUserSchema = z.object({
  id: z.string().uuid(),
})

export const deleteUser = createServerFn({ method: 'DELETE' })
  .inputValidator(deleteUserSchema)
  .middleware([authMiddleware, adminMiddleware])
  .handler(async ({ data }) => {
    await db.user.delete({ where: { id: data.id } })
    return { success: true }
  })
```

## Client에서 호출 (TanStack Query)

### useSuspenseQuery (GET)

```typescript
// app/routes/users.$userId.tsx
import { createFileRoute } from '@tanstack/react-router'
import { useSuspenseQuery } from '@tanstack/react-query'
import { getUser } from '~/functions/users'

export const Route = createFileRoute('/users/$userId')({
  component: UserDetail,
})

function UserDetail() {
  const { userId } = Route.useParams()

  const { data: user } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser({ data: { id: userId } }),
  })

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

### useMutation (POST/PUT/DELETE)

```typescript
// app/routes/users.new.tsx
import { createFileRoute } from '@tanstack/react-router'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createUser } from '~/functions/users'

export const Route = createFileRoute('/users/new')({
  component: NewUser,
})

function NewUser() {
  const queryClient = useQueryClient()
  const navigate = Route.useNavigate()

  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: (user) => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      navigate({ to: '/users/$userId', params: { userId: user.id } })
    },
  })

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    mutation.mutate({
      data: {
        email: formData.get('email') as string,
        name: formData.get('name') as string,
      },
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" required />
      <input name="name" type="text" required />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating...' : 'Create User'}
      </button>
      {mutation.isError && <p>Error: {mutation.error.message}</p>}
    </form>
  )
}
```

## Helper Functions 패턴

**규칙**: 민감한 로직(DB 쿼리, 인증, 비즈니스 로직)은 Server Function 외부에 분리

### ✅ 올바른 패턴

```typescript
// app/functions/users-helpers.ts
import 'server-only' // Ensures this file is never bundled for client

export async function getUserFromDB(id: string) {
  const user = await db.user.findUnique({ where: { id } })
  if (!user) throw new Error('User not found')
  return user
}

export async function createUserInDB(data: {
  email: string
  name: string
  passwordHash: string
}) {
  return db.user.create({ data })
}

// app/functions/users.ts
import { createServerFn } from '@tanstack/react-start'
import { getUserFromDB, createUserInDB } from './users-helpers'

export const getUser = createServerFn({ method: 'GET' })
  .inputValidator(getUserSchema)
  .handler(async ({ data }) => getUserFromDB(data.id))

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .middleware([authMiddleware])
  .handler(async ({ data }) => {
    const passwordHash = await hashPassword(data.password)
    return createUserInDB({ ...data, passwordHash })
  })
```

### ❌ 잘못된 패턴

```typescript
// ❌ Server Function 내부에 직접 DB 로직
export const getUser = createServerFn({ method: 'GET' })
  .inputValidator(getUserSchema)
  .handler(async ({ data }) => {
    // ❌ 민감 로직이 클라이언트 번들에 포함될 수 있음
    const user = await db.user.findUnique({ where: { id: data.id } })
    return user
  })
```

## Environment Variables 보안

```typescript
// ✅ Helper function에서 env 사용
// app/functions/stripe-helpers.ts
import 'server-only'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
})

export async function createPaymentIntent(amount: number) {
  return stripe.paymentIntents.create({
    amount,
    currency: 'usd',
  })
}

// app/functions/stripe.ts
import { createServerFn } from '@tanstack/react-start'
import { createPaymentIntent } from './stripe-helpers'

export const createPayment = createServerFn({ method: 'POST' })
  .inputValidator(z.object({ amount: z.number().positive() }))
  .middleware([authMiddleware])
  .handler(async ({ data }) => createPaymentIntent(data.amount))
```

## Static Server Functions (Experimental)

정적 사이트 생성 시 Server Functions를 빌드 타임에 실행:

```typescript
import { createServerFn } from '@tanstack/react-start'
import { staticFunctionMiddleware } from '@tanstack/react-start/static'

export const getStaticPosts = createServerFn({ method: 'GET' })
  .middleware([staticFunctionMiddleware])
  .handler(async () => {
    const posts = await fetchAllPosts()
    return posts
  })
```

</server_functions>

---

<middleware>

## Middleware 개요

Middleware는 Server Functions와 Routes에서 재사용 가능한 로직을 제공합니다.

**사용 사례**:
- 인증/인가
- 입력 검증
- 로깅
- Rate limiting
- CORS 설정

## createMiddleware

```typescript
// app/middleware/auth.ts
import { createMiddleware } from '@tanstack/react-start'
import { getSessionFromCookie } from '~/auth-helpers'

export const authMiddleware = createMiddleware().server(async ({ next }) => {
  const session = await getSessionFromCookie()

  if (!session) {
    throw new Error('Unauthorized')
  }

  return next({
    context: {
      user: session.user,
      sessionId: session.id,
    },
  })
})
```

## Zod Validation Middleware

```typescript
// app/middleware/validation.ts
import { createMiddleware } from '@tanstack/react-start'
import { z } from 'zod'

export const createValidationMiddleware = <T extends z.ZodType>(
  schema: T
) => {
  return createMiddleware().server(async ({ next, data }) => {
    const validated = schema.parse(data)

    return next({
      context: {
        validated: validated as z.infer<T>,
      },
    })
  })
}

// Usage
const userSchema = z.object({ email: z.email() })
const validateUser = createValidationMiddleware(userSchema)

export const createUser = createServerFn({ method: 'POST' })
  .middleware([validateUser])
  .handler(async ({ context }) => {
    const { validated } = context // Type-safe
    return db.user.create({ data: validated })
  })
```

## Middleware Chaining

```typescript
// app/middleware/admin.ts
import { createMiddleware } from '@tanstack/react-start'

export const adminMiddleware = createMiddleware().server(
  async ({ next, context }) => {
    // authMiddleware에서 context.user 주입됨
    if (context.user.role !== 'admin') {
      throw new Error('Forbidden: Admin access required')
    }

    return next({
      context: {
        ...context,
        isAdmin: true,
      },
    })
  }
)

// Usage: authMiddleware → adminMiddleware 순서로 실행
export const deleteUser = createServerFn({ method: 'DELETE' })
  .inputValidator(deleteUserSchema)
  .middleware([authMiddleware, adminMiddleware])
  .handler(async ({ data, context }) => {
    console.log(context.isAdmin) // true
    await db.user.delete({ where: { id: data.id } })
    return { success: true }
  })
```

## Global Middleware

```typescript
// app/router.tsx
import { createRouter } from '@tanstack/react-router'
import { loggingMiddleware } from '~/middleware/logging'

export const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  context: {
    // Global context
  },
  middleware: [loggingMiddleware], // 모든 routes에 적용
})
```

## Route-level Middleware

```typescript
// app/routes/_authenticated.tsx
import { createFileRoute } from '@tanstack/react-router'
import { authMiddleware } from '~/middleware/auth'

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: async ({ context }) => {
    // authMiddleware 실행
    const session = await getSession()
    if (!session) {
      throw redirect({ to: '/login' })
    }
    return {
      user: session.user,
    }
  },
})
```

## Logging Middleware

```typescript
// app/middleware/logging.ts
import { createMiddleware } from '@tanstack/react-start'

export const loggingMiddleware = createMiddleware().server(
  async ({ next, method, url }) => {
    const start = Date.now()

    console.log(`[${method}] ${url} - Start`)

    try {
      const result = await next()
      const duration = Date.now() - start
      console.log(`[${method}] ${url} - Success (${duration}ms)`)
      return result
    } catch (error) {
      const duration = Date.now() - start
      console.error(`[${method}] ${url} - Error (${duration}ms)`, error)
      throw error
    }
  }
)
```

## Rate Limiting Middleware

```typescript
// app/middleware/rate-limit.ts
import { createMiddleware } from '@tanstack/react-start'
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
})

export const rateLimitMiddleware = createMiddleware().server(
  async ({ next, context }) => {
    const identifier = context.user?.id || 'anonymous'
    const { success } = await ratelimit.limit(identifier)

    if (!success) {
      throw new Error('Rate limit exceeded')
    }

    return next()
  }
)
```

</middleware>

---

<routing>

## File-based Routing

TanStack Start는 `app/routes/` 디렉토리 구조를 URL로 변환합니다.

### 파일 구조 → URL 매핑

| 파일 경로 | URL |
|-----------|-----|
| `routes/index.tsx` | `/` |
| `routes/about.tsx` | `/about` |
| `routes/posts.index.tsx` | `/posts` |
| `routes/posts.$postId.tsx` | `/posts/:postId` |
| `routes/posts.$postId.edit.tsx` | `/posts/:postId/edit` |
| `routes/blog._layout.tsx` | Layout (no URL) |
| `routes/blog._layout.posts.tsx` | `/blog/posts` |
| `routes/admin._.tsx` | `/admin/*` (catch-all) |

## Basic Routes

### Index Route

```typescript
// app/routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: Home,
})

function Home() {
  return (
    <div>
      <h1>Welcome to TanStack Start</h1>
    </div>
  )
}
```

### Static Route

```typescript
// app/routes/about.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/about')({
  component: About,
})

function About() {
  return <div>About Page</div>
}
```

## Loader Pattern

```typescript
// app/routes/posts.index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPosts } from '~/functions/posts'

export const Route = createFileRoute('/posts/')({
  loader: async () => {
    const posts = await getPosts()
    return { posts }
  },
  component: PostsList,
})

function PostsList() {
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

## Dynamic Routes

### Path Parameters

```typescript
// app/routes/posts.$postId.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPost } from '~/functions/posts'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost({ data: { id: params.postId } })
    return { post }
  },
  component: PostDetail,
})

function PostDetail() {
  const { postId } = Route.useParams()
  const { post } = Route.useLoaderData()

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  )
}
```

### Search Parameters

```typescript
// app/routes/search.tsx
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'

const searchSchema = z.object({
  q: z.string().optional(),
  page: z.number().int().positive().default(1),
  sort: z.enum(['asc', 'desc']).default('asc'),
})

export const Route = createFileRoute('/search')({
  validateSearch: searchSchema,
  loaderDeps: ({ search }) => ({ search }),
  loader: async ({ deps }) => {
    const results = await searchPosts(deps.search)
    return { results }
  },
  component: SearchPage,
})

function SearchPage() {
  const { q, page, sort } = Route.useSearch()
  const { results } = Route.useLoaderData()
  const navigate = Route.useNavigate()

  const updateSearch = (newQ: string) => {
    navigate({
      search: (prev) => ({ ...prev, q: newQ, page: 1 }),
    })
  }

  return (
    <div>
      <input
        value={q || ''}
        onChange={(e) => updateSearch(e.target.value)}
      />
      <ul>
        {results.map((result) => (
          <li key={result.id}>{result.title}</li>
        ))}
      </ul>
    </div>
  )
}
```

## SSR Options

```typescript
// app/routes/posts.$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost({ data: { id: params.postId } })
    return { post }
  },
  staleTime: 1000 * 60 * 5, // 5분간 캐시
  gcTime: 1000 * 60 * 10, // 10분 후 가비지 컬렉션
  shouldReload: false, // 재방문 시 reload 안함
  component: PostDetail,
})
```

**SWR Caching 옵션**:
| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `staleTime` | 데이터가 fresh한 시간 (ms) | 0 |
| `gcTime` | 메모리에서 제거되기까지 시간 (ms) | 30분 |
| `shouldReload` | 재방문 시 reload 여부 | true |

## beforeLoad (Auth Guard)

```typescript
// app/routes/_authenticated.tsx
import { createFileRoute, redirect } from '@tanstack/react-router'
import { getSession } from '~/auth-helpers'

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: async ({ context, location }) => {
    const session = await getSession()

    if (!session) {
      throw redirect({
        to: '/login',
        search: {
          redirect: location.href,
        },
      })
    }

    return {
      user: session.user,
    }
  },
})

// app/routes/_authenticated.profile.tsx
export const Route = createFileRoute('/_authenticated/profile')({
  component: Profile,
})

function Profile() {
  const { user } = Route.useRouteContext()
  return <div>Welcome, {user.name}</div>
}
```

## Nested Layouts

```typescript
// app/routes/_layout.tsx
import { createFileRoute, Outlet } from '@tanstack/react-router'

export const Route = createFileRoute('/_layout')({
  component: Layout,
})

function Layout() {
  return (
    <div>
      <nav>Navigation</nav>
      <main>
        <Outlet /> {/* Child routes render here */}
      </main>
      <footer>Footer</footer>
    </div>
  )
}

// app/routes/_layout.page1.tsx
export const Route = createFileRoute('/_layout/page1')({
  component: () => <div>Page 1</div>,
})

// app/routes/_layout.page2.tsx
export const Route = createFileRoute('/_layout/page2')({
  component: () => <div>Page 2</div>,
})
```

## Server Routes (New API)

**중요**: `createAPIFileRoute()` → `createServerFileRoute()` + `.methods()` 로 변경됨

### RESTful API Endpoint

```typescript
// app/routes/api/users.$userId.tsx
import { createServerFileRoute } from '@tanstack/react-start'
import { z } from 'zod'

const getUserSchema = z.object({
  userId: z.string().uuid(),
})

const updateUserSchema = z.object({
  userId: z.string().uuid(),
  name: z.string().optional(),
  email: z.email().optional(),
})

export const Route = createServerFileRoute('/api/users/$userId')
  .methods({
    GET: async ({ request, params }) => {
      const { userId } = getUserSchema.parse(params)
      const user = await db.user.findUnique({ where: { id: userId } })

      if (!user) {
        return new Response('Not Found', { status: 404 })
      }

      return Response.json(user)
    },

    PUT: async ({ request, params }) => {
      const body = await request.json()
      const { userId, ...updates } = updateUserSchema.parse({
        ...params,
        ...body,
      })

      const user = await db.user.update({
        where: { id: userId },
        data: updates,
      })

      return Response.json(user)
    },

    DELETE: async ({ request, params }) => {
      const { userId } = getUserSchema.parse(params)
      await db.user.delete({ where: { id: userId } })

      return Response.json({ success: true })
    },
  })
```

### File Upload Endpoint

```typescript
// app/routes/api/upload.tsx
import { createServerFileRoute } from '@tanstack/react-start'
import { writeFile } from 'fs/promises'
import { join } from 'path'

export const Route = createServerFileRoute('/api/upload')
  .methods({
    POST: async ({ request }) => {
      const formData = await request.formData()
      const file = formData.get('file') as File

      if (!file) {
        return new Response('No file provided', { status: 400 })
      }

      const bytes = await file.arrayBuffer()
      const buffer = Buffer.from(bytes)

      const path = join(process.cwd(), 'uploads', file.name)
      await writeFile(path, buffer)

      return Response.json({ success: true, path })
    },
  })
```

## Catch-all Routes

```typescript
// app/routes/docs._.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/docs/$')({
  component: DocsPage,
})

function DocsPage() {
  const params = Route.useParams()
  const splat = params['_splat'] // Captures everything after /docs/

  return <div>Docs: {splat}</div>
}
```

## Link Navigation

```typescript
import { Link } from '@tanstack/react-router'

function Navigation() {
  return (
    <nav>
      <Link to="/">Home</Link>
      <Link to="/about">About</Link>
      <Link
        to="/posts/$postId"
        params={{ postId: '123' }}
      >
        Post 123
      </Link>
      <Link
        to="/search"
        search={{ q: 'tanstack', page: 1 }}
      >
        Search
      </Link>
    </nav>
  )
}
```

## Preload Strategy

```typescript
// app/routes/posts.$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost({ data: { id: params.postId } })
    return { post }
  },
  component: PostDetail,
})

// Usage
function PostsList() {
  return (
    <div>
      {posts.map((post) => (
        <Link
          key={post.id}
          to="/posts/$postId"
          params={{ postId: post.id }}
          preload="intent" // Preload on hover/focus
        >
          {post.title}
        </Link>
      ))}
    </div>
  )
}
```

**Preload 옵션**:
| 값 | 동작 |
|----|------|
| `false` | Preload 안함 |
| `intent` | Hover/focus 시 preload |
| `render` | Link 렌더링 시 preload |
| `viewport` | Viewport 진입 시 preload |

## Pending Component

```typescript
// app/routes/posts.$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    await delay(2000) // Simulate slow loading
    const post = await getPost({ data: { id: params.postId } })
    return { post }
  },
  pendingComponent: () => <div>Loading post...</div>,
  component: PostDetail,
})
```

## Error Boundaries

```typescript
// app/routes/posts.$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost({ data: { id: params.postId } })
    if (!post) {
      throw new Error('Post not found')
    }
    return { post }
  },
  errorComponent: ({ error }) => (
    <div>
      <h1>Error</h1>
      <p>{error.message}</p>
    </div>
  ),
  component: PostDetail,
})
```

## Router Context

```typescript
// app/router.tsx
import { createRouter } from '@tanstack/react-router'
import { QueryClient } from '@tanstack/react-query'

const queryClient = new QueryClient()

export const router = createRouter({
  routeTree,
  context: {
    queryClient,
  },
  defaultPreload: 'intent',
  defaultStaleTime: 1000 * 60 * 5, // 5분
})

// app/routes/posts.$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params, context }) => {
    const post = await context.queryClient.ensureQueryData({
      queryKey: ['post', params.postId],
      queryFn: () => getPost({ data: { id: params.postId } }),
    })
    return { post }
  },
  component: PostDetail,
})
```

## Streaming SSR

```typescript
// app/routes/dashboard.tsx
import { createFileRoute } from '@tanstack/react-router'
import { Suspense } from 'react'

export const Route = createFileRoute('/dashboard')({
  component: Dashboard,
})

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<div>Loading analytics...</div>}>
        <AnalyticsPanel />
      </Suspense>
      <Suspense fallback={<div>Loading activity...</div>}>
        <ActivityFeed />
      </Suspense>
    </div>
  )
}

function AnalyticsPanel() {
  const { data } = useSuspenseQuery({
    queryKey: ['analytics'],
    queryFn: () => getAnalytics(),
  })
  return <div>{/* Render analytics */}</div>
}
```

</routing>

---

<auth_patterns>

## Better Auth 통합

Better Auth는 TanStack Start와 완벽하게 호환되는 인증 라이브러리입니다.

### 설치 및 설정

```bash
npm install better-auth
```

```typescript
// app/auth.ts
import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { prisma } from '~/db'

export const auth = betterAuth({
  database: prismaAdapter(prisma, {
    provider: 'postgresql',
  }),
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
})
```

### Auth Server Functions

```typescript
// app/functions/auth.ts
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'
import { auth } from '~/auth'

const signUpSchema = z.object({
  email: z.email(),
  password: z.string().min(8),
  name: z.string().min(2),
})

export const signUp = createServerFn({ method: 'POST' })
  .inputValidator(signUpSchema)
  .handler(async ({ data }) => {
    const user = await auth.api.signUpEmail({
      email: data.email,
      password: data.password,
      name: data.name,
    })
    return user
  })

const signInSchema = z.object({
  email: z.email(),
  password: z.string(),
})

export const signIn = createServerFn({ method: 'POST' })
  .inputValidator(signInSchema)
  .handler(async ({ data }) => {
    const session = await auth.api.signInEmail({
      email: data.email,
      password: data.password,
    })
    return session
  })

export const signOut = createServerFn({ method: 'POST' }).handler(
  async () => {
    await auth.api.signOut()
    return { success: true }
  }
)

export const getSession = createServerFn({ method: 'GET' }).handler(
  async () => {
    const session = await auth.api.getSession()
    return session
  }
)
```

### Auth Middleware

```typescript
// app/middleware/auth.ts
import { createMiddleware } from '@tanstack/react-start'
import { auth } from '~/auth'

export const authMiddleware = createMiddleware().server(async ({ next }) => {
  const session = await auth.api.getSession()

  if (!session) {
    throw new Error('Unauthorized')
  }

  return next({
    context: {
      user: session.user,
      sessionId: session.session.id,
    },
  })
})

export const adminMiddleware = createMiddleware().server(
  async ({ next, context }) => {
    // Requires authMiddleware to run first
    if (context.user.role !== 'admin') {
      throw new Error('Forbidden: Admin access required')
    }

    return next({
      context: {
        ...context,
        isAdmin: true,
      },
    })
  }
)
```

### Protected Routes

```typescript
// app/routes/_authenticated.tsx
import { createFileRoute, redirect } from '@tanstack/react-router'
import { getSession } from '~/functions/auth'

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: async ({ context, location }) => {
    const session = await getSession()

    if (!session) {
      throw redirect({
        to: '/login',
        search: {
          redirect: location.href,
        },
      })
    }

    return {
      user: session.user,
    }
  },
})

// app/routes/_authenticated.profile.tsx
export const Route = createFileRoute('/_authenticated/profile')({
  component: Profile,
})

function Profile() {
  const { user } = Route.useRouteContext()

  return (
    <div>
      <h1>Profile</h1>
      <p>Email: {user.email}</p>
      <p>Name: {user.name}</p>
    </div>
  )
}

// app/routes/_authenticated.settings.tsx
export const Route = createFileRoute('/_authenticated/settings')({
  component: Settings,
})

function Settings() {
  const { user } = Route.useRouteContext()
  const queryClient = useQueryClient()

  const signOutMutation = useMutation({
    mutationFn: signOut,
    onSuccess: () => {
      queryClient.clear()
      window.location.href = '/login'
    },
  })

  return (
    <div>
      <h1>Settings</h1>
      <p>Logged in as {user.email}</p>
      <button onClick={() => signOutMutation.mutate()}>
        Sign Out
      </button>
    </div>
  )
}
```

### Login Form

```typescript
// app/routes/login.tsx
import { createFileRoute } from '@tanstack/react-router'
import { useMutation } from '@tanstack/react-query'
import { signIn } from '~/functions/auth'
import { z } from 'zod'

const searchSchema = z.object({
  redirect: z.string().optional(),
})

export const Route = createFileRoute('/login')({
  validateSearch: searchSchema,
  component: Login,
})

function Login() {
  const { redirect } = Route.useSearch()
  const navigate = Route.useNavigate()

  const signInMutation = useMutation({
    mutationFn: signIn,
    onSuccess: () => {
      window.location.href = redirect || '/'
    },
  })

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    signInMutation.mutate({
      data: {
        email: formData.get('email') as string,
        password: formData.get('password') as string,
      },
    })
  }

  return (
    <div>
      <h1>Login</h1>
      <form onSubmit={handleSubmit}>
        <input
          name="email"
          type="email"
          placeholder="Email"
          required
        />
        <input
          name="password"
          type="password"
          placeholder="Password"
          required
        />
        <button type="submit" disabled={signInMutation.isPending}>
          {signInMutation.isPending ? 'Signing in...' : 'Sign In'}
        </button>
        {signInMutation.isError && (
          <p>Error: {signInMutation.error.message}</p>
        )}
      </form>
    </div>
  )
}
```

### Role-based Access Control

```typescript
// app/functions/admin.ts
import { createServerFn } from '@tanstack/react-start'
import { authMiddleware, adminMiddleware } from '~/middleware/auth'

export const getAdminStats = createServerFn({ method: 'GET' })
  .middleware([authMiddleware, adminMiddleware])
  .handler(async ({ context }) => {
    const stats = await db.stats.findMany()
    return stats
  })

export const deleteUser = createServerFn({ method: 'DELETE' })
  .inputValidator(z.object({ userId: z.string().uuid() }))
  .middleware([authMiddleware, adminMiddleware])
  .handler(async ({ data }) => {
    await db.user.delete({ where: { id: data.userId } })
    return { success: true }
  })

// app/routes/_authenticated._admin.dashboard.tsx
export const Route = createFileRoute('/_authenticated/_admin/dashboard')({
  beforeLoad: async ({ context }) => {
    if (context.user.role !== 'admin') {
      throw redirect({ to: '/' })
    }
  },
  loader: async () => {
    const stats = await getAdminStats()
    return { stats }
  },
  component: AdminDashboard,
})

function AdminDashboard() {
  const { stats } = Route.useLoaderData()
  return <div>{/* Render admin dashboard */}</div>
}
```

</auth_patterns>

---

<file_structure>

## 권장 디렉토리 구조

```
app/
├── routes/
│   ├── __root.tsx
│   ├── index.tsx
│   ├── about.tsx
│   ├── posts.index.tsx
│   ├── posts.$postId.tsx
│   ├── posts.$postId.edit.tsx
│   ├── _authenticated.tsx
│   ├── _authenticated.profile.tsx
│   └── api/
│       └── users.$userId.tsx
├── components/
│   ├── ui/
│   │   ├── Button.tsx
│   │   └── Input.tsx
│   └── PostCard.tsx
├── functions/
│   ├── posts.ts
│   ├── posts-helpers.ts
│   ├── users.ts
│   └── auth.ts
├── middleware/
│   ├── auth.ts
│   ├── logging.ts
│   └── validation.ts
├── hooks/
│   ├── useUser.ts
│   └── usePosts.ts
├── lib/
│   ├── db.ts
│   ├── auth.ts
│   └── utils.ts
├── router.tsx
└── env.ts
```

## Route 파일 컨벤션

### Colocation Pattern

Route 파일 옆에 관련 파일들을 배치할 때 `-` prefix 사용:

```
routes/
├── posts.index.tsx
├── posts.index-components/
│   ├── PostCard.tsx
│   └── PostsList.tsx
├── posts.index-hooks/
│   └── usePosts.ts
├── posts.$postId.tsx
├── posts.$postId-components/
│   ├── PostHeader.tsx
│   └── CommentSection.tsx
└── posts.$postId-functions/
    ├── updatePost.ts
    └── deletePost.ts
```

**규칙**: `-components`, `-hooks`, `-functions` 접미사 사용

### ✅ 올바른 패턴

```typescript
// posts.index-functions/getPosts.ts
import { createServerFn } from '@tanstack/react-start'

export const getPosts = createServerFn({ method: 'GET' }).handler(
  async () => {
    return db.post.findMany()
  }
)

// posts.index-components/PostCard.tsx
export function PostCard({ post }: { post: Post }) {
  return <div>{post.title}</div>
}

// posts.index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPosts } from './posts.index-functions/getPosts'
import { PostCard } from './posts.index-components/PostCard'

export const Route = createFileRoute('/posts/')({
  loader: async () => {
    const posts = await getPosts()
    return { posts }
  },
  component: PostsList,
})

function PostsList() {
  const { posts } = Route.useLoaderData()
  return (
    <div>
      {posts.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

### ❌ 잘못된 패턴

```
routes/
├── posts.index.tsx
├── PostCard.tsx  ❌ Route 파일과 혼재
└── getPosts.ts   ❌ 명확한 분류 없음
```

</file_structure>

---

<dos_donts>

## Do's

| 패턴 | 예시 |
|------|------|
| **✅ .inputValidator() 사용** | `createServerFn({ method: 'POST' }).inputValidator(schema)` |
| **✅ Middleware로 인증** | `.middleware([authMiddleware])` |
| **✅ Helper functions 분리** | `import 'server-only'` + 별도 파일 |
| **✅ TanStack Query로 호출** | `useSuspenseQuery`, `useMutation` |
| **✅ beforeLoad로 guard** | `beforeLoad: async () => { if (!session) throw redirect() }` |
| **✅ Zod로 입력 검증** | `z.email()`, `z.url()`, `z.string().min()` |
| **✅ 명시적 return type** | `function getData(): Promise<User[]>` |
| **✅ Server env 분리** | Server: `process.env`, Client: `import.meta.env.VITE_*` |
| **✅ SWR caching 활용** | `staleTime`, `gcTime`, `shouldReload` 설정 |
| **✅ Streaming SSR** | `<Suspense>` + `useSuspenseQuery` |

## Don'ts

| 패턴 | 이유 |
|------|------|
| **❌ .validator() 사용** | Deprecated. `.inputValidator()` 사용 필수 |
| **❌ createAPIFileRoute()** | Deprecated. `createServerFileRoute().methods()` 사용 |
| **❌ @tanstack/start** | 패키지명 변경됨. `@tanstack/react-start` 사용 |
| **❌ Server Function에 민감 로직** | 클라이언트 번들 포함 위험. Helper 분리 |
| **❌ Server에서 import.meta.env** | 서버에서는 `process.env` 사용 |
| **❌ Client에서 process.env** | 클라이언트에서는 `import.meta.env.VITE_*` 사용 |
| **❌ verbatimModuleSyntax: true** | TanStack Start 호환성 문제 |
| **❌ gcTime: 0 남발** | 캐시 무효화. 신중히 사용 |
| **❌ any 타입** | Type safety 상실. `unknown` 또는 명시적 타입 |
| **❌ Route 파일에 비즈니스 로직** | 관심사 분리. `-functions/` 사용 |

## 마이그레이션 체크리스트

### v1.121.0+ 업데이트

| 변경 전 | 변경 후 |
|---------|---------|
| `import { createServerFn } from '@tanstack/start'` | `import { createServerFn } from '@tanstack/react-start'` |
| `.validator(schema)` | `.inputValidator(schema)` |
| `createAPIFileRoute('/api/users')` | `createServerFileRoute('/api/users').methods({ GET, POST })` |
| Vinxi config | Vite config (`vite.config.ts`) |

</dos_donts>

---

<quick_reference>

## Server Function 템플릿

```typescript
// GET
export const getData = createServerFn({ method: 'GET' })
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }) => {
    return await getDataFromDB(data.id)
  })

// POST
export const createData = createServerFn({ method: 'POST' })
  .inputValidator(z.object({ name: z.string() }))
  .middleware([authMiddleware])
  .handler(async ({ data, context }) => {
    return await createDataInDB({
      ...data,
      userId: context.user.id,
    })
  })

// PUT
export const updateData = createServerFn({ method: 'PUT' })
  .inputValidator(z.object({ id: z.string(), name: z.string() }))
  .middleware([authMiddleware])
  .handler(async ({ data }) => {
    return await updateDataInDB(data.id, data)
  })

// DELETE
export const deleteData = createServerFn({ method: 'DELETE' })
  .inputValidator(z.object({ id: z.string() }))
  .middleware([authMiddleware, adminMiddleware])
  .handler(async ({ data }) => {
    await deleteDataFromDB(data.id)
    return { success: true }
  })
```

## Route 템플릿

```typescript
// Basic Route
export const Route = createFileRoute('/path')({
  component: Component,
})

// Route with Loader
export const Route = createFileRoute('/path')({
  loader: async () => {
    const data = await getData()
    return { data }
  },
  component: Component,
})

// Route with Params
export const Route = createFileRoute('/path/$id')({
  loader: async ({ params }) => {
    const data = await getData({ data: { id: params.id } })
    return { data }
  },
  component: Component,
})

// Route with Search
export const Route = createFileRoute('/path')({
  validateSearch: z.object({
    q: z.string().optional(),
  }),
  loaderDeps: ({ search }) => ({ search }),
  loader: async ({ deps }) => {
    const results = await search(deps.search.q)
    return { results }
  },
  component: Component,
})

// Protected Route
export const Route = createFileRoute('/_auth/path')({
  beforeLoad: async ({ context }) => {
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })
    return { user: session.user }
  },
  component: Component,
})
```

## Middleware 템플릿

```typescript
// Auth Middleware
export const authMiddleware = createMiddleware().server(
  async ({ next }) => {
    const session = await getSession()
    if (!session) throw new Error('Unauthorized')
    return next({ context: { user: session.user } })
  }
)

// Validation Middleware
export const validateMiddleware = <T extends z.ZodType>(schema: T) =>
  createMiddleware().server(async ({ next, data }) => {
    const validated = schema.parse(data)
    return next({ context: { validated } })
  })

// Logging Middleware
export const loggingMiddleware = createMiddleware().server(
  async ({ next, method, url }) => {
    console.log(`[${method}] ${url}`)
    const result = await next()
    console.log(`[${method}] ${url} - Success`)
    return result
  }
)
```

## TanStack Query 템플릿

```typescript
// useSuspenseQuery (GET)
const { data } = useSuspenseQuery({
  queryKey: ['key', id],
  queryFn: () => getData({ data: { id } }),
})

// useMutation (POST/PUT/DELETE)
const mutation = useMutation({
  mutationFn: createData,
  onSuccess: (data) => {
    queryClient.invalidateQueries({ queryKey: ['key'] })
  },
})

mutation.mutate({ data: { name: 'value' } })
```

## Server Routes 템플릿

```typescript
// RESTful API
export const Route = createServerFileRoute('/api/resource/$id')
  .methods({
    GET: async ({ params }) => {
      const data = await getResource(params.id)
      return Response.json(data)
    },
    PUT: async ({ request, params }) => {
      const body = await request.json()
      const data = await updateResource(params.id, body)
      return Response.json(data)
    },
    DELETE: async ({ params }) => {
      await deleteResource(params.id)
      return Response.json({ success: true })
    },
  })
```

## Auth 템플릿

```typescript
// Auth Server Functions
export const signIn = createServerFn({ method: 'POST' })
  .inputValidator(z.object({ email: z.email(), password: z.string() }))
  .handler(async ({ data }) => {
    return await auth.api.signInEmail(data)
  })

export const getSession = createServerFn({ method: 'GET' })
  .handler(async () => {
    return await auth.api.getSession()
  })

// Protected Route
export const Route = createFileRoute('/_auth')({
  beforeLoad: async ({ location }) => {
    const session = await getSession()
    if (!session) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
    return { user: session.user }
  },
})
```

## Deployment 템플릿

### Cloudflare Workers

```typescript
// app/entry.server.tsx
export default {
  async fetch(request: Request, env: Env) {
    return handleRequest(request, { env })
  },
}
```

### Vercel

```json
// vercel.json
{
  "buildCommand": "npm run build",
  "framework": "vite"
}
```

### Netlify

```toml
# netlify.toml
[build]
  command = "npm run build"
  publish = "dist/public"

[[redirects]]
  from = "/*"
  to = "/.netlify/functions/server"
  status = 200
```

</quick_reference>

---

<version_info>

## 버전 정보

**현재 버전**: v1.x (RC, ~v1.159.x)

**주요 변경사항**:

| 버전 | 변경 내용 |
|------|-----------|
| v1.121.0+ | `@tanstack/start` → `@tanstack/react-start` 패키지명 변경 |
| v1.x | Vinxi → Vite 빌드 시스템 마이그레이션 |
| v1.x | `.validator()` → `.inputValidator()` (deprecated) |
| v1.x | `createAPIFileRoute()` → `createServerFileRoute().methods()` |
| v1.x | React 18+ or 19+ 지원 |
| v1.x | Vite 7+ 필수 |
| v1.x | Node.js >=22.12.0 필수 |

**Breaking Changes**:

1. **패키지명 변경**: `@tanstack/start` → `@tanstack/react-start`
2. **빌드 시스템**: Vinxi config → Vite config
3. **Validator API**: `.validator()` deprecated, `.inputValidator()` 사용
4. **Server Routes API**: `createAPIFileRoute()` deprecated, `createServerFileRoute().methods()` 사용

**마이그레이션 가이드**:

```bash
# 1. 패키지 업데이트
npm uninstall @tanstack/start
npm install @tanstack/react-start@latest

# 2. Import 변경
# Before: import { createServerFn } from '@tanstack/start'
# After:  import { createServerFn } from '@tanstack/react-start'

# 3. Validator 변경
# Before: .validator(schema)
# After:  .inputValidator(schema)

# 4. Server Routes 변경
# Before: createAPIFileRoute('/api/users')
# After:  createServerFileRoute('/api/users').methods({ GET, POST })

# 5. Vite config 생성
# vinxi.config.ts 삭제 → vite.config.ts 생성
```

**향후 계획**:

- **React Server Components**: v1.x에 non-breaking 방식으로 추가 예정
- **Static Server Functions**: Experimental 단계, 정식 지원 예정
- **v2.0**: Breaking changes 예정 (정확한 일정 미정)

**호환성**:

| 패키지 | 최소 버전 | 권장 버전 |
|--------|-----------|-----------|
| React | 18.0.0 | 19.x |
| Vite | 7.0.0 | 7.x |
| Node.js | 22.12.0 | 22.x LTS |
| TypeScript | 5.0.0 | 5.x |

**알려진 이슈**:

- `verbatimModuleSyntax: true` 사용 시 호환성 문제
- Full `strict` mode 대신 `strictNullChecks: true` 권장

**참고 자료**:

- Official Docs: https://tanstack.com/start
- GitHub: https://github.com/TanStack/router
- Discord: https://tanstack.com/discord

</version_info>
