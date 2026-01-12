# Zod - 변환

<patterns>

```typescript
// Transform
const stringToLength = z.string().transform((val) => val.length)
stringToLength.parse('hello')  // => 5

type In = z.input<typeof stringToLength>   // string
type Out = z.output<typeof stringToLength> // number

// Pipe (검증 후 변환)
const stringToNumber = z.string()
  .transform((val) => parseInt(val, 10))
  .pipe(z.number().min(0).max(100))

stringToNumber.parse('50')  // => 50
stringToNumber.parse('150') // throws

// Coerce (강제 변환)
z.coerce.string()   // 모든 값 → 문자열
z.coerce.number()   // 모든 값 → 숫자
z.coerce.boolean()  // 모든 값 → 불리언
z.coerce.date()     // 모든 값 → 날짜
z.coerce.bigint()   // 모든 값 → BigInt

z.coerce.number().parse("42")  // => 42
z.coerce.date().parse("2021-01-01")  // => Date

// v4: 입력 타입이 unknown으로 변경
type In = z.input<typeof z.coerce.string()>  // unknown

// v4 환경변수 불리언
z.stringbool()  // "true"/"yes"/"1" → true, "false"/"no"/"0" → false

// Preprocess
const trimmed = z.preprocess(
  (val) => typeof val === 'string' ? val.trim() : val,
  z.string()
)

// 입력/출력 타입 분리
const Schema = z.object({
  createdAt: z.string().transform((str) => new Date(str)),
})
type SchemaInput = z.input<typeof Schema>   // { createdAt: string }
type SchemaOutput = z.output<typeof Schema> // { createdAt: Date }
```

</patterns>
