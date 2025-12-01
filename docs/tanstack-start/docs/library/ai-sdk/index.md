# Vercel AI SDK

> **Version**: 4.x / 5.x | TypeScript AI Toolkit

---

## 🚀 Quick Reference (복사용)

```typescript
// 텍스트 생성
import { generateText, streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const { text } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello, world!',
})

// 스트리밍
const result = streamText({
  model: openai('gpt-4o'),
  prompt: 'Write a story.',
})

for await (const chunk of result.textStream) {
  console.log(chunk)
}

// 구조화된 출력
import { generateObject } from 'ai'
import { z } from 'zod'

const { object } = await generateObject({
  model: openai('gpt-4o'),
  schema: z.object({ name: z.string(), age: z.number() }),
  prompt: 'Generate a user.',
})

// React Hook
import { useChat } from '@ai-sdk/react'

const { messages, input, handleInputChange, handleSubmit } = useChat()
```

---

## 문서 구조

- [프로바이더 설정](./providers.md) - OpenAI, Anthropic, Google 등
- [OpenRouter](./openrouter.md) - 통합 AI 게이트웨이 (수백 개 모델)
- [텍스트 생성](./streaming.md) - generateText, streamText
- [React Hooks](./hooks.md) - useChat, useCompletion
- [Tool Calling](./tools.md) - 도구 정의 및 호출
- [구조화된 출력](./structured-output.md) - generateObject, 스키마 기반 출력

---

## 설치

```bash
# 코어 패키지
npm install ai

# 프로바이더 패키지 (필요한 것만 설치)
npm install @ai-sdk/openai      # OpenAI
npm install @ai-sdk/anthropic   # Anthropic (Claude)
npm install @ai-sdk/google      # Google (Gemini)

# React Hook 사용 시
npm install @ai-sdk/react
```

---

## 핵심 개념

### 프로바이더 (Providers)

AI 모델 서비스와의 연결을 담당합니다.

```typescript
import { openai } from '@ai-sdk/openai'
import { anthropic } from '@ai-sdk/anthropic'
import { google } from '@ai-sdk/google'

// 모델 인스턴스 생성
const gpt4 = openai('gpt-4o')
const claude = anthropic('claude-3-5-sonnet-20241022')
const gemini = google('gemini-1.5-pro')
```

### 코어 함수

| 함수 | 용도 | 반환 |
|------|------|------|
| `generateText` | 텍스트 생성 (비스트리밍) | `{ text, toolCalls, ... }` |
| `streamText` | 텍스트 스트리밍 | `{ textStream, ... }` |
| `generateObject` | 구조화된 객체 생성 | `{ object }` |
| `streamObject` | 구조화된 객체 스트리밍 | `{ partialObjectStream }` |

### React Hooks

| Hook | 용도 |
|------|------|
| `useChat` | 채팅 인터페이스 |
| `useCompletion` | 텍스트 완성 |
| `useObject` | 구조화된 객체 생성 (실험적) |

---

## 기본 사용법

### 텍스트 생성

```typescript
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

const { text, usage } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Explain quantum computing in simple terms.',
})

console.log(text)
console.log(`Tokens used: ${usage.totalTokens}`)
```

### 스트리밍

```typescript
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const result = streamText({
  model: openai('gpt-4o'),
  prompt: 'Write a haiku about programming.',
})

for await (const chunk of result.textStream) {
  process.stdout.write(chunk)
}
```

### 채팅 (메시지 기반)

```typescript
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

const { text } = await generateText({
  model: openai('gpt-4o'),
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: 'What is TypeScript?' },
  ],
})
```

---

## TanStack Start 통합

### API Route 설정

```typescript
// app/api/chat/route.ts
import { streamText, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
  })

  return result.toUIMessageStreamResponse()
}
```

### 클라이언트 컴포넌트

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
        <input value={input} onChange={handleInputChange} placeholder="Say something..." />
        <button type="submit">Send</button>
      </form>
    </div>
  )
}
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

## v5 주요 변경사항

### 스트림 프로토콜 변경

```typescript
// v4 - text protocol 명시 필요
const { messages } = useChat({ streamProtocol: 'text' })

// v5 - 기본값이 data protocol
const { messages } = useChat()
```

### 프로바이더 초기화 변경

```typescript
// v4 (deprecated)
const openai = new OpenAI({ /* ... */ })

// v5
import { createOpenAI } from '@ai-sdk/openai'
const openai = createOpenAI({ /* ... */ })
```

### responseMessages 제거

```typescript
// v4
const { text, responseMessages } = await generateText({ ... })

// v5
const { text, response } = await generateText({ ... })
const responseMessages = response.messages
```

---

## 참고 자료

- [AI SDK 공식 문서](https://sdk.vercel.ai/docs)
- [AI SDK GitHub](https://github.com/vercel/ai)
- [AI SDK 예제](https://github.com/vercel/ai/tree/main/examples)
