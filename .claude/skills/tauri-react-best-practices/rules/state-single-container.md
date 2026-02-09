---
title: Single Container for Multiple States
impact: MEDIUM
impactDescription: prevents state registration conflicts
tags: state, container, tauri, type-map, rust
---

# 동일 타입 중복 등록 방지

## 왜 중요한가

Tauri의 상태 관리는 **타입 기반 의존성 주입** 시스템을 사용합니다. 동일한 타입을 여러 번 `manage()`로 등록하면 **두 번째 등록이 무시**되어 의도하지 않은 상태를 사용하게 됩니다.

## ❌ 잘못된 패턴

**동일 타입을 여러 번 manage() 호출:**

```rust
// ❌ src-tauri/src/main.rs
use std::sync::Mutex;
use tauri::State;

type DatabaseState = Mutex<String>;
type CacheState = Mutex<String>;

#[tauri::command]
fn get_db_connection(db: State<'_, DatabaseState>) -> String {
    let db = db.lock().unwrap();
    db.clone()
}

#[tauri::command]
fn get_cache_connection(cache: State<'_, CacheState>) -> String {
    let cache = cache.lock().unwrap();
    cache.clone()
}

fn main() {
    tauri::Builder::default()
        .manage(DatabaseState::new(String::from("postgres://localhost")))
        .manage(CacheState::new(String::from("redis://localhost")))
        // ❌ 두 번째 manage()가 무시됨! (둘 다 Mutex<String> 타입)
        .invoke_handler(tauri::generate_handler![
            get_db_connection,
            get_cache_connection
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**프론트엔드에서 호출:**

```typescript
// 둘 다 "postgres://localhost" 반환!
const db = await invoke('get_db_connection') // "postgres://localhost"
const cache = await invoke('get_cache_connection') // "postgres://localhost" (예상: "redis://localhost")
```

**문제:**
- `CacheState`가 등록되지 않음
- `get_cache_connection`이 `DatabaseState`를 반환
- 런타임 에러는 발생하지 않지만 잘못된 상태 사용

## ✅ 올바른 패턴

**컨테이너 구조체로 여러 상태 통합:**

```rust
// ✅ src-tauri/src/state.rs
use std::sync::Mutex;

pub struct AppStateInner {
    pub database_url: String,
    pub cache_url: String,
    pub api_key: String
}

pub type AppState = Mutex<AppStateInner>;

impl AppStateInner {
    pub fn new() -> Self {
        Self {
            database_url: String::from("postgres://localhost"),
            cache_url: String::from("redis://localhost"),
            api_key: String::from("secret")
        }
    }
}
```

```rust
// ✅ src-tauri/src/main.rs
mod state;

use state::{AppState, AppStateInner};
use tauri::State;

#[tauri::command]
fn get_db_connection(state: State<'_, AppState>) -> String {
    let state = state.lock().unwrap();
    state.database_url.clone()
}

#[tauri::command]
fn get_cache_connection(state: State<'_, AppState>) -> String {
    let state = state.lock().unwrap();
    state.cache_url.clone()
}

#[tauri::command]
fn get_api_key(state: State<'_, AppState>) -> String {
    let state = state.lock().unwrap();
    state.api_key.clone()
}

fn main() {
    tauri::Builder::default()
        .manage(AppState::new(AppStateInner::new())) // 단일 컨테이너 등록
        .invoke_handler(tauri::generate_handler![
            get_db_connection,
            get_cache_connection,
            get_api_key
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**newtype 패턴 (타입 래핑):**

```rust
// ✅ src-tauri/src/state.rs - newtype 패턴
use std::sync::Mutex;

// 각각 고유한 타입으로 래핑
pub struct DatabaseState(pub Mutex<String>);
pub struct CacheState(pub Mutex<String>);

impl DatabaseState {
    pub fn new(url: String) -> Self {
        Self(Mutex::new(url))
    }
}

impl CacheState {
    pub fn new(url: String) -> Self {
        Self(Mutex::new(url))
    }
}
```

```rust
// ✅ src-tauri/src/main.rs
mod state;

use state::{DatabaseState, CacheState};
use tauri::State;

#[tauri::command]
fn get_db_connection(db: State<'_, DatabaseState>) -> String {
    let db = db.0.lock().unwrap();
    db.clone()
}

#[tauri::command]
fn get_cache_connection(cache: State<'_, CacheState>) -> String {
    let cache = cache.0.lock().unwrap();
    cache.clone()
}

fn main() {
    tauri::Builder::default()
        .manage(DatabaseState::new(String::from("postgres://localhost")))
        .manage(CacheState::new(String::from("redis://localhost")))
        // ✅ 이제 각각 고유한 타입이므로 둘 다 등록됨
        .invoke_handler(tauri::generate_handler![
            get_db_connection,
            get_cache_connection
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## 추가 컨텍스트

**Tauri의 타입 기반 상태 시스템:**

```rust
// Tauri 내부적으로 TypeMap 사용
// TypeMap<TypeId, Box<dyn Any>>
// 각 타입당 하나의 값만 저장 가능

.manage(value1) // TypeId::of::<T>() → value1
.manage(value2) // TypeId::of::<T>() → value2 (value1 덮어쓰기 또는 무시)
```

**패턴 비교:**

| 패턴 | 장점 | 단점 | 권장 |
|------|------|------|------|
| **단일 컨테이너** | 단순, 명확 | 큰 구조체 | ✅ 대부분의 경우 |
| **Newtype** | 타입 안전 | 보일러플레이트 | ⚠️ 필요 시만 |
| **여러 manage()** | - | ❌ 작동 안함 | ❌ 사용 금지 |

**컨테이너 구조체 설계:**

```rust
// ✅ 도메인별 그룹화
pub struct AppStateInner {
    // 데이터베이스 관련
    pub db_pool: DatabasePool,
    pub db_url: String,

    // 캐시 관련
    pub cache_pool: CachePool,
    pub cache_url: String,

    // 인증 관련
    pub jwt_secret: String,
    pub api_key: String,

    // 설정 관련
    pub config: AppConfig
}
```

**env 변수 로드:**

```rust
use std::env;

impl AppStateInner {
    pub fn from_env() -> Self {
        Self {
            database_url: env::var("DATABASE_URL")
                .unwrap_or_else(|_| String::from("postgres://localhost")),
            cache_url: env::var("REDIS_URL")
                .unwrap_or_else(|_| String::from("redis://localhost")),
            api_key: env::var("API_KEY")
                .expect("API_KEY must be set"),
        }
    }
}

fn main() {
    tauri::Builder::default()
        .manage(AppState::new(AppStateInner::from_env()))
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**디버깅 팁:**

```rust
// State를 찾을 수 없을 때 런타임 에러
#[tauri::command]
fn test_command(state: State<'_, WrongType>) {
    // panic: no state of type `WrongType` is managed
}

// 등록된 상태 확인
println!("Registered state: {:?}", std::any::type_name::<AppState>());
```

**참고:**
- Tauri State Management: [Managing State](https://tauri.app/v2/guides/features/state-management/)
- Rust TypeId: [std::any::TypeId](https://doc.rust-lang.org/std/any/struct.TypeId.html)

**영향도:**
- 타입 안전성: MEDIUM (타입 충돌 방지)
- 버그 가능성: HIGH (잘못된 상태 사용 방지)
- 유지보수: HIGH (명확한 구조)
