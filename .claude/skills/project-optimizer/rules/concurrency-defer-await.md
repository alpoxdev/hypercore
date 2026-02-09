---
title: Defer Await to Point of Use
impact: CRITICAL
impactDescription: Eliminates unnecessary blocking, enables overlap
tags: concurrency, async, await, deferred
languages: all
related: [concurrency-parallel, memory-lazy-init]
---

## await/블로킹을 사용 지점으로 이동

비동기 작업의 결과를 기다리는 시점을 실제 사용 지점으로 미뤄서, 그 사이에 다른 작업이 실행될 수 있게 합니다.

**❌ 잘못된 예시 (즉시 대기):**

```typescript
// 결과가 10줄 뒤에서 필요한데 즉시 await
const data = await fetchData()
// ... 다른 동기 작업 10줄 ...
processData(data)
```

```python
data = await fetch_data()  # 여기서 블로킹
# ... 다른 동기 작업 ...
process_data(data)
```

**✅ 올바른 예시 (사용 시점에서 대기):**

```typescript
// Promise를 먼저 시작, 나중에 await
const dataPromise = fetchData()  // 시작만 함
// ... 다른 동기 작업 (이 동안 fetch 진행) ...
const data = await dataPromise   // 실제 필요 시점에 await
processData(data)
```

```python
import asyncio
task = asyncio.create_task(fetch_data())  # 시작만 함
# ... 다른 동기 작업 ...
data = await task  # 실제 필요 시점에 await
process_data(data)
```

```go
ch := make(chan *Data, 1)
go func() { ch <- fetchData(ctx) }()  // 시작
// ... 다른 작업 ...
data := <-ch  // 실제 필요 시점에 수신
```

**핵심:** 작업 시작과 결과 소비 사이에 다른 유용한 작업이 있으면 defer 적용.
