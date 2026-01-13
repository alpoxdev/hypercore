# Zod

> v4 | TypeScript Schema Validation

<context>

**Purpose:** Type-safe schema validation with TypeScript inference
**Requirements:** TypeScript v5.5+, strict mode enabled
**Bundle Size:** 2kb core (gzipped), zero dependencies

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **Deprecated API** | `z.string().email()`, `z.string().url()`, `z.string().uuid()` |
| **Error Messages** | `message`, `invalid_type_error`, `required_error` (v3) |
| **타입** | any 타입 (unknown 사용) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **v4 API** | `z.email()`, `z.url()`, `z.uuid()` (top-level) |
| **Error Param** | `{ error: "message" }` (v4 통합 파라미터) |
| **TanStack Start** | `.inputValidator(schema)` 사용 |
| **타입 추론** | `z.infer<typeof schema>` |

</required>

---

<installation>

## Installation

```bash
npm install zod@^4.0.0
```

## TypeScript Config

```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

</installation>

---

<v4_breaking_changes>

## v3 → v4 Breaking Changes

| v3 (Deprecated) | v4 (Required) |
|-----------------|---------------|
| `z.string().email()` | `z.email()` |
| `z.string().url()` | `z.url()` |
| `z.string().uuid()` | `z.uuid()` |
| `z.string().min(5, { message: "..." })` | `z.string().min(5, { error: "..." })` |
| `z.string().email({ message: "..." })` | `z.email({ error: "..." })` |

## Refinement Chaining

```typescript
// ✅ v4: Refinement 체이닝 가능
z.string().refine(val => val.includes("@")).min(5)

// ❌ v3: ZodEffects로 래핑되어 체이닝 불가
z.string().refine(val => val.includes("@")).min(5) // Error
```

## Object Types

```typescript
// ✅ v4: 새로운 객체 타입
z.strictObject({ name: z.string() })  // 추가 키 에러
z.looseObject({ name: z.string() })   // 추가 키 통과
z.object({ name: z.string() })        // 기본 동작 (strip)
```

</v4_breaking_changes>

---

<v4_new_apis>

## String Formats

| API | 설명 |
|-----|------|
| `z.email()` | 이메일 검증 |
| `z.url()` | URL 검증 |
| `z.uuid()`, `z.uuidv1()`, `z.uuidv4()`, `z.uuidv7()` | UUID 검증 |
| `z.ipv4()`, `z.ipv6()` | IP 주소 |
| `z.cidr()`, `z.cidrvv4()`, `z.cidrv6()` | CIDR 표기법 |
| `z.base64()`, `z.base64url()` | Base64 인코딩 |
| `z.jwt()` | JWT 토큰 |

## ISO Formats

| API | 설명 |
|-----|------|
| `z.iso.date()` | ISO 8601 날짜 (YYYY-MM-DD) |
| `z.iso.datetime()` | ISO 8601 날짜/시간 |
| `z.iso.time()` | ISO 8601 시간 |
| `z.iso.duration()` | ISO 8601 기간 |

## Numeric Types

| API | 설명 |
|-----|------|
| `z.int()` | 정수 |
| `z.float32()`, `z.float64()` | 부동소수점 |
| `z.int32()`, `z.uint32()` | 32비트 정수 |
| `z.int64()`, `z.uint64()` | 64비트 정수 |

## Special Types

| API | 설명 | 예시 |
|-----|------|------|
| `z.stringbool()` | 문자열 → 불리언 | `"true"`, `"1"`, `"yes"` → `true` |
| `z.templateLiteral()` | 템플릿 리터럴 타입 | `` `${number}px` `` |
| `z.file()` | 파일 검증 | `.min()`, `.max()`, `.mime()` |

## Metadata & Tools

| API | 설명 |
|-----|------|
| `z.registry()` | 커스텀 메타데이터 |
| `z.globalRegistry` | JSON Schema 호환 메타데이터 |
| `.meta()` | 스키마 메타데이터 첨부 |
| `z.toJSONSchema()` | JSON Schema 변환 |
| `z.prettifyError()` | 사용자 친화적 에러 포맷 |
| `.overwrite()` | 타입 보존 변환 |

</v4_new_apis>

---

<basic_usage>

## Basic Schema

```typescript
import { z } from 'zod'

// ✅ v4 API
const userSchema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional(),
  age: z.number().int().positive(),
})

type User = z.infer<typeof userSchema>
// → { email: string; name: string; website?: string; age: number }

// ✅ 검증
const result = userSchema.parse(data)              // 실패 시 throw
const safe = userSchema.safeParse(data)            // { success, data/error }

if (safe.success) {
  console.log(safe.data.email)
} else {
  console.error(safe.error.issues)
}
```

## TanStack Start Integration

```typescript
import { createServerFn } from '@tanstack/start'
import { z } from 'zod'

// ✅ Server Function with Zod v4
const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    //               ^? { email: string; name: string; website?: string }
    return prisma.user.create({ data })
  })
