# Custom Hook Patterns

> Centralize all logic, state, and lifecycle for pages/sections

---

## Required Rule: Custom Hook Separation

**Every page MUST separate Custom Hooks into the `-hooks/` folder.**

- MUST separate regardless of page size (line count)
- Even a 10-line simple page requires Hook separation
- Page components handle ONLY UI rendering

```
routes/users/
├── index.tsx              // UI only
├── -hooks/
│   └── use-users.ts       // All logic
├── -components/
└── -functions/
```

---

## Hook Internal Order (Required)

| Order | Hook Type | Example |
|-------|-----------|---------|
| 1 | State | `useState`, zustand store |
| 2 | Global Hooks | `useParams`, `useNavigate`, `useQueryClient` |
| 3 | Server Functions | `useServerFn` wrappers |
| 4 | React Query | `useQuery` -> `useMutation` |
| 5 | Event Handlers | `handleCreate`, `handleDelete` (useCallback) |
| 6 | useMemo | Computed values |
| 7 | useEffect | Side effects |

---

## Page Hook Pattern

```typescript
// routes/users/-hooks/use-users.ts
import { useState, useMemo, useEffect, useCallback } from 'react'
import { useNavigate } from '@tanstack/react-router'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/services/user'
import type { User } from '@/types'

interface UseUsersReturn {
  users: User[] | undefined
  filteredUsers: User[]
  isLoading: boolean
  search: string
  setSearch: (value: string) => void
  handleCreate: (data: { email: string; name: string }) => void
  handleDelete: (id: string) => void
}

export const useUsers = (): UseUsersReturn => {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. State
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const [search, setSearch] = useState('')

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. Global Hooks
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. Server Functions (useServerFn wrappers, if needed)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. React Query
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  })

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  })

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. Event Handlers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const handleCreate = useCallback(
    (data: { email: string; name: string }) => {
      createMutation.mutate({ data })
    },
    [createMutation]
  )

  const handleDelete = useCallback(
    (id: string) => {
      deleteMutation.mutate({ data: id })
    },
    [deleteMutation]
  )

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. useMemo
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const filteredUsers = useMemo(() => {
    if (!users) return []
    if (!search) return users
    return users.filter((user) =>
      user.name.toLowerCase().includes(search.toLowerCase())
    )
  }, [users, search])

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. useEffect
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  useEffect(() => {
    // Side effects here
  }, [])

  return {
    users,
    filteredUsers,
    isLoading,
    search,
    setSearch,
    handleCreate,
    handleDelete,
  }
}
```

---

## Wrong Order (Forbidden)

```typescript
export const useBadHook = () => {
  const queryClient = useQueryClient()  // Global Hook first - WRONG
  useEffect(() => { /* ... */ }, [])    // useEffect in the middle - WRONG
  const [state, setState] = useState()  // State after - WRONG
  const { data } = useQuery({})         // Query after Effect - WRONG
}
```

---

## TanStack Router Hooks

| Hook | Purpose | Example |
|------|---------|---------|
| `useParams` | URL parameters | `const { id } = useParams({ from: '/users/$id' })` |
| `useNavigate` | Navigation | `navigate({ to: '/users' })` |
| `useSearch` | Search params | `const { page } = useSearch({ from: '/users' })` |
| `useLoaderData` | Loader data | `const user = Route.useLoaderData()` |
| `useRouteContext` | Route context | `const { auth } = useRouteContext({ from: '__root__' })` |
| `useServerFn` | Server function wrapper | `const fn = useServerFn(serverFn)` |

> `useServerFn` is imported from `@tanstack/react-start`, not `@tanstack/react-router`.

---

## useServerFn + React Query Pattern

> Recommended pattern for calling server functions in components

```typescript
import { useServerFn } from '@tanstack/react-start'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers } from './-functions/get-users'
import { createUser } from './-functions/create-user'

export const useUsers = (): UseUsersReturn => {
  const queryClient = useQueryClient()

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Server Function Wrappers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const getServerUsers = useServerFn(getUsers)
  const createServerUser = useServerFn(createUser)

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // React Query
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: () => getServerUsers(),
  })

  const createMutation = useMutation({
    mutationFn: (data: { email: string; name: string }) =>
      createServerUser({ data }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  })

  return { users, isLoading, createMutation }
}
```

| Pattern | When | Import From |
|---------|------|-------------|
| Direct call | `loader`, `beforeLoad` (server-side) | Direct import |
| `useServerFn` | Component (client-side) | `@tanstack/react-start` |

---

## Requirements

| Principle | Description |
|-----------|-------------|
| **Order compliance** | State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect |
| **Type definition** | Explicit return type (interface) |
| **Single responsibility** | One Hook handles one concern |
| **useCallback** | Memoize event handlers with useCallback |
| **Clear naming** | `use-users.ts`, `use-user-filter.ts` |
