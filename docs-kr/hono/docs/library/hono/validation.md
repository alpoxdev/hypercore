# Hono + Zod 검증

> @hono/zod-validator로 타입 안전 요청 검증

<setup>
```bash
npm install zod @hono/zod-validator
```
</setup>

---

<patterns>

## JSON Body

```typescript
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),              // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // ✅ v4
})

app.post('/users', zValidator('json', createUserSchema), (c) => {
  const data = c.req.valid('json')
  return c.json({ user: data }, 201)
})
```

## Query / Param / Header

```typescript
// Query
const searchSchema = z.object({
  q: z.string(),
  page: z.coerce.number().positive().optional(),
  limit: z.coerce.number().max(100).optional(),
})

app.get('/search', zValidator('query', searchSchema), (c) => {
  const { q, page = 1, limit = 10 } = c.req.valid('query')
  return c.json({ query: q, page, limit })
})

// Param
app.get('/users/:id',
  zValidator('param', z.object({ id: z.string().uuid() })),
  (c) => {
    const { id } = c.req.valid('param')
    return c.json({ id })
  }
)

// Header (소문자!)
app.get('/api/protected',
  zValidator('header', z.object({ 'x-api-key': z.string().uuid() })),
  (c) => {
    return c.json({ apiKey: c.req.valid('header')['x-api-key'] })
  }
)
```

## 복합 검증

```typescript
app.post(
  '/posts/:id',
  zValidator('param', z.object({ id: z.string().uuid() })),
  zValidator('query', z.object({ draft: z.coerce.boolean().optional() })),
  zValidator('json', z.object({ title: z.string(), body: z.string() })),
  (c) => {
    const { id } = c.req.valid('param')
    const { draft } = c.req.valid('query')
    const postData = c.req.valid('json')
    return c.json({ id, draft: draft ?? false, ...postData })
  }
)
```

## 커스텀 에러

```typescript
app.post(
  '/users',
  zValidator('json', createUserSchema, (result, c) => {
    if (!result.success) {
      return c.json({
        error: 'Validation failed',
        fieldErrors: result.error.flatten().fieldErrors,
      }, 400)
    }
  }),
  (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  }
)
```

## 재사용 스키마

```typescript
// validators/user.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
  password: z.string().min(8),
})

export const updateUserSchema = createUserSchema.partial()

export type CreateUserInput = z.infer<typeof createUserSchema>
```

</patterns>

---

<advanced>

```typescript
// Coerce
z.coerce.number()    // string → number
z.coerce.boolean()   // 'true' → boolean
z.coerce.date()      // string → Date

// Enum
z.enum(['pending', 'active', 'completed'])

// Transform
z.email().transform((e) => e.toLowerCase())

// Refinement
z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})
```

</advanced>
