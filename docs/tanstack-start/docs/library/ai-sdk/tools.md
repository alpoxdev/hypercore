# AI SDK - Tool Calling

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK의 도구(Tool)를 사용하면 AI 모델이 외부 함수를 호출할 수 있습니다. 날씨 조회, 데이터베이스 검색, API 호출 등 다양한 작업을 수행할 수 있습니다.

---

## 기본 도구 정의

```typescript
import { generateText, tool } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const { text, toolCalls, toolResults } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'What is the weather in Seoul?',
  tools: {
    getWeather: tool({
      description: 'Get the weather for a location',
      inputSchema: z.object({
        location: z.string().describe('The city name'),
      }),
      execute: async ({ location }) => {
        // 실제 날씨 API 호출
        return {
          location,
          temperature: 22,
          condition: 'Sunny',
        }
      },
    }),
  },
})
```

---

## tool() 함수 구조

```typescript
import { tool } from 'ai'
import { z } from 'zod'

const myTool = tool({
  // 도구 설명 (모델이 언제 사용할지 결정하는데 사용)
  description: 'Tool description for the AI model',

  // 입력 스키마 (Zod로 정의)
  inputSchema: z.object({
    param1: z.string().describe('Parameter description'),
    param2: z.number().optional(),
  }),

  // 실행 함수
  execute: async (args, context) => {
    // args: 스키마에 맞는 입력 값
    // context: { toolCallId, messages } 등 컨텍스트 정보
    return { result: 'success' }
  },
})
```

---

## 여러 도구 정의

```typescript
import { generateText, tool } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'What is the weather in Seoul and what attractions should I visit?',
  tools: {
    getWeather: tool({
      description: 'Get the weather for a location',
      inputSchema: z.object({
        location: z.string(),
      }),
      execute: async ({ location }) => ({
        temperature: 22,
        condition: 'Sunny',
      }),
    }),

    getAttractions: tool({
      description: 'Get tourist attractions for a city',
      inputSchema: z.object({
        city: z.string(),
      }),
      execute: async ({ city }) => ({
        attractions: ['Gyeongbokgung Palace', 'N Seoul Tower', 'Bukchon Hanok Village'],
      }),
    }),
  },
})

console.log(result.text)
console.log(result.toolResults)
```

---

## 도구 호출 결과 접근

```typescript
const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Get the weather in Tokyo',
  tools: { /* ... */ },
})

// 도구 호출 목록
for (const toolCall of result.toolCalls) {
  console.log('Tool:', toolCall.toolName)
  console.log('Input:', toolCall.input)
}

// 도구 실행 결과
for (const toolResult of result.toolResults) {
  console.log('Tool:', toolResult.toolName)
  console.log('Output:', toolResult.output)
}
```

---

## 스트리밍에서 도구 사용

```typescript
import { streamText, tool } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const result = streamText({
  model: openai('gpt-4o'),
  prompt: 'What is the weather?',
  tools: {
    getWeather: tool({
      description: 'Get weather',
      inputSchema: z.object({ location: z.string() }),
      execute: async ({ location }) => ({ temp: 22 }),
    }),
  },
})

// fullStream으로 도구 이벤트 처리
for await (const event of result.fullStream) {
  switch (event.type) {
    case 'text-delta':
      process.stdout.write(event.textDelta)
      break
    case 'tool-call':
      console.log('Tool called:', event.toolName)
      break
    case 'tool-result':
      console.log('Tool result:', event.output)
      break
  }
}
```

---

## API Route에서 도구 사용

```typescript
// app/api/chat/route.ts
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      getWeather: tool({
        description: 'Get weather for a location',
        inputSchema: z.object({
          location: z.string(),
        }),
        execute: async ({ location }) => {
          // 날씨 API 호출
          const weather = await fetchWeather(location)
          return weather
        },
      }),
      searchDatabase: tool({
        description: 'Search the database',
        inputSchema: z.object({
          query: z.string(),
        }),
        execute: async ({ query }) => {
          // 데이터베이스 검색
          const results = await db.search(query)
          return results
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
}
```

---

## 도구 컨텍스트 접근

도구 실행 시 추가 컨텍스트 정보에 접근할 수 있습니다:

```typescript
const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Hello',
  tools: {
    myTool: tool({
      description: 'My tool',
      inputSchema: z.object({ input: z.string() }),
      execute: async (args, context) => {
        // 도구 호출 ID
        console.log('Tool call ID:', context.toolCallId)

        // 전체 메시지 히스토리
        console.log('Messages:', context.messages)

        return { success: true }
      },
    }),
  },
})
```

---

## 다중 단계 실행

AI가 여러 도구를 순차적으로 호출하도록 허용:

```typescript
import { generateText, stepCountIs } from 'ai'

const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Plan a trip to Seoul',
  tools: { /* ... */ },
  stopWhen: stepCountIs(5), // 최대 5단계
})

// 각 단계 정보 접근
for (const step of result.steps) {
  console.log('Step:', step.toolCalls)
}

// 모든 도구 호출 추출
const allToolCalls = result.steps.flatMap(step => step.toolCalls)
```

