---
title: Reuse Connections with Pooling
impact: HIGH
impactDescription: Eliminates connection overhead, 5-20x throughput
tags: io, connection, pool, keep-alive, reuse
languages: all
related: [concurrency-pool, memory-pool-reuse]
---

## 커넥션 풀/재사용

매 요청마다 새 커넥션을 생성하지 않고 풀에서 재사용합니다.

**❌ 잘못된 예시 (매번 새 커넥션):**

```python
def get_user(user_id):
    conn = psycopg2.connect(DSN)  # 매번 TCP 핸드셰이크 + TLS + 인증
    cursor = conn.cursor()
    cursor.execute("SELECT ...", (user_id,))
    result = cursor.fetchone()
    conn.close()
    return result
```

**✅ 올바른 예시 (커넥션 풀):**

```python
# Python (SQLAlchemy)
engine = create_engine(DSN, pool_size=10, max_overflow=20, pool_recycle=3600)

# Python (asyncpg)
pool = await asyncpg.create_pool(DSN, min_size=5, max_size=20)
async with pool.acquire() as conn:
    result = await conn.fetchrow("SELECT ...", user_id)
```

```typescript
// Prisma (자동 풀링)
// datasource db { url = "..." } → connection_limit 설정
// schema.prisma: url = "...?connection_limit=10"
```

```go
// Go (database/sql - 내장 풀)
db, _ := sql.Open("postgres", dsn)
db.SetMaxOpenConns(25)
db.SetMaxIdleConns(10)
db.SetConnMaxLifetime(5 * time.Minute)
```

```rust
// Rust (deadpool-postgres)
let pool = Pool::builder(manager).max_size(16).build().unwrap();
let client = pool.get().await?;
let rows = client.query("SELECT ...", &[&user_id]).await?;
```

```java
// Java (HikariCP)
HikariConfig config = new HikariConfig();
config.setMaximumPoolSize(10);
config.setMinimumIdle(5);
config.setConnectionTimeout(30000);
```

**HTTP 커넥션 재사용:** `Keep-Alive` 헤더, HTTP/2 멀티플렉싱, HTTP 클라이언트 인스턴스 재사용.
