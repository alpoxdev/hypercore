---
name: tauri-react-best-practices
description: Tauri v2와 React 성능 최적화 가이드. Tauri 데스크톱/모바일 앱의 IPC, 보안, 번들 최적화, 상태 관리 패턴 보장. React 컴포넌트, Tauri Commands, 플러그인, 배포 작업에 트리거.
license: MIT
framework: tauri-v2
metadata:
  author: tauri-community
  version: "1.0.0"
  adapted_for: tauri-v2-react
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md
@../../instructions/multi-agent/coordination-guide.md
@../../instructions/multi-agent/execution-patterns.md

# Tauri v2 React 베스트 프랙티스

Tauri v2 + React 19 데스크톱/모바일 애플리케이션 성능 및 보안 최적화 가이드. 8개 카테고리, 40+ 규칙 포함. IPC 최적화(Commands, Events, Channels), 보안(Capabilities, Permissions, Scopes), 번들 크기 최소화, 상태 관리, 플러그인 패턴, 배포 최적화 등 Tauri 특화 패턴 반영.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| **Tauri Command 작성** | Rust 명령 정의, invoke 호출, 에러 처리 |
| **IPC 패턴 구현** | Commands, Events, Channels 통신 패턴 |
| **보안 설정** | Capabilities, Permissions, Scopes 구성 |
| **번들 최적화** | 앱 크기 감소, Cargo 프로필 최적화 |
| **상태 관리** | Rust 상태 + React 상태 통합 |
| **플러그인 사용** | 공식/커스텀 플러그인 통합 |
| **배포** | 빌드, 코드 서명, 자동 업데이트 |
| **React 성능** | Re-render 최적화, 번들 스플리팅 |

