# Zod

> v4 | TypeScript Schema Validation

@complex-types.md
@transforms.md
@validation.md

---

<quick_reference>

```typescript
// 기본
const schema = z.object({
  email: z.email(),              // v4!
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // v4!
  age: z.number().int().positive(),
})
type Input = z.infer<typeof schema>

schema.parse(data)              // 실패 시 throw
schema.safeParse(data)          // { success, data/error }

// TanStack Start
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(schema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

</quick_reference>

<v4_changes>

```typescript
// ✅ v4 새 API
z.email()  z.url()  z.uuid()
z.iso.date()  z.iso.datetime()  z.iso.duration()
z.stringbool()  // "true"/"yes"/"1" → true

// ❌ v3 deprecated
z.string().email()  z.string().url()

// 변경사항
z.string().min(5, { error: "Too short." })  // message → error
z.strictObject({ name: z.string() })  // 추가 키 에러
z.looseObject({ name: z.string() })   // 추가 키 통과
z.string().refine(val => val.includes("@")).min(5)  // refinement 체이닝

// 템플릿 리터럴
const css = z.templateLiteral([z.number(), z.enum(["px", "em", "rem"])])
// `${number}px` | `${number}em` | `${number}rem`
```

</v4_changes>
