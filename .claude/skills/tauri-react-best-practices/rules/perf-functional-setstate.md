# 함수형 setState로 안정적 콜백

## 왜 중요한가

현재 상태 값을 기반으로 상태를 업데이트할 때 상태 변수를 직접 참조하면 stale closure가 발생하고, 콜백이 상태 변경마다 재생성됩니다. 함수형 setState를 사용하면 안정적인 콜백 참조를 유지하고 불필요한 리렌더링을 방지할 수 있습니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState, useCallback } from 'react'

function NotificationPanel() {
  const [notifications, setNotifications] = useState<string[]>([])

  // ❌ 콜백이 notifications에 의존 (매번 재생성)
  const addNotification = useCallback(async (message: string) => {
    setNotifications([...notifications, message])
  }, [notifications])  // ❌ notifications 의존성으로 인한 재생성

  // ❌ 의존성 누락 (stale closure 버그)
  const clearNotifications = useCallback(() => {
    setNotifications([])  // 항상 초기 notifications 참조
  }, [])  // ❌ stale closure 위험

  return (
    <div>
      <button onClick={() => addNotification('New message')}>Add</button>
      <button onClick={clearNotifications}>Clear</button>
      {notifications.map((msg, i) => <div key={i}>{msg}</div>)}
    </div>
  )
}
```

**문제점:**
- `notifications`가 변경될 때마다 콜백 재생성
- 자식 컴포넌트가 불필요하게 리렌더링
- 의존성 누락 시 stale closure 버그

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState, useCallback } from 'react'

function NotificationPanel() {
  const [notifications, setNotifications] = useState<string[]>([])

  // ✅ 안정적인 콜백, 재생성 안 됨
  const addNotification = useCallback(async (message: string) => {
    setNotifications(curr => [...curr, message])
  }, [])  // ✅ 의존성 불필요

  // ✅ 항상 최신 상태 사용
  const clearNotifications = useCallback(() => {
    setNotifications([])
  }, [])  // ✅ 안전하고 안정적

  return (
    <div>
      <button onClick={() => addNotification('New message')}>Add</button>
      <button onClick={clearNotifications}>Clear</button>
      {notifications.map((msg, i) => <div key={i}>{msg}</div>)}
    </div>
  )
}
```

**Tauri IPC와 함께 사용:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { listen, UnlistenFn } from '@tauri-apps/api/event'
import { useEffect, useState, useCallback } from 'react'

function FileWatcher() {
  const [files, setFiles] = useState<string[]>([])

  // ✅ 함수형 setState로 안정적인 이벤트 핸들러
  useEffect(() => {
    let unlisten: UnlistenFn | undefined

    listen<string>('file-added', event => {
      setFiles(curr => [...curr, event.payload])  // ✅ 최신 상태 참조
    }).then(fn => unlisten = fn)

    return () => unlisten?.()
  }, [])  // ✅ 의존성 없음

  // ✅ 안정적인 삭제 핸들러
  const removeFile = useCallback((fileName: string) => {
    setFiles(curr => curr.filter(f => f !== fileName))
  }, [])

  return (
    <div>
      {files.map(file => (
        <div key={file}>
          {file}
          <button onClick={() => removeFile(file)}>Remove</button>
        </div>
      ))}
    </div>
  )
}
```

**invoke 호출과 상태 업데이트:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState, useCallback } from 'react'

type TodoItem = {
  id: string
  title: string
  completed: boolean
}

function TodoList() {
  const [todos, setTodos] = useState<TodoItem[]>([])

  // ✅ 함수형 setState로 안정적인 추가 로직
  const addTodo = useCallback(async (title: string) => {
    const newTodo = await invoke<TodoItem>('create_todo', { title })
    setTodos(curr => [...curr, newTodo])
  }, [])

  // ✅ 함수형 setState로 안정적인 토글 로직
  const toggleTodo = useCallback(async (id: string) => {
    await invoke('toggle_todo', { id })
    setTodos(curr =>
      curr.map(todo =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    )
  }, [])

  // ✅ 함수형 setState로 안정적인 삭제 로직
  const deleteTodo = useCallback(async (id: string) => {
    await invoke('delete_todo', { id })
    setTodos(curr => curr.filter(todo => todo.id !== id))
  }, [])

  return (
    <div>
      {todos.map(todo => (
        <div key={todo.id}>
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={() => toggleTodo(todo.id)}
          />
          {todo.title}
          <button onClick={() => deleteTodo(todo.id)}>Delete</button>
        </div>
      ))}
      <button onClick={() => addTodo('New Task')}>Add Todo</button>
    </div>
  )
}
```

## 추가 컨텍스트

**장점:**
1. **안정적인 콜백 참조** - 상태 변경 시 콜백 재생성 불필요
2. **Stale closure 없음** - 항상 최신 상태 값으로 동작
3. **적은 의존성** - 의존성 배열 단순화
4. **버그 방지** - React closure 버그의 가장 흔한 원인 제거

**함수형 업데이트를 사용해야 하는 경우:**
- 현재 상태 값에 의존하는 모든 setState
- 상태가 필요한 useCallback/useMemo 내부
- 상태를 참조하는 이벤트 핸들러
- 상태를 업데이트하는 비동기 작업 (invoke, listen)

**직접 업데이트를 사용해도 되는 경우:**
- 정적 값으로 상태 설정: `setCount(0)`
- props/arguments로만 상태 설정: `setName(newName)`
- 상태가 이전 값에 의존하지 않는 경우

**Tauri 이벤트 리스너에서 특히 중요:**
- 이벤트 핸들러는 등록 시점의 상태를 클로저로 캡처
- 함수형 setState 없이는 초기 상태만 참조 (버그)
- cleanup 시에도 최신 상태 참조 필요

**참고:** [React useState](https://react.dev/reference/react/useState)

영향도: MEDIUM - 성능, 버그 방지, 콜백 안정성
