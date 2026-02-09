---
title: Async Mutex for IO Resources
impact: MEDIUM
impactDescription: prevents blocking tokio runtime
tags: state, mutex, async, tokio, performance
---

# IO 리소스만 Tokio Mutex, 나머지는 Std Mutex

## 왜 중요한가

Rust의 `std::sync::Mutex`는 **CPU 작업**에 최적화되어 있고, `tokio::sync::Mutex`는 **비동기 IO 작업**에 최적화되어 있습니다. 잘못된 Mutex를 사용하면 **성능 저하**나 **데드락**이 발생할 수 있습니다.

## ❌ 잘못된 패턴

**모든 곳에 Tokio Mutex 사용 (CPU 작업에서 오버헤드):**

```rust
// ❌ src-tauri/src/main.rs
use tokio::sync::Mutex; // ❌ CPU 작업에는 비효율적
use tauri::State;

struct AppStateInner {
    counter: i32,         // CPU 작업
    database: Database    // IO 작업
}

type AppState = Mutex<AppStateInner>;

#[tauri::command]
async fn increment(state: State<'_, AppState>) -> Result<i32, String> {
    let mut state = state.lock().await; // ❌ 불필요한 async
    state.counter += 1; // CPU 작업인데 tokio::Mutex 사용
    Ok(state.counter)
}

#[tauri::command]
async fn query_db(state: State<'_, AppState>) -> Result<String, String> {
    let state = state.lock().await; // ❌ Database도 함께 락
    let result = state.database.query("SELECT * FROM users").await?;
    Ok(result)
}
```

**문제:**
- `increment`는 CPU 작업인데 `tokio::Mutex`의 async 오버헤드 발생
- `database` IO 작업 중에도 `counter`가 락되어 병렬성 저하

## ✅ 올바른 패턴

**CPU 작업과 IO 작업을 분리, 적절한 Mutex 사용:**

```rust
// ✅ src-tauri/src/state.rs
use std::sync::Mutex as StdMutex;
use tokio::sync::Mutex as TokioMutex;

pub struct Database {
    pool: sqlx::Pool<sqlx::Postgres>
}

impl Database {
    pub async fn query(&self, sql: &str) -> Result<String, sqlx::Error> {
        let rows = sqlx::query(sql)
            .fetch_all(&self.pool)
            .await?;
        Ok(format!("{:?}", rows))
    }
}

pub struct AppStateInner {
    // CPU 작업: std::sync::Mutex
    counter: StdMutex<i32>,
    settings: StdMutex<AppSettings>,

    // IO 작업: tokio::sync::Mutex
    database: TokioMutex<Database>,
    http_client: TokioMutex<reqwest::Client>
}

pub type AppState = AppStateInner;

impl AppStateInner {
    pub fn new(db_pool: sqlx::Pool<sqlx::Postgres>) -> Self {
        Self {
            counter: StdMutex::new(0),
            settings: StdMutex::new(AppSettings::default()),
            database: TokioMutex::new(Database { pool: db_pool }),
            http_client: TokioMutex::new(reqwest::Client::new())
        }
    }
}
```

```rust
// ✅ src-tauri/src/main.rs
mod state;

use state::{AppState, AppStateInner};
use tauri::State;

// CPU 작업: 동기 함수, std::Mutex
#[tauri::command]
fn increment(state: State<'_, AppState>) -> Result<i32, String> {
    let mut counter = state.counter.lock()
        .map_err(|e| format!("Failed to lock counter: {}", e))?;
    *counter += 1;
    Ok(*counter)
}

// IO 작업: async 함수, tokio::Mutex
#[tauri::command]
async fn query_db(state: State<'_, AppState>) -> Result<String, String> {
    let db = state.database.lock().await; // await 필요
    let result = db.query("SELECT * FROM users")
        .await
        .map_err(|e| e.to_string())?;
    Ok(result)
}

// IO 작업: async 함수, tokio::Mutex
#[tauri::command]
async fn fetch_data(state: State<'_, AppState>, url: String) -> Result<String, String> {
    let client = state.http_client.lock().await;
    let response = client.get(&url)
        .send()
        .await
        .map_err(|e| e.to_string())?
        .text()
        .await
        .map_err(|e| e.to_string())?;
    Ok(response)
}

#[tokio::main]
async fn main() {
    let db_pool = sqlx::postgres::PgPoolOptions::new()
        .connect("postgres://localhost/mydb")
        .await
        .expect("Failed to connect to database");

    tauri::Builder::default()
        .manage(AppStateInner::new(db_pool))
        .invoke_handler(tauri::generate_handler![
            increment,
            query_db,
            fetch_data
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**RwLock 혼합 사용 (읽기 많은 경우):**

```rust
use std::sync::RwLock as StdRwLock;
use tokio::sync::RwLock as TokioRwLock;

