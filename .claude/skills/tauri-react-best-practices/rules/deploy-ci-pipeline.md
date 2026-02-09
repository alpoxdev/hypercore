# GitHub Actions 멀티 플랫폼 빌드

## 왜 중요한가

Tauri 앱을 수동으로 빌드하면 플랫폼별 환경 설정이 복잡하고 시간이 오래 걸립니다. GitHub Actions로 자동화하면 태그 푸시만으로 Linux/macOS/Windows 빌드를 병렬로 진행하고, 서명/공증/릴리스까지 원스톱으로 처리할 수 있습니다.

## ❌ 잘못된 패턴

```bash
# ❌ 수동 빌드 (플랫폼마다 반복)
# macOS
pnpm tauri build
codesign ...
notarize ...

# Windows (별도 PC에서)
pnpm tauri build
signtool ...

# Linux (별도 환경에서)
pnpm tauri build

# 릴리스 수동 업로드
gh release upload v1.0.0 ./target/release/bundle/**/*
```

**문제점:**
- 플랫폼마다 수동 빌드 필요 (시간 소요)
- 환경 설정 불일치로 빌드 실패 위험
- 서명/공증 단계 누락 가능
- 릴리스 업로드 실수

## ✅ 올바른 패턴

### GitHub Actions Workflow (전체 파이프라인)

```yaml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    permissions:
      contents: write
    strategy:
      fail-fast: false
      matrix:
        include:
          - platform: macos-latest
            target: aarch64-apple-darwin
          - platform: macos-latest
            target: x86_64-apple-darwin
          - platform: windows-latest
            target: x86_64-pc-windows-msvc
          - platform: ubuntu-22.04
            target: x86_64-unknown-linux-gnu

    runs-on: ${{ matrix.platform }}
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v2
        with:
          version: 8

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.target }}

      - name: Install Linux dependencies
        if: matrix.platform == 'ubuntu-22.04'
        run: |
          sudo apt-get update
          sudo apt-get install -y \
            libwebkit2gtk-4.1-dev \
            libappindicator3-dev \
            librsvg2-dev \
            patchelf

      - name: Install frontend dependencies
        run: pnpm install

      # macOS 서명 설정
      - name: Import macOS certificate
        if: matrix.platform == 'macos-latest'
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

      # 빌드 + 서명
      - name: Build app
        env:
          TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
          TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
        run: pnpm tauri build --target ${{ matrix.target }}

      # macOS 공증
      - name: Notarize macOS app
        if: matrix.platform == 'macos-latest'
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: |
          xcrun notarytool submit \
            ./target/${{ matrix.target }}/release/bundle/macos/*.app.tar.gz \
            --apple-id "$APPLE_ID" \
            --password "$APPLE_PASSWORD" \
            --team-id "$APPLE_TEAM_ID" \
            --wait
          xcrun stapler staple ./target/${{ matrix.target }}/release/bundle/macos/*.app

      # Windows 서명
      - name: Sign Windows app
        if: matrix.platform == 'windows-latest'
        env:
          WINDOWS_CERTIFICATE: ${{ secrets.WINDOWS_CERTIFICATE }}
          WINDOWS_CERTIFICATE_PASSWORD: ${{ secrets.WINDOWS_CERTIFICATE_PASSWORD }}
        run: |
          echo $env:WINDOWS_CERTIFICATE | Out-File -FilePath certificate.txt
          certutil -decode certificate.txt certificate.pfx
          Get-ChildItem ./target/${{ matrix.target }}/release/bundle/msi/*.msi | ForEach-Object {
            signtool sign /f certificate.pfx /p $env:WINDOWS_CERTIFICATE_PASSWORD /tr http://timestamp.digicert.com /td sha256 /fd sha256 $_
          }

      # GitHub Release 업로드
      - name: Upload to GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            ./target/${{ matrix.target }}/release/bundle/macos/*.dmg
            ./target/${{ matrix.target }}/release/bundle/msi/*.msi
            ./target/${{ matrix.target }}/release/bundle/appimage/*.AppImage
            ./target/${{ matrix.target }}/release/bundle/deb/*.deb
          draft: true
          prerelease: false
```

