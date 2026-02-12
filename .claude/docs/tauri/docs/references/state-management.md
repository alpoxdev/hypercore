# State Management

> Tauri Rust 상태 관리 상세 가이드

---

## Rust State 패턴

```rust
use std::sync::Mutex;
use tauri::{Builder, Manager, State};

// 상태 정의
struct AppState {
    counter: u32,
    db_url: String,
}

// Command에서 사용
#[tauri::command]
async fn increment(state: State<'_, Mutex<AppState>>) -> Result<u32, String> {
    let mut s = state.lock().map_err(|e| e.to_string())?;
    s.counter += 1;
    Ok(s.counter)
}

// 등록
fn main() {
    Builder::default()
        .setup(|app| {
            app.manage(Mutex::new(AppState { counter: 0, db_url: String::new() }));
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![increment])
        .run(tauri::generate_context!())
        .unwrap();
}
```

---

## State 규칙

| 규칙 | 설명 |
|------|------|
| **Arc 불필요** | State<T>가 내부적으로 Arc 처리 |
| **가변 상태** | `Mutex<T>` 사용 |
| **await 제한** | await 포인트 넘어 lock 유지 금지 (데드락) |
| **타입 별칭** | 잘못된 타입 접근 → 런타임 패닉 |

---

## Mutex 선택 기준

| Mutex 종류 | 사용 시점 | 예시 |
|-----------|----------|------|
| `std::sync::Mutex` | CPU 작업 (빠른 연산) | counter, config, cache |
| `tokio::sync::Mutex` | IO 작업 (await 필요) | DB, HTTP, File |

---

## await 걸쳐 lock 유지 금지

```rust
// ❌ 잘못된 예시: await 걸쳐 lock 유지 → 데드락 위험
#[tauri::command]
async fn bad_example(state: State<'_, std::sync::Mutex<AppState>>) -> Result<(), String> {
    let s = state.lock().unwrap();  // lock 획득
    some_async_operation().await;   // await 포인트 → 다른 스레드 블로킹
    s.counter += 1;                 // lock 아직 유지 중
    Ok(())
}

// ✅ 올바른 예시 1: lock 범위 최소화
#[tauri::command]
async fn good_example_1(state: State<'_, std::sync::Mutex<AppState>>) -> Result<(), String> {
    let data = {
        let s = state.lock().unwrap();
        s.get_data()  // lock 범위 내에서 필요한 작업만
    };  // lock 해제
    some_async_operation(data).await;  // await는 lock 밖에서
    Ok(())
}

// ✅ 올바른 예시 2: IO 작업 시 tokio::sync::Mutex
#[tauri::command]
async fn good_example_2(state: State<'_, tokio::sync::Mutex<DbConnection>>) -> Result<(), String> {
    let mut db = state.lock().await;  // tokio Mutex는 await 가능
    db.query("SELECT * FROM users").await?;
    Ok(())
}
```

---

## Frontend State (Zustand)

```typescript
// stores/app.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useAppStore = create(
  persist(
    (set) => ({
      theme: 'dark' as 'light' | 'dark',
      setTheme: (theme) => set({ theme }),
    }),
    { name: 'app-store' }
  )
);
```

| 상태 유형 | 위치 | 사용 |
|----------|------|------|
| **시스템 상태** | Rust State | DB 연결, 설정, 캐시 |
| **UI 상태** | Zustand | 테마, 사이드바, 임시 데이터 |
