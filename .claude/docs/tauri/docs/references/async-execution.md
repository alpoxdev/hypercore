# Async Execution Model

> Tauri Command의 비동기 실행 원리

---

## async vs non-async Command

| 유형 | 실행 위치 | 사용 시점 |
|------|----------|----------|
| `async fn` | Tokio async runtime | IO 작업 (DB, HTTP, File) |
| `fn` (non-async) | 별도 스레드풀 | CPU 작업 (계산, 변환) |

```rust
// ✅ async Command: Tokio runtime에서 실행
// - await 사용 가능
// - IO 작업에 적합 (non-blocking)
#[tauri::command]
async fn fetch_data(url: String) -> Result<String, String> {
    let response = reqwest::get(&url).await.map_err(|e| e.to_string())?;
    response.text().await.map_err(|e| e.to_string())
}

// ✅ non-async Command: 스레드풀에서 실행
// - CPU 집약적 작업에 적합
// - 메인 스레드 블로킹 방지
#[tauri::command]
fn heavy_computation(data: Vec<u8>) -> Vec<u8> {
    // CPU 집약적 작업
    data.iter().map(|x| x.wrapping_mul(2)).collect()
}
```

---

## Tokio Runtime 동작

```
┌─────────────────────────────────────────────────────────────┐
│                      Tauri Application                       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   Tokio Runtime                      │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │    │
│  │  │ async Task 1│  │ async Task 2│  │ async Task 3│ │    │
│  │  │ (fetch_data)│  │ (read_file) │  │ (db_query)  │ │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Thread Pool (sync commands)             │    │
│  │  ┌─────────────┐  ┌─────────────┐                   │    │
│  │  │ sync Task 1 │  │ sync Task 2 │                   │    │
│  │  │ (compute)   │  │ (transform) │                   │    │
│  │  └─────────────┘  └─────────────┘                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 주의사항

| 패턴 | 설명 |
|------|------|
| **async에서 blocking 금지** | `std::thread::sleep()` 대신 `tokio::time::sleep()` 사용 |
| **sync에서 await 불가** | non-async 함수에서는 `.await` 사용 불가 |
| **spawn_blocking** | async 내에서 blocking 작업 필요 시 `tokio::task::spawn_blocking` |
