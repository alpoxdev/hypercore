# TanStack Query

> **Version**: 5.x | React Data Fetching Library

---

## 🚀 Quick Reference (복사용)

```typescript
// useQuery - 데이터 조회
const { data, isLoading, error } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
})

// useMutation - 데이터 변경
const queryClient = useQueryClient()
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
  },
})

// mutation 실행
mutation.mutate({ email, name })

// Optimistic Update
const mutation = useMutation({
  mutationFn: updateUser,
  onMutate: async (newUser) => {
    await queryClient.cancelQueries({ queryKey: ['users'] })
    const previous = queryClient.getQueryData(['users'])
    queryClient.setQueryData(['users'], (old) => [...old, newUser])
    return { previous }
  },
  onError: (err, newUser, context) => {
    queryClient.setQueryData(['users'], context.previous)
  },
})
```

### QueryClient 설정

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

---

## 문서 구조

- [설치 및 설정](./setup.md) - QueryClient 설정
- [useQuery](./use-query.md) - 데이터 조회 훅
- [useMutation](./use-mutation.md) - 데이터 변경 훅
- [무효화](./invalidation.md) - Query 무효화 및 리페치
- [Optimistic Updates](./optimistic-updates.md) - 낙관적 업데이트

## 빠른 시작

```bash
yarn add @tanstack/react-query
```

### QueryClient 설정

```tsx
import {
  QueryClient,
  QueryClientProvider,
} from '@tanstack/react-query'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

## 핵심 개념

### useQuery - 데이터 조회

```tsx
import { useQuery } from '@tanstack/react-query'

function Todos() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['todos'],
    queryFn: getTodos,
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((todo) => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  )
}
```

### useMutation - 데이터 변경

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'

function AddTodo() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: postTodo,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  })

  return (
    <button onClick={() => mutation.mutate({ title: 'New Todo' })}>
      Add Todo
    </button>
  )
}
```

## 참고 자료

- [TanStack Query 공식 문서](https://tanstack.com/query/latest)
- [TanStack Query GitHub](https://github.com/tanstack/query)
