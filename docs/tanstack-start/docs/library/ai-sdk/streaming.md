# AI SDK - 텍스트 생성

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK는 두 가지 주요 텍스트 생성 방식을 제공합니다:
- `generateText`: 전체 응답을 한 번에 반환
- `streamText`: 실시간 스트리밍 응답

---

## generateText

전체 응답이 완료될 때까지 기다린 후 결과를 반환합니다.

### 기본 사용

```typescript
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

const { text, usage, finishReason } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Explain quantum computing.',
})

console.log(text)
console.log(`Tokens: ${usage.totalTokens}`)
console.log(`Finish reason: ${finishReason}`)
```

### 메시지 기반 (채팅)

```typescript
import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'

const { text } = await generateText({
  model: openai('gpt-4o'),
  system: 'You are a helpful assistant.',
  messages: [
    { role: 'user', content: 'What is TypeScript?' },
    { role: 'assistant', content: 'TypeScript is a typed superset of JavaScript.' },
    { role: 'user', content: 'How do I get started?' },
  ],
})
```

### 반환값

```typescript
const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',
})

// 주요 속성
result.text           // 생성된 텍스트
result.usage          // { promptTokens, completionTokens, totalTokens }
result.finishReason   // 'stop' | 'length' | 'content-filter' | 'tool-calls' | ...
result.toolCalls      // 도구 호출 목록
result.toolResults    // 도구 실행 결과
result.response       // 원본 응답 객체
result.steps          // 다중 단계 실행 시 각 단계 정보
```

---

## streamText

실시간으로 응답을 스트리밍합니다. 사용자 경험이 중요한 채팅 애플리케이션에 적합합니다.

### 기본 사용

```typescript
import { streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const result = streamText({
  model: openai('gpt-4o'),
  prompt: 'Write a haiku about programming.',
})

// AsyncIterable로 스트리밍
for await (const chunk of result.textStream) {
  process.stdout.write(chunk)
}
```

### 메시지 기반 스트리밍

```typescript
import { streamText, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'

const result = streamText({
  model: openai('gpt-4o'),
  system: 'You are a helpful assistant.',
  messages: convertToModelMessages([
    { id: '1', role: 'user', content: 'Hello!' },
    { id: '2', role: 'assistant', content: 'Hi there!' },
    { id: '3', role: 'user', content: 'How are you?' },
  ]),
})

for await (const chunk of result.textStream) {
  console.log(chunk)
}
```

### 스트리밍 속성

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',
})

// 다양한 스트림 접근
result.textStream        // 텍스트만 스트리밍
result.fullStream        // 전체 이벤트 스트리밍 (도구 호출 포함)

// 최종 결과 (Promise)
const finalText = await result.text
const finalUsage = await result.usage
const finalFinishReason = await result.finishReason
```

### fullStream 이벤트

```typescript
for await (const event of result.fullStream) {
  switch (event.type) {
    case 'text-delta':
      console.log('Text:', event.textDelta)
      break
    case 'tool-call':
      console.log('Tool call:', event.toolName, event.input)
      break
    case 'tool-result':
      console.log('Tool result:', event.output)
      break
    case 'finish':
      console.log('Finished:', event.finishReason)
      break
    case 'error':
      console.error('Error:', event.error)
      break
  }
}
```

---

## API Route에서 사용

### TanStack Start / Next.js

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

  // UI 메시지 스트림으로 변환
  return result.toUIMessageStreamResponse()
}
```

### 텍스트 스트림으로 반환

```typescript
export async function POST(req: Request) {
  const { prompt } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    prompt,
  })

  // 순수 텍스트 스트림
  return result.toTextStreamResponse()
}
```

### 에러 핸들링

```typescript
export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
  })

  // 에러 메시지를 UI로 전달
  return result.toUIMessageStreamResponse({
    getErrorMessage: (error) => {
      if (error instanceof Error) {
        return error.message
      }
      return 'An error occurred'
    },
  })
}
```

---

## 고급 옵션

### 온도 및 토큰 제한

```typescript
const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Write a creative story.',
  temperature: 0.9,      // 높을수록 창의적 (0-2)
  maxTokens: 2000,       // 최대 출력 토큰
  topP: 0.95,            // 핵 샘플링
})
```

### 중단 조건

```typescript
import { generateText, stopWhen, stepCountIs } from 'ai'

const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Solve this problem step by step.',
  stopWhen: stepCountIs(5), // 최대 5단계
})
```

### 응답 메시지 접근

```typescript
const { text, response } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',
})

// v5에서 responseMessages 접근 방법
const responseMessages = response.messages
```

---

## onFinish 콜백

스트리밍 완료 시 실행되는 콜백:

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  prompt: 'Hello!',
  onFinish: async ({ text, usage, finishReason }) => {
    console.log('Completed:', text)
    console.log('Tokens used:', usage.totalTokens)

    // DB에 저장 등
    await saveToDatabase({ text, usage })
  },
})
```

---

## TanStack Start Server Function 통합

```typescript
// lib/ai.ts
import { createServerFn } from '@tanstack/react-start'
import { generateText, streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

// 비스트리밍 버전
export const generateResponse = createServerFn({ method: 'POST' })
  .inputValidator((data: { prompt: string }) => data)
  .handler(async ({ data }) => {
    const { text } = await generateText({
      model: openai('gpt-4o'),
      prompt: data.prompt,
    })
    return { text }
  })

// 스트리밍은 API Route 사용 권장
```

---

## 파라미터 요약

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `model` | Model | AI 모델 인스턴스 |
| `prompt` | string | 단일 프롬프트 |
| `messages` | Message[] | 메시지 배열 (채팅) |
| `system` | string | 시스템 프롬프트 |
| `temperature` | number | 창의성 (0-2) |
| `maxTokens` | number | 최대 출력 토큰 |
| `topP` | number | 핵 샘플링 (0-1) |
| `frequencyPenalty` | number | 반복 억제 (-2 to 2) |
| `presencePenalty` | number | 새로운 주제 유도 (-2 to 2) |
| `stopSequences` | string[] | 생성 중단 시퀀스 |
| `tools` | ToolSet | 도구 정의 |
| `onFinish` | Function | 완료 콜백 |
