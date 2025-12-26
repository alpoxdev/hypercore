# AI SDK - 구조화된 출력

> Zod 스키마로 타입 안전한 객체 생성

---

## generateObject

```typescript
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const userSchema = z.object({
  name: z.string(),
  age: z.number(),
  email: z.email(),
})

app.post('/api/generate-user', async (c) => {
  const { prompt } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: userSchema,
    prompt,
  })

  // object: { name: string, age: number, email: string }
  return c.json(object)
})
```

---

## 복잡한 스키마

```typescript
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
  prepTime: z.number().describe('Prep time in minutes'),
  cookTime: z.number().describe('Cook time in minutes'),
  difficulty: z.enum(['easy', 'medium', 'hard']),
})

app.post('/api/recipe', async (c) => {
  const { dish } = await c.req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: recipeSchema,
    prompt: `Generate a recipe for ${dish}.`,
  })

  return c.json(object)
})
```

---

## streamObject

스트리밍으로 객체 생성.

```typescript
import { streamObject } from 'ai'

app.post('/api/stream-user', async (c) => {
  const { prompt } = await c.req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema: userSchema,
    prompt,
  })

  return result.toTextStreamResponse()
})
```

### 부분 객체 수신

```typescript
const result = streamObject({
  model: openai('gpt-4o'),
  schema: userSchema,
  prompt,
})

for await (const partialObject of result.partialObjectStream) {
  console.log('Partial:', partialObject)
  // { name: 'Jo' }
  // { name: 'John', age: 25 }
  // { name: 'John', age: 25, email: 'john@...' }
}
```

---

## 출력 모드

```typescript
// Array 모드
const { object } = await generateObject({
  model: openai('gpt-4o'),
  output: 'array',
  schema: z.object({ name: z.string(), role: z.string() }),
  prompt: 'List 5 team members.',
})
// object: [{ name: 'Alice', role: 'Engineer' }, ...]

// Enum 모드
const { object } = await generateObject({
  model: openai('gpt-4o'),
  output: 'enum',
  enum: ['positive', 'negative', 'neutral'],
  prompt: 'Classify the sentiment: "I love this product!"',
})
// object: 'positive'
```

---

## 에러 처리

```typescript
import { NoObjectGeneratedError, InvalidResponseDataError } from 'ai'

try {
  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: userSchema,
    prompt,
  })
  return c.json(object)
} catch (error) {
  if (error instanceof NoObjectGeneratedError) {
    return c.json({ error: 'Failed to generate object' }, 500)
  }
  if (error instanceof InvalidResponseDataError) {
    return c.json({ error: 'Invalid response format' }, 500)
  }
  throw error
}
```

---

## 관련 문서

- [AI SDK 개요](./index.md)
- [스트리밍](./streaming.md)
- [도구](./tools.md)
