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
  staleTime: 1000 * 60 * 5,      // time to keep data fresh
  gcTime: 1000 * 60 * 30,        // garbage collection time
  refetchOnWindowFocus: true,    // refetch on window focus
  refetchInterval: 1000 * 60,    // auto-refetch interval
  retry: 3,                      // retry attempts
  enabled: !!userId,             // conditional execution
  initialData: [],               // initial data
  select: (data) => data.filter(t => t.done),  // data transformation
})

// With parameter
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
|----------|-------------|
| data | Query result |
| error | Error object |
| isLoading | First loading state |
| isFetching | Background fetching state |
| isError/isSuccess | Status flags |
| refetch | Manual refetch function |
| status | 'pending' \| 'error' \| 'success' |

</returns>
