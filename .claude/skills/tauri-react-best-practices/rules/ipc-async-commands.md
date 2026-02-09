---
title: Use async Commands for Non-Blocking Operations
impact: CRITICAL
impactDescription: Prevent UI freezes with async Rust commands
tags: ipc, async, tokio, performance, tauri-v2
---

# async 커맨드로 UI 차단 방지

## 왜 중요한가

Rust 커맨드가 동기(blocking) 작업을 수행하면 Tauri 런타임이 차단되어 UI가 멈춥니다. `async` 커맨드를 사용하면 I/O, 네트워크, 파일 작업을 비차단(non-blocking) 방식으로 실행하여 UI 응답성을 유지할 수 있습니다.

**영향도:**
- UI 응답성: 차단 방지
- 동시성: 여러 작업 병렬 처리
- 사용자 경험: 부드러운 인터랙션

## ❌ 잘못된 패턴

**동기 커맨드에서 blocking 작업:**

```rust
use std::fs;
use std::thread::sleep;
use std::time::Duration;

// ❌ 동기 커맨드에서 파일 I/O (UI 차단)
#[tauri::command]
fn read_large_file(path: String) -> Result<String, String> {
  // 메인 스레드 차단
  let content = fs::read_to_string(&path)
    .map_err(|e| e.to_string())?;
  Ok(content)
}

// ❌ 동기 커맨드에서 sleep (UI 멈춤)
#[tauri::command]
fn slow_operation() -> String {
  sleep(Duration::from_secs(5)); // 5초 동안 UI 멈춤
  "Done".to_string()
}
```

**문제점:**
- 커맨드 실행 중 UI 완전히 멈춤
- 다른 IPC 요청도 차단됨
- 사용자 경험 저하

## ✅ 올바른 패턴

**async 커맨드로 비차단 실행:**

```rust
use tokio::fs;
use tokio::time::{sleep, Duration};

// ✅ async 커맨드로 파일 I/O (UI 차단 없음)
#[tauri::command]
async fn read_large_file(path: String) -> Result<String, String> {
  // tokio 비동기 파일 I/O
  let content = fs::read_to_string(&path)
    .await
    .map_err(|e| e.to_string())?;
  Ok(content)
}

// ✅ async 커맨드로 지연 작업 (UI 응답 유지)
#[tauri::command]
async fn slow_operation() -> String {
  sleep(Duration::from_secs(5)).await; // 다른 작업 진행 가능
  "Done".to_string()
}
```

**HTTP 요청 예시:**

```rust
use reqwest;

// ✅ 비동기 HTTP 요청
#[tauri::command]
async fn fetch_data(url: String) -> Result<String, String> {
  let response = reqwest::get(&url)
    .await
    .map_err(|e| e.to_string())?
    .text()
    .await
    .map_err(|e| e.to_string())?;
  Ok(response)
}
```

**병렬 작업 실행:**

```rust
use tokio::task::spawn;

#[tauri::command]
async fn process_multiple_files(paths: Vec<String>) -> Result<Vec<String>, String> {
  let mut tasks = vec![];

  for path in paths {
    // 각 파일을 별도 태스크로 처리
    let task = spawn(async move {
      fs::read_to_string(&path).await
    });
    tasks.push(task);
  }

  // 모든 태스크 완료 대기
  let results = futures::future::try_join_all(tasks)
    .await
    .map_err(|e| e.to_string())?;

  results
    .into_iter()
    .collect::<Result<Vec<_>, _>>()
    .map_err(|e| e.to_string())
}
```

## async에서 &str 사용 제한

**❌ async 함수에서 &str 파라미터 불가:**

```rust
// ❌ 컴파일 에러: async 함수는 'static 라이프타임 필요
#[tauri::command]
async fn process_text(text: &str) -> String {
  // Error: `text` has an incompatible lifetime
  text.to_uppercase()
}
```

**✅ String 사용:**

```rust
// ✅ String으로 소유권 확보
#[tauri::command]
async fn process_text(text: String) -> String {
  text.to_uppercase()
}
```

**이유:**
- async 함수는 Future로 변환되어 나중에 실행됨
- 참조(&str)는 원본 데이터가 유효함을 보장할 수 없음
- String은 소유권을 가져 'static 라이프타임 요구사항 충족

## 추가 컨텍스트

**언제 async 커맨드를 사용해야 하는가:**
- 파일 I/O (`tokio::fs`)
- 네트워크 요청 (`reqwest`, `tokio::net`)
- 데이터베이스 쿼리 (`sqlx`, `tokio-postgres`)
- 타이머/지연 (`tokio::time::sleep`)
- CPU 집약적이지 않은 모든 작업

**동기 커맨드를 사용해도 되는 경우:**
- 즉시 완료되는 간단한 계산
- 상태 읽기/쓰기 (Mutex)
- 메모리 작업만 수행하는 경우

**주의사항:**
- `Cargo.toml`에 `tokio` 의존성 추가 필요: `tokio = { version = "1", features = ["full"] }`
- CPU 집약적 작업은 `tokio::task::spawn_blocking` 사용
- async 커맨드 내부에서 std 동기 함수 호출 시 주의

**참고:**
- [Tauri Async Commands](https://tauri.app/develop/calling-rust/#async-commands)
- [Tokio Documentation](https://tokio.rs/)
