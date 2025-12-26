# AI SDK - OpenRouter

> 수백 개 모델을 단일 API로

---

## 설치

```bash
npm install @openrouter/ai-sdk-provider
```

---

## 기본 사용

```typescript
import { Hono } from 'hono'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 동적 모델 선택

```typescript
import { HTTPException } from 'hono/http-exception'

const ALLOWED_MODELS = [
  'anthropic/claude-3.5-sonnet',
  'openai/gpt-4o',
  'google/gemini-pro-1.5',
  'meta-llama/llama-3.1-70b-instruct',
]

app.post('/api/chat', async (c) => {
  const { messages, model } = await c.req.json()

  if (!ALLOWED_MODELS.includes(model)) {
    throw new HTTPException(400, { message: 'Invalid model' })
  }

  const result = streamText({
    model: openrouter.chat(model),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})
```

---

## Cloudflare Workers

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

type Bindings = { OPENROUTER_API_KEY: string }

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const openrouter = createOpenRouter({
    apiKey: c.env.OPENROUTER_API_KEY,
  })

  const { messages, model } = await c.req.json()

  const result = streamText({
    model: openrouter.chat(model ?? 'anthropic/claude-3.5-sonnet'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 주요 모델

| 프로바이더 | 모델 |
|-----------|------|
| Anthropic | `anthropic/claude-3.5-sonnet`, `anthropic/claude-3-opus` |
| OpenAI | `openai/gpt-4o`, `openai/gpt-4-turbo` |
| Google | `google/gemini-pro-1.5` |
| Meta | `meta-llama/llama-3.1-70b-instruct` |

---

## 관련 문서

- [AI SDK 개요](./index.md)
- [프로바이더](./providers.md)
