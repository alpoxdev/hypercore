# Architecture Rules Reference

> Complete rule set for Vite + TanStack Router hypercore projects

Note: some rules below are stricter than TanStack Router defaults. They are hypercore team conventions, not universal framework requirements.

Brownfield adoption rule: untouched legacy code may be tracked as migration work instead of an immediate failure if the issue is stylistic or hypercore-specific. Safety-boundary issues still block immediately, especially in touched code.

---

## Forbidden

| Category | Forbidden |
|----------|-----------|
| Routes | Flat file routes for full pages that own their own UI/logic folders (`routes/users.tsx`) |
| Route Export | `export const IndexRoute`, `const Route` (without export) |
| Server Functions | `createServerFn`, `useServerFn`, `createMiddleware` (server-side) |
| Route Folders | `-functions/` folder inside any route |
| Layers | Direct `fetch`/`axios` in routes or hooks |
| Barrel Export | `services/index.ts` (Tree Shaking failure) |
| Folder Names | `lib/store` (use `stores/`) |
| Filenames | camelCase (`getUserById.ts`) |
| TypeScript | `any` type, `function` keyword declaration |
| Runtime Boundaries | Secrets, DB clients, or non-`VITE_` env reads in client-reachable route code |
| Generated Files | Hand-editing `routeTree.gen.ts` |
| Git | AI markers, multi-line commit messages, emojis |

---

## Layer Architecture

```
Client (Browser)
  TanStack Router -> TanStack Query -> React UI
  State: TanStack Query (80%) + Zustand (20%)
       |
       v
  Services (API wrappers)
  schemas.ts, queries.ts, mutations.ts
       |
       v
  External API (REST / GraphQL / RPC)
```

**Data flow rules:**
- Query: Page -> useQuery -> service function -> fetch/axios -> External API
- Mutation: Form -> useMutation -> schema validation -> service function -> External API -> invalidateQueries

---

## Route Structure Rules

### Every page MUST have:
```
routes/<page>/
├── route.tsx          # Shared layout / beforeLoad / loader when needed
├── index.tsx          # UI only (no logic)
├── -components/       # REQUIRED always
├── -hooks/            # REQUIRED always (even 10-line pages)
├── $child/
│   ├── index.tsx
│   ├── -components/
│   └── -hooks/
└── -sections/         # Optional (200+ lines only)
```

Hypercore prefers directory routes for any page that owns `-components/` or `-hooks/`, even though TanStack Router also supports flat file forms like `posts.$postId.tsx`.

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
- If the repo customizes `routeToken`, keep the folder convention explicit and documented

### beforeLoad vs loader:
| | beforeLoad | loader |
|---|-----------|--------|
| Execution | Sequential (outer -> inner) | Parallel (after beforeLoad) |
| Use | Auth check, redirects | Query prefetching |
| Performance | HIGH impact (blocking) | LOW impact (parallel) |

### Loader pattern (client-reachable prefetch):
```typescript
// Use ensureQueryData for TanStack Query prefetching.
// Treat loaders as client-reachable. If the app later adds SSR/manual rendering,
// the same loader may also run during server render.
loader: ({ context: { queryClient } }) =>
  queryClient.ensureQueryData(usersQueryOptions()),
```

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

## Services Rules

### Folder structure:
```
services/<domain>/
├── schemas.ts      # Zod schemas + inferred types
├── queries.ts      # GET requests (read)
└── mutations.ts    # POST/PUT/DELETE (write)
```

Import service functions directly from `queries.ts` or `mutations.ts`. Do not add `services/index.ts` barrel exports.

### Query function pattern:
```typescript
// services/user/queries.ts
import type { User } from '@/types'

export const getUsers = async (): Promise<User[]> => {
  const response = await apiClient.get('/users')
  return response.data
}

export const getUserById = async (id: string): Promise<User> => {
  const response = await apiClient.get(`/users/${id}`)
  return response.data
}
```

### Mutation function pattern:
```typescript
// services/user/mutations.ts
import { createUserSchema } from './schemas'
import type { CreateUserInput, User } from '@/types'

export const createUser = async (input: CreateUserInput): Promise<User> => {
  createUserSchema.parse(input)  // validate before send
  const response = await apiClient.post('/users', input)
  return response.data
}
```

