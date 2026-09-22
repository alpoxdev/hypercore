# Validation

> Request validation rules for Hono

---
## Stable Package Baseline

As verified on 2026-08-04: `@hono/zod-validator` 0.9.0 supports Hono `>=4.11.2` and Zod `^3.25.0 || ^4.0.0`; `@hono/standard-validator` 0.3.0 supports Hono `>=4.11.2` and Standard Schema `^1.0.0`. Inspect the installed lockfile before using APIs or syntax.

- Validate every externally controlled `param`, `query`, `header`, `cookie`, `json`, or `form` value that influences behavior.
- Consume validator output only through `c.req.valid(target)`; do not parse the same body again.
- Header schema keys must be lowercase.
- JSON validation requires an appropriate `Content-Type`; test missing/wrong content types and malformed bodies.
- Define hook/error behavior once per API surface so validation errors share a stable, non-sensitive envelope.
- Keep coercion and defaults intentional. Query/path inputs start as strings and must not acquire surprising domain semantics.
- Do not add or swap validation libraries merely to match this skill.

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


## Sources

> No external sources were used in this file. Official Hono behavior is delegated to `references/official/hono-docs.md` (last verified 2026-08-04). Repository-local links checked 2026-09-21.
