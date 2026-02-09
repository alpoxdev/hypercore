# Tauri v2 React 베스트 프랙티스

**Version 1.0.0**
Tauri v2 + React 19 데스크톱/모바일 앱 최적화 가이드
February 2026

> **참고:**
> 이 문서는 주로 에이전트와 LLM이 Tauri v2 + React 코드베이스를 유지보수, 생성, 리팩토링할 때 따르기 위한 것입니다.

---

## 요약

AI 에이전트를 위한 Tauri v2 (@tauri-apps/api v2.10+) + React 19 애플리케이션 종합 최적화 가이드. 8개 카테고리에 걸쳐 40+ 규칙 포함. IPC 최적화(Commands/Events/Channels), 보안(Capabilities/Permissions/Scopes), 번들 크기 최소화(Cargo 프로필, 미사용 커맨드 제거), Rust 상태 관리(Mutex 패턴), React 통합(invoke hook, 이벤트 리스너), 플러그인 패턴, 배포/업데이트 등 Tauri 특화 패턴 반영.

---

<instructions>

## 문서 사용 지침

@rules/ipc-batch-commands.md
@rules/ipc-channel-streaming.md
@rules/ipc-async-commands.md
@rules/ipc-binary-response.md
@rules/ipc-type-safe.md
@rules/ipc-error-handling.md
@rules/security-least-privilege.md
@rules/security-scope-paths.md
@rules/security-capability-split.md
@rules/security-csp.md
@rules/security-no-wildcard.md
@rules/bundle-cargo-profile.md
@rules/bundle-remove-unused-commands.md
@rules/bundle-barrel-imports.md
@rules/bundle-lazy-components.md
@rules/bundle-frontend-treeshake.md
@rules/state-mutex-pattern.md
@rules/state-single-container.md
@rules/state-async-mutex.md
@rules/state-react-sync.md
@rules/react-invoke-hook.md
@rules/react-event-listener.md
@rules/react-file-src.md
@rules/react-error-boundary.md
@rules/react-optimistic-update.md
@rules/plugin-permission-scope.md
@rules/plugin-lifecycle.md
@rules/plugin-mobile-compat.md
@rules/deploy-signing.md
@rules/deploy-updater.md
@rules/deploy-ci-pipeline.md
@rules/perf-functional-setstate.md
@rules/perf-lazy-state-init.md
@rules/perf-derived-state.md
@rules/perf-index-maps.md

</instructions>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 설명 |
|---------|---------|--------|------|
| 1 | IPC 최적화 | **CRITICAL** | Commands 배치, Channel 스트리밍, 바이너리 응답으로 IPC 병목 제거 |
| 2 | 보안 설정 | **CRITICAL** | 최소 권한, Scope 제한, Capability 분리로 공격 표면 최소화 |
| 3 | 번들 크기 최적화 | **HIGH** | Cargo 프로필, 미사용 커맨드 제거, 프론트엔드 tree-shaking |
| 4 | Tauri 상태 관리 | HIGH | Mutex 패턴, 타입 별칭, React 상태 동기화 |
| 5 | React 통합 패턴 | MEDIUM-HIGH | invoke hook, 이벤트 리스너 정리, convertFileSrc |
| 6 | 플러그인 패턴 | MEDIUM | 플러그인 권한 설정, 라이프사이클, 모바일 호환 |
| 7 | 배포 최적화 | MEDIUM | 코드 서명, 자동 업데이트, CI/CD 파이프라인 |
| 8 | Re-render/JS 성능 | LOW-MEDIUM | 함수형 setState, 파생 상태, Map 조회 |

</categories>

---

<critical_patterns>

## 1. IPC 최적화 (CRITICAL)

IPC는 Tauri 앱의 가장 큰 성능 병목입니다. 모든 프론트엔드-백엔드 통신이 JSON 직렬화를 거칩니다.

### 배치 커맨드

```rust
// ❌ N번 IPC 호출 (느림)
// JS: for (item of items) await invoke('process', { item })

// ✅ 1번 IPC 호출 (빠름)
#[tauri::command]
fn process_batch(items: Vec<String>) -> Result<Vec<String>, String> {
  items.iter().map(|item| process_item(item)).collect()
}
```

### Channel 스트리밍 (Events 대신)

```rust
use tauri::ipc::Channel;

// ❌ Events (높은 지연, 낮은 처리량)
#[tauri::command]
async fn download(app: AppHandle, url: String) {
  for chunk in download_stream(&url) {
    app.emit("progress", chunk).unwrap();
  }
}

// ✅ Channel (낮은 지연, 높은 처리량)
#[tauri::command]
async fn download(url: String, on_progress: Channel<u32>) -> Result<(), String> {
  for (i, _chunk) in download_stream(&url).enumerate() {
    on_progress.send(i as u32).unwrap();
  }
  Ok(())
}
```

