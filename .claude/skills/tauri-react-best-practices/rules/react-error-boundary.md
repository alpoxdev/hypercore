# invoke 실패에 대한 ErrorBoundary 처리

## 왜 중요한가

Tauri Command 호출은 Rust panic, 권한 거부, 타입 불일치 등 다양한 이유로 실패할 수 있습니다. ErrorBoundary 없이는 전체 앱이 크래시되거나 사용자에게 불친절한 에러 메시지가 노출됩니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState } from 'react'

function DataViewer() {
  const [data, setData] = useState(null)

  useEffect(() => {
    // ❌ 에러 처리 없음, 실패 시 앱 크래시
    invoke('fetch_data').then(setData)
  }, [])

  // data가 null이면 렌더링 에러 발생 가능
  return <div>{data.items.map(...)}</div>
}
```

**문제점:**
- try/catch 없는 invoke 호출
- 에러 상태 관리 없음
- 사용자에게 피드백 없음

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

function DataViewer() {
  const [data, setData] = useState<DataType | null>(null)
  const [error, setError] = useState<Error | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    invoke<DataType>('fetch_data')
      .then(setData)
      .catch(err => setError(err))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div>Loading...</div>
  if (error) throw error // ErrorBoundary로 전파
  if (!data) return <div>No data</div>

  return (
    <div>
      {data.items.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
    </div>
  )
}

function App() {
  return (
    <ErrorBoundary
      fallback={<ErrorFallback />}
      onError={(error, errorInfo) => {
        console.error('Caught by ErrorBoundary:', error, errorInfo)
      }}
    >
      <DataViewer />
    </ErrorBoundary>
  )
}

function ErrorFallback({ error, resetErrorBoundary }: {
  error: Error
  resetErrorBoundary: () => void
}) {
  return (
    <div role="alert">
      <h2>Something went wrong</h2>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  )
}
```

**Tauri 특화 에러 타입 처리:**

```tsx
import { invoke } from '@tauri-apps/api/core'

type TauriError = {
  message: string
  kind?: 'PermissionDenied' | 'NotFound' | 'InvalidData' | 'Unknown'
}

function parseTauriError(error: unknown): TauriError {
  if (typeof error === 'string') {
    // Rust에서 String 에러
    return { message: error, kind: 'Unknown' }
  }

  if (error instanceof Error) {
    // JS Error 객체
    const message = error.message

    if (message.includes('permission denied')) {
      return { message, kind: 'PermissionDenied' }
    }
    if (message.includes('not found')) {
      return { message, kind: 'NotFound' }
    }
    if (message.includes('invalid')) {
      return { message, kind: 'InvalidData' }
    }

    return { message, kind: 'Unknown' }
  }

  return { message: 'Unknown error', kind: 'Unknown' }
}

function DataViewer() {
  const [error, setError] = useState<TauriError | null>(null)

  useEffect(() => {
    invoke('fetch_data')
      .then(setData)
      .catch(err => setError(parseTauriError(err)))
  }, [])

  if (error) {
    if (error.kind === 'PermissionDenied') {
      return <div>권한이 필요합니다. 설정에서 권한을 허용해주세요.</div>
    }
    if (error.kind === 'NotFound') {
      return <div>데이터를 찾을 수 없습니다.</div>
    }
    return <div>오류: {error.message}</div>
  }

  return <div>{/* ... */}</div>
}
```

**재시도 로직:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState, useCallback } from 'react'

function useInvokeWithRetry<T>(
  command: string,
  args?: Record<string, unknown>,
  maxRetries = 3
) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<Error | null>(null)
  const [loading, setLoading] = useState(false)
  const [retries, setRetries] = useState(0)

  const execute = useCallback(async () => {
    setLoading(true)
    setError(null)

    for (let i = 0; i <= maxRetries; i++) {
      try {
        const result = await invoke<T>(command, args)
        setData(result)
        setRetries(i)
        return
      } catch (err) {
        if (i === maxRetries) {
          setError(err as Error)
          setRetries(i)
        } else {
          await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)))
        }
      }
    }

    setLoading(false)
  }, [command, args, maxRetries])

  return { data, error, loading, retries, execute }
}

// 사용 예시
function DataViewer() {
  const { data, error, loading, retries, execute } = useInvokeWithRetry<Data>(
    'fetch_data'
  )

  useEffect(() => {
    execute()
  }, [execute])

  if (loading) return <div>Loading... (Attempt {retries + 1})</div>
  if (error) return <div>Failed after {retries} retries: {error.message}</div>
  return <div>{data && JSON.stringify(data)}</div>
}
```

## 추가 컨텍스트

**ErrorBoundary 라이브러리:**
- [react-error-boundary](https://github.com/bvaughn/react-error-boundary): 가장 인기
- React 19+ 내장 ErrorBoundary (계획 중)

**Rust 에러를 사용자 친화적으로 변환:**

```rust
// Rust 측에서 에러 메시지 커스터마이징
#[tauri::command]
fn fetch_data() -> Result<Data, String> {
    match load_data() {
        Ok(data) => Ok(data),
        Err(_) => Err("데이터를 불러올 수 없습니다. 나중에 다시 시도해주세요.".to_string())
    }
}
```

**전역 에러 처리:**
```tsx
function App() {
  return (
    <ErrorBoundary fallback={<GlobalError />}>
      <Router />
    </ErrorBoundary>
  )
}
```

**참고:** [Error Handling in Tauri](https://beta.tauri.app/develop/calling-rust/#error-handling)

영향도: HIGH - 사용자 경험, 앱 안정성, 에러 복구 가능성
