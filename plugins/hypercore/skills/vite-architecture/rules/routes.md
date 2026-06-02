# Route Structure

> Vite + TanStack Router file-based routing

Note: TanStack Router officially supports both flat file routes and folder routes. Hypercore intentionally prefers folder routes for pages that own `-components/` or `-hooks/`, because that keeps UI, logic, and nested page assets together.

---

## Route Folder Structure

```
routes/
├── __root.tsx           # Root Layout
├── index.tsx            # / (Home)
├── users/
│   ├── route.tsx        # Shared layout / beforeLoad / loader
│   ├── index.tsx        # /users (List)
│   ├── -components/     # Page-specific components (REQUIRED)
│   ├── -hooks/          # Page-specific hooks (REQUIRED)
│   ├── $id/
│   │   ├── index.tsx    # /users/:id (Detail)
│   │   ├── -components/ # REQUIRED
│   │   └── -hooks/      # REQUIRED
│   └── -sections/       # Section separation (optional, complex pages only)
└── posts/
    ├── index.tsx
    ├── -components/     # REQUIRED
    ├── -hooks/          # REQUIRED
    └── $slug/
        ├── index.tsx
        ├── -components/
        └── -hooks/
```

| Prefix | Purpose | Route Generated |
|--------|---------|-----------------|
| `-` | Route-excluded folder | Excluded |
| `$` | Dynamic parameter | Generated |
| `_` | Pathless Layout | Generated (no path) |
| `(group)/` | Route group (parentheses) | URL is unchanged; only used to organize files |

**Required rules:**
- Every page MUST have `-components/`, `-hooks/` folders
- NO `-functions/` folder (no server functions in Vite)
- Custom Hooks MUST be separated into `-hooks/` folder **regardless of page size**
- `-sections/` is optional, only for complex pages (200+ lines)
- Use `route.tsx` for shared layout, `beforeLoad`, or shared loader behavior
- If the repo customizes `routeToken`, keep the convention explicit in `tsr.config.json`

---

## Route Filename Rules

| Path | Filename | Description |
|------|----------|-------------|
| `/` | `index.tsx` | Index route |
| `/users` | `users/index.tsx` | List page |
| `/users/:id` | `users/$id/index.tsx` | Dynamic parameter |
| `/dashboard/*` | `dashboard/$.tsx` | Catch-all route |
| Layout | `__root.tsx` | Root layout |
| Folder layout | `users/route.tsx` | Layout for child pages under `/users` |
| Pathless | `_layout.tsx` | Pathless layout |

---

## Basic Route Pattern

```tsx
// routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { UserListSection } from './-sections/user-list-section'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})

const UsersPage = (): JSX.Element => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <UserListSection />
    </div>
  )
}
```

## Loader Pattern (Client-Reachable Prefetch)

> Treat route loaders as client-reachable code. In a typical SPA-only Vite app they run on navigation in the browser. If the repo later adds SSR or manual server rendering, the same loader may also participate in server render. Keep loaders public-safe either way.

The recommended pairing in current TanStack Router docs is `ensureQueryData` in the loader plus `useSuspenseQuery` in the component. `useSuspenseQuery` reads the cache the loader already filled and subscribes to updates without a loading flash.

```tsx
// routes/users/$id/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { useSuspenseQuery } from '@tanstack/react-query'
import { userQueryOptions } from '@/services/user/queries'

export const Route = createFileRoute('/users/$id')({
  loader: ({ params: { id }, context: { queryClient } }) =>
    queryClient.ensureQueryData(userQueryOptions(id)),
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const { id } = Route.useParams()
  const { data: user } = useSuspenseQuery(userQueryOptions(id))
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

Use `useQuery` only for non-critical data fetched alongside (e.g. analytics widgets) where a loading skeleton is acceptable.

## Deferred Data Loading

```tsx
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

