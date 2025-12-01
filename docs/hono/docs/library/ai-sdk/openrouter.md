# AI SDK - OpenRouter (Hono)

> **상위 문서**: [AI SDK](./index.md) | [프로바이더](./providers.md)

---

## 개요

[OpenRouter](https://openrouter.ai/)는 Anthropic, Google, Meta, Mistral 등 주요 AI 프로바이더의 수백 개 모델에 단일 API로 접근할 수 있는 통합 게이트웨이입니다.

### 주요 장점

| 장점 | 설명 |
|------|------|
| **통합 API** | 하나의 API 키로 수백 개 모델 접근 |
| **비용 효율** | 월정액 없이 사용량 기반 과금 |
| **투명한 가격** | 모델별 토큰당 비용 명확히 표시 |
| **고가용성** | 엔터프라이즈급 인프라와 자동 장애 조치 |
| **최신 모델** | 새 모델 출시 즉시 사용 가능 |

---

## 설치

```bash
npm install @openrouter/ai-sdk-provider
```

---

## 기본 설정

### Provider 인스턴스 생성

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})
```

API 키는 [OpenRouter Dashboard](https://openrouter.ai/keys)에서 발급받을 수 있습니다.

---

## Hono 통합

### 기본 채팅 API

```typescript
import { Hono } from 'hono'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

const app = new Hono()

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

export default app
```

### 동적 모델 선택

```typescript
import { Hono } from 'hono'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { HTTPException } from 'hono/http-exception'

const app = new Hono()

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

// 허용된 모델 목록
const ALLOWED_MODELS = [
  'anthropic/claude-3.5-sonnet',
  'anthropic/claude-3-opus',
  'openai/gpt-4o',
  'openai/gpt-4-turbo',
  'google/gemini-pro-1.5',
  'meta-llama/llama-3.1-70b-instruct',
]

