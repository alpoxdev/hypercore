# AI SDK - Tool Calling (Hono)

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK의 도구(Tool)를 Hono에서 사용하면 AI 모델이 외부 함수를 호출할 수 있습니다. 날씨 조회, 데이터베이스 검색, API 호출 등 다양한 작업을 수행할 수 있습니다.

---

## 기본 도구 정의

```typescript
import { Hono } from 'hono'
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

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

  return result.toUIMessageStreamResponse()
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
import { Hono } from 'hono'
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

app.post('/api/assistant', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
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
          attractions: [
            'Gyeongbokgung Palace',
            'N Seoul Tower',
            'Bukchon Hanok Village',
          ],
        }),
      }),

      searchDatabase: tool({
        description: 'Search the database for information',
        inputSchema: z.object({
          query: z.string(),
          limit: z.number().optional().default(10),
        }),
        execute: async ({ query, limit }) => {
          // 데이터베이스 검색 로직
          return { results: [], total: 0 }
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 도구와 외부 서비스 연동

### 데이터베이스 연동

```typescript
import { Hono } from 'hono'
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'
import { prisma } from '@/database/prisma'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      searchProducts: tool({
        description: 'Search for products in the database',
        inputSchema: z.object({
          query: z.string().describe('Search query'),
          category: z.string().optional().describe('Product category'),
          maxPrice: z.number().optional().describe('Maximum price'),
        }),
        execute: async ({ query, category, maxPrice }) => {
          const products = await prisma.product.findMany({
            where: {
              name: { contains: query },
              ...(category && { category }),
              ...(maxPrice && { price: { lte: maxPrice } }),
            },
            take: 10,
          })
          return { products }
        },
      }),

      getOrderStatus: tool({
        description: 'Get the status of an order',
        inputSchema: z.object({
          orderId: z.string().describe('The order ID'),
        }),
        execute: async ({ orderId }) => {
          const order = await prisma.order.findUnique({
            where: { id: orderId },
            include: { items: true },
          })
          return order ?? { error: 'Order not found' }
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})
```

### 외부 API 연동

```typescript
import { Hono } from 'hono'
import { streamText, tool, convertToModelMessages } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

type Bindings = {
  WEATHER_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      getWeather: tool({
        description: 'Get real-time weather data',
        inputSchema: z.object({
          city: z.string(),
        }),
        execute: async ({ city }) => {
          const response = await fetch(
            `https://api.weather.com/v1/current?city=${city}&key=${c.env.WEATHER_API_KEY}`
          )
          return response.json()
        },
      }),

      translateText: tool({
        description: 'Translate text to another language',
        inputSchema: z.object({
          text: z.string(),
          targetLanguage: z.string(),
        }),
        execute: async ({ text, targetLanguage }) => {
          // 번역 API 호출
          const response = await fetch('https://api.translate.com/v1/translate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text, target: targetLanguage }),
          })
          return response.json()
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 다중 단계 실행

AI가 여러 도구를 순차적으로 호출하도록 허용:

```typescript
import { Hono } from 'hono'
import { generateText, tool, stepCountIs } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

app.post('/api/plan-trip', async (c) => {
  const { destination } = await c.req.json()

  const result = await generateText({
    model: openai('gpt-4o'),
    prompt: `Plan a trip to ${destination}`,
    tools: {
      getWeather: tool({
        description: 'Get weather forecast',
        inputSchema: z.object({ location: z.string() }),
        execute: async ({ location }) => ({ forecast: 'Sunny, 22°C' }),
      }),
      getFlights: tool({
        description: 'Search for flights',
        inputSchema: z.object({ destination: z.string() }),
        execute: async ({ destination }) => ({ flights: ['Flight A', 'Flight B'] }),
      }),
      getHotels: tool({
        description: 'Search for hotels',
        inputSchema: z.object({ location: z.string() }),
        execute: async ({ location }) => ({ hotels: ['Hotel A', 'Hotel B'] }),
      }),
    },
    stopWhen: stepCountIs(5), // 최대 5단계
  })

  return c.json({
    plan: result.text,
    steps: result.steps.map((step) => ({
      toolCalls: step.toolCalls,
      toolResults: step.toolResults,
    })),
  })
})
```

---

## 도구 컨텍스트 활용

```typescript
app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      processRequest: tool({
        description: 'Process a user request',
        inputSchema: z.object({ request: z.string() }),
        execute: async (args, context) => {
          // 도구 호출 ID
          console.log('Tool call ID:', context.toolCallId)

          // 전체 메시지 히스토리 접근
          console.log('Messages:', context.messages)

          return { processed: true }
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})
```

---

## 도구 결과 스트리밍

```typescript
import { Hono } from 'hono'
import { streamText, tool } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'
import { stream } from 'hono/streaming'

const app = new Hono()

app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages,
    tools: {
      getWeather: tool({
        description: 'Get weather',
        inputSchema: z.object({ location: z.string() }),
        execute: async ({ location }) => ({ temp: 22 }),
      }),
    },
  })

  return stream(c, async (stream) => {
    for await (const event of result.fullStream) {
      switch (event.type) {
        case 'text-delta':
          await stream.write(
            JSON.stringify({ type: 'text', content: event.textDelta }) + '\n'
          )
          break
        case 'tool-call':
          await stream.write(
            JSON.stringify({
              type: 'tool-call',
              name: event.toolName,
              args: event.args,
            }) + '\n'
          )
          break
        case 'tool-result':
          await stream.write(
            JSON.stringify({
              type: 'tool-result',
              name: event.toolName,
              result: event.result,
            }) + '\n'
          )
          break
      }
    }
  })
})
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
    description: 'Calculate sum',
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

// Hono 라우트에서 사용
app.post('/api/typed-chat', async (c) => {
  const { messages } = await c.req.json()

  const result = await generateText({
    model: openai('gpt-4o'),
    tools: myToolSet,
    messages,
  })

  // 타입 안전한 접근
  const toolCalls: MyToolCall[] = result.toolCalls
  const toolResults: MyToolResult[] = result.toolResults

  return c.json({ toolCalls, toolResults })
})
```

---

## 도구 에러 처리

```typescript
app.post('/api/chat', async (c) => {
  const { messages } = await c.req.json()

  const result = streamText({
    model: openai('gpt-4o'),
    messages: convertToModelMessages(messages),
    tools: {
      riskyOperation: tool({
        description: 'Perform a risky operation',
        inputSchema: z.object({ data: z.string() }),
        execute: async ({ data }) => {
          try {
            // 위험한 작업 수행
            const result = await performRiskyTask(data)
            return { success: true, result }
          } catch (error) {
            // 에러를 AI가 이해할 수 있는 형태로 반환
            return {
              success: false,
              error: error instanceof Error ? error.message : 'Unknown error',
            }
          }
        },
      }),
    },
  })

  return result.toUIMessageStreamResponse()
})
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
