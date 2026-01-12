# Zod - Transforms

<patterns>

```typescript
// Transform
const stringToLength = z.string().transform((val) => val.length)
stringToLength.parse('hello')  // => 5

type In = z.input<typeof stringToLength>   // string
type Out = z.output<typeof stringToLength> // number

// Pipe (validate then transform)
const stringToNumber = z.string()
  .transform((val) => parseInt(val, 10))
  .pipe(z.number().min(0).max(100))

stringToNumber.parse('50')  // => 50
stringToNumber.parse('150') // throws

// Coerce (force conversion)
z.coerce.string()   // any → string
z.coerce.number()   // any → number
z.coerce.boolean()  // any → boolean
z.coerce.date()     // any → Date
z.coerce.bigint()   // any → BigInt

z.coerce.number().parse("42")  // => 42
z.coerce.date().parse("2021-01-01")  // => Date

// v4: input type changed to unknown
type In = z.input<typeof z.coerce.string()>  // unknown

// v4 environment boolean
z.stringbool()  // "true"/"yes"/"1" → true, "false"/"no"/"0" → false

// Preprocess
const trimmed = z.preprocess(
  (val) => typeof val === 'string' ? val.trim() : val,
  z.string()
)

// Separate input/output types
const Schema = z.object({
  createdAt: z.string().transform((str) => new Date(str)),
})
type SchemaInput = z.input<typeof Schema>   // { createdAt: string }
type SchemaOutput = z.output<typeof Schema> // { createdAt: Date }
```

</patterns>
