# Route Structure

> Vite + TanStack Router file-based routing

---

## Route Folder Structure

```
routes/
├── __root.tsx           # Root Layout
├── index.tsx            # / (Home)
├── users/
│   ├── index.tsx        # /users (List)
│   ├── $id.tsx          # /users/:id (Detail)
│   ├── -components/     # Page-specific components (REQUIRED)
│   ├── -hooks/          # Page-specific hooks (REQUIRED)
│   └── -sections/       # Section separation (optional, complex pages only)
└── posts/
    ├── index.tsx
    ├── $slug.tsx
    ├── -components/     # REQUIRED
    └── -hooks/          # REQUIRED
```

| Prefix | Purpose | Route Generated |
|--------|---------|-----------------|
| `-` | Route-excluded folder | Excluded |
| `$` | Dynamic parameter | Generated |
| `_` | Pathless Layout | Generated (no path) |

**Required rules:**
- Every page MUST have `-components/`, `-hooks/` folders
- NO `-functions/` folder (no server functions in Vite)
- Custom Hooks MUST be separated into `-hooks/` folder **regardless of page size**
- `-sections/` is optional, only for complex pages (200+ lines)

---

## Route Filename Rules

| Path | Filename | Description |
|------|----------|-------------|
| `/` | `index.tsx` | Index route |
| `/users` | `users/index.tsx` | List page |
| `/users/:id` | `users/$id.tsx` | Dynamic parameter |
| `/dashboard/*` | `dashboard/$.tsx` | Catch-all route |
| Layout | `__root.tsx` | Root layout |
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

## Loader Pattern (Client-side Prefetch)

> Loaders in Vite run client-side. Use `ensureQueryData` to prefetch TanStack Query data.

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'
import { userQueryOptions } from '@/services/user/queries'

export const Route = createFileRoute('/users/$id')({
  loader: ({ params: { id }, context: { queryClient } }) =>
    queryClient.ensureQueryData(userQueryOptions(id)),
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const { id } = Route.useParams()
  const { data: user } = useQuery(userQueryOptions(id))
  return (
    <div>
      <h1>{user?.name}</h1>
      <p>{user?.email}</p>
    </div>
  )
}
```

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
| `zodValidator` | `@tanstack/zod-adapter` | Schema validation for search params |
| `fallback` | `@tanstack/zod-adapter` | Default values for invalid params |
| `Route.useSearch()` | `@tanstack/react-router` | Access validated search params |
| `Route.useNavigate()` | `@tanstack/react-router` | Navigate with search param updates |

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
  beforeLoad: ({ context }) => {
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
| ~100 lines | `-components/`, `-hooks/` | - |
| 100-200 lines | `-components/`, `-hooks/` | - |
| 200+ lines | `-components/`, `-hooks/` | `-sections/` |
