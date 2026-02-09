---
title: Batch Queries to Eliminate N+1
impact: HIGH
impactDescription: 100x fewer queries, 10x faster response
tags: io, database, n+1, batch, query
languages: all
related: [concurrency-parallel, io-cache-layer]
---

## N+1 쿼리 제거

목록 조회 후 각 항목마다 추가 쿼리를 실행하는 N+1 패턴을 배치/조인으로 전환합니다.

**❌ 잘못된 예시 (N+1):**

```python
# 100명 유저 = 101 쿼리
users = db.query("SELECT * FROM users")
for user in users:
    orders = db.query(f"SELECT * FROM orders WHERE user_id = {user.id}")
```

```typescript
// Prisma N+1
const users = await prisma.user.findMany()
for (const user of users) {
  const orders = await prisma.order.findMany({ where: { userId: user.id } })
}
```

**✅ 올바른 예시 (배치/조인):**

```python
# 2 쿼리
users = db.query("SELECT * FROM users")
user_ids = [u.id for u in users]
orders = db.query("SELECT * FROM orders WHERE user_id = ANY($1)", user_ids)

# SQLAlchemy - eager loading
users = session.query(User).options(selectinload(User.orders)).all()
```

```typescript
// Prisma - include
const users = await prisma.user.findMany({
  include: { orders: true }
})
```

```go
// GORM - Preload
var users []User
db.Preload("Orders").Find(&users)
```

```ruby
# ActiveRecord - includes
users = User.includes(:orders).all
```

```java
// JPA - EntityGraph
@EntityGraph(attributePaths = {"orders"})
List<User> findAll();
```

**감지 방법:** 쿼리 로그에서 반복되는 유사 쿼리 패턴 확인. ORM 쿼리 카운터 활용.
