# TanStack Query - Query 무효화

> **상위 문서**: [TanStack Query](./index.md)

## 기본 무효화

```typescript
const queryClient = useQueryClient()

// 단일 쿼리 무효화
await queryClient.invalidateQueries({ queryKey: ['todos'] })

// 다중 쿼리 무효화
await Promise.all([
  queryClient.invalidateQueries({ queryKey: ['todos'] }),
  queryClient.invalidateQueries({ queryKey: ['reminders'] }),
])

// 모든 쿼리 무효화
queryClient.invalidateQueries()
```

## 무효화 옵션

```typescript
await queryClient.invalidateQueries(
  {
    queryKey: ['posts'],
    exact: true, // 정확한 키 매칭만
    refetchType: 'active', // 'active' | 'inactive' | 'all' | 'none'
  },
  {
    throwOnError: false,
    cancelRefetch: true,
  }
)
```

## refetchType 옵션

- `active`: 현재 렌더링 중인 쿼리만 재조회 (기본값)
- `inactive`: 비활성 쿼리만 재조회
- `all`: 모든 매칭 쿼리 재조회
- `none`: 무효화만 하고 재조회 안 함

## Query Key로 무효화

```typescript
// 'todos'로 시작하는 모든 쿼리 무효화
queryClient.invalidateQueries({ queryKey: ['todos'] })

// 정확히 ['todos', 'list']인 쿼리만 무효화
queryClient.invalidateQueries({
  queryKey: ['todos', 'list'],
  exact: true,
})

// ['todos', { type: 'done' }] 무효화
queryClient.invalidateQueries({
  queryKey: ['todos', { type: 'done' }],
})
```

## Mutation과 함께 사용

### onSuccess에서 무효화

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'

function TodosComponent() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: addTodo,
    onSuccess: async () => {
      // 단일 쿼리 무효화
      await queryClient.invalidateQueries({ queryKey: ['todos'] })

      // 여러 쿼리 무효화
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ['todos'] }),
        queryClient.invalidateQueries({ queryKey: ['reminders'] }),
      ])
    },
  })

  return (
    <button onClick={() => mutation.mutate(newTodo)}>
      Add Todo
    </button>
  )
}
```

### onSettled에서 무효화

```tsx
const mutation = useMutation({
  mutationFn: updateTodo,
  onSettled: () => {
    // 성공/실패 관계없이 무효화
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

## 캐시 직접 업데이트 vs 무효화

```tsx
// 방법 1: 캐시 직접 업데이트 (더 빠름)
queryClient.setQueryData(['todos'], (old) => [...old, newTodo])

// 방법 2: 무효화 후 재조회 (서버 데이터 보장)
queryClient.invalidateQueries({ queryKey: ['todos'] })
```

## 조건부 무효화

```tsx
const mutation = useMutation({
  mutationFn: updateTodo,
  onSuccess: (data, variables) => {
    // 특정 조건에서만 무효화
    if (variables.category === 'important') {
      queryClient.invalidateQueries({ queryKey: ['todos', 'important'] })
    }

    // 항상 개별 항목은 무효화
    queryClient.invalidateQueries({ queryKey: ['todo', variables.id] })
  },
})
```

## prefetch와 조합

```tsx
// 무효화 전에 새 데이터 프리페치
await queryClient.prefetchQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

// 이후 무효화 시 이미 새 데이터가 있음
queryClient.invalidateQueries({ queryKey: ['todos'] })
```
