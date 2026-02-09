# 플러그인별 최소 권한 + Scope

## 왜 중요한가

Tauri 플러그인은 기본적으로 모든 권한을 허용하지 않습니다. 필요한 커맨드만 명시하고 scope를 제한해야 보안 취약점을 방지할 수 있습니다. 과도한 권한은 악의적인 코드나 XSS 공격 시 시스템 접근을 허용할 수 있습니다.

## ❌ 잘못된 패턴

```json
// tauri.conf.json
{
  "plugins": {
    "fs": {
      "all": true,  // ❌ 모든 파일 시스템 접근 허용
      "scope": ["**"]  // ❌ 전체 디렉토리 접근 가능
    },
    "shell": {
      "all": true  // ❌ 모든 셸 커맨드 실행 허용
    }
  }
}
```

**문제점:**
- 불필요한 권한 부여 (최소 권한 원칙 위반)
- 악의적인 코드가 시스템 전체 접근 가능
- XSS 공격 시 파일 삭제, 임의 명령 실행 가능

## ✅ 올바른 패턴

```json
// tauri.conf.json
{
  "plugins": {
    "fs": {
      "scope": [
        "$APPDATA/user-data/**",  // ✅ 앱 데이터 폴더만
        "$RESOURCE/assets/**"     // ✅ 앱 리소스 폴더만
      ],
      "commands": {
        "readFile": true,
        "writeFile": true,
        "readDir": true,
        "exists": true
      }
    },
    "shell": {
      "scope": [
        {
          "name": "ffmpeg",
          "cmd": "ffmpeg",
          "args": [
            "-i", { "validator": "\\.(mp4|avi|mov)$" },
            "-o", { "validator": "^[^/\\\\]+$" }
          ]
        }
      ]
    },
    "http": {
      "scope": [
        "https://api.example.com/*"  // ✅ 특정 도메인만
      ],
      "commands": {
        "fetch": true
      }
    }
  }
}
```

**파일 시스템 플러그인 권한 예시:**

```json
{
  "plugins": {
    "fs": {
      "scope": [
        // 읽기 전용 리소스
        {
          "path": "$RESOURCE/**",
          "permissions": ["read"]
        },
        // 읽기/쓰기 가능한 사용자 데이터
        {
          "path": "$APPDATA/config.json",
          "permissions": ["read", "write"]
        },
        {
          "path": "$APPDATA/cache/**",
          "permissions": ["read", "write", "delete"]
        }
      ],
      "commands": {
        "readFile": true,
        "writeFile": true,
        "readDir": true,
        "exists": true
        // removeFile, renameFile 등 불필요한 커맨드 비활성화
      }
    }
  }
}
```

**HTTP 플러그인 권한 예시:**

```json
{
  "plugins": {
    "http": {
      "scope": [
        "https://api.example.com/*",
        "https://cdn.example.com/assets/*"
      ],
      "commands": {
        "fetch": true
      }
    }
  }
}
```

**Shell 플러그인 권한 예시:**

```json
{
  "plugins": {
    "shell": {
      "scope": [
        {
          "name": "video-convert",
          "cmd": "ffmpeg",
          "args": [
            "-i", { "validator": "^[a-zA-Z0-9_-]+\\.(mp4|avi)$" },
            "-codec", "copy",
            { "validator": "^output\\.mp4$" }
          ],
          "sidecar": false
        }
      ]
    }
  }
}
```

**런타임 권한 요청 (Tauri v2.1+):**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { requestPermission } from '@tauri-apps/plugin-fs'

async function writeUserConfig(data: Config) {
  const granted = await requestPermission({
    path: '$APPDATA/config.json',
    permissions: ['write']
  })

  if (!granted) {
    throw new Error('Permission denied')
  }

  await invoke('write_config', { data })
}
```

## 추가 컨텍스트

**Scope 패턴:**
- `$APPDATA`: 사용자 앱 데이터 디렉토리
- `$RESOURCE`: 앱 리소스 디렉토리 (번들된 파일)
- `$HOME`: 사용자 홈 디렉토리 (가급적 피하기)
- `**`: 하위 디렉토리 포함 (주의해서 사용)

**공식 플러그인 권한 체크리스트:**

| 플러그인 | 최소 권한 예시 |
|---------|---------------|
| fs | 특정 디렉토리만 + read/write 구분 |
| http | 특정 도메인만 허용 |
| shell | 화이트리스트 커맨드 + args 검증 |
| notification | 기본 권한 (OS 수준 허용 필요) |
| clipboard | 기본 권한 |
| dialog | 기본 권한 |

**보안 원칙:**
1. 최소 권한 원칙: 필요한 권한만 부여
2. Scope 제한: 전체 파일 시스템 접근 금지
3. 화이트리스트: 허용 목록 기반 권한 관리
4. Validator: args에 정규식 검증 추가

**참고:** [Tauri Security Best Practices](https://beta.tauri.app/security/best-practices/)

영향도: CRITICAL - 보안, 권한 관리, XSS 공격 방어
