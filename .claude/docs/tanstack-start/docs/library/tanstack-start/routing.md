# TanStack Start - Routing

> File-based routing with TanStack Router (v1.159.4)

---

<overview>

## File-based Routing

TanStack Start는 TanStack Router 위에 구축되어 있으며, Router의 모든 기능을 사용할 수 있습니다. 파일 시스템 구조로 라우팅이 자동 생성됩니다.

| 개념 | 설명 |
|------|------|
| **File-based** | 파일 경로 = URL 경로 |
| **Dynamic Routes** | `$param.tsx` = `/:param` |
| **Nested Routes** | 폴더 구조 = 계층 라우트 |
| **Server Routes** | API 엔드포인트 (Server Functions 대신) |
| **Loader** | 라우트 로드 시 데이터 사전 로드 |
| **SSR** | 서버 사이드 렌더링 옵션 (true/false/'data-only') |
| **Pathless Layout** | URL 경로 없이 레이아웃/로직 적용 |
| **Non-Nested** | 부모 경로에서 언네스팅 |
| **Grouped** | 디렉토리 그룹핑 (경로 계층 영향 없음) |

</overview>

---

<router_config>

## Router 설정

`src/router.tsx` 파일에서 라우터 동작을 설정합니다.

```typescript
// src/router.tsx
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

// 매번 새 router 인스턴스를 반환하는 함수 export
export function getRouter() {
  const router = createRouter({
    routeTree,
    scrollRestoration: true,
  })

  return router
}
```

> **참고:** `routeTree.gen.ts`는 `npm run dev` 또는 `npm run start` 실행 시 자동 생성됩니다. TanStack Start의 타입 안전성은 이 파일에 의존합니다.

</router_config>

---

<file_structure>

## 파일 구조 -> URL 매핑

| 파일 경로 | URL | 타입 |
|----------|-----|------|
| `routes/index.tsx` | `/` | Index Route |
| `routes/about.tsx` | `/about` | Static Route |
| `routes/posts.tsx` | `/posts` | "Layout" Route |
| `routes/posts/index.tsx` | `/posts/` | Index Route |
| `routes/posts/$postId.tsx` | `/posts/:postId` | Dynamic Route |
| `routes/rest/$.tsx` | `/rest/*` | Wildcard Route |
| `routes/__root.tsx` | - | Root layout (모든 라우트 부모) |
| `routes/_authed.tsx` | - | Pathless Layout (인증 레이아웃 등) |
| `routes/dashboard/_layout.tsx` | - | 중첩 레이아웃 |

### 라우트 타입 정리

| 타입 | 설명 | 예시 |
|------|------|------|
| **Index Routes** | URL이 정확히 일치 | `index.tsx` |
| **Dynamic Routes** | URL 일부를 변수로 캡처 | `$postId.tsx` |
| **Wildcard/Splat** | URL 전체를 캡처 | `$.tsx` |
| **Pathless Layout** | URL 없이 레이아웃 적용 | `_authed.tsx` |
| **Non-Nested** | 부모에서 독립 | 별도 컴포넌트 트리 |
| **Grouped** | 디렉토리 정리용 | 경로 계층 영향 없음 |

</file_structure>

---

<root_route>

## Root Route (__root.tsx)

Root Route는 라우트 트리 최상위이며, 모든 라우트를 감쌉니다.

```tsx
// src/routes/__root.tsx
import type { ReactNode } from 'react'
import {
  Outlet,
  createRootRoute,
  HeadContent,
  Scripts,
} from '@tanstack/react-router'

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { title: 'TanStack Start Starter' },
    ],
  }),
  component: RootComponent,
})

function RootComponent() {
  return (
    <RootDocument>
      <Outlet />
    </RootDocument>
  )
}

function RootDocument({ children }: Readonly<{ children: ReactNode }>) {
  return (
    <html>
      <head>
        <HeadContent />
      </head>
      <body>
        {children}
        <Scripts />
      </body>
    </html>
  )
}
```

**특징:**
- 경로 없음 - **항상** 매칭
- 컴포넌트가 **항상** 렌더링
- document shell (`<html>`, `<body>`) 렌더링 장소
- 전역 로직 처리에 적합

**핵심 컴포넌트:**
| 컴포넌트 | 위치 | 역할 |
|---------|------|------|
| `<HeadContent />` | `<head>` 안 | head/title/meta/link/script 렌더링 |
| `<Outlet />` | 어디든 | 다음 매칭 자식 라우트 렌더링 |
| `<Scripts />` | `<body>` 안 | 클라이언트 JavaScript 로드 (필수) |

</root_route>

---

<basic_routes>

## 기본 라우트

### 정적 라우트

