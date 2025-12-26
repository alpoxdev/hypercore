# TanStack Query

> 5.x | React Data Fetching Library

@use-query.md
@use-mutation.md
@invalidation.md
@optimistic-updates.md

---

## Quick Reference

```typescript
// useQuery
const { data, isLoading, error } = useQuery({
  queryKey: ['users'],
  queryFn: () => getUsers(),
})

// useMutation + invalidation
const queryClient = useQueryClient()
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
})
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

### 설정

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5분
      gcTime: 1000 * 60 * 30,     // 30분 (이전 cacheTime)
      retry: 3,
    },
  },
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

### Query Keys 패턴

```typescript
['todos']                       // 단순
['todo', { id: 5 }]             // 파라미터
['todos', 'list', { filters }]  // 계층적
['todos', 'detail', todoId]
```
