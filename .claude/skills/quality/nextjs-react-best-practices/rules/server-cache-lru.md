---
title: Cross-Request LRU Caching
impact: HIGH
impactDescription: caches across requests
tags: server, cache, lru, cross-request
---

## 요청 간 LRU 캐싱

`React.cache()`는 단일 요청 내에서만 동작합니다. 연속된 요청 간 데이터 공유가 필요한 경우(사용자가 버튼 A를 클릭한 후 버튼 B를 클릭하는 경우)에는 LRU 캐시를 사용하세요.

**구현:**

```typescript
import { LRUCache } from 'lru-cache'

const cache = new LRUCache<string, any>({
  max: 1000,
  ttl: 5 * 60 * 1000  // 5분
})

export async function getUser(id: string) {
  const cached = cache.get(id)
  if (cached) return cached

  const user = await db.user.findUnique({ where: { id } })
  cache.set(id, user)
  return user
}

// 요청 1: DB 쿼리, 결과 캐시됨
// 요청 2: 캐시 히트, DB 쿼리 없음
```

연속된 사용자 행동이 몇 초 내에 동일한 데이터가 필요한 여러 엔드포인트를 호출할 때 사용하세요.

**Vercel의 [Fluid Compute](https://vercel.com/docs/fluid-compute)를 사용하는 경우:** LRU 캐싱은 특히 효과적입니다. 여러 동시 요청이 동일한 함수 인스턴스와 캐시를 공유할 수 있기 때문입니다. 이는 Redis와 같은 외부 스토리지 없이도 요청 간 캐시가 유지됨을 의미합니다.

**전통적인 서버리스 환경에서는:** 각 호출이 격리된 환경에서 실행되므로 프로세스 간 캐싱을 위해 Redis 사용을 고려하세요.

참고: [https://github.com/isaacs/node-lru-cache](https://github.com/isaacs/node-lru-cache)
