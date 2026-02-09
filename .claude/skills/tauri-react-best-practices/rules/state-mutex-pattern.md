---
title: Mutex for Mutable State
impact: HIGH
impactDescription: prevents panic from concurrent access
tags: state, mutex, thread-safety, tauri, rust
---

# Mutex로 가변 상태 관리, 타입 별칭 사용

## 왜 중요한가

Tauri의 상태 관리는 **여러 스레드에서 동시에 접근**할 수 있습니다. 가변 상태를 `Mutex`로 감싸지 않으면 **런타임 패닉**이 발생하며, 타입 불일치로 인한 버그를 방지하기 위해 **타입 별칭**을 사용해야 합니다.

## ❌ 잘못된 패턴

**Mutex 없이 가변 상태 관리 (패닉 발생):**

```rust
// ❌ src-tauri/src/main.rs
use tauri::State;

struct AppState {
    count: i32
}

#[tauri::command]
fn increment(state: State<'_, AppState>) -> i32 {
    state.count += 1; // ❌ 컴파일 에러: cannot mutate immutable field
    state.count
}

fn main() {
    tauri::Builder::default()
        .manage(AppState { count: 0 })
        .invoke_handler(tauri::generate_handler![increment])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**Mutex 사용하지만 타입 별칭 없음 (불일치 위험):**

```rust
// ⚠️ src-tauri/src/main.rs
use std::sync::Mutex;
use tauri::State;

struct AppStateInner {
    count: i32
}

#[tauri::command]
fn increment(state: State<'_, Mutex<AppStateInner>>) -> i32 {
    let mut state = state.lock().unwrap();
    state.count += 1;
    state.count
}

#[tauri::command]
fn get_count(state: State<'_, AppStateInner>) -> i32 {
    // ❌ 타입 불일치: Mutex<AppStateInner>를 등록했지만
    // AppStateInner로 접근 시도 → 런타임 패닉!
    state.count
}

fn main() {
    tauri::Builder::default()
        .manage(Mutex::new(AppStateInner { count: 0 }))
        .invoke_handler(tauri::generate_handler![increment, get_count])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**런타임 에러:**
```
thread 'main' panicked at 'Failed to get state: no state of type `AppStateInner` is managed'
```

## ✅ 올바른 패턴

**Mutex + 타입 별칭으로 타입 안전성 보장:**

```rust
// ✅ src-tauri/src/main.rs
use std::sync::Mutex;
use tauri::State;

// 내부 상태 구조체
struct AppStateInner {
    count: i32,
    username: String
}

// 타입 별칭으로 Mutex 포함
type AppState = Mutex<AppStateInner>;

#[tauri::command]
fn increment(state: State<'_, AppState>) -> i32 {
    let mut state = state.lock().unwrap();
    state.count += 1;
    state.count
}

#[tauri::command]
fn get_count(state: State<'_, AppState>) -> i32 {
    let state = state.lock().unwrap();
    state.count
}

#[tauri::command]
fn set_username(state: State<'_, AppState>, name: String) {
    let mut state = state.lock().unwrap();
    state.username = name;
}

fn main() {
    tauri::Builder::default()
        .manage(AppState::new(AppStateInner {
            count: 0,
            username: String::from("Guest")
        }))
        .invoke_handler(tauri::generate_handler![
            increment,
            get_count,
            set_username
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**별도 파일로 상태 관리 분리:**

```rust
// ✅ src-tauri/src/state.rs
use std::sync::Mutex;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct AppStateInner {
    pub count: i32,
    pub username: String,
    pub is_logged_in: bool
}

impl Default for AppStateInner {
    fn default() -> Self {
        Self {
            count: 0,
            username: String::from("Guest"),
            is_logged_in: false
        }
    }
}

pub type AppState = Mutex<AppStateInner>;

impl AppStateInner {
    pub fn new() -> Self {
        Self::default()
    }
}
```

```rust
// ✅ src-tauri/src/main.rs
mod state;

use state::{AppState, AppStateInner};
use tauri::State;

#[tauri::command]
fn increment(state: State<'_, AppState>) -> i32 {
    let mut state = state.lock().unwrap();
    state.count += 1;
    state.count
}

#[tauri::command]
fn login(state: State<'_, AppState>, username: String) {
    let mut state = state.lock().unwrap();
    state.username = username;
    state.is_logged_in = true;
}

fn main() {
    tauri::Builder::default()
        .manage(AppState::new(AppStateInner::new()))
        .invoke_handler(tauri::generate_handler![increment, login])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## 추가 컨텍스트

**Mutex가 필요한 이유:**

| 상황 | Mutex 필요 여부 | 이유 |
|------|----------------|------|
| 읽기 전용 상태 | ❌ | `State<'_, T>` 자체가 읽기 전용 보장 |
| 가변 상태 | ✅ | 여러 스레드에서 동시 수정 가능 |
| 단일 스레드 | ⚠️ | Tauri는 멀티스레드 환경이므로 Mutex 필수 |

**타입 별칭의 장점:**

1. **타입 안전성**: 모든 커맨드에서 동일한 타입 사용
2. **가독성**: `State<'_, AppState>` vs `State<'_, Mutex<AppStateInner>>`
3. **유지보수**: 상태 구조 변경 시 타입 별칭만 수정

**Mutex::lock() 에러 처리:**

```rust
// ❌ unwrap() - 패닉 발생 가능
let mut state = state.lock().unwrap();

// ✅ Result 반환 - 에러 처리
#[tauri::command]
fn increment(state: State<'_, AppState>) -> Result<i32, String> {
    let mut state = state.lock()
        .map_err(|e| format!("Failed to lock state: {}", e))?;
    state.count += 1;
    Ok(state.count)
}
```

**RwLock vs Mutex:**

```rust
// 읽기가 많고 쓰기가 적은 경우 RwLock 사용
use std::sync::RwLock;

type AppState = RwLock<AppStateInner>;

#[tauri::command]
fn get_count(state: State<'_, AppState>) -> i32 {
    let state = state.read().unwrap(); // 여러 스레드 동시 읽기 가능
    state.count
}

#[tauri::command]
fn increment(state: State<'_, AppState>) -> i32 {
    let mut state = state.write().unwrap(); // 배타적 쓰기
    state.count += 1;
    state.count
}
```

**패턴 비교:**

| 패턴 | 장점 | 단점 | 권장 |
|------|------|------|------|
| `Mutex<T>` | 단순, 안전 | 읽기도 락 필요 | 쓰기 많을 때 |
| `RwLock<T>` | 읽기 병렬화 | 복잡, 오버헤드 | 읽기 많을 때 |
| `Arc<Mutex<T>>` | 복제 가능 | 불필요 (Tauri가 관리) | ❌ 사용 안함 |

**참고:**
- Tauri State Management: [Managing State](https://tauri.app/v2/guides/features/state-management/)
- Rust Mutex: [std::sync::Mutex](https://doc.rust-lang.org/std/sync/struct.Mutex.html)

**영향도:**
- 안정성: HIGH (패닉 방지)
- 타입 안전성: HIGH (컴파일 타임 검증)
- 성능: NEUTRAL (Mutex 오버헤드 미미)
