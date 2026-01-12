# Zod - Complex Types

<patterns>

```typescript
// Object
const UserSchema = z.object({
  name: z.string(),
  email: z.email(),
  age: z.number().optional(),
})

UserSchema.partial()              // all fields optional
UserSchema.required()             // all fields required
UserSchema.pick({ name: true })   // specific fields only
UserSchema.omit({ email: true })  // exclude specific fields
UserSchema.extend({ role: z.enum(['admin', 'user']) })
UserSchema.merge(AnotherSchema)

z.strictObject({ name: z.string() })  // v4: additional keys throw error
z.looseObject({ name: z.string() })   // v4: additional keys pass through

// Array/Tuple
z.array(z.string())
z.array(z.number()).min(1).max(10).length(5).nonempty()
z.tuple([z.string(), z.number()])  // [string, number]

// Union
z.union([z.string(), z.number()])
z.string().or(z.number())

z.discriminatedUnion('type', [
  z.object({ type: z.literal('circle'), radius: z.number() }),
  z.object({ type: z.literal('rectangle'), width: z.number(), height: z.number() }),
])

// Enum
const Status = z.enum(['pending', 'done', 'cancelled'])
type Status = z.infer<typeof Status>  // 'pending' | 'done' | 'cancelled'

enum Fruits { Apple, Banana }
z.nativeEnum(Fruits)

// Record/Map/Set
z.record(z.string(), z.object({ name: z.string() }))  // { [key: string]: { name: string } }
z.map(z.string(), z.number())  // Map<string, number>
z.set(z.number())              // Set<number>

// Recursive
type Json = string | number | boolean | null | { [key: string]: Json } | Json[]

const jsonSchema: z.ZodType<Json> = z.lazy(() =>
  z.union([
    z.string(), z.number(), z.boolean(), z.null(),
    z.array(jsonSchema),
    z.record(jsonSchema)
  ])
)
```

</patterns>
