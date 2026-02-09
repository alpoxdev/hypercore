# TanStack Router - Route Context

> TanStack Router v1.159.4

Route context로 라우트 간 상태 공유. 인증, 권한, 사용자 정보, 의존성 주입 등.

---

<context_fundamentals>

## Context 기본 개념

Context는 라우트를 통해 전달되는 공유 상태. 인증, 쿼리 클라이언트, 권한 등에 활용.

### 3가지 Context 레벨

| 레벨 | 정의 위치 | 사용 범위 | 타입 |
|------|----------|---------|------|
| Root Context | `createRootRouteWithContext<T>()` | 모든 라우트 | 필수 |
| Route Context | `beforeLoad` 반환값 | 해당 라우트 + 자식 | 선택 |
| Pathless Layout | `beforeLoad` + `_authed/` | 자식 라우트만 | 선택 |

### 주요 활용 사례

- **의존성 주입**: 데이터 페칭 함수, 쿼리 클라이언트, 뮤테이션 서비스 등
- **빵 부스러기 (Breadcrumbs)**: 각 라우트에 제목/메타 정보 첨부
- **동적 메타 태그**: 라우트별 title, description 관리
- **인증/권한**: 사용자 정보와 권한 전파

</context_fundamentals>

---

<root_context>

## Root Context: 전역 상태

Router 초기화 시 모든 라우트에서 접근 가능한 context.

### 타입 정의

```tsx
// /src/lib/router-context.ts
import { QueryClient } from '@tanstack/react-query'
import { User } from '@/lib/auth'

export interface RouterContext {
  queryClient: QueryClient
  auth: {
    isAuthenticated: boolean
    user: User | null
    permissions: string[]
  }
}
```

> RouterContext에는 `createRouter`에 직접 전달되는 내용만 포함. beforeLoad에서 추가되는 context는 자동 추론됨.

### Root Route 정의

```tsx
// /src/routes/__root.tsx
import { createRootRouteWithContext } from '@tanstack/react-router'
import { RouterContext } from '@/lib/router-context'

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
  notFoundComponent: NotFound,
})
// 주의: createRootRouteWithContext는 팩토리 함수라 ()() 이중 호출 필요

const RootLayout = () => (
  <div>
    <nav>{/* ... */}</nav>
    <main>
      <Outlet />
    </main>
  </div>
)
```

### Router 초기화

```tsx
// /src/main.tsx
import { QueryClient } from '@tanstack/react-query'
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'
import { RouterContext } from '@/lib/router-context'
import { getCurrentUser } from '@/lib/auth'

const queryClient = new QueryClient()

// 초기 context 설정
const initialContext: RouterContext = {
  queryClient,
  auth: {
    isAuthenticated: false,
    user: null,
    permissions: [],
  }
}

const router = createRouter({
  routeTree,
  context: initialContext,
})

// 초기 인증 상태 로드
const user = await getCurrentUser()
if (user) {
  router.context = {
    ...router.context,
    auth: {
      isAuthenticated: true,
      user,
      permissions: user.permissions,
    },
  }
}

createRoot(document.getElementById('root')).render(
  <RouterProvider router={router} />
)
```

### RouterProvider에서 context 주입 (React 훅 사용)

React 훅을 beforeLoad/loader에서 쓸 수 없으므로, RouterProvider의 `context` prop으로 주입.

```tsx
// /src/router.tsx
const router = createRouter({
  routeTree,
  context: {
    networkStrength: undefined!,  // React에서 나중에 설정
  },
})

// /src/main.tsx
import { useNetworkStrength } from '@/hooks/useNetworkStrength'

function App() {
  const networkStrength = useNetworkStrength()
  // 훅 결과를 context로 주입
  return <RouterProvider router={router} context={{ networkStrength }} />
}
```

```tsx
// /src/routes/posts.tsx
export const Route = createFileRoute('/posts')({
  loader: ({ context }) => {
    if (context.networkStrength === 'STRONG') {
      // 고해상도 데이터 로드
    }
  },
})
```

