# Tauri

> **Version 2.x** | Cross-platform Desktop & Mobile Application Framework

---

<context>

**Purpose:** Rust 백엔드 + 시스템 WebView 기반 크로스플랫폼 앱 프레임워크
**Generated:** 2026-02-09
**Source:** https://tauri.app, https://v2.tauri.app, https://github.com/tauri-apps/tauri

**Key Features:**
- 시스템 WebView 활용 (최소 600KB 바이너리)
- Rust 메모리/타입 안전성 기반 보안
- Commands + Events IPC 시스템
- Capabilities/Permissions 보안 모델
- Plugin 시스템 (네이티브 확장)
- 데스크톱 (Windows, macOS, Linux) + 모바일 (iOS, Android) 지원

</context>

---

<forbidden>

| 분류 | ❌ 금지 | 이유 |
|------|---------|------|
| **v1 API** | `@tauri-apps/api/tauri` import | `@tauri-apps/api/core` 사용 |
| **v1 API** | `Window` 타입 | `WebviewWindow` 사용 |
| **v1 API** | `get_window()` | `get_webview_window()` 사용 |
| **v1 API** | allowlist 설정 | Capabilities/Permissions 사용 |
| **v1 API** | `.validator()` | v2에서 제거됨 |
| **보안** | Permission 없이 Command 노출 | Capabilities 필수 |
| **보안** | CSP 비활성화 | 항상 CSP 설정 |
| **보안** | `'unsafe-eval'` 무분별 사용 | WASM만 `'wasm-unsafe-eval'` 허용 |
| **보안** | CDN에서 원격 스크립트 로드 | 공격 벡터, 로컬 번들 사용 |
| **IPC** | Rust 함수 직접 FFI 호출 | `invoke()` 메시지 패싱 사용 |
| **IPC** | async command에 &str 인자 | `String`으로 변환 필수 |
| **상태** | `State<T>`에 Arc 래핑 | Tauri가 내부적으로 처리 |
| **상태** | async에서 await 걸쳐 Mutex lock | 데드락 위험, 표준 Mutex 사용 |
| **Plugin** | v1 built-in API 직접 사용 | v2 plugin으로 설치 필요 |

</forbidden>

---

<required>

| 분류 | ✅ 필수 | 상세 |
|------|---------|------|
| **Command** | `#[tauri::command]` 어노테이션 | 모든 프론트엔드 호출 함수 |
| **Command** | `tauri::generate_handler![]` 등록 | Builder에 핸들러 등록 |
| **Command** | `serde::Serialize/Deserialize` | 인자/반환값 직렬화 필수 |
| **Command** | `Result<T, E>` 반환 | E도 직렬화 가능해야 함 |
| **IPC** | `invoke()` 사용 | `@tauri-apps/api/core`에서 import |
| **IPC** | camelCase 인자 | Rust snake_case → JS camelCase 자동 변환 |
| **보안** | Capabilities 파일 정의 | `src-tauri/capabilities/` |
| **보안** | Plugin Permission 추가 | 사용하는 모든 plugin에 대해 |
| **보안** | CSP 설정 | `tauri.conf.json > app > security > csp` |
| **상태** | `app.manage()` 등록 | setup 내에서 상태 등록 |
| **상태** | `State<'_, T>` 매개변수 | Command에서 상태 접근 |
| **상태** | 가변 상태 → `Mutex<T>` | 스레드 안전 보장 |
| **모바일** | lib.rs 엔트리포인트 | 모바일은 라이브러리로 로드 |
| **Config** | `identifier` 설정 | 역도메인 형식 (com.example.app) |

</required>

---

<setup>

## 설치

```bash
# 새 프로젝트 생성 (React + TypeScript + Vite)
npm create tauri-app@latest -- --template react-ts

# 기존 Vite 프로젝트에 추가
npm add -D @tauri-apps/cli@latest
npx tauri init
```

## Prerequisites

**모든 플랫폼:**
- Rust (rustup 설치)
- Node.js

**macOS:**
- Xcode Command Line Tools

**Windows:**
- Microsoft C++ Build Tools (Desktop development with C++)
- WebView2 Runtime (Windows 10 v1803+ 기본 포함)

**Linux:**
- webkit2gtk, build-essential, libssl-dev, librsvg2-dev

## 초기 설정

```json
// src-tauri/tauri.conf.json
{
  "productName": "my-app",
  "identifier": "com.example.myapp",
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:5173",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [{ "title": "My App", "width": 1024, "height": 768 }],
    "security": {
      "csp": {
        "default-src": "'self' customprotocol: asset:",
        "connect-src": "ipc: http://ipc.localhost",
        "img-src": "'self' asset: http://asset.localhost blob: data:",
        "style-src": "'unsafe-inline' 'self'"
      }
    }
  }
}
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const host = process.env.TAURI_DEV_HOST;

export default defineConfig({
  plugins: [react()],
  clearScreen: false,
  server: {
    port: 5173,
    strictPort: true,
    host: host || false,
    hmr: host ? { protocol: 'ws', host, port: 1421 } : undefined,
    watch: { ignored: ['**/src-tauri/**'] },
  },
  envPrefix: ['VITE_', 'TAURI_ENV_*'],
  build: {
    target: process.env.TAURI_ENV_PLATFORM === 'windows' ? 'chrome105' : 'safari13',
    minify: !process.env.TAURI_ENV_DEBUG ? 'esbuild' : false,
    sourcemap: !!process.env.TAURI_ENV_DEBUG,
  },
});
```

</setup>

