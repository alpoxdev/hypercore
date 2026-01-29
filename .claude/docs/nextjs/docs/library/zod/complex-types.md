# Zod - 복합 타입

<patterns>

```typescript
// 객체
const UserSchema = z.object({
  name: z.string(),
  email: z.email(),
  age: z.number().optional(),
})

UserSchema.partial()              // 모든 필드 optional
UserSchema.required()             // 모든 필드 required
UserSchema.pick({ name: true })   // 특정 필드만
UserSchema.omit({ email: true })  // 특정 필드 제외
UserSchema.extend({ role: z.enum(['admin', 'user']) })
UserSchema.merge(AnotherSchema)

z.strictObject({ name: z.string() })  // v4: 추가 키 에러
z.looseObject({ name: z.string() })   // v4: 추가 키 통과

// 배열/튜플
z.array(z.string())
z.array(z.number()).min(1).max(10).length(5).nonempty()
z.tuple([z.string(), z.number()])  // [string, number]

// 유니온
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

// 재귀
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