### Root Context 접근

```tsx
// 모든 라우트에서 접근 가능
const Dashboard = () => {
  const { user, permissions } = Route.useRouteContext()

  return (
    <div>
      <h1>Welcome, {user?.name}!</h1>
      {permissions.includes('admin') && <AdminPanel />}
    </div>
  )
}
```

</root_context>

---

<route_context>

## Route Context: 라우트 레벨 상태

특정 라우트에서 beforeLoad로 context 추가. 자식 라우트도 접근 가능.

### beforeLoad에서 Context 생성

```tsx
// /src/routes/dashboard.tsx
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context, location }) => {
    // 인증 확인
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }

    // 라우트 특화 context 추가
    const userPermissions = await fetchPermissions(context.auth.user!.id)
    const dashboardConfig = await fetchConfig()

    return {
      userPermissions,
      dashboardConfig,
    }
  },
  loader: async ({ context }) => {
    // beforeLoad의 context 사용
    const data = await fetchDashboardData(context.userPermissions)
    return { data }
  },
  component: DashboardPage,
})

const DashboardPage = () => {
  // context 접근
  const { userPermissions, dashboardConfig } = Route.useRouteContext()

  return (
    <div>
      {userPermissions.includes('edit') && <EditButton />}
    </div>
  )
}
```

### 부모 Context 확장 (누적)

context는 라우트 트리를 따라 merge됨. 각 라우트에서 추가한 context가 자식에 전파.

```tsx
// /src/routes/_authed.tsx (parent)
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ context }) => ({
    user: await getCurrentUser(),
  }),
  component: () => <Outlet />,
})

// /src/routes/_authed/dashboard.tsx (child)
export const Route = createFileRoute('/_authed/dashboard')({
  beforeLoad: async ({ context }) => ({
    // 부모의 context + 추가 context
    dashboardData: await fetchDashboard(context.user.id),
  }),
  component: Dashboard,
})

const Dashboard = () => {
  // 부모 + 자신의 context 모두 접근
  const { user, dashboardData } = Route.useRouteContext()

  return <div>User: {user.name}, Data: {dashboardData}</div>
}
```

### 의존성 주입 패턴

```tsx
// /src/routes/__root.tsx
export const Route = createRootRouteWithContext<{
  fetchPosts: typeof fetchPosts
  queryClient: QueryClient
}>()({
  component: App,
})

// /src/routes/posts.tsx
export const Route = createFileRoute('/posts')({
  loader: ({ context: { fetchPosts } }) => fetchPosts(),
})

// /src/routes/todos.tsx (TanStack Query와 함께)
export const Route = createFileRoute('/todos')({
  loader: async ({ context }) => {
    await context.queryClient.ensureQueryData({
      queryKey: ['todos'],
      queryFn: fetchTodos,
    })
  },
})
```

</route_context>

---

<pathless_layout>

## Pathless Layout (_authed/): 인증 보호 그룹

_로 시작하는 레이아웃은 URL에 반영되지 않음. 인증, 권한 보호에 활용.

### 구조

```
routes/
├── __root.tsx              # Root layout
├── _authed.tsx             # Protected layout (경로 없음)
├── _authed/
│   ├── dashboard.tsx       # /dashboard (protected)
│   ├── settings.tsx        # /settings (protected)
│   └── profile.tsx         # /profile (protected)
├── index.tsx               # / (public)
├── login.tsx               # /login (public)
└── $.tsx                   # Catch-all
```

### 구현

```tsx
// /src/routes/_authed.tsx
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ context, location }) => {
    // 인증 확인
    const user = await getCurrentUser()

    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },  // 로그인 후 돌아올 경로
      })
    }

    // Context에 user 추가
    return { user }
  },
  // Outlet으로 자식 라우트 렌더링
  component: () => <Outlet />,
})

// /src/routes/_authed/dashboard.tsx
export const Route = createFileRoute('/_authed/dashboard')({
  component: Dashboard,
})

const Dashboard = () => {
  // 부모 _authed에서 전달된 user 접근
  const { user } = Route.useRouteContext()

  return <h1>Welcome, {user.name}!</h1>
}

// /src/routes/_authed/settings.tsx
export const Route = createFileRoute('/_authed/settings')({
  component: Settings,
})

const Settings = () => {
  const { user } = Route.useRouteContext()

  return (
    <div>
      <h1>Settings for {user.email}</h1>
    </div>
  )
}
```

