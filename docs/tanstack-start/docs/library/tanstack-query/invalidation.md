# TanStack Query - Query Invalidation

<patterns>

```typescript
const queryClient = useQueryClient()

// Single
queryClient.invalidateQueries({ queryKey: ['todos'] })

// Multiple
await Promise.all([
  queryClient.invalidateQueries({ queryKey: ['todos'] }),
  queryClient.invalidateQueries({ queryKey: ['reminders'] }),
])

// All
queryClient.invalidateQueries()

// Options
queryClient.invalidateQueries({
  queryKey: ['posts'],
  exact: true,  // Exact key match only
  refetchType: 'active',  // 'active' | 'inactive' | 'all' | 'none'
})

// Query Key matching
queryClient.invalidateQueries({ queryKey: ['todos'] })  // Prefix match
queryClient.invalidateQueries({ queryKey: ['todos', 'list'], exact: true })  // Exact match

// With Mutation
useMutation({
  mutationFn: addTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),  // Regardless of success/failure
})

// Direct update vs invalidation
queryClient.setQueryData(['todos'], (old) => [...old, newTodo])  // Faster
queryClient.invalidateQueries({ queryKey: ['todos'] })  // Guarantees server data
```

</patterns>

<options>

| refetchType | Description |
|-------------|------|
| active | Refetch only active queries (default) |
| inactive | Only inactive queries |
| all | All matching queries |
| none | Invalidate only, no refetch |

</options>
