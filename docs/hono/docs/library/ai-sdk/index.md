# AI SDK - Hono 통합 가이드

> Vercel AI SDK를 Hono와 함께 사용하기

---

## 개요

AI SDK는 TypeScript 기반의 AI 애플리케이션 개발 라이브러리입니다. Hono의 경량화된 API와 결합하여 고성능 AI 엔드포인트를 구축할 수 있습니다.

---

## 설치

```bash
npm install ai @ai-sdk/openai
```

### 프로바이더별 설치

```bash
npm install @ai-sdk/anthropic   # Claude
npm install @ai-sdk/google      # Gemini
npm install @ai-sdk/mistral     # Mistral
npm install @ai-sdk/groq        # Groq
```

---

## 빠른 시작

### 기본 채팅 API

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

export default app
```

### 텍스트 생성 API

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

export default app
```

---

## 핵심 함수

| 함수 | 용도 | 응답 타입 |
|------|------|----------|
| `generateText` | 텍스트 생성 (비스트리밍) | `Promise<{ text }>` |
| `streamText` | 텍스트 스트리밍 | `StreamTextResult` |
| `generateObject` | 구조화된 객체 생성 | `Promise<{ object }>` |
| `streamObject` | 객체 스트리밍 | `StreamObjectResult` |

---

## Hono 미들웨어 패턴

### AI 컨텍스트 미들웨어

```typescript
import { Hono } from 'hono'
import { createMiddleware } from 'hono/factory'
import { openai } from '@ai-sdk/openai'

type AIVariables = {
  aiModel: ReturnType<typeof openai>
}

const aiMiddleware = createMiddleware<{ Variables: AIVariables }>(
  async (c, next) => {
    c.set('aiModel', openai('gpt-4o'))
    await next()
  }
)

const app = new Hono<{ Variables: AIVariables }>()

app.use('/api/ai/*', aiMiddleware)

app.post('/api/ai/chat', async (c) => {
  const model = c.get('aiModel')
  const { messages } = await c.req.json()

  const result = streamText({
    model,
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### Rate Limiting 미들웨어

```typescript
import { Hono } from 'hono'
import { rateLimiter } from 'hono-rate-limiter'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

// AI 엔드포인트에 Rate Limiting 적용
app.use(
  '/api/ai/*',
  rateLimiter({
    windowMs: 60 * 1000, // 1분
    limit: 10, // 최대 10 요청
    standardHeaders: 'draft-6',
    keyGenerator: (c) => c.req.header('x-forwarded-for') ?? 'anonymous',
  })
)

app.post('/api/ai/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 스트리밍 응답 처리

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

  // UI 메시지 스트림 (프론트엔드용)
  return result.toUIMessageStreamResponse()
})

app.post('/api/stream-text', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  // 텍스트 스트림 (SSE)
  return result.toTextStreamResponse()
})
```

### 커스텀 스트림 처리

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

---

## 도구 (Tool) 통합

```typescript
import { Hono } from 'hono'
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

app.post('/api/chat-with-tools', async (c) => {
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
          // 실제 날씨 API 호출
          return { location, temperature: 22, condition: 'Sunny' }
        },
      }),
      searchDatabase: tool({
        description: 'Search the database',
        inputSchema: z.object({
          query: z.string(),
        }),
        execute: async ({ query }) => {
          // 데이터베이스 검색
          return { results: [] }
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
import { Hono } from 'hono'
import { generateObject, streamObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

const userSchema = z.object({
  name: z.string(),
  age: z.number(),
  email: z.string().email(),
})

// 비스트리밍 객체 생성
app.post('/api/generate-user', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: userSchema,
    prompt,
  })

  return c.json(object)
})

// 스트리밍 객체 생성
app.post('/api/stream-user', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema: userSchema,
    prompt,
  })

  return result.toTextStreamResponse()
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
    const { messages } = await c.req.json()

    if (!messages || !Array.isArray(messages)) {
      throw new HTTPException(400, { message: 'Invalid messages format' })
    }

    const result = streamText({
      model: openai('gpt-4o'),
      messages,
    })

    return result.toUIMessageStreamResponse()
  } catch (error) {
    if (error instanceof HTTPException) {
      throw error
    }

    console.error('AI Error:', error)
    throw new HTTPException(500, { message: 'AI processing failed' })
  }
})

// 글로벌 에러 핸들러
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  return c.json({ error: 'Internal server error' }, 500)
})
```

---

## Cloudflare Workers 배포

### 기본 설정

```typescript
// src/index.ts
import { Hono } from 'hono'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenAI } from '@ai-sdk/openai'

type Bindings = {
  OPENAI_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const openai = createOpenAI({
    apiKey: c.env.OPENAI_API_KEY,
  })

  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})

export default app
```

### wrangler.toml

```toml
name = "ai-api"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
# 환경 변수는 Cloudflare 대시보드에서 설정
```

---

## 환경 변수

```bash
# .env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_GENERATIVE_AI_API_KEY=...
```

---

## 관련 문서

- [프로바이더](./providers.md) - AI 프로바이더 설정
- [OpenRouter](./openrouter.md) - 통합 AI 게이트웨이 (수백 개 모델)
- [스트리밍](./streaming.md) - 텍스트 생성과 스트리밍
- [도구](./tools.md) - Tool Calling 구현
- [구조화된 출력](./structured-output.md) - 타입 안전한 객체 생성
