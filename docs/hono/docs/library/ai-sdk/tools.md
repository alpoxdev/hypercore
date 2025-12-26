# AI SDK - Tool Calling

> AI 모델이 외부 함수를 호출

---

## 기본 도구 정의

```typescript
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      getWeather: tool({
        description: 'Get the weather for a location',
        inputSchema: z.object({
          location: z.string().describe('The city name'),
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

## tool() 구조

```typescript
import { tool } from 'ai'
import { z } from 'zod'

const myTool = tool({
  description: 'Tool description for the AI',
  inputSchema: z.object({
    param1: z.string().describe('Parameter description'),
    param2: z.number().optional(),
  }),
  execute: async (args, context) => {
    // args: 스키마에 맞는 입력값
    // context: { toolCallId, messages }
    return { result: 'success' }
  },
})
```

---

## 여러 도구

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  messages: convertToModelMessages(messages),
  tools: {
    getWeather: tool({
      description: 'Get weather',
      inputSchema: z.object({ location: z.string() }),
      execute: async ({ location }) => {
        return { temperature: 22, condition: 'Sunny' }
      },
    }),
    searchDatabase: tool({
      description: 'Search the database',
      inputSchema: z.object({ query: z.string() }),
      execute: async ({ query }) => {
        return { results: [] }
      },
    }),
    sendEmail: tool({
      description: 'Send an email',
      inputSchema: z.object({
        to: z.email(),
        subject: z.string(),
        body: z.string(),
      }),
      execute: async (args) => {
        return { sent: true }
      },
    }),
  },
})
```

---

## 다단계 도구 호출

```typescript
import { generateText } from 'ai'

const { text, steps } = await generateText({
  model: openai('gpt-4o'),
  messages: convertToModelMessages(messages),
  tools: { ... },
  maxSteps: 5, // 최대 도구 호출 횟수
})

// steps: 각 단계의 도구 호출 정보
```

---

## 도구 선택 제어

```typescript
const result = streamText({
  model: openai('gpt-4o'),
  messages,
  tools: { ... },

  // 도구 사용 강제
  toolChoice: 'required',

  // 특정 도구만
  toolChoice: { type: 'tool', toolName: 'getWeather' },

  // 도구 사용 금지
  toolChoice: 'none',

  // 자동 (기본)
  toolChoice: 'auto',
})
```

---

## 관련 문서

- [AI SDK 개요](./index.md)
- [스트리밍](./streaming.md)
- [구조화된 출력](./structured-output.md)
