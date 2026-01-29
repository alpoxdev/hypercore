# Zod - Validation

<patterns>

```typescript
// Refinement (v4: message → error)
const PasswordSchema = z.string()
  .min(8)
  .refine((val) => /[A-Z]/.test(val), { error: 'Uppercase letter required' })
  .refine((val) => /[0-9]/.test(val), { error: 'Number required' })

z.string().refine(val => val.includes("@")).min(5)  // v4: chaining after refinement

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
      message: 'Passwords do not match',
      path: ['confirmPassword'],
    })
  }
})  // v4: ctx.path is unavailable

// Custom
const px = z.custom<`${number}px`>((val) =>
  typeof val === 'string' && /^\d+px$/.test(val)
)
px.parse('42px')  // ✅
px.parse('42vw')  // throws

// Error handling
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

// Environment variables
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
