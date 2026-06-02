# Server Functions and Service Layer

> Server function API usage, runtime validation, and hypercore layering between routes, features, services, and database access.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Use `createServerFn` for client-callable server RPC | Official | Required for server RPC |
| Use `.inputValidator(...)` as canonical validation API | Official + Drift note | Block new `.validator(...)` unless installed types prove otherwise |
| Validate mutation input at runtime | Safety policy | Block POST/PUT/PATCH without validation |
| Handler last in chain | Official/API shape | Block malformed chain |
| Feature/service layer for non-trivial logic | Hypercore convention | Apply to touched non-trivial logic |
| No `functions/index.ts` barrel | Hypercore convention + Safety policy | Avoid import-protection/tree-shaking ambiguity |

See `references/official/api-drift-notes.md` for `.inputValidator()` vs stale `.validator()` examples.

## Canonical Server Function Pattern

```typescript
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .middleware([authMiddleware])
  .handler(async ({ data, context }) => {
    return createUserMutation({ data, user: context.user })
  })
```

Notes:

- `inputValidator` can accept Zod schemas directly in the canonical current guide.
- Middleware and input validation order can vary; `handler` must finish the chain.
- If a project-local installed version disagrees, verify with typecheck and record the exception.

## Layering

```text
Route / hook / query
  -> server function in routes/<page>/-functions/ or functions/
  -> features/<domain>/queries.ts or mutations.ts
  -> database/ ORM client or services/<provider>/ SDK wrapper
```

- **Safety policy:** routes do not import database/ORM clients directly.
- **Hypercore convention:** non-trivial business logic belongs in `features/` or `services/`, not route files.
- **Hypercore convention:** simple CRUD can stay in a server function if extraction would add noise.

## Query and Mutation Pattern

- Reads: use GET server functions when safe and cache semantics are appropriate.
- Mutations: use POST/PUT/PATCH with runtime `inputValidator`.
- Client hooks should usually wrap server functions with `useServerFn` and TanStack Query for cache invalidation.
- Loaders may directly call server functions because route lifecycle code is not a React component.

## Validation Checklist

- [ ] New mutation server functions have `.inputValidator(...)`.
- [ ] New `.validator(...)` usage is absent or justified by installed package types.
- [ ] `handler` is last in the chain.
- [ ] Auth-required server functions use middleware or an equivalent checked boundary.
- [ ] Routes do not access ORM/database clients directly.
- [ ] Non-trivial logic is delegated to `features/` or `services/`.
- [ ] No `functions/index.ts` barrel export was introduced.
