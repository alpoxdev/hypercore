# 모바일 호환성 확인

## 왜 중요한가

Tauri v2는 iOS/Android를 지원하지만, 일부 플러그인과 API는 데스크톱 전용입니다. 모바일에서 미지원 API를 호출하면 런타임 에러나 크래시가 발생합니다. 플랫폼별 조건부 코드를 작성해야 크로스 플랫폼 앱을 안정적으로 배포할 수 있습니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { open } from '@tauri-apps/plugin-dialog'

function FilePicker() {
  const selectFile = async () => {
    // ❌ 모바일에서 dialog 플러그인 미지원 (크래시)
    const file = await open({
      multiple: false,
      directory: false
    })
    console.log(file)
  }

  return <button onClick={selectFile}>Select File</button>
}
```

**문제점:**
- 플랫폼 구분 없이 데스크톱 전용 API 사용
- 모바일에서 런타임 에러 발생
- 플랫폼별 대체 로직 없음

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { open } from '@tauri-apps/plugin-dialog'
import { platform } from '@tauri-apps/plugin-os'

function FilePicker() {
  const selectFile = async () => {
    const os = await platform()

    if (os === 'android' || os === 'ios') {
      // ✅ 모바일: 네이티브 파일 피커 사용
      const result = await invoke<string>('mobile_pick_file')
      console.log(result)
    } else {
      // ✅ 데스크톱: dialog 플러그인 사용
      const file = await open({
        multiple: false,
        directory: false
      })
      console.log(file)
    }
  }

  return <button onClick={selectFile}>Select File</button>
}
```

**Rust 측 플랫폼 조건부 컴파일:**

```rust
#[tauri::command]
fn get_system_info() -> String {
    #[cfg(target_os = "android")]
    {
        "Android".to_string()
    }

    #[cfg(target_os = "ios")]
    {
        "iOS".to_string()
    }

    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        "Desktop".to_string()
    }
}
```

**모바일 전용 플러그인 사용:**

```rust
// Cargo.toml
[dependencies]
tauri-plugin-barcode-scanner = "2.0.0-beta"  // 모바일 전용

// src/lib.rs
#[cfg(mobile)]
use tauri_plugin_barcode_scanner::BarcodeScanner;

fn main() {
    tauri::Builder::default()
        .plugin(
            #[cfg(mobile)]
            tauri_plugin_barcode_scanner::init()
        )
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**React Native 스타일 플랫폼 분기:**

```tsx
import { platform } from '@tauri-apps/plugin-os'
import { useEffect, useState } from 'react'

function usePlatform() {
  const [os, setOs] = useState<string>('unknown')

  useEffect(() => {
    platform().then(setOs)
  }, [])

  return {
    os,
    isDesktop: ['windows', 'macos', 'linux'].includes(os),
    isMobile: ['android', 'ios'].includes(os),
    isAndroid: os === 'android',
    isIOS: os === 'ios'
  }
}

function App() {
  const { isDesktop, isMobile } = usePlatform()

  return (
    <div>
      {isDesktop && <DesktopMenu />}
      {isMobile && <MobileTabBar />}
    </div>
  )
}
```

**파일 경로 처리:**

```tsx
import { appDataDir, join } from '@tauri-apps/api/path'
import { platform } from '@tauri-apps/plugin-os'

async function getConfigPath() {
  const os = await platform()
  const dataDir = await appDataDir()

  if (os === 'android') {
    // Android: /data/data/com.example.app/files
    return await join(dataDir, 'config.json')
  } else if (os === 'ios') {
    // iOS: /var/mobile/Containers/Data/Application/.../Documents
    return await join(dataDir, 'config.json')
  } else {
    // Desktop: ~/.local/share/com.example.app
    return await join(dataDir, 'config.json')
  }
}
```

**모바일 미지원 플러그인 목록:**

| 플러그인 | 데스크톱 | 모바일 | 대체 방법 |
|---------|---------|--------|----------|
| dialog | ✅ | ❌ | 네이티브 UI 사용 |
| global-shortcut | ✅ | ❌ | 모바일은 제스처 사용 |
| updater | ✅ | ❌ | Play Store/App Store 업데이트 |
| window (일부) | ✅ | ⚠️ | 일부 API만 지원 |
| shell (open) | ✅ | ✅ | URL 열기만 지원 |
| fs | ✅ | ✅ | 전체 지원 |
| http | ✅ | ✅ | 전체 지원 |

## 추가 컨텍스트

**모바일 개발 시 체크리스트:**
1. `platform()` API로 플랫폼 구분
2. 데스크톱 전용 플러그인 조건부 사용
3. 파일 경로 플랫폼별 처리
4. UI/UX 모바일 최적화 (터치, 작은 화면)
5. 권한 요청 (카메라, 위치 등)

**Rust cfg 속성:**
```rust
#[cfg(target_os = "android")]  // Android 전용
#[cfg(target_os = "ios")]      // iOS 전용
#[cfg(mobile)]                 // Android + iOS
#[cfg(desktop)]                // Windows + macOS + Linux
#[cfg(not(mobile))]            // 데스크톱만
```

**권장 사항:**
- 플랫폼별 빌드 후 실제 기기에서 테스트
- 에뮬레이터/시뮬레이터에서 미지원 API 확인
- `try/catch`로 런타임 에러 처리

**참고:** [Tauri Mobile Guide](https://beta.tauri.app/develop/mobile/)

영향도: HIGH - 모바일 앱 안정성, 크로스 플랫폼 호환성
