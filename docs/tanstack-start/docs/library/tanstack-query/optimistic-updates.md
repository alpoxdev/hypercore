# TanStack Query - Optimistic Updates

> **상위 문서**: [TanStack Query](./index.md)

낙관적 업데이트는 서버 응답을 기다리지 않고 UI를 즉시 업데이트하는 패턴입니다.

## 기본 패턴

```tsx
const addTodoMutation = useMutation({
  mutationFn: (newTodo: string) => axios.post('/api/data', { text: newTodo }),
  // mutation 완료 후 쿼리 무효화
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})

const { isPending, submittedAt, variables, mutate, isError } = addTodoMutation
```

## 완전한 Optimistic Update 패턴

```tsx
type Todo = { id: string; text: string }
type TodosResponse = { items: Todo[]; ts: number }

function TodoList() {
  const queryClient = useQueryClient()
  const [text, setText] = React.useState('')

  const addTodoMutation = useMutation({
    mutationFn: async (newTodo: string): Promise<Todo> => {
      const response = await fetch('/api/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: newTodo }),
      })
      return response.json()
    },
    onMutate: async (newTodo) => {
      // 1. 진행 중인 refetch 취소 (optimistic update 덮어쓰기 방지)
      await queryClient.cancelQueries({ queryKey: ['todos'] })

      // 2. 롤백을 위한 이전 값 스냅샷
      const previousTodos = queryClient.getQueryData<TodosResponse>(['todos'])

      // 3. 캐시 optimistic 업데이트
      if (previousTodos) {
        queryClient.setQueryData<TodosResponse>(['todos'], {
          ...previousTodos,
          items: [
            ...previousTodos.items,
            { id: Math.random().toString(), text: newTodo },
          ],
        })
      }

      // 4. context로 이전 값 반환
      return { previousTodos }
    },
    onError: (err, variables, context) => {
      // 5. 에러 시 롤백
      if (context?.previousTodos) {
        queryClient.setQueryData(['todos'], context.previousTodos)
      }
    },
    onSettled: () => {
      // 6. 서버와 캐시 동기화를 위해 refetch
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  })

  return (
    <div>
      <form onSubmit={(e) => {
        e.preventDefault()
        addTodoMutation.mutate(text)
        setText('')
      }}>
        <input value={text} onChange={(e) => setText(e.target.value)} />
        <button type="submit" disabled={addTodoMutation.isPending}>
          {addTodoMutation.isPending ? 'Adding...' : 'Add Todo'}
        </button>
      </form>
      {addTodoMutation.isError && <div>Error: {addTodoMutation.error.message}</div>}
    </div>
  )
}
```

## 단일 항목 Optimistic Update

```tsx
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // 진행 중인 refetch 취소
    await queryClient.cancelQueries({ queryKey: ['todos', newTodo.id] })

    // 이전 값 스냅샷
    const previousTodo = queryClient.getQueryData(['todos', newTodo.id])

    // Optimistic 업데이트
    queryClient.setQueryData(['todos', newTodo.id], newTodo)

    return { previousTodo, newTodo }
  },
  onError: (err, newTodo, context) => {
    // 에러 시 롤백
    queryClient.setQueryData(
      ['todos', context.newTodo.id],
      context.previousTodo,
    )
  },
  onSettled: (newTodo) => {
    queryClient.invalidateQueries({ queryKey: ['todos', newTodo.id] })
  },
})
```

## 삭제 Optimistic Update

```tsx
const deleteMutation = useMutation({
  mutationFn: (todoId: string) => deleteTodo(todoId),
  onMutate: async (todoId) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

    // 삭제된 항목 제외
    queryClient.setQueryData<Todo[]>(['todos'], (old) =>
      old?.filter((todo) => todo.id !== todoId)
    )

    return { previousTodos }
  },
  onError: (err, todoId, context) => {
    queryClient.setQueryData(['todos'], context?.previousTodos)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

## 토글 Optimistic Update

```tsx
const toggleMutation = useMutation({
  mutationFn: (todoId: string) => toggleTodo(todoId),
  onMutate: async (todoId) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

    // 토글 상태 변경
    queryClient.setQueryData<Todo[]>(['todos'], (old) =>
      old?.map((todo) =>
        todo.id === todoId
          ? { ...todo, completed: !todo.completed }
          : todo
      )
    )

    return { previousTodos }
  },
  onError: (err, todoId, context) => {
    queryClient.setQueryData(['todos'], context?.previousTodos)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

## Persist (영속성)

### Optimistic Update 즉시 저장

```tsx
const persister = experimental_createQueryPersister({
  storage: AsyncStorage,
  maxAge: 1000 * 60 * 60 * 12, // 12시간
})

const queryClient = useQueryClient()

useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Optimistic 업데이트
    queryClient.setQueryData(['todos'], (old) => [...old, newTodo])
    // 즉시 스토리지에 저장
    persister.persistQueryByKey(['todos'], queryClient)
  },
})
```
