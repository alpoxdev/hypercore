# CLAUDE.md - Tauri

> Cross-platform Desktop & Mobile App Framework

<context>

**Purpose:** Tauri v2 프레임워크로 데스크톱/모바일 크로스플랫폼 애플리케이션 개발을 위한 작업 지침

**Scope:** Rust 백엔드 + React + TypeScript + Vite 프론트엔드 기반 크로스플랫폼 앱 (iOS, Android, Windows, macOS)

**Key Features:**
- Rust 백엔드 + 시스템 WebView (작은 바이너리 사이즈)
- React + TypeScript + Vite 프론트엔드
- IPC (Commands + Events) 기반 프론트엔드-백엔드 통신
- Capabilities/Permissions 보안 모델
- Plugin 시스템 (데스크톱 + 모바일 네이티브 확장)
- iOS, Android, Windows, macOS, Linux 빌드

</context>

---

<instructions>
@docs/library/tauri/index.md
@docs/guides/getting-started.md
@docs/guides/mobile.md
@docs/guides/distribution.md
</instructions>

---

<forbidden>

| 분류 | 금지 행동 |
|------|----------|
| **보안** | Capabilities 없이 Command 노출, CSP 비활성화, `'unsafe-eval'` 무분별 사용 |
| **IPC** | 프론트엔드에서 Rust 함수 직접 호출 (invoke 사용), 민감 데이터 Event로 브로드캐스트 |
| **상태관리** | Arc 래핑 (State<T>가 내부 처리), 비동기 코드에서 await 걸쳐 Mutex lock 유지 |
| **모바일** | iOS 개발을 macOS 외 플랫폼에서 시도, Android 메인 스레드에서 블로킹 I/O |
| **빌드** | `--no-verify` 또는 보안 검증 우회, WebView2 설치 skip |
| **v1 API** | allowlist 사용 (capabilities 사용), `@tauri-apps/api/tauri` import (core 사용), Window 타입 (WebviewWindow 사용) |

</forbidden>

---

<required>

| 작업 | 필수 행동 |
|------|----------|
| **Command 정의** | `#[tauri::command]` 어노테이션, `tauri::generate_handler!` 등록 |
| **프론트엔드 호출** | `invoke()` from `@tauri-apps/api/core` 사용 |
| **보안** | Capabilities 파일 정의 (`src-tauri/capabilities/`), Permission 명시 |
| **상태관리** | `app.manage()` + `State<T>` 패턴, 가변 상태 → `Mutex<T>` |
| **모바일 빌드** | `tauri android init` / `tauri ios init` 먼저 실행 |
| **Plugin 사용** | Plugin별 Permission 추가 (`src-tauri/capabilities/`) |
| **타입 안전성** | Command 인자/반환 → `serde::Serialize`/`Deserialize` |
| **에러 처리** | Command → `Result<T, E>` 반환, Error 타입 직렬화 가능 |

</required>

---

<tech_stack>

| 기술 | 버전 | 주의 |
|------|------|------|
| Tauri | 2.x | CLI: @tauri-apps/cli@latest |
| Rust | stable | MSVC 툴체인 (Windows) |
| React | 19.x | - |
| TypeScript | 5.x | strict |
| Vite | 6.x | strictPort: true |
| @tauri-apps/api | 2.x | core, webviewWindow |

</tech_stack>

---

<structure>
```
my-tauri-app/
├── src/                    # React + TypeScript 프론트엔드
│   ├── App.tsx
│   ├── main.tsx
│   └── components/
├── src-tauri/              # Rust 백엔드
│   ├── src/
│   │   ├── main.rs         # 앱 엔트리, Command 등록
│   │   ├── lib.rs          # 라이브러리 (모바일 지원)
│   │   └── commands/       # Command 모듈
│   ├── capabilities/       # 보안 Capabilities
│   │   └── default.json
│   ├── Cargo.toml
│   ├── tauri.conf.json     # Tauri 설정
│   ├── tauri.android.conf.json  # Android 설정
│   └── tauri.ios.conf.json      # iOS 설정
├── package.json
├── vite.config.ts
└── tsconfig.json
```
</structure>

---

<conventions>

파일명: kebab-case (TS), snake_case (Rust)
Command: snake_case (Rust) → camelCase (JS invoke)
Config: `tauri.conf.json` (메인), `tauri.[platform].conf.json` (플랫폼별)
Capabilities: `src-tauri/capabilities/` (JSON/TOML)
Permissions: `<plugin>:allow-<command>`, `<plugin>:deny-<command>`

</conventions>

---

<quick_patterns>

```rust
// Rust Command 정의
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

// main.rs에 등록
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .setup(|app| {
            app.manage(Mutex::new(AppState { counter: 0 }));
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![greet, increment])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```typescript
// 프론트엔드 invoke
import { invoke } from '@tauri-apps/api/core';

const greeting = await invoke<string>('greet', { name: 'World' });

// Event 리스닝
import { listen } from '@tauri-apps/api/event';
const unlisten = await listen<string>('download-progress', (event) => {
  console.log(event.payload);
});
```

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "기본 앱 권한",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:allow-open"
  ]
}
```

</quick_patterns>

---

<docs_structure>
```
docs/
├── guides/
│   ├── getting-started.md   # 설치, 프로젝트 생성, 개발 시작
│   ├── mobile.md            # iOS/Android 개발 가이드
│   └── distribution.md      # 빌드, 코드 서명, 배포
└── library/
    └── tauri/
        └── index.md         # Tauri 핵심 API + IPC + Security
```
</docs_structure>