app.post('/api/chat', async (c) => {
  const { messages, model = 'anthropic/claude-3.5-sonnet' } = await c.req.json()

  // 모델 검증
  if (!ALLOWED_MODELS.includes(model)) {
    throw new HTTPException(400, { message: 'Invalid model' })
  }

  const result = streamText({
    model: openrouter.chat(model),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})

export default app
```

---

## Cloudflare Workers 배포

### 기본 설정

```typescript
// src/index.ts
import { Hono } from 'hono'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

type Bindings = {
  OPENROUTER_API_KEY: string
}

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

export default app
```

### wrangler.toml

```toml
name = "ai-api"
main = "src/index.ts"
compatibility_date = "2024-01-01"

# API 키는 Cloudflare 대시보드에서 설정
# Settings > Variables > Environment Variables
```

---

## 인기 모델

| 모델 ID | 설명 |
|---------|------|
| `anthropic/claude-3.5-sonnet` | Claude 3.5 Sonnet |
| `anthropic/claude-3-opus` | Claude 3 Opus |
| `openai/gpt-4o` | GPT-4o |
| `openai/gpt-4-turbo` | GPT-4 Turbo |
| `google/gemini-pro-1.5` | Gemini Pro 1.5 |
| `meta-llama/llama-3.1-405b-instruct` | Llama 3.1 405B |
| `meta-llama/llama-3.1-70b-instruct` | Llama 3.1 70B |
| `mistralai/mistral-large` | Mistral Large |

전체 모델 목록: [OpenRouter Models](https://openrouter.ai/docs#models)

---

## 도구 사용

```typescript
import { Hono } from 'hono'
import { streamText, tool, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { z } from 'zod'

type Bindings = {
  OPENROUTER_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/assistant', async (c) => {
  const openrouter = createOpenRouter({
    apiKey: c.env.OPENROUTER_API_KEY,
  })

  const { messages } = await c.req.json()

  const result = streamText({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
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
      searchProducts: tool({
        description: 'Search products in database',
        inputSchema: z.object({
          query: z.string(),
          limit: z.number().optional().default(10),
        }),
        execute: async ({ query, limit }) => {
          // 데이터베이스 검색
          return { products: [], total: 0 }
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})

export default app
```

---

## 구조화된 출력

```typescript
import { Hono } from 'hono'
import { generateObject } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { z } from 'zod'

type Bindings = {
  OPENROUTER_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

const userSchema = z.object({
  name: z.string(),
  age: z.number(),
  skills: z.array(z.string()),
})

app.post('/api/generate-user', async (c) => {
  const openrouter = createOpenRouter({
    apiKey: c.env.OPENROUTER_API_KEY,
  })

  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
    schema: userSchema,
    prompt,
  })

  return c.json(object)
})

export default app
```

---

## 미들웨어 패턴

### OpenRouter 미들웨어

```typescript
import { Hono } from 'hono'
import { createMiddleware } from 'hono/factory'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

type Bindings = {
  OPENROUTER_API_KEY: string
}

type Variables = {
  openrouter: ReturnType<typeof createOpenRouter>
}

const openrouterMiddleware = createMiddleware<{
  Bindings: Bindings
  Variables: Variables
}>(async (c, next) => {
  const openrouter = createOpenRouter({
    apiKey: c.env.OPENROUTER_API_KEY,
  })
  c.set('openrouter', openrouter)
  await next()
})

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

app.use('/api/*', openrouterMiddleware)

app.post('/api/chat', async (c) => {
  const openrouter = c.get('openrouter')
  const { messages } = await c.req.json()

  const result = streamText({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})

export default app
```

### Rate Limiting

```typescript
import { Hono } from 'hono'
import { rateLimiter } from 'hono-rate-limiter'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

type Bindings = {
  OPENROUTER_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

// Rate limiting 적용
app.use(
  '/api/*',
  rateLimiter({
    windowMs: 60 * 1000, // 1분
    limit: 20, // 최대 20 요청
    standardHeaders: 'draft-6',
    keyGenerator: (c) => c.req.header('x-forwarded-for') ?? 'anonymous',
  })
)

app.post('/api/chat', async (c) => {
  const openrouter = createOpenRouter({
    apiKey: c.env.OPENROUTER_API_KEY,
  })

  const { messages } = await c.req.json()

  const result = streamText({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
})

export default app
```

---

## 에러 처리

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

type Bindings = {
  OPENROUTER_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  try {
    const openrouter = createOpenRouter({
      apiKey: c.env.OPENROUTER_API_KEY,
    })

    const body = await c.req.json()

    if (!body.messages || !Array.isArray(body.messages)) {
      throw new HTTPException(400, { message: 'Invalid messages format' })
    }

    const result = streamText({
      model: openrouter.chat(body.model ?? 'anthropic/claude-3.5-sonnet'),
      messages: convertToModelMessages(body.messages),
    })

    return result.toUIMessageStreamResponse()
  } catch (error) {
    if (error instanceof HTTPException) {
      throw error
    }

    console.error('OpenRouter Error:', error)
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

export default app
```

---

## 비용 관리

### 사용량 추적

```typescript
app.post('/api/generate', async (c) => {
  const openrouter = createOpenRouter({
    apiKey: c.env.OPENROUTER_API_KEY,
  })

  const { prompt } = await c.req.json()

  const result = await generateText({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
    prompt,
  })

  return c.json({
    text: result.text,
    usage: result.usage,
    // { promptTokens: 10, completionTokens: 50, totalTokens: 60 }
  })
})
```

---

## 환경 변수

```bash
# .env (로컬 개발)
OPENROUTER_API_KEY=sk-or-v1-...
```

```toml
# wrangler.toml (Cloudflare Workers)
# API 키는 Cloudflare 대시보드에서 설정:
# Settings > Variables > Environment Variables
```

---

## 리소스

- [OpenRouter 공식 문서](https://openrouter.ai/docs)
- [OpenRouter 대시보드](https://openrouter.ai/dashboard)
- [API 키 발급](https://openrouter.ai/keys)
- [모델 목록](https://openrouter.ai/docs#models)
- [GitHub 저장소](https://github.com/OpenRouterTeam/ai-sdk-provider)
- [상태 페이지](https://status.openrouter.ai)