```

</basic_usage>

---

<primitives>

## Primitive Types

| Type | Example |
|------|---------|
| `z.string()` | `z.string().min(5).max(100)` |
| `z.number()` | `z.number().int().positive()` |
| `z.boolean()` | `z.boolean()` |
| `z.date()` | `z.date().min(new Date('2020-01-01'))` |
| `z.null()` | `z.null()` |
| `z.undefined()` | `z.undefined()` |
| `z.void()` | `z.void()` |
| `z.any()` | `z.any()` (❌ 사용 지양) |
| `z.unknown()` | `z.unknown()` (✅ 권장) |
| `z.never()` | `z.never()` |

## String Methods

```typescript
z.string()
  .min(5, { error: "Too short." })
  .max(100, { error: "Too long." })
  .length(10, { error: "Must be 10 chars." })
  .trim()
  .toLowerCase()
  .toUpperCase()
  .startsWith("https://")
  .endsWith(".com")
  .regex(/^\d+$/, { error: "Must be digits." })
```

## Number Methods

```typescript
z.number()
  .gt(5)        // Greater than
  .gte(5)       // Greater than or equal
  .lt(100)      // Less than
  .lte(100)     // Less than or equal
  .int()        // Integer
  .positive()   // > 0
  .nonnegative()// >= 0
  .negative()   // < 0
  .nonpositive()// <= 0
  .multipleOf(5)// 배수
  .finite()     // Not Infinity/-Infinity
  .safe()       // Number.MIN_SAFE_INTEGER ~ MAX_SAFE_INTEGER
```

</primitives>

---

<complex_types>

## Objects

```typescript
const schema = z.object({
  name: z.string(),
  age: z.number(),
})

// ✅ Methods
schema.shape.name              // z.string()
schema.keyof()                 // z.enum(['name', 'age'])
schema.extend({ email: z.email() })
schema.merge(otherSchema)
schema.pick({ name: true })
schema.omit({ age: true })
schema.partial()               // 모든 필드 optional
schema.deepPartial()           // 재귀적 partial
schema.required()              // 모든 필드 required
schema.passthrough()           // 추가 키 허용
schema.strict()                // 추가 키 에러
```

## Arrays

```typescript
z.array(z.string())
  .min(1, { error: "At least 1 item." })
  .max(10)
  .length(5)
  .nonempty()

// ✅ Non-empty array
z.string().array().nonempty()
```

## Tuples

```typescript
const tuple = z.tuple([
  z.string(),
  z.number(),
  z.boolean(),
])

type Tuple = z.infer<typeof tuple>
// → [string, number, boolean]

// ✅ Rest parameter
z.tuple([z.string()]).rest(z.number())
// → [string, ...number[]]
```

## Unions

```typescript
const schema = z.union([z.string(), z.number()])
// 또는
const schema = z.string().or(z.number())

type Value = z.infer<typeof schema>
// → string | number
```

## Discriminated Unions

```typescript
const schema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('email'), email: z.email() }),
  z.object({ type: z.literal('phone'), phone: z.string() }),
])

type Contact = z.infer<typeof schema>
// → { type: 'email'; email: string } | { type: 'phone'; phone: string }
```

## Records

```typescript
z.record(z.string())              // Record<string, string>
z.record(z.enum(['a', 'b']), z.number())  // Record<'a' | 'b', number>
```

## Maps & Sets

```typescript
z.map(z.string(), z.number())     // Map<string, number>
z.set(z.string())                 // Set<string>
```

</complex_types>

---

<validation>

## Optional & Nullable

```typescript
z.string().optional()             // string | undefined
z.string().nullable()             // string | null
z.string().nullish()              // string | null | undefined
```

## Default Values

```typescript
z.string().default("default")
z.number().default(0)
z.boolean().default(false)
```

## Enums

```typescript
// ✅ Native enum
enum Fruits {
  Apple,
  Banana,
}
z.nativeEnum(Fruits)

// ✅ Zod enum
const fruits = z.enum(['apple', 'banana', 'orange'])
type Fruit = z.infer<typeof fruits>  // 'apple' | 'banana' | 'orange'

// ✅ 값 추출
fruits.enum.apple  // 'apple'
fruits.options     // ['apple', 'banana', 'orange']
```

## Literals

```typescript
z.literal('hello')
z.literal(42)
z.literal(true)
```

</validation>

---

<transforms>

## Transform

```typescript
const schema = z.string()
  .transform((val) => val.length)
  .pipe(z.number().positive())

schema.parse("hello")  // → 5
schema.parse("")       // Error: number must be positive
```

## Preprocess

```typescript
const schema = z.preprocess(
  (val) => (val === "" ? undefined : val),
  z.string().optional()
)

schema.parse("")      // → undefined
schema.parse("hello") // → "hello"
```

## Coerce

```typescript
z.coerce.string()   // String(val)
z.coerce.number()   // Number(val)
z.coerce.boolean()  // Boolean(val)
z.coerce.date()     // new Date(val)

// ✅ 예시
z.coerce.number().parse("42")  // → 42
```

</transforms>

---

<refinements>

## Refine

```typescript
const schema = z.string()
  .refine((val) => val.length >= 5, {
    error: "Must be at least 5 characters.",
  })

