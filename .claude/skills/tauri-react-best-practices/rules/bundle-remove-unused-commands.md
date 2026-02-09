---
title: Remove Unused Tauri Commands
impact: MEDIUM
impactDescription: reduces bundle by excluding unused commands
tags: bundle, commands, tauri-build, optimization, v2.4
---

# 미사용 Tauri 커맨드 자동 제거

## 왜 중요한가

Tauri v2.4부터 빌드 시스템이 프론트엔드 코드를 정적 분석하여 **실제로 사용되지 않는 커맨드를 바이너리에서 자동으로 제거**할 수 있습니다. 이는 특히 많은 커맨드를 정의했지만 일부만 사용하는 앱에서 효과적입니다.

## ❌ 잘못된 패턴

**기본 설정 (tauri.config.json):**

```json
{
  "build": {
    "beforeDevCommand": "npm run dev",
    "devPath": "http://localhost:1420",
    "beforeBuildCommand": "npm run build",
    "frontendDist": "../dist"
    // removeUnusedCommands 설정 없음
  }
}
```

**Rust 코드에 정의된 커맨드:**

```rust
// src-tauri/src/main.rs
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

#[tauri::command]
fn calculate(a: i32, b: i32) -> i32 {
    a + b
}

#[tauri::command]
fn get_system_info() -> String {
    // 복잡한 로직...
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            greet,
            calculate,
            get_system_info // 프론트엔드에서 사용하지 않음!
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

**프론트엔드 코드:**

```typescript
// src/App.tsx
import { invoke } from '@tauri-apps/api/core'

function App() {
  const handleClick = async () => {
    await invoke('greet', { name: 'World' })
    await invoke('calculate', { a: 1, b: 2 })
    // get_system_info는 호출하지 않음
  }
  return <button onClick={handleClick}>Call</button>
}
```

**문제:**
- `get_system_info` 커맨드가 바이너리에 포함됨
- 미사용 커맨드의 의존성도 함께 번들에 포함

## ✅ 올바른 패턴

**tauri.config.json에 removeUnusedCommands 활성화:**

```json
{
  "build": {
    "beforeDevCommand": "npm run dev",
    "devPath": "http://localhost:1420",
    "beforeBuildCommand": "npm run build",
    "frontendDist": "../dist",
    "removeUnusedCommands": true
  }
}
```

**Cargo.toml 버전 확인:**

```toml
[build-dependencies]
# tauri-build 2.1.0 이상 필요
tauri-build = "^2.1"

[dependencies]
# tauri 2.4.0 이상 필요
tauri = "^2.4"
```

**빌드 로그 확인:**

```bash
npm run tauri build
```

**출력:**
```
[INFO] Analyzing frontend code for command usage...
[INFO] Found commands: greet, calculate
[INFO] Removing unused commands: get_system_info
[INFO] Building optimized bundle...
```

## 추가 컨텍스트

**요구 버전:**
- Tauri: **2.4.0 이상**
- tauri-build: **2.1.0 이상**

**작동 원리:**
1. `tauri-build`가 프론트엔드 번들을 정적 분석
2. `invoke('command_name', ...)`로 호출되는 커맨드 목록 추출
3. `generate_handler!` 매크로에서 미사용 커맨드 제거
4. 바이너리 컴파일 시 미사용 코드 제외

**제약 사항:**
- 동적 커맨드 이름은 감지 불가:
  ```typescript
  // ❌ 감지 안됨
  const cmd = 'greet'
  invoke(cmd, { name: 'World' })
  ```
- 정적 문자열만 감지:
  ```typescript
  // ✅ 감지됨
  invoke('greet', { name: 'World' })
  ```

**효과:**
- 미사용 커맨드가 많을수록 효과 증가
- 5-10개 커맨드 중 2-3개만 사용: ~10-20% 크기 감소
- 특히 무거운 의존성이 있는 커맨드 제거 시 효과적

**참고:**
- Tauri v2.4 Release Notes: [Remove Unused Commands](https://v2.tauri.app/blog/tauri-2-4/#remove-unused-commands)
- tauri-build Documentation: [Command Analysis](https://docs.rs/tauri-build/latest/tauri_build/)

**영향도:**
- 크기: MEDIUM (10-20% 감소 가능)
- 빌드 시간: NEUTRAL (분석 오버헤드 미미)
- 개발 경험: POSITIVE (자동 최적화)