```typescript
import { invoke, Channel } from '@tauri-apps/api/core';

const onProgress = new Channel<number>();
onProgress.onmessage = (bytes) => updateProgressBar(bytes);
await invoke('download', { url, onProgress });
```

### 바이너리 응답 (JSON 직렬화 우회)

```rust
use tauri::ipc::Response;

// ❌ Vec<u8> JSON 직렬화 (크기 증가, 느림)
#[tauri::command]
fn get_image() -> Result<Vec<u8>, String> { ... }

// ✅ Raw 바이너리 (직렬화 없음)
#[tauri::command]
fn get_image() -> Result<Response, String> {
  let bytes = std::fs::read("/path/to/image.png").map_err(|e| e.to_string())?;
  Ok(Response::new(bytes))
}
```

### Async Commands (비차단)

```rust
// ❌ 동기 커맨드 (메인 스레드 차단)
#[tauri::command]
fn heavy_work() -> String {
  std::thread::sleep(std::time::Duration::from_secs(5));
  "done".to_string()
}

// ✅ 비동기 커맨드 (비차단)
#[tauri::command]
async fn heavy_work() -> Result<String, String> {
  tokio::time::sleep(std::time::Duration::from_secs(5)).await;
  Ok("done".to_string())
}
```

### 구조화된 에러 처리

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
```

</critical_patterns>

---

<security>

## 2. 보안 설정 (CRITICAL)

Tauri의 보안은 Trust Boundary (Rust=신뢰, WebView=검증 필요) 기반입니다.

### 최소 권한 Capability

```json
{
  "identifier": "main-window",
  "windows": ["main"],
  "permissions": [
    "core:window:allow-close",
    "core:window:allow-minimize",
    "fs:allow-read"
  ]
}
```

### Scope 제한

```toml
# ❌ 위험: 모든 경로
[[scope.allow]]
path = "/*"

# ❌ 위험: 모든 명령
[permission.commands]
allow = ["*"]

# ✅ 안전: 특정 경로만
[[scope.allow]]
path = "$APPDATA/my-app/data/**"

[[scope.deny]]
path = "$HOME/.ssh/**"
path = "$HOME/.gnupg/**"
```

### 윈도우별 Capability 분리

```json
// capabilities/main-window.json - UI 권한
{
  "identifier": "main-cap",
  "windows": ["main"],
  "permissions": ["fs:allow-read", "window:allow-create"]
}

// capabilities/worker-window.json - 백그라운드 권한
{
  "identifier": "worker-cap",
  "windows": ["worker"],
  "permissions": ["fs:allow-read", "fs:allow-write", "http:allow-fetch"]
}
```

### CSP 설정

```json
{
  "app": {
    "security": {
      "csp": "default-src 'self'; script-src 'self'; img-src 'self' data: asset:; style-src 'self' 'unsafe-inline'"
    }
  }
}
```

</security>

---

<bundle_optimization>

## 3. 번들 크기 최적화 (HIGH)

Tauri 앱은 OS 네이티브 WebView를 사용하여 Electron보다 훨씬 작지만, 추가 최적화가 가능합니다.

### Cargo Release 프로필

```toml
# src-tauri/Cargo.toml
[profile.release]
codegen-units = 1    # LLVM 최적화 극대화
lto = true           # 링크 타임 최적화
opt-level = "s"      # 크기 우선 ("3"은 성능 우선)
panic = "abort"      # 패닉 핸들러 제거
strip = true         # 디버그 심볼 제거
```

### 미사용 커맨드 제거 (v2.4+)

```json
{
  "build": {
    "removeUnusedCommands": true
  }
}
```

### 프론트엔드 최적화

```tsx
// ❌ 전체 라이브러리 import
import { Check, X, Menu } from 'lucide-react'

// ✅ 직접 import
import Check from 'lucide-react/dist/esm/icons/check'

// ✅ 무거운 컴포넌트 lazy load
const HeavyEditor = lazy(() => import('./components/HeavyEditor'))
```

</bundle_optimization>

---

<state_management>

## 4. Tauri 상태 관리 (HIGH)

### Mutex 패턴 + 타입 별칭

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

// 초기화
tauri::Builder::default()
  .manage(AppState::default())

// 커맨드에서 접근
#[tauri::command]
fn increment(state: State<'_, AppState>) -> u32 {
  let mut s = state.lock().unwrap();
  s.counter += 1;
  s.counter
}
```

### 동일 타입 중복 등록 방지