---

## IPC (Inter-Process Communication)

### Commands (프론트엔드 → Rust)

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

### Events (양방향 통신)

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

### Channels (고속 스트리밍)

```rust
use tauri::ipc::Channel;

#[tauri::command]
fn stream_data(channel: Channel<String>) {
    for i in 0..100 {
        channel.send(format!("chunk {}", i)).unwrap();
    }
}
```

---

## Security (보안)

### Capabilities

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "메인 윈도우 기본 권한",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "core:window:allow-set-title",
    "core:window:allow-close",
    "shell:allow-open"
  ]
}
```

```json
// 플랫폼별 Capability
{
  "identifier": "mobile-features",
  "description": "모바일 전용 권한",
  "windows": ["main"],
  "platforms": ["iOS", "android"],
  "permissions": [
    "nfc:default",
    "biometric:default"
  ]
}
```

### Permission 패턴

```
core:default                    # Core 기본 권한
core:window:allow-<command>     # Window 개별 허용
core:event:allow-listen         # Event 리스닝 허용
<plugin>:default                # Plugin 기본 권한
<plugin>:allow-<command>        # Plugin 개별 허용
<plugin>:deny-<command>         # Plugin 개별 거부
```

### CSP 설정

```json
// tauri.conf.json > app > security > csp
{
  "default-src": "'self' customprotocol: asset:",
  "connect-src": "ipc: http://ipc.localhost",
  "font-src": ["https://fonts.gstatic.com"],
  "img-src": "'self' asset: http://asset.localhost blob: data:",
  "style-src": "'unsafe-inline' 'self'"
}
```

---

## State Management (상태 관리)

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

**규칙:**
- Arc 불필요 (State<T>가 내부 처리)
- 가변 상태 → `Mutex<T>` (std::sync::Mutex 권장)
- 비동기 코드에서 await 포인트 넘어 lock 유지 금지
- 잘못된 타입 접근 → 런타임 패닉 (타입 별칭 권장)

---

## Plugins (v2)

### v1 Built-in → v2 Plugin 전환

| 기능 | v2 Plugin 패키지 |
|------|-----------------|
| Clipboard | `@tauri-apps/plugin-clipboard-manager` |
| Dialog | `@tauri-apps/plugin-dialog` |
| File System | `@tauri-apps/plugin-fs` |
| HTTP | `@tauri-apps/plugin-http` |
| Shell | `@tauri-apps/plugin-shell` |
| Process | `@tauri-apps/plugin-process` |
| OS Info | `@tauri-apps/plugin-os` |
| Store | `@tauri-apps/plugin-store` |
| Notification | `@tauri-apps/plugin-notification` |
| Global Shortcut | `@tauri-apps/plugin-global-shortcut` |

### Plugin 사용 패턴

```bash
# 설치 (Rust + JS 바인딩)
npm add @tauri-apps/plugin-shell
cargo add tauri-plugin-shell -F tauri-plugin-shell/build
```

```rust
// main.rs에 등록
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .unwrap();
}
```

```json
// capabilities에 Permission 추가
{
  "permissions": ["shell:allow-open"]
}
```

---

## Configuration

### 플랫폼별 설정

```
src-tauri/
├── tauri.conf.json              # 공통 설정
├── tauri.windows.conf.json      # Windows 오버라이드
├── tauri.macos.conf.json        # macOS 오버라이드
├── tauri.linux.conf.json        # Linux 오버라이드
├── tauri.android.conf.json      # Android 오버라이드
└── tauri.ios.conf.json          # iOS 오버라이드
```

### 핵심 설정 필드

```json
{
  "productName": "My App",
  "version": "1.0.0",
  "identifier": "com.example.myapp",
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:5173",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [{ "title": "My App", "width": 1024, "height": 768 }],
    "security": { "csp": "..." }
  },
  "bundle": {
    "active": true,
    "targets": ["deb", "rpm", "appimage", "msi", "nsis", "dmg", "app"],
    "icon": ["icons/32x32.png", "icons/icon.icns", "icons/icon.ico"],
    "android": { "minSdkVersion": 24 },
    "macOS": { "minimumSystemVersion": "10.13" }
  }
}
```

---

<quick_reference>

```rust
// Command 기본 패턴
#[tauri::command]
async fn my_command(arg: String, state: State<'_, Mutex<AppState>>) -> Result<MyResponse, MyError> {
    let s = state.lock().map_err(|e| MyError::Lock(e.to_string()))?;
    Ok(MyResponse { data: s.process(arg) })
}
```

```typescript
// invoke 기본 패턴
const result = await invoke<ResponseType>('my_command', { arg: 'value' });
```

```json
// Capability 기본 패턴
{ "identifier": "main", "windows": ["main"], "permissions": ["core:default", "plugin:allow-command"] }
```

</quick_reference>

---

<version_info>

**Version:** 2.x (현재 2.10.x)
**CLI Package:** @tauri-apps/cli
**API Package:** @tauri-apps/api
**Rust Crate:** tauri

**v1 → v2 Breaking Changes:**
- Config: `tauri {}` → `app {}`, `build.distDir` → `frontendDist`, `build.devPath` → `devUrl`
- API: `@tauri-apps/api/tauri` → `@tauri-apps/api/core`
- Window: `Window` → `WebviewWindow`, `get_window()` → `get_webview_window()`
- Security: allowlist → Capabilities/Permissions 시스템
- Plugins: 모든 시스템 API가 별도 plugin으로 분리
- Events: source-based → target-based 필터링

</version_info>
