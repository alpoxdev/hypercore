---
title: Add Cache Layer for Repeated Reads
impact: HIGH
impactDescription: 10-100x latency reduction for cached data
tags: io, cache, lru, ttl, redis, in-memory
languages: all
related: [io-batch-queries, memory-bounded-cache]
---

## 반복 읽기에 캐시 레이어 추가

동일 데이터를 반복 조회하는 경우 인메모리/외부 캐시를 추가하여 DB/API 부하를 줄입니다.

**❌ 잘못된 예시 (매번 DB 조회):**

```python
def get_user(user_id: str) -> User:
    return db.query("SELECT * FROM users WHERE id = $1", user_id)
```

**✅ 올바른 예시 (캐시 레이어):**

```python
# Python (functools.lru_cache)
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_config(key: str) -> str:
    return db.query("SELECT value FROM config WHERE key = $1", key)

# TTL 있는 캐시 (cachetools)
from cachetools import TTLCache
cache = TTLCache(maxsize=1000, ttl=300)  # 5분
```

```typescript
// Node.js (lru-cache)
import { LRUCache } from 'lru-cache'
const cache = new LRUCache<string, User>({ max: 1000, ttl: 5 * 60 * 1000 })

async function getUser(id: string): Promise<User> {
  const cached = cache.get(id)
  if (cached) return cached
  const user = await db.user.findUnique({ where: { id } })
  if (user) cache.set(id, user)
  return user
}
```

```go
// Go (groupcache / ristretto)
import "github.com/dgraph-io/ristretto"
cache, _ := ristretto.NewCache(&ristretto.Config{
    NumCounters: 1e7, MaxCost: 1 << 30, BufferItems: 64,
})
```

```rust
// Rust (moka)
use moka::future::Cache;
let cache: Cache<String, User> = Cache::builder()
    .max_capacity(1000)
    .time_to_live(Duration::from_secs(300))
    .build();
```

**캐시 전략:** 읽기 빈도 높고, 쓰기 빈도 낮은 데이터에 적용. TTL로 신선도 보장.