```tsx
// routes/about.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/about')({
  component: AboutPage,
})

const AboutPage = (): JSX.Element => {
  return (
    <div>
      <h1>About</h1>
      <p>This is the about page</p>
    </div>
  )
}
```

### 인덱스 라우트

```tsx
// routes/index.tsx
export const Route = createFileRoute('/')({
  component: HomePage,
})

const HomePage = (): JSX.Element => {
  return <h1>Welcome Home</h1>
}
```

> **참고:** `createFileRoute`에 전달하는 경로 문자열은 TanStack Router Bundler Plugin이 **자동으로 작성/관리**합니다. 파일 이동이나 이름 변경 시 자동 업데이트됩니다.

</basic_routes>

---

<nested_routing>

## 중첩 라우팅 (Nested Routing)

TanStack Router는 URL을 올바른 컴포넌트 트리에 매칭합니다.

```
routes/
├── __root.tsx        # <Root> 렌더링
├── posts.tsx         # <Posts> 렌더링
├── posts/$postId.tsx # <Post> 렌더링
```

URL: `/posts/123` -> 컴포넌트 트리:

```
<Root>
  <Posts>
    <Post />
  </Posts>
</Root>
```

</nested_routing>

---

<loaders>

## Loader: 데이터 사전 로드

### 기본 Loader

```tsx
// routes/posts/index.tsx
export const Route = createFileRoute('/posts')({
  loader: async (): Promise<{ posts: Post[] }> => {
    const posts = await getPosts()
    return { posts }
  },
  component: PostsPage,
})

const PostsPage = (): JSX.Element => {
  const { posts } = Route.useLoaderData()

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>
          <h2>{post.title}</h2>
        </li>
      ))}
    </ul>
  )
}
```

### Server Function으로 데이터 로드

```tsx
export const Route = createFileRoute('/dashboard')({
  loader: async (): Promise<{ dashboard: DashboardData }> => {
    const dashboard = await getDashboardData()
    return { dashboard }
  },
  component: DashboardPage,
})
```

### 로더에서 에러 처리

```tsx
export const Route = createFileRoute('/items/$id')({
  loader: async ({ params }): Promise<{ item: Item }> => {
    try {
      const item = await getItemById(params.id)
      if (!item) {
        throw new Error('Item not found')
      }
      return { item }
    } catch (error) {
      throw redirect({ to: '/items' })
    }
  },
  component: ItemDetailPage,
})
```

</loaders>

---

<dynamic_routes>

## 동적 라우트 ($param)

### 단일 파라미터

```tsx
// routes/users/$id.tsx
export const Route = createFileRoute('/users/$id')({
  loader: async ({ params }): Promise<{ user: User }> => {
    const user = await getUserById(params.id)
    if (!user) {
      throw redirect({ to: '/users' })
    }
    return { user }
  },
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const { user } = Route.useLoaderData()
  const { id } = Route.useParams()

  return (
    <div>
      <h1>{user.name}</h1>
      <p>ID: {id}</p>
    </div>
  )
}
```

### 다중 파라미터

```tsx
// routes/blog/$year/$month/$day.tsx
export const Route = createFileRoute('/blog/$year/$month/$day')({
  loader: async ({ params }): Promise<{ posts: Post[] }> => {
    const posts = await getPostsByDate(params.year, params.month, params.day)
    return { posts }
  },
  component: BlogArchivePage,
})
```

### Catch-all ($.tsx)

```tsx
// routes/search/$.tsx
export const Route = createFileRoute('/search/$')({
  loader: async ({ params }): Promise<{ query: string }> => {
    return { query: params._ }
  },
  component: SearchPage,
})
```

</dynamic_routes>

---

<ssr_options>

## SSR (Server-Side Rendering) 옵션

### Selective SSR

`ssr` 속성으로 라우트별 SSR 동작을 제어합니다. 기본값은 `true`입니다.

```typescript
// src/start.ts에서 전역 기본값 변경 가능
import { createStart } from '@tanstack/react-start'

export const startInstance = createStart(() => ({
  defaultSsr: false,  // 기본적으로 SSR 비활성화
}))
```

### ssr: true (기본값)

초기 요청 시:
1. `beforeLoad` 서버에서 실행, context를 클라이언트에 전송
2. `loader` 서버에서 실행, 데이터를 클라이언트에 전송
3. 컴포넌트 서버에서 렌더링, HTML을 클라이언트에 전송

```tsx
export const Route = createFileRoute('/products')({
  ssr: true,  // 기본값 (생략 가능)
  loader: async () => {
    const products = await getProducts()
    return { products }
  },
  component: ProductsPage,
})
```

### ssr: false

