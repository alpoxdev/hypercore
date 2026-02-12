# IPC Guide

> Inter-Process Communication 상세 가이드

---

## Commands (프론트엔드 → Rust)

```rust
// src-tauri/src/commands/mod.rs
use serde::{Deserialize, Serialize};
use tauri::State;
use std::sync::Mutex;

#[derive(Serialize, Deserialize)]
pub struct User {
    pub id: u32,
    pub name: String,
}

// 기본 Command
#[tauri::command]
fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}

// 비동기 Command + State
#[tauri::command]
async fn get_user(id: u32, db: State<'_, Mutex<Database>>) -> Result<User, String> {
    let db = db.lock().map_err(|e| e.to_string())?;
    db.find_user(id).ok_or("User not found".into())
}

// 에러 처리 (thiserror 권장)
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Not found: {0}")]
    NotFound(String),
    #[error("Internal error: {0}")]
    Internal(String),
}

impl serde::Serialize for AppError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where S: serde::Serializer {
        serializer.serialize_str(self.to_string().as_ref())
    }
}

#[tauri::command]
async fn delete_user(id: u32) -> Result<(), AppError> {
    // ...
    Err(AppError::NotFound(format!("User {} not found", id)))
}
```

```typescript
// 프론트엔드 invoke
import { invoke } from '@tauri-apps/api/core';

// 기본 호출
const greeting = await invoke<string>('greet', { name: 'World' });

// 타입 안전 호출
interface User { id: number; name: string; }
const user = await invoke<User>('get_user', { id: 1 });

// 에러 처리
try {
  await invoke('delete_user', { id: 999 });
} catch (error) {
  console.error('Command failed:', error);
}
```

---

## Events (양방향 통신)

```rust
// Rust → 프론트엔드 Event 발행
use tauri::{AppHandle, Emitter};

#[derive(Clone, Serialize)]
struct DownloadProgress {
    url: String,
    progress: f64,
}

fn download_file(app: AppHandle, url: String) {
    // 모든 윈도우에 Global Event
    app.emit("download-progress", DownloadProgress {
        url, progress: 0.5,
    }).unwrap();

    // 특정 윈도우에만
    app.emit_to("main", "download-complete", ()).unwrap();
}
```

```typescript
// 프론트엔드 Event 리스닝
import { listen, once } from '@tauri-apps/api/event';

// 지속 리스닝
const unlisten = await listen<{ url: string; progress: number }>(
  'download-progress',
  (event) => console.log(`${event.payload.url}: ${event.payload.progress * 100}%`)
);

// 단발 리스닝
await once('download-complete', () => console.log('Done!'));

// 리스너 해제
unlisten();
```

---

## Channels (고속 스트리밍)

```rust
use tauri::ipc::Channel;

#[tauri::command]
fn stream_data(channel: Channel<String>) {
    for i in 0..100 {
        channel.send(format!("chunk {}", i)).unwrap();
    }
}
```
