# TanStack Query - Optimistic Updates

<patterns>

```tsx
// 추가
useMutation({
  mutationFn: addTodo,
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previousTodos = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old) => [...old, newTodo])
    return { previousTodos }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})

// 삭제
useMutation({
  mutationFn: deleteTodo,
  onMutate: async (todoId) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previousTodos = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old) =>
      old.filter((todo) => todo.id !== todoId)
    )
    return { previousTodos }
  },
  onError: (err, todoId, context) => {
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})

// 토글
useMutation({
  mutationFn: toggleTodo,
  onMutate: async (todoId) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previousTodos = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old) =>
      old.map((todo) =>
        todo.id === todoId ? { ...todo, completed: !todo.completed } : todo
      )
    )
    return { previousTodos }
  },
  onError: (err, todoId, context) => {
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})

// 단일 항목
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos', newTodo.id] })
    const previousTodo = queryClient.getQueryData(['todos', newTodo.id])
    queryClient.setQueryData(['todos', newTodo.id], newTodo)
    return { previousTodo, newTodo }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos', context.newTodo.id], context.previousTodo)
  },
  onSettled: (newTodo) => {
    queryClient.invalidateQueries({ queryKey: ['todos', newTodo.id] })
  },
})
```

</patterns>