### TanStack Query options pattern:
```typescript
// services/user/queries.ts
import { queryOptions } from '@tanstack/react-query'

export const usersQueryOptions = () =>
  queryOptions({
    queryKey: ['users'],
    queryFn: getUsers,
  })

export const userQueryOptions = (id: string) =>
  queryOptions({
    queryKey: ['users', id],
    queryFn: () => getUserById(id),
  })
```

---

## Hook Rules

### Mandatory separation:
ALL pages must have hooks in `-hooks/` folder. No exceptions regardless of page size.

### Internal order (STRICT):
```typescript
export const usePageName = (): UsePageNameReturn => {
  // 1. State (useState, zustand)
  // 2. Global Hooks (useParams, useNavigate, useQueryClient)
  // 3. React Query (useQuery -> useMutation)
  // 4. Event Handlers (useCallback)
  // 5. useMemo (computed values)
  // 6. useEffect (side effects)

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
| Service files | kebab-case | `get-users.ts` |

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

## Execution Model Rules

- Route modules and loaders are client-reachable by default
- If the app adds SSR/manual server rendering, loaders may also execute during server render
- Secrets, DB clients, filesystem access, and privileged SDKs do not belong in routes, loaders, or shared client-reachable helpers
- Browser APIs belong in components/hooks/effects, not in module scope or shared route utilities without a boundary
- Only public `VITE_` env values belong in client-reachable code

---

## Platform Setup Rules

- `vite.config.ts` should keep `tanstackRouter()` explicit and before `react()`
- `routeTree.gen.ts` is generated output and must not be hand-edited
- Keep router wiring explicit in `src/router.tsx`
- If SSR/manual rendering exists, prefer a fresh router factory instead of a process-global singleton
- Keep path aliases explicit in both Vite and TypeScript config
- Keep env typing/runtime validation explicit instead of relying on ad-hoc reads

---

## Auto-Remediation Policy

- Auto-fix directly when the issue is local, reversible, and low-risk
- Examples: add `validateSearch`, move direct route/hook networking into services, add missing `pendingComponent`, add missing route folders, restore explicit router plugin/config wiring
- Do not auto-apply broad or potentially breaking migrations without clear justification
- Examples: mass route/file renames, sweeping route tree restructuring, introducing SSR/manual rendering into an SPA-only app, large auth/api-client rewrites

---

## Services Layer (API)

```
services/<domain>/
├── schemas.ts      # Zod schemas
├── queries.ts      # GET requests + queryOptions
└── mutations.ts    # POST/PUT/DELETE
```

---

## External Services Layer (Third-party SDKs)

```
services/<provider>/
├── client.ts       # SDK client initialization
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
| Bundler | Vite (latest) |
| Router | TanStack Router (latest) |
| Data | TanStack Query 5.x |
| State | Zustand (latest) |
| Validation | Zod 4.x (`z.email()`, `z.url()`) |
| Zod Adapter | @tanstack/zod-adapter |
| UI | React 19+, Tailwind CSS 4.x |
| Auth | Client-side auth (Better Auth / Clerk / etc.) |
| Env | t3-env |
| Monitoring | Sentry |

---

## Context Management

```typescript
// 1. Root: define context
interface RouterContext {
  queryClient: QueryClient
  auth: AuthState
}
export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
})

// 2. Extend in route.tsx
beforeLoad: async ({ context }) => {
  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' })
  }
}

// 3. Use in component
const { queryClient } = useRouteContext({ from: '__root__' })

// 4. Search params validation
import { zodValidator } from '@tanstack/zod-adapter'

export const Route = createFileRoute('/dashboard/')({
  validateSearch: zodValidator(dashboardSearchSchema),
  component: DashboardPage,
})
```

---

## API Client Setup

```typescript
// config/api-client.ts
import axios from 'axios'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: { 'Content-Type': 'application/json' },
})

apiClient.interceptors.request.use((config) => {
  const token = getAuthToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})
```
