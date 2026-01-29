# Zod - 검증

<patterns>

```typescript
// Refinement (v4: message → error)
const PasswordSchema = z.string()
  .min(8)
  .refine((val) => /[A-Z]/.test(val), { error: '대문자 필수' })
  .refine((val) => /[0-9]/.test(val), { error: '숫자 필수' })

z.string().refine(val => val.includes("@")).min(5)  // v4: refinement 후 체이닝

// Async
const schema = z.string().refine(async (val) => val.length <= 8)
await schema.parseAsync('hello')

// Superrefine
z.object({
  password: z.string(),
  confirmPassword: z.string(),
}).superRefine((data, ctx) => {
  if (data.password !== data.confirmPassword) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: '비밀번호 불일치',
      path: ['confirmPassword'],
    })
  }
})  // v4: ctx.path 사용 불가

// 커스텀
const px = z.custom<`${number}px`>((val) =>
  typeof val === 'string' && /^\d+px$/.test(val)
)
px.parse('42px')  // ✅
px.parse('42vw')  // throws

// 에러 처리
const result = schema.safeParse(data)
if (!result.success) {
  result.error.errors.forEach((err) => {
    console.log(err.path, err.message, err.code)
  })
  const flat = result.error.flatten()  // { fieldErrors: { email: ['Invalid email'] } }
}

// TanStack Start
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => prisma.user.create({ data }))

// 환경 변수
const env = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  API_SECRET: z.string().min(32),
}).parse(process.env)

// Middleware
const workspaceMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(zodValidator(z.object({ workspaceId: z.string() })))
  .server(({ next, data }) => next())

// Zod Mini (v4)
import * as z from "zod/mini"
z.string().check(z.minLength(5), z.maxLength(10), z.trim())
```

</patterns>
