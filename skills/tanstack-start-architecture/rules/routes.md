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
| `-hooks/`, `-components/`, `-functions/` for pages with logic/server integration | Hypercore convention | Apply when logic/integration exists |

## Publishing-Only Exception

Publishing-only pages are static display pages with no interactive logic and no server integration.
Examples: terms, privacy, about, simple marketing content.

- They do **not** require `-components/`, `-hooks/`, or `-functions/`.
- If interactive logic is added, create `-hooks/` and route-local components as needed.
- If server integration is added, create `-functions/` and route-local hooks for query/mutation orchestration.

## Hypercore Route Folder Shape

```text
routes/<page>/
├── index.tsx          # page UI only
├── route.tsx          # layout/beforeLoad/loader when needed
├── -components/       # page-local components when UI grows or repeats
├── -hooks/            # page-local interactive/query orchestration
├── -functions/        # page-local server functions
└── -sections/         # optional for large page sections
```

Official TanStack Router supports flat route files. The shape above is a hypercore maintainability convention.

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
- Move privileged work to `createServerFn` or `createServerOnlyFn` and call that boundary from the loader.

## Validation Checklist

- [ ] Touched file routes export `Route`.
- [ ] Search params are validated with a pattern appropriate to the installed Zod version.
- [ ] `beforeLoad` holds auth/context/redirect logic that must run serially.
- [ ] Loader code contains no direct secret/DB/filesystem access.
- [ ] Publishing-only pages were not forced into empty route-local folders.
- [ ] Pages with logic/server integration have route-local organization or a documented reason not to.
