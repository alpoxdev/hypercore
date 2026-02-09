---
title: Use React 19 use() Hook for Promise Handling
impact: MEDIUM
impactDescription: replaces useEffect fetch patterns
tags: client, react-19, use-hook, promises, suspense
---

## React 19 use() Hook으로 Promise 처리

React 19의 `use()` 훅은 렌더링 중 Promise를 읽어 Suspense와 자동 통합됩니다. `useEffect` + `useState` 조합을 대체합니다.

**❌ 잘못된 예시 (useEffect + useState 패턴):**

```tsx
function Comments({ postId }: { postId: string }) {
  const [comments, setComments] = useState<Comment[] | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    setLoading(true)
    getComments({ data: { postId } })
      .then(setComments)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [postId])

  if (loading) return <CommentsSkeleton />
  if (error) return <ErrorMessage error={error} />
  return <CommentList comments={comments!} />
}
```

**✅ 올바른 예시 (use() + Suspense):**

```tsx
import { use, Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

function Comments({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  const comments = use(commentsPromise)
  return <CommentList comments={comments} />
}

// 부모에서 Promise 전달
function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()

  return (
    <div>
      <PostContent post={post} />
      <ErrorBoundary fallback={<ErrorMessage />}>
        <Suspense fallback={<CommentsSkeleton />}>
          <Comments commentsPromise={deferredComments} />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}
```

**use()로 Context 읽기:**

```tsx
// 조건부 Context 읽기 (useContext와 달리 조건부 호출 가능)
function ThemeButton({ override }: { override?: Theme }) {
  if (override) return <Button theme={override} />

  const theme = use(ThemeContext)
  return <Button theme={theme} />
}
```

**use() 사용 규칙:**
- ✅ 조건문/루프 내에서 호출 가능 (일반 Hook과 다름)
- ❌ 컴포넌트 내에서 `new Promise()` 생성 후 전달 금지 (매 렌더링마다 재생성)
- ✅ loader, server function, 부모 컴포넌트에서 생성된 Promise 전달

**TanStack Start와 조합:** loader에서 deferred Promise를 반환하고, 컴포넌트에서 `use()` 또는 `<Await>`로 처리합니다. 두 패턴 모두 유효하며, `<Await>`가 TanStack Router의 공식 패턴입니다.

참고: [React use() API](https://react.dev/reference/react/use)
