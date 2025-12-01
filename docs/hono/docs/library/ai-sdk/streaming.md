# AI SDK - 텍스트 생성 & 스트리밍 (Hono)

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK의 `generateText`와 `streamText`를 Hono에서 사용하는 방법입니다.

---

## generateText

텍스트를 한 번에 생성합니다. 짧은 응답이나 후처리가 필요한 경우에 적합합니다.

### 기본 사용

```typescript
import { Hono } from 'hono'
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

app.post('/api/generate', async (c) => {
  const { prompt } = await c.req.json()

  const { text } = await generateText({
    model: openai('gpt-4o'),
    prompt,
  })

  return c.json({ text })
})
```

### 메시지 형식

```typescript
import { Hono } from 'hono'
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const { text } = await generateText({
    model: openai('gpt-4o'),
    messages,
  })

  return c.json({ response: text })
})
```

### 시스템 프롬프트

```typescript
app.post('/api/assistant', async (c) => {
  const { prompt } = await c.req.json()

  const { text } = await generateText({
    model: openai('gpt-4o'),
    system: 'You are a helpful coding assistant.',
    prompt,
  })

  return c.json({ text })
})
```

### 반환값 활용

```typescript
app.post('/api/analyze', async (c) => {
  const { prompt } = await c.req.json()

  const result = await generateText({
    model: openai('gpt-4o'),
    prompt,
  })

  return c.json({
    text: result.text,
    usage: result.usage, // 토큰 사용량
    finishReason: result.finishReason, // 완료 이유
  })
})
```

---

## streamText

텍스트를 실시간으로 스트리밍합니다. 긴 응답이나 실시간 피드백이 필요한 경우에 적합합니다.

### 기본 스트리밍

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

app.post('/api/stream', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  return result.toTextStreamResponse()
})
```

### UI 메시지 스트림 (프론트엔드용)

```typescript
import { Hono } from 'hono'
import { streamText, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
  })

  // @ai-sdk/react의 useChat과 호환
  return result.toUIMessageStreamResponse()
})
```

### Hono 스트리밍 헬퍼 사용

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'
import { stream } from 'hono/streaming'

const app = new Hono()

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

### SSE (Server-Sent Events)

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'
import { streamSSE } from 'hono/streaming'

const app = new Hono()

app.post('/api/sse', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  return streamSSE(c, async (stream) => {
    for await (const chunk of result.textStream) {
      await stream.writeSSE({
        data: chunk,
        event: 'message',
      })
    }
    await stream.writeSSE({
      data: '[DONE]',
      event: 'done',
    })
  })
})
```

---

## 스트림 이벤트 처리

### fullStream

모든 이벤트에 접근:

```typescript
app.post('/api/full-stream', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  return stream(c, async (stream) => {
    for await (const event of result.fullStream) {
      switch (event.type) {
        case 'text-delta':
          await stream.write(
            JSON.stringify({ type: 'text', content: event.textDelta }) + '\n'
          )
          break
        case 'tool-call':
          await stream.write(
            JSON.stringify({ type: 'tool', name: event.toolName }) + '\n'
          )
          break
        case 'finish':
          await stream.write(
            JSON.stringify({
              type: 'finish',
              usage: event.usage,
            }) + '\n'
          )
          break
      }
    }
  })
})
```

---

## 시스템 프롬프트 패턴

### 역할 기반 시스템 프롬프트

```typescript
const systemPrompts = {
  coder: 'You are an expert programmer. Provide clean, efficient code.',
  writer: 'You are a professional writer. Create engaging content.',
  analyst: 'You are a data analyst. Provide insights based on data.',
}

app.post('/api/chat/:role', async (c) => {
  const role = c.req.param('role') as keyof typeof systemPrompts
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    system: systemPrompts[role] ?? systemPrompts.coder,
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### 컨텍스트 주입

```typescript
app.post('/api/chat-with-context', async (c) => {
  const { messages, context } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    system: `You are a helpful assistant.

Use the following context to answer questions:
${context}

If the context doesn't contain relevant information, say so.`,
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 에러 처리

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

app.post('/api/chat', async (c) => {
  try {
    const body = await c.req.json()

    if (!body.messages) {
      throw new HTTPException(400, { message: 'Messages required' })
    }

    const result = streamText({
      model: openai('gpt-4o'),
      messages: body.messages,
    })

    return result.toUIMessageStreamResponse()
  } catch (error) {
    if (error instanceof HTTPException) {
      throw error
    }

    console.error('Stream error:', error)
    throw new HTTPException(500, { message: 'AI processing failed' })
  }
})
```

---

## Abort 처리

```typescript
app.post('/api/stream', async (c) => {
  const { prompt } = await c.req.json()

  const abortController = new AbortController()

  // 클라이언트 연결 종료 시 abort
  c.req.raw.signal.addEventListener('abort', () => {
    abortController.abort()
  })

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
    abortSignal: abortController.signal,
  })

  return result.toTextStreamResponse()
})
```

---

## 캐싱 패턴

```typescript
import { Hono } from 'hono'
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

type Bindings = {
  AI_CACHE: KVNamespace // Cloudflare KV
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/generate', async (c) => {
  const { prompt } = await c.req.json()

  // 캐시 키 생성
  const cacheKey = `ai:${btoa(prompt)}`

  // 캐시 확인
  const cached = await c.env.AI_CACHE.get(cacheKey)
  if (cached) {
    return c.json({ text: cached, cached: true })
  }

  // 새로 생성
  const { text } = await generateText({
    model: openai('gpt-4o'),
    prompt,
  })

  // 캐시 저장 (1시간)
  await c.env.AI_CACHE.put(cacheKey, text, { expirationTtl: 3600 })

  return c.json({ text, cached: false })
})
```

---

## 타임아웃 설정

```typescript
app.post('/api/generate', async (c) => {
  const { prompt } = await c.req.json()

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 30000) // 30초

  try {
    const { text } = await generateText({
      model: openai('gpt-4o'),
      prompt,
      abortSignal: controller.signal,
    })

    return c.json({ text })
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      return c.json({ error: 'Request timed out' }, 408)
    }
    throw error
  } finally {
    clearTimeout(timeout)
  }
})
```

---

## 병렬 생성

```typescript
app.post('/api/multi-generate', async (c) => {
  const { prompts } = await c.req.json()

  const results = await Promise.all(
    prompts.map((prompt: string) =>
      generateText({
        model: openai('gpt-4o'),
        prompt,
      })
    )
  )

  return c.json({
    texts: results.map((r) => r.text),
  })
})
```
