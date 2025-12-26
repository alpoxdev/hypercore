# Zod

> **v4** | TypeScript Schema Validation

@complex-types.md
@transforms.md
@validation.md

---

## Quick Reference

```typescript
// 기본 스키마
const schema = z.object({
  email: z.email(),              // v4! (string().email() 아님)
  name: z.string().min(1).trim(),
  website: z.url().optional(),   // v4! (string().url() 아님)
  age: z.number().int().positive(),
})

type Input = z.infer<typeof schema>

// 파싱
schema.parse(data)              // 실패 시 throw
schema.safeParse(data)          // { success, data/error }

// TanStack Start 연동
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(schema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

### ⚠️ v4 새 API

```typescript
// ✅ v4
z.email()          z.url()          z.uuid()
z.iso.date()       z.iso.datetime()

// ❌ v3 deprecated
z.string().email()  z.string().url()
```

### v4 주요 변경

```typescript
// 에러 커스텀: message → error
z.string().min(5, { error: "Too short." })

// Strict/Loose 객체
z.strictObject({ name: z.string() })  // 추가 키 에러
z.looseObject({ name: z.string() })   // 추가 키 통과

// Refinement 체이닝 가능
z.string().refine(val => val.includes("@")).min(5)  // ✅ v4
```

### v4 추가 API

```typescript
// 문자열 불리언 (환경변수용)
z.stringbool()  // "true"/"yes"/"1" → true

// 날짜/시간 ISO 포맷
z.iso.date()      // 2024-01-15
z.iso.datetime()  // ISO 날짜시간
z.iso.duration()  // P1D, PT1H

// 템플릿 리터럴
const css = z.templateLiteral([z.number(), z.enum(["px", "em", "rem"])])
// `${number}px` | `${number}em` | `${number}rem`
```