pub struct AppStateInner {
    // 읽기 많은 CPU 작업: std::sync::RwLock
    config: StdRwLock<AppConfig>,

    // 읽기 많은 IO 작업: tokio::sync::RwLock
    cache: TokioRwLock<Cache>
}

#[tauri::command]
fn get_config(state: State<'_, AppState>) -> Result<String, String> {
    let config = state.config.read()
        .map_err(|e| format!("Failed to read config: {}", e))?;
    Ok(format!("{:?}", *config))
}

#[tauri::command]
async fn get_cached_data(state: State<'_, AppState>, key: String) -> Result<String, String> {
    let cache = state.cache.read().await;
    cache.get(&key)
        .await
        .ok_or_else(|| "Key not found".to_string())
}
```

## 추가 컨텍스트

**Mutex 선택 가이드:**

| 작업 유형 | Mutex 종류 | 이유 |
|-----------|-----------|------|
| CPU 계산 (counter, settings) | `std::sync::Mutex` | OS 레벨 락, 오버헤드 낮음 |
| IO 작업 (DB, HTTP, 파일) | `tokio::sync::Mutex` | async/await 호환, tokio runtime 차단 안함 |
| 읽기 많음 + CPU | `std::sync::RwLock` | 여러 스레드 동시 읽기 |
| 읽기 많음 + IO | `tokio::sync::RwLock` | 비동기 읽기 병렬화 |

**성능 비교:**

```rust
// 벤치마크 예시 (단순 증가 연산 1,000,000회)
// std::sync::Mutex: 50ms
// tokio::sync::Mutex: 120ms (2.4배 느림)

// IO 작업 시 (100ms 네트워크 요청)
// std::sync::Mutex: tokio runtime 차단 → 다른 작업 대기
// tokio::sync::Mutex: 다른 작업 병렬 실행 가능
```

**데드락 위험:**

```rust
// ❌ std::sync::Mutex를 async 블록 안에서 .await 넘어 사용
async fn bad_example(state: State<'_, AppState>) {
    let lock = state.counter.lock().unwrap(); // std::Mutex
    some_async_function().await; // ❌ .await 동안 락 유지 → 데드락 위험
    println!("{}", *lock);
}

// ✅ 락 범위 최소화
async fn good_example(state: State<'_, AppState>) {
    let value = {
        let lock = state.counter.lock().unwrap();
        *lock // 값 복사 후 락 해제
    };
    some_async_function().await; // ✅ 락 해제 후 await
    println!("{}", value);
}
```

**Tauri 2.0+ 권장 패턴:**

```rust
// Tauri 2.0부터는 async command가 기본
// IO 작업은 tokio::Mutex + async
// CPU 작업은 std::Mutex + 동기 함수 (Tauri가 tokio::spawn_blocking 자동 처리)

#[tauri::command]
fn cpu_intensive_task(state: State<'_, AppState>) -> Result<i32, String> {
    // Tauri가 자동으로 blocking thread에서 실행
    let mut data = state.cpu_data.lock().unwrap();
    // 무거운 CPU 작업...
    Ok(*data)
}
```

**Arc는 언제 사용?**

```rust
// ❌ Tauri State에서는 Arc 불필요
use std::sync::Arc;
type AppState = Arc<Mutex<AppStateInner>>; // ❌ 불필요한 Arc

// ✅ Tauri가 자동으로 State를 관리 (이미 Arc 내부 사용)
type AppState = Mutex<AppStateInner>; // ✅ 충분

// ✅ State 외부에서 공유 필요 시에만 Arc 사용
let shared_db = Arc::new(Database::new());
let db_clone = Arc::clone(&shared_db);
tokio::spawn(async move {
    db_clone.query("...").await;
});
```

**참고:**
- Tokio Mutex: [tokio::sync::Mutex](https://docs.rs/tokio/latest/tokio/sync/struct.Mutex.html)
- Std Mutex: [std::sync::Mutex](https://doc.rust-lang.org/std/sync/struct.Mutex.html)
- Tauri Async: [Async Commands](https://tauri.app/v2/guides/features/commands/#async-commands)

**영향도:**
- 성능: MEDIUM (CPU 작업 2-3배, IO 작업 병렬성 향상)
- 데드락 방지: HIGH (올바른 Mutex 선택)
- 복잡도: MEDIUM (작업 유형 판단 필요)