### 공개 라우트

```tsx
// /src/routes/index.tsx (public, 인증 불필요)
export const Route = createFileRoute('/')({
  component: HomePage,
})

// /src/routes/login.tsx (public)
export const Route = createFileRoute('/login')({
  component: LoginPage,
})

const LoginPage = () => {
  const navigate = useNavigate()
  const searchParams = useSearch({ strict: false })

  const handleLogin = async (credentials) => {
    await authenticate(credentials)

    // 로그인 후 리다이렉트 (redirect 파라미터 사용)
    navigate({
      to: searchParams.redirect ?? '/dashboard',
    })
  }

  return <LoginForm onSubmit={handleLogin} />
}
```

</pathless_layout>

---

<before_load>

## beforeLoad: Context 추가 시점

beforeLoad는 loader 전에 실행. Context 추가에 최적.

### 실행 순서

```
1. beforeLoad() 실행 (Serial, Top-Down)
   |- context 접근 (Root + 부모 beforeLoad context)
   |- location 접근
   |- search 접근
   +- context 추가 반환
      |
2. loader() 실행 (Parallel)
   |- 추가된 context 사용
   +- 데이터 반환
      |
3. component 렌더링
   |- Route.useRouteContext() 사용
   +- loader 데이터 사용
```

### beforeLoad 파라미터

```typescript
interface BeforeLoadParams {
  context: RouterContext     // Root + 부모 context
  location: Location         // 현재 위치 정보
  search: SearchParams       // 검증된 search params
  params: PathParams         // 경로 파라미터
  cause: 'enter' | 'stay'   // 진입 원인
  abortController: AbortController
}
```

### beforeLoad에서 인증 체크

```tsx
export const Route = createFileRoute('/admin')({
  beforeLoad: async ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }

    if (!context.auth.permissions.includes('admin')) {
      throw new Error('Access denied')
    }

    // 추가 context
    const adminData = await fetchAdminData()

    return { adminData }
  },
  loader: async ({ context }) => {
    // beforeLoad에서 추가된 adminData 사용
    return fetchFullAdminPanel(context.adminData)
  },
  component: AdminPanel,
})
```

### 검색 쿼리 기반 Context

```tsx
export const Route = createFileRoute('/posts')({
  beforeLoad: async ({ search, context }) => {
    // Search params 기반 context
    const filters = {
      category: search.category ?? 'all',
      sort: search.sort ?? 'newest',
    }

    return { filters }
  },
  loader: async ({ context }) => {
    // context.filters로 필터링
    return fetchPosts(context.filters)
  },
  component: Posts,
})
```

</before_load>

---

<context_access>

## Context 접근 방법

| 위치 | 접근 방법 | 접근 가능 |
|------|----------|---------|
| `beforeLoad()` | `{ context }` 파라미터 | Root context + 부모 beforeLoad context |
| `loader()` | `{ context }` 파라미터 | Root + Route context (beforeLoad 포함) |
| `component` | `Route.useRouteContext()` | Root + Route context |
| 다른 라우트 | `useRouterState()` | Root context만 |

### Component에서 접근

```tsx
const Page = () => {
  // 현재 라우트 context (Root + Route-specific)
  const context = Route.useRouteContext()

  return <div>{context.user?.name}</div>
}
```

### Loader에서 접근

```tsx
export const Route = createFileRoute('/posts')({
  loader: async ({ context }) => {
    // Root context + 부모 beforeLoad context
    console.log(context.queryClient)    // Root
    console.log(context.user)           // 부모 beforeLoad에서 추가됨
    return fetchPosts()
  },
  component: Posts,
})
```

### 누적 Context로 Breadcrumb 생성

