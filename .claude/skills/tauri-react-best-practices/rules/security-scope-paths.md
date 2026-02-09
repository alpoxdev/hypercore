# 파일 경로 Scope 제한

## 왜 중요한가

Tauri의 파일 시스템 권한은 기본적으로 전체 시스템에 접근할 수 있습니다. Scope를 사용하여 접근 가능한 경로를 명시적으로 제한하면, 악의적인 코드나 프로그래밍 오류로 인한 민감한 파일(비밀번호, SSH 키, 시스템 설정 등) 접근을 방지할 수 있습니다. `deny` 리스트를 활용하면 특정 하위 경로를 추가로 차단할 수 있습니다.

## ❌ 잘못된 패턴

```json
// src-tauri/capabilities/default.json
{
  "permissions": [
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "/*" }
      ]
    },
    {
      "identifier": "fs:allow-write-text-file",
      "allow": [
        { "path": "$HOME/*" }
      ]
    }
  ]
}
```

**문제점:**
- `path: "/*"`는 전체 파일 시스템 읽기 허용
- `$HOME/*`는 사용자 홈 디렉토리 전체를 쓰기 가능하게 함
- `.ssh/`, `.gnupg/`, `.aws/` 등 민감한 디렉토리 접근 가능
- 브라우저 비밀번호, 쿠키 파일 등 개인정보 유출 위험

## ✅ 올바른 패턴

```json
// src-tauri/capabilities/default.json
{
  "permissions": [
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "$APPDATA/my-app/*" },
        { "path": "$DOCUMENT/*.txt" },
        { "path": "$DOCUMENT/*.json" }
      ],
      "deny": [
        { "path": "$APPDATA/my-app/secrets/*" }
      ]
    },
    {
      "identifier": "fs:allow-write-text-file",
      "allow": [
        { "path": "$APPDATA/my-app/config.json" },
        { "path": "$DOCUMENT/exports/*.txt" }
      ]
    }
  ]
}
```

**장점:**
- 애플리케이션 데이터 디렉토리와 문서 폴더만 접근 가능
- 파일 확장자로 추가 제한 (`.txt`, `.json`만 허용)
- `deny` 리스트로 민감한 하위 폴더 차단
- 사용자의 다른 데이터는 완전히 보호됨

**추가 예시 (임시 파일 처리):**

```json
{
  "permissions": [
    {
      "identifier": "fs:allow-read-text-file",
      "allow": [
        { "path": "$TEMP/my-app-*.tmp" }
      ]
    },
    {
      "identifier": "fs:allow-remove",
      "allow": [
        { "path": "$TEMP/my-app-*.tmp" }
      ]
    }
  ]
}
```

## 추가 컨텍스트

**Tauri 환경 변수 목록:**

| 변수 | 설명 | macOS 경로 예시 | Windows 경로 예시 |
|------|------|----------------|------------------|
| `$APPDATA` | 앱 데이터 디렉토리 | `~/Library/Application Support` | `%APPDATA%` |
| `$APPLOCALDATA` | 로컬 앱 데이터 | `~/Library/Application Support` | `%LOCALAPPDATA%` |
| `$APPCONFIG` | 앱 설정 디렉토리 | `~/Library/Application Support` | `%APPDATA%` |
| `$APPLOG` | 로그 디렉토리 | `~/Library/Logs` | `%LOCALAPPDATA%` |
| `$APPCACHE` | 캐시 디렉토리 | `~/Library/Caches` | `%LOCALAPPDATA%\cache` |
| `$DOCUMENT` | 사용자 문서 폴더 | `~/Documents` | `%USERPROFILE%\Documents` |
| `$DOWNLOAD` | 다운로드 폴더 | `~/Downloads` | `%USERPROFILE%\Downloads` |
| `$PICTURE` | 사진 폴더 | `~/Pictures` | `%USERPROFILE%\Pictures` |
| `$DESKTOP` | 데스크톱 | `~/Desktop` | `%USERPROFILE%\Desktop` |
| `$HOME` | 홈 디렉토리 | `~` | `%USERPROFILE%` |
| `$TEMP` | 임시 파일 디렉토리 | `/tmp` | `%TEMP%` |
| `$RESOURCE` | 앱 리소스 (읽기 전용) | 앱 번들 내부 | 앱 설치 디렉토리 |

**Scope 설계 가이드라인:**

1. **가장 구체적인 경로 사용**
   ```json
   // ❌ 너무 광범위
   { "path": "$APPDATA/*" }

   // ✅ 앱 전용 하위 디렉토리
   { "path": "$APPDATA/my-app/*" }
   ```

2. **파일 확장자로 제한**
   ```json
   // 특정 파일 타입만 허용
   { "path": "$DOCUMENT/*.pdf" }
   { "path": "$DOCUMENT/*.{txt,md,json}" }
   ```

3. **Deny 리스트 활용**
   ```json
   {
     "allow": [{ "path": "$APPDATA/my-app/*" }],
     "deny": [
       { "path": "$APPDATA/my-app/.env" },
       { "path": "$APPDATA/my-app/tokens/*" }
     ]
   }
   ```

4. **읽기/쓰기 권한 분리**
   ```json
   // 읽기는 넓게, 쓰기는 좁게
   {
     "identifier": "fs:allow-read-text-file",
     "allow": [{ "path": "$DOCUMENT/*" }]
   },
   {
     "identifier": "fs:allow-write-text-file",
     "allow": [{ "path": "$DOCUMENT/exports/*" }]
   }
   ```

**보안 체크리스트:**
- [ ] `path: "/*"` 또는 `$HOME/*` 사용하지 않음
- [ ] 앱 전용 서브디렉토리 사용 (`$APPDATA/my-app/`)
- [ ] 파일 확장자로 추가 제한
- [ ] 민감한 경로는 `deny` 리스트에 명시
- [ ] 읽기/쓰기 권한을 분리하여 최소화

**참조:**
- [Tauri File System Scope](https://tauri.app/v2/core/capability/#file-system-scope)
- [Path Variables Reference](https://tauri.app/v2/guides/filesystem/)
