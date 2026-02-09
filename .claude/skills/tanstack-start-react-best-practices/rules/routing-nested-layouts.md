---
title: Use Outlet and Pathless Layouts for Nested UI
impact: HIGH
impactDescription: enables shared UI structure without prop drilling
tags: routing, outlet, layouts, createRootRoute, nesting
---

## Outlet과 Pathless Layout으로 중첩 UI 구현

`<Outlet />`으로 하위 라우트를 렌더링하고, pathless layout(`_prefix`)으로 URL 변경 없이 공유 UI를 적용합니다.

**❌ 잘못된 예시 (레이아웃 중복):**

```tsx
// routes/dashboard/overview.tsx
function OverviewPage() {
  return (
    <div className="dashboard">
      <Sidebar />       {/* 중복 */}
      <main><Overview /></main>
    </div>
  )
}

// routes/dashboard/analytics.tsx
function AnalyticsPage() {
  return (
    <div className="dashboard">
      <Sidebar />       {/* 중복 */}
      <main><Analytics /></main>
    </div>
  )
}
```

**✅ 올바른 예시 (Outlet으로 레이아웃 공유):**

```tsx
// src/routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: () => (
    <div>
      <Header />
      <Outlet />   {/* 하위 라우트가 여기에 렌더링 */}
      <Footer />
    </div>
  ),
})

// src/routes/dashboard.tsx - 레이아웃 라우트
export const Route = createFileRoute('/dashboard')({
  component: DashboardLayout,
})

function DashboardLayout() {
  return (
    <div className="dashboard">
      <Sidebar />
      <main>
        <Outlet />  {/* dashboard/overview, dashboard/analytics 렌더링 */}
      </main>
    </div>
  )
}

// src/routes/dashboard/overview.tsx
export const Route = createFileRoute('/dashboard/overview')({
  component: () => <Overview />,  // DashboardLayout 안에 렌더링
})

// src/routes/dashboard/analytics.tsx
export const Route = createFileRoute('/dashboard/analytics')({
  component: () => <Analytics />,
})
```

**Pathless Layout (URL 없는 레이아웃):**

```
src/routes/
├── _public.tsx              ← /없음 (pathless, navbar+footer만)
├── _public/
│   ├── index.tsx            → /
│   ├── about.tsx            → /about
│   └── pricing.tsx          → /pricing
├── _dashboard.tsx           ← /없음 (pathless, sidebar 레이아웃)
└── _dashboard/
    ├── overview.tsx         → /overview
    ├── analytics.tsx        → /analytics
    └── settings.tsx         → /settings
```

```tsx
// src/routes/_dashboard.tsx
export const Route = createFileRoute('/_dashboard')({
  component: () => (
    <div className="flex">
      <Sidebar />
      <main className="flex-1">
        <Outlet />
      </main>
    </div>
  ),
})

// src/routes/_dashboard/overview.tsx
export const Route = createFileRoute('/_dashboard/overview')({
  component: () => <h1>Overview</h1>,  // URL: /overview
})
```

**Route Group vs Pathless Layout:**

| 패턴 | 문법 | URL 영향 | 레이아웃 |
|------|------|---------|---------|
| **Route Group** | `(groupName)/` | 없음 | ❌ 불가 |
| **Pathless Layout** | `_layoutName.tsx` | 없음 | ✅ 가능 |

- Route Group `(public)/`: 파일 정리용, 레이아웃 없음
- Pathless Layout `_public.tsx`: 공유 UI 래핑 가능

**createRootRouteWithContext:**

```tsx
// 타입 안전한 전역 context
interface RouterContext {
  queryClient: QueryClient
  auth: AuthState
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: () => <Outlet />,
})

// 하위 라우트에서 context 접근
export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context }) => {
    // context.queryClient, context.auth 타입 안전
  },
})
```

**component 생략 시 자동 Outlet:**

```tsx
// component를 지정하지 않으면 자동으로 <Outlet /> 렌더링
export const Route = createFileRoute('/app')({
  // component 생략 → Outlet 자동 렌더링
  beforeLoad: async ({ context }) => { /* ... */ },
})
```

참고: [Outlets Guide](https://tanstack.com/router/latest/docs/framework/react/guide/outlets), [Route Trees](https://tanstack.com/router/latest/docs/framework/react/guide/route-trees)
