# Route Structure

> Route organization, file-route lifecycle, search validation, and hypercore page folder conventions.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| File route instance exported as `Route` | Official | Block if missing |
| Search params validated when consumed | Official + Safety policy | Block if unvalidated user input affects behavior |
| `beforeLoad` before `loader` lifecycle | Official | Use for auth/context/redirect decisions |
| Mixed flat/directory routes supported by Router | Official | Do not claim flat routes are invalid TanStack usage |
| Route-directory preference for app pages | Hypercore convention | Apply to touched app pages unless official defaults requested |
| `-hooks/` and `-components/` for pages with interactive logic or growing UI | Hypercore convention | Apply when route-local orchestration or UI extraction exists |
| `-functions/` only for route-local server function exceptions | Hypercore convention + Safety policy | Use domain modules by default; keep route-only actions local |

## Publishing-Only Exception

Publishing-only pages are static display pages with no interactive logic and no server integration.
Examples: terms, privacy, about, simple marketing content.

- They do **not** require `-components/`, `-hooks/`, or `-functions/`.
- If interactive logic is added, create `-hooks/` and route-local components as needed.
- When server integration is added, the default is to call server functions from `src/modules/<domain>/<feature>/` via route-local hooks. Use `-functions/` only for truly single-route actions.

## Hypercore Route Folder Shape

For global Start project structure, actual route-root discovery, generated `routeTree.gen.ts`, and shared nested folder policy, read `rules/project-structure.md`.

```text
routes/<page>/
├── index.tsx          # page UI only
├── route.tsx          # layout/beforeLoad/loader when needed
├── -components/       # page-local components when UI grows or repeats
├── -hooks/            # page-local interactive/query orchestration
└── -sections/         # optional for large page sections
```

Route-local server function exception:

```text
routes/<page>/
└── -functions/
    ├── <resource>.functions.ts
    ├── <resource>.server.ts
    └── <resource>.schemas.ts
```

Official TanStack Router supports flat route files. The shapes above are hypercore maintainability conventions. `-`-prefixed folders such as `-components/`, `-hooks/`, and `-functions/` align with Router's default ignore prefix and are used as co-location folders that route generation does not treat as route files.

## File Route Export

```typescript
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})
```

- The route instance must be exported as `Route`.
- `createFileRoute` path strings are generated/updated by the router plugin or CLI.

## Route Lifecycle

| Step | Official behavior | Use for |
|---|---|---|
| `validateSearch` | Runs during matching/search validation | Parse and validate URL search state |
| `beforeLoad` | Runs serially before route loading | Auth, redirects, context extension |
| `loader` | Runs in route loading phase and can be cached/preloaded | Data loading; do not treat as server-only |
| `pendingComponent` | Optional threshold-based pending UI | Slow critical loader UX |
| `errorComponent` | Handles route lifecycle/render errors | Recoverable route errors |

## Search Validation

When a route consumes search params, validate them.

Zod v4 official path:

```typescript
import { z } from 'zod'

const searchSchema = z.object({
  page: z.number().default(1),
})

export const Route = createFileRoute('/products/')({
  validateSearch: searchSchema,
  component: ProductsPage,
})
```

Zod v3 official path:

```typescript
import { zodValidator, fallback } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  page: fallback(z.number(), 1).default(1),
})

export const Route = createFileRoute('/products/')({
  validateSearch: zodValidator(searchSchema),
  component: ProductsPage,
})
```

If a project standardizes on `zodValidator` for all versions, label that as a hypercore convention in the project notes.

## Loader Boundary Rule

- Loaders are isomorphic in TanStack Start.
- Do not access secrets, database clients, filesystem, or privileged SDKs directly in loader code.
- Move privileged work behind `createServerFn` in route-local exception `-functions/<resource>.functions.ts` or the default shared location `src/modules/<domain>/<feature>/<resource>.functions.ts`.
- Import `*.server.ts` helpers only inside `*.functions.ts` handlers; routes/components/hooks statically import the server function wrapper.

## Validation Checklist

- [ ] Touched file routes export `Route`.
- [ ] Search params are validated with a pattern appropriate to the installed Zod version.
- [ ] `beforeLoad` holds auth/context/redirect logic that must run serially.
- [ ] Loader code contains no direct secret/DB/filesystem access.
- [ ] Publishing-only pages were not forced into empty route-local folders.
- [ ] Pages with interactive logic have route-local hooks/components or a documented reason not to.
- [ ] Route-local server functions use `.functions.ts` / `.server.ts` / schema split or have been promoted to `src/modules/<domain>/<feature>/`.
