---
title: Use Route-Level Error Boundaries
impact: HIGH
impactDescription: graceful error recovery per route
tags: server, error-handling, error-boundary, tanstack-router
---

## 라우트 레벨 에러 바운더리

TanStack Router는 라우트별 `errorComponent`를 지원합니다. 전역 에러 페이지 대신 라우트 단위 에러 처리로 사용자 경험을 개선하세요.

**❌ 잘못된 예시 (에러 처리 없음):**

```typescript
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    return { post } // post가 null이면 런타임 에러
  },
  component: PostPage
})

function PostPage() {
  const { post } = Route.useLoaderData()
  return <div>{post.title}</div> // 💥 Cannot read property 'title' of null
}
```

**✅ 올바른 예시 (라우트별 에러 처리):**

```typescript
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) throw new Error('Post not found')
    return { post }
  },
  errorComponent: ({ error, reset }) => (
    <div>
      <h2>오류가 발생했습니다</h2>
      <p>{error.message}</p>
      <button onClick={reset}>다시 시도</button>
    </div>
  ),
  component: PostPage
})
```

**전역 기본 에러 컴포넌트 설정:**

```typescript
import { createRouter } from '@tanstack/react-router'

const router = createRouter({
  routeTree,
  defaultErrorComponent: ({ error, reset }) => (
    <div>
      <h1>예기치 못한 오류</h1>
      <p>{error.message}</p>
      <button onClick={reset}>재시도</button>
    </div>
  )
})
```

**notFoundComponent로 404 처리:**

```typescript
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) throw notFound()
    return { post }
  },
  notFoundComponent: () => <div>게시글을 찾을 수 없습니다</div>
})
```

**원칙:** loader에서 예외를 명시적으로 throw하고, errorComponent/notFoundComponent로 처리합니다. TanStack Router가 자동으로 Suspense와 ErrorBoundary를 래핑합니다.
