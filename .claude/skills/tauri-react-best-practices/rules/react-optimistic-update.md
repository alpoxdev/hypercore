# useOptimistic으로 IPC 대기 시간 마스킹

## 왜 중요한가

Tauri Command 호출은 Rust ↔ JS 직렬화 오버헤드가 있어 최소 수십 ms 지연이 발생합니다. React 19의 `useOptimistic`을 사용하면 서버 응답 대기 없이 UI를 즉시 업데이트하여 사용자 경험을 개선할 수 있습니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState } from 'react'

function TodoList({ initialTodos }: { initialTodos: Todo[] }) {
  const [todos, setTodos] = useState(initialTodos)
  const [loading, setLoading] = useState(false)

  const addTodo = async (title: string) => {
    setLoading(true)
    // ❌ invoke 응답까지 사용자는 대기해야 함
    const newTodo = await invoke<Todo>('create_todo', { title })
    setTodos(prev => [...prev, newTodo])
    setLoading(false)
  }

  return (
    <div>
      {loading && <Spinner />}
      {todos.map(todo => <TodoItem key={todo.id} todo={todo} />)}
      <button onClick={() => addTodo('New Task')}>Add</button>
    </div>
  )
}
```

**문제점:**
- 사용자는 Rust 응답까지 대기 (느린 UX)
- 네트워크/IPC 지연이 체감됨
- 로딩 스피너로 인한 UI 깜빡임

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useOptimistic, startTransition, useState } from 'react'

type Todo = {
  id: string
  title: string
  completed: boolean
  pending?: boolean
}

function TodoList({ initialTodos }: { initialTodos: Todo[] }) {
  const [todos, setTodos] = useState(initialTodos)
  const [optimisticTodos, addOptimistic] = useOptimistic(
    todos,
    (current, newTodo: Todo) => [...current, { ...newTodo, pending: true }]
  )

  const addTodo = async (title: string) => {
    const tempTodo: Todo = {
      id: crypto.randomUUID(),
      title,
      completed: false
    }

    startTransition(async () => {
      addOptimistic(tempTodo) // ✅ 즉시 UI에 반영

      try {
        const savedTodo = await invoke<Todo>('create_todo', { title })
        setTodos(prev => [...prev, savedTodo])
      } catch (error) {
        // 실패 시 자동 롤백됨
        console.error('Failed to create todo:', error)
      }
    })
  }

  return (
    <div>
      {optimisticTodos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          style={{ opacity: todo.pending ? 0.5 : 1 }}
        />
      ))}
      <button onClick={() => addTodo('New Task')}>Add</button>
    </div>
  )
}
```

**좋아요/투표 UI 예시:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useOptimistic, startTransition } from 'react'

function LikeButton({ postId, liked, count }: {
  postId: string
  liked: boolean
  count: number
}) {
  const [optimistic, setOptimistic] = useOptimistic(
    { liked, count },
    (curr) => ({
      liked: !curr.liked,
      count: curr.liked ? curr.count - 1 : curr.count + 1
    })
  )

  const toggleLike = () => {
    startTransition(async () => {
      setOptimistic(null) // ✅ 즉시 UI 토글

      try {
        await invoke('toggle_like', { postId })
      } catch (error) {
        // 실패 시 자동 롤백
        console.error('Failed to toggle like:', error)
      }
    })
  }

  return (
    <button onClick={toggleLike}>
      {optimistic.liked ? '❤️' : '🤍'} {optimistic.count}
    </button>
  )
}
```

**삭제 액션 예시:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useOptimistic, startTransition, useState } from 'react'

function FileList({ initialFiles }: { initialFiles: File[] }) {
  const [files, setFiles] = useState(initialFiles)
  const [optimisticFiles, removeOptimistic] = useOptimistic(
    files,
    (current, fileIdToRemove: string) =>
      current.filter(f => f.id !== fileIdToRemove)
  )

  const deleteFile = (fileId: string) => {
    startTransition(async () => {
      removeOptimistic(fileId) // ✅ 즉시 제거

      try {
        await invoke('delete_file', { fileId })
        setFiles(prev => prev.filter(f => f.id !== fileId))
      } catch (error) {
        // 실패 시 자동 롤백
        alert('Failed to delete file')
      }
    })
  }

  return (
    <div>
      {optimisticFiles.map(file => (
        <div key={file.id}>
          {file.name}
          <button onClick={() => deleteFile(file.id)}>Delete</button>
        </div>
      ))}
    </div>
  )
}
```

## 추가 컨텍스트

**사용 시점:**
- 좋아요/투표 버튼
- 댓글 추가/삭제
- 장바구니 아이템 추가/제거
- 토글 스위치 (완료/미완료)
- 파일 업로드/삭제

**주의사항:**
- `startTransition` 내에서 사용해야 자동 롤백 작동
- 복잡한 데이터 구조는 `immer` 같은 라이브러리 활용
- 에러 발생 시 사용자에게 피드백 제공 (toast, alert)

**React 19 미만 환경:**
```tsx
// React 18 이하에서는 수동 롤백 구현
const [tempState, setTempState] = useState(null)

const addTodo = async (title: string) => {
  const tempTodo = { id: 'temp', title }
  setTempState(tempTodo)

  try {
    const saved = await invoke('create_todo', { title })
    setTodos(prev => [...prev, saved])
  } catch {
    // 수동 롤백
    setTempState(null)
  }
}
```

**참고:** [React 19 useOptimistic](https://react.dev/reference/react/useOptimistic)

영향도: MEDIUM-HIGH - 사용자 체감 응답 속도, UX 품질
