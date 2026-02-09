---
title: Stream Data from Server Functions
impact: MEDIUM
impactDescription: progressive data delivery
tags: server, streaming, async-generator, ReadableStream, tanstack-start
---

## Server Functions에서 데이터 스트리밍

대량 데이터나 실시간 업데이트가 필요한 경우, Server Function에서 스트리밍으로 데이터를 점진적 전달합니다.

**❌ 잘못된 예시 (전체 데이터 대기):**

```typescript
const generateReport = createServerFn({ method: 'POST' })
  .handler(async () => {
    const items = []
    for (const chunk of await processLargeDataset()) {
      items.push(chunk)
    }
    return items // 전체 처리 완료까지 대기
  })
```

**✅ 올바른 예시 (async generator로 스트리밍):**

```typescript
import { createServerFn } from '@tanstack/react-start'

const generateReport = createServerFn({ method: 'POST' })
  .handler(async function* () {
    yield { status: 'processing', progress: 0 }

    for await (const chunk of processLargeDataset()) {
      yield { status: 'processing', data: chunk, progress: chunk.index }
    }

    yield { status: 'complete', progress: 100 }
  })
```

**✅ ReadableStream 방식 (세밀한 제어):**

```typescript
const streamResponse = createServerFn({ method: 'POST' })
  .handler(async () => {
    return new ReadableStream({
      start(controller) {
        const encoder = new TextEncoder()
        controller.enqueue(encoder.encode(JSON.stringify({ msg: 'chunk 1' })))
        controller.enqueue(encoder.encode(JSON.stringify({ msg: 'chunk 2' })))
        controller.close()
      }
    })
  })
```

**클라이언트에서 스트림 소비:**

```tsx
function ReportGenerator() {
  const [chunks, setChunks] = useState<ReportChunk[]>([])

  const handleGenerate = async () => {
    const stream = await generateReport()
    for await (const chunk of stream) {
      setChunks(prev => [...prev, chunk])
    }
  }

  return (
    <div>
      <button onClick={handleGenerate}>Generate</button>
      {chunks.map((chunk, i) => <ChunkDisplay key={i} chunk={chunk} />)}
    </div>
  )
}
```

**사용 시점:** AI 응답 스트리밍, 대용량 CSV/JSON 내보내기, 실시간 진행률 표시, 로그 스트리밍.

**주의:** ReadableStream 사용 시 UTF-8 인코딩을 위해 `TextEncoder.encode()` 필수. async generator가 더 간결하고 타입 안전합니다.

참고: [Streaming Data from Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/streaming-data-from-server-functions)
