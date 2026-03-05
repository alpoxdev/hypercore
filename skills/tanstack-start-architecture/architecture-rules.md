# Architecture Rules Reference

> Complete rule set for TanStack Start hypercore projects

---

## Forbidden

| Category | Forbidden |
|----------|-----------|
| Routes | Flat file routes (`routes/users.tsx`) |
| Route Export | `export const IndexRoute`, `const Route` (without export) |
| API | `/api` router creation (use Server Functions) |
| Layers | Skip Features layer, access DB directly from Routes |
| Validation | Manual validation inside handler, scattered auth logic |
| Barrel Export | `functions/index.ts` (Tree Shaking failure) |
| Folder Names | `lib/db`, `lib/store` (use `database/`, `stores/`) |
| Filenames | camelCase (`getUserById.ts`) |
| TypeScript | `any` type, `function` keyword declaration |
| Server Fn API | `.validator()` (does NOT exist, use `.inputValidator()`) |
| Client | Direct Server Function calls (must use TanStack Query) |
| Git | AI markers, multi-line commit messages, emojis |
| Prisma | Auto-run `db push/migrate/generate`, unauthorized `schema.prisma` edits |

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
  Prisma queries, schemas    | Stripe, S3, SendGrid
       |
       v
  Database Layer (Prisma -> PostgreSQL + Redis)
```

**Data flow rules:**
- Query: Page -> useQuery -> Server Function -> Features -> Prisma -> DB
- Mutation: Form -> useMutation -> Server Function -> inputValidator -> Features -> DB -> invalidateQueries

---

## Route Structure Rules

### Every page MUST have:
```
routes/<page>/
├── index.tsx          # UI only (no logic)
├── -components/       # REQUIRED always
├── -hooks/            # REQUIRED always (even 10-line pages)
├── -functions/        # REQUIRED always
└── -sections/         # Optional (200+ lines only)
```

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

### Method chaining order:
```typescript
// Pattern A: middleware first
createServerFn({ method: 'POST' })
  .middleware([authMiddleware])      // 1. middleware
  .inputValidator(createUserSchema)  // 2. inputValidator
  .handler(async ({ data }) => {})   // 3. handler (always last)

// Pattern B: inputValidator first (also valid)
createServerFn({ method: 'POST' })
  .inputValidator(zodValidator(createUserSchema))  // 1. inputValidator
  .middleware([authMiddleware])                     // 2. middleware
  .handler(async ({ data, context }) => {})        // 3. handler (always last)
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
| ORM | Prisma 7.x |
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

## Prisma Rules

- Multi-file structure: `prisma/schema/`
  - `+base.prisma` (datasource, generator)
  - `+enum.prisma` (enums)
  - `[model].prisma` (per model)
- Korean comments on ALL elements
- Singleton client in `database/prisma.ts`
- NEVER auto-run `db push`, `migrate`, `generate`
