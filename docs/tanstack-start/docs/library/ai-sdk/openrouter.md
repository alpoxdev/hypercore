# AI SDK - OpenRouter

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

### 환경 변수

```bash
# .env
OPENROUTER_API_KEY=sk-or-v1-...
```

---

## 모델 사용

### Chat 모델 (권장)

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { generateText } from 'ai'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

const { text } = await generateText({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  prompt: 'Hello!',
})
```

### Completion 모델

```typescript
const { text } = await generateText({
  model: openrouter.completion('meta-llama/llama-3.1-405b-instruct'),
  prompt: 'Write a poem.',
})
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
| `cohere/command-r-plus` | Command R+ |

전체 모델 목록: [OpenRouter Models](https://openrouter.ai/docs#models)

---

## 스트리밍

### streamText

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { streamText } from 'ai'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

const result = streamText({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  prompt: 'Write a short story about AI.',
})

for await (const chunk of result.textStream) {
  process.stdout.write(chunk)
}
```

### React에서 사용

```tsx
'use client'

import { useChat } from '@ai-sdk/react'

export default function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: '/api/chat',
  })

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id}>
          <strong>{m.role}:</strong> {m.content}
        </div>
      ))}

      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} />
        <button type="submit">Send</button>
      </form>
    </div>
  )
}
```

---

## API Route 설정

### TanStack Start API Route

```typescript
// app/routes/api/chat.ts
import { createAPIFileRoute } from '@tanstack/react-start/api'
import { streamText, convertToModelMessages } from 'ai'
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

export const APIRoute = createAPIFileRoute('/api/chat')({
  POST: async ({ request }) => {
    const { messages, model } = await request.json()

    const result = streamText({
      model: openrouter.chat(model ?? 'anthropic/claude-3.5-sonnet'),
      messages: convertToModelMessages(messages),
    })

    return result.toUIMessageStreamResponse()
  },
})
```

### 모델 선택 UI

```tsx
'use client'

import { useChat } from '@ai-sdk/react'
import { useState } from 'react'

const MODELS = [
  { id: 'anthropic/claude-3.5-sonnet', name: 'Claude 3.5 Sonnet' },
  { id: 'openai/gpt-4o', name: 'GPT-4o' },
  { id: 'google/gemini-pro-1.5', name: 'Gemini Pro 1.5' },
  { id: 'meta-llama/llama-3.1-70b-instruct', name: 'Llama 3.1 70B' },
]

export default function Chat() {
  const [selectedModel, setSelectedModel] = useState(MODELS[0].id)

  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: '/api/chat',
    body: {
      model: selectedModel,
    },
  })

  return (
    <div>
      <select
        value={selectedModel}
        onChange={(e) => setSelectedModel(e.target.value)}
      >
        {MODELS.map((model) => (
          <option key={model.id} value={model.id}>
            {model.name}
          </option>
        ))}
      </select>

      {messages.map((m) => (
        <div key={m.id}>
          <strong>{m.role}:</strong> {m.content}
        </div>
      ))}

      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} />
        <button type="submit">Send</button>
      </form>
    </div>
  )
}
```

---

## 구조화된 출력

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { generateObject } from 'ai'
import { z } from 'zod'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

const { object } = await generateObject({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  schema: z.object({
    name: z.string(),
    age: z.number(),
    skills: z.array(z.string()),
  }),
  prompt: 'Generate a developer profile.',
})
```

---

## 도구 사용

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { generateText, tool } from 'ai'
import { z } from 'zod'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

const { text, toolCalls } = await generateText({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  prompt: 'What is the weather in Seoul?',
  tools: {
    getWeather: tool({
      description: 'Get weather for a location',
      inputSchema: z.object({
        location: z.string(),
      }),
      execute: async ({ location }) => {
        return { temperature: 22, condition: 'Sunny' }
      },
    }),
  },
})
```

---

## 고급 설정

### 커스텀 헤더

```typescript
const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
  headers: {
    'HTTP-Referer': 'https://your-app.com',
    'X-Title': 'Your App Name',
  },
})
```

### 모델 파라미터

```typescript
const result = await generateText({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  prompt: 'Hello!',
  temperature: 0.7,
  maxTokens: 1000,
  topP: 0.9,
})
```

---

## 비용 관리

### 사용량 추적

```typescript
const result = await generateText({
  model: openrouter.chat('anthropic/claude-3.5-sonnet'),
  prompt: 'Hello!',
})

console.log('Token usage:', result.usage)
// { promptTokens: 10, completionTokens: 50, totalTokens: 60 }
```

### 모델별 비용

OpenRouter 대시보드에서 실시간으로 모델별 비용을 확인할 수 있습니다:
- [OpenRouter Dashboard](https://openrouter.ai/dashboard)

---

## 에러 처리

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider'
import { generateText } from 'ai'

const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
})

try {
  const { text } = await generateText({
    model: openrouter.chat('anthropic/claude-3.5-sonnet'),
    prompt: 'Hello!',
  })
} catch (error) {
  if (error instanceof Error) {
    console.error('OpenRouter Error:', error.message)
  }
}
```

---

## 리소스

- [OpenRouter 공식 문서](https://openrouter.ai/docs)
- [OpenRouter 대시보드](https://openrouter.ai/dashboard)
- [API 키 발급](https://openrouter.ai/keys)
- [모델 목록](https://openrouter.ai/docs#models)
- [GitHub 저장소](https://github.com/OpenRouterTeam/ai-sdk-provider)
- [상태 페이지](https://status.openrouter.ai)
