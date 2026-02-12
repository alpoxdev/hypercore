# Tauri

> **Version 2.x** | Cross-platform Desktop & Mobile Application Framework

<instructions>
@references/ipc-guide.md
@references/security-guide.md
@references/state-guide.md
@references/plugins-guide.md
@references/configuration.md
</instructions>

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
| **보안** | Permission 없이 Command 노출 | Capabilities 필수 |
| **보안** | CSP 비활성화 | 항상 CSP 설정 |
| **보안** | `'unsafe-eval'` 무분별 사용 | WASM만 `'wasm-unsafe-eval'` 허용 |
| **IPC** | Rust 함수 직접 FFI 호출 | `invoke()` 메시지 패싱 사용 |
| **IPC** | async command에 &str 인자 | `String`으로 변환 필수 |
| **상태** | `State<T>`에 Arc 래핑 | Tauri가 내부적으로 처리 |
| **상태** | async에서 await 걸쳐 Mutex lock | 데드락 위험 |

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

**모든 플랫폼:** Rust (rustup), Node.js

**macOS:** Xcode Command Line Tools

**Windows:** Microsoft C++ Build Tools, WebView2 Runtime

**Linux:** webkit2gtk, build-essential, libssl-dev, librsvg2-dev

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

</setup>

---

<quick_reference>

## Quick Reference

### Command 기본 패턴

```rust
#[tauri::command]
async fn my_command(arg: String, state: State<'_, Mutex<AppState>>) -> Result<MyResponse, MyError> {
    let s = state.lock().map_err(|e| MyError::Lock(e.to_string()))?;
    Ok(MyResponse { data: s.process(arg) })
}
```

### invoke 기본 패턴

```typescript
import { invoke } from '@tauri-apps/api/core';
const result = await invoke<ResponseType>('my_command', { arg: 'value' });
```

### Capability 기본 패턴

```json
{ "identifier": "main", "windows": ["main"], "permissions": ["core:default", "plugin:allow-command"] }
```

### Event 리스닝

```typescript
import { listen } from '@tauri-apps/api/event';
const unlisten = await listen<PayloadType>('event-name', (e) => console.log(e.payload));
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

</version_info>

---

<references_index>

## References

| 문서 | 내용 |
|------|------|
| **@references/ipc-guide.md** | Commands, Events, Channels 상세 |
| **@references/security-guide.md** | Capabilities, CSP 상세 |
| **@references/state-guide.md** | State 패턴, Mutex 규칙 |
| **@references/plugins-guide.md** | v2 Plugin 목록, 사용법 |
| **@references/configuration.md** | 플랫폼별 설정 상세 |

</references_index>
