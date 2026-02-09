---
title: Pipeline Parallelization
impact: HIGH
impactDescription: Continuous throughput for multi-stage processing
tags: concurrency, pipeline, streaming, producer-consumer
languages: all
related: [concurrency-parallel, io-stream, memory-large-data]
---

## 파이프라인 병렬화

다단계 처리에서 각 단계를 동시에 실행하여 처리량을 극대화합니다. 한 단계의 출력이 다음 단계의 입력이 되는 스트리밍 방식.

**❌ 잘못된 예시 (단계별 전체 처리):**

```python
# 모든 데이터를 한 단계 완료 후 다음 단계
items = fetch_all()           # 10초 대기
processed = [process(i) for i in items]  # 10초 대기
results = [save(p) for p in processed]   # 10초 대기
# 총 30초, 메모리에 전체 데이터 적재
```

**✅ 올바른 예시 (스트리밍 파이프라인):**

```python
# Python (async generator)
async def fetch_stream():
    async for item in db.stream_query("SELECT ..."):
        yield item

async def process_stream(items):
    async for item in items:
        yield transform(item)

async def save_stream(items):
    batch = []
    async for item in items:
        batch.append(item)
        if len(batch) >= 100:
            await db.bulk_insert(batch)
            batch.clear()
    if batch:
        await db.bulk_insert(batch)

# 파이프라인 연결
await save_stream(process_stream(fetch_stream()))
```

```go
// Go (channel pipeline)
func fetch(ctx context.Context) <-chan Item {
    out := make(chan Item, 100)
    go func() { defer close(out); /* fetch and send */ }()
    return out
}

func process(in <-chan Item) <-chan Result {
    out := make(chan Result, 100)
    go func() { defer close(out); for item := range in { out <- transform(item) } }()
    return out
}

// 파이프라인 연결
results := process(fetch(ctx))
```

**적용 기준:** 데이터가 대량이고 단계별로 독립 처리 가능할 때.
