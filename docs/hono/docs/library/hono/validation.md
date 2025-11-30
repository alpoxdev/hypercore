# Hono + Zod 검증

> @hono/zod-validator를 사용한 타입 안전 요청 검증

---

## 설치

```bash
# Zod
npm install zod

# Zod Validator Middleware
npm install @hono/zod-validator
```

---

## 기본 사용법

### JSON Body 검증

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

// ✅ Zod v4 문법
const createUserSchema = z.object({
  email: z.email(),              // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // ✅ v4
})

app.post('/users', zValidator('json', createUserSchema), (c) => {
  const data = c.req.valid('json') // 타입 추론됨
  return c.json({ user: data }, 201)
})
```

### Query Parameter 검증

```typescript
const searchSchema = z.object({
  q: z.string(),
  page: z.coerce.number().positive().optional(),
  limit: z.coerce.number().max(100).optional(),
})

app.get('/search', zValidator('query', searchSchema), (c) => {
  const { q, page = 1, limit = 10 } = c.req.valid('query')
  return c.json({ query: q, page, limit, results: [] })
})
```

### Path Parameter 검증

```typescript
const paramSchema = z.object({
  id: z.string().uuid(),
})

app.get('/users/:id', zValidator('param', paramSchema), (c) => {
  const { id } = c.req.valid('param')
  return c.json({ id })
})
```

### Header 검증

```typescript
// ⚠️ 헤더 이름은 소문자로
const headerSchema = z.object({
  'x-api-key': z.string().uuid(),
  'x-request-id': z.string().optional(),
})

app.get('/api/protected', zValidator('header', headerSchema), (c) => {
  const headers = c.req.valid('header')
  return c.json({ apiKey: headers['x-api-key'] })
})
```

### Form Data 검증

```typescript
const formSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(10),
})

app.post('/posts', zValidator('form', formSchema), (c) => {
  const data = c.req.valid('form')
  return c.json({ post: data }, 201)
})
```

---

## 복합 검증

### 여러 소스 검증

```typescript
const postSchema = z.object({
  title: z.string().min(1).max(100),
  body: z.string().min(10),
})

app.post(
  '/posts/:id',
  zValidator('param', z.object({ id: z.string().uuid() })),
  zValidator('query', z.object({ draft: z.coerce.boolean().optional() })),
  zValidator('json', postSchema),
  (c) => {
    const { id } = c.req.valid('param')
    const { draft } = c.req.valid('query')
    const postData = c.req.valid('json')

    return c.json({ id, draft: draft ?? false, ...postData })
  }
)
```

---

## 커스텀 에러 처리

### 기본 에러 응답

```typescript
app.post(
  '/users',
  zValidator('json', createUserSchema, (result, c) => {
    if (!result.success) {
      return c.json(
        {
          error: 'Validation failed',
          issues: result.error.flatten(),
        },
        400
      )
    }
  }),
  (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  }
)
```

### 상세 에러 응답

```typescript
app.post(
  '/users',
  zValidator('json', createUserSchema, (result, c) => {
    if (!result.success) {
      const errors = result.error.flatten()
      return c.json(
        {
          error: 'Validation failed',
          fieldErrors: errors.fieldErrors,
          formErrors: errors.formErrors,
        },
        400
      )
    }
  }),
  (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  }
)
```

---

## 재사용 가능한 스키마

### validators/user.ts

```typescript
import { z } from 'zod'

// ✅ Zod v4 문법
export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
  password: z.string().min(8),
})

export const updateUserSchema = createUserSchema.partial()

export const userIdSchema = z.object({
  id: z.string().uuid(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

### routes/users.ts

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import {
  createUserSchema,
  updateUserSchema,
  userIdSchema,
} from '../validators/user'

const users = new Hono()

users.post('/', zValidator('json', createUserSchema), (c) => {
  const data = c.req.valid('json')
  return c.json({ user: data }, 201)
})

users.put(
  '/:id',
  zValidator('param', userIdSchema),
  zValidator('json', updateUserSchema),
  (c) => {
    const { id } = c.req.valid('param')
    const data = c.req.valid('json')
    return c.json({ id, ...data })
  }
)

export default users
```

---

## 고급 스키마 패턴

### Coerce (타입 변환)

```typescript
const querySchema = z.object({
  // string → number 변환
  page: z.coerce.number().positive(),
  // string → boolean 변환
  active: z.coerce.boolean(),
  // string → Date 변환
  since: z.coerce.date(),
})
```

### Enum

```typescript
const statusSchema = z.object({
  status: z.enum(['pending', 'active', 'completed']),
})
```

### Array

```typescript
const tagsSchema = z.object({
  tags: z.array(z.string()).min(1).max(10),
})
```

### Union

```typescript
const idSchema = z.union([
  z.string().uuid(),
  z.coerce.number().positive(),
])
```

### Refinement

```typescript
const passwordSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})
```

### Transform

```typescript
const userSchema = z.object({
  email: z.email().transform((email) => email.toLowerCase()),
  name: z.string().transform((name) => name.trim()),
})
```

---

## Standard Schema Validator

Zod 외에도 다양한 검증 라이브러리 지원:

```typescript
import { sValidator } from '@hono/standard-validator'
import { z } from 'zod'

const schema = z.object({
  name: z.string(),
  age: z.number(),
})

app.post('/author', sValidator('json', schema), (c) => {
  const data = c.req.valid('json')
  return c.json({ success: true, message: `${data.name} is ${data.age}` })
})
```

---

## 관련 문서

- [기본 사용법](./index.md)
- [미들웨어](./middleware.md)
- [에러 처리](./error-handling.md)
- [Zod 가이드](../zod/index.md)
