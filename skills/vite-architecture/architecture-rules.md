# Architecture Rules Reference

> Complete rule set for Vite + TanStack Router hypercore projects

---

## Forbidden

| Category | Forbidden |
|----------|-----------|
| Routes | Flat file routes (`routes/users.tsx`) |
| Route Export | `export const IndexRoute`, `const Route` (without export) |
| Server Functions | `createServerFn`, `useServerFn`, `createMiddleware` (server-side) |
| Route Folders | `-functions/` folder inside any route |
| Layers | Direct `fetch`/`axios` in routes or hooks |
| Barrel Export | `services/index.ts` (Tree Shaking failure) |
| Folder Names | `lib/store` (use `stores/`) |
| Filenames | camelCase (`getUserById.ts`) |
| TypeScript | `any` type, `function` keyword declaration |
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
├── index.tsx          # UI only (no logic)
├── -components/       # REQUIRED always
├── -hooks/            # REQUIRED always (even 10-line pages)
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
| Use | Auth check, redirects | Query prefetching |
| Performance | HIGH impact (blocking) | LOW impact (parallel) |

### loader pattern (client-side prefetch):
```typescript
// Use ensureQueryData for TanStack Query prefetching
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
