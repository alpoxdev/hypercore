# Custom Hook 패턴

> 페이지/섹션의 모든 로직, 상태, 라이프사이클 중앙화

---

## 필수 규칙: Custom Hook 분리

**모든 페이지는 Custom Hook을 `-hooks/` 폴더에 분리해야 합니다.**

- 페이지 크기(줄 수)와 **무관**하게 반드시 분리
- 10줄짜리 간단한 페이지도 Hook 분리 필수
- 페이지 컴포넌트는 오직 UI 렌더링만 담당

```
routes/users/
├── index.tsx              // UI만
├── -hooks/
│   └── use-users.ts       // 모든 로직
├── -components/
└── -functions/
```

---

## Hook 내부 순서 (필수)

| 순서 | Hook 타입 | 예시 |
|------|-----------|------|
| 1 | State | `useState`, zustand store |
| 2 | Global Hooks | `useParams`, `useNavigate`, `useQueryClient` |
| 3 | Server Functions | `useServerFn` 래퍼 |
| 4 | React Query | `useQuery` -> `useMutation` |
| 5 | Event Handlers | `handleCreate`, `handleDelete` (useCallback) |
| 6 | useMemo | 계산된 값 |
| 7 | useEffect | 부수 효과 |

---

## Page Hook 패턴

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
  // 3. Server Functions (useServerFn 래퍼, 필요 시)
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
    // 필요한 부수 효과
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

## 잘못된 순서 (금지)

```typescript
export const useBadHook = () => {
  const queryClient = useQueryClient()  // Global Hook이 먼저
  useEffect(() => { /* ... */ }, [])    // useEffect가 중간에
  const [state, setState] = useState()  // State가 나중에
  const { data } = useQuery({})         // Query가 Effect 다음에
}
```

---

## TanStack Router Hooks

| Hook | 용도 | 예시 |
|------|------|------|
| `useParams` | URL 파라미터 | `const { id } = useParams({ from: '/users/$id' })` |
| `useNavigate` | 네비게이션 | `navigate({ to: '/users' })` |
| `useSearch` | Search params | `const { page } = useSearch({ from: '/users' })` |
| `useLoaderData` | Loader 데이터 | `const user = Route.useLoaderData()` |
| `useRouteContext` | Route context | `const { auth } = useRouteContext({ from: '__root__' })` |
| `useServerFn` | 서버 함수 래퍼 | `const fn = useServerFn(serverFn)` |

> `useServerFn`은 `@tanstack/react-router`가 아닌 `@tanstack/react-start`에서 import합니다.

---

## useServerFn + React Query 패턴

> 컴포넌트에서 서버 함수 호출을 위한 권장 패턴

```typescript
import { useServerFn } from '@tanstack/react-start'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers } from './-functions/get-users'
import { createUser } from './-functions/create-user'

export const useUsers = (): UseUsersReturn => {
  const queryClient = useQueryClient()

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Server Function 래퍼
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

| 패턴 | 사용 시점 | Import 출처 |
|------|----------|-------------|
| 직접 호출 | `loader`, `beforeLoad` (서버사이드) | 직접 import |
| `useServerFn` | 컴포넌트 (클라이언트) | `@tanstack/react-start` |

---

## 요구사항

| 원칙 | 설명 |
|------|------|
| **순서 준수** | State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect |
| **타입 정의** | Return 타입 명시 (interface) |
| **단일 책임** | 하나의 Hook은 하나의 관심사 |
| **useCallback** | Event handler는 useCallback으로 메모이제이션 |
| **명확한 네이밍** | `use-users.ts`, `use-user-filter.ts` |
