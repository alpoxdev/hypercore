# Configuration

> Tauri v2 설정 상세 가이드

---

## 플랫폼별 설정

```
src-tauri/
├── tauri.conf.json              # 공통 설정
├── tauri.windows.conf.json      # Windows 오버라이드
├── tauri.macos.conf.json        # macOS 오버라이드
├── tauri.linux.conf.json        # Linux 오버라이드
├── tauri.android.conf.json      # Android 오버라이드
└── tauri.ios.conf.json          # iOS 오버라이드
```

---

## 핵심 설정 필드

```json
{
  "productName": "My App",
  "version": "1.0.0",
  "identifier": "com.example.myapp",
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:5173",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [{ "title": "My App", "width": 1024, "height": 768 }],
    "security": { "csp": "..." }
  },
  "bundle": {
    "active": true,
    "targets": ["deb", "rpm", "appimage", "msi", "nsis", "dmg", "app"],
    "icon": ["icons/32x32.png", "icons/icon.icns", "icons/icon.ico"],
    "android": { "minSdkVersion": 24 },
    "macOS": { "minimumSystemVersion": "10.13" }
  }
}
```
