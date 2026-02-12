# State Management Guide

> Tauri Rust 상태 관리 상세 가이드

---

## State 패턴

```rust
use std::sync::Mutex;
use tauri::{Builder, Manager, State};

struct AppState {
    counter: u32,
    db_url: String,
}

#[tauri::command]
async fn increment(state: State<'_, Mutex<AppState>>) -> Result<u32, String> {
    let mut s = state.lock().map_err(|e| e.to_string())?;
    s.counter += 1;
    Ok(s.counter)
}

fn main() {
    Builder::default()
        .setup(|app| {
            // 불변 상태
            app.manage(String::from("config-value"));
            // 가변 상태
            app.manage(Mutex::new(AppState { counter: 0, db_url: String::new() }));
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![increment])
        .run(tauri::generate_context!())
        .unwrap();
}
```

---

## 규칙

| 규칙 | 설명 |
|------|------|
| **Arc 불필요** | State<T>가 내부 처리 |
| **가변 상태** | `Mutex<T>` 사용 (std::sync::Mutex 권장) |
| **await 제한** | await 포인트 넘어 lock 유지 금지 |
| **타입 별칭** | 잘못된 타입 접근 → 런타임 패닉 |
