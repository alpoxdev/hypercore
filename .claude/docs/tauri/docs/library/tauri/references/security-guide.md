# Security Guide

> Tauri v2 보안 상세 가이드

---

## Capabilities

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "메인 윈도우 기본 권한",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "core:window:allow-set-title",
    "core:window:allow-close",
    "shell:allow-open"
  ]
}
```

```json
// 플랫폼별 Capability
{
  "identifier": "mobile-features",
  "description": "모바일 전용 권한",
  "windows": ["main"],
  "platforms": ["iOS", "android"],
  "permissions": [
    "nfc:default",
    "biometric:default"
  ]
}
```

---

## Permission 패턴

```
core:default                    # Core 기본 권한
core:window:allow-<command>     # Window 개별 허용
core:event:allow-listen         # Event 리스닝 허용
<plugin>:default                # Plugin 기본 권한
<plugin>:allow-<command>        # Plugin 개별 허용
<plugin>:deny-<command>         # Plugin 개별 거부
```

---

## CSP 설정

```json
// tauri.conf.json > app > security > csp
{
  "default-src": "'self' customprotocol: asset:",
  "connect-src": "ipc: http://ipc.localhost",
  "font-src": ["https://fonts.gstatic.com"],
  "img-src": "'self' asset: http://asset.localhost blob: data:",
  "style-src": "'unsafe-inline' 'self'"
}
```
