---
title: Use Deferred Data for Non-Critical Content
impact: HIGH
impactDescription: faster initial page render
tags: server, streaming, suspense, deferred-data, ux
---

## Use Deferred Data for Non-Critical Content

Load critical data with `await`, but return non-critical data as Promises for streaming. This allows the page to render immediately while slow queries complete in the background.

**Incorrect (blocks on slow query):**

```typescript
import { createFileRoute } from '@tanstack/react-router'
import { getPost, getComments } from '@/functions/data'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId) // Fast: 50ms
    const comments = await getComments(params.postId) // Slow: 3s
    return { post, comments }
  }
})
// Total wait: 3.05s before page renders
```

**Correct (stream slow data):**

```typescript
import { createFileRoute, Await } from '@tanstack/react-router'
import { getPost, getComments } from '@/functions/data'
import { Suspense } from 'react'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // Critical: await immediately
    const post = await getPost(params.postId)

    // Non-critical: return Promise (don't await)
    const deferredComments = getComments(params.postId)

    return { post, deferredComments }
  },
  component: PostPage
})

function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()

  return (
    <div>
      <PostContent post={post} /> {/* Renders immediately */}

      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

Page renders in 50ms instead of 3s. Comments stream in when ready. Use for: analytics, recommendations, user activity, social features.

Reference: [TanStack Router Deferred Data Loading](https://tanstack.com/router/v1/docs/framework/react/guide/deferred-data-loading)
