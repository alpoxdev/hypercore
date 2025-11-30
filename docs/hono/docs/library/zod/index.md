# Zod v4 - Schema Validation

> TypeScript-first 스키마 선언 및 검증 라이브러리

---

## ⚠️ 버전 주의

이 문서는 **Zod v4** 기준입니다. v3과 API가 다릅니다.

```typescript
// ✅ v4 문법
z.email()
z.url()
z.uuid()

// ❌ v3 문법 (사용 금지)
z.string().email()
z.string().url()
z.string().uuid()
```

---

## 설치

```bash
npm install zod
```

---

## 기본 타입

### Primitives

```typescript
import { z } from 'zod'

// 문자열
const stringSchema = z.string()

// 숫자
const numberSchema = z.number()

// 불리언
const booleanSchema = z.boolean()

// BigInt
const bigintSchema = z.bigint()

// Date
const dateSchema = z.date()

// Undefined / Null
const undefinedSchema = z.undefined()
const nullSchema = z.null()
```

### 문자열 검증 (v4)

```typescript
// ✅ v4 전용 메서드
z.email()                    // 이메일
z.url()                      // URL
z.uuid()                     // UUID
z.cuid()                     // CUID
z.ulid()                     // ULID
z.ip()                       // IP 주소

// 문자열 + 체이닝
z.string().min(1)            // 최소 길이
z.string().max(100)          // 최대 길이
z.string().length(10)        // 정확한 길이
z.string().trim()            // 앞뒤 공백 제거
z.string().toLowerCase()     // 소문자 변환
z.string().toUpperCase()     // 대문자 변환
z.string().startsWith('a')   // 접두사
z.string().endsWith('z')     // 접미사
z.string().includes('test')  // 포함
z.string().regex(/^[a-z]+$/) // 정규식
```

### 숫자 검증

```typescript
z.number().int()             // 정수
z.number().positive()        // 양수
z.number().negative()        // 음수
z.number().nonnegative()     // 0 이상
z.number().nonpositive()     // 0 이하
z.number().min(1)            // 최소값
z.number().max(100)          // 최대값
z.number().multipleOf(5)     // 배수
z.number().finite()          // 유한수
z.number().safe()            // 안전한 정수 범위
```

---

## 객체

### 기본 객체

```typescript
const userSchema = z.object({
  id: z.string(),
  email: z.email(),
  name: z.string().min(1).trim(),
  age: z.number().int().positive(),
})

type User = z.infer<typeof userSchema>
// { id: string; email: string; name: string; age: number }
```

### Optional / Nullable

```typescript
const schema = z.object({
  required: z.string(),
  optional: z.string().optional(),     // string | undefined
  nullable: z.string().nullable(),     // string | null
  nullish: z.string().nullish(),       // string | null | undefined
})
```

### 기본값

```typescript
const schema = z.object({
  name: z.string().default('Anonymous'),
  role: z.enum(['user', 'admin']).default('user'),
  active: z.boolean().default(true),
})
```

### Partial / Required

```typescript
const userSchema = z.object({
  name: z.string(),
  email: z.email(),
})

// 모든 필드 optional
const partialSchema = userSchema.partial()
// { name?: string; email?: string }

// 모든 필드 required
const requiredSchema = partialSchema.required()
// { name: string; email: string }

// 특정 필드만 partial
const mixedSchema = userSchema.partial({ email: true })
// { name: string; email?: string }
```

### Pick / Omit

```typescript
const userSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.email(),
  password: z.string(),
})

// 특정 필드만 선택
const publicSchema = userSchema.pick({ id: true, name: true })
// { id: string; name: string }

// 특정 필드 제외
const createSchema = userSchema.omit({ id: true })
// { name: string; email: string; password: string }
```

### Extend / Merge

```typescript
const baseSchema = z.object({
  id: z.string(),
  createdAt: z.date(),
})

// 확장
const userSchema = baseSchema.extend({
  name: z.string(),
  email: z.email(),
})

// 병합
const anotherSchema = z.object({
  updatedAt: z.date(),
})
const mergedSchema = baseSchema.merge(anotherSchema)
```

