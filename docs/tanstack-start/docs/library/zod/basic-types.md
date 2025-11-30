# Zod - 기본 타입

> **상위 문서**: [Zod](./index.md)

## 문자열

```typescript
z.string()
z.string().min(1)          // 최소 길이
z.string().max(100)        // 최대 길이
z.string().length(5)       // 정확한 길이
z.string().regex(/^\d+$/)  // 정규식
z.string().trim()          // 공백 제거
z.string().toLowerCase()   // 소문자 변환
z.string().toUpperCase()   // 대문자 변환
```

### v4 새로운 최상위 문자열 포맷 API

```typescript
// 더 나은 tree-shaking을 위해 최상위 API 사용 권장
z.email()           // 이메일 형식
z.url()             // URL 형식
z.uuid()            // UUID 형식
z.base64()          // Base64 형식
z.base64url()       // Base64 URL 형식
z.nanoid()          // NanoID 형식
z.cuid()            // CUID 형식
z.cuid2()           // CUID2 형식
z.ulid()            // ULID 형식
z.emoji()           // 이모지 (단일 문자)
z.ipv4()            // IPv4 주소
z.ipv6()            // IPv6 주소
z.cidrv4()          // IPv4 범위
z.cidrv6()          // IPv6 범위

// ISO 날짜/시간 형식
z.iso.date()        // ISO 날짜 (2024-01-15)
z.iso.time()        // ISO 시간 (14:30:00)
z.iso.datetime()    // ISO 날짜시간
z.iso.duration()    // ISO 기간 (P1D, PT1H)
```

### 템플릿 리터럴 타입 (v4 신규)

```typescript
const hello = z.templateLiteral(["hello, ", z.string()])
// `hello, ${string}`

const cssUnits = z.enum(["px", "em", "rem", "%"])
const css = z.templateLiteral([z.number(), cssUnits])
// `${number}px` | `${number}em` | `${number}rem` | `${number}%`

const email = z.templateLiteral([
  z.string().min(1),
  "@",
  z.string().max(64),
])
// `${string}@${string}` (min/max refinements도 적용됨!)
```

## 숫자

```typescript
z.number()
z.number().min(0)          // 최솟값
z.number().max(100)        // 최댓값
z.number().int()           // 정수만
z.number().positive()      // 양수만
z.number().negative()      // 음수만
z.number().nonnegative()   // 0 이상
z.number().nonpositive()   // 0 이하
z.number().finite()        // 유한 숫자
z.number().safe()          // 안전한 정수 범위
```

## 불리언

```typescript
z.boolean()
```

### 문자열 불리언 (v4 신규)

환경변수 스타일 불리언 변환:

```typescript
const strbool = z.stringbool()

strbool.parse("true")     // => true
strbool.parse("1")        // => true
strbool.parse("yes")      // => true
strbool.parse("on")       // => true
strbool.parse("enabled")  // => true

strbool.parse("false")    // => false
strbool.parse("0")        // => false
strbool.parse("no")       // => false
strbool.parse("off")      // => false
strbool.parse("disabled") // => false

// 커스텀 truthy/falsy 값
z.stringbool({
  truthy: ["yes", "true"],
  falsy: ["no", "false"]
})
```

## 날짜

```typescript
z.date()
z.date().min(new Date('2020-01-01'))
z.date().max(new Date('2030-12-31'))
```

## BigInt

```typescript
z.bigint()
z.bigint().positive()
z.bigint().negative()
```

## 리터럴

```typescript
z.literal('hello')       // 정확히 'hello'만
z.literal(42)            // 정확히 42만
z.literal(true)          // 정확히 true만
```

## Null, Undefined, Void

```typescript
z.null()       // null만 허용
z.undefined()  // undefined만 허용
z.void()       // undefined 허용 (반환 타입용)
```

## Any, Unknown, Never

```typescript
z.any()      // 모든 타입 허용
z.unknown()  // unknown 타입
z.never()    // 값 없음 (유니온에서 사용)
```

> **v4 변경**: `z.any()`와 `z.unknown()`은 더 이상 객체에서 선택적 키로 추론되지 않습니다.
> ```typescript
> const mySchema = z.object({ a: z.any(), b: z.unknown() })
> // v3: { a?: any; b?: unknown }
> // v4: { a: any; b: unknown }
> ```

## Optional & Nullable

```typescript
z.string().optional()  // string | undefined
z.string().nullable()  // string | null
z.string().nullish()   // string | null | undefined
```

## Default 값

```typescript
const Schema = z.object({
  name: z.string().default('Anonymous'),
  role: z.enum(['admin', 'user']).default('user'),
})

Schema.parse({}) // { name: 'Anonymous', role: 'user' }
```

## 타입 추론

```typescript
const stringSchema = z.string()
type StringType = z.infer<typeof stringSchema> // string

const numberSchema = z.number().optional()
type NumberType = z.infer<typeof numberSchema> // number | undefined

const dateSchema = z.date().nullable()
type DateType = z.infer<typeof dateSchema> // Date | null
```
