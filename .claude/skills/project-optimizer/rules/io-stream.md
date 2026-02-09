---
title: Stream Large Data Instead of Loading All
impact: HIGH
impactDescription: Constant memory usage, no OOM on large datasets
tags: io, streaming, iterator, generator, memory
languages: all
related: [memory-large-data, concurrency-pipeline]
---

## 대용량 데이터 스트리밍 처리

전체 데이터를 메모리에 적재하지 않고 스트림/이터레이터/제너레이터로 청크 단위 처리합니다.

**❌ 잘못된 예시 (전체 로드):**

```python
# 100만 행 전체 메모리 적재
rows = db.execute("SELECT * FROM big_table").fetchall()
for row in rows:
    process(row)
```

**✅ 올바른 예시 (스트리밍):**

```python
# Python - 서버 사이드 커서
cursor = db.execute("SELECT * FROM big_table")
while batch := cursor.fetchmany(1000):
    for row in batch:
        process(row)

# 파일 스트리밍
with open("huge.csv") as f:
    for line in f:  # 한 줄씩 (메모리 일정)
        process(line)
```

```typescript
// Node.js - 스트림
import { createReadStream } from 'fs'
import { pipeline } from 'stream/promises'

await pipeline(
  createReadStream('huge.csv'),
  new Transform({ transform(chunk, enc, cb) { /* 청크 처리 */ cb() } }),
  createWriteStream('output.csv')
)
```

```go
// Go - Scanner (파일), rows.Next() (DB)
scanner := bufio.NewScanner(file)
for scanner.Scan() {
    process(scanner.Text())
}

rows, _ := db.Query("SELECT * FROM big_table")
defer rows.Close()
for rows.Next() {
    var item Item
    rows.Scan(&item.ID, &item.Name)
    process(item)
}
```

```rust
// Rust - Iterator (lazy)
use std::io::{BufRead, BufReader};
let reader = BufReader::new(file);
for line in reader.lines() {
    process(line?);
}
```

**적용 기준:** 10MB+ 파일, 10K+ DB 행, API 페이지네이션.