```rust
// ❌ 두 번째 등록은 무시됨
app.manage(Mutex::new(AppState { counter: 0 }));
app.manage(Mutex::new(AppState { counter: 100 })); // 무시!

// ✅ 컨테이너로 통합
struct AppStates {
  counter1: u32,
  counter2: u32,
}
app.manage(Mutex::new(AppStates { counter1: 0, counter2: 100 }));
```

### 비동기 Mutex 선택 기준

```rust
// ✅ 대부분: 표준 Mutex (빠름)
use std::sync::Mutex;

// ✅ IO 리소스 (DB 연결 등): Tokio Mutex
use tokio::sync::Mutex;

#[tauri::command]
async fn query_db(state: State<'_, tokio::sync::Mutex<DbPool>>) -> Result<Vec<User>, String> {
  let pool = state.lock().await;
  // await 포인트 너머로 lock 유지 필요할 때만 Tokio Mutex
  pool.query("SELECT * FROM users").await.map_err(|e| e.to_string())
}
```

</state_management>

---

<react_integration>

## 5. React 통합 패턴 (MEDIUM-HIGH)

### invoke Hook 패턴

```tsx
import { invoke } from '@tauri-apps/api/core';

// ✅ invoke + 에러 처리 + 로딩 상태
function useInvoke<T>(cmd: string, args?: Record<string, unknown>) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    invoke<T>(cmd, args)
      .then(setData)
      .catch((err) => setError(String(err)))
      .finally(() => setLoading(false));
  }, [cmd, JSON.stringify(args)]);

  return { data, error, loading };
}
```

### 이벤트 리스너 정리 필수

```tsx
// ✅ cleanup으로 메모리 누수 방지
useEffect(() => {
  let unlisten: (() => void) | undefined;

  const setup = async () => {
    unlisten = await listen('event-name', (event) => {
      setStatus(event.payload as string);
    });
  };
  setup();

  return () => { unlisten?.(); };
}, []);
```

### convertFileSrc로 로컬 파일 렌더링

```tsx
import { convertFileSrc } from '@tauri-apps/api/core';

// ❌ invoke로 파일 읽어서 base64 변환 (느림)
const base64 = await invoke('read_image_base64', { path });

// ✅ 네이티브 프로토콜로 직접 렌더링 (빠름)
const assetUrl = convertFileSrc(filePath);
return <img src={assetUrl} />;
```

</react_integration>

---

<deployment>

## 6. 배포 최적화 (MEDIUM)

### GitHub Actions 멀티 플랫폼

```yaml
strategy:
  matrix:
    platform:
      - os: ubuntu-latest
        rust_target: x86_64-unknown-linux-gnu
      - os: macos-latest
        rust_target: aarch64-apple-darwin
      - os: windows-latest
        rust_target: x86_64-pc-windows-msvc

steps:
  - uses: tauri-apps/tauri-action@v0
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_PRIVATE_KEY }}
```

### 자동 업데이트

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
  await update.downloadAndInstall((event) => {
    if (event.event === 'Progress') console.log(event.data.chunkLength);
  });
  await relaunch();
}
```

</deployment>

---

<references>

## 참고 자료

### Tauri v2 공식 문서
1. [Tauri Overview](https://tauri.app/start/)
2. [Calling Rust from Frontend](https://tauri.app/develop/calling-rust/)
3. [Calling Frontend from Rust](https://tauri.app/develop/calling-frontend/)
4. [Inter-Process Communication](https://tauri.app/concept/inter-process-communication/)
5. [State Management](https://tauri.app/develop/state-management/)
6. [Security](https://tauri.app/security/)
7. [Capabilities](https://tauri.app/security/capabilities/)
8. [Permissions](https://tauri.app/security/permissions/)
9. [App Size](https://tauri.app/concept/size/)
10. [Distribution](https://tauri.app/distribute/)
11. [Updater Plugin](https://tauri.app/plugin/updater/)
12. [Migration from v1](https://tauri.app/start/migrate/from-tauri-1/)

### React 19
13. [React](https://react.dev)
14. [React use()](https://react.dev/reference/react/use)
15. [React useOptimistic](https://react.dev/reference/react/useOptimistic)
16. [React Compiler](https://react.dev/learn/react-compiler)

### TypeScript 타입 안전성
17. [tauri-specta](https://github.com/specta-rs/tauri-specta)
18. [TauRPC](https://github.com/MatsDK/TauRPC)

### 외부 자료
19. [Tauri v2 + React 19 Template](https://github.com/dannysmith/tauri-template)
20. [Tauri Plugins Workspace](https://github.com/tauri-apps/plugins-workspace)

</references>
