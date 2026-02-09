# 자동 업데이트 서명 키 관리

## 왜 중요한가

Tauri의 자동 업데이트는 서명된 업데이트 파일만 설치합니다. 서명 키를 올바르게 생성하고 환경 변수로 관리하지 않으면 업데이트가 실패하거나 보안 취약점이 발생합니다. 키를 하드코딩하면 소스 코드 유출 시 악의적인 업데이트 배포가 가능합니다.

## ❌ 잘못된 패턴

```json
// tauri.conf.json
{
  "bundle": {
    "updater": {
      "active": true,
      "endpoints": ["https://example.com/updates/{{target}}/{{current_version}}"],
      // ❌ 공개 키를 하드코딩 (private 키는 더 위험)
      "pubkey": "dW50cnVzdGVkIGNvbW1lbnQ6IG1pbmlzaWduIHB1YmxpYyBrZXk6IDEyMzQ1Njc4OTBBQkNERUYKUldRZEdzV3RQNjNiUEsxL0ZyQWt4SUVGQldRcVFRSkRYRFFRWENnPT0K"
    }
  }
}
```

```bash
# ❌ private 키를 프로젝트 디렉토리에 보관 (Git에 커밋 위험)
ls ~/.tauri/myapp.key
```

**문제점:**
- 서명 키 미설정 또는 하드코딩
- private 키가 Git에 커밋될 위험
- CI/CD에서 키 관리 없음
- 업데이트 서명 실패

## ✅ 올바른 패턴

### 1. 서명 키 생성

```bash
# Tauri CLI로 서명 키 생성
pnpm tauri signer generate -- -w ~/.tauri/myapp.key

# 출력:
# Private key: ~/.tauri/myapp.key
# Public key: dW50cnVzdGVkIGNvbW1lbnQ6...
# Password: (비워두면 비밀번호 없음)
```

### 2. 환경 변수로 키 관리

```bash
# .env (Git에 커밋하지 않음)
TAURI_SIGNING_PRIVATE_KEY="dW50cnVzdGVkIGNvbW1lbnQ6IHJzaWduIGVuY3J5cHRlZCBzZWNyZXQga2V5ClJXUlRZMEl5T0ZraGtUcjVVU28ybmNaNFN0Y1lHSzc0TVh4MkJiUGREN2xrPQo="
TAURI_SIGNING_PRIVATE_KEY_PASSWORD=""  # 비밀번호가 있으면 설정
```

```bash
# .gitignore
.env
*.key
```

### 3. tauri.conf.json 설정

```json
{
  "bundle": {
    "identifier": "com.example.app",
    "version": "1.0.0",
    "updater": {
      "active": true,
      "endpoints": [
        "https://example.com/updates/{{target}}/{{current_version}}"
      ],
      "pubkey": "dW50cnVzdGVkIGNvbW1lbnQ6IG1pbmlzaWduIHB1YmxpYyBrZXk6IDEyMzQ1Njc4OTBBQkNERUYKUldRZEdzV3RQNjNiUEsxL0ZyQWt4SUVGQldRcVFRSkRYRFFRWENnPT0K"
    }
  }
}
```

### 4. 빌드 시 서명

```bash
# private 키 환경 변수로 주입
export TAURI_SIGNING_PRIVATE_KEY=$(cat ~/.tauri/myapp.key)
export TAURI_SIGNING_PRIVATE_KEY_PASSWORD=""

# 빌드 (자동으로 서명됨)
pnpm tauri build
```

### 5. 업데이트 서버 응답 형식

```json
{
  "version": "1.0.1",
  "date": "2024-02-09T12:00:00Z",
  "platforms": {
    "darwin-aarch64": {
      "url": "https://example.com/releases/MyApp-1.0.1-arm64.app.tar.gz",
      "signature": "dW50cnVzdGVkIGNvbW1lbnQ6IHNpZ25hdHVyZSBmcm9tIHRhdXJpIHNlY3JldCBrZXkKUldRZEdzV3RQNjNiUEsxL0ZyQWt4SUVGQldRcVFRSkRYRFFRWENnPT0K"
    },
    "darwin-x86_64": {
      "url": "https://example.com/releases/MyApp-1.0.1-x64.app.tar.gz",
      "signature": "..."
    },
    "windows-x86_64": {
      "url": "https://example.com/releases/MyApp-1.0.1-x64.msi.zip",
      "signature": "..."
    }
  }
}
```

### 6. GitHub Actions CI/CD

```yaml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ${{ matrix.platform }}
    strategy:
      matrix:
        platform: [macos-latest, windows-latest, ubuntu-latest]

    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4

      - name: Install dependencies
        run: pnpm install

      - name: Build with signing
        env:
          TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
          TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
        run: pnpm tauri build

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: app-${{ matrix.platform }}
          path: ./target/release/bundle/**/*
```

**GitHub Secrets 설정:**
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. New repository secret:
   - `TAURI_SIGNING_PRIVATE_KEY`: `cat ~/.tauri/myapp.key` 출력값
   - `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`: 비밀번호 (없으면 빈 문자열)

### 7. 프론트엔드에서 업데이트 확인

```tsx
import { check, installUpdate } from '@tauri-apps/plugin-updater'
import { relaunch } from '@tauri-apps/plugin-process'
import { useEffect, useState } from 'react'

function UpdateChecker() {
  const [updateAvailable, setUpdateAvailable] = useState(false)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    check().then(update => {
      if (update?.available) {
        setUpdateAvailable(true)
      }
    })
  }, [])

  const handleUpdate = async () => {
    setLoading(true)
    try {
      await installUpdate()
      await relaunch()
    } catch (error) {
      console.error('Update failed:', error)
      setLoading(false)
    }
  }

  if (!updateAvailable) return null

  return (
    <div className="update-banner">
      <p>새 버전이 있습니다!</p>
      <button onClick={handleUpdate} disabled={loading}>
        {loading ? 'Updating...' : 'Update Now'}
      </button>
    </div>
  )
}
```

## 추가 컨텍스트

**서명 키 관리 원칙:**
1. private 키는 절대 Git에 커밋하지 않음
2. 환경 변수로만 관리 (`.env`, GitHub Secrets)
3. public 키는 `tauri.conf.json`에 하드코딩 가능
4. private 키는 팀 내 안전한 저장소에 백업

**Updater 엔드포인트 변수:**
- `{{target}}`: 플랫폼 식별자 (darwin-aarch64, windows-x86_64 등)
- `{{current_version}}`: 현재 앱 버전
- `{{arch}}`: CPU 아키텍처

**서명 파일 위치:**
- macOS: `*.app.tar.gz.sig`
- Windows: `*.msi.zip.sig`
- Linux: `*.AppImage.tar.gz.sig`

**권장 업데이트 서버:**
- GitHub Releases (무료, 간단)
- AWS S3 + CloudFront
- Cloudflare R2
- 자체 서버 (Nginx/Caddy)

**참고:** [Tauri Updater Guide](https://beta.tauri.app/plugin/updater/)

영향도: CRITICAL - 보안, 자동 업데이트 기능, 배포 신뢰성
