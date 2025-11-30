# Zod - 변환

> **상위 문서**: [Zod](./index.md)

## Transform

입력값을 다른 형태로 변환합니다.

```typescript
const stringToLength = z.string().transform((val) => val.length)

stringToLength.parse('string') // => 6

type MySchemaIn = z.input<typeof stringToLength>   // string
type MySchemaOut = z.output<typeof stringToLength> // number
```

### 체인으로 변환

```typescript
const emailToLower = z.string()
  .email()
  .transform((email) => email.toLowerCase())

emailToLower.parse('User@Example.COM') // => "user@example.com"
```

## Pipe를 사용한 Transform

```typescript
const stringToLength = z.string().pipe(z.transform(val => val.length))

stringToLength.parse('hello') // => 5
```

### 검증 후 변환

```typescript
const stringToNumber = z.string()
  .transform((val) => parseInt(val, 10))
  .pipe(z.number().min(0).max(100))

stringToNumber.parse('50') // => 50
stringToNumber.parse('150') // => throws
```

## Transform 내에서 검증

```typescript
const coercedInt = z.transform((val, ctx) => {
  try {
    const parsed = Number.parseInt(String(val))
    return parsed
  } catch (e) {
    ctx.issues.push({
      code: 'custom',
      message: 'Not a number',
      input: val,
    })
    return z.NEVER // 타입에 영향 없이 에러 반환
  }
})
```

## Coerce (강제 변환)

입력값을 자동으로 해당 타입으로 변환합니다.

```typescript
z.coerce.string()   // 모든 값을 문자열로
z.coerce.number()   // 모든 값을 숫자로
z.coerce.boolean()  // 모든 값을 불리언으로
z.coerce.date()     // 모든 값을 날짜로
z.coerce.bigint()   // 모든 값을 BigInt로
```

### v4 Coerce 입력 타입 변경

```typescript
const schema = z.coerce.string()
type schemaInput = z.input<typeof schema>
// v3: string
// v4: unknown  // ⚠️ 주의: 입력 타입이 unknown으로 변경됨
```

### Coerce 예시

```typescript
// string coercion
z.coerce.string().parse(123)     // => "123"
z.coerce.string().parse(true)    // => "true"
z.coerce.string().parse(null)    // => "null"

// number coercion
z.coerce.number().parse("42")    // => 42
z.coerce.number().parse(true)    // => 1
z.coerce.number().parse(false)   // => 0

// boolean coercion
z.coerce.boolean().parse("true") // => true
z.coerce.boolean().parse("")     // => false
z.coerce.boolean().parse(1)      // => true

// date coercion
z.coerce.date().parse("2021-01-01") // => Date
z.coerce.date().parse(1609459200000) // => Date
```

### 환경변수 불리언 (v4 권장)

`z.coerce.boolean()` 대신 더 정교한 `z.stringbool()` 사용:

```typescript
const strbool = z.stringbool()

strbool.parse("true")     // => true
strbool.parse("yes")      // => true
strbool.parse("1")        // => true
strbool.parse("false")    // => false
strbool.parse("no")       // => false
strbool.parse("0")        // => false
```

## Preprocess

검증 전에 데이터를 전처리합니다.

```typescript
const castToString = z.preprocess((val) => String(val), z.string())

castToString.parse(123) // => "123"
castToString.parse(null) // => "null"
```

### Preprocess vs Coerce

```typescript
// preprocess - 커스텀 로직 가능
const trimmedString = z.preprocess(
  (val) => typeof val === 'string' ? val.trim() : val,
  z.string()
)

// coerce - 내장 변환만
const coercedString = z.coerce.string()
```

## 입력/출력 타입 분리

```typescript
const Schema = z.object({
  createdAt: z.string().transform((str) => new Date(str)),
})

type SchemaInput = z.input<typeof Schema>
// { createdAt: string }

type SchemaOutput = z.output<typeof Schema>
// { createdAt: Date }
```

## 조건부 변환

```typescript
const conditionalTransform = z.string().transform((val) => {
  if (val === 'null') return null
  if (val === 'undefined') return undefined
  return val
})

conditionalTransform.parse('hello')     // => "hello"
conditionalTransform.parse('null')      // => null
conditionalTransform.parse('undefined') // => undefined
```
