# AI SDK - Hono 통합

> Vercel AI SDK + Hono

@providers.md
@openrouter.md
@streaming.md
@tools.md
@structured-output.md

---

## 설치

```bash
npm install ai @ai-sdk/openai

# 다른 프로바이더
npm install @ai-sdk/anthropic  # Claude
npm install @ai-sdk/google     # Gemini
```

---

## 핵심 함수

| 함수 | 용도 |
|------|------|
| `generateText` | 텍스트 생성 (비스트리밍) |
| `streamText` | 텍스트 스트리밍 |
| `generateObject` | 구조화된 객체 생성 |
| `streamObject` | 객체 스트리밍 |

---

## 기본 채팅 API

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

  return result.toUIMessageStreamResponse()
})
```

---

## 텍스트 생성

```typescript
import { generateText } from 'ai'

app.post('/api/generate', async (c) => {
  const { prompt } = await c.req.json()

  const { text } = await generateText({
    model: openai('gpt-4o'),
    prompt,
  })

  return c.json({ text })
})
```

---

## 도구 (Tool)

```typescript
import { streamText, tool, convertToModelMessages } from 'ai'
import { z } from 'zod'

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      getWeather: tool({
        description: 'Get weather for a location',
        inputSchema: z.object({
          location: z.string().describe('City name'),
        }),
        execute: async ({ location }) => {
          return { location, temperature: 22, condition: 'Sunny' }
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 구조화된 출력

```typescript
import { generateObject } from 'ai'
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),
  age: z.number(),
  email: z.email(),
})

app.post('/api/generate-user', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: userSchema,
    prompt,
  })

  return c.json(object)
})
```

---

## Cloudflare Workers

```typescript
import { createOpenAI } from '@ai-sdk/openai'

type Bindings = { OPENAI_API_KEY: string }

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const openai = createOpenAI({ apiKey: c.env.OPENAI_API_KEY })
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 에러 처리

```typescript
import { HTTPException } from 'hono/http-exception'

app.post('/api/chat', async (c) => {
  try {
    const { messages } = await c.req.json()

    if (!messages || !Array.isArray(messages)) {
      throw new HTTPException(400, { message: 'Invalid messages' })
    }

    const result = streamText({ model: openai('gpt-4o'), messages })
    return result.toUIMessageStreamResponse()
  } catch (error) {
    console.error('AI Error:', error)
    throw new HTTPException(500, { message: 'AI processing failed' })
  }
})
```

---

## 관련 문서

- [프로바이더](./providers.md)
- [OpenRouter](./openrouter.md)
- [스트리밍](./streaming.md)
- [도구](./tools.md)
- [구조화된 출력](./structured-output.md)
