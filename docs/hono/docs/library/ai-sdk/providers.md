# AI SDK - 프로바이더 (Hono)

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK 프로바이더를 Hono와 함께 사용하는 방법입니다. Cloudflare Workers 환경에서의 설정을 포함합니다.

---

## 설치

```bash
npm install @ai-sdk/openai      # OpenAI
npm install @ai-sdk/anthropic   # Anthropic (Claude)
npm install @ai-sdk/google      # Google (Gemini)
npm install @ai-sdk/mistral     # Mistral
npm install @ai-sdk/groq        # Groq
```

---

## OpenAI

### 기본 사용

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### Cloudflare Workers 설정

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
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
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### 사용 가능한 모델

| 모델 | 설명 |
|------|------|
| `gpt-4o` | 최신 GPT-4 Omni |
| `gpt-4o-mini` | 경량화된 GPT-4o |
| `gpt-4-turbo` | GPT-4 Turbo |
| `o1` | 추론 최적화 모델 |
| `o1-mini` | 경량 추론 모델 |

---

## Anthropic (Claude)

### 기본 사용

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { anthropic } from '@ai-sdk/anthropic'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: anthropic('claude-3-5-sonnet-20241022'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### Cloudflare Workers 설정

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { createAnthropic } from '@ai-sdk/anthropic'

type Bindings = {
  ANTHROPIC_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const anthropic = createAnthropic({
    apiKey: c.env.ANTHROPIC_API_KEY,
  })

  const { messages } = await c.req.json()

  const result = streamText({
    model: anthropic('claude-3-5-sonnet-20241022'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### 사용 가능한 모델

| 모델 | 설명 |
|------|------|
| `claude-3-5-sonnet-20241022` | Claude 3.5 Sonnet (최신) |
| `claude-3-5-haiku-20241022` | Claude 3.5 Haiku (빠름) |
| `claude-3-opus-20240229` | Claude 3 Opus (강력) |

---

## Google (Gemini)

### 기본 사용

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { google } from '@ai-sdk/google'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: google('gemini-1.5-pro'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### Cloudflare Workers 설정

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { createGoogleGenerativeAI } from '@ai-sdk/google'

type Bindings = {
  GOOGLE_GENERATIVE_AI_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const google = createGoogleGenerativeAI({
    apiKey: c.env.GOOGLE_GENERATIVE_AI_API_KEY,
  })

  const { messages } = await c.req.json()

  const result = streamText({
    model: google('gemini-1.5-pro'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### 사용 가능한 모델

| 모델 | 설명 |
|------|------|
| `gemini-1.5-pro` | Gemini 1.5 Pro |
| `gemini-1.5-flash` | Gemini 1.5 Flash (빠름) |
| `gemini-2.0-flash-exp` | Gemini 2.0 Flash (실험) |

---

## Groq

### 기본 사용

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { groq } from '@ai-sdk/groq'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: groq('llama-3.1-70b-versatile'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

### Cloudflare Workers 설정

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { createGroq } from '@ai-sdk/groq'

type Bindings = {
  GROQ_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const groq = createGroq({
    apiKey: c.env.GROQ_API_KEY,
  })

  const { messages } = await c.req.json()

  const result = streamText({
    model: groq('llama-3.1-70b-versatile'),
    messages,
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 다중 프로바이더 설정

```typescript
import { Hono } from 'hono'
import { streamText } from 'ai'
import { createOpenAI } from '@ai-sdk/openai'
import { createAnthropic } from '@ai-sdk/anthropic'
import { createGoogleGenerativeAI } from '@ai-sdk/google'

type Bindings = {
  OPENAI_API_KEY: string
  ANTHROPIC_API_KEY: string
  GOOGLE_GENERATIVE_AI_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat/:provider', async (c) => {
  const provider = c.req.param('provider')
  const { messages } = await c.req.json()

  let model

  switch (provider) {
    case 'openai':
      const openai = createOpenAI({ apiKey: c.env.OPENAI_API_KEY })
      model = openai('gpt-4o')
      break
    case 'anthropic':
      const anthropic = createAnthropic({ apiKey: c.env.ANTHROPIC_API_KEY })
      model = anthropic('claude-3-5-sonnet-20241022')
      break
    case 'google':
      const google = createGoogleGenerativeAI({
        apiKey: c.env.GOOGLE_GENERATIVE_AI_API_KEY,
      })
      model = google('gemini-1.5-pro')
      break
    default:
      return c.json({ error: 'Unknown provider' }, 400)
  }

  const result = streamText({ model, messages })

  return result.toUIMessageStreamResponse()
})
```

---

## 프로바이더 미들웨어

```typescript
import { Hono } from 'hono'
import { createMiddleware } from 'hono/factory'
import { streamText } from 'ai'
import { createOpenAI } from '@ai-sdk/openai'
import { createAnthropic } from '@ai-sdk/anthropic'

type Bindings = {
  OPENAI_API_KEY: string
  ANTHROPIC_API_KEY: string
}

type Variables = {
  providers: {
    openai: ReturnType<typeof createOpenAI>
    anthropic: ReturnType<typeof createAnthropic>
  }
}

const providersMiddleware = createMiddleware<{
  Bindings: Bindings
  Variables: Variables
}>(async (c, next) => {
  c.set('providers', {
    openai: createOpenAI({ apiKey: c.env.OPENAI_API_KEY }),
    anthropic: createAnthropic({ apiKey: c.env.ANTHROPIC_API_KEY }),
  })
  await next()
})

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

app.use('/api/*', providersMiddleware)

app.post('/api/chat', async (c) => {
  const { messages, provider = 'openai' } = await c.req.json()
  const providers = c.get('providers')

  const model =
    provider === 'anthropic'
      ? providers.anthropic('claude-3-5-sonnet-20241022')
      : providers.openai('gpt-4o')

  const result = streamText({ model, messages })

  return result.toUIMessageStreamResponse()
})
```

---

## 모델 파라미터

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  messages,

  // 공통 파라미터
  temperature: 0.7, // 창의성 (0-2)
  maxTokens: 1000, // 최대 토큰 수
  topP: 0.9, // 핵 샘플링
  frequencyPenalty: 0.5, // 반복 억제
  presencePenalty: 0.5, // 새로운 주제 유도
  stopSequences: ['\n\n'], // 생성 중단 시퀀스
})
```

---

## OpenRouter (통합 게이트웨이)

하나의 API 키로 수백 개 모델에 접근할 수 있는 통합 게이트웨이입니다.

### 설치

```bash
npm install @openrouter/ai-sdk-provider
```

### Hono 사용

```typescript
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
```

### 인기 모델

| 모델 ID | 설명 |
|---------|------|
| `anthropic/claude-3.5-sonnet` | Claude 3.5 Sonnet |
| `openai/gpt-4o` | GPT-4o |
| `google/gemini-pro-1.5` | Gemini Pro 1.5 |
| `meta-llama/llama-3.1-70b-instruct` | Llama 3.1 70B |

자세한 내용: [OpenRouter 가이드](./openrouter.md)

---

## 환경 변수 설정

### .env (로컬 개발)

```bash
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_GENERATIVE_AI_API_KEY=...
GROQ_API_KEY=gsk_...
MISTRAL_API_KEY=...
OPENROUTER_API_KEY=sk-or-v1-...
```

### wrangler.toml (Cloudflare Workers)

```toml
[vars]
# 민감하지 않은 변수만 여기에

# 민감한 키는 Cloudflare 대시보드에서 설정:
# Settings > Variables > Environment Variables
```

### Cloudflare 대시보드 설정

1. Workers & Pages > 프로젝트 선택
2. Settings > Variables
3. Environment Variables에서 API 키 추가