---

## 배열

```typescript
// 기본 배열
z.array(z.string())

// 길이 제한
z.array(z.string()).min(1)
z.array(z.string()).max(10)
z.array(z.string()).length(5)
z.array(z.string()).nonempty()

// 중복 제거 (unique는 없음, transform 사용)
z.array(z.string()).transform((arr) => [...new Set(arr)])
```

---

## Enum / Union

### Enum

```typescript
// Zod enum
const statusSchema = z.enum(['pending', 'active', 'completed'])
type Status = z.infer<typeof statusSchema>
// 'pending' | 'active' | 'completed'

// TypeScript enum 사용
enum Role {
  User = 'user',
  Admin = 'admin',
}
const roleSchema = z.nativeEnum(Role)
```

### Union

```typescript
// 기본 union
const stringOrNumber = z.union([z.string(), z.number()])

// Discriminated union
const responseSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('success'), data: z.unknown() }),
  z.object({ type: z.literal('error'), message: z.string() }),
])
```

---

## Coerce (타입 변환)

```typescript
// Query parameter 등에서 유용
z.coerce.string()   // any → string
z.coerce.number()   // string → number
z.coerce.boolean()  // 'true'/'false' → boolean
z.coerce.date()     // string → Date
z.coerce.bigint()   // string → bigint
```

---

## Transform

```typescript
// 값 변환
const schema = z.string().transform((val) => val.toUpperCase())

// 타입 변환
const numberToString = z.number().transform((n) => String(n))

// 복합 변환
const userSchema = z.object({
  email: z.email().transform((e) => e.toLowerCase()),
  name: z.string().transform((n) => n.trim()),
  tags: z.string().transform((s) => s.split(',').map((t) => t.trim())),
})
```

---

## Refine (커스텀 검증)

### 단일 필드

```typescript
const passwordSchema = z.string().refine(
  (password) => password.length >= 8 && /[A-Z]/.test(password),
  { message: '8자 이상, 대문자 포함 필요' }
)
```

### 객체 전체

```typescript
const schema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: '비밀번호가 일치하지 않습니다',
    path: ['confirmPassword'], // 에러 위치 지정
  }
)
```

### SuperRefine (고급)

```typescript
const schema = z.string().superRefine((val, ctx) => {
  if (val.length < 8) {
    ctx.addIssue({
      code: z.ZodIssueCode.too_small,
      minimum: 8,
      type: 'string',
      inclusive: true,
      message: '8자 이상 입력하세요',
    })
  }
  if (!/[A-Z]/.test(val)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: '대문자를 포함하세요',
    })
  }
})
```

---

## 에러 처리

### safeParse

```typescript
const schema = z.object({
  email: z.email(),
  age: z.number().min(0),
})

const result = schema.safeParse(input)

if (result.success) {
  console.log(result.data) // 검증된 데이터
} else {
  console.log(result.error.flatten())
  // {
  //   formErrors: [],
  //   fieldErrors: {
  //     email: ['Invalid email'],
  //     age: ['Number must be greater than or equal to 0']
  //   }
  // }
}
```

### 커스텀 에러 메시지

```typescript
const schema = z.object({
  email: z.email({ message: '올바른 이메일을 입력하세요' }),
  name: z.string().min(1, { message: '이름을 입력하세요' }),
  age: z.number()
    .min(0, { message: '나이는 0 이상이어야 합니다' })
    .max(150, { message: '나이는 150 이하여야 합니다' }),
})
```

---

## Hono와 함께 사용

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

// ✅ v4 문법 사용
const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional(),
})

app.post(
  '/users',
  zValidator('json', createUserSchema, (result, c) => {
    if (!result.success) {
      return c.json(
        { errors: result.error.flatten().fieldErrors },
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

## 관련 문서

- [Hono 검증](../hono/validation.md)
- [복잡한 타입](./complex-types.md)
- [Transform](./transforms.md)