</when_to_use>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "tauri-team", description: "Tauri + React 최적화" })
Task(subagent_type="general-purpose", team_name="tauri-team", name="optimizer", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## 병렬 에이전트 실행

**ULTRAWORK MODE:** Tauri + React 최적화 작업 시 여러 규칙을 동시에 적용.

### 기본 원칙

| 원칙 | 실행 방법 | 효과 |
|------|----------|------|
| **PARALLEL** | 독립 작업을 단일 메시지에서 동시 실행 | 5-15배 속도 향상 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | 품질 향상, 컨텍스트 격리 |
| **SMART MODEL** | 복잡도별 모델 선택 (haiku/sonnet/opus) | 비용 최적화 |

### Phase별 에이전트 활용

| Phase | 작업 | 에이전트 | 병렬 실행 |
|-------|------|---------|----------|
| **1. 코드베이스 분석** | Rust commands, React 컴포넌트, capabilities 파악 | explore (haiku) | O |
| **2. 규칙 적용** | IPC 최적화, 보안 강화, 번들 최적화 | implementation-executor (sonnet) | O |
| **3. 검증** | typecheck/lint/build, 보안 리뷰 | lint-fixer (sonnet), code-reviewer (opus) | lint 순차, review 병렬 |
| **4. 완료** | git commit | git-operator (sonnet) | 순차 |

### 에이전트별 역할

| 에이전트 | 모델 | Tauri 작업 | 병렬 실행 |
|---------|------|-----------|----------|
| **explore** | haiku | Rust commands/상태/capabilities 구조 분석 | O |
| **implementation-executor** | sonnet | IPC 최적화, 보안 설정, 번들 최적화 | O |
| **code-reviewer** | opus | 보안/성능 검토 | O |
| **lint-fixer** | sonnet | tsc/eslint/clippy 에러 수정 | 순차 |

### Model Routing

| 복잡도 | 모델 | Tauri 작업 예시 |
|--------|------|---------------|
| **LOW** | haiku | 파일 구조 파악, capabilities 확인 |
| **MEDIUM** | sonnet | IPC 패턴 적용, 플러그인 통합, 번들 최적화 |
| **HIGH** | opus | 보안 아키텍처 설계, 멀티 윈도우 IPC 전략 |

</parallel_agent_execution>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 접두사 |
|---------|---------|--------|--------|
| 1 | IPC 최적화 | **CRITICAL** | `ipc-` |
| 2 | 보안 설정 | **CRITICAL** | `security-` |
| 3 | 번들 크기 최적화 | **HIGH** | `bundle-` |
| 4 | Tauri 상태 관리 | HIGH | `state-` |
| 5 | React 통합 패턴 | MEDIUM-HIGH | `react-` |
| 6 | 플러그인 패턴 | MEDIUM | `plugin-` |
| 7 | 배포 최적화 | MEDIUM | `deploy-` |
| 8 | Re-render/JS 성능 | LOW-MEDIUM | `perf-` |

</categories>

---

<rules>

## 빠른 참조

### 1. IPC 최적화 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `ipc-batch-commands` | 여러 invoke를 하나의 배치 커맨드로 통합 |
| `ipc-channel-streaming` | 대용량 데이터는 Channel 사용 (Events 대신) |
| `ipc-async-commands` | Rust 커맨드는 async로 비차단 실행 |
| `ipc-binary-response` | 바이너리 데이터는 Response로 JSON 직렬화 우회 |
| `ipc-type-safe` | tauri-specta로 TypeScript 바인딩 자동 생성 |
| `ipc-error-handling` | 구조화된 에러 타입 (thiserror + serde) |

### 2. 보안 설정 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `security-least-privilege` | 최소 권한 원칙, 필요한 커맨드만 허용 |
| `security-scope-paths` | 파일 경로 Scope 제한 ($APPDATA 등) |
| `security-capability-split` | 윈도우별 Capability 분리 |
| `security-csp` | Content Security Policy 설정 |
| `security-no-wildcard` | 와일드카드 권한/경로 사용 금지 |

### 3. 번들 크기 최적화 (HIGH)

| 규칙 | 설명 |
|------|------|
| `bundle-cargo-profile` | Cargo release 프로필 (lto, codegen-units=1, strip) |
| `bundle-remove-unused-commands` | 미사용 커맨드 자동 제거 (v2.4+) |
| `bundle-barrel-imports` | 직접 import, barrel 파일 회피 |
| `bundle-lazy-components` | 무거운 컴포넌트 lazy() 로드 |
| `bundle-frontend-treeshake` | 프론트엔드 tree-shaking 확인 |

### 4. Tauri 상태 관리 (HIGH)

| 규칙 | 설명 |
|------|------|
| `state-mutex-pattern` | Mutex로 가변 상태 관리, 타입 별칭 사용 |
| `state-single-container` | 동일 타입 중복 등록 방지, 컨테이너로 통합 |
| `state-async-mutex` | IO 리소스만 Tokio Mutex, 나머지는 std Mutex |
| `state-react-sync` | Rust 상태와 React 상태 동기화 패턴 |

### 5. React 통합 패턴 (MEDIUM-HIGH)

| 규칙 | 설명 |
|------|------|
| `react-invoke-hook` | useEffect + invoke 패턴, 정리(cleanup) 필수 |
| `react-event-listener` | listen/unlisten 라이프사이클 관리 |
| `react-file-src` | convertFileSrc()로 로컬 파일 직접 렌더링 |
| `react-error-boundary` | invoke 실패에 대한 에러 바운더리 |
| `react-optimistic-update` | useOptimistic으로 IPC 대기 시간 마스킹 |

### 6. 플러그인 패턴 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `plugin-permission-scope` | 플러그인별 최소 권한 + Scope 설정 |
| `plugin-lifecycle` | setup/on_event/on_drop 라이프사이클 관리 |
| `plugin-mobile-compat` | 모바일 호환성 확인 (Android/iOS) |

### 7. 배포 최적화 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `deploy-signing` | 코드 서명 필수 (macOS/Windows) |
| `deploy-updater` | 자동 업데이트 서명 키 관리 |
| `deploy-ci-pipeline` | GitHub Actions 멀티 플랫폼 빌드 |

### 8. Re-render/JS 성능 (LOW-MEDIUM)

| 규칙 | 설명 |
|------|------|
| `perf-functional-setstate` | 함수형 setState로 안정적 콜백 |
| `perf-lazy-state-init` | 비싼 초기값은 함수로 useState에 전달 |
| `perf-derived-state` | 파생 boolean 구독, raw 값 구독 회피 |
| `perf-index-maps` | 반복 조회용 Map 빌드 |

</rules>

---

<patterns>

## 핵심 패턴

### IPC 최적화: 배치 커맨드

```rust
// ❌ 프론트엔드에서 N번 호출
// for (item of items) await invoke('process', { item })

// ✅ 배치 처리 (1번 호출)
#[tauri::command]
fn process_batch(items: Vec<String>) -> Result<Vec<String>, String> {
  items.iter().map(|item| process_item(item)).collect()
}
```

### IPC 최적화: Channel 스트리밍

```rust
use tauri::ipc::Channel;

// ❌ Events로 대용량 스트리밍 (느림)
#[tauri::command]
async fn download(app: AppHandle, url: String) {
  for chunk in download_stream(&url) {
    app.emit("progress", chunk).unwrap();
  }
}

// ✅ Channel로 스트리밍 (빠름)
#[tauri::command]
async fn download(url: String, on_progress: Channel<u32>) -> Result<(), String> {
  for (i, _chunk) in download_stream(&url).enumerate() {
    on_progress.send(i as u32).unwrap();
  }
  Ok(())
}
```

```typescript
// JavaScript
import { invoke, Channel } from '@tauri-apps/api/core';

const onProgress = new Channel<number>();
onProgress.onmessage = (bytes) => updateProgressBar(bytes);
await invoke('download', { url, onProgress });
```

### IPC 최적화: 바이너리 응답

```rust
use tauri::ipc::Response;

// ❌ JSON 직렬화 (느림, 크기 증가)
#[tauri::command]
fn get_image() -> Result<Vec<u8>, String> {
  std::fs::read("/path/to/image.png").map_err(|e| e.to_string())
}

// ✅ Raw 바이너리 응답 (직렬화 우회)
#[tauri::command]
fn get_image() -> Result<Response, String> {
  let bytes = std::fs::read("/path/to/image.png").map_err(|e| e.to_string())?;
  Ok(Response::new(bytes))
}
```

### 보안: 최소 권한 Capability

```json
{
  "identifier": "main-window",
  "description": "메인 윈도우 최소 권한",
  "windows": ["main"],
  "permissions": [
    "core:window:allow-close",
    "core:window:allow-minimize",
    "fs:allow-read"
  ]
}
```

```toml
# ❌ 와일드카드 (위험)
[[scope.allow]]
path = "/*"

# ✅ 특정 경로만 (안전)
[[scope.allow]]
path = "$APPDATA/my-app/data/**"

[[scope.deny]]
path = "$HOME/.ssh/**"
```

### 상태 관리: Mutex + 타입 별칭

```rust
use std::sync::Mutex;
use tauri::State;

// ✅ 타입 별칭으로 불일치 방지
type AppState = Mutex<AppStateInner>;

#[derive(Default)]
struct AppStateInner {
  counter: u32,
  users: Vec<String>,
}

#[tauri::command]
fn increment(state: State<'_, AppState>) -> u32 {
  let mut s = state.lock().unwrap();
  s.counter += 1;
  s.counter
}
```

### React 통합: invoke Hook 패턴

```tsx
import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';

// ✅ 이벤트 리스너 정리 필수
function StatusMonitor() {
  const [status, setStatus] = useState('idle');

  useEffect(() => {
    let unlisten: (() => void) | undefined;

    const setup = async () => {
      unlisten = await listen('status-changed', (event) => {
        setStatus(event.payload as string);
      });
    };
    setup();

    return () => { unlisten?.(); };
  }, []);

  return <div>Status: {status}</div>;
}

// ✅ invoke + 에러 처리
function FileReader({ path }: { path: string }) {
  const [content, setContent] = useState('');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    invoke<string>('read_file', { path })
      .then(setContent)
      .catch((err) => setError(String(err)));
  }, [path]);

  if (error) return <div>Error: {error}</div>;
  return <pre>{content}</pre>;
}
```

### 번들 최적화: Cargo 프로필

```toml
# src-tauri/Cargo.toml
[profile.release]
codegen-units = 1    # LLVM 최적화 극대화
lto = true           # 링크 타임 최적화
opt-level = "s"      # 크기 우선 최적화
panic = "abort"      # 패닉 핸들러 제거
strip = true         # 디버그 심볼 제거
```

### 에러 처리: 구조화된 에러

```rust
#[derive(Debug, thiserror::Error)]
enum AppError {
  #[error("File not found: {0}")]
  FileNotFound(String),
  #[error("Permission denied")]
  PermissionDenied,
  #[error(transparent)]
  Io(#[from] std::io::Error),
}

impl serde::Serialize for AppError {
  fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
  where S: serde::ser::Serializer {
    serializer.serialize_str(self.to_string().as_ref())
  }
}

#[tauri::command]
fn read_file(path: String) -> Result<String, AppError> {
  std::fs::read_to_string(&path).map_err(|_| AppError::FileNotFound(path))
}
```

</patterns>

---

<tauri_specific>

## Tauri v2 특화 패턴

### Commands vs Events vs Channels

| 측면 | Commands | Events | Channels |
|------|----------|--------|----------|
| **프로토콜** | JSON-RPC | 단방향 메시지 | 스트리밍 |
| **방향** | Frontend -> Rust | 양방향 | Rust -> Frontend |
| **응답** | 필수 | 없음 | 연속 |
| **처리량** | 보통 | 낮음 | 높음 |
| **사용 사례** | 함수 호출 | 알림, 상태 변경 | 파일 다운로드, 진행률 |

### Commands 인자 규칙

```rust
// ❌ camelCase 자동 변환 혼동
#[tauri::command]
fn process_data(user_id: i32) {} // JS: invoke('process_data', { userId: 1 })

// ✅ 명시적 snake_case 유지
#[tauri::command(rename_all = "snake_case")]
fn process_data(user_id: i32) {} // JS: invoke('process_data', { user_id: 1 })
```

### 특수 파라미터 자동 주입

```rust
use tauri::{AppHandle, State, WebviewWindow};
use tauri::ipc::Request;

#[tauri::command]
fn my_command(
  app: AppHandle,           // 앱 핸들 (자동 주입)
  window: WebviewWindow,    // 현재 윈도우 (자동 주입)
  state: State<'_, AppState>, // 상태 (자동 주입)
  request: Request,         // Raw IPC 요청 (자동 주입)
  user_input: String,       // 사용자 인자 (invoke에서 전달)
) -> Result<String, String> {
  Ok(format!("Hello from {}", window.label()))
}
```

### 모듈 구조화

```
src-tauri/src/
├── main.rs (또는 lib.rs)
├── commands/
│   ├── mod.rs
│   ├── auth.rs
│   ├── files.rs
│   └── settings.rs
└── state.rs
```

```rust
// commands/mod.rs
pub mod auth;
pub mod files;

// lib.rs
mod commands;
mod state;

tauri::Builder::default()
  .manage(Mutex::new(state::AppState::default()))
  .invoke_handler(tauri::generate_handler![
    commands::auth::login,
    commands::auth::logout,
    commands::files::read_file,
  ])
```

### 보안 파일 구조

```
src-tauri/
├── capabilities/
│   ├── main-window.json    # 메인 UI 권한
│   ├── worker-window.json  # 백그라운드 권한
│   └── admin.json          # 관리자 권한
├── permissions/
│   ├── fs.toml             # 파일시스템 권한
│   └── http.toml           # HTTP 권한
└── tauri.conf.json
```

### 자동 업데이트 설정

```json
{
  "bundle": { "createUpdaterArtifacts": true },
  "plugins": {
    "updater": {
      "pubkey": "PUBLIC_KEY",
      "endpoints": ["https://releases.myapp.com/{{target}}/{{arch}}/{{current_version}}"]
    }
  }
}
```

```typescript
import { check } from '@tauri-apps/plugin-updater';
import { relaunch } from '@tauri-apps/plugin-process';

const update = await check();
if (update) {
  await update.downloadAndInstall();
  await relaunch();
}
```

</tauri_specific>

---

<usage>

## 사용법

**상세 규칙 및 예시:**

```
rules/ipc-batch-commands.md
rules/ipc-channel-streaming.md
rules/security-least-privilege.md
rules/bundle-cargo-profile.md
rules/state-mutex-pattern.md
rules/react-invoke-hook.md
```

각 규칙 파일 포함 내용:
- 중요한 이유 설명
- ❌ 잘못된 코드 예시 + 설명
- ✅ 올바른 코드 예시 + 설명
- 추가 컨텍스트 및 참조

</usage>

---

<references>

## 참고 자료

### Tauri v2 공식 문서
1. [Tauri Overview](https://tauri.app/start/)
2. [Calling Rust from Frontend](https://tauri.app/develop/calling-rust/)
3. [Calling Frontend from Rust](https://tauri.app/develop/calling-frontend/)
4. [Inter-Process Communication](https://tauri.app/concept/inter-process-communication/)
5. [State Management](https://tauri.app/develop/state-management/)
6. [Security Overview](https://tauri.app/security/)
7. [Capabilities](https://tauri.app/security/capabilities/)
8. [Permissions](https://tauri.app/security/permissions/)
9. [Configuration](https://tauri.app/develop/configuration/)
10. [Plugin Development](https://tauri.app/develop/plugins/)
11. [App Size Optimization](https://tauri.app/concept/size/)
12. [Distribution](https://tauri.app/distribute/)
13. [Updater Plugin](https://tauri.app/plugin/updater/)
14. [Debug Guide](https://tauri.app/develop/debug/)
15. [Migration from v1](https://tauri.app/start/migrate/from-tauri-1/)

### React 19
16. [React 공식 문서](https://react.dev)
17. [React use() API](https://react.dev/reference/react/use)
18. [React useOptimistic](https://react.dev/reference/react/useOptimistic)
19. [React Compiler](https://react.dev/learn/react-compiler)

### TypeScript 타입 안전성
20. [tauri-specta](https://github.com/specta-rs/tauri-specta)
21. [TauRPC](https://github.com/MatsDK/TauRPC)

### 외부 자료
22. [Tauri v2 + React 19 Template](https://github.com/dannysmith/tauri-template)
23. [Tauri Plugins Workspace](https://github.com/tauri-apps/plugins-workspace)

</references>
