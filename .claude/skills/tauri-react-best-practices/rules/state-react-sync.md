---
title: Rust-React State Synchronization
impact: HIGH
impactDescription: ensures consistent state across boundaries
tags: state, react, events, synchronization, ipc
---

# Rust 상태와 React 상태 동기화 패턴

## 왜 중요한가

Tauri 앱에서 **Rust 백엔드 상태**와 **React 프론트엔드 상태**가 독립적으로 관리되면 **불일치**가 발생합니다. Tauri Events를 사용하여 양방향 동기화를 구현해야 합니다.

## ❌ 잘못된 패턴

**Rust와 React 상태가 각각 독립적으로 관리:**

```rust
// ❌ src-tauri/src/main.rs - Rust 상태만 업데이트
use std::sync::Mutex;
use tauri::State;

struct AppStateInner {
    count: i32
}

type AppState = Mutex<AppStateInner>;

#[tauri::command]
fn increment(state: State<'_, AppState>) -> i32 {
    let mut state = state.lock().unwrap();
    state.count += 1;
    state.count // React에 반환만 하고 끝
}
```

```typescript
// ❌ src/App.tsx - React 상태가 동기화되지 않음
import { useState } from 'react'
import { invoke } from '@tauri-apps/api/core'

function App() {
  const [count, setCount] = useState(0)

  const handleIncrement = async () => {
    const newCount = await invoke<number>('increment')
    setCount(newCount) // ✅ 이 창에서는 동기화됨
  }

  // ❌ 다른 창이나 백그라운드 업데이트는 감지 못함
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={handleIncrement}>Increment</button>
    </div>
  )
}
```

**문제:**
- 다른 창에서 `increment` 호출 시 현재 창의 `count`가 업데이트되지 않음
- Rust 상태 변경이 React에 전파되지 않음
- 백그라운드 작업이 상태를 변경해도 UI가 업데이트 안됨

## ✅ 올바른 패턴

**Tauri Events로 Rust → React 동기화:**

```rust
// ✅ src-tauri/src/state.rs
use std::sync::Mutex;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppStateInner {
    pub count: i32,
    pub username: String
}

pub type AppState = Mutex<AppStateInner>;

impl AppStateInner {
    pub fn new() -> Self {
        Self {
            count: 0,
            username: String::from("Guest")
        }
    }
}
```

```rust
// ✅ src-tauri/src/main.rs - 상태 변경 시 이벤트 발행
mod state;

use state::{AppState, AppStateInner};
use tauri::{State, Manager, Emitter};

#[tauri::command]
fn increment(state: State<'_, AppState>, app: tauri::AppHandle) -> Result<i32, String> {
    let new_count = {
        let mut state = state.lock().unwrap();
        state.count += 1;
        state.count
    };

    // ✅ 모든 창에 상태 변경 알림
    app.emit("state-changed", &new_count)
        .map_err(|e| format!("Failed to emit event: {}", e))?;

    Ok(new_count)
}

#[tauri::command]
fn set_username(
    state: State<'_, AppState>,
    app: tauri::AppHandle,
    username: String
) -> Result<(), String> {
    {
        let mut state = state.lock().unwrap();
        state.username = username.clone();
    }

    // ✅ username 변경 이벤트 발행
    app.emit("username-changed", &username)
        .map_err(|e| format!("Failed to emit event: {}", e))?;

    Ok(())
}

#[tauri::command]
fn get_state(state: State<'_, AppState>) -> Result<AppStateInner, String> {
    let state = state.lock()
        .map_err(|e| format!("Failed to lock state: {}", e))?;
    Ok(state.clone())
}

fn main() {
    tauri::Builder::default()
        .manage(AppState::new(AppStateInner::new()))
        .invoke_handler(tauri::generate_handler![
            increment,
            set_username,
            get_state
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```typescript
// ✅ src/App.tsx - 이벤트 리스너로 동기화
import { useState, useEffect } from 'react'
import { invoke } from '@tauri-apps/api/core'
import { listen } from '@tauri-apps/api/event'

interface AppState {
  count: number
  username: string
}

function App() {
  const [state, setState] = useState<AppState>({
    count: 0,
    username: 'Guest'
  })

  useEffect(() => {
    // ✅ 초기 상태 로드
    invoke<AppState>('get_state').then(setState)

    // ✅ Rust 상태 변경 감지
    const unlistenCount = listen<number>('state-changed', (event) => {
      setState(prev => ({ ...prev, count: event.payload }))
    })

    const unlistenUsername = listen<string>('username-changed', (event) => {
      setState(prev => ({ ...prev, username: event.payload }))
    })

    // 클린업
    return () => {
      unlistenCount.then(fn => fn())
      unlistenUsername.then(fn => fn())
    }
  }, [])

  const handleIncrement = async () => {
    await invoke('increment') // 이벤트로 상태 업데이트됨
  }

  const handleSetUsername = async (name: string) => {
    await invoke('set_username', { username: name })
  }

  return (
    <div>
      <p>Count: {state.count}</p>
      <p>Username: {state.username}</p>
      <button onClick={handleIncrement}>Increment</button>
      <button onClick={() => handleSetUsername('Alice')}>
        Set Username
      </button>
    </div>
  )
}