### GitHub Secrets 설정 가이드

**필수 Secrets (Repository → Settings → Secrets):**

| Secret 이름 | 설명 | 획득 방법 |
|-------------|------|----------|
| `MACOS_CERTIFICATE` | macOS 코드 서명 인증서 (base64) | `base64 -i certificate.p12` |
| `MACOS_CERTIFICATE_PWD` | 인증서 비밀번호 | Keychain Access에서 설정 |
| `APPLE_ID` | Apple ID 이메일 | Apple Developer 계정 |
| `APPLE_PASSWORD` | App-specific password | appleid.apple.com에서 생성 |
| `APPLE_TEAM_ID` | Apple Team ID | Developer 계정에서 확인 |
| `WINDOWS_CERTIFICATE` | Windows 코드 서명 인증서 (base64) | `[Convert]::ToBase64String([IO.File]::ReadAllBytes("cert.pfx"))` |
| `WINDOWS_CERTIFICATE_PASSWORD` | 인증서 비밀번호 | 인증서 발급 시 설정 |
| `TAURI_SIGNING_PRIVATE_KEY` | Updater 서명 private 키 | `pnpm tauri signer generate` |
| `TAURI_SIGNING_PRIVATE_KEY_PASSWORD` | 서명 키 비밀번호 | 생성 시 설정 (없으면 빈 문자열) |

### tauri-action 사용 (간소화 버전)

```yaml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    permissions:
      contents: write
    strategy:
      fail-fast: false
      matrix:
        platform: [macos-latest, ubuntu-22.04, windows-latest]

    runs-on: ${{ matrix.platform }}
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Install Linux dependencies
        if: matrix.platform == 'ubuntu-22.04'
        run: |
          sudo apt-get update
          sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf

      - name: Install frontend dependencies
        run: pnpm install

      - uses: tauri-apps/tauri-action@v0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
          APPLE_CERTIFICATE: ${{ secrets.APPLE_CERTIFICATE }}
          APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        with:
          tagName: ${{ github.ref_name }}
          releaseName: 'App v__VERSION__'
          releaseBody: 'See the assets to download this version.'
          releaseDraft: true
          prerelease: false
```

### 릴리스 트리거 방법

```bash
# 1. 버전 업데이트 (package.json, tauri.conf.json)
pnpm version 1.0.1

# 2. 태그 생성 및 푸시
git tag v1.0.1
git push origin v1.0.1

# 3. GitHub Actions 자동 실행 (Release 탭에서 확인)
```

## 추가 컨텍스트

**matrix 빌드 장점:**
- 플랫폼별 빌드를 병렬로 실행 (시간 절약)
- 환경 불일치 방지 (GitHub 호스팅 러너 사용)
- 빌드 실패 시 다른 플랫폼은 계속 진행 (`fail-fast: false`)

**Linux 의존성:**
- Ubuntu 22.04 권장 (최신 라이브러리)
- `libwebkit2gtk-4.1-dev`: WebView 렌더링
- `patchelf`: 바이너리 수정 도구

**릴리스 전략:**
- `draft: true`: 수동으로 릴리스 퍼블리시 (테스트 후 배포)
- `prerelease: false`: 정식 릴리스로 표시
- `tagName`: Git 태그와 릴리스 이름 일치

**빌드 산출물:**
- macOS: `.dmg`, `.app.tar.gz`
- Windows: `.msi`, `.exe` (Installer)
- Linux: `.deb`, `.AppImage`, `.rpm`

**자동 업데이트 통합:**
- `.tar.gz.sig` 파일도 함께 업로드 필요
- Updater 엔드포인트를 GitHub Releases로 설정

**참고:** [tauri-action GitHub](https://github.com/tauri-apps/tauri-action)

영향도: HIGH - 배포 자동화, 멀티 플랫폼 지원, 릴리스 신뢰성
