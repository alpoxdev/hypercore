---
title: Use beforeLoad for Authentication Guards
impact: HIGH
impactDescription: prevents unauthorized access before data loading
tags: routing, beforeLoad, authentication, redirect, guards
---

## beforeLoad로 인증 가드 구현

`beforeLoad`는 loader보다 먼저 순차 실행되며, 인증 체크/리다이렉트에 최적입니다. Pathless layout(`_prefix`)과 조합하면 하위 라우트 전체를 보호합니다.

**❌ 잘못된 예시 (loader에서 인증 체크):**

```tsx
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getSession()
    if (!user) throw redirect({ to: '/login' })  // 데이터 로딩 후 체크 (늦음)
    const data = await fetchDashboard(user.id)
    return { data }
  },
})
```

**✅ 올바른 예시 (beforeLoad + pathless layout):**

```tsx
// src/routes/_authenticated.tsx - 인증 가드 레이아웃
import { createFileRoute, redirect, Outlet } from '@tanstack/react-router'

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: async ({ location }) => {
    const user = await verifySession()

    if (!user) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },  // 원래 위치 보존
      })
    }

    return { user }  // context로 하위 라우트에 전달
  },
  component: () => <Outlet />,
})

// src/routes/_authenticated/dashboard.tsx - 보호된 라우트
export const Route = createFileRoute('/_authenticated/dashboard')({
  loader: async ({ context }) => {
    // context.user는 beforeLoad에서 타입 안전하게 전달됨
    return { stats: await fetchDashboard(context.user.id) }
  },
  component: Dashboard,
})

function Dashboard() {
  const { stats } = Route.useLoaderData()
  return <DashboardView stats={stats} />
}
```

**실행 순서:**

```
1. Root.beforeLoad()            ← 순차 실행
2. _authenticated.beforeLoad()  ← 인증 실패 시 여기서 redirect
3. Dashboard.beforeLoad()       ← 인증 통과 후 실행
4. Root.loader()                ← 모든 loader 병렬 실행
5. _authenticated.loader()
6. Dashboard.loader()
```

**beforeLoad vs loader:**

| 항목 | beforeLoad | loader |
|------|-----------|--------|
| 실행 | 순차 (부모→자식) | 병렬 (모든 라우트 동시) |
| 시점 | loader 전 | beforeLoad 후 |
| 용도 | 인증, 리다이렉트, context 설정 | 데이터 페칭 |
| 반환값 | context 객체 (하위 라우트 접근 가능) | 라우트 데이터 |
| 성능 | 가볍게 유지 (모든 네비게이션에서 실행) | 무거운 작업 가능 |

**선택적 인증 (인증 없어도 페이지 렌더링):**

```tsx
export const Route = createFileRoute('/profile')({
  beforeLoad: async () => {
    try {
      const user = await verifySession()
      return { user }
    } catch {
      return { user: null }  // 리다이렉트 없이 null 반환
    }
  },
  component: Profile,
})

function Profile() {
  const { user } = Route.useRouteContext()
  return user ? <UserProfile user={user} /> : <LoginPrompt />
}
```

**redirect에서 isRedirect 사용:**

```tsx
import { redirect, isRedirect } from '@tanstack/react-router'

beforeLoad: async ({ location }) => {
  try {
    const user = await verifySession()
    if (!user) throw redirect({ to: '/login' })
    return { user }
  } catch (error) {
    if (isRedirect(error)) throw error  // redirect는 그대로 전파
    throw redirect({ to: '/login' })    // 다른 에러도 로그인으로
  }
}
```

참고: [Authenticated Routes](https://tanstack.com/router/latest/docs/framework/react/guide/authenticated-routes)
