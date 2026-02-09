---
title: Use Channels for Large Data Streaming
impact: CRITICAL
impactDescription: 5-10x faster than Events for continuous data streams
tags: ipc, performance, channel, streaming, tauri-v2
---

# Channel로 대용량 데이터 스트리밍

## 왜 중요한가

대용량 데이터나 연속적인 진행률 업데이트를 전송할 때, Events는 각 메시지마다 오버헤드가 크고 느립니다. Tauri v2의 Channel은 스트리밍 최적화 프로토콜로 5-10배 빠른 처리량을 제공합니다.

**영향도:**
- 처리량: 5-10배 향상
- 메모리: 버퍼링 최적화
- 응답성: 실시간 진행률 표시

## ❌ 잘못된 패턴

**Events로 대용량 스트리밍:**

```rust
use tauri::{AppHandle, Emitter};

// ❌ Events로 청크 전송 (느림, 오버헤드 큼)
#[tauri::command]
async fn download_file(app: AppHandle, url: String) -> Result<(), String> {
  let mut downloaded = 0u64;
  let total = 1_000_000u64;

  for chunk in 0..1000 {
    downloaded += 1000;
    // 각 emit마다 이벤트 버스 오버헤드
    app.emit("download-progress", (downloaded, total))
      .map_err(|e| e.to_string())?;

    // 실제 다운로드 로직...
  }
  Ok(())
}
```

```typescript
// ❌ 프론트엔드: Events 리스닝
import { listen } from '@tauri-apps/api/event';

listen<[number, number]>('download-progress', (event) => {
  const [downloaded, total] = event.payload;
  updateProgressBar(downloaded / total);
});

await invoke('download_file', { url: 'https://...' });
```

**문제점:**
- Events는 브로드캐스트 방식 (모든 윈도우에 전송)
- 각 메시지마다 이벤트 버스 오버헤드
- 백프레셔(backpressure) 제어 없음

## ✅ 올바른 패턴

**Channel로 스트리밍:**

```rust
use tauri::ipc::Channel;

// ✅ Channel로 스트리밍 (빠름, 직접 연결)
#[tauri::command]
async fn download_file(
  url: String,
  on_progress: Channel<(u64, u64)>,
) -> Result<(), String> {
  let mut downloaded = 0u64;
  let total = 1_000_000u64;

  for _chunk in 0..1000 {
    downloaded += 1000;
    // Channel은 단일 연결, 낮은 오버헤드
    on_progress.send((downloaded, total))
      .map_err(|e| e.to_string())?;

    // 실제 다운로드 로직...
  }
  Ok(())
}
```

```typescript
// ✅ 프론트엔드: Channel 사용
import { invoke, Channel } from '@tauri-apps/api/core';

async function downloadFile(url: string) {
  const onProgress = new Channel<[number, number]>();

  onProgress.onmessage = ([downloaded, total]) => {
    updateProgressBar(downloaded / total);
  };

  await invoke('download_file', { url, onProgress });
}
```

**파일 스트리밍 예시:**

```rust
use tokio::fs::File;
use tokio::io::AsyncReadExt;

#[tauri::command]
async fn stream_file_chunks(
  path: String,
  on_chunk: Channel<Vec<u8>>,
) -> Result<(), String> {
  let mut file = File::open(&path)
    .await
    .map_err(|e| e.to_string())?;

  let mut buffer = vec![0u8; 8192]; // 8KB 청크

  loop {
    let n = file.read(&mut buffer)
      .await
      .map_err(|e| e.to_string())?;

    if n == 0 { break; }

    on_chunk.send(buffer[..n].to_vec())
      .map_err(|e| e.to_string())?;
  }

  Ok(())
}
```

```typescript
import { Channel } from '@tauri-apps/api/core';

const chunks: Uint8Array[] = [];
const onChunk = new Channel<number[]>();

onChunk.onmessage = (chunk) => {
  chunks.push(new Uint8Array(chunk));
};

await invoke('stream_file_chunks', {
  path: '/path/to/large-file.bin',
  onChunk,
});

// 모든 청크 합치기
const blob = new Blob(chunks);
```

## Channels vs Events 비교

| 측면 | Channels | Events |
|------|----------|--------|
| **방향** | Rust → Frontend (단방향) | 양방향 브로드캐스트 |
| **수신자** | 호출한 윈도우만 | 모든 윈도우 |
| **처리량** | 높음 (5-10x) | 낮음 |
| **오버헤드** | 낮음 (직접 연결) | 높음 (이벤트 버스) |
| **백프레셔** | 지원 | 미지원 |
| **사용 사례** | 대용량 스트리밍, 진행률 | 알림, 상태 브로드캐스트 |

## 추가 컨텍스트

**언제 Channel을 사용해야 하는가:**
- 진행률 업데이트 (다운로드, 인코딩 등)
- 파일 청크 스트리밍
- 실시간 데이터 피드 (로그, 센서 데이터)
- 100+ 메시지를 빠르게 전송해야 할 때

**언제 Events를 사용해야 하는가:**
- 모든 윈도우에 알림 필요
- 간헐적인 이벤트 (클릭, 상태 변경)
- 양방향 통신 필요

**주의사항:**
- Channel은 **타입 파라미터**를 반드시 명시해야 함: `Channel<T>`
- 프론트엔드에서 `onmessage` 핸들러 설정 후 `invoke` 호출
- Channel은 `invoke` 호출이 끝나면 자동으로 닫힘

**참고:**
- [Tauri Channels Guide](https://tauri.app/develop/calling-frontend/#channels)
- [IPC Concept](https://tauri.app/concept/inter-process-communication/)
