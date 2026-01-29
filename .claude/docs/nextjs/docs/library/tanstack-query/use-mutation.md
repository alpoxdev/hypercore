# TanStack Query - useMutation

<patterns>

```tsx
// Basic
const queryClient = useQueryClient()
const mutation = useMutation({
  mutationFn: postTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})
mutation.mutate({ title: 'New Todo' })

// Callbacks
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // before mutation starts (for optimistic updates)
    return { previousData }  // passed to context
  },
  onSuccess: (data, variables, context) => {},
  onError: (error, variables, context) => {},
  onSettled: (data, error, variables, context) => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})

// mutate vs mutateAsync
mutation.mutate(data, {
  onSuccess: (result) => console.log(result),
  onError: (error) => console.log(error),
})

try {
  const result = await mutation.mutateAsync(data)
} catch (error) { ... }

// Cache update
useMutation({
  mutationFn: patchTodo,
  onSuccess: (data) => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
    queryClient.setQueryData(['todo', { id: data.id }], data)
  },
})
```

</patterns>

<returns>

| Property | Description |
|----------|-------------|
| data | Mutation result |
| error | Error object |
| isPending | Execution in progress |
| isSuccess/isError | Status flags |
| mutate | Execute (async) |
| mutateAsync | Execute (Promise) |
| reset | Reset state |
| variables | Passed variables |

</returns>
