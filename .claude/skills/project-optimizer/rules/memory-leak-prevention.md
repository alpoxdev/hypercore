---
title: Guarantee Resource Cleanup
impact: HIGH
impactDescription: Prevents memory leaks, file handle exhaustion, connection leaks
tags: memory, resource, leak, cleanup, dispose
languages: all
related: [memory-pool-reuse, io-connection-reuse]
---

## 리소스 해제 보장

파일, DB 커넥션, 소켓, 락 등 시스템 리소스는 예외 발생 시에도 반드시 해제합니다.

**❌ 잘못된 예시:**

```python
f = open("data.csv")
data = f.read()  # 예외 시 f.close() 호출 안 됨

conn = db.connect()
result = conn.execute(query)  # 예외 시 커넥션 누수
```

**✅ 올바른 예시:**

```python
# Python - context manager
with open("data.csv") as f:
    data = f.read()

async with pool.acquire() as conn:
    result = await conn.execute(query)
```

```go
// Go - defer
resp, err := http.Get(url)
if err != nil { return err }
defer resp.Body.Close()

f, err := os.Open("data.csv")
if err != nil { return err }
defer f.Close()
```

```typescript
// JS/TS - try/finally
const conn = await pool.acquire()
try {
  return await conn.query(sql)
} finally {
  conn.release()
}

// TC39 Explicit Resource Management (using)
await using conn = await pool.acquire()
return await conn.query(sql)
```

```rust
// Rust - RAII (자동)
let file = File::open("data.csv")?;  // Drop trait으로 스코프 끝에서 자동 해제
let data = read_to_string(&file)?;
// file 자동 해제
```

```java
// Java - try-with-resources
try (var conn = dataSource.getConnection();
     var stmt = conn.prepareStatement(sql)) {
    return stmt.executeQuery();
}
```

```csharp
// C# - using
await using var conn = await pool.GetConnectionAsync();
return await conn.QueryAsync(sql);
```
