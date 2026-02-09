---
title: Segregate Large Interfaces
impact: LOW-MEDIUM
impactDescription: Reduced coupling, easier testing and mocking
tags: arch, interface, segregation, coupling
languages: [ts, go, rust, java, csharp]
related: [arch-module-boundary, code-duplication]
---

## 큰 인터페이스를 작은 단위로 분리

하나의 거대한 인터페이스 대신 용도별 작은 인터페이스를 사용합니다.

**❌ 잘못된 예시:**

```typescript
interface UserService {
  getUser(id: string): User
  createUser(data: CreateUserData): User
  deleteUser(id: string): void
  sendEmail(userId: string, subject: string): void
  generateReport(userId: string): Report
  uploadAvatar(userId: string, file: File): string
}
// 이메일만 보내려는 컴포넌트도 전체 인터페이스에 의존
```

**✅ 올바른 예시:**

```typescript
interface UserReader { getUser(id: string): User }
interface UserWriter { createUser(data: CreateUserData): User; deleteUser(id: string): void }
interface EmailSender { sendEmail(userId: string, subject: string): void }
// 각 소비자는 필요한 인터페이스만 의존
```

```go
// Go - 암시적 인터페이스 (소비자 쪽에서 정의)
// reader.go - 이 패키지에서 필요한 것만 정의
type UserGetter interface {
    GetUser(ctx context.Context, id string) (*User, error)
}
```

```rust
// Rust - trait 분리
trait Readable { fn read(&self, id: &str) -> Result<User>; }
trait Writable { fn write(&self, user: &User) -> Result<()>; }
```

**원칙:** "클라이언트는 자신이 사용하지 않는 메서드에 의존하지 않아야 한다" (ISP).
