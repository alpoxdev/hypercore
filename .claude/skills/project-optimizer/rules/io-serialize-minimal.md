---
title: Serialize Only Required Fields
impact: MEDIUM
impactDescription: 30-70% payload reduction, faster serialization
tags: io, serialization, payload, network, select
languages: all
related: [io-batch-queries, memory-large-data]
---

## 필요한 필드만 직렬화/전송

전체 객체 대신 실제 사용하는 필드만 선택하여 직렬화 비용과 네트워크 전송량을 줄입니다.

**❌ 잘못된 예시 (전체 객체 반환):**

```python
# 50개 필드 전부 전송, 클라이언트는 3개만 사용
@app.get("/users")
def list_users():
    return db.query(User).all()  # password_hash 포함 위험
```

```typescript
// 전체 객체 반환
return await prisma.user.findMany()  // 50개 필드
```

**✅ 올바른 예시 (필요 필드만):**

```python
# DTO/스키마로 필드 제한
@app.get("/users")
def list_users():
    users = db.query(User.id, User.name, User.email).all()
    return [UserResponse(id=u.id, name=u.name, email=u.email) for u in users]
```

```typescript
// Prisma select
const users = await prisma.user.findMany({
  select: { id: true, name: true, email: true }
})
```

```sql
-- SQL
SELECT id, name, email FROM users;  -- ✅
SELECT * FROM users;                -- ❌
```

```go
// Go - json 태그로 제어
type UserResponse struct {
    ID    string `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
    // PasswordHash 필드 없음 → 자동 제외
}
```

**적용 범위:** API 응답, SSR 데이터, 캐시 저장, 메시지 큐 페이로드.
