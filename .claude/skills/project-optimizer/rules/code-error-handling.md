---
title: Consistent Error Handling Pattern
impact: MEDIUM
impactDescription: Predictable error flow, easier debugging
tags: code, error, exception, result, handling
languages: all
related: [code-complexity, memory-leak-prevention]
---

## 일관된 에러 처리 패턴

프로젝트 전체에서 하나의 에러 처리 패턴을 일관되게 사용합니다.

**언어별 권장 패턴:**

| 언어 | 패턴 | 핵심 |
|------|------|------|
| **Go** | `(value, error)` | 항상 err 체크, sentinel errors |
| **Rust** | `Result<T, E>` | `?` 연산자, 커스텀 Error enum |
| **Python** | Exception 계층 | 커스텀 Exception, `raise from` |
| **JS/TS** | 커스텀 Error / Result | Error 서브클래스 또는 Result 타입 |
| **Java** | Unchecked 선호 | RuntimeException 서브클래스 |

**✅ 올바른 예시:**

```typescript
// JS/TS - 커스텀 Error 클래스
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500
  ) {
    super(message)
    this.name = 'AppError'
  }
}
class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404)
  }
}
```

```go
// Go - sentinel errors + wrapping
var ErrNotFound = errors.New("not found")
var ErrUnauthorized = errors.New("unauthorized")

func getUser(id string) (*User, error) {
    user, err := db.Find(id)
    if err != nil {
        return nil, fmt.Errorf("getUser(%s): %w", id, err)
    }
    if user == nil {
        return nil, ErrNotFound
    }
    return user, nil
}
```

```rust
// Rust - thiserror
#[derive(Debug, thiserror::Error)]
enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    #[error("unauthorized")]
    Unauthorized,
    #[error(transparent)]
    Database(#[from] sqlx::Error),
}
```

**원칙:** 에러는 발생 지점에서 컨텍스트를 추가하고, 처리 지점에서 변환/로깅합니다.
