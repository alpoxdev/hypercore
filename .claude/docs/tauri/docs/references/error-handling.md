# Error Handling

> Rust Error → JSON → TypeScript Error 전파 메커니즘

---

## 커스텀 Error 타입 정의

```rust
// src-tauri/src/error.rs
use serde::Serialize;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Database error: {0}")]
    Database(String),

    #[error("Internal error: {0}")]
    Internal(String),
}

// serde::Serialize 구현 필수 (JSON 직렬화)
impl Serialize for AppError {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(self.to_string().as_ref())
    }
}

// From 변환 구현 (다른 에러 타입 자동 변환)
impl From<sqlx::Error> for AppError {
    fn from(e: sqlx::Error) -> Self {
        AppError::Database(e.to_string())
    }
}
```

---

## Command에서 에러 반환

```rust
#[tauri::command]
async fn get_user(id: u32, db: State<'_, DbPool>) -> Result<User, AppError> {
    let user = sqlx::query_as!(User, "SELECT * FROM users WHERE id = $1", id)
        .fetch_optional(&**db)
        .await?  // sqlx::Error → AppError 자동 변환
        .ok_or_else(|| AppError::NotFound(format!("User {} not found", id)))?;

    Ok(user)
}
```

---

## Frontend 에러 처리

```typescript
import { invoke } from '@tauri-apps/api/core';

interface User {
  id: number;
  name: string;
}

async function getUser(id: number): Promise<User | null> {
  try {
    return await invoke<User>('get_user', { id });
  } catch (error) {
    // error는 Rust에서 직렬화된 문자열
    const errorMessage = error as string;

    if (errorMessage.includes('Not found')) {
      console.warn('User not found:', id);
      return null;
    }

    if (errorMessage.includes('Unauthorized')) {
      // 인증 에러 처리
      window.location.href = '/login';
      return null;
    }

    // 기타 에러
    console.error('Failed to get user:', errorMessage);
    throw new Error(errorMessage);
  }
}
```

---

## 에러 전파 흐름

```
┌─────────────┐    Result<T,E>    ┌─────────────┐    JSON     ┌─────────────┐
│   Rust      │ ─────────────────▶│    IPC      │ ──────────▶ │  Frontend   │
│  Command    │    Err(AppError)  │   Bridge    │  serialize  │   catch()   │
└─────────────┘                   └─────────────┘             └─────────────┘
       │                                                             │
       │ #[error("...")] 메시지                                      │ error as string
       │                                                             │
       ▼                                                             ▼
"Not found: User 1 not found"                      "Not found: User 1 not found"
```
