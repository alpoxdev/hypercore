# Plugins Guide

> Tauri v2 Plugin 사용 가이드

---

## v1 Built-in → v2 Plugin 전환

| 기능 | v2 Plugin 패키지 |
|------|-----------------|
| Clipboard | `@tauri-apps/plugin-clipboard-manager` |
| Dialog | `@tauri-apps/plugin-dialog` |
| File System | `@tauri-apps/plugin-fs` |
| HTTP | `@tauri-apps/plugin-http` |
| Shell | `@tauri-apps/plugin-shell` |
| Process | `@tauri-apps/plugin-process` |
| OS Info | `@tauri-apps/plugin-os` |
| Store | `@tauri-apps/plugin-store` |
| Notification | `@tauri-apps/plugin-notification` |
| Global Shortcut | `@tauri-apps/plugin-global-shortcut` |

---

## Plugin 사용 패턴

```bash
# 설치 (Rust + JS 바인딩)
npm add @tauri-apps/plugin-shell
cargo add tauri-plugin-shell -F tauri-plugin-shell/build
```

```rust
// main.rs에 등록
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .unwrap();
}
```

```json
// capabilities에 Permission 추가
{
  "permissions": ["shell:allow-open"]
}
```
