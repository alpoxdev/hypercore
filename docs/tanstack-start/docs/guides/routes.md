# Route Structure

> TanStack Start File-Based Routing

<instructions>
@../library/tanstack-router/index.md
</instructions>

---

<route_structure>

## Route Folder Structure

```
routes/
├── __root.tsx           # Root Layout
├── index.tsx            # / (Home)
├── users/
│   ├── index.tsx        # /users (List)
│   ├── $id.tsx          # /users/:id (Detail)
│   ├── -components/     # Page-specific components (required)
│   ├── -hooks/          # Page-specific Hooks (required)
│   ├── -functions/      # Page-specific Server Functions (required)
│   └── -sections/       # Section separation (optional, complex pages only)
└── posts/
    ├── index.tsx
    ├── $slug.tsx
    ├── -components/     # Required
    ├── -hooks/          # Required
    └── -functions/      # Required
```

| Prefix | Purpose | Route Generation |
|--------|---------|------------------|
| `-` | Exclude from routes | ❌ Excluded |
| `$` | Dynamic parameters | ✅ Generated |
| `_` | Pathless Layout | ✅ Generated (no path) |

**⚠️ Required Rules:**
- All pages must have `-components/`, `-hooks/`, `-functions/` folders
- Custom Hooks must always be separated into `-hooks/` folder regardless of page size
- `-sections/` is optional, use only for complex pages (200+ lines)

</route_structure>

---

<file_naming>

## Route File Naming Rules

| Path | Filename | Description |
|------|----------|-------------|
| `/` | `index.tsx` | Index route |
| `/users` | `users/index.tsx` | List page |
| `/users/:id` | `users/$id.tsx` | Dynamic parameter |
| `/posts/:slug` | `posts/$slug.tsx` | URL parameter |
| `/dashboard/*` | `dashboard/$.tsx` | Catch-all route |
| Layout | `__root.tsx` | Root layout |
| Pathless | `_layout.tsx` | Pathless layout |

</file_naming>

---

<patterns>

## Basic Route Pattern

```tsx
// routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { UserListSection } from './-sections/user-list-section'
import { UserFilterSection } from './-sections/user-filter-section'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})

const UsersPage = (): JSX.Element => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <UserFilterSection />
      <UserListSection />
    </div>
  )
}
```

## Dynamic Route + Loader

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getUserById } from '@/services/user'

export const Route = createFileRoute('/users/$id')({
  loader: ({ params: { id } }) => getUserById({ data: id }),
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const user = Route.useLoaderData()

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

## Loader with Dependencies

```tsx
// routes/posts/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPosts } from '@/services/post'
import { z } from 'zod'

const postsSearchSchema = z.object({
  offset: z.number().default(0),
  limit: z.number().default(10),
})

export const Route = createFileRoute('/posts/')({
  validateSearch: postsSearchSchema,
  loaderDeps: ({ search: { offset, limit } }) => ({ offset, limit }),
  loader: ({ deps: { offset, limit } }) => getPosts({ data: { offset, limit } }),
  component: PostsPage,
})

const PostsPage = (): JSX.Element => {
  const posts = Route.useLoaderData()
  const { offset, limit } = Route.useSearch()

  return (
    <div>
      <h1>Posts (offset: {offset}, limit: {limit})</h1>
      {posts.map((post) => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

## Deferred Data Loading

```tsx
// routes/dashboard/index.tsx
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'
import { getFastData, getSlowData } from '@/services/dashboard'

export const Route = createFileRoute('/dashboard/')({
  loader: async () => {
    const slowDataPromise = getSlowData()
    const fastData = await getFastData()

    return {
      fastData,
      deferredSlowData: slowDataPromise,
    }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { fastData, deferredSlowData } = Route.useLoaderData()

  return (
    <div>
      <h1>Fast Data</h1>
      <pre>{JSON.stringify(fastData, null, 2)}</pre>

      <h1>Slow Data (Deferred)</h1>
      <Suspense fallback={<div>Loading slow data...</div>}>
        <Await promise={deferredSlowData}>
          {(slowData) => <pre>{JSON.stringify(slowData, null, 2)}</pre>}
        </Await>
      </Suspense>
    </div>
  )
}
```

## Section Pattern

```tsx
// routes/users/-sections/user-list-section.tsx
import { useUsers } from '../-hooks/use-users'
import { UserCard } from '../-components/user-card'

export const UserListSection = (): JSX.Element => {
  const { users, isLoading, error, deleteUser, isDeleting } = useUsers()

  if (isLoading) return <div className="text-center py-8">Loading...</div>
  if (error) return <div className="text-red-600 py-8">Error: {error.message}</div>
  if (!users?.length) return <div className="text-gray-500 py-8">No users found</div>

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {users.map((user) => (
        <UserCard
          key={user.id}
          user={user}
          onDelete={deleteUser}
          isDeleting={isDeleting}
        />
      ))}
    </div>
  )
}
```

## Component Pattern

```tsx
// routes/users/-components/user-card.tsx
import type { User } from '@/types'
import { Button } from '@/components/ui/button'

interface UserCardProps {
  user: User
  onDelete?: (id: string) => void
  isDeleting?: boolean
}

export const UserCard = ({
  user,
  onDelete,
  isDeleting,
}: UserCardProps): JSX.Element => {
  return (
    <div className="rounded-lg border p-4 shadow-sm">
      <div className="flex items-center gap-4">
        <div className="h-12 w-12 rounded-full bg-gray-200" />
        <div>
          <h3 className="font-semibold">{user.name}</h3>
          <p className="text-sm text-gray-600">{user.email}</p>
        </div>
      </div>

      {onDelete && (
        <div className="mt-4">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onDelete(user.id)}
            disabled={isDeleting}
          >
            {isDeleting ? 'Deleting...' : 'Delete'}
          </Button>
        </div>
      )}
    </div>
  )
}
```

</patterns>

---

<folder_structure_rules>

## Folder Structure Rules

**⚠️ Required for All Pages:**
- `-components/`: Page-specific components
- `-hooks/`: Page-specific Custom Hooks (regardless of line count)
- `-functions/`: Page-specific Server Functions

**Optional:**
- `-sections/`: Use only for complex pages (200+ lines)

| Page Size | Required | Optional |
|-----------|----------|----------|
| ~100 lines | `-components/`, `-hooks/`, `-functions/` | - |
| 100-200 lines | `-components/`, `-hooks/`, `-functions/` | - |
| 200+ lines | `-components/`, `-hooks/`, `-functions/` | `-sections/` |

</folder_structure_rules>

---

<loader_execution>

## Loader Execution Order

| Step | Execution | Description |
|------|-----------|-------------|
| 1. `beforeLoad` | Sequential (outermost → innermost) | Auth check, context setup |
| 2. `loader` | Parallel (all loaders simultaneously) | Data fetching |

```tsx
// Parent Route
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async () => {
    // 1. Runs first (sequential)
    const auth = await checkAuth()
    return { auth }
  },
  loader: async () => {
    // 2. Runs later (parallel)
    return getDashboardData()
  },
})

// Child Route
export const Route = createFileRoute('/dashboard/users')({
  beforeLoad: async () => {
    // 1. Runs after Parent beforeLoad
    return {}
  },
  loader: async () => {
    // 2. Runs in parallel with Parent loader
    return getUsers()
  },
})
```

</loader_execution>

---

<sources>

- [TanStack Router Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
- [TanStack Router Deferred Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/deferred-data-loading)
- [TanStack Router File-Based Routing](https://tanstack.com/router/latest/docs/framework/react/guide/file-based-routing)

</sources>
