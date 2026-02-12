# Data Flow

> Tauri 데이터 흐름 패턴

---

## Command Flow (읽기)

```
┌─────────┐   invoke   ┌─────────┐   validate   ┌─────────┐   execute   ┌─────────┐
│ React   │───────────▶│  IPC    │─────────────▶│Capability│────────────▶│ Command │
│ Hook    │            │ Bridge  │              │ Check   │             │ Handler │
└─────────┘            └─────────┘              └─────────┘             └────┬────┘
     ▲                                                                       │
     │                                                                       ▼
     │                                                                 ┌─────────┐
     │◀────────────────────────────────────────────────────────────────│  State  │
     │                           Result<T>                             │ / DB    │
                                                                       └─────────┘
```

---

## Event Flow (실시간 업데이트)

```
┌─────────┐                              ┌─────────┐
│  Rust   │   app.emit("event", data)   │ Frontend│
│  Core   │─────────────────────────────▶│ listen()│
└─────────┘                              └─────────┘
     │
     │  Background Task (download, sync, etc.)
     │
     └──▶ Progress Event ──▶ UI Update
```

---

## Plugin Data Flow

```
Frontend ──▶ invoke("plugin:fs|read") ──▶ Capability Check ──▶ Plugin Handler ──▶ OS API
                                                                     │
                                              ◀─────────────────────┘
                                                   Result/Error
```