서버 사이드 `beforeLoad`/`loader` 실행 및 컴포넌트 렌더링 비활성화.

```tsx
export const Route = createFileRoute('/dashboard')({
  ssr: false,  // 클라이언트에서만 렌더링
  beforeLoad: () => {
    console.log('클라이언트 hydration 중에만 실행')
  },
  component: DashboardPage,
})
// 인증 필요한 페이지, 브라우저 전용 API 사용 시 적합
```

### ssr: 'data-only'

`beforeLoad`와 `loader`는 서버에서 실행하지만, 컴포넌트 렌더링은 클라이언트에서만.

```tsx
export const Route = createFileRoute('/items')({
  ssr: 'data-only',
  loader: async () => {
    // 서버에서 실행 (DB 접근 가능)
    const items = await getItems()
    return { items }
  },
  component: ItemsPage,
})
// 무거운 컴포넌트 + 서버 데이터 조합에 적합
```

</ssr_options>

---

<before_load>

## beforeLoad: 라우트 진입 전 검증

### 인증 체크

```tsx
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ location }): Promise<{ user: User }> => {
    const user = await getCurrentUser()

    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
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

### 권한 체크

```tsx
export const Route = createFileRoute('/admin')({
  beforeLoad: async ({ context }): Promise<{ user: User }> => {
    const user = await getCurrentUser()

    if (!user || user.role !== 'ADMIN') {
      throw redirect({ to: '/' })
    }

    return { user }
  },
  component: AdminPage,
})
```

### 데이터 검증

```tsx
export const Route = createFileRoute('/items/$id')({
  beforeLoad: async ({ params }): Promise<{ valid: boolean }> => {
    const isValidId = await validateItemId(params.id)

    if (!isValidId) {
      throw redirect({ to: '/items' })
    }

    return { valid: true }
  },
  loader: async ({ params }) => {
    // beforeLoad가 성공한 후 실행
    return { item: await getItemById(params.id) }
  },
  component: ItemDetailPage,
})
```

</before_load>

---

<server_routes>

## Server Routes: API 엔드포인트

**주의:** Server Functions 사용 권장. Server Routes는 복잡한 요청/응답이 필요할 때만 사용.

### 기본 Server Route

```tsx
// routes/api/hello.tsx
export const Route = createFileRoute('/api/hello')({
  server: {
    handlers: {
      GET: async (): Promise<Response> => {
        return new Response('Hello World', {
          headers: { 'Content-Type': 'text/plain' },
        })
      },
    },
  },
})
```

### 여러 메서드

```tsx
export const Route = createFileRoute('/api/users')({
  server: {
    handlers: {
      GET: async (): Promise<Response> => {
        const users = await prisma.user.findMany()
        return Response.json(users)
      },
      POST: async ({ request }): Promise<Response> => {
        const body = await request.json()
        const user = await prisma.user.create({ data: body })
        return Response.json(user, { status: 201 })
      },
    },
  },
})
```

### 미들웨어 + Server Route

```tsx
export const Route = createFileRoute('/api/protected')({
  server: {
    middleware: [authMiddleware, adminMiddleware],
    handlers: {
      GET: async ({ request }): Promise<Response> => {
        return Response.json({ data: 'admin only' })
      },
    },
  },
})
```

</server_routes>

---

<catch_all>

## Catch-all Route (404)

```tsx
// routes/$.tsx
export const Route = createFileRoute('/$')({
  component: NotFoundPage,
})

const NotFoundPage = (): JSX.Element => {
  const { _splat } = Route.useParams()

  return (
    <div style={{ textAlign: 'center', padding: '2rem' }}>
      <h1>404 - Page Not Found</h1>
      <p>The page "{_splat}" does not exist.</p>
      <a href="/">Go Home</a>
    </div>
  )
}
```

### Error Boundary

```tsx
// routes/__root.tsx
export const Route = createRootRoute({
  component: RootLayout,
  errorComponent: ({ error }) => (
    <div>
      <h1>Error</h1>
      <p>{error.message}</p>
    </div>
  ),
})
```

</catch_all>

---

<nested_layouts>

## 중첩 레이아웃

### Pathless Layout (_authed 패턴)

URL 경로에 영향 없이 레이아웃과 로직을 그룹에 적용:

```tsx
// routes/_authed.tsx (pathless layout - URL에 _authed 없음)
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }) => {
    const user = await getCurrentUser()
    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }
    return { user }
  },
  component: AuthedLayout,
})

function AuthedLayout() {
  return (
    <div>
      <Outlet />
    </div>
  )
}

// routes/_authed/dashboard.tsx -> /dashboard
export const Route = createFileRoute('/_authed/dashboard')({
  component: DashboardPage,
})

