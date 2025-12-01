# AI SDK - 구조화된 출력

> **상위 문서**: [AI SDK](./index.md)

---

## 개요

AI SDK의 `generateObject`와 `streamObject`를 사용하면 타입 안전한 구조화된 데이터를 생성할 수 있습니다. Zod 스키마를 사용하여 출력 형식을 정의합니다.

---

## generateObject

### 기본 사용

```typescript
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const { object } = await generateObject({
  model: openai('gpt-4o'),
  schema: z.object({
    name: z.string(),
    age: z.number(),
    email: z.string().email(),
  }),
  prompt: 'Generate a random user profile.',
})

console.log(object.name)  // 타입 안전: string
console.log(object.age)   // 타입 안전: number
```

### 복잡한 스키마

```typescript
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

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

const { object: recipe } = await generateObject({
  model: openai('gpt-4o'),
  schema: recipeSchema,
  prompt: 'Generate a lasagna recipe.',
})

console.log(recipe.name)
console.log(recipe.ingredients)
console.log(recipe.steps)
```

---

## 출력 모드

### Object (기본)

```typescript
const { object } = await generateObject({
  model: openai('gpt-4o'),
  schema: z.object({
    name: z.string(),
    age: z.number(),
  }),
  prompt: 'Generate a user.',
})
```

### Array

배열 형태의 출력:

```typescript
const { object } = await generateObject({
  model: openai('gpt-4o'),
  output: 'array',
  schema: z.object({
    name: z.string(),
    class: z.string().describe('Character class'),
    description: z.string(),
  }),
  prompt: 'Generate 3 RPG characters.',
})

// object는 배열
for (const character of object) {
  console.log(character.name)
}
```

### Enum

분류 작업에 유용:

```typescript
const { object } = await generateObject({
  model: openai('gpt-4o'),
  output: 'enum',
  enum: ['action', 'comedy', 'drama', 'horror', 'sci-fi'],
  prompt: `
    Classify this movie:
    "A group of astronauts travel through a wormhole
    in search of a new habitable planet."
  `,
})

console.log(object) // 'sci-fi'
```

### No Schema

스키마 없이 자유 형식 JSON 생성:

```typescript
const { object } = await generateObject({
  model: openai('gpt-4o'),
  output: 'no-schema',
  prompt: 'Generate a recipe for pasta.',
})

// object는 any 타입
console.log(object)
```

---

## streamObject

스트리밍으로 객체를 점진적으로 생성:

```typescript
import { streamObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const schema = z.object({
  name: z.string(),
  bio: z.string(),
  skills: z.array(z.string()),
})

const result = streamObject({
  model: openai('gpt-4o'),
  schema,
  prompt: 'Generate a developer profile.',
})

// 부분 객체 스트리밍
for await (const partialObject of result.partialObjectStream) {
  console.log(partialObject)
  // { name: 'J' }
  // { name: 'John' }
  // { name: 'John', bio: 'A' }
  // ...
}

// 최종 객체
const finalObject = await result.object
```

---

## generateText에서 구조화된 출력

`generateText`에서도 구조화된 출력을 사용할 수 있습니다:

```typescript
import { generateText, Output } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const { output } = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Generate a random user.',
  output: Output.object({
    schema: z.object({
      name: z.string(),
      age: z.number(),
      labels: z.array(z.string()),
    }),
  }),
})

console.log(output.name)
console.log(output.age)
```

---

## 도구와 구조화된 출력 결합

```typescript
import { generateText, tool, Output, stepCountIs } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const result = await generateText({
  model: openai('gpt-4o'),
  prompt: 'Analyze this data and provide a summary.',
  output: Output.object({
    schema: z.object({
      summary: z.string(),
      sentiment: z.enum(['positive', 'neutral', 'negative']),
    }),
  }),
  tools: {
    analyzeData: tool({
      description: 'Analyze data',
      inputSchema: z.object({ data: z.string() }),
      execute: async ({ data }) => ({ result: 'analyzed' }),
    }),
  },
  // 구조화된 출력을 위해 추가 단계 필요
  stopWhen: stepCountIs(3),
})

console.log(result.output)
```

---

## API Route에서 사용

### generateObject

```typescript
// app/api/generate-profile/route.ts
import { generateObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const profileSchema = z.object({
  name: z.string(),
  bio: z.string(),
  skills: z.array(z.string()),
})

export async function POST(req: Request) {
  const { prompt } = await req.json()

  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema: profileSchema,
    prompt,
  })

  return Response.json(object)
}
```

### streamObject

```typescript
// app/api/stream-profile/route.ts
import { streamObject } from 'ai'
import { openai } from '@ai-sdk/openai'
import { z } from 'zod'

const profileSchema = z.object({
  name: z.string(),
  bio: z.string(),
  skills: z.array(z.string()),
})

export async function POST(req: Request) {
  const { prompt } = await req.json()

  const result = streamObject({
    model: openai('gpt-4o'),
    schema: profileSchema,
    prompt,
  })

  return result.toTextStreamResponse()
}
```

---

## 클라이언트에서 사용 (useObject)

```tsx
'use client'

import { experimental_useObject as useObject } from '@ai-sdk/react'
import { z } from 'zod'

const profileSchema = z.object({
  name: z.string(),
  bio: z.string(),
  skills: z.array(z.string()),
})

export default function ProfileGenerator() {
  const { object, submit, isLoading, error } = useObject({
    api: '/api/stream-profile',
    schema: profileSchema,
  })

  return (
    <div>
      <button
        onClick={() => submit('Generate a developer profile')}
        disabled={isLoading}
      >
        {isLoading ? 'Generating...' : 'Generate Profile'}
      </button>

      {error && <p className="error">{error.message}</p>}

      {object && (
        <div className="profile">
          <h2>{object.name}</h2>
          <p>{object.bio}</p>
          <ul>
            {object.skills?.map((skill, i) => (
              <li key={i}>{skill}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
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

## 에러 처리

```typescript
try {
  const { object } = await generateObject({
    model: openai('gpt-4o'),
    schema,
    prompt,
  })
} catch (error) {
  if (error instanceof z.ZodError) {
    console.error('Validation error:', error.errors)
  } else {
    console.error('Generation error:', error)
  }
}
```
