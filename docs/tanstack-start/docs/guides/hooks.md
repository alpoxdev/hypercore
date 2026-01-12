# Custom Hook Patterns

> Centralize all logic, state, and lifecycle for pages/sections

<instructions>
@../library/tanstack-router/hooks.md
@../library/tanstack-query/use-query.md
@../library/tanstack-query/use-mutation.md
</instructions>

---

<mandatory_separation>

## ⚠️ Required Rule: Custom Hook Separation

**All pages must separate Custom Hooks into `-hooks/` folder.**

- Must be separated **regardless of page size** (line count)
- Even simple 10-line pages require Hook separation
- Page components should only handle UI rendering

```typescript
// ✅ Correct structure
routes/users/
├── index.tsx              // UI only
├── -hooks/
│   └── use-users.ts       // All logic
├── -components/
└── -functions/

// ❌ Wrong structure
routes/users/
└── index.tsx              // UI + logic mixed
```

</mandatory_separation>

---

<hook_order>

## Hook Internal Order (Required)

| Order | Hook Type | Examples |
|-------|-----------|----------|
| 1 | State | `useState`, zustand store |
| 2 | Global Hooks | `useParams`, `useNavigate`, `useQueryClient` |
| 3 | React Query | `useQuery` → `useMutation` |
| 4 | Event Handlers | `handleCreate`, `handleDelete` |
| 5 | useMemo | Computed values |
| 6 | useEffect | Side effects |

</hook_order>

---

<patterns>

## Page Hook Pattern

```typescript
// routes/users/-hooks/use-users.ts
import { useState, useMemo, useEffect, useCallback } from 'react'
import { useParams, useNavigate } from '@tanstack/react-router'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useAuthStore } from '@/stores/auth'
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
  const { user: currentUser } = useAuthStore()

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. Global Hooks
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const params = useParams({ from: '/users/$id' })
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. React Query
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
  // 4. Event Handlers
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
  // 5. useMemo
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const filteredUsers = useMemo(() => {
    if (!users) return []
    if (!search) return users
    return users.filter((user) =>
      user.name.toLowerCase().includes(search.toLowerCase())
    )
  }, [users, search])

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. useEffect
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  useEffect(() => {
    if (!currentUser) {
      navigate({ to: '/login' })
    }
  }, [currentUser, navigate])

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

## Filter Hook Pattern

```typescript
// routes/users/-hooks/use-user-filter.ts
import { useState, useCallback } from 'react'

interface UseUserFilterReturn {
  search: string
  setSearch: (value: string) => void
  role: string
  setRole: (value: string) => void
  clearFilters: () => void
}

export const useUserFilter = (): UseUserFilterReturn => {
  const [search, setSearch] = useState('')
  const [role, setRole] = useState('')

  const clearFilters = useCallback(() => {
    setSearch('')
    setRole('')
  }, [])

  return { search, setSearch, role, setRole, clearFilters }
}
```

## Form Hook Pattern

```typescript
// routes/users/-hooks/use-user-form.ts
import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createUser } from '@/services/user'
import type { CreateUserInput } from '@/services/user'

interface UseUserFormReturn {
  email: string
  setEmail: (value: string) => void
  name: string
  setName: (value: string) => void
  handleSubmit: (e: React.FormEvent) => void
  isSubmitting: boolean
  error: Error | null
}

export const useUserForm = (): UseUserFormReturn => {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. State
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. Global Hooks
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const queryClient = useQueryClient()

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. React Query
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const { mutate, isPending, error } = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      setEmail('')
      setName('')
    },
  })

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. Event Handlers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    mutate({ data: { email, name } })
  }

  return {
    email,
    setEmail,
    name,
    setName,
    handleSubmit,
    isSubmitting: isPending,
    error,
  }
}
```

</patterns>

---

<anti_patterns>

## ❌ Wrong Order

```typescript
// ❌ Mixed order (wrong example)
export const useBadHook = () => {
  const queryClient = useQueryClient()  // ❌ Global Hook first

  useEffect(() => { /* ... */ }, [])    // ❌ useEffect in the middle

  const [state, setState] = useState()  // ❌ State later

  const { data } = useQuery({ /* ... */ })  // ❌ Query after Effect

  const computed = useMemo(() => {}, [])  // ❌ useMemo wrong position
}
```

## ✅ Correct Order

```typescript
export const useGoodHook = () => {
  // 1. State
  const [state, setState] = useState()

  // 2. Global Hooks
  const queryClient = useQueryClient()

  // 3. React Query
  const { data } = useQuery({ /* ... */ })

  // 4. Event Handlers
  const handleClick = useCallback(() => {}, [])

  // 5. useMemo
  const computed = useMemo(() => {}, [])

  // 6. useEffect
  useEffect(() => { /* ... */ }, [])

  return { state, data, handleClick, computed }
}
```

</anti_patterns>

---

<router_hooks>

## TanStack Router Hooks

| Hook | Purpose | Example |
|------|---------|---------|
| `useParams` | URL parameters | `const { id } = useParams({ from: '/users/$id' })` |
| `useNavigate` | Programmatic navigation | `navigate({ to: '/users' })` |
| `useSearch` | Search params | `const { page } = useSearch({ from: '/users' })` |
| `useLoaderData` | Loader data | `const user = Route.useLoaderData()` |
| `useRouteContext` | Route context | `const { auth } = useRouteContext({ from: '__root__' })` |

```typescript
// routes/users/$id.tsx Hook
import { useParams, useNavigate, useLoaderData } from '@tanstack/react-router'

export const useUserDetail = () => {
  const { id } = useParams({ from: '/users/$id' })
  const navigate = useNavigate()
  const user = Route.useLoaderData()

  const handleBack = () => navigate({ to: '/users' })
  const handleEdit = () => navigate({ to: '/users/$id/edit', params: { id } })

  return {
    user,
    handleBack,
    handleEdit,
  }
}
```

</router_hooks>

---

<query_hooks>

## TanStack Query Hooks

| Hook | Purpose | Features |
|------|---------|----------|
| `useQuery` | Data fetching (GET) | Auto caching, revalidation |
| `useMutation` | Data modification (POST/PUT/DELETE) | Cache invalidation on success |
| `useQueryClient` | Cache control | `invalidateQueries`, `setQueryData` |

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser } from '@/services/user'

export const useUsers = () => {
  const queryClient = useQueryClient()

  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
    staleTime: 60 * 1000,  // 1분
  })

  const { mutate, isPending } = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  return { data, isLoading, error, mutate, isPending }
}
```

</query_hooks>

---

<best_practices>

| Principle | Description |
|-----------|-------------|
| **Order Compliance** | State → Global → Query → Handlers → Memo → Effect |
| **Type Definition** | Explicit return type (interface) |
| **Single Responsibility** | One Hook, one concern |
| **useCallback** | Memoize event handlers with useCallback |
| **Clear Naming** | `use-users.ts`, `use-user-filter.ts` |

</best_practices>

---

<sources>

- [TanStack Router Hooks](https://tanstack.com/router/latest/docs/framework/react/guide/router-hooks)
- [TanStack Query useQuery](https://tanstack.com/query/latest/docs/framework/react/guides/queries)
- [TanStack Query useMutation](https://tanstack.com/query/latest/docs/framework/react/guides/mutations)

</sources>
