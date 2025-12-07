# TanStack Query

> 5.x | React Data Fetching Library

@setup.md
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

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```
