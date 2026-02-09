# Mobile Development

> Tauri v2 iOS & Android 모바일 개발 가이드

---

## iOS Prerequisites (macOS 전용)

```bash
# 1. Xcode 설치 (App Store → 실행하여 초기 설정 완료)

# 2. iOS Rust 타겟 추가
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

# 3. Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. CocoaPods 설치
brew install cocoapods
```

**중요:** iOS 개발은 macOS에서만 가능합니다.

---

## Android Prerequisites

### 1. Android Studio 설치

[Android Developer](https://developer.android.com/studio) 에서 다운로드

### 2. 환경 변수 설정

```bash
# ~/.bashrc 또는 ~/.zshrc
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
# Windows: C:\Program Files\Android\Android Studio\jbr
# Linux: /opt/android-studio/jbr

export ANDROID_HOME="$HOME/Android/Sdk"
# macOS: $HOME/Library/Android/sdk
# Windows: %LOCALAPPDATA%\Android\Sdk

export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"
```

### 3. SDK Manager 설정 (Android Studio)

SDK Manager에서 설치:
- Android SDK Platform (최신)
- Android SDK Platform-Tools
- NDK (Side by side)
- Android SDK Build-Tools
- Android SDK Command-line Tools

### 4. Rust 타겟 추가

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
```

---

## 프로젝트 초기화

```bash
# iOS 프로젝트 초기화
npx tauri ios init

# Android 프로젝트 초기화
npx tauri android init
```

**생성되는 파일:**
```
src-tauri/
├── gen/
│   ├── apple/          # Xcode 프로젝트
│   └── android/        # Android Studio 프로젝트
```

---

## 개발 모드

### iOS

```bash
# 시뮬레이터에서 실행
npx tauri ios dev

# Xcode에서 열기 (디바이스 선택, 디버깅)
npx tauri ios dev --open

# 물리 디바이스 연결 시 IP 지정
npx tauri ios dev --host
```

**Web Inspector:** Safari → Develop 메뉴 → 디바이스/시뮬레이터 선택

### Android

```bash
# 에뮬레이터에서 실행
npx tauri android dev

# Android Studio에서 열기
npx tauri android dev --open

# 물리 디바이스 연결 시
npx tauri android dev --host
```

**Web Inspector:** Chrome → `chrome://inspect` → Remote Devices

---

## 모바일 빌드

### iOS

```bash
# 릴리스 빌드 (IPA)
npx tauri ios build

# App Store 제출용
npx tauri ios build --export-method app-store-connect
```

**IPA 위치:** `src-tauri/gen/apple/build/arm64/$APPNAME.ipa`

### Android

```bash
# AAB (Google Play 권장)
npx tauri android build -- --aab

# APK (사이드로딩/테스트)
npx tauri android build -- --apk

# 특정 아키텍처만
npx tauri android build -- --aab --target aarch64
```

**AAB 위치:** `gen/android/app/build/outputs/bundle/universalRelease/app-universal-release.aab`

---

## 플랫폼별 설정

```json
// tauri.android.conf.json (Android 전용 오버라이드)
{
  "bundle": {
    "android": {
      "minSdkVersion": 24,
      "versionCode": 1
    }
  }
}
```

```json
// tauri.ios.conf.json (iOS 전용 오버라이드)
{
  "bundle": {
    "iOS": {}
  }
}
```

---

## 앱 아이콘

```bash
# 플랫폼 초기화 후 아이콘 생성
npx tauri icon /path/to/app-icon.png

# iOS 배경색 지정
npx tauri icon /path/to/app-icon.png -- --ios-color '#ffffff'
```

**권장:** 1024x1024 PNG, 알파 채널 포함

---

## 앱 배포

### iOS App Store

1. **Apple Developer Program** 등록 ($99/년)
2. **App Store Connect** 에서 앱 등록 (Bundle ID = `tauri.conf.json > identifier`)
3. **코드 서명** 설정

```bash
# App Store용 빌드
npx tauri ios build --export-method app-store-connect

# App Store Connect API 키 설정
# AuthKey_<KEY_ID>.p8 → ~/.appstoreconnect/private_keys/

# 업로드
xcrun altool --upload-app --type ios \
  --file "src-tauri/gen/apple/build/arm64/$APPNAME.ipa" \
  --apiKey $APPLE_API_KEY_ID --apiIssuer $APPLE_API_ISSUER
```

### Google Play

1. **Play Console** 개발자 계정 생성
2. **앱 등록** 후 코드 서명 설정

```bash
# AAB 빌드
npx tauri android build -- --aab

# 번들 위치
# gen/android/app/build/outputs/bundle/universalRelease/app-universal-release.aab
# Play Console에서 수동 업로드 (첫 번째 릴리스)
```

---

## Mobile Plugin 개발

### 아키텍처

```
plugin/
├── src/
│   ├── lib.rs         # 공유 로직
│   ├── desktop.rs     # 데스크톱 구현
│   └── mobile.rs      # 모바일 브릿지
├── android/
│   └── src/.../MyPlugin.kt   # Kotlin 구현
└── ios/
    └── Sources/MyPlugin.swift  # Swift 구현
```

### Android (Kotlin)

```kotlin
@TauriPlugin
class MyPlugin : Plugin() {
    @Command
    fun doSomething(invoke: Invoke) {
        // 블로킹 I/O → 별도 스레드 필수
        CoroutineScope(Dispatchers.IO).launch {
            val result = heavyWork()
            val ret = JSObject()
            ret.put("data", result)
            invoke.resolve(ret)
        }
    }
}
```

### iOS (Swift)

```swift
public class MyPlugin: Plugin {
    @objc public func doSomething(_ invoke: Invoke) throws {
        let result = heavyWork()
        invoke.resolve(["data": result])
    }
}
```

### Rust에서 호출

```rust
// mobile.rs
self.0.run_mobile_plugin("doSomething", payload)
```

---

## 모바일 개발 팁

| 항목 | 설명 |
|------|------|
| **HMR** | 프론트엔드 변경 → 모바일에서도 즉시 반영 |
| **Rust HMR** | Rust 코드 변경 → 자동 재컴파일 |
| **첫 빌드** | Rust 패키지 다운로드로 수 분 소요 (이후 캐싱) |
| **Android 메인 스레드** | 블로킹 I/O → UI 프리징, Coroutine 사용 필수 |
| **iOS macOS 전용** | iOS 개발/빌드는 macOS에서만 가능 |
| **최소 Android** | SDK 24 (Android 7.0) |
