# Distribution

> Tauri v2 빌드, 코드 서명, 배포 가이드

---

## 빌드 명령어

### 데스크톱

```bash
# 기본 빌드 (현재 플랫폼)
npx tauri build

# 특정 번들 포맷
npx tauri build --bundles msi          # Windows MSI
npx tauri build --bundles nsis         # Windows NSIS
npx tauri build --bundles dmg          # macOS DMG
npx tauri build --bundles app          # macOS App Bundle
npx tauri build --bundles appimage     # Linux AppImage
npx tauri build --bundles deb          # Linux Debian
npx tauri build --bundles rpm          # Linux RPM

# macOS Universal (ARM + Intel)
npx tauri build --bundles app --target universal-apple-darwin

# 디버그 빌드
npx tauri build --debug

# 빌드만 (번들링 스킵)
npx tauri build --no-bundle
```

### 모바일

```bash
# Android
npx tauri android build -- --aab        # AAB (Play Store)
npx tauri android build -- --apk        # APK (사이드로딩)
npx tauri android build -- --aab --target aarch64  # 특정 아키텍처

# iOS
npx tauri ios build                     # 일반 IPA
npx tauri ios build --export-method app-store-connect  # App Store
```

---

## Windows 배포

### 인스톨러 형식

| 형식 | 특징 |
|------|------|
| **NSIS** | 크로스 컴파일 가능, 커스텀 UI |
| **MSI** | WiX 기반, Windows 전용 컴파일 |

### WebView2 설치 모드

```json
// tauri.conf.json > bundle > windows
{
  "webviewInstallMode": {
    "type": "downloadBootstrapper"
  }
}
```

| 모드 | 인터넷 | 크기 증가 | 설명 |
|------|--------|----------|------|
| `downloadBootstrapper` | 필요 | 없음 | 기본값, 최소 인스톨러 |
| `embedBootstrapper` | 필요 | ~1.8MB | Windows 7 호환 |
| `offlineInstaller` | 불필요 | ~127MB | 오프라인 환경 |
| `skip` | - | 없음 | 비권장 |

### NSIS 설정

```json
{
  "bundle": {
    "windows": {
      "nsis": {
        "oneClick": false,
        "allowToChangeInstallationDirectory": true,
        "createDesktopShortcut": true,
        "createStartMenuShortcut": true,
        "installMode": "both"
      }
    }
  }
}
```

### Windows 코드 서명

```json
// tauri.conf.json > bundle > windows
{
  "certificateThumbprint": "A1B1A2B2...",
  "digestAlgorithm": "sha256",
  "timestampUrl": "http://timestamp.comodoca.com"
}
```

**인증서 준비:**
```bash
# PFX 변환
openssl pkcs12 -export -in cert.cer -inkey private-key.key -out certificate.pfx

# Thumbprint 확인: certmgr.msc > Details
```

---

## macOS 배포

### DMG 설정

```json
// tauri.conf.json > bundle > macOS > dmg
{
  "background": "./images/dmg-background.png",
  "windowSize": { "width": 660, "height": 400 },
  "appPosition": { "x": 180, "y": 220 },
  "applicationFolderPosition": { "x": 480, "y": 220 }
}
```

### macOS 코드 서명

```bash
# 서명 ID 확인
security find-identity -v -p codesigning

# 환경 변수 (CI/CD)
export APPLE_CERTIFICATE=<base64-encoded-p12>
export APPLE_CERTIFICATE_PASSWORD=<password>
export APPLE_SIGNING_IDENTITY="Developer ID Application: Company (TEAM123)"

# Notarization
export APPLE_API_ISSUER=<issuer-id>
export APPLE_API_KEY=<key-id>
export APPLE_API_KEY_PATH=~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8
```

### macOS App Store 제출

```bash
# 1. Universal 빌드
npx tauri build --bundles app --target universal-apple-darwin

# 2. PKG 생성
xcrun productbuild --component MyApp.app /Applications \
  --sign "Mac Installer Distribution: Company (TEAM123)" MyApp.pkg

# 3. 업로드
xcrun altool --upload-app -f MyApp.pkg -t macos \
  --apiKey $KEY_ID --apiIssuer $ISSUER_ID
```

**필수 Entitlements:**
```xml
<!-- Entitlements.plist -->
<key>com.apple.security.app-sandbox</key>
<true/>
```

---

## Linux 배포

| 포맷 | 명령어 | 대상 |
|------|--------|------|
| AppImage | `--bundles appimage` | 범용 |
| Debian | `--bundles deb` | Ubuntu, Debian |
| RPM | `--bundles rpm` | Fedora, RHEL |

---

## GitHub Actions CI/CD

```yaml
name: Build & Release
on:
  push:
    branches: [release]

jobs:
  build:
    permissions:
      contents: write
    strategy:
      fail-fast: false
      matrix:
        include:
          - platform: macos-latest
            args: '--target universal-apple-darwin'
          - platform: ubuntu-22.04
            args: ''
          - platform: windows-latest
            args: ''

    runs-on: ${{ matrix.platform }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: lts/*
          cache: npm

      - uses: dtolnay/rust-toolchain@stable
        with:
          targets: aarch64-apple-darwin

      - name: Install Linux deps
        if: startsWith(matrix.platform, 'ubuntu-')
        run: |
          sudo apt-get update
          sudo apt-get install -y libwebkit2gtk-4.1-dev \
            libappindicator3-dev librsvg2-dev patchelf

      - run: npm install

      - uses: tauri-apps/tauri-action@v0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          APPLE_CERTIFICATE: ${{ secrets.APPLE_CERTIFICATE }}
          APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
          APPLE_SIGNING_IDENTITY: ${{ secrets.APPLE_SIGNING_IDENTITY }}
        with:
          tagName: v__VERSION__
          releaseName: v__VERSION__
          releaseDraft: true
          args: ${{ matrix.args }}
```

---

## 빌드 최적화

### Cargo 프로필 설정

```toml
# src-tauri/Cargo.toml
[profile.release]
strip = true          # 디버그 심볼 제거
lto = true            # Link-Time Optimization
opt-level = "s"       # 사이즈 최적화 ("z"는 더 작지만 느림)
codegen-units = 1     # 최적화 극대화 (빌드 느려짐)
panic = "abort"       # 패닉 시 즉시 종료 (바이너리 축소)
```

### 번들 사이즈 참고

| 구성 | 대략적 크기 |
|------|-----------|
| 최소 Tauri 앱 | ~600KB |
| React + Vite | ~2-5MB |
| + Plugin 몇 개 | ~5-15MB |
| Electron 동급 앱 | ~150-300MB |
