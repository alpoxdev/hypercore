---
title: 중요하지 않은 콘텐츠에 지연 데이터 사용
impact: HIGH
impactDescription: 초기 페이지 렌더링 속도 향상
tags: server, streaming, suspense, deferred-data, ux
---

## 중요하지 않은 콘텐츠에 지연 데이터 (Deferred Data) 사용

중요한 데이터는 `await`로 로드하고, 중요하지 않은 데이터는 Promise로 반환해 스트리밍. 느린 쿼리가 백그라운드에서 완료되는 동안 페이지를 즉시 렌더링합니다.

**❌ 잘못된 예 (느린 쿼리에서 차단):**

```typescript
import { createFileRoute } from '@tanstack/react-router'
import { getPost, getComments } from '@/functions/data'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId) // 빠름: 50ms
    const comments = await getComments(params.postId) // 느림: 3s
    return { post, comments }
  }
})
// 총 대기 시간: 3.05초 후 페이지 렌더링
```

**✅ 올바른 예 (느린 데이터 스트리밍):**

```typescript
import { createFileRoute, Await } from '@tanstack/react-router'
import { getPost, getComments } from '@/functions/data'
import { Suspense } from 'react'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // 중요: 즉시 await
    const post = await getPost(params.postId)

    // 중요하지 않음: Promise 반환 (await 하지 않음)
    const deferredComments = getComments(params.postId)

    return { post, deferredComments }
  },
  component: PostPage
})

function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()

  return (
    <div>
      <PostContent post={post} /> {/* 즉시 렌더링 */}

      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

페이지가 3초 대신 50ms에 렌더링됩니다. 댓글은 준비되면 스트리밍. 다음에 사용: 분석, 추천, 사용자 활동, 소셜 기능.

참고: [TanStack Router Deferred Data Loading](https://tanstack.com/router/v1/docs/framework/react/guide/deferred-data-loading)
