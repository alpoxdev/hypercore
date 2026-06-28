# Server Functions and Domain Modules

> Server function API usage, runtime validation, and hypercore layering between routes, modules, lib helpers, integrations, and database access.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Use `createServerFn` for client-callable server RPC | Official | Required for server RPC |
| Use `.inputValidator(...)` as canonical validation API | Official + Drift note | Block new `.validator(...)` unless installed types prove otherwise |
| Validate mutation input at runtime | Safety policy | Block POST/PUT/PATCH without validation |
| Handler last in chain | Official/API shape | Block malformed chain |
| Domain module/lib layer for non-trivial logic | Hypercore convention | Apply to touched non-trivial logic |
| Split server function wrappers from server-only helpers | Official + Safety policy | Keep `.functions.ts` and `.server.ts` roles separate |
| No `functions/index.ts` barrel | Hypercore convention + Safety policy | Avoid import-protection/tree-shaking ambiguity |
| Server functions are same-origin app RPC | Official + Safety policy | Use server routes for public/cross-origin HTTP endpoints |

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
- Server functions are same-origin app RPC. Use server routes for public APIs, webhooks, cross-origin endpoints, or raw HTTP semantics under `rules/server-routes.md`.

## Server Function File Organization

TanStack Start's official guidance separates server function wrappers from server-only helpers for larger applications. Hypercore applies this pattern inside route-local `-functions/` exceptions and shared `src/modules/<domain>/<feature>/` nested folders.

Route-local exception example:

```text
src/routes/billing/
├── route.tsx
├── index.tsx
├── -hooks/
│   └── use-invoices.ts
└── -functions/
    ├── invoices.functions.ts
    ├── invoices.server.ts
    └── invoices.schemas.ts
```

Default domain module example:

```text
src/modules/billing/invoices/
├── invoices.functions.ts
├── invoices.server.ts
├── invoices.schemas.ts
├── invoices-query-keys.ts
├── hooks/
└── components/
```

Roles:

| File | Importable from | Allowed contents |
|---|---|---|
| `*.functions.ts` | Static imports from loaders, components, hooks, or other server functions | `createServerFn` wrappers, middleware/inputValidator/handler chains |
| `*.server.ts` | Inside `*.functions.ts` handlers or server-only modules | DB, secrets, filesystem, privileged SDKs, internal business logic |
| `*.schemas.ts` / `schemas.ts` | Client and server | Zod schemas, serializable DTOs, constants |
| `*-query-keys.ts` | Client and server | TanStack Query key builders, cache tags |

Rules:

- Do not dynamically import server functions. Use direct static imports so client-bundle rewrites and import protection remain traceable.
- `*.functions.ts` must not reference server-only helpers from surviving exports outside handlers.
- Do not re-export safe exports and `.server.ts` exports through the same `index.ts` barrel.
- Promote route-local `-functions/` to `src/modules/<domain>/<feature>/` when cross-route reuse, domain nouns, cache/auth, or permission responsibilities appear.
- Shared domain code uses nested domain/feature folders. Do not add new direct leaves such as `src/modules/foo.ts`.
- Keep external provider clients out of domain modules when possible; put them under `src/integrations/<provider>/` or a server-only module.

## Layering

```text
Route / hook / query
  -> routes/<page>/-functions/<resource>.functions.ts
     or src/modules/<domain>/<feature>/<resource>.functions.ts
  -> src/modules/<domain>/<feature>/<resource>.server.ts
  -> src/lib/<domain>/shared helpers, src/db/<domain>/repositories,
     or src/integrations/<provider>/server-only clients
  -> database/ORM client or external SDK
```

- **Safety policy:** routes do not import database/ORM clients directly.
- **Safety policy:** `*.server.ts` or DB/repository imports must not survive in client-reachable files.
- **Hypercore convention:** non-trivial business logic belongs in `modules/<domain>/<feature>/` or domain-specific `lib/<domain>/` folders, not route files.
- **Hypercore convention:** simple CRUD can stay in a server function if extraction would add noise.

## Query and Mutation Pattern

- Reads: use GET server functions when safe and cache semantics are appropriate.
- Mutations: use POST/PUT/PATCH with runtime `inputValidator`.
- Client hooks should usually wrap server functions with `useServerFn` and TanStack Query for cache invalidation.
- Loaders may directly call server functions because route lifecycle code is not a React component.
- Auth-required server functions must not rely only on route `beforeLoad`; add middleware or handler-level auth checks to the server function itself.
- If a custom `src/start.ts` exists, confirm server-function CSRF request middleware is preserved.
- GET server functions that depend on user/session/tenant data must not set public cache headers. Choose response cache policy from identity dependency.

## Validation Checklist

- [ ] New mutation server functions have `.inputValidator(...)`.
- [ ] New `.validator(...)` usage is absent or justified by installed package types.
- [ ] `handler` is last in the chain.
- [ ] Auth-required server functions use middleware or an equivalent checked boundary.
- [ ] `*.functions.ts` and `*.server.ts` are split, and server-only imports do not survive outside recognized boundaries.
- [ ] Server functions are direct static imports, not dynamic imports or mixed-barrel imports.
- [ ] Public/cross-origin/raw HTTP endpoints use server routes, not server functions.
- [ ] Custom `src/start.ts` preserves server-function CSRF middleware when present.
- [ ] Routes do not access ORM/database clients directly.
- [ ] Non-trivial logic is delegated to `modules/<domain>/<feature>/` or domain-specific `lib/<domain>/` folders.
- [ ] No `functions/index.ts` barrel export was introduced.
