# Zod - 검증

> **상위 문서**: [Zod](./index.md)

## Refinement (커스텀 검증)

```typescript
// v4 - error 파라미터 사용 (message는 deprecated)
const PasswordSchema = z.string()
  .min(8)
  .refine((val) => /[A-Z]/.test(val), {
    error: '대문자가 포함되어야 합니다',  // v4: message → error
  })
  .refine((val) => /[0-9]/.test(val), {
    error: '숫자가 포함되어야 합니다',
  })
```

### v4 Refinement 체이닝 개선

```typescript
// v3 - ZodEffects로 래핑되어 .min() 호출 불가
z.string()
  .refine(val => val.includes("@"))
  .min(5) // ❌ 에러

// v4 - 스키마 내부에 저장되어 체이닝 가능
z.string()
  .refine(val => val.includes("@"))
  .min(5) // ✅ 정상 작동
```

### Async Refinement

```typescript
const schema = z.string().refine(async (val) => val.length <= 8)

await schema.parseAsync('hello') // => "hello"
```

### 이메일 중복 검사 예시

```typescript
const EmailSchema = z.email()  // v4 새 API
  .refine(async (email) => {
    const exists = await checkEmailExists(email)
    return !exists
  }, {
    error: '이미 사용 중인 이메일입니다',  // v4: message → error
  })
```

## Superrefine (고급 검증)

여러 이슈를 추가하거나 경로를 지정할 수 있습니다.

> **v4 변경**: `ctx.path`는 더 이상 사용할 수 없습니다 (성능 향상을 위해 제거됨)

```typescript
const Schema = z.object({
  password: z.string(),
  confirmPassword: z.string(),
}).superRefine((data, ctx) => {
  if (data.password !== data.confirmPassword) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: '비밀번호가 일치하지 않습니다',
      path: ['confirmPassword'],
    })
  }
  // ctx.path // ❌ v4에서 더 이상 사용 불가
})
```

### 복잡한 검증 로직

```typescript
const UserSchema = z.object({
  username: z.string(),
  email: z.string().email(),
  age: z.number(),
}).superRefine((data, ctx) => {
  // 여러 조건 검증
  if (data.age < 13 && data.email.includes('work')) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: '13세 미만은 업무용 이메일을 사용할 수 없습니다',
      path: ['email'],
    })
  }

  if (data.username.toLowerCase() === 'admin' && data.age < 18) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'admin 사용자명은 18세 이상만 사용 가능합니다',
      path: ['username'],
    })
  }
})
```

## 커스텀 스키마

```typescript
const px = z.custom<`${number}px`>((val) => {
  return typeof val === 'string' ? /^\d+px$/.test(val) : false
})

type Px = z.infer<typeof px> // `${number}px`

px.parse('42px')  // '42px'
px.parse('42vw')  // throws
```

## TanStack Start와 함께 사용

### Server Function 입력 검증

```typescript
import { createServerFn } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/react-start/validators'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),  // v4 새 API
  name: z.string().min(1).max(100).trim(),
  bio: z.string().max(500).optional(),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => {
    // data는 타입 안전함
    return prisma.user.create({ data })
  })
```

### 환경 변수 검증

```typescript
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  API_SECRET: z.string().min(32),
})

export const env = envSchema.parse(process.env)
```

### Middleware에서 사용

```typescript
import { createMiddleware } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/react-start/validators'
import { z } from 'zod'

const mySchema = z.object({
  workspaceId: z.string(),
})

const workspaceMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(zodValidator(mySchema))
  .server(({ next, data }) => {
    console.log('Workspace ID:', data.workspaceId)
    return next()
  })
```

## 에러 처리

```typescript
const result = UserSchema.safeParse(data)

if (!result.success) {
  // ZodError 객체
  const errors = result.error.errors

  errors.forEach((err) => {
    console.log('Path:', err.path)
    console.log('Message:', err.message)
    console.log('Code:', err.code)
  })

  // 평면화된 에러
  const flatErrors = result.error.flatten()
  console.log(flatErrors.fieldErrors)
  // { email: ['Invalid email'], name: ['Required'] }
}
```

## Zod Mini (경량 버전)

v4에서 새롭게 추가된 경량 API:

```typescript
import * as z from "zod/mini"

// regular Zod
z.string().min(5).max(10).trim()

// Zod Mini - check 메서드로 통합
z.string().check(
  z.minLength(5),
  z.maxLength(10),
  z.toLowerCase(),
  z.trim(),
)
```
