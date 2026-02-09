---
title: Paginate or Stream Large Datasets
impact: MEDIUM
impactDescription: Constant memory usage regardless of data size
tags: memory, pagination, streaming, large-data
languages: all
related: [io-stream, concurrency-pipeline]
---

## 대용량 데이터 페이지네이션/스트리밍

전체 데이터를 한번에 메모리에 적재하지 않고 페이지 단위 또는 스트림으로 처리합니다.

**❌ 잘못된 예시:**

```python
all_users = db.query("SELECT * FROM users").fetchall()  # 100만 행 = OOM
response = jsonify(all_users)
```

**✅ 올바른 예시:**

```python
# 커서 기반 페이지네이션
@app.get("/users")
def list_users(cursor: str = None, limit: int = 50):
    query = db.query(User).order_by(User.id)
    if cursor:
        query = query.filter(User.id > cursor)
    users = query.limit(limit).all()
    next_cursor = users[-1].id if users else None
    return {"data": users, "next_cursor": next_cursor}
```

```typescript
// 커서 기반 (Prisma)
const users = await prisma.user.findMany({
  take: 50,
  skip: cursor ? 1 : 0,
  cursor: cursor ? { id: cursor } : undefined,
  orderBy: { id: 'asc' },
})
```

```go
// Go - 청크 처리
const batchSize = 1000
var lastID int64
for {
    var batch []User
    db.Where("id > ?", lastID).Order("id").Limit(batchSize).Find(&batch)
    if len(batch) == 0 { break }
    processBatch(batch)
    lastID = batch[len(batch)-1].ID
}
```

**페이지네이션 유형:**

| 유형 | 장점 | 단점 |
|------|------|------|
| **Offset** | 간단 구현 | 대량 데이터 시 느림, 중복/누락 |
| **Cursor** | 일관성, 빠름 | 임의 페이지 접근 불가 |
| **Keyset** | 가장 빠름 | 정렬 키 필요 |
