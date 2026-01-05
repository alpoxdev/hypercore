# TanStack Router - Route Context

beforeLoad, context, protected routes 구현.

## beforeLoad

라우트 로드 전 실행. 인증 체크, 리다이렉트, context 추가.

```tsx
import { createFileRoute, redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context, location }) => {
    // context에서 인증 상태 확인
    if (!context.auth.isAuthenticated) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }

    // 추가 context 반환 (loader에서 사용 가능)
    return {
      userPermissions: await fetchPermissions(context.auth.user.id),
    }
  },
  loader: async ({ context }) => {
    // beforeLoad에서 반환한 context 사용
    return fetchDashboardData(context.userPermissions)
  },
  component: DashboardPage,
})
```

## Protected Routes (Layout)

pathless layout으로 보호된 라우트 그룹 생성.

### _authed.tsx (Layout)

```tsx
// routes/_authed.tsx
import { createFileRoute, redirect, Outlet } from '@tanstack/react-router'
import { getCurrentUser } from '@/functions/auth'

export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }) => {
    const user = await getCurrentUser()

    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }

    // 하위 라우트에서 사용할 context
    return { user }
  },
  component: () => <Outlet />,
})
```

### _authed/dashboard.tsx

```tsx
// routes/_authed/dashboard.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/_authed/dashboard')({
  component: DashboardPage,
})

function DashboardPage() {
  // _authed에서 전달된 context
  const { user } = Route.useRouteContext()

  return (
    <div>
      <h1>Welcome, {user.name}!</h1>
    </div>
  )
}
```

### 구조

```
routes/
├── _authed.tsx           # Protected layout (beforeLoad에서 인증 체크)
├── _authed/
│   ├── dashboard.tsx     # /dashboard (protected)
│   ├── settings.tsx      # /settings (protected)
│   └── profile.tsx       # /profile (protected)
├── login.tsx             # /login (public)
└── index.tsx             # / (public)
```

## Root Context

전역 context 설정 (QueryClient, Auth 등).

### __root.tsx

```tsx
// routes/__root.tsx
import { createRootRouteWithContext, Outlet } from '@tanstack/react-router'
import type { QueryClient } from '@tanstack/react-query'

interface RouterContext {
  queryClient: QueryClient
  auth: {
    isAuthenticated: boolean
    user: { id: string; name: string } | null
  }
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
})

function RootLayout() {
  return (
    <div>
      <Outlet />
    </div>
  )
}
```

### Router 생성

```tsx
// app/router.tsx
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'
import { queryClient } from './query-client'

export const router = createRouter({
  routeTree,
  context: {
    queryClient,
    auth: {
      isAuthenticated: false,
      user: null,
    },
  },
})
```

## redirect

```tsx
import { redirect } from '@tanstack/react-router'

// 기본 리다이렉트
throw redirect({ to: '/login' })

// Search params 포함
throw redirect({
  to: '/login',
  search: { redirect: '/dashboard' },
})

// 동적 파라미터
throw redirect({
  to: '/posts/$postId',
  params: { postId: '123' },
})

// replace (뒤로가기 X)
throw redirect({
  to: '/home',
  replace: true,
})
```

## Context 사용 위치

| 위치 | 접근 방법 |
|------|----------|
| beforeLoad | `{ context }` 파라미터 |
| loader | `{ context }` 파라미터 |
| component | `Route.useRouteContext()` |

```tsx
export const Route = createFileRoute('/example')({
  beforeLoad: ({ context }) => {
    console.log(context.auth)
    return { extra: 'data' }
  },
  loader: ({ context }) => {
    // beforeLoad 반환값도 포함됨
    console.log(context.extra)
  },
  component: ExamplePage,
})

function ExamplePage() {
  const context = Route.useRouteContext()
  // context.auth, context.extra 모두 접근 가능
}
```
