---
title: Use Response for Binary Data to Bypass JSON Serialization
impact: HIGH
impactDescription: 3-5x faster, no size overhead for binary data
tags: ipc, performance, binary, response, tauri-v2
---

# Response로 바이너리 데이터 직렬화 우회

## 왜 중요한가

바이너리 데이터를 `Vec<u8>`로 반환하면 JSON으로 직렬화되어 크기가 증가하고 속도가 느립니다. `tauri::ipc::Response`를 사용하면 JSON 직렬화를 우회하여 raw 바이너리를 직접 전송할 수 있습니다.

**영향도:**
- 속도: 3-5배 향상
- 크기: 30-40% 감소 (Base64 인코딩 없음)
- 메모리: 복사 최소화

## ❌ 잘못된 패턴

**Vec<u8> 반환 (JSON 직렬화됨):**

```rust
use std::fs;

// ❌ Vec<u8>는 JSON 배열로 직렬화됨
#[tauri::command]
fn read_image(path: String) -> Result<Vec<u8>, String> {
  fs::read(&path).map_err(|e| e.to_string())
}

// 결과: [255, 216, 255, 224, ...] 형태로 직렬화
// 1MB 이미지 → 1.3MB JSON 배열
```

```typescript
// ❌ 프론트엔드에서 다시 Uint8Array로 변환 필요
const imageBytes = await invoke<number[]>('read_image', { path });
const blob = new Blob([new Uint8Array(imageBytes)]);
```

**문제점:**
- JSON 직렬화 오버헤드
- 크기 증가 (각 바이트가 숫자로 표현)
- 메모리 복사 증가

## ✅ 올바른 패턴

**Response로 raw 바이너리 반환:**

```rust
use tauri::ipc::Response;
use std::fs;

// ✅ Response로 JSON 직렬화 우회
#[tauri::command]
fn read_image(path: String) -> Result<Response, String> {
  let bytes = fs::read(&path).map_err(|e| e.to_string())?;
  Ok(Response::new(bytes))
}
```

```typescript
// ✅ 프론트엔드: 자동으로 Uint8Array로 수신
const imageBytes = await invoke<Uint8Array>('read_image', { path });
const blob = new Blob([imageBytes], { type: 'image/png' });
const url = URL.createObjectURL(blob);

// 이미지 표시
<img src={url} alt="Loaded from Rust" />
```

**스트리밍 대용량 파일:**

```rust
use tauri::ipc::{Channel, Response};
use tokio::fs::File;
use tokio::io::AsyncReadExt;

// ✅ 작은 파일: Response 직접 반환
#[tauri::command]
async fn read_small_file(path: String) -> Result<Response, String> {
  let bytes = tokio::fs::read(&path)
    .await
    .map_err(|e| e.to_string())?;
  Ok(Response::new(bytes))
}

// ✅ 큰 파일: Channel로 청크 스트리밍
#[tauri::command]
async fn read_large_file(
  path: String,
  on_chunk: Channel<Response>,
) -> Result<(), String> {
  let mut file = File::open(&path)
    .await
    .map_err(|e| e.to_string())?;

  let mut buffer = vec![0u8; 65536]; // 64KB 청크

  loop {
    let n = file.read(&mut buffer)
      .await
      .map_err(|e| e.to_string())?;

    if n == 0 { break; }

    on_chunk.send(Response::new(buffer[..n].to_vec()))
      .map_err(|e| e.to_string())?;
  }

  Ok(())
}
```

**바이너리 데이터 생성 예시:**

```rust
use image::{ImageBuffer, Rgb};

#[tauri::command]
fn generate_thumbnail(
  path: String,
  width: u32,
  height: u32,
) -> Result<Response, String> {
  let img = image::open(&path)
    .map_err(|e| e.to_string())?;

  let thumbnail = img.resize(
    width,
    height,
    image::imageops::FilterType::Lanczos3,
  );

  let mut bytes: Vec<u8> = Vec::new();
  thumbnail.write_to(
    &mut std::io::Cursor::new(&mut bytes),
    image::ImageFormat::Png,
  ).map_err(|e| e.to_string())?;

  Ok(Response::new(bytes))
}
```

## JavaScript에서 Blob 생성

**다양한 바이너리 데이터 처리:**

```typescript
// 이미지 파일
const imageBytes = await invoke<Uint8Array>('read_image', { path });
const imageBlob = new Blob([imageBytes], { type: 'image/png' });
const imageUrl = URL.createObjectURL(imageBlob);

// PDF 파일
const pdfBytes = await invoke<Uint8Array>('read_pdf', { path });
const pdfBlob = new Blob([pdfBytes], { type: 'application/pdf' });

// 비디오 스트리밍
const videoChunks: Uint8Array[] = [];
const onChunk = new Channel<Uint8Array>();
onChunk.onmessage = (chunk) => videoChunks.push(chunk);
await invoke('stream_video', { path, onChunk });
const videoBlob = new Blob(videoChunks, { type: 'video/mp4' });

// 다운로드 링크 생성
const downloadUrl = URL.createObjectURL(videoBlob);
const a = document.createElement('a');
a.href = downloadUrl;
a.download = 'video.mp4';
a.click();

// 메모리 정리
URL.revokeObjectURL(downloadUrl);
```

## 추가 컨텍스트

**언제 Response를 사용해야 하는가:**
- 이미지, 비디오, 오디오 파일
- PDF, 압축 파일 등 바이너리 문서
- 암호화된 데이터
- 프로토콜 버퍼, MessagePack 등 바이너리 형식

**JSON 직렬화가 적합한 경우:**
- 구조화된 데이터 (객체, 배열)
- 작은 숫자 배열 (< 100 요소)
- 타입 안전성이 중요한 경우

**주의사항:**
- `Response::new()`는 `Vec<u8>` 소유권을 가져감
- 매우 큰 파일(100MB+)은 Channel 스트리밍 사용
- `URL.createObjectURL()` 후 `URL.revokeObjectURL()`로 메모리 정리 필수

**참고:**
- [Tauri Response API](https://docs.rs/tauri/latest/tauri/ipc/struct.Response.html)
- [MDN Blob API](https://developer.mozilla.org/en-US/docs/Web/API/Blob)
