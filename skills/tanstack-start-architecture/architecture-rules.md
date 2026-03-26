# Architecture Rules Reference

> Complete rule set for TanStack Start hypercore projects

Note: some rules below are stricter than TanStack Start defaults. They are hypercore team conventions, not universal framework requirements.

Brownfield adoption rule: untouched legacy code may be tracked as migration work instead of an immediate failure if the issue is stylistic or hypercore-specific. Safety-boundary issues still block immediately, especially in touched code.

---

## Forbidden

| Category | Forbidden |
|----------|-----------|
| Routes | Flat file routes (`routes/users.tsx`) |
| Route Export | `export const IndexRoute`, `const Route` (without export) |
| API | `/api` route creation except justified HTTP endpoints such as required `better-auth`, webhooks, health, or machine-readable public endpoints |
| Layers | Skip Features layer, access DB directly from Routes |
| Validation | Manual validation inside handler, scattered auth logic |
| Barrel Export | `functions/index.ts` (Tree Shaking failure) |
| Folder Names | `lib/db`, `lib/store` (use `database/`, `stores/`) |
| Filenames | camelCase (`getUserById.ts`) |
| TypeScript | `any` type, `function` keyword declaration |
| Server Fn API | `.validator()` (does NOT exist — runtime error. Use `.inputValidator()` which accepts `z.object()` directly) |
| Client | Direct Server Function calls (must use TanStack Query) |
| Import Boundaries | Client-reachable `*.server.*`, server-side `*.client.*`, disabled `importProtection` |
| Git | AI markers, multi-line commit messages, emojis |
| ORM | Auto-run `db push/migrate/generate` (Prisma) or unauthorized schema edits. Applies to both Prisma and Drizzle |

---

## Layer Architecture

```
Client (Browser)
  React Router -> TanStack Query -> React UI
  State: TanStack Query (80%) + Zustand (20%)
       |
       v
TanStack Start Server
  Server Functions (routes/-functions/ or functions/)
       |
       v
  Features (internal domain) | Services (external SDK)
  ORM queries, schemas       | Stripe, S3, SendGrid
  (Prisma or Drizzle)        |
       |
       v
  Database Layer (Prisma/Drizzle -> PostgreSQL + Redis)
```

**Data flow rules:**
- Query: Page -> useQuery -> Server Function -> Features -> ORM (Prisma/Drizzle) -> DB
- Mutation: Form -> useMutation -> Server Function -> inputValidator -> Features -> DB -> invalidateQueries

---

## Route Structure Rules

### Every page with logic MUST have:
```
routes/<page>/
├── index.tsx          # UI only (no logic)
├── -components/       # REQUIRED for pages with logic
├── -hooks/            # REQUIRED for pages with logic
├── -functions/        # REQUIRED for pages with logic
└── -sections/         # Optional (200+ lines only)
```

### Publishing-only exception:
Pages that only display static content with **no interactive logic AND no server integration** do NOT require `-components/`, `-hooks/`, `-functions/`.

Examples of publishing-only pages: about, terms, privacy policy, simple marketing pages.

**Server integration = folders required:**
- If a page has **any** server integration (loader calling server functions, `useQuery`, `useMutation`, `useServerFn`, data fetching) → `-functions/` and `-hooks/` are MANDATORY
- If a page has **any** interactive UI logic (`useState`, `useCallback`, custom hooks) → all three folders are required

### Auto-setup rule:
If a TanStack Start project has routes but is missing the required folder structure, create the missing folders automatically before writing any code. Do not create folders for publishing-only pages.

### Route Export (strict):
```typescript
// MUST be exactly this pattern
export const Route = createFileRoute('/path')({
  component: PageComponent,
})
```

### Route Group pattern:
- List pages -> `(main)/` route group
- Create/Edit pages -> outside group
- `route.tsx` for shared layout (beforeLoad, loader)

### `/api` policy:
- Do NOT create `/api` routes for normal app features
- Use TanStack Start Server Functions instead
- Exceptions: required `better-auth` endpoints, webhooks, health/readiness, and explicitly required machine-readable public endpoints
- Any non-justified internal app RPC under `/api` must be treated as an architecture violation unless the user explicitly requests it

### beforeLoad vs loader:
| | beforeLoad | loader |
|---|-----------|--------|
| Execution | Sequential (outer -> inner) | Parallel (after beforeLoad) |
| Use | Auth, context, redirects | Data loading |
| Performance | HIGH impact (blocking) | LOW impact (parallel) |

### Component separation:
- 100+ lines -> extract to `-components/`
- 200+ lines -> extract to `-sections/`
- Component with logic -> subfolder with `-hooks/`

```
-components/
├── user-card/
│   ├── index.tsx           # UI only
│   └── -hooks/
│       └── use-user-card.ts # Logic
```

---

## Server Function Rules

### CRITICAL: `.inputValidator()` is the ONLY validation API

