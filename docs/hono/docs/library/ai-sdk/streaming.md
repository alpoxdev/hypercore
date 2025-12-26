# AI SDK - 텍스트 생성 & 스트리밍

> generateText, streamText 사용법

---

## generateText

한 번에 텍스트 생성 (비스트리밍).

```typescript
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

app.post('/api/generate', async (c) => {
  const { prompt } = await c.req.json()

  const { text, usage, finishReason } = await generateText({
    model: openai('gpt-4o'),
    prompt,
  })

  return c.json({ text, usage, finishReason })
})
```

### 시스템 프롬프트

```typescript
const { text } = await generateText({
  model: openai('gpt-4o'),
  system: 'You are a helpful coding assistant.',
  prompt,
})
```

### 메시지 형식

```typescript
const { text } = await generateText({
  model: openai('gpt-4o'),
  messages: [
    { role: 'user', content: 'Hello!' },
    { role: 'assistant', content: 'Hi!' },
    { role: 'user', content: 'How are you?' },
  ],
})
```

---

## streamText

실시간 텍스트 스트리밍.

```typescript
import { streamText } from 'ai'

app.post('/api/stream', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  return result.toUIMessageStreamResponse()
})
```

### 스트림 응답 타입

```typescript
// UI 메시지 스트림 (프론트엔드용)
return result.toUIMessageStreamResponse()

// 텍스트 스트림 (SSE)
return result.toTextStreamResponse()

// Data 스트림
return result.toDataStreamResponse()
```

### 커스텀 스트림 처리

```typescript
import { stream } from 'hono/streaming'

app.post('/api/custom-stream', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  return stream(c, async (stream) => {
    for await (const chunk of result.textStream) {
      await stream.write(chunk)
    }
  })
})
```

---

## 옵션

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  prompt,
  temperature: 0.7,     // 창의성 (0-2)
  maxTokens: 1000,      // 최대 토큰
  topP: 0.9,            // 누적 확률
  frequencyPenalty: 0,  // 반복 페널티
  presencePenalty: 0,   // 존재 페널티
  stopSequences: ['---'], // 중단 시퀀스
})
```

---

## 스트림 이벤트

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  prompt,
  onChunk: ({ chunk }) => {
    console.log('Chunk:', chunk)
  },
  onFinish: ({ text, usage, finishReason }) => {
    console.log('Finished:', text)
    console.log('Usage:', usage)
  },
})
```

---

## 관련 문서

- [AI SDK 개요](./index.md)
- [도구](./tools.md)
- [구조화된 출력](./structured-output.md)
