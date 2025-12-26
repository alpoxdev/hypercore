# Custom Hook 패턴

페이지/섹션의 모든 로직, 상태, 라이프사이클을 중앙화.

## 필수: Hook 내부 순서

```
1. State (useState, zustand store)
2. Global Hooks (useParams, useNavigate, useQueryClient)
3. React Query (useQuery → useMutation)
4. Event Handlers & Functions
5. useMemo
6. useEffect
```

## Page Hook 예시

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
  error: Error | null
  search: string
  setSearch: (value: string) => void
  handleCreate: (data: { email: string; name: string }) => void
  handleDelete: (id: string) => void
  isCreating: boolean
  isDeleting: boolean
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
  const { data: users, isLoading, error } = useQuery({
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
    error,
    search,
    setSearch,
    handleCreate,
    handleDelete,
    isCreating: createMutation.isPending,
    isDeleting: deleteMutation.isPending,
  }
}
```

## 잘못된 순서 (금지)

```typescript
// ❌ 순서가 뒤섞인 잘못된 예시
export const useBadHook = () => {
  const queryClient = useQueryClient()  // ❌ Global Hook이 먼저

  useEffect(() => { /* ... */ }, [])    // ❌ useEffect가 중간에

  const [state, setState] = useState()  // ❌ State가 나중에

  const { data } = useQuery({ /* ... */ })  // ❌ Query가 Effect 다음에

  const computed = useMemo(() => {}, [])  // ❌ useMemo 위치 잘못됨
}
```

## Filter Hook 예시

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
