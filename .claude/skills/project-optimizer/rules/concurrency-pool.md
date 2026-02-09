---
title: Limit Concurrency with Pools
impact: HIGH
impactDescription: Prevents resource exhaustion, stable throughput
tags: concurrency, pool, semaphore, rate-limiting, backpressure
languages: all
related: [concurrency-parallel, io-connection-reuse, memory-bounded-cache]
---

## 동시 실행 수 제한

무제한 병렬화는 리소스 고갈을 유발. 커넥션 풀, 세마포어, 워커 풀로 동시 실행 수를 제한합니다.

**❌ 잘못된 예시 (무제한 동시 실행):**

```typescript
// 1000개 URL 동시 요청 → 커넥션 고갈, OOM
const results = await Promise.all(
  urls.map(url => fetch(url))
)
```

**✅ 올바른 예시 (동시 실행 수 제한):**

```typescript
// JS/TS (p-limit)
import pLimit from 'p-limit'
const limit = pLimit(10)  // 최대 10개 동시
const results = await Promise.all(
  urls.map(url => limit(() => fetch(url)))
)
```

```python
# Python (asyncio.Semaphore)
sem = asyncio.Semaphore(10)
async def limited_fetch(url):
    async with sem:
        return await fetch(url)

results = await asyncio.gather(*[limited_fetch(url) for url in urls])
```

```go
// Go (worker pool)
func worker(jobs <-chan string, results chan<- Result) {
    for url := range jobs {
        results <- fetch(url)
    }
}
// 10개 워커 실행
for i := 0; i < 10; i++ { go worker(jobs, results) }
```

```rust
// Rust (tokio::sync::Semaphore)
let sem = Arc::new(Semaphore::new(10));
let tasks: Vec<_> = urls.iter().map(|url| {
    let permit = sem.clone().acquire_owned();
    async move {
        let _permit = permit.await.unwrap();
        fetch(url).await
    }
}).collect();
let results = futures::future::join_all(tasks).await;
```

**적정 동시 실행 수:** DB 커넥션 10-25, HTTP 요청 10-50, 파일 I/O 5-20.
