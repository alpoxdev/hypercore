# AI SDK - 구조화된 출력 (Hono)

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK의 `generateObject`와 `streamObject`를 Hono에서 사용하면 타입 안전한 구조화된 데이터를 생성할 수 있습니다. Zod 스키마를 사용하여 출력 형식을 정의합니다.

---

## generateObject

### 기본 사용

```typescript
import { Hono } from 'hono'
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

app.post('/api/generate-user', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: z.object({
      name: z.string(),
      age: z.number(),
      email: z.string().email(),
    }),
    prompt,
  })

  // object는 타입 안전: { name: string, age: number, email: string }
  return c.json(object)
})
```

### 복잡한 스키마

```typescript
import { Hono } from 'hono'
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

const recipeSchema = z.object({
  name: z.string().describe('Recipe name'),
  ingredients: z.array(
    z.object({
      name: z.string(),
      amount: z.string(),
      unit: z.string().optional(),
    })
  ),
  steps: z.array(z.string()),
  prepTime: z.number().describe('Preparation time in minutes'),
  cookTime: z.number().describe('Cooking time in minutes'),
  servings: z.number(),
  difficulty: z.enum(['easy', 'medium', 'hard']),
})

app.post('/api/generate-recipe', async (c) => {
  const { dish } = await c.req.json()

  const { object: recipe } = await generateObject({
    model: openai('gpt-4o'),
    schema: recipeSchema,
    prompt: `Generate a recipe for ${dish}.`,
  })

  return c.json(recipe)
})
```

---

## 출력 모드

### Object (기본)

```typescript
app.post('/api/object', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: z.object({
      name: z.string(),
      age: z.number(),
    }),
    prompt,
  })

  return c.json(object)
})
```

### Array

배열 형태의 출력:

```typescript
app.post('/api/array', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    output: 'array',
    schema: z.object({
      name: z.string(),
      class: z.string().describe('Character class'),
      description: z.string(),
    }),
    prompt,
  })

  // object는 배열
  return c.json({ characters: object })
})
```

### Enum

분류 작업에 유용:

```typescript
app.post('/api/classify', async (c) => {
  const { text } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    output: 'enum',
    enum: ['action', 'comedy', 'drama', 'horror', 'sci-fi'],
    prompt: `Classify this movie: "${text}"`,
  })

  return c.json({ genre: object })
})
```

### No Schema

스키마 없이 자유 형식 JSON 생성:

```typescript
app.post('/api/freeform', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    output: 'no-schema',
    prompt,
  })

  // object는 any 타입
  return c.json(object)
})
```

---

## streamObject

스트리밍으로 객체를 점진적으로 생성:

```typescript
import { Hono } from 'hono'
import { streamObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

const profileSchema = z.object({
  name: z.string(),
  bio: z.string(),
  skills: z.array(z.string()),
})

app.post('/api/stream-profile', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema: profileSchema,
    prompt,
  })

  return result.toTextStreamResponse()
})
```

### 부분 객체 처리

```typescript
import { Hono } from 'hono'
import { streamObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'
import { stream } from 'hono/streaming'

const app = new Hono()

app.post('/api/stream-partial', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema: z.object({
      name: z.string(),
      bio: z.string(),
      skills: z.array(z.string()),
    }),
    prompt,
  })

  return stream(c, async (stream) => {
    for await (const partialObject of result.partialObjectStream) {
      await stream.write(JSON.stringify(partialObject) + '\n')
    }
  })
})
```

---

## 스키마 설계 팁

### 필드 설명 추가

```typescript
const schema = z.object({
  title: z.string().describe('A catchy title for the article'),
  summary: z.string().describe('A 2-3 sentence summary'),
  tags: z.array(z.string()).describe('Relevant topic tags'),
})
```

### Optional 필드

```typescript
const schema = z.object({
  name: z.string(),
  nickname: z.string().optional(),
  age: z.number().nullable(),
})
```

### 기본값

```typescript
const schema = z.object({
  name: z.string(),
  role: z.string().default('user'),
  isActive: z.boolean().default(true),
})
```

