---
title: Parallel Data Fetching in TanStack Router Loader
impact: CRITICAL
impactDescription: 2-10× improvement
tags: async, loader, tanstack-router, parallelization, waterfalls
---

## Parallel Data Fetching in TanStack Router Loader

Execute independent server function calls concurrently in `loader` using `Promise.all()`. This eliminates request waterfalls.

**Incorrect (sequential execution, 2 round trips):**

```typescript
import { createFileRoute } from '@tanstack/react-router'
import { getUser, getPosts } from '@/functions/data'

export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getUser()
    const posts = await getPosts()
    return { user, posts }
  }
})
```

**Correct (parallel execution, 1 round trip):**

```typescript
import { createFileRoute } from '@tanstack/react-router'
import { getUser, getPosts } from '@/functions/data'

export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const [user, posts] = await Promise.all([
      getUser(),
      getPosts()
    ])
    return { user, posts }
  }
})
```

This pattern works with any independent `createServerFn()` calls, reducing page load time by 50-80%.
