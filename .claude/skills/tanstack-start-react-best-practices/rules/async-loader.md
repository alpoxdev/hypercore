---
title: TanStack Router Loader에서 병렬 데이터 페칭
impact: CRITICAL
impactDescription: 2-10배 성능 향상
tags: async, loader, tanstack-router, parallelization, waterfalls
---

## TanStack Router Loader에서 병렬 데이터 페칭

`loader`에서 독립적인 서버 함수 호출을 `Promise.all()`을 사용해 동시 실행. 요청 워터폴 (waterfalls)을 제거합니다.

**❌ 잘못된 예 (순차 실행, 2번의 왕복):**

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

**✅ 올바른 예 (병렬 실행, 1번의 왕복):**

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

독립적인 `createServerFn()` 호출에 모두 적용 가능하며, 페이지 로드 시간을 50-80% 단축합니다.