`.validator()` does NOT exist in TanStack Start — it will cause a runtime error. Always use `.inputValidator()`.

`inputValidator` accepts Zod objects directly — no adapter wrapper needed:

```typescript
// ✅ Inline z.object() — simplest pattern
createServerFn({ method: 'POST' })
  .inputValidator(z.object({
    email: z.email(),
    name: z.string().min(1),
  }))
  .handler(async ({ data }) => {})

// ✅ Named Zod schema — also direct
createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {})

// ✅ With zodValidator adapter — optional, for explicit type narrowing
createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))
  .handler(async ({ data }) => {})
```

### Method chaining order:
```typescript
// Pattern A: middleware first
createServerFn({ method: 'POST' })
  .middleware([authMiddleware])      // 1. middleware
  .inputValidator(createUserSchema)  // 2. inputValidator (accepts z.object() directly)
  .handler(async ({ data }) => {})   // 3. handler (always last)

// Pattern B: inputValidator first (also valid)
createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)            // 1. inputValidator
  .middleware([authMiddleware])                 // 2. middleware
  .handler(async ({ data, context }) => {})    // 3. handler (always last)
```

> Both orders are valid. `handler` must ALWAYS be last.

### Placement:
- Global: `functions/<name>.ts` (NO `functions/index.ts`!)
- Per-page: `routes/<page>/-functions/<name>.ts`

### Middleware pattern:
```typescript
// functions/middlewares/auth.ts
export const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, context }) => {
    const session = await getSession()
    if (!session?.user) throw new Error('Unauthorized')
    return next({ context: { ...context, user: session.user } })
  })
```

### Server Function types:
| Type | Location | Use |
|------|----------|-----|
| createServerFn | Server | DB access, secrets (DEFAULT) |
| createClientOnlyFn | Client | localStorage, window |
| createIsomorphicFn | Both | Environment-specific |
| zodValidator | Adapter | Zod schema adapter from `@tanstack/zod-adapter` |

---

## Import Protection Rules

### Core rule:
- Client-reachable code MUST NOT import `*.server.*`
- Server execution paths MUST NOT import `*.client.*`
- Environment-specific modules MUST use filename suffixes or marker imports
- `vite.config.ts` MUST preserve or extend TanStack Start `importProtection`
- `importProtection: { enabled: false }` is forbidden unless the user explicitly requests it

### Marker imports:
```typescript
import '@tanstack/react-start/server-only'
import '@tanstack/react-start/client-only'
```

- Use markers when the filename cannot clearly express the boundary
- Never use both markers in the same file

### `vite.config.ts` baseline:
```typescript
tanstackStart({
  importProtection: {
    behavior: {
      dev: 'mock',
      build: 'error',
    },
    client: {
      files: ['**/*.server.*', '**/server/**', '**/database/**', '**/db/**'],
    },
    server: {
      files: ['**/*.client.*', '**/client/**'],
    },
  },
})
```

### Review rule:
- If dev warns about a leak, confirm with a production build
- If a server-only import survives outside `createServerFn`/`createServerOnlyFn`, refactor immediately

---

## Execution Model Rules

- `loader` is isomorphic by default, not server-only
- Secrets, DB access, filesystem access, and privileged SDK calls belong behind `createServerFn` or `createServerOnlyFn`
- Browser APIs belong behind `createClientOnlyFn`, `ClientOnly`, or client-only hooks/components
- Prefer explicit environment primitives over ad-hoc `typeof window` branching

---

## Server Route Policy

- Default: use Server Functions for internal app RPC
- Allowed server routes: required `better-auth` endpoints, webhooks, health checks, sitemap/robots/feed endpoints, and explicitly required machine-readable public endpoints
- Server routes should stay HTTP-native and protocol-oriented
- Use middleware and explicit `Response` headers/status when HTTP semantics matter

---

## SSR / Hydration Rules

- Avoid hydration-unsafe first render output (`Date.now()`, random IDs, locale-variant text, viewport-only branching)
- Prefer deterministic server output or loader-hydrated values
- Use `ClientOnly` for truly browser-only widgets
- Use route `ssr: false` / `ssr: 'data-only'` deliberately, with fallback strategy
- Understand `shellComponent` behavior before reducing root SSR

---

## Platform Setup Rules

- `src/router.tsx` should export `getRouter()` and return a fresh router instance each call
- Configure path aliases intentionally for the Vite version in use
- Type and validate environment variables
- Keep health/sitemap/robots/LLMO endpoints separate from internal app RPC

---

## Auto-Remediation Policy

