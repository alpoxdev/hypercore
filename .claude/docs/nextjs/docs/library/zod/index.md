# Zod

> v4 | TypeScript Schema Validation

@complex-types.md
@transforms.md
@validation.md

---

<quick_reference>

```typescript
// Basic
const schema = z.object({
  email: z.email(),              // v4!
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // v4!
  age: z.number().int().positive(),
})
type Input = z.infer<typeof schema>

schema.parse(data)              // throws on failure
schema.safeParse(data)          // { success, data/error }

// TanStack Start
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(schema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

</quick_reference>

<v4_changes>

```typescript
// ✅ v4 new APIs
z.email()  z.url()  z.uuid()
z.iso.date()  z.iso.datetime()  z.iso.duration()
z.stringbool()  // "true"/"yes"/"1" → true

// ❌ v3 deprecated
z.string().email()  z.string().url()

// Changes
z.string().min(5, { error: "Too short." })  // message → error
z.strictObject({ name: z.string() })  // additional keys throw error
z.looseObject({ name: z.string() })   // additional keys pass through
z.string().refine(val => val.includes("@")).min(5)  // refinement chaining

// Template literals
const css = z.templateLiteral([z.number(), z.enum(["px", "em", "rem"])])
// `${number}px` | `${number}em` | `${number}rem`
```

</v4_changes>
