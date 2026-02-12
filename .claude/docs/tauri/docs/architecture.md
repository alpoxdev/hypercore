# Architecture

> Tauri v2 애플리케이션 아키텍처

<instructions>
@references/async-execution.md
@references/error-handling.md
@references/security-model.md
@references/state-management.md
@references/mobile-architecture.md
@references/data-flow.md
@references/tech-stack.md
@../guides/getting-started.md
@../guides/mobile.md
@../guides/distribution.md
@../library/tauri/index.md
</instructions>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **IPC** | Rust 함수 직접 FFI 호출 (invoke 사용) |
| **IPC** | async command에 &str 인자 (String 변환 필수) |
| **보안** | Capabilities 없이 Command 노출 |
| **보안** | CSP 비활성화, `'unsafe-eval'` 무분별 사용 |
| **보안** | CDN에서 원격 스크립트 로드 |
| **상태** | State<T>에 Arc 래핑 (내부 처리) |
| **상태** | async에서 await 걸쳐 Mutex lock 유지 |
| **모바일** | iOS 개발을 macOS 외 플랫폼에서 시도 |
| **모바일** | Android 메인 스레드에서 블로킹 I/O |
| **v1 API** | allowlist 사용 (capabilities 사용) |
| **v1 API** | `@tauri-apps/api/tauri` import (core 사용) |
| **v1 API** | Window 타입 (WebviewWindow 사용) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **Command** | `#[tauri::command]` 어노테이션 |
| **Command** | `tauri::generate_handler![]` 등록 |
| **Command** | `Result<T, E>` 반환, E 직렬화 가능 |
| **Command** | `serde::Serialize/Deserialize` 인자/반환값 |
| **IPC** | `invoke()` from `@tauri-apps/api/core` |
| **IPC** | camelCase 인자 (Rust snake_case 자동 변환) |
| **보안** | Capabilities 파일 정의 (`src-tauri/capabilities/`) |
| **보안** | Plugin Permission 명시 |
| **보안** | CSP 설정 (`tauri.conf.json > app > security`) |
| **상태** | `app.manage()` + `State<'_, T>` 패턴 |
| **상태** | 가변 상태 → `Mutex<T>` |
| **모바일** | `lib.rs` 엔트리포인트 (라이브러리 로드) |
| **Config** | identifier 역도메인 형식 |

</required>

---

<system_overview>

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      Frontend (WebView)                          │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │   React/Vue    │───▶│  @tauri-apps/  │───▶│    WebView    │  │
│  │   Framework    │◀───│   api/core     │◀───│   Renderer    │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
│                                │ invoke() / listen()             │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      IPC Bridge (Trust Boundary)                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  JSON-RPC Serialization | Capabilities Check | CSP Filter  │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────────┼────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Tauri Core (Rust)                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Commands | Events | Channels                   │ │
│  │              State<T> | Mutex<T> | app.manage()            │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                      Plugins Layer                          │ │
│  │     shell | fs | dialog | http | store | notification      │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    tauri-runtime (TAO + WRY)                │ │
│  │   Window Management (TAO) | WebView Rendering (WRY)        │ │
│  └────────────────────────────┬───────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Operating System                         │
│  Windows (WebView2) | macOS (WKWebView) | Linux (webkitgtk)     │
│  Android (WebView)  | iOS (WKWebView)                           │
└─────────────────────────────────────────────────────────────────┘
```

</system_overview>

---

<folder_structure>

## Folder Structure

```
my-tauri-app/
├── src/                         # 프론트엔드 (React + TypeScript)
│   ├── main.tsx                 # React 엔트리
│   ├── App.tsx                  # 루트 컴포넌트
│   ├── components/              # UI 컴포넌트
│   ├── hooks/                   # Custom Hooks
│   ├── stores/                  # Zustand 스토어
│   └── lib/                     # 유틸리티
├── src-tauri/                   # 백엔드 (Rust)
│   ├── src/
│   │   ├── main.rs              # 데스크톱 엔트리
│   │   ├── lib.rs               # 공유 로직 (모바일 지원)
│   │   ├── commands/            # Command 모듈
│   │   └── error.rs             # 에러 타입 정의
│   ├── capabilities/            # 보안 Capabilities
│   ├── gen/                     # 플랫폼 코드 (apple/, android/)
│   ├── Cargo.toml               # Rust 의존성
│   ├── tauri.conf.json          # Tauri 메인 설정
│   └── tauri.[platform].conf.json  # 플랫폼별 설정
├── package.json
└── vite.config.ts
```

| 폴더 | 역할 |
|------|------|
| **src/** | 프론트엔드 UI |
| **src-tauri/src/commands/** | Rust Command 정의 |
| **src-tauri/capabilities/** | 보안 권한 설정 |
| **src-tauri/gen/** | 플랫폼별 생성 코드 |

</folder_structure>

---

<process_model>

## Process Model

> Tauri는 **Single-Process Multi-Thread Architecture** 사용 (Electron과 다름)

**Electron과의 차이:**
- Electron: Main Process + Renderer Process (별도 프로세스)
- Tauri: **단일 프로세스** 내에서 Rust Core와 WebView가 **별도 스레드**로 실행
- IPC는 프로세스 간 통신이 아닌 **스레드 간 통신** → 더 빠르고 메모리 효율적

```
┌─────────────────┐     ┌─────────────────┐
│   Main Thread   │     │ WebView Thread  │
│   (Full Trust)  │◄───►│ (Sandboxed)     │
│                 │ IPC │                 │
│  • System API   │     │  • UI Only      │
│  • File I/O     │     │  • No Direct    │
│  • Network      │     │    System       │
│  • State        │     │    Access       │
└─────────────────┘     └─────────────────┘
     (Rust Core)           (WebView)