```tsx
// /src/routes/__root.tsx
export const Route = createRootRoute({
  component: () => {
    const matches = useRouterState({ select: s => s.matches })

    const breadcrumbs = matches
      .filter(match => match.context.getTitle)
      .map(({ pathname, context }) => ({
        title: context.getTitle(),
        path: pathname,
      }))

    return (
      <div>
        <nav>{breadcrumbs.map(b => (
          <Link key={b.path} to={b.path}>{b.title}</Link>
        ))}</nav>
        <Outlet />
      </div>
    )
  },
})
```

### 동적 타이틀 관리

```tsx
export const Route = createRootRoute({
  component: () => {
    const matches = useRouterState({ select: s => s.matches })

    const matchWithTitle = [...matches]
      .reverse()
      .find(d => d.context.getTitle)

    const title = matchWithTitle?.context.getTitle() || 'My App'

    return (
      <html>
        <head>
          <title>{title}</title>
        </head>
        <body>
          <Outlet />
        </body>
      </html>
    )
  },
})
```

</context_access>

---

<redirect>

## redirect(): 조건부 리다이렉트

beforeLoad에서 throw하여 즉시 리다이렉트.

### 기본 사용

```tsx
import { redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login' })
    }
  },
  component: Dashboard,
})
```

### 리다이렉트 후 돌아오기

```tsx
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({
        to: '/login',
        // Search params에 현재 경로 저장
        search: { redirect: location.href },
      })
    }
  },
  component: () => <Outlet />,
})

// /src/routes/login.tsx
export const Route = createFileRoute('/login')({
  component: LoginPage,
})

const LoginPage = () => {
  const navigate = useNavigate()
  const { redirect: redirectPath } = useSearch()

  const handleLogin = async (credentials) => {
    await authenticate(credentials)

    // 원래 경로로 리다이렉트
    navigate({ to: redirectPath ?? '/dashboard' })
  }

  return <LoginForm onSubmit={handleLogin} />
}
```

### Params와 Search 함께 사용

```tsx
throw redirect({
  to: '/posts/$postId',
  params: { postId: '123' },
  search: { tab: 'comments' },
})
```

### History Replace

```tsx
// 브라우저 히스토리에 남지 않음 (뒤로 가기 시 이전 페이지로)
throw redirect({
  to: '/login',
  replace: true,
})
```

### 조건부 리다이렉트

```tsx
export const Route = createFileRoute('/posts/$postId')({
  beforeLoad: async ({ params, context }) => {
    // 삭제된 포스트: 목록으로
    const post = await getPost(params.postId)
    if (post.isDeleted) {
      throw redirect({ to: '/posts' })
    }

    // 비공개 포스트 + 소유자 아님: 홈으로
    if (!post.isPublished && post.ownerId !== context.auth.user?.id) {
      throw redirect({ to: '/' })
    }

    return { post }
  },
  component: PostDetail,
})
```

</redirect>

---

<auth_example>

## 실전 예시: Better Auth 통합

Better Auth와 Route Context 통합.

### Context 타입

```tsx
// /src/lib/router-context.ts
import { QueryClient } from '@tanstack/react-query'
import { User, Session } from 'better-auth'

export interface RouterContext {
  queryClient: QueryClient
  auth: {
    isAuthenticated: boolean
    user: User | null
    session: Session | null
  }
}
```

### Root Route

```tsx
// /src/routes/__root.tsx
import { createRootRouteWithContext } from '@tanstack/react-router'
import { RouterContext } from '@/lib/router-context'

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
})

const RootLayout = () => (
  <div>
    <Header />
    <Outlet />
  </div>
)

const Header = () => {
  const { user } = Route.useRouteContext()

  return (
    <header>
      {user && <span>Logged in as {user.email}</span>}
    </header>
  )
}
```

### Protected Layout

