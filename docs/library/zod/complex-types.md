# Zod - 복합 타입

> **상위 문서**: [Zod](./index.md)

## 객체

```typescript
const UserSchema = z.object({
  name: z.string(),
  email: z.email(),  // v4 새 API
  age: z.number().optional(),  // 선택적 필드
})

// 검증
const result = UserSchema.parse({
  name: 'john',
  email: 'john@example.com',
  age: 25,
})

// 안전한 검증
const safeResult = UserSchema.safeParse(data)
if (safeResult.success) {
  console.log(safeResult.data)
} else {
  console.log(safeResult.error)
}
```

### 객체 메서드

```typescript
// 부분 객체 (모든 필드가 optional)
const PartialUser = UserSchema.partial()

// 필수 객체 (모든 필드가 required)
const RequiredUser = UserSchema.required()

// 필드 선택
const UserName = UserSchema.pick({ name: true })

// 필드 제외
const UserWithoutEmail = UserSchema.omit({ email: true })

// 확장
const ExtendedUser = UserSchema.extend({
  role: z.enum(['admin', 'user']),
})

// 병합
const MergedSchema = UserSchema.merge(AnotherSchema)
```

### Strict/Loose 객체 (v4)

```typescript
// v3
z.object({ name: z.string() }).strict()     // 추가 키 에러
z.object({ name: z.string() }).passthrough() // 추가 키 통과

// v4 - 새로운 API
z.strictObject({ name: z.string() })  // 추가 키 에러
z.looseObject({ name: z.string() })   // 추가 키 통과
```

## 배열

```typescript
z.array(z.string())
z.array(z.number()).min(1)     // 최소 1개
z.array(z.number()).max(10)    // 최대 10개
z.array(z.number()).length(5)  // 정확히 5개
z.array(z.number()).nonempty() // 비어있지 않음
```

## 튜플

```typescript
const tuple = z.tuple([
  z.string(),  // 첫 번째 요소
  z.number(),  // 두 번째 요소
])

type Tuple = z.infer<typeof tuple>
// [string, number]
```

## 유니온

```typescript
const StringOrNumber = z.union([z.string(), z.number()])
// 또는
const StringOrNumber = z.string().or(z.number())

type StringOrNumber = z.infer<typeof StringOrNumber>
// string | number
```

## Discriminated Union

```typescript
const Shape = z.discriminatedUnion('type', [
  z.object({ type: z.literal('circle'), radius: z.number() }),
  z.object({ type: z.literal('rectangle'), width: z.number(), height: z.number() }),
])

type Shape = z.infer<typeof Shape>
// { type: 'circle'; radius: number } | { type: 'rectangle'; width: number; height: number }
```

### v4 향상된 Discriminated Union

```typescript
// 유니온 및 파이프 discriminator 지원
const MyResult = z.discriminatedUnion("status", [
  // 단순 리터럴
  z.object({ status: z.literal("aaa"), data: z.string() }),
  // 유니온 discriminator
  z.object({ status: z.union([z.literal("bbb"), z.literal("ccc")]) }),
  // 파이프 discriminator
  z.object({ status: z.literal("fail").transform(val => val.toUpperCase()) }),
])

// 중첩 discriminated union
const BaseError = z.object({ status: z.literal("failed"), message: z.string() })

const MyResult2 = z.discriminatedUnion("status", [
  z.object({ status: z.literal("success"), data: z.string() }),
  z.discriminatedUnion("code", [
    BaseError.extend({ code: z.literal(400) }),
    BaseError.extend({ code: z.literal(401) }),
    BaseError.extend({ code: z.literal(500) })
  ])
])
```

## Enum

```typescript
// 문자열 enum
const FishEnum = z.enum(['Salmon', 'Tuna', 'Trout'])

FishEnum.parse('Salmon') // => "Salmon"
FishEnum.parse('Swordfish') // => ❌ throws

type Fish = z.infer<typeof FishEnum>
// 'Salmon' | 'Tuna' | 'Trout'

// Native enum
enum Fruits {
  Apple,
  Banana,
}
const FruitSchema = z.nativeEnum(Fruits)
```

## Record

```typescript
const UserStore = z.record(z.string(), z.object({
  name: z.string(),
}))

type UserStore = z.infer<typeof UserStore>
// { [key: string]: { name: string } }

// 사용
const userStore: UserStore = {}
userStore['77d2586b-9e8e-4ecf-8b21-ea7e0530eadd'] = {
  name: 'Carlotta',
} // passes

userStore['77d2586b-9e8e-4ecf-8b21-ea7e0530eadd'] = {
  whatever: 'Ice cream sundae',
} // TypeError
```

## Map & Set

```typescript
// Map
const stringNumberMap = z.map(z.string(), z.number())
type StringNumberMap = z.infer<typeof stringNumberMap>
// Map<string, number>

// Set
const numberSet = z.set(z.number())
type NumberSet = z.infer<typeof numberSet>
// Set<number>
```

## 재귀 스키마 (JSON)

```typescript
const literalSchema = z.union([z.string(), z.number(), z.boolean(), z.null()])
type Literal = z.infer<typeof literalSchema>
type Json = Literal | { [key: string]: Json } | Json[]

const jsonSchema: z.ZodType<Json> = z.lazy(() =>
  z.union([literalSchema, z.array(jsonSchema), z.record(jsonSchema)])
)

jsonSchema.parse({ foo: [1, 2, { bar: 'baz' }] })
```
