---
title: Use useOptimistic for Instant UI Feedback
impact: MEDIUM-HIGH
impactDescription: eliminates perceived latency on mutations
tags: client, react-19, useOptimistic, mutations, optimistic-ui
---

## useOptimistic으로 즉각적인 UI 피드백

React 19의 `useOptimistic`으로 서버 응답 대기 없이 UI를 즉시 업데이트하고, 실패 시 자동 롤백합니다.

**❌ 잘못된 예시 (서버 응답까지 대기):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  const mutation = useMutation({
    mutationFn: createTodo,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] })
  })

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      mutation.mutate({ title: inputValue })
      // 사용자는 서버 응답까지 기다려야 아이템을 볼 수 있음
    }}>
      {mutation.isPending && <Spinner />}
      {todos.map(todo => <TodoItem key={todo.id} todo={todo} />)}
    </form>
  )
}
```

**✅ 올바른 예시 (useOptimistic으로 즉시 반영):**

```tsx
import { useOptimistic, startTransition } from 'react'

function TodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimistic] = useOptimistic(
    todos,
    (current, newTodo: Todo) => [...current, { ...newTodo, pending: true }]
  )

  const handleAdd = async (formData: FormData) => {
    const newTodo = {
      id: crypto.randomUUID(),
      title: formData.get('title') as string,
      completed: false
    }

    startTransition(async () => {
      addOptimistic(newTodo) // 즉시 UI에 반영
      await createTodo({ data: newTodo }) // 서버에 저장
      // 실패 시 자동으로 이전 상태로 롤백
    })
  }

  return (
    <form action={handleAdd}>
      <input name="title" />
      <button type="submit">추가</button>
      {optimisticTodos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          style={{ opacity: todo.pending ? 0.5 : 1 }}
        />
      ))}
    </form>
  )
}
```

**TanStack Query와 조합:**

```tsx
function LikeButton({ postId, liked, count }: Props) {
  const [optimistic, setOptimistic] = useOptimistic(
    { liked, count },
    (curr) => ({
      liked: !curr.liked,
      count: curr.liked ? curr.count - 1 : curr.count + 1
    })
  )

  const mutation = useMutation({
    mutationFn: () => toggleLike({ data: { postId } }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['post', postId] })
  })

  return (
    <button onClick={() => {
      startTransition(async () => {
        setOptimistic(null)
        await mutation.mutateAsync()
      })
    }}>
      {optimistic.liked ? '❤️' : '🤍'} {optimistic.count}
    </button>
  )
}
```

**사용 시점:** 좋아요/투표, 댓글 추가, 장바구니 아이템 추가/삭제, 토글 스위치 등 사용자가 즉각적인 피드백을 기대하는 모든 액션.

**주의:** `startTransition` 내에서 사용해야 자동 롤백이 작동합니다.

참고: [React 19 useOptimistic](https://react.dev/reference/react/useOptimistic)
