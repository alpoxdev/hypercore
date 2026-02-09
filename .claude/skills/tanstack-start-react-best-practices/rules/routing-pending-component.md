---
title: Use pendingComponent for Route Loading States
impact: MEDIUM
impactDescription: eliminates layout shift during navigation
tags: routing, pendingComponent, loading, UX, transitions
---

## pendingComponent로 라우트 로딩 상태 처리

`pendingComponent`는 loader가 완료되기 전 보여주는 로딩 UI입니다. `pendingMs`/`pendingMinMs`로 플리커 없는 로딩 경험을 구현합니다.

**❌ 잘못된 예시 (로딩 상태 없음):**

```tsx
export const Route = createFileRoute('/tasks')({
  loader: async () => {
    const tasks = await fetchTasks()  // 2초 소요
    return { tasks }
  },
  component: TasksPage,
  // 로딩 UI 없음 → 사용자가 2초간 빈 화면 봄
})
```

**✅ 올바른 예시 (pendingComponent + 타이밍 설정):**

```tsx
export const Route = createFileRoute('/tasks')({
  loader: async () => {
    return { tasks: await fetchTasks() }
  },
  pendingComponent: () => (
    <div className="p-4">
      <div className="animate-pulse space-y-3">
        <div className="h-8 bg-gray-200 rounded w-1/3" />
        <div className="h-4 bg-gray-200 rounded" />
        <div className="h-4 bg-gray-200 rounded" />
      </div>
    </div>
  ),
  pendingMs: 150,     // 150ms 후에도 loader 미완료 시 로딩 UI 표시
  pendingMinMs: 200,  // 로딩 UI 최소 200ms 표시 (플리커 방지)
  component: TasksPage,
})
```

**타이밍 동작:**

```
Time 0ms:      네비게이션 시작
Time 150ms:    pendingMs 경과 → loader 미완료면 pendingComponent 표시
               loader 완료면 즉시 컴포넌트 렌더링 (로딩 UI 없음)

pendingComponent 표시 후:
  loader 완료 시 → 최소 200ms(pendingMinMs) 후 컴포넌트 전환
  (짧은 플리커 방지)
```

**Router 레벨 기본값:**

```tsx
const router = createRouter({
  routeTree,
  defaultPendingComponent: () => <GlobalSpinner />,
  defaultPendingMs: 150,
  defaultPendingMinMs: 200,
})
```

**pendingComponent vs Suspense:**

| 항목 | pendingComponent | Suspense |
|------|-----------------|----------|
| 대상 | 라우트 네비게이션 | 컴포넌트 내 비동기 |
| 트리거 | loader 미완료 | Promise throw |
| 타이밍 제어 | pendingMs/pendingMinMs | 없음 |
| 사용 시점 | 페이지 전환 | deferred data, lazy 컴포넌트 |

**조합 패턴 (pendingComponent + Suspense):**

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)             // 빠른 데이터
    const deferredComments = getComments(params.postId)    // 느린 데이터
    return { post, deferredComments }
  },
  // 페이지 전환 시 로딩 UI (post 로딩 중)
  pendingComponent: () => <PostSkeleton />,
  pendingMs: 150,
  component: PostPage,
})

function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()
  return (
    <div>
      <PostContent post={post} />
      {/* 댓글은 별도 Suspense (이미 post는 로드됨) */}
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

참고: [Pending Component](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading#pending-component)
