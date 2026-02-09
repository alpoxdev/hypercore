---
title: Bound Cache Size with LRU/TTL
impact: MEDIUM
impactDescription: Prevents unbounded memory growth
tags: memory, cache, lru, ttl, bounded
languages: all
related: [io-cache-layer, concurrency-pool]
---

## 캐시에 크기 제한 설정

무제한 캐시는 시간이 지남에 따라 메모리를 소진합니다. LRU(최소 최근 사용) + TTL(유효 시간)로 제한합니다.

**❌ 잘못된 예시 (무제한 캐시):**

```python
cache = {}  # 무제한 성장
def get_user(id):
    if id not in cache:
        cache[id] = db.get_user(id)
    return cache[id]
# 100만 유저 → 100만 항목, OOM
```

**✅ 올바른 예시 (제한된 캐시):**

```python
# Python
from cachetools import TTLCache, LRUCache
cache = TTLCache(maxsize=10000, ttl=300)  # 최대 1만, 5분 TTL

# functools (크기만 제한)
@lru_cache(maxsize=1000)
def get_config(key): ...
```

```typescript
// Node.js
import { LRUCache } from 'lru-cache'
const cache = new LRUCache<string, User>({
  max: 10000,              // 최대 항목 수
  ttl: 5 * 60 * 1000,     // 5분
  maxSize: 50 * 1024 * 1024, // 50MB (선택)
  sizeCalculation: (v) => JSON.stringify(v).length,
})
```

```go
// Go (ristretto)
cache, _ := ristretto.NewCache(&ristretto.Config{
    NumCounters: 1e5,      // 키 추적 수
    MaxCost:     1 << 26,  // 64MB
    BufferItems: 64,
})
```

```rust
// Rust (moka)
let cache: Cache<String, User> = Cache::builder()
    .max_capacity(10_000)
    .time_to_live(Duration::from_secs(300))
    .build();
```

**원칙:** 캐시 = max 크기 + 만료 정책. 둘 다 없으면 메모리 릭과 같음.
