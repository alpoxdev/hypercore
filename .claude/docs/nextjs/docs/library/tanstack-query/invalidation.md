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
  exact: true,  // exact key match only
  refetchType: 'active',  // 'active' | 'inactive' | 'all' | 'none'
})

// Query key matching
queryClient.invalidateQueries({ queryKey: ['todos'] })  // prefix matching
queryClient.invalidateQueries({ queryKey: ['todos', 'list'], exact: true })  // exact matching

// With mutation
useMutation({
  mutationFn: addTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),  // regardless of success/failure
})

// Direct update vs invalidation
queryClient.setQueryData(['todos'], (old) => [...old, newTodo])  // faster
queryClient.invalidateQueries({ queryKey: ['todos'] })  // guarantees server data
```

</patterns>

<options>

| refetchType | Description |
|-------------|-------------|
| active | Refetch only queries currently being rendered (default) |
| inactive | Refetch only inactive queries |
| all | Refetch all matching queries |
| none | Invalidate only, no refetch |

</options>
