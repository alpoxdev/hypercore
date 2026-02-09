---
title: Pool and Reuse Expensive Objects
impact: MEDIUM
impactDescription: Reduces GC pressure, allocation overhead
tags: memory, pool, reuse, allocation, gc
languages: all
related: [memory-leak-prevention, concurrency-pool, io-connection-reuse]
---

## 비싼 객체 풀링/재사용

반복 생성-소멸되는 비싼 객체(버퍼, 커넥션, HTTP 클라이언트)를 풀에서 재사용합니다.

**❌ 잘못된 예시:**

```go
// 매 요청마다 새 버퍼 할당
func handler(w http.ResponseWriter, r *http.Request) {
    buf := make([]byte, 32*1024)  // 32KB 매번 할당 + GC
    io.CopyBuffer(w, r.Body, buf)
}
```

```python
# 매번 새 HTTP 세션
def fetch(url):
    return requests.get(url)  # 매번 새 커넥션
```

**✅ 올바른 예시:**

```go
// Go - sync.Pool
var bufPool = sync.Pool{
    New: func() any { return make([]byte, 32*1024) },
}

func handler(w http.ResponseWriter, r *http.Request) {
    buf := bufPool.Get().([]byte)
    defer bufPool.Put(buf)
    io.CopyBuffer(w, r.Body, buf)
}
```

```python
# Python - 세션 재사용
session = requests.Session()  # 모듈 레벨에서 한 번 생성

def fetch(url):
    return session.get(url)  # 커넥션 재사용, Keep-Alive
```

```typescript
// Node.js - HTTP Agent 재사용
import { Agent } from 'undici'
const agent = new Agent({ connections: 10, keepAliveTimeout: 30_000 })

// 또는 전역 fetch에서 agent 사용
```

```rust
// Rust - 정적 클라이언트
use reqwest::Client;
use std::sync::LazyLock;
static CLIENT: LazyLock<Client> = LazyLock::new(|| {
    Client::builder().pool_max_idle_per_host(10).build().unwrap()
});
```

**적용 대상:** HTTP 클라이언트, DB 커넥션, 버퍼, 정규식 컴파일 결과, 시리얼라이저 인스턴스.
