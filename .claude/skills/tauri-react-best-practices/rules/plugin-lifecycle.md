# setup/on_event/on_drop 라이프사이클 관리

## 왜 중요한가

Tauri 플러그인의 리소스(DB 연결, 파일 핸들, 소켓 등)를 제대로 초기화하고 정리하지 않으면 메모리 누수, 파일 잠금, 좀비 프로세스가 발생합니다. 플러그인 라이프사이클을 명확히 관리해야 앱 안정성을 보장할 수 있습니다.

## ❌ 잘못된 패턴

```rust
use tauri::{plugin::{Builder, TauriPlugin}, Runtime};

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("my-plugin")
        .invoke_handler(tauri::generate_handler![my_command])
        .build()
}

#[tauri::command]
fn my_command(db: State<Database>) -> Result<Vec<Item>, String> {
    // ❌ Database 초기화 없음
    // ❌ 앱 종료 시 DB 연결 정리 없음
    db.query_items().map_err(|e| e.to_string())
}
```

**문제점:**
- 리소스 초기화 로직 없음
- 앱 종료 시 cleanup 없음 (DB 연결 유지, 파일 잠금)
- 상태 관리 누락

## ✅ 올바른 패턴

```rust
use tauri::{
    plugin::{Builder, TauriPlugin},
    AppHandle, Manager, Runtime, State
};
use std::sync::Mutex;

pub struct Database {
    conn: Mutex<rusqlite::Connection>,
}

impl Database {
    fn new(path: &str) -> Result<Self, rusqlite::Error> {
        let conn = rusqlite::Connection::open(path)?;
        Ok(Database {
            conn: Mutex::new(conn),
        })
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("my-plugin")
        .invoke_handler(tauri::generate_handler![my_command])
        .setup(|app_handle, _api| {
            // ✅ 플러그인 초기화 시점
            let app_data = app_handle.path().app_data_dir().unwrap();
            let db_path = app_data.join("data.db");
            let db = Database::new(db_path.to_str().unwrap())
                .expect("Failed to init database");

            app_handle.manage(db);
            println!("Plugin initialized");

            Ok(())
        })
        .on_event(|app_handle, event| {
            // ✅ 앱 이벤트 핸들러
            match event {
                tauri::RunEvent::Exit => {
                    println!("App exiting, cleaning up...");
                }
                tauri::RunEvent::ExitRequested { .. } => {
                    println!("Exit requested");
                }
                _ => {}
            }
        })
        .build()
}

#[tauri::command]
fn my_command(db: State<Database>) -> Result<Vec<Item>, String> {
    // ✅ 초기화된 Database 사용
    let conn = db.conn.lock().unwrap();
    conn.query_items().map_err(|e| e.to_string())
}
```

**파일 핸들 정리 예시:**

```rust
use std::fs::File;
use std::sync::Mutex;

pub struct FileCache {
    handles: Mutex<HashMap<String, File>>,
}

impl FileCache {
    fn new() -> Self {
        FileCache {
            handles: Mutex::new(HashMap::new()),
        }
    }

    fn cleanup(&self) {
        let mut handles = self.handles.lock().unwrap();
        for (path, _file) in handles.drain() {
            println!("Closing file: {}", path);
        }
    }
}

impl Drop for FileCache {
    fn drop(&mut self) {
        // ✅ 자동 cleanup
        self.cleanup();
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("file-cache")
        .setup(|app_handle, _api| {
            app_handle.manage(FileCache::new());
            Ok(())
        })
        .on_event(|app_handle, event| {
            if let tauri::RunEvent::Exit = event {
                if let Some(cache) = app_handle.try_state::<FileCache>() {
                    cache.cleanup();
                }
            }
        })
        .build()
}
```

**비동기 리소스 정리 예시:**

```rust
use tokio::sync::RwLock;
use reqwest::Client;

pub struct ApiClient {
    client: Client,
    pending_requests: RwLock<Vec<tokio::task::JoinHandle<()>>>,
}

impl ApiClient {
    fn new() -> Self {
        ApiClient {
            client: Client::new(),
            pending_requests: RwLock::new(Vec::new()),
        }
    }

    async fn shutdown(&self) {
        let mut pending = self.pending_requests.write().await;
        for handle in pending.drain(..) {
            handle.abort();
        }
        println!("All pending requests aborted");
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("api-client")
        .setup(|app_handle, _api| {
            app_handle.manage(ApiClient::new());
            Ok(())
        })
        .on_event(|app_handle, event| {
            if let tauri::RunEvent::Exit = event {
                if let Some(client) = app_handle.try_state::<ApiClient>() {
                    tauri::async_runtime::block_on(client.shutdown());
                }
            }
        })
        .build()
}
```

**커스텀 플러그인 구조 템플릿:**

```rust
use tauri::{plugin::{Builder, TauriPlugin}, Runtime, AppHandle, Manager};

pub struct MyPluginState {
    // 플러그인 상태
}

impl MyPluginState {
    fn new() -> Self {
        // 초기화 로직
        Self {}
    }

    fn cleanup(&self) {
        // 정리 로직
    }
}

impl Drop for MyPluginState {
    fn drop(&mut self) {
        self.cleanup();
    }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("my-plugin")
        .invoke_handler(tauri::generate_handler![
            my_command_1,
            my_command_2
        ])
        .setup(|app_handle, _api| {
            // 플러그인 초기화
            let state = MyPluginState::new();
            app_handle.manage(state);
            Ok(())
        })
        .on_event(|app_handle, event| {
            // 이벤트 핸들러
            match event {
                tauri::RunEvent::Exit => {
                    if let Some(state) = app_handle.try_state::<MyPluginState>() {
                        state.cleanup();
                    }
                }
                _ => {}
            }
        })
        .build()
}

#[tauri::command]
fn my_command_1(state: State<MyPluginState>) -> Result<String, String> {
    // 커맨드 로직
    Ok("Success".to_string())
}
```

## 추가 컨텍스트

**라이프사이클 단계:**
1. `setup`: 플러그인 초기화 (앱 시작 시 한 번)
2. `invoke_handler`: 커맨드 실행 (프론트엔드 호출 시)
3. `on_event`: 앱 이벤트 처리 (Exit, ExitRequested 등)
4. `Drop`: 자동 정리 (플러그인 상태가 drop될 때)

**RunEvent 종류:**
- `Exit`: 앱 종료 직전
- `ExitRequested`: 앱 종료 요청 시 (취소 가능)
- `WindowEvent`: 윈도우 이벤트
- `Ready`: 앱 준비 완료

**Tauri State 관리:**
- `app_handle.manage()`: 전역 상태 등록
- `State<T>`: 커맨드에서 상태 접근
- `app_handle.try_state::<T>()`: 상태 가져오기 (Option)

**참고:** [Tauri Plugin Development](https://beta.tauri.app/develop/plugins/)

영향도: HIGH - 메모리 누수, 리소스 잠금, 앱 안정성
