# listen/unlisten 라이프사이클 관리

## 왜 중요한가

Tauri의 이벤트 리스너는 수동으로 등록 해제하지 않으면 메모리에 남아 누수를 일으킵니다. 컴포넌트가 여러 번 마운트/언마운트되는 경우 리스너가 중복 등록되어 동일 이벤트에 여러 핸들러가 실행될 수 있습니다.

## ❌ 잘못된 패턴

```tsx
import { listen } from '@tauri-apps/api/event'
import { useEffect, useState } from 'react'

function NotificationPanel() {
  const [messages, setMessages] = useState<string[]>([])

  useEffect(() => {
    // ❌ unlisten 호출 없음 (메모리 누수)
    listen<string>('notification', event => {
      setMessages(prev => [...prev, event.payload])
    })
  }, [])

  return (
    <div>
      {messages.map((msg, i) => <div key={i}>{msg}</div>)}
    </div>
  )
}
```

**문제점:**
- cleanup에서 unlisten 호출 안 함 (리스너 계속 활성 상태)
- 컴포넌트 재마운트 시 리스너 중복 등록
- 언마운트된 컴포넌트에서 setState 호출 위험

## ✅ 올바른 패턴

```tsx
import { listen, UnlistenFn } from '@tauri-apps/api/event'
import { useEffect, useState } from 'react'

function NotificationPanel() {
  const [messages, setMessages] = useState<string[]>([])

  useEffect(() => {
    let unlisten: UnlistenFn | undefined

    listen<string>('notification', event => {
      setMessages(prev => [...prev, event.payload])
    }).then(unlistenFn => {
      unlisten = unlistenFn
    })

    return () => {
      unlisten?.()
    }
  }, [])

  return (
    <div>
      {messages.map((msg, i) => <div key={i}>{msg}</div>)}
    </div>
  )
}
```

**once() 패턴 (일회성 이벤트):**

```tsx
import { once } from '@tauri-apps/api/event'

function WelcomeScreen() {
  const [ready, setReady] = useState(false)

  useEffect(() => {
    let unlisten: UnlistenFn | undefined

    once<void>('app-ready', () => {
      setReady(true)
    }).then(unlistenFn => {
      unlisten = unlistenFn
    })

    return () => unlisten?.()
  }, [])

  return ready ? <MainApp /> : <SplashScreen />
}
```

**커스텀 hook 패턴:**

```tsx
import { listen, Event, UnlistenFn } from '@tauri-apps/api/event'
import { useEffect, useState } from 'react'

function useEvent<T>(
  eventName: string,
  handler: (event: Event<T>) => void
) {
  useEffect(() => {
    let unlisten: UnlistenFn | undefined

    listen<T>(eventName, handler).then(unlistenFn => {
      unlisten = unlistenFn
    })

    return () => unlisten?.()
  }, [eventName, handler])
}

// 사용 예시
function StatusBar() {
  const [status, setStatus] = useState('idle')

  useEvent<string>('status-update', event => {
    setStatus(event.payload)
  })

  return <div>Status: {status}</div>
}
```

## 추가 컨텍스트

**cleanup 타이밍:**
- useEffect return 함수는 언마운트 시 또는 의존성 변경 시 실행
- 리스너는 항상 cleanup에서 제거해야 메모리 누수 방지

**글로벌 이벤트 vs 로컬 이벤트:**
- `listen()`: 모든 윈도우에서 수신
- `emit()`: 현재 윈도우로 전송
- `once()`: 한 번만 실행 후 자동 제거

**타입 안정성:**
```tsx
type NotificationPayload = {
  title: string
  body: string
  level: 'info' | 'warning' | 'error'
}

listen<NotificationPayload>('notification', event => {
  // event.payload는 타입 안전하게 추론됨
  console.log(event.payload.title)
})
```

**참고:** [Tauri Events Guide](https://beta.tauri.app/develop/calling-rust/#events)

영향도: HIGH - 메모리 누수, 중복 핸들러 실행 방지
