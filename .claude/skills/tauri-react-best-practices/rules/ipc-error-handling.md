---
title: Use Structured Error Types with thiserror
impact: CRITICAL
impactDescription: Debuggable errors, error code-based handling
tags: ipc, error-handling, thiserror, serde, tauri-v2
---

# 구조화된 에러 타입으로 디버깅 향상

## 왜 중요한가

`Result<T, String>` 같은 단순 에러는 디버깅이 어렵고 프론트엔드에서 에러 종류별 처리가 불가능합니다. `thiserror`로 구조화된 에러를 정의하고 `serde::Serialize`를 구현하면 타입 안전하고 디버깅 가능한 에러 처리가 가능합니다.

**영향도:**
- 디버깅: 에러 종류, 원인 명확화
- UX: 에러별 맞춤 메시지 표시
- 유지보수: 에러 코드 기반 처리

## ❌ 잘못된 패턴

**단순 String 에러:**

```rust
// ❌ String 에러 (종류 구분 불가)
#[tauri::command]
fn read_file(path: String) -> Result<String, String> {
  std::fs::read_to_string(&path)
    .map_err(|e| e.to_string()) // 에러 타입 정보 손실
}

#[tauri::command]
fn delete_file(path: String) -> Result<(), String> {
  std::fs::remove_file(&path)
    .map_err(|e| format!("Failed to delete: {}", e))
}
```

```typescript
// ❌ 프론트엔드: 에러 문자열 파싱으로 종류 판단
try {
  await invoke('read_file', { path: '/secret.txt' });
} catch (err) {
  // 문자열 파싱으로 에러 종류 추측 (취약함)
  if (err.includes('permission')) {
    alert('권한이 없습니다');
  } else if (err.includes('not found')) {
    alert('파일을 찾을 수 없습니다');
  }
}
```

**문제점:**
- 에러 종류 구분 불가
- 디버깅 정보 부족
- 프론트엔드에서 일관된 처리 어려움

## ✅ 올바른 패턴

**thiserror로 구조화된 에러:**

### 1. 의존성 추가

```toml
# src-tauri/Cargo.toml
[dependencies]
thiserror = "2.0"
serde = { version = "1.0", features = ["derive"] }
```

### 2. 에러 타입 정의

```rust
use serde::{Serialize, Serializer};
use thiserror::Error;

// ✅ 구조화된 에러 enum
#[derive(Debug, Error)]
enum AppError {
  #[error("File not found: {path}")]
  FileNotFound { path: String },

  #[error("Permission denied: {path}")]
  PermissionDenied { path: String },

  #[error("Invalid file format: expected {expected}, got {actual}")]
  InvalidFormat { expected: String, actual: String },

  #[error("Network error: {0}")]
  Network(String),

  #[error(transparent)]
  Io(#[from] std::io::Error),
}

// ✅ Serialize 구현으로 JSON 변환
impl Serialize for AppError {
  fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
  where
    S: Serializer,
  {
    use serde::ser::SerializeStruct;

    let mut state = serializer.serialize_struct("AppError", 2)?;

    // 에러 코드
    let code = match self {
      AppError::FileNotFound { .. } => "FILE_NOT_FOUND",
      AppError::PermissionDenied { .. } => "PERMISSION_DENIED",
      AppError::InvalidFormat { .. } => "INVALID_FORMAT",
      AppError::Network(_) => "NETWORK_ERROR",
      AppError::Io(_) => "IO_ERROR",
    };
    state.serialize_field("code", code)?;

    // 에러 메시지
    state.serialize_field("message", &self.to_string())?;

    state.end()
  }
}
```

### 3. 커맨드에서 사용

```rust
#[tauri::command]
fn read_file(path: String) -> Result<String, AppError> {
  // 자동 변환: std::io::Error -> AppError::Io
  let content = std::fs::read_to_string(&path)?;
  Ok(content)
}

#[tauri::command]
fn process_config(path: String) -> Result<Config, AppError> {
  let content = std::fs::read_to_string(&path)
    .map_err(|_| AppError::FileNotFound { path: path.clone() })?;

  if !content.starts_with('[') {
    return Err(AppError::InvalidFormat {
      expected: "JSON".to_string(),
      actual: "Plain text".to_string(),
    });
  }

  // 파싱 로직...
  Ok(Config::default())
}
```

### 4. 프론트엔드에서 에러 처리

```typescript
// ✅ 에러 타입 정의
interface AppError {
  code: string;
  message: string;
}

// ✅ 에러 코드 기반 처리
async function loadFile(path: string) {
  try {
    const content = await invoke<string>('read_file', { path });
    return content;
  } catch (err) {
    const error = err as AppError;

    switch (error.code) {
      case 'FILE_NOT_FOUND':
        toast.error('파일을 찾을 수 없습니다');
        break;
      case 'PERMISSION_DENIED':
        toast.error('파일 접근 권한이 없습니다');
        break;
      case 'INVALID_FORMAT':
        toast.error(`잘못된 파일 형식: ${error.message}`);
        break;
      default:
        toast.error(`오류: ${error.message}`);
    }

    // 로깅
    console.error(`[${error.code}] ${error.message}`);
  }
}
```

## 고급 패턴: 에러 컨텍스트

**anyhow로 에러 체인:**

```rust
use anyhow::{Context, Result};

#[tauri::command]
fn load_config(path: String) -> Result<Config, String> {
  let content = std::fs::read_to_string(&path)
    .context(format!("Failed to read config from {}", path))?;

  let config: Config = serde_json::from_str(&content)
    .context("Failed to parse JSON config")?;

  Ok(config)
}
// 에러 메시지: "Failed to parse JSON config: unexpected character at line 5"
```

**tauri-specta와 통합:**

```rust
use specta::Type;

#[derive(Debug, Error, Type)]
#[serde(tag = "type", content = "data")]
enum AppError {
  #[error("File not found")]
  FileNotFound { path: String },

  #[error("Permission denied")]
  PermissionDenied,
}

// TypeScript에서 자동 생성:
// type AppError =
//   | { type: "FileNotFound", data: { path: string } }
//   | { type: "PermissionDenied" }
```

## 추가 컨텍스트

**언제 구조화된 에러를 사용해야 하는가:**
- 에러 종류가 2개 이상
- 프론트엔드에서 에러별 처리 필요
- 디버깅 정보 제공 필요
- 에러 로깅/모니터링 시스템 연동

**에러 설계 원칙:**
- 에러 코드는 대문자 스네이크 케이스 (`FILE_NOT_FOUND`)
- 메시지는 사용자 친화적으로
- 민감 정보 (경로, 비밀번호 등) 제외
- 복구 가능한 에러만 반환 (패닉 금지)

**주의사항:**
- `#[error(transparent)]`로 다른 에러 타입 자동 변환
- `Serialize` 구현 시 순환 참조 주의
- 에러 메시지는 국제화(i18n) 고려

**참고:**
- [thiserror Documentation](https://docs.rs/thiserror/)
- [Rust Error Handling](https://doc.rust-lang.org/book/ch09-00-error-handling.html)
- [anyhow for Application Errors](https://docs.rs/anyhow/)