export default App
```

**React → Rust 동기화 (양방향):**

```typescript
// ✅ src/App.tsx - React 상태 변경 시 Rust에 동기화
function App() {
  const [localCount, setLocalCount] = useState(0)

  const handleLocalIncrement = async () => {
    // 낙관적 업데이트
    const newCount = localCount + 1
    setLocalCount(newCount)

    // Rust 상태 동기화
    try {
      await invoke('increment')
    } catch (error) {
      // 실패 시 롤백
      setLocalCount(localCount)
      console.error('Failed to sync state:', error)
    }
  }

  return (
    <div>
      <p>Local Count: {localCount}</p>
      <button onClick={handleLocalIncrement}>Increment</button>
    </div>
  )
}
```

**커스텀 훅으로 추상화:**

```typescript
// ✅ src/hooks/useTauriState.ts
import { useState, useEffect } from 'react'
import { invoke } from '@tauri-apps/api/core'
import { listen } from '@tauri-apps/api/event'

export function useTauriState<T>(
  getCommand: string,
  eventName: string
): [T | null, (newValue: T) => Promise<void>] {
  const [state, setState] = useState<T | null>(null)

  useEffect(() => {
    // 초기 상태 로드
    invoke<T>(getCommand).then(setState)

    // 이벤트 리스너
    const unlisten = listen<T>(eventName, (event) => {
      setState(event.payload)
    })

    return () => {
      unlisten.then(fn => fn())
    }
  }, [getCommand, eventName])

  const updateState = async (newValue: T) => {
    setState(newValue)
    await invoke('update_state', { newValue })
  }

  return [state, updateState]
}

// 사용 예시
function App() {
  const [count, setCount] = useTauriState<number>('get_count', 'count-changed')

  return (
    <div>
      <p>Count: {count ?? 'Loading...'}</p>
      <button onClick={() => setCount((count ?? 0) + 1)}>
        Increment
      </button>
    </div>
  )
}
```

## 추가 컨텍스트

**양방향 동기화 아키텍처:**

```
┌─────────────┐         invoke()        ┌─────────────┐
│   React     │ ───────────────────────> │    Rust     │
│   State     │                          │    State    │
│             │ <─────────────────────── │             │
└─────────────┘      emit() event        └─────────────┘
```

**동기화 패턴 비교:**

| 패턴 | 장점 | 단점 | 권장 |
|------|------|------|------|
| **Poll (주기적 조회)** | 간단 | 비효율적, 지연 | ❌ |
| **Event-driven** | 실시간, 효율적 | 복잡도 증가 | ✅ |
| **낙관적 업데이트** | 빠른 UX | 실패 시 롤백 필요 | ⚠️ 선택 |

**여러 창 동기화:**

```rust
// 모든 창에 브로드캐스트
app.emit_all("state-changed", &new_count)?;

// 특정 창에만 전송
if let Some(window) = app.get_window("main") {
    window.emit("state-changed", &new_count)?;
}
```

**에러 처리:**

```typescript
useEffect(() => {
  const unlisten = listen<number>('state-changed', (event) => {
    setState(event.payload)
  }).catch((error) => {
    console.error('Failed to listen to events:', error)
  })

  return () => {
    unlisten.then(fn => fn()).catch(console.error)
  }
}, [])
```

**성능 최적화:**

```rust
// 디바운싱으로 과도한 이벤트 방지
use std::time::{Duration, Instant};

struct StateEmitter {
    last_emit: Mutex<Instant>
}

impl StateEmitter {
    fn emit_throttled(&self, app: &tauri::AppHandle, count: i32) -> Result<(), String> {
        let mut last = self.last_emit.lock().unwrap();
        let now = Instant::now();

        if now.duration_since(*last) > Duration::from_millis(100) {
            app.emit("state-changed", &count)
                .map_err(|e| e.to_string())?;
            *last = now;
        }

        Ok(())
    }
}
```

**참고:**
- Tauri Events: [Inter-Process Communication](https://tauri.app/v2/guides/features/events/)
- React useEffect: [Synchronizing with Effects](https://react.dev/learn/synchronizing-with-effects)

**영향도:**
- 일관성: HIGH (상태 불일치 방지)
- 실시간성: HIGH (즉시 동기화)
- 복잡도: MEDIUM (이벤트 관리 필요)
