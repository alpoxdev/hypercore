---
title: Batch Multiple invoke Calls into Single Command
impact: CRITICAL
impactDescription: Reduce IPC round-trips from N to 1
tags: ipc, performance, batch, tauri-v2
---

# 배치 커맨드로 IPC 왕복 최소화

## 왜 중요한가

여러 개의 `invoke` 호출을 순차적으로 실행하면 각각 IPC 왕복(round-trip)이 발생하여 성능이 저하됩니다. 특히 루프 안에서 `invoke`를 호출하면 N번의 IPC 오버헤드가 발생합니다. 배치 커맨드로 통합하면 IPC 왕복을 1회로 줄여 처리 속도를 크게 향상시킬 수 있습니다.

**영향도:**
- IPC 왕복: N회 → 1회
- 지연 시간: 누적 감소
- 처리량: 5-10배 향상 (데이터 크기에 따라)

## ❌ 잘못된 패턴

**프론트엔드에서 개별 호출:**

```typescript
// ❌ 루프에서 N번 invoke 호출
import { invoke } from '@tauri-apps/api/core';

async function processItems(items: string[]) {
  const results = [];
  for (const item of items) {
    // 각 호출마다 IPC 왕복 발생
    const result = await invoke<string>('process_item', { item });
    results.push(result);
  }
  return results;
}
```

**문제점:**
- 100개 아이템 = 100번 IPC 왕복
- 각 호출마다 직렬화/역직렬화 오버헤드
- 네트워크 레이턴시와 유사한 누적 지연

## ✅ 올바른 패턴

**배치 커맨드로 통합:**

```rust
// ✅ Rust: 배치 처리 커맨드
#[tauri::command]
fn process_batch(items: Vec<String>) -> Result<Vec<String>, String> {
  items
    .iter()
    .map(|item| process_item(item))
    .collect::<Result<Vec<_>, _>>()
}

fn process_item(item: &str) -> Result<String, String> {
  // 실제 처리 로직
  Ok(item.to_uppercase())
}
```

```typescript
// ✅ 프론트엔드: 1번 호출
import { invoke } from '@tauri-apps/api/core';

async function processItems(items: string[]) {
  // 단일 IPC 왕복
  const results = await invoke<string[]>('process_batch', { items });
  return results;
}

// 사용 예시
const items = ['apple', 'banana', 'cherry'];
const results = await processItems(items); // ['APPLE', 'BANANA', 'CHERRY']
```

**병렬 처리가 필요한 경우:**

```rust
use rayon::prelude::*;

#[tauri::command]
fn process_batch_parallel(items: Vec<String>) -> Result<Vec<String>, String> {
  items
    .par_iter()  // 병렬 반복자
    .map(|item| process_item(item))
    .collect::<Result<Vec<_>, _>>()
}
```

**부분 실패 처리:**

```rust
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct BatchResult {
  success: Vec<String>,
  failed: Vec<(String, String)>, // (item, error)
}

#[tauri::command]
fn process_batch_resilient(items: Vec<String>) -> BatchResult {
  let mut success = Vec::new();
  let mut failed = Vec::new();

  for item in items {
    match process_item(&item) {
      Ok(result) => success.push(result),
      Err(err) => failed.push((item, err)),
    }
  }

  BatchResult { success, failed }
}
```

## 추가 컨텍스트

**언제 배치 커맨드를 사용해야 하는가:**
- 같은 커맨드를 3회 이상 호출해야 할 때
- 루프 안에서 `invoke`를 호출할 때
- 배열 데이터를 개별 처리해야 할 때

**주의사항:**
- 배치 크기가 매우 큰 경우(10,000+ 아이템) 청크 단위로 분할 호출
- 메모리 사용량 모니터링 필요
- 진행률 표시가 필요하면 [Channel 스트리밍](./ipc-channel-streaming.md) 패턴 사용

**참고:**
- [Tauri IPC Guide](https://tauri.app/concept/inter-process-communication/)
- [Calling Rust from Frontend](https://tauri.app/develop/calling-rust/)
