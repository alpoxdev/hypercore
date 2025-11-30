# Zod

> **Version**: 4.x | TypeScript Schema Validation

---

## 🚀 Quick Reference (복사용)

```typescript
// 기본 스키마
const schema = z.object({
  email: z.email(),              // v4 (string().email() 아님!)
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // v4 (string().url() 아님!)
  age: z.number().int().positive(),
})

// 타입 추출
type Input = z.infer<typeof schema>

// 파싱
schema.parse(data)              // 실패 시 throw
schema.safeParse(data)          // { success, data/error }

// TanStack Start 연동
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(schema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

### v4 새 API (⚠️ 중요)

```typescript
// ✅ v4 사용
z.email()
z.url()
z.uuid()
z.iso.date()
z.iso.datetime()

// ❌ v3 (deprecated)
z.string().email()
z.string().url()
```

---

## 문서 구조

- [기본 타입](./basic-types.md) - 문자열, 숫자, 불리언, 날짜
- [복합 타입](./complex-types.md) - 객체, 배열, 튜플, 유니온, Enum
- [변환](./transforms.md) - Transform, Coerce, Preprocess
- [검증](./validation.md) - Refinement, Superrefine, 커스텀 검증

## 빠른 시작

```bash
yarn add zod
```

### 기본 사용법

```typescript
import { z } from 'zod'

// 스키마 생성
const mySchema = z.string()

// parsing (실패 시 에러 throw)
mySchema.parse('tuna') // => "tuna"
mySchema.parse(12) // => throws ZodError

// safe parsing (에러를 던지지 않음)
mySchema.safeParse('tuna') // => { success: true; data: "tuna" }
mySchema.safeParse(12) // => { success: false; error: ZodError }
```

### 타입 추론

```typescript
import { z } from 'zod'

const Player = z.object({
  username: z.string(),
  xp: z.number(),
})

// 스키마에서 타입 추출
type Player = z.infer<typeof Player>

// 타입 안전하게 사용
const player: Player = { username: 'billie', xp: 100 }
```

## v4 주요 변경사항

### 에러 커스터마이징 통합

```typescript
// v3 (deprecated)
z.string().min(5, { message: "Too short." })
z.string({ invalid_type_error: "Not a string", required_error: "Required" })

// v4 - error 파라미터로 통합
z.string().min(5, { error: "Too short." })
z.string({
  error: (issue) => issue.input === undefined
    ? "This field is required"
    : "Not a string"
})
```

### 새로운 최상위 문자열 포맷 API

```typescript
// v3 (deprecated)
z.string().email()
z.string().uuid()

// v4 - 최상위 API (더 나은 tree-shaking)
z.email()
z.uuid()
z.url()
z.base64()
z.nanoid()
z.cuid()
z.cuid2()
z.ulid()
z.ipv4()
z.ipv6()
z.iso.date()
z.iso.time()
z.iso.datetime()
```

### Strict/Loose 객체

```typescript
// v3
z.object({ name: z.string() }).strict()
z.object({ name: z.string() }).passthrough()

// v4
z.strictObject({ name: z.string() })
z.looseObject({ name: z.string() })
```

### Refinements가 스키마 내부에 저장

```typescript
// v3 - ZodEffects로 래핑되어 .min() 호출 불가
z.string()
  .refine(val => val.includes("@"))
  .min(5) // ❌ Property 'min' does not exist on type ZodEffects

// v4 - 스키마 내부에 저장되어 체이닝 가능
z.string()
  .refine(val => val.includes("@"))
  .min(5) // ✅
```

## TanStack Start와 함께 사용

```typescript
import { createServerFn } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/react-start/validators'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),  // v4 새 API
  name: z.string().min(1).max(100).trim(),
  bio: z.string().max(500).optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => {
    // data는 타입 안전함
    return prisma.user.create({ data })
  })
```

## 참고 자료

- [Zod 공식 문서](https://zod.dev)
- [Zod GitHub](https://github.com/colinhacks/zod)
