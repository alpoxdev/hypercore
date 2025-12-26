# Zod v4 - Schema Validation

> TypeScript-first 스키마 검증

---

## 버전 주의

```typescript
// ✅ v4 문법
z.email()
z.url()
z.uuid()

// ❌ v3 문법 (사용 금지)
z.string().email()
z.string().url()
```

---

## 설치

```bash
npm install zod
```

---

## 기본 타입

```typescript
import { z } from 'zod'

z.string()
z.number()
z.boolean()
z.date()
z.undefined()
z.null()
```

### 문자열 (v4)

```typescript
z.email()                    // 이메일
z.url()                      // URL
z.uuid()                     // UUID
z.string().min(1).max(100)   // 길이
z.string().trim()            // 공백 제거
z.string().regex(/^[a-z]+$/) // 정규식
```

### 숫자

```typescript
z.number().int()        // 정수
z.number().positive()   // 양수
z.number().min(1).max(100)
```

---

## 객체

```typescript
const userSchema = z.object({
  id: z.string(),
  email: z.email(),
  name: z.string().min(1).trim(),
  age: z.number().int().positive(),
})

type User = z.infer<typeof userSchema>
```

### Optional / Nullable

```typescript
z.string().optional()   // string | undefined
z.string().nullable()   // string | null
z.string().nullish()    // string | null | undefined
```

### 기본값

```typescript
z.string().default('Anonymous')
z.enum(['user', 'admin']).default('user')
```

### Partial / Pick / Omit

```typescript
userSchema.partial()              // 모든 필드 optional
userSchema.partial({ email: true }) // 특정 필드만
userSchema.pick({ id: true, name: true })
userSchema.omit({ password: true })
```

---

## Enum / Union

```typescript
// Enum
z.enum(['pending', 'active', 'completed'])

// Union
z.union([z.string(), z.number()])

// Discriminated Union
z.discriminatedUnion('type', [
  z.object({ type: z.literal('success'), data: z.unknown() }),
  z.object({ type: z.literal('error'), message: z.string() }),
])
```

---

## Coerce (타입 변환)

```typescript
z.coerce.number()   // string → number
z.coerce.boolean()  // 'true' → boolean
z.coerce.date()     // string → Date
```

---

## Transform

```typescript
z.email().transform((e) => e.toLowerCase())
z.string().transform((s) => s.split(','))
```

---

## Refine (커스텀 검증)

```typescript
// 단일 필드
z.string().refine((val) => val.length >= 8, {
  message: '8자 이상 필요',
})

// 객체 전체
z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: '비밀번호 불일치',
  path: ['confirmPassword'],
})
```

---

## 에러 처리

```typescript
const result = schema.safeParse(input)

if (result.success) {
  console.log(result.data)
} else {
  console.log(result.error.flatten())
  // { fieldErrors: { email: ['Invalid email'] } }
}
```

### 커스텀 에러

```typescript
z.email({ message: '올바른 이메일 입력' })
z.string().min(1, { message: '필수 입력' })
```

---

## Hono와 함께

```typescript
import { zValidator } from '@hono/zod-validator'

const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
})

app.post('/users',
  zValidator('json', schema, (result, c) => {
    if (!result.success) {
      return c.json({ errors: result.error.flatten().fieldErrors }, 400)
    }
  }),
  (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  }
)
```

---

## 관련 문서

- [Hono 검증](../hono/validation.md)