- Auto-fix directly when the issue is local, reversible, and low-risk
- Examples: **create missing route folder structure** (`-components/`, `-hooks/`, `-functions/` for pages with logic), add missing `importProtection`, add `getRouter()` pattern, add env typing/validation stubs, add marker imports, add middleware validation, add missing explicit config
- Do not auto-apply broad or potentially breaking migrations without clear justification
- Examples: mass route/file renames, sweeping `/api` to Server Function refactors, SSR mode changes across many routes, alias-wide import rewrites
- In brownfield projects, strict hypercore conventions should always apply to touched files; untouched legacy files can be logged as migration backlog when the issue is non-safety-related

---

## Hook Rules

### Mandatory separation:
ALL pages must have hooks in `-hooks/` folder. No exceptions regardless of page size.

### Internal order (STRICT):
```typescript
export const usePageName = (): UsePageNameReturn => {
  // 1. State (useState, zustand)
  // 2. Global Hooks (useParams, useNavigate, useQueryClient)
  // 3. Server Functions (useServerFn wrappers)
  // 4. React Query (useQuery -> useMutation)
  // 5. Event Handlers (useCallback)
  // 6. useMemo (computed values)
  // 7. useEffect (side effects)

  return { /* ... */ }
}
```

### Requirements:
- Return type interface defined and exported
- Korean block comments for each section (with ━━━ separator)
- `useCallback` for event handlers
- File naming: `use-kebab-case.ts`

---

## Convention Rules

### Filenames:
| Type | Rule | Example |
|------|------|---------|
| General | kebab-case | `user-profile.tsx` |
| Route files | TanStack Router | `__root.tsx`, `index.tsx`, `$id.tsx` |
| Hook files | `use-` prefix | `use-user-filter.ts` |
| Server Fn | kebab-case | `get-users.ts` |

### TypeScript:
- `const` arrow functions (NO `function` keyword)
- Explicit return types always
- `interface` for objects, `type` for unions
- `unknown` instead of `any`
- Type imports separated: `import type { X } from '...'`

### Import order:
```typescript
// 1. External libraries
import { createFileRoute } from '@tanstack/react-router'
// 2. Internal (@/)
import { Button } from '@/components/ui/button'
// 3. Relative
import { UserCard } from './-components/user-card'
// 4. Type imports
import type { User } from '@/types'
```

### Korean block comments:
```typescript
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Section description in Korean
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Error handling:
- `errorComponent` required in each route
- `notFoundComponent` required in `__root.tsx`
- Custom error classes: `AppError`, `NotFoundError`, `ValidationError`, `UnauthorizedError`

---

## Features Layer

```
features/<domain>/
├── schemas.ts      # Zod schemas
├── queries.ts      # TanStack Query options
└── mutations.ts    # useMutation options
```

---

## Services Layer (External SDK)

```
services/<provider>/
├── client.ts       # SDK client
├── types.ts        # Type definitions
└── utils.ts        # Helper functions
```

---

## State Management

| State Type | Tool | Usage |
|------------|------|-------|
| Server state | TanStack Query | API data, caching (80%) |
| Client state | Zustand | UI state, settings (20%) |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | TanStack Start (latest) |
| Router | TanStack Router (latest) |
| Data | TanStack Query 5.x |
| State | Zustand (latest) |
| ORM | Prisma 7.x **or** Drizzle ORM (project choice) |
| Validation | Zod 4.x (`z.email()`, `z.url()`) |
| Zod Adapter | @tanstack/zod-adapter |
| Database | PostgreSQL |
| Cache | Redis |
| UI | React 19+, Tailwind CSS 4.x |
| Auth | Better Auth |
| Env | t3-env |
| Monitoring | Sentry |

---

## Context Management

```typescript
// 1. Root: define context
interface RouterContext { user: User | null }
export const Route = createRootRouteWithContext<RouterContext>()({
  beforeLoad: async () => ({ user: await getUser() }),
})

// 2. Extend in route.tsx
beforeLoad: async ({ context }) => ({
  ...context,
  permissions: await getPermissions(context.user.id),
})

// 3. Use in component
const { user, permissions } = useRouteContext({ from: '/dashboard' })

// 4. Search params validation
import { zodValidator } from '@tanstack/zod-adapter'

export const Route = createFileRoute('/dashboard/')({
  validateSearch: zodValidator(dashboardSearchSchema),
  component: DashboardPage,
})
```

---

## ORM Rules

The project may use **Prisma** or **Drizzle ORM**. Check `package.json` for which is installed. All layer architecture and server function rules apply equally to both.

### Prisma

- Multi-file structure: `prisma/schema/`
  - `+base.prisma` (datasource, generator)
  - `+enum.prisma` (enums)
  - `[model].prisma` (per model)
- Korean comments on ALL elements
- Singleton client in `database/prisma.ts`
- NEVER auto-run `db push`, `migrate`, `generate`

### Drizzle

- Schema in `database/schema/` (TypeScript files)
- Singleton client in `database/drizzle.ts` (or `database/client.ts`)
- NEVER auto-run `drizzle-kit push`, `migrate`, `generate` without explicit permission
- Same layer rules apply: routes must NOT import ORM directly