```tsx
// /src/routes/_authed.tsx
import { redirect } from '@tanstack/react-router'
import { authClient } from '@/lib/auth-client'

export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ context, location }) => {
    // Better Auth로 세션 확인
    const session = await authClient.getSession()

    if (!session) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }

    // Context 업데이트
    context.auth = {
      isAuthenticated: true,
      user: session.user,
      session,
    }

    return {}
  },
  component: () => <Outlet />,
})
```

### Protected Route

```tsx
// /src/routes/_authed/dashboard.tsx
export const Route = createFileRoute('/_authed/dashboard')({
  component: Dashboard,
})

const Dashboard = () => {
  const { user } = Route.useRouteContext()

  return (
    <div>
      <h1>Welcome, {user.name || user.email}!</h1>
      <Link to="/logout">Logout</Link>
    </div>
  )
}
```

### Router 초기화

```tsx
// /src/main.tsx
import { QueryClient } from '@tanstack/react-query'
import { createRouter } from '@tanstack/react-router'
import { authClient } from '@/lib/auth-client'
import { routeTree } from './routeTree.gen'
import { RouterContext } from '@/lib/router-context'

const queryClient = new QueryClient()

// 초기 컨텍스트
const initialContext: RouterContext = {
  queryClient,
  auth: {
    isAuthenticated: false,
    user: null,
    session: null,
  }
}

const router = createRouter({
  routeTree,
  context: initialContext,
})

// 세션 로드
const session = await authClient.getSession()
if (session) {
  router.context = {
    ...router.context,
    auth: {
      isAuthenticated: true,
      user: session.user,
      session,
    }
  }
}

createRoot(document.getElementById('root')).render(
  <RouterProvider router={router} />
)
```

</auth_example>

---

<router_invalidate>

## router.invalidate(): Context 재설정

인증 상태 변경 시 라우터 상태 갱신. 모든 활성 라우트의 loader를 즉시 재실행하고 캐시를 stale로 표시.

### 로그인 후

```tsx
const LoginPage = () => {
  const router = useRouter()
  const navigate = useNavigate()

  const handleLogin = async (credentials) => {
    await authenticate(credentials)

    // 라우터 context 갱신 (loader와 beforeLoad 재실행)
    await router.invalidate()

    // 대시보드로 이동
    navigate({ to: '/dashboard' })
  }

  return <LoginForm onSubmit={handleLogin} />
}
```

### 로그아웃 후

```tsx
const LogoutButton = () => {
  const router = useRouter()
  const navigate = useNavigate()

  const handleLogout = async () => {
    await logout()

    // Context 갱신
    router.context = {
      ...router.context,
      auth: {
        isAuthenticated: false,
        user: null,
        session: null,
      }
    }

    // 라우터 상태 갱신
    await router.invalidate()

    // 홈으로 이동
    navigate({ to: '/' })
  }

  return <button onClick={handleLogout}>Logout</button>
}
```

### 인증 상태 변경 감지

```tsx
function useAuth() {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged(user => {
      setUser(user)
      router.invalidate()  // 인증 변경 시 라우터 갱신
    })

    return unsubscribe
  }, [])

  return user
}
```

</router_invalidate>

---

<dos_donts>

## Do's & Don'ts

| Do | Don't |
|-------|---------|
| `createRootRouteWithContext<T>()` | context 없이 root 생성 |
| `beforeLoad`에서 인증 체크 | `component`에서 try-catch |
| `_authed/` layout으로 그룹 보호 | 모든 라우트에 인증 로직 중복 |
| `redirect()` throw | `navigate()`로 리다이렉트 |
| `beforeLoad`에서 context 추가 | `loader`에서 context 추가 |
| `Route.useRouteContext()` | 글로벌 상태로 context 관리 |
| Root context 최소화 | Root에 모든 상태 넣기 |
| Route-specific context 사용 | 모든 context Root에 정의 |
| RouterProvider context로 React 훅 주입 | beforeLoad에서 React 훅 호출 |
| `router.invalidate()` 인증 변경 시 | 수동으로 context 동기화 |
| `()()` 이중 호출 (팩토리 패턴) | `createRootRouteWithContext<T>()` 단일 호출 |

</dos_donts>
