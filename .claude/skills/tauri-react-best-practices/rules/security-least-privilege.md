# 최소 권한 원칙

## 왜 중요한가

Tauri 애플리케이션은 시스템 리소스 접근 시 최소 권한 원칙(Principle of Least Privilege)을 따라야 합니다. 필요한 커맨드만 명시적으로 허용하면 공격 표면을 최소화하고, 악의적인 코드나 XSS 공격으로부터 사용자를 보호할 수 있습니다. 와일드카드 권한은 예상치 못한 커맨드 실행을 허용하여 심각한 보안 취약점이 됩니다.

## ❌ 잘못된 패턴

```json
// src-tauri/capabilities/default.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "모든 권한 허용",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:allow-*",
    "fs:allow-*",
    "http:allow-*"
  ]
}
```

**문제점:**
- `allow-*` 와일드카드는 해당 플러그인의 모든 커맨드를 허용
- XSS 공격 시 임의의 셸 명령어, 파일 시스템 접근, HTTP 요청 가능
- 악의적인 스크립트가 민감한 데이터 탈취 가능
- 의도하지 않은 시스템 변경 발생 가능

## ✅ 올바른 패턴

```json
// src-tauri/capabilities/default.json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "최소 권한만 허용",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "core:window:allow-close",
    "core:window:allow-minimize",
    "shell:allow-open",
    "fs:allow-read-text-file",
    "fs:allow-write-text-file",
    "http:allow-fetch",
    "http:allow-fetch-cancel"
  ]
}
```

**장점:**
- 애플리케이션이 필요한 기능만 명시적으로 나열
- 각 권한의 목적과 사용처가 명확함
- 보안 감사 시 검토 범위가 제한적
- 공격자가 악용할 수 있는 경로가 제한됨

**추가 예시 (scope와 함께 사용):**

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "문서 편집 앱",
  "windows": ["main"],
  "permissions": [
    "core:default",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "$DOCUMENT/*" }
      ]
    },
    {
      "identifier": "fs:allow-write-text-file",
      "allow": [
        { "path": "$DOCUMENT/*" }
      ]
    },
    "shell:allow-open"
  ]
}
```

## 추가 컨텍스트

**주요 플러그인별 일반적인 권한:**

| 플러그인 | 일반적으로 필요한 권한 | 위험한 권한 |
|---------|---------------------|-----------|
| `core` | `window:allow-close`, `window:allow-minimize` | `app:allow-app-hide` (남용 가능) |
| `shell` | `allow-open` (URL 열기) | `allow-execute` (임의 명령 실행) |
| `fs` | `allow-read-text-file`, `allow-write-text-file` | `allow-remove`, `allow-rename` |
| `http` | `allow-fetch`, `allow-fetch-cancel` | - (scope 필수) |

**권한 설계 체크리스트:**
1. 각 권한이 실제로 사용되는지 확인 (미사용 권한 제거)
2. 와일드카드 사용 금지 (`allow-*`, `deny-*`)
3. 파일 시스템 권한은 scope와 함께 사용
4. HTTP 권한은 URL 패턴으로 제한
5. `shell:allow-execute`는 가급적 피하고, 필요하면 특정 바이너리만 허용

**참조:**
- [Tauri Security Best Practices](https://tauri.app/v2/security/)
- [Capability Configuration](https://tauri.app/v2/core/capability/)
