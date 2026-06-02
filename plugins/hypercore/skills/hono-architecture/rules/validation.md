# Validation

> Request validation rules for Hono

---

## Core Rule

Validate request data before service logic consumes it.

## Approved options

- `validator()` for narrow built-in checks
- `@hono/zod-validator` when the repo uses Zod
- `@hono/standard-validator` when the repo already standardizes on Standard Schema libraries

## Example

```ts
import { z } from 'zod'
import { zValidator } from '@hono/zod-validator'

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

const app = new Hono().post(
  '/',
  zValidator('json', createUserSchema),
  async (c) => {
    const payload = c.req.valid('json')
    return c.json({ payload }, 201)
  }
)
```

## Review Checklist

- Params/query/json/form use validator middleware when non-trivial
- Validation happens before domain logic
- One feature does not mix unrelated validation styles without reason
- No new dependency is added without need

