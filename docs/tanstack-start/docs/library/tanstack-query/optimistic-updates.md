# TanStack Query - Optimistic Updates

서버 응답 전 UI 즉시 업데이트.

## 패턴

```tsx
useMutation({
  mutationFn: addTodo,
  onMutate: async (newTodo) => {
    // 1. 진행 중인 refetch 취소
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // 2. 이전 값 스냅샷
    const previousTodos = queryClient.getQueryData(['todos'])

    // 3. 낙관적 업데이트
    queryClient.setQueryData(['todos'], (old) => [...old, newTodo])

    // 4. context로 이전 값 반환
    return { previousTodos }
  },
  onError: (err, newTodo, context) => {
    // 5. 에러 시 롤백
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => {
    // 6. 서버와 동기화
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

## 삭제

```tsx
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
```

## 토글

```tsx
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
```

## 단일 항목 업데이트

```tsx
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
