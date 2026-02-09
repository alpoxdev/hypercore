# 윈도우별 Capability 분리

## 왜 중요한가

Tauri 애플리케이션은 여러 윈도우를 가질 수 있으며, 각 윈도우는 서로 다른 목적과 신뢰 수준을 가집니다. 모든 윈도우에 동일한 권한을 부여하면, 덜 신뢰할 수 있는 콘텐츠를 표시하는 윈도우(예: 외부 웹뷰, 플러그인 UI)가 과도한 권한을 갖게 됩니다. 윈도우별로 Capability를 분리하면 권한 상승 공격(Privilege Escalation)을 방지할 수 있습니다.

## ❌ 잘못된 패턴

```json
// src-tauri/capabilities/default.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "모든 윈도우에 동일한 권한",
  "windows": ["main", "worker", "external-viewer"],
  "permissions": [
    "core:default",
    "fs:allow-read-text-file",
    "fs:allow-write-text-file",
    "shell:allow-execute",
    "http:allow-fetch"
  ]
}
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .setup(|app| {
            // 외부 콘텐츠를 표시하는 윈도우도 동일한 권한
            tauri::window::WindowBuilder::new(
                app,
                "external-viewer",
                tauri::WindowUrl::External("https://untrusted.com".parse().unwrap())
            ).build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**문제점:**
- 외부 웹사이트를 표시하는 윈도우가 파일 시스템, 셸 실행 권한을 갖음
- XSS 공격 시 `shell:allow-execute`로 임의 명령 실행 가능
- 신뢰할 수 없는 콘텐츠가 로컬 파일 읽기/쓰기 가능
- 모든 윈도우가 동일한 공격 표면을 가짐

## ✅ 올바른 패턴

```json
// src-tauri/capabilities/main-window.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "main-window",
  "description": "메인 윈도우 전체 권한",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "core:window:allow-close",
    "core:window:allow-minimize",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [{ "path": "$APPDATA/my-app/*" }]
    },
    {
      "identifier": "fs:allow-write-text-file",
      "allow": [{ "path": "$APPDATA/my-app/*" }]
    },
    "shell:allow-open",
    "http:allow-fetch"
  ]
}
```

```json
// src-tauri/capabilities/worker-window.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "worker-window",
  "description": "백그라운드 작업 윈도우 (읽기 전용)",
  "windows": ["worker"],
  "permissions": [
    "core:default",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [{ "path": "$APPDATA/my-app/queue/*" }]
    },
    "http:allow-fetch"
  ]
}
```

```json
// src-tauri/capabilities/external-viewer.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "external-viewer",
  "description": "외부 콘텐츠 뷰어 (최소 권한)",
  "windows": ["external-viewer"],
  "permissions": [
    "core:default",
    "core:window:allow-close"
  ]
}
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .setup(|app| {
            // 각 윈도우는 자신의 capability를 가짐
            tauri::window::WindowBuilder::new(
                app,
                "external-viewer",
                tauri::WindowUrl::External("https://untrusted.com".parse().unwrap())
            ).build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**장점:**
- 각 윈도우는 필요한 최소 권한만 가짐
- 외부 콘텐츠 윈도우는 시스템 접근 불가
- 백그라운드 워커는 쓰기 권한 없음 (데이터 손상 방지)
- 공격 성공 시 피해 범위 제한

## 추가 컨텍스트

**Capability 병합 규칙:**

Tauri는 여러 capability 파일을 자동으로 병합합니다. 윈도우는 자신의 이름이 `windows` 배열에 포함된 모든 capability의 권한을 받습니다.

```json
// capabilities/base.json
{
  "identifier": "base",
  "windows": ["main", "worker"],
  "permissions": ["core:default"]
}

// capabilities/main-only.json
{
  "identifier": "main-only",
  "windows": ["main"],
  "permissions": ["fs:allow-write-text-file"]
}
```

결과:
- `main` 윈도우: `core:default` + `fs:allow-write-text-file`
- `worker` 윈도우: `core:default`만

**일반적인 윈도우 타입별 권한 예시:**

| 윈도우 타입 | 설명 | 필요한 권한 |
|-----------|------|-----------|
| `main` | 메인 애플리케이션 UI | 전체 파일 시스템, HTTP, 일부 셸 |
| `settings` | 설정 창 | 설정 파일 읽기/쓰기만 |
| `worker` | 백그라운드 작업 | HTTP, 임시 파일 읽기/쓰기 |
| `preview` | 파일 미리보기 | 읽기 전용 파일 시스템 |
| `external` | 외부 웹 콘텐츠 | 윈도우 제어만 (close/minimize) |
| `admin` | 관리자 기능 | 전체 권한 (추가 인증 필요) |

**보안 설계 패턴:**

1. **신뢰 경계 식별**
   ```
   신뢰도: main > settings > worker > preview > external
   권한:   많음 ←------------------------→ 적음
   ```

2. **기본 권한 + 확장 패턴**
   ```json
   // base.json: 모든 윈도우에 기본 권한
   { "windows": ["*"], "permissions": ["core:default"] }

   // main.json: 메인 윈도우만 확장
   { "windows": ["main"], "permissions": ["fs:allow-*"] }
   ```

3. **명시적 윈도우 나열**
   ```json
   // ❌ 와일드카드 사용
   { "windows": ["*"], "permissions": ["fs:allow-write-text-file"] }

   // ✅ 필요한 윈도우만 명시
   { "windows": ["main", "settings"], "permissions": ["fs:allow-write-text-file"] }
   ```

**체크리스트:**
- [ ] 각 윈도우의 신뢰 수준을 평가함
- [ ] 외부 콘텐츠를 표시하는 윈도우는 최소 권한만
- [ ] 백그라운드 워커는 쓰기 권한 최소화
- [ ] 관리자 기능은 별도 윈도우로 분리
- [ ] Capability 파일 이름이 윈도우 이름과 일치 (가독성)

**참조:**
- [Tauri Multi-Window Security](https://tauri.app/v2/security/#multi-window-applications)
- [Capability Configuration](https://tauri.app/v2/core/capability/)