export const Route = createFileRoute('/dashboard/')({
  loader: async ({ context: { queryClient } }) => {
    const slowDataPromise = queryClient.fetchQuery(slowQueryOptions())
    const fastData = await queryClient.ensureQueryData(fastQueryOptions())
    return { fastData, deferredSlowData: slowDataPromise }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { fastData, deferredSlowData } = Route.useLoaderData()
  return (
    <div>
      <div>{JSON.stringify(fastData)}</div>
      <Suspense fallback={<div>Loading...</div>}>
        <Await promise={deferredSlowData}>
          {(data) => <div>{JSON.stringify(data)}</div>}
        </Await>
      </Suspense>
    </div>
  )
}
```

---

## Search Params Validation

> Type-safe search parameters with `@tanstack/zod-adapter`

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { zodValidator, fallback } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  page: fallback(z.number().int().positive(), 1),
  filter: z.string().optional(),
  sortBy: z.enum(['newest', 'oldest', 'price']).default('newest'),
})

export const Route = createFileRoute('/products/')({
  validateSearch: zodValidator(searchSchema),
  // Bridge validated search params into the loader cache key
  loaderDeps: ({ search: { page, sortBy, filter } }) => ({ page, sortBy, filter }),
  loader: ({ deps, context: { queryClient } }) =>
    queryClient.ensureQueryData(productsQueryOptions(deps)),
  component: ProductsPage,
})

const ProductsPage = (): JSX.Element => {
  const { page, filter, sortBy } = Route.useSearch()
  const navigate = Route.useNavigate()

  return (
    <div>
      <select
        value={sortBy}
        onChange={(e) =>
          navigate({
            search: (prev) => ({ ...prev, sortBy: e.target.value as 'newest' | 'oldest' | 'price' }),
          })
        }
      >
        <option value="newest">Newest</option>
        <option value="oldest">Oldest</option>
        <option value="price">Price</option>
      </select>
    </div>
  )
}
```

| API | Source | Purpose |
|-----|--------|---------|
| `zodValidator` | `@tanstack/zod-adapter` | Schema validation for search params (Zod v3) |
| `fallback` | `@tanstack/zod-adapter` | Default values for invalid params (preserves type, unlike raw `.catch()`) |
| `loaderDeps` | route option | Bridge validated search params into loader cache keys |
| `Route.useSearch()` | `@tanstack/react-router` | Access validated search params |
| `Route.useNavigate()` | `@tanstack/react-router` | Navigate with search param updates |

> Zod 4: you can pass the schema directly to `validateSearch` without `zodValidator` (the adapter is only needed for Zod v3). On Zod v3, prefer `fallback(...)` over `.catch(...)`; with `zodValidator` plain `.catch()` makes the inferred type `unknown`.

### Route Group (parentheses)

Wrap files inside `(groupName)/` to organize them without changing the URL. Hypercore commonly uses `(main)/` for list pages so create/edit pages can live outside the group while sharing nothing in the URL.

```text
routes/
├── (main)/
│   ├── users/
│   │   ├── route.tsx          # /users layout
│   │   └── index.tsx          # /users
│   └── posts/
│       └── index.tsx          # /posts
└── users/
    └── new/
        └── index.tsx          # /users/new (outside the group)
```

---

## Route Options: Loading & Error States

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/')({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(postsQueryOptions()),
  pendingComponent: () => <div>Loading posts...</div>,
  errorComponent: ({ error }) => (
    <div>
      <h2>Error</h2>
      <p>{error.message}</p>
    </div>
  ),
  component: PostsPage,
})
```

| Route Option | Purpose | Required |
|--------------|---------|----------|
| `pendingComponent` | Loading UI while loader runs | Recommended |
| `errorComponent` | Error UI when loader/component fails | Required |
| `notFoundComponent` | 404 UI (root route) | Required in `__root.tsx` |
| `validateSearch` | Search param validation | When using search params |

---

## Auth Guard Pattern (beforeLoad)

```tsx
// routes/dashboard/route.tsx
import { createFileRoute, redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
  },
})
```

---

## Loader Execution Order

| Step | Execution | Description |
|------|-----------|-------------|
| 0. `validateSearch` | Before navigation | Search params validation |
| 1. `beforeLoad` | Sequential (outermost -> innermost) | Auth check, redirects |
| 2. `loader` | Parallel (all loaders simultaneously) | Query prefetching |

---

## Folder Structure Rules

| Page Size | Required | Optional |
|-----------|----------|----------|
| ~100 lines | `route.tsx` when shared layout/loader exists, plus `-components/`, `-hooks/` | - |
| 100-200 lines | `-components/`, `-hooks/` | - |
| 200+ lines | `-components/`, `-hooks/` | `-sections/` |
