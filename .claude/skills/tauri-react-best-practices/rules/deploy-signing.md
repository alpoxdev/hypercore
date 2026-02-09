# 코드 서명 필수

## 왜 중요한가

서명 없이 배포하면 macOS는 "손상된 앱" 경고를, Windows는 SmartScreen 경고를 표시합니다. 사용자는 앱을 신뢰할 수 없어 설치를 포기하거나 보안 위험에 노출됩니다. 코드 서명은 앱 무결성을 보장하고 사용자 신뢰를 확보하는 필수 단계입니다.

## ❌ 잘못된 패턴

```bash
# ❌ 서명 없이 빌드
pnpm tauri build

# ❌ 서명 없이 배포
gh release upload v1.0.0 ./target/release/bundle/**/*
```

**문제점:**
- macOS: "App is damaged and can't be opened" 경고
- Windows: "Windows protected your PC" SmartScreen 경고
- 사용자가 설치 과정을 포기
- 앱 무결성 검증 불가

## ✅ 올바른 패턴

### macOS 코드 서명 + 공증

```bash
# 1. Apple Developer 인증서 설치
# - Keychain Access에서 Developer ID Application 인증서 확인

# 2. 빌드 시 서명
pnpm tauri build

# 3. 공증 (notarization)
xcrun notarytool submit \
  ./target/release/bundle/macos/MyApp.app.zip \
  --apple-id "your-email@example.com" \
  --password "app-specific-password" \
  --team-id "YOUR_TEAM_ID" \
  --wait

# 4. 공증 완료 후 stapler로 티켓 첨부
xcrun stapler staple ./target/release/bundle/macos/MyApp.app
```

**tauri.conf.json 설정:**

```json
{
  "bundle": {
    "macOS": {
      "signingIdentity": "Developer ID Application: Your Name (TEAM_ID)",
      "entitlements": "entitlements.plist",
      "provisioningProfile": null
    }
  }
}
```

**entitlements.plist:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

### Windows 코드 서명

```bash
# 1. 코드 서명 인증서 (*.pfx) 준비

# 2. signtool로 서명
signtool sign /f "certificate.pfx" /p "password" /tr http://timestamp.digicert.com /td sha256 /fd sha256 "./target/release/bundle/msi/MyApp_1.0.0_x64_en-US.msi"

# 3. 서명 확인
signtool verify /pa "./target/release/bundle/msi/MyApp_1.0.0_x64_en-US.msi"
```

**tauri.conf.json 설정:**

```json
{
  "bundle": {
    "windows": {
      "certificateThumbprint": "YOUR_CERT_THUMBPRINT",
      "timestampUrl": "http://timestamp.digicert.com",
      "digestAlgorithm": "sha256",
      "wix": {
        "language": "en-US"
      }
    }
  }
}
```

**GitHub Actions CI/CD:**

```yaml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4

      - name: Install dependencies
        run: pnpm install

      - name: Import signing certificate
        env:
          MACOS_CERTIFICATE: ${{ secrets.MACOS_CERTIFICATE }}
          MACOS_CERTIFICATE_PWD: ${{ secrets.MACOS_CERTIFICATE_PWD }}
        run: |
          echo $MACOS_CERTIFICATE | base64 --decode > certificate.p12
          security create-keychain -p actions temp.keychain
          security default-keychain -s temp.keychain
          security unlock-keychain -p actions temp.keychain
          security import certificate.p12 -k temp.keychain -P $MACOS_CERTIFICATE_PWD -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k actions temp.keychain

      - name: Build and sign
        run: pnpm tauri build

      - name: Notarize
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: |
          xcrun notarytool submit \
            ./target/release/bundle/macos/MyApp.app.zip \
            --apple-id "$APPLE_ID" \
            --password "$APPLE_PASSWORD" \
            --team-id "$APPLE_TEAM_ID" \
            --wait
          xcrun stapler staple ./target/release/bundle/macos/MyApp.app

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4

      - name: Install dependencies
        run: pnpm install

      - name: Build
        run: pnpm tauri build

      - name: Sign
        env:
          WINDOWS_CERTIFICATE: ${{ secrets.WINDOWS_CERTIFICATE }}
          WINDOWS_CERTIFICATE_PASSWORD: ${{ secrets.WINDOWS_CERTIFICATE_PASSWORD }}
        run: |
          echo $env:WINDOWS_CERTIFICATE | Out-File -FilePath certificate.txt
          certutil -decode certificate.txt certificate.pfx
          signtool sign /f certificate.pfx /p $env:WINDOWS_CERTIFICATE_PASSWORD /tr http://timestamp.digicert.com /td sha256 /fd sha256 .\target\release\bundle\msi\*.msi
```

## 추가 컨텍스트

**플랫폼별 서명 체크리스트:**

| 플랫폼 | 필수 단계 | 비용 |
|--------|----------|------|
| macOS | Developer ID Application 인증서 + 공증 | $99/년 (Apple Developer) |
| Windows | Code Signing Certificate | $100-500/년 |
| Linux | 서명 선택사항 (권장하지만 필수 아님) | 무료 |

**인증서 종류:**
- **macOS**: Developer ID Application (App Store 외부 배포)
- **Windows**: Extended Validation (EV) 또는 Standard Code Signing
- **Linux**: GPG 서명 (선택사항)

**공증 (Notarization) 필수:**
- macOS Catalina 이상에서 공증 없으면 실행 불가
- 공증은 서명 후 Apple 서버에 앱 업로드하여 악성 코드 스캔
- 통과 시 티켓 발급 → stapler로 앱에 첨부

**Secrets 관리:**
- GitHub Actions Secrets에 인증서/비밀번호 저장
- 절대 코드에 하드코딩 금지
- `.gitignore`에 `*.p12`, `*.pfx` 추가

**참고:** [Tauri Code Signing Guide](https://beta.tauri.app/distribute/sign/)

영향도: CRITICAL - 사용자 신뢰, 앱 설치율, 보안
