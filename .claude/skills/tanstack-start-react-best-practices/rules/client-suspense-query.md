---
title: Use useSuspenseQuery for Declarative Data Loading
impact: MEDIUM-HIGH
impactDescription: eliminates loading state boilerplate
tags: client, tanstack-query, suspense, data-fetching
---

## useSuspenseQuery로 선언적 데이터 로딩

TanStack Query v5의 `useSuspenseQuery`는 Suspense를 기본 지원하여 로딩/에러 상태 보일러플레이트를 제거합니다.

**❌ 잘못된 예시 (수동 로딩/에러 처리):**

```tsx
import { useQuery } from '@tanstack/react-query'

function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser({ data: { id: userId } })
  })

  if (isLoading) return <UserSkeleton />
  if (error) return <ErrorMessage error={error} />
  if (!user) return null

  return <div>{user.name}</div>
}
```

**✅ 올바른 예시 (Suspense + ErrorBoundary):**

```tsx
import { useSuspenseQuery } from '@tanstack/react-query'
import { Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

function UserProfile({ userId }: { userId: string }) {
  // data는 항상 존재 (undefined 아님), 타입 안전
  const { data: user } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser({ data: { id: userId } })
  })

  return <div>{user.name}</div>
}

// 부모에서 Suspense + ErrorBoundary로 감싸기
function UserPage({ userId }: { userId: string }) {
  return (
    <ErrorBoundary fallback={<ErrorMessage />}>
      <Suspense fallback={<UserSkeleton />}>
        <UserProfile userId={userId} />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**장점:**
- `data`가 `undefined`가 아닌 확정 타입 (타입 가드 불필요)
- 로딩/에러 처리가 컴포넌트 트리 상위로 위임 (관심사 분리)
- 여러 쿼리의 로딩 상태를 하나의 Suspense로 통합 가능

**TanStack Query v5 주요 변경 (v4 대비):**

| v4 | v5 |
|----|-----|
| `cacheTime` | `gcTime` |
| `keepPreviousData` | `placeholderData` |
| `isLoading` | `isPending` |
| `useSuspenseQuery` (실험적) | `useSuspenseQuery` (안정적) |

참고: [TanStack Query](https://tanstack.com/query/latest/docs/framework/react/overview)
