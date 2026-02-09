---
title: Use Router Context for Dependency Injection
impact: MEDIUM-HIGH
impactDescription: enables type-safe shared state across all routes
tags: routing, context, createRootRouteWithContext, dependency-injection
---

## Router Context로 의존성 주입

`createRootRouteWithContext`로 QueryClient, 인증 상태 등을 타입 안전하게 모든 라우트에 전달합니다.

**❌ 잘못된 예시 (전역 변수/import):**

```tsx
// 전역 import → 테스트 어려움, 타입 안전성 없음
import { queryClient } from '../lib/queryClient'
import { getAuth } from '../lib/auth'

export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getAuth()  // 타입 추론 불가
    return await queryClient.fetchQuery(...)
  },
})
```

**✅ 올바른 예시 (createRootRouteWithContext):**

```tsx
// 1. Context 인터페이스 정의
interface RouterContext {
  queryClient: QueryClient
  auth: { user: User | null }
}

// 2. Root route에 context 타입 바인딩
// src/routes/__root.tsx
import { createRootRouteWithContext, Outlet } from '@tanstack/react-router'

export const Route = createRootRouteWithContext<RouterContext>()({
  component: () => <Outlet />,
})

// 3. Router 생성 시 context 값 전달
// src/router.tsx
const router = createRouter({
  routeTree,
  context: {
    queryClient: new QueryClient(),
    auth: { user: null },
  },
})

// 4. 하위 라우트에서 타입 안전하게 접근
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context }) => {
    // context.queryClient: QueryClient ✅ 완전한 타입 추론
    // context.auth: { user: User | null } ✅
    if (!context.auth.user) {
      throw redirect({ to: '/login' })
    }
  },
  loader: async ({ context }) => {
    return context.queryClient.ensureQueryData({
      queryKey: ['dashboard'],
      queryFn: fetchDashboard,
    })
  },
})
```

**beforeLoad에서 context 확장:**

```tsx
// 부모 라우트에서 context 확장 → 자식 라우트에서 접근
export const Route = createFileRoute('/admin')({
  beforeLoad: async ({ context }) => {
    const permissions = await fetchPermissions(context.auth.user!.id)
    return { permissions }  // context에 병합됨
  },
})

// 자식 라우트
export const Route = createFileRoute('/admin/users')({
  beforeLoad: async ({ context }) => {
    // context.permissions 접근 가능 (부모에서 추가됨)
    if (!context.permissions.includes('manage_users')) {
      throw redirect({ to: '/admin' })
    }
  },
})
```

**컴포넌트에서 context 접근:**

```tsx
function Dashboard() {
  // useRouteContext로 접근
  const { queryClient, auth } = Route.useRouteContext()

  // 또는 getRouteApi 사용 (코드 스플릿)
  const routeApi = getRouteApi('/dashboard')
  const context = routeApi.useRouteContext()
}
```

**useRouterState (라우터 전역 상태):**

```tsx
// 라우터 상태 반응형 구독
const status = useRouterState({ select: (s) => s.status })
// 'idle' | 'pending' → 전역 로딩 인디케이터에 사용

const location = useRouterState({ select: (s) => s.location })
// 현재 URL 정보

// ⚠️ useRouter().state는 반응형이 아님 → useRouterState 사용
```

참고: [Router Context](https://tanstack.com/router/latest/docs/framework/react/guide/router-context)