```

| 이점 | 설명 |
|------|------|
| **보안** | WebView Sandbox + CSP로 XSS → 시스템 접근 차단 |
| **성능** | 메모리 효율 (Electron 대비 1/10), 스레드 통신이 프로세스 통신보다 빠름 |
| **메모리** | 단일 프로세스로 중복 메모리 할당 없음 |

</process_model>

---

<ipc_architecture>

## IPC Architecture

| 원칙 | 설명 |
|------|------|
| **Asynchronous Message Passing** | 직접 함수 호출 대신 메시지 전달 |
| **JSON-RPC Serialization** | 모든 데이터 JSON 직렬화 |
| **Trust Boundary** | WebView → Core 요청은 Capabilities 검증 |

### Commands (프론트엔드 → Rust)

```
Frontend ──invoke()──▶ IPC Bridge ──handler──▶ Command ──▶ State/DB
    ◀──Result<T>─────────────────────────────────────────────────┘
```

```typescript
const user = await invoke<User>('get_user', { id: 1 });
```

```rust
#[tauri::command]
async fn get_user(id: u32, state: State<'_, Db>) -> Result<User, AppError> {
    state.find_user(id).await
}
```

### Events (양방향 통신)

- **Fire-and-forget**: 응답 없음, 단방향
- **Lifecycle/State 변경**: 진행률, 상태 업데이트
- **양방향**: Frontend ↔ Rust 모두 emit/listen 가능

### Channels (고속 스트리밍)

- **대용량 데이터**: 파일 다운로드, 실시간 로그
- **단방향 스트림**: Rust → Frontend
- **고성능**: Events보다 빠름, 대량 메시지에 적합

**Details:** @references/async-execution.md, @references/error-handling.md

</ipc_architecture>

---

<quick_patterns>

## Quick Patterns

```rust
// Command 정의
#[tauri::command]
async fn greet(name: String) -> Result<String, String> {
    Ok(format!("Hello, {}!", name))
}

// State 사용
#[tauri::command]
async fn increment(state: State<'_, Mutex<AppState>>) -> Result<u32, String> {
    let mut s = state.lock().unwrap();
    s.counter += 1;
    Ok(s.counter)
}

// main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            app.manage(Mutex::new(AppState { counter: 0 }));
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![greet, increment])
        .run(tauri::generate_context!())
        .expect("error");
}
```

```typescript
// 프론트엔드
import { invoke } from '@tauri-apps/api/core';
const greeting = await invoke<string>('greet', { name: 'World' });

import { listen } from '@tauri-apps/api/event';
const unlisten = await listen<string>('download-progress', (e) => console.log(e.payload));
```

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "windows": ["main"],
  "permissions": ["core:default", "shell:allow-open"]
}
```

</quick_patterns>

---

<references_index>

## References

| 문서 | 내용 |
|------|------|
| **@references/async-execution.md** | Tokio runtime, async vs sync command |
| **@references/error-handling.md** | 에러 타입, 전파 메커니즘 |
| **@references/security-model.md** | Trust Boundary, Capabilities, CSP |
| **@references/state-management.md** | Mutex 선택, await lock 패턴 |
| **@references/mobile-architecture.md** | 엔트리포인트, Plugin 구조 |
| **@references/data-flow.md** | Command/Event/Plugin 데이터 흐름 |
| **@references/tech-stack.md** | 기술 스택, WebView 엔진 |

</references_index>