### Enum 사용

```typescript
const schema = z.object({
  status: z.enum(['pending', 'approved', 'rejected']),
  priority: z.enum(['low', 'medium', 'high', 'critical']),
})
```

### 중첩 객체

```typescript
const schema = z.object({
  user: z.object({
    name: z.string(),
    email: z.string().email(),
  }),
  address: z.object({
    street: z.string(),
    city: z.string(),
    country: z.string(),
  }),
})
```

---

## 실용 예제

### 데이터 추출

```typescript
app.post('/api/extract', async (c) => {
  const { text } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: z.object({
      people: z.array(
        z.object({
          name: z.string(),
          role: z.string().optional(),
        })
      ),
      organizations: z.array(z.string()),
      locations: z.array(z.string()),
      dates: z.array(z.string()),
    }),
    prompt: `Extract entities from this text: ${text}`,
  })

  return c.json(object)
})
```

### 요약 생성

```typescript
app.post('/api/summarize', async (c) => {
  const { content } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: z.object({
      summary: z.string().describe('One paragraph summary'),
      keyPoints: z.array(z.string()).describe('3-5 key points'),
      sentiment: z.enum(['positive', 'neutral', 'negative']),
      topics: z.array(z.string()),
    }),
    prompt: `Summarize this content: ${content}`,
  })

  return c.json(object)
})
```

### 폼 데이터 생성

```typescript
app.post('/api/generate-form', async (c) => {
  const { description } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: z.object({
      fields: z.array(
        z.object({
          name: z.string(),
          type: z.enum(['text', 'email', 'number', 'select', 'textarea']),
          label: z.string(),
          required: z.boolean(),
          placeholder: z.string().optional(),
          options: z.array(z.string()).optional(),
        })
      ),
    }),
    prompt: `Generate form fields for: ${description}`,
  })

  return c.json(object)
})
```

---

## 에러 처리

```typescript
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const app = new Hono()

app.post('/api/generate', async (c) => {
  const { prompt } = await c.req.json()

  try {
    const { object } = await generateObject({
      model: openai('gpt-4o'),
      schema: z.object({
        name: z.string(),
        age: z.number(),
      }),
      prompt,
    })

    return c.json(object)
  } catch (error) {
    if (error instanceof z.ZodError) {
      // 스키마 검증 실패
      return c.json(
        { error: 'Validation error', details: error.errors },
        400
      )
    }

    console.error('Generation error:', error)
    throw new HTTPException(500, { message: 'Failed to generate object' })
  }
})
```

---

## 반환값

### generateObject

```typescript
const result = await generateObject({
  model: openai('gpt-4o'),
  schema,
  prompt,
})

result.object     // 생성된 객체 (타입 안전)
result.usage      // 토큰 사용량
result.finishReason // 완료 이유
```

### streamObject

```typescript
const result = streamObject({
  model: openai('gpt-4o'),
  schema,
  prompt,
})

result.partialObjectStream  // AsyncIterable<PartialObject>
result.object               // Promise<FinalObject>
result.usage                // Promise<Usage>
```

---

## Cloudflare Workers 예제

```typescript
import { Hono } from 'hono'
import { generateObject, streamObject } from 'ai'
import { createOpenAI } from '@ai-sdk/openai'
import { z } from 'zod'

type Bindings = {
  OPENAI_API_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

const productSchema = z.object({
  name: z.string(),
  description: z.string(),
  price: z.number(),
  features: z.array(z.string()),
})

app.post('/api/generate-product', async (c) => {
  const openai = createOpenAI({ apiKey: c.env.OPENAI_API_KEY })
  const { category } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: productSchema,
    prompt: `Generate a product in the ${category} category.`,
  })

  return c.json(object)
})

app.post('/api/stream-product', async (c) => {
  const openai = createOpenAI({ apiKey: c.env.OPENAI_API_KEY })
  const { category } = await c.req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema: productSchema,
    prompt: `Generate a product in the ${category} category.`,
  })

  return result.toTextStreamResponse()
})

export default app
```
