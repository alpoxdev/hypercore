# Mobile Architecture

> Tauri v2 모바일 아키텍처 상세 가이드

---

## 엔트리포인트 구조

```rust
// lib.rs - 공유 로직 (데스크톱 + 모바일)
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![...])
        .run(tauri::generate_context!())
        .expect("error");
}

// main.rs - 데스크톱 전용
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
fn main() {
    my_app_lib::run()
}
```

---

## Mobile Plugin 구조

```
plugin/
├── src/
│   ├── lib.rs          # 공유 로직
│   ├── desktop.rs      # 데스크톱 구현
│   └── mobile.rs       # 모바일 브릿지 (Kotlin/Swift 호출)
├── android/
│   └── src/.../Plugin.kt   # Kotlin 구현
└── ios/
    └── Sources/Plugin.swift  # Swift 구현
```

---

## 플랫폼 설정

| 파일 | 용도 |
|------|------|
| `tauri.conf.json` | 공통 설정 |
| `tauri.android.conf.json` | Android 오버라이드 |
| `tauri.ios.conf.json` | iOS 오버라이드 |
| `tauri.windows.conf.json` | Windows 오버라이드 |
| `tauri.macos.conf.json` | macOS 오버라이드 |
| `tauri.linux.conf.json` | Linux 오버라이드 |

---

## 모바일 개발 주의사항

| 항목 | 설명 |
|------|------|
| **iOS 개발** | macOS에서만 가능 |
| **Android 메인 스레드** | 블로킹 I/O → UI 프리징, Coroutine 사용 필수 |
| **최소 Android SDK** | 24 (Android 7.0) |
| **lib.rs 엔트리포인트** | 모바일은 라이브러리로 로드 |
