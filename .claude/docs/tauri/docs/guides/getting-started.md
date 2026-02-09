# Getting Started

> Tauri v2 + React + TypeScript + Vite 프로젝트 시작 가이드

---

## Prerequisites

### 모든 플랫폼 공통

```bash
# Rust 설치
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node.js (LTS)
# https://nodejs.org/ 에서 설치
```

### macOS

```bash
# Xcode Command Line Tools
xcode-select --install
# 또는 App Store에서 Xcode 설치 (iOS 개발 시 필수)
```

### Windows

1. **Visual Studio Build Tools** 설치
   - "Desktop development with C++" 워크로드 선택
   - MSVC 툴체인 기본 선택 확인
2. **WebView2 Runtime** (Windows 10 v1803+ 기본 포함)
3. **VBSCRIPT** feature (MSI 패키지 빌드 시)

### Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y libwebkit2gtk-4.1-dev build-essential curl wget \
  libssl-dev libgtk-3-dev librsvg2-dev libappindicator3-dev patchelf
```

---

## 프로젝트 생성

### 방법 1: create-tauri-app (권장)

```bash
# npm
npm create tauri-app@latest

# 대화형 프롬프트:
# - Project name: my-app
# - Identifier: com.example.myapp
# - Frontend language: TypeScript / JavaScript
# - Package manager: npm (또는 pnpm, yarn)
# - UI template: React
# - UI flavor: TypeScript
```

### 방법 2: 기존 Vite 프로젝트에 추가

```bash
# 1. Vite + React + TS 프로젝트 생성
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install

# 2. Tauri CLI 설치
npm add -D @tauri-apps/cli@latest

# 3. Tauri 초기화
npx tauri init
# - App name: my-app
# - Window title: My App
# - Web assets location: ../dist
# - Dev server URL: http://localhost:5173
# - Dev command: npm run dev
# - Build command: npm run build

# 4. Tauri API 패키지
npm add @tauri-apps/api
```

---

## 개발 시작

```bash
# 개발 서버 + Tauri 앱 실행
npx tauri dev

# 또는 package.json에 스크립트 추가
# "tauri": "tauri"
npm run tauri dev
```

**개발 모드 특징:**
- Vite HMR (프론트엔드 변경 → 즉시 반영)
- Rust 코드 변경 → 자동 재컴파일
- DevTools 접근 가능

---

## 프로젝트 구조

```
my-app/
├── src/                         # React + TypeScript (프론트엔드)
│   ├── main.tsx                 # React 엔트리
│   ├── App.tsx                  # 루트 컴포넌트
│   ├── App.css
│   └── components/
├── src-tauri/                   # Rust (백엔드)
│   ├── src/
│   │   ├── main.rs              # 데스크톱 엔트리
│   │   └── lib.rs               # 공유 로직 (모바일 지원)
│   ├── capabilities/
│   │   └── default.json         # 기본 권한
│   ├── icons/                   # 앱 아이콘
│   ├── Cargo.toml               # Rust 의존성
│   ├── tauri.conf.json          # Tauri 설정
│   └── build.rs                 # 빌드 스크립트
├── public/                      # 정적 파일
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

---

## Vite 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const host = process.env.TAURI_DEV_HOST;

export default defineConfig({
  plugins: [react()],
  clearScreen: false,
  server: {
    port: 5173,
    strictPort: true,              // Tauri가 기대하는 포트 보장
    host: host || false,           // 모바일 물리 디바이스 개발 시
    hmr: host
      ? { protocol: 'ws', host, port: 1421 }
      : undefined,
    watch: {
      ignored: ['**/src-tauri/**'], // Rust 재빌드 트리거 방지
    },
  },
  envPrefix: ['VITE_', 'TAURI_ENV_*'],
  build: {
    target: process.env.TAURI_ENV_PLATFORM === 'windows'
      ? 'chrome105'
      : 'safari13',
    minify: !process.env.TAURI_ENV_DEBUG ? 'esbuild' : false,
    sourcemap: !!process.env.TAURI_ENV_DEBUG,
  },
});
```

---

## Tauri 설정 (tauri.conf.json)

```json
{
  "productName": "my-app",
  "version": "0.1.0",
  "identifier": "com.example.myapp",
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:5173",
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      {
        "title": "My App",
        "width": 1024,
        "height": 768,
        "resizable": true,
        "fullscreen": false
      }
    ],
    "security": {
      "csp": {
        "default-src": "'self' customprotocol: asset:",
        "connect-src": "ipc: http://ipc.localhost",
        "img-src": "'self' asset: http://asset.localhost blob: data:",
        "style-src": "'unsafe-inline' 'self'"
      }
    }
  },
  "bundle": {
    "active": true,
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ]
  }
}
```

---

## 첫 번째 Command 만들기

### 1. Rust Command 정의

```rust
// src-tauri/src/lib.rs
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```rust
// src-tauri/src/main.rs
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    my_app_lib::run()
}
```

### 2. 프론트엔드에서 호출

```tsx
// src/App.tsx
import { useState } from 'react';
import { invoke } from '@tauri-apps/api/core';

function App() {
  const [greeting, setGreeting] = useState('');
  const [name, setName] = useState('');

  async function handleGreet() {
    const result = await invoke<string>('greet', { name });
    setGreeting(result);
  }

  return (
    <div>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <button onClick={handleGreet}>Greet</button>
      <p>{greeting}</p>
    </div>
  );
}

export default App;
```

### 3. Capability 추가 (필요 시)

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "기본 앱 권한",
  "windows": ["main"],
  "permissions": [
    "core:default"
  ]
}
```

---

## CLI 명령어

| 명령어 | 설명 |
|--------|------|
| `npx tauri dev` | 개발 모드 실행 |
| `npx tauri build` | 프로덕션 빌드 |
| `npx tauri icon <path>` | 앱 아이콘 생성 |
| `npx tauri info` | 시스템 정보 출력 |
| `npx tauri init` | Tauri 프로젝트 초기화 |
| `npx tauri android init` | Android 프로젝트 초기화 |
| `npx tauri ios init` | iOS 프로젝트 초기화 |
| `npx tauri android dev` | Android 개발 모드 |
| `npx tauri ios dev` | iOS 개발 모드 |