---

## 도구 호출 복구

잘못된 도구 호출을 자동으로 복구:

```typescript
import { generateText, generateObject, NoSuchToolError, tool } from 'ai'
import { openai } from '@ai-sdk/openai'

const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Get weather',
  tools: { /* ... */ },

  experimental_repairToolCall: async ({ toolCall, tools, inputSchema, error }) => {
    // 존재하지 않는 도구면 복구 시도 안함
    if (NoSuchToolError.isInstance(error)) {
      return null
    }

    // 더 강력한 모델로 입력 재생성
    const tool = tools[toolCall.toolName as keyof typeof tools]

    const { object: repairedArgs } = await generateObject({
      model: openai('gpt-4o'),
      schema: tool.inputSchema,
      prompt: [
        `The tool "${toolCall.toolName}" was called with invalid inputs:`,
        JSON.stringify(toolCall.input),
        'Please fix the inputs according to the schema.',
      ].join('\n'),
    })

    return { ...toolCall, input: JSON.stringify(repairedArgs) }
  },
})
```

---

## 도구 상태 스트리밍

도구 실행 중 상태를 UI로 전송:

```typescript
import { streamText, tool, createUIMessageStream, createUIMessageStreamResponse } from 'ai'

export async function POST(req: Request) {
  const { messages } = await req.json()

  const stream = createUIMessageStream({
    execute: ({ writer }) => {
      const result = streamText({
        model: openai('gpt-4o'),
        messages,
        tools: {
          longRunningTask: tool({
            description: 'A long running task',
            inputSchema: z.object({ input: z.string() }),
            execute: async (args, { toolCallId }) => {
              // 진행 상태 전송
              writer.write({
                type: 'data-tool-status',
                id: toolCallId,
                data: { status: 'started' },
              })

              // 작업 수행...
              await doSomething()

              writer.write({
                type: 'data-tool-status',
                id: toolCallId,
                data: { status: 'completed' },
              })

              return { result: 'done' }
            },
          }),
        },
      })

      writer.merge(result.toUIMessageStream())
    },
  })

  return createUIMessageStreamResponse({ stream })
}
```

---

## 타입 안전한 도구

```typescript
import { tool, TypedToolCall, TypedToolResult } from 'ai'
import { z } from 'zod'

const myToolSet = {
  greet: tool({
    description: 'Greet a user',
    inputSchema: z.object({ name: z.string() }),
    execute: async ({ name }) => `Hello, ${name}!`,
  }),
  calculate: tool({
    description: 'Calculate',
    inputSchema: z.object({
      a: z.number(),
      b: z.number(),
    }),
    execute: async ({ a, b }) => a + b,
  }),
}

// 타입 추출
type MyToolCall = TypedToolCall<typeof myToolSet>
type MyToolResult = TypedToolResult<typeof myToolSet>

// 타입 안전한 함수
async function generate(prompt: string): Promise<{
  text: string
  toolCalls: MyToolCall[]
  toolResults: MyToolResult[]
}> {
  return generateText({
    model: openai('gpt-4o'),
    tools: myToolSet,
    prompt,
  })
}
```

---

## 클라이언트에서 도구 결과 표시

```tsx
'use client'

import { useChat } from '@ai-sdk/react'

export default function Chat() {
  const { messages } = useChat({ api: '/api/chat' })

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id}>
          {/* 텍스트 */}
          {m.content && <p>{m.content}</p>}

          {/* 도구 호출 */}
          {m.toolInvocations?.map((tool, i) => (
            <div key={i} className="tool-invocation">
              <h4>Tool: {tool.toolName}</h4>
              <pre>Args: {JSON.stringify(tool.args, null, 2)}</pre>

              {tool.state === 'result' && (
                <pre>Result: {JSON.stringify(tool.result, null, 2)}</pre>
              )}

              {tool.state === 'partial-call' && (
                <span>Calling...</span>
              )}
            </div>
          ))}
        </div>
      ))}
    </div>
  )
}
```

---

## 도구 정의 팁

1. **명확한 설명**: 모델이 언제 도구를 사용할지 이해하도록 상세히 작성
2. **스키마 설명**: 각 파라미터에 `.describe()` 추가
3. **에러 처리**: execute 함수에서 적절한 에러 처리
4. **반환값**: 모델이 이해할 수 있는 구조화된 데이터 반환

```typescript
const goodTool = tool({
  description: `
    Search for products in the database.
    Use this when the user asks about available products,
    product prices, or product availability.
  `,
  inputSchema: z.object({
    query: z.string().describe('Search query for product name or category'),
    maxResults: z.number().default(10).describe('Maximum number of results'),
    category: z.string().optional().describe('Filter by category'),
  }),
  execute: async ({ query, maxResults, category }) => {
    try {
      const results = await db.products.search({ query, maxResults, category })
      return { success: true, products: results }
    } catch (error) {
      return { success: false, error: 'Failed to search products' }
    }
  },
})
```
