# TanStack Query - useQuery

<patterns>

```tsx
// Basic
const { data, isLoading, error } = useQuery({
  queryKey: ['todos'],
  queryFn: getTodos,
})
if (isLoading) return <div>Loading...</div>
if (error) return <div>Error: {error.message}</div>

// Options
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  staleTime: 1000 * 60 * 5,      // Time to stay fresh
  gcTime: 1000 * 60 * 30,        // Garbage collection time
  refetchOnWindowFocus: true,    // Refetch on focus
  refetchInterval: 1000 * 60,    // Auto refetch interval
  retry: 3,                      // Retry count
  enabled: !!userId,             // Conditional execution
  initialData: [],               // Initial data
  select: (data) => data.filter(t => t.done),  // Data transformation
})

// With parameters
useQuery({
  queryKey: ['todo', todoId],
  queryFn: () => fetchTodoById(todoId),
  enabled: !!todoId,
})

// Dependent queries
const { data: user } = useQuery({ queryKey: ['user', userId], queryFn: ... })
const { data: posts } = useQuery({
  queryKey: ['posts', user?.id],
  queryFn: () => fetchPostsByUserId(user!.id),
  enabled: !!user?.id,
})

// Parallel
const usersQuery = useQuery({ queryKey: ['users'], queryFn: fetchUsers })
const postsQuery = useQuery({ queryKey: ['posts'], queryFn: fetchPosts })

// Dynamic parallel
const userQueries = useQueries({
  queries: userIds.map((id) => ({
    queryKey: ['user', id],
    queryFn: () => fetchUserById(id),
  })),
})
```

</patterns>

<returns>

| Property | Description |
|------|------|
| data | Query result |
| error | Error object |
| isLoading | Initial loading |
| isFetching | Background fetching |
| isError/isSuccess | Status |
| refetch | Manual refetch |
| status | 'pending' \| 'error' \| 'success' |

</returns>
