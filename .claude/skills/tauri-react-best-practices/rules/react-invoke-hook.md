# useEffect + invoke 패턴으로 Tauri Command 호출

## 왜 중요한가

Tauri의 `invoke()` 호출은 비동기 IPC이므로 React 컴포넌트 라이프사이클과 통합 시 cleanup이 필수입니다. 컴포넌트 언마운트 후 응답이 도착하면 "Can't perform state update on unmounted component" 경고와 메모리 누수가 발생합니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState } from 'react'

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState(null)

  // ❌ cleanup 없음, 언마운트 후 setState 위험
  invoke('get_user', { userId })
    .then(setUser)
    .catch(console.error)

  return user ? <div>{user.name}</div> : <div>Loading...</div>
}
```

**문제점:**
- useEffect 없이 invoke 호출 (매 렌더링마다 실행)
- cleanup 로직 없음 (언마운트 후 setState)
- 에러 처리 불충분

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState } from 'react'

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false

    setLoading(true)
    setError(null)

    invoke<User>('get_user', { userId })
      .then(data => {
        if (!cancelled) setUser(data)
      })
      .catch(err => {
        if (!cancelled) setError(err.message)
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [userId])

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  return user ? <div>{user.name}</div> : null
}
```

**개선된 커스텀 hook 패턴:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState } from 'react'

function useInvoke<T>(
  command: string,
  args?: Record<string, unknown>
) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<Error | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false

    setLoading(true)
    setError(null)

    invoke<T>(command, args)
      .then(result => !cancelled && setData(result))
      .catch(err => !cancelled && setError(err))
      .finally(() => !cancelled && setLoading(false))

    return () => {
      cancelled = true
    }
  }, [command, JSON.stringify(args)])

  return { data, error, loading }
}

// 사용 예시
function UserProfile({ userId }: { userId: string }) {
  const { data: user, error, loading } = useInvoke<User>(
    'get_user',
    { userId }
  )

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  return user ? <div>{user.name}</div> : null
}
```

## 추가 컨텍스트

**AbortController 패턴 (Tauri v2.1+):**

```tsx
useEffect(() => {
  const controller = new AbortController()

  invoke('long_running_task', { signal: controller.signal })
    .then(setResult)
    .catch(err => {
      if (err.name !== 'AbortError') setError(err)
    })

  return () => controller.abort()
}, [])
```

**권장 의존성 관리:**
- 원시 값 (`userId`, `query`): 직접 의존성 배열에 추가
- 객체/배열 args: `JSON.stringify(args)` 또는 `useMemo`로 안정화

**참고:** TanStack Query와 함께 사용 시 `queryFn`에서 invoke 호출하면 자동 cleanup 제공.

영향도: HIGH - 메모리 누수, 상태 버그, 콘솔 경고 방지