// routes/_authed/settings.tsx -> /settings
export const Route = createFileRoute('/_authed/settings')({
  component: SettingsPage,
})
```

### 중첩 레이아웃 (Dashboard)

```tsx
// routes/dashboard/_layout.tsx
export const Route = createFileRoute('/dashboard')({
  component: DashboardLayout,
  loader: async () => {
    const user = await getCurrentUser()
    return { user }
  },
})

const DashboardLayout = (): JSX.Element => {
  const { user } = Route.useLoaderData()

  return (
    <div style={{ display: 'flex' }}>
      <aside>
        <p>Welcome, {user.name}</p>
      </aside>
      <main>
        <Outlet />
      </main>
    </div>
  )
}

// routes/dashboard/index.tsx
export const Route = createFileRoute('/dashboard/')({
  component: () => <h1>Dashboard Home</h1>,
})

// routes/dashboard/analytics.tsx
export const Route = createFileRoute('/dashboard/analytics')({
  component: () => <h1>Analytics</h1>,
})
```

### Context 전달

```tsx
// 부모 라우트의 loader/beforeLoad에서 반환한 데이터는
// 자식 라우트에서 useRouteContext()로 접근 가능
const DashboardPage = (): JSX.Element => {
  const { user } = Route.useRouteContext()
  return <h1>Welcome, {user.name}!</h1>
}
```

</nested_layouts>

---

<search_params>

## Search Parameters (Query String)

```tsx
// routes/search.tsx
export const Route = createFileRoute('/search')({
  validateSearch: (search): { q: string; page: number } => {
    return {
      q: (search.q as string) || '',
      page: (search.page as number) || 1,
    }
  },
  loader: async ({ search }) => {
    const results = await searchItems(search.q, search.page)
    return { results }
  },
  component: SearchPage,
})

const SearchPage = (): JSX.Element => {
  const navigate = useNavigate({ from: '/search' })
  const search = Route.useSearch()
  const { results } = Route.useLoaderData()

  return (
    <div>
      <input
        value={search.q}
        onChange={(e) => {
          navigate({
            search: { q: e.target.value, page: 1 },
          })
        }}
      />
      <div>Page: {search.page}</div>
    </div>
  )
}
```

</search_params>

---

<navigation>

## 네비게이션

```tsx
import { Link, useNavigate } from '@tanstack/react-router'

// Link 컴포넌트
const HomePage = (): JSX.Element => {
  return (
    <div>
      <Link to="/about">About</Link>
      <Link to="/users/$id" params={{ id: '123' }}>
        User Detail
      </Link>
    </div>
  )
}

// useNavigate 훅
const LoginPage = (): JSX.Element => {
  const navigate = useNavigate()

  const handleLogin = () => {
    navigate({ to: '/dashboard' })
  }

  return <button onClick={handleLogin}>Login</button>
}
```

</navigation>

---

<project_structure>

## 권장 프로젝트 구조

```
src/
├── routes/
│   ├── __root.tsx              # Root layout (html/body/scripts)
│   ├── index.tsx               # /
│   ├── $.tsx                   # Catch-all (404)
│   ├── about.tsx               # /about
│   ├── _authed.tsx             # Pathless layout (인증 필요 페이지)
│   ├── _authed/
│   │   ├── dashboard.tsx       # /dashboard (인증 필요)
│   │   └── settings.tsx        # /settings (인증 필요)
│   ├── api/
│   │   └── hello.tsx           # /api/hello (Server Routes)
│   ├── users/
│   │   ├── index.tsx           # /users
│   │   ├── $id.tsx             # /users/:id
│   │   └── -components/        # 페이지 전용
│   └── dashboard/
│       ├── _layout.tsx         # 레이아웃
│       ├── index.tsx           # /dashboard
│       └── analytics.tsx       # /dashboard/analytics
├── router.tsx                   # Router 설정
├── routeTree.gen.ts             # 자동 생성
├── functions/                   # 공통 Server Functions
├── middleware/                  # 공통 Middleware
└── components/
```

</project_structure>

---

<version_info>

**Version:** TanStack Start/Router v1.159.4

**Key Features:**
- File-based routing (zero-config, 자동 경로 관리)
- Type-safe route parameters (routeTree.gen.ts 기반)
- Selective SSR (true/false/'data-only', 라우트별 설정)
- createStart에서 defaultSsr 전역 설정
- beforeLoad for auth/validation
- Server Routes for API endpoints (메서드별 미들웨어 가능)
- Nested layouts, Pathless layouts, Grouped routes
- HeadContent/Scripts 컴포넌트 (Root Route 필수)
- scrollRestoration 기본 지원

</version_info>
