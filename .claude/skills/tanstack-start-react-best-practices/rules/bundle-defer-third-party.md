---
title: Defer Non-Critical Third-Party Libraries
impact: MEDIUM
impactDescription: loads after hydration
tags: bundle, third-party, analytics, defer
---

## 중요하지 않은 서드파티 라이브러리 연기하기

분석, 로깅, 에러 추적은 사용자 상호작용을 차단하지 않습니다. 하이드레이션 후에 로드합니다.

**❌ 잘못된 예시 (초기 번들 차단):**

```tsx
import { Analytics } from '@vercel/analytics/react'
import { ErrorTracker } from './error-tracker'

function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      {children}
      <Analytics />
      <ErrorTracker />
    </div>
  )
}
```

**✅ 올바른 예시 (하이드레이션 후 lazy load):**

```tsx
import { lazy, Suspense, useEffect, useState } from 'react'

const Analytics = lazy(() =>
  import('@vercel/analytics/react').then(m => ({ default: m.Analytics }))
)

function RootLayout({ children }: { children: React.ReactNode }) {
  const [hydrated, setHydrated] = useState(false)

  useEffect(() => {
    setHydrated(true)
  }, [])

  return (
    <div>
      {children}
      {hydrated && (
        <Suspense fallback={null}>
          <Analytics />
        </Suspense>
      )}
    </div>
  )
}
```

**✅ 더 간단한 대안 (useEffect로 직접 초기화):**

```tsx
function RootLayout({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // 하이드레이션 후 비동기 로드
    import('./analytics').then(mod => mod.init())
    import('./error-tracker').then(mod => mod.init())
  }, [])

  return <div>{children}</div>
}
```

TanStack Start에서는 `next/dynamic`을 사용할 수 없으므로, React의 `lazy()` + `Suspense` 또는 `useEffect` 내 동적 `import()`를 사용합니다.
