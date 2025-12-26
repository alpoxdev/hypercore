# AI SDK - 프로바이더

> 다양한 AI 프로바이더 설정

---

## 설치

```bash
npm install @ai-sdk/openai      # OpenAI
npm install @ai-sdk/anthropic   # Claude
npm install @ai-sdk/google      # Gemini
npm install @ai-sdk/mistral     # Mistral
npm install @ai-sdk/groq        # Groq
```

---

## OpenAI

```typescript
import { openai } from '@ai-sdk/openai'

const result = streamText({
  model: openai('gpt-4o'),
  messages,
})
```

### Cloudflare Workers

```typescript
import { createOpenAI } from '@ai-sdk/openai'

type Bindings = { OPENAI_API_KEY: string }
const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const openai = createOpenAI({ apiKey: c.env.OPENAI_API_KEY })
  const result = streamText({ model: openai('gpt-4o'), messages })
  return result.toUIMessageStreamResponse()
})
```

### 모델

| 모델 | 설명 |
|------|------|
| `gpt-4o` | GPT-4 Omni |
| `gpt-4o-mini` | 경량 GPT-4o |
| `o1` | 추론 최적화 |

---

## Anthropic (Claude)

```typescript
import { anthropic } from '@ai-sdk/anthropic'

const result = streamText({
  model: anthropic('claude-3-5-sonnet-latest'),
  messages,
})
```

### 모델

| 모델 | 설명 |
|------|------|
| `claude-3-5-sonnet-latest` | Claude 3.5 Sonnet |
| `claude-3-opus-latest` | Claude 3 Opus |
| `claude-3-haiku-latest` | 경량 모델 |

---

## Google (Gemini)

```typescript
import { google } from '@ai-sdk/google'

const result = streamText({
  model: google('gemini-1.5-pro'),
  messages,
})
```

---

## 환경 변수

```bash
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_GENERATIVE_AI_API_KEY=...
```

---

## 관련 문서

- [AI SDK 개요](./index.md)
- [OpenRouter](./openrouter.md)
