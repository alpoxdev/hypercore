# Custom Hook 패턴

> 페이지/섹션의 모든 로직, 상태, 라이프사이클 중앙화

<instructions>
@../library/tanstack-router/hooks.md
@../library/tanstack-query/use-query.md
@../library/tanstack-query/use-mutation.md
</instructions>

---

<mandatory_separation>

## ⚠️ 필수 규칙: Custom Hook 분리

**모든 페이지는 Custom Hook을 `-hooks/` 폴더에 분리해야 합니다.**

- 페이지 크기(줄 수)와 **무관**하게 반드시 분리
- 10줄짜리 간단한 페이지도 Hook 분리 필수
- 페이지 컴포넌트는 오직 UI 렌더링만 담당

```typescript
// ✅ 올바른 구조
routes/users/
├── index.tsx              // UI만
├── -hooks/
│   └── use-users.ts       // 모든 로직
├── -components/
└── -functions/

// ❌ 잘못된 구조
routes/users/
└── index.tsx              // UI + 로직 혼재
```

</mandatory_separation>

---

<hook_order>

## Hook 내부 순서 (필수)

| 순서 | Hook 타입 | 예시 |
|------|-----------|------|
| 1 | State | `useState`, zustand store |
| 2 | Global Hooks | `useParams`, `useNavigate`, `useQueryClient` |
| 3 | React Query | `useQuery` → `useMutation` |
| 4 | Event Handlers | `handleCreate`, `handleDelete` |
| 5 | useMemo | 계산된 값 |
| 6 | useEffect | 부수 효과 |

</hook_order>

---

<patterns>

## Page Hook 패턴

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

## Filter Hook 패턴

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

## Form Hook 패턴

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

## ❌ 잘못된 순서

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

## ✅ 올바른 순서

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

| Hook | 용도 | 예시 |
|------|------|------|
| `useParams` | URL 파라미터 | `const { id } = useParams({ from: '/users/$id' })` |
| `useNavigate` | 프로그래밍 방식 네비게이션 | `navigate({ to: '/users' })` |
| `useSearch` | Search params | `const { page } = useSearch({ from: '/users' })` |
| `useLoaderData` | Loader 데이터 | `const user = Route.useLoaderData()` |
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

| Hook | 용도 | 특징 |
|------|------|------|
| `useQuery` | 데이터 조회 (GET) | 자동 캐싱, 재검증 |
| `useMutation` | 데이터 변경 (POST/PUT/DELETE) | 성공 시 캐시 무효화 |
| `useQueryClient` | 캐시 제어 | `invalidateQueries`, `setQueryData` |

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

| 원칙 | 설명 |
|------|------|
| **순서 준수** | State → Global → Query → Handlers → Memo → Effect |
| **타입 정의** | Return 타입 명시 (interface) |
| **단일 책임** | 하나의 Hook은 하나의 관심사 |
| **useCallback** | Event handler는 useCallback으로 메모이제이션 |
| **명확한 네이밍** | `use-users.ts`, `use-user-filter.ts` |

</best_practices>

---

<sources>

- [TanStack Router Hooks](https://tanstack.com/router/latest/docs/framework/react/guide/router-hooks)
- [TanStack Query useQuery](https://tanstack.com/query/latest/docs/framework/react/guides/queries)
- [TanStack Query useMutation](https://tanstack.com/query/latest/docs/framework/react/guides/mutations)

</sources>
