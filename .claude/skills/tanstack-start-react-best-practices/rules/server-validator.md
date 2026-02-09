---
title: Use inputValidator for Type-Safe Server Functions
impact: HIGH
impactDescription: runtime type safety with Zod
tags: server, validation, inputValidator, zod, tanstack-start
---

## inputValidator로 타입 안전한 Server Functions

`createServerFn`의 `.inputValidator()`로 런타임 입력 검증과 TypeScript 타입 추론을 동시에 확보합니다.

**❌ 잘못된 예시 (검증 없음, 타입 안전하지 않음):**

```typescript
const createUser = createServerFn({ method: 'POST' })
  .handler(async (data: any) => {
    // data가 검증되지 않음 - 런타임 에러 위험
    return await db.user.create({ data })
  })
```

**✅ 올바른 예시 (Zod로 검증 + 타입 추론):**

```typescript
import { z } from 'zod'
import { createServerFn } from '@tanstack/react-start'

const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email()
})

const createUser = createServerFn({ method: 'POST' })
  .inputValidator((d: unknown) => UserSchema.parse(d))
  .handler(async ({ data }) => {
    // data는 자동으로 { name: string; email: string } 타입
    return await db.user.create({ data })
  })

// 클라이언트에서 호출
await createUser({ data: { name: 'Alice', email: 'alice@example.com' } })
```

**중요:** `.inputValidator()`는 반드시 **함수** 형태로 전달해야 합니다. Zod schema를 직접 전달하면 안 됩니다.

```typescript
// ❌ 잘못됨: schema 직접 전달
.inputValidator(UserSchema)

// ✅ 올바름: 함수로 감싸서 전달
.inputValidator((d: unknown) => UserSchema.parse(d))
```

**FormData 검증:**

```typescript
const uploadFile = createServerFn({ method: 'POST' })
  .inputValidator((d: unknown) => {
    if (!(d instanceof FormData)) throw new Error('Expected FormData')
    return {
      name: d.get('name')?.toString() || '',
      file: d.get('file') as File
    }
  })
  .handler(async ({ data }) => {
    // data.name, data.file 모두 타입 안전
    return await saveFile(data.file)
  })
```

참고: [Server Functions Guide](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