// ✅ v4: 체이닝 가능
z.string()
  .refine((val) => val.includes("@"))
  .min(5)
```

## SuperRefine

```typescript
const schema = z.object({
  password: z.string(),
  confirmPassword: z.string(),
}).superRefine((data, ctx) => {
  if (data.password !== data.confirmPassword) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['confirmPassword'],
      message: "Passwords don't match.",
    })
  }
})
```

</refinements>

---

<error_handling>

## Error Handling

```typescript
try {
  schema.parse(data)
} catch (error) {
  if (error instanceof z.ZodError) {
    console.log(error.issues)
    // [{
    //   code: 'invalid_type',
    //   expected: 'string',
    //   received: 'number',
    //   path: ['name'],
    //   message: 'Expected string, received number'
    // }]
  }
}

// ✅ Safe parse
const result = schema.safeParse(data)
if (!result.success) {
  console.log(result.error.format())
}
```

## Custom Errors

```typescript
const schema = z.string().min(5, { error: "Too short." })
const schema = z.email({ error: "Invalid email." })

// ✅ v4: error 파라미터 통합
z.number().int({ error: "Must be integer." })
```

## Prettify Errors

```typescript
import { z } from 'zod'

const error = schema.safeParse(data).error
const pretty = z.prettifyError(error)
console.log(pretty)
```

</error_handling>

---

<advanced>

## Template Literals

```typescript
const css = z.templateLiteral([
  z.number(),
  z.enum(["px", "em", "rem"]),
])

type CSS = z.infer<typeof css>
// → `${number}px` | `${number}em` | `${number}rem`

css.parse("16px")  // ✅
css.parse("16")    // ❌
```

## String Bool

```typescript
const schema = z.stringbool()

schema.parse("true")   // → true
schema.parse("1")      // → true
schema.parse("yes")    // → true
schema.parse("on")     // → true
schema.parse("false")  // → false
schema.parse("0")      // → false
schema.parse("no")     // → false
schema.parse("off")    // → false
```

## File Validation

```typescript
const schema = z.file()
  .min(1024)                    // 1KB 이상
  .max(10 * 1024 * 1024)        // 10MB 이하
  .mime(['image/png', 'image/jpeg'])

// ✅ 사용
schema.parse(fileInput.files[0])
```

## JSON Schema

```typescript
const schema = z.object({
  name: z.string(),
  age: z.number(),
})

const jsonSchema = z.toJSONSchema(schema)
// {
//   type: 'object',
//   properties: {
//     name: { type: 'string' },
//     age: { type: 'number' }
//   },
//   required: ['name', 'age']
// }
```

## Promise & Function Schemas

```typescript
const promiseSchema = z.promise(z.string())
const fnSchema = z.function()
  .args(z.string(), z.number())
  .returns(z.boolean())
```

</advanced>

---

<patterns>

## TanStack Start Patterns

| 용도 | 패턴 |
|------|------|
| **Server Function** | `.inputValidator(schema)` |
| **Search Params** | `validateSearch: schema` |
| **Form 검증** | `schema.safeParse(formData)` |

```typescript
// ✅ POST Server Function
const createPostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
  tags: z.array(z.string()).max(5),
})

export const createPost = createServerFn({ method: 'POST' })
  .inputValidator(createPostSchema)
  .handler(async ({ data }) => prisma.post.create({ data }))

// ✅ Search Params
export const Route = createFileRoute('/posts')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sort: z.enum(['newest', 'oldest']).catch('newest'),
  }),
})

// ✅ Form 검증
const formSchema = z.object({
  email: z.email(),
  password: z.string().min(8),
})

const handleSubmit = (formData: FormData) => {
  const result = formSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  })

  if (!result.success) {
    return { errors: result.error.flatten() }
  }

  // result.data is type-safe
}
```

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|----------|
| `z.email()` 사용 | `z.string().email()` (deprecated) |
| `{ error: "..." }` 파라미터 | `{ message: "..." }` (v3) |
| `z.unknown()` 사용 | `z.any()` 남용 |
| `.safeParse()` 사용자 입력 | `.parse()` 사용자 입력 (throw) |
| 타입 추론 활용 | 중복 타입 정의 |

</patterns>

---

<migration>

## v3 → v4 Migration Checklist

| 항목 | 작업 |
|------|------|
| **String formats** | `z.string().email()` → `z.email()` |
| **Error messages** | `{ message: "..." }` → `{ error: "..." }` |
| **Object types** | `.strict()` → `z.strictObject()` |
| **Refinements** | 체이닝 가능 확인 |
| **Bundle size** | `zod/mini` 고려 (85% 감소) |

```typescript
// ❌ v3
const schema = z.object({
  email: z.string().email({ message: "Invalid email." }),
  age: z.number().min(18, { message: "Must be 18+." }),
})

// ✅ v4
const schema = z.object({
  email: z.email({ error: "Invalid email." }),
  age: z.number().min(18, { error: "Must be 18+." }),
})
```

</migration>
