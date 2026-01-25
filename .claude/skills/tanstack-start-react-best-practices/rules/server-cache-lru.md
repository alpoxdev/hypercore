---
title: 크로스 리퀘스트 LRU 캐싱
impact: HIGH
impactDescription: 요청 간 캐싱
tags: server, cache, lru, cross-request
---

## 크로스 리퀘스트 LRU 캐싱

순차적 요청 간 공유되는 데이터 (사용자가 버튼 A 클릭 후 버튼 B 클릭)에는 LRU 캐시 사용.

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

// 요청 1: DB 쿼리, 결과 캐싱
// 요청 2: 캐시 히트, DB 쿼리 없음
```

순차적 사용자 액션이 수초 내에 동일한 데이터가 필요한 여러 엔드포인트를 호출할 때 사용.

**Vercel의 [Fluid Compute](https://vercel.com/docs/fluid-compute)에서:** LRU 캐싱이 특히 효과적. 여러 동시 요청이 동일한 함수 인스턴스와 캐시를 공유할 수 있습니다. 즉, Redis 같은 외부 스토리지 없이 요청 간 캐시가 유지됩니다.

**기존 서버리스 환경:** 각 호출이 격리되어 실행되므로 프로세스 간 캐싱을 위해 Redis 고려.

참고: [https://github.com/isaacs/node-lru-cache](https://github.com/isaacs/node-lru-cache)
