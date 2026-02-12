# Security Model

> Tauri v2 보안 모델 상세 가이드

---

## Trust Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│                    UNTRUSTED ZONE                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    WebView                             │  │
│  │   • HTML/CSS/JS                                       │  │
│  │   • 사용자 입력                                        │  │
│  │   • 외부 콘텐츠 (제한적)                               │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │ IPC (Capabilities 검증)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     TRUSTED ZONE                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   Rust Core                            │  │
│  │   • 시스템 API 접근                                    │  │
│  │   • 파일 시스템                                        │  │
│  │   • 네트워크                                           │  │
│  │   • 민감 데이터                                        │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Capabilities System

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "메인 윈도우 기본 권한",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "core:window:allow-set-title",
    "shell:allow-open"
  ]
}
```

| Permission 패턴 | 설명 |
|----------------|------|
| `core:default` | Core 기본 권한 |
| `core:window:allow-<cmd>` | Window 개별 허용 |
| `<plugin>:default` | Plugin 기본 권한 |
| `<plugin>:allow-<cmd>` | Plugin 개별 허용 |
| `<plugin>:deny-<cmd>` | Plugin 개별 거부 |

---

## CSP (Content Security Policy)

```json
// tauri.conf.json > app > security > csp
{
  "default-src": "'self' customprotocol: asset:",
  "connect-src": "ipc: http://ipc.localhost",
  "img-src": "'self' asset: http://asset.localhost blob: data:",
  "style-src": "'unsafe-inline' 'self'"
}
```

### CSP 프로토콜 설명

| 프로토콜 | 설명 |
|---------|------|
| `'self'` | 같은 origin 리소스만 허용 |
| `customprotocol:` | Tauri 커스텀 프로토콜 (앱 내부 통신) |
| `asset:` | 로컬 파일 접근 프로토콜 (Tauri v2) |
| `ipc:` | Frontend ↔ Rust IPC 통신 프로토콜 |
| `http://ipc.localhost` | IPC 브릿지 localhost 접근 |
| `http://asset.localhost` | 로컬 에셋 서빙 |
| `'unsafe-inline'` | 인라인 스타일 허용 (CSS-in-JS 라이브러리 호환, style-src만) |
| `blob:` | Blob URL 허용 (동적 이미지 생성) |
| `data:` | Data URL 허용 (Base64 이미지) |
