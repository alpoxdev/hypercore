# TanStack Query

> 5.x | React Data Fetching

@use-query.md
@use-mutation.md
@invalidation.md
@optimistic-updates.md

---

<quick_reference>

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

// Setup
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5 minutes
      gcTime: 1000 * 60 * 30,     // 30 minutes
      retry: 3,
    },
  },
})

const App = () => (
  <QueryClientProvider client={queryClient}>
    <YourApp />
  </QueryClientProvider>
)

// Query Keys
['todos']                       // simple
['todo', { id: 5 }]             // with parameter
['todos', 'list', { filters }]  // hierarchical
```

</quick_reference>
