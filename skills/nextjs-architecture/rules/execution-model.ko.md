# Execution Model

> Next.js Server and Client Component boundary 규칙.

---

## Core Rule

코드가 어디서 실행되는지 추측하지 않습니다.

- App Router에서는 Server Components가 기본입니다.
- Server Components에서 렌더링되는 client entry-point file에는 `'use client'`가 필요합니다.
- 한 파일에 `'use client'`가 붙으면 그 imports와 child components는 client module graph의 일부가 됩니다.
- Client Components도 prerender될 수 있으므로 server secrets와 server-only APIs를 피해야 합니다.
- Server-only code는 client environment 밖에 있어야 합니다.

## Default Strategy

1. Server Component에서 시작합니다.
2. state, event handlers, effects, browser APIs, client-only hooks가 필요할 때만 `'use client'`를 추가합니다.
3. client boundary를 tree에서 가능한 한 낮게 둡니다.
4. server에서 client로는 serializable하고 최소한의 props만 전달합니다.
5. privileged reads는 server-only modules 또는 DAL에 둡니다.

## Hard Rules

| 확인 | 규칙 |
|---|---|
| interactive code에 `'use client'` 없음 | 차단 |
| 실제 필요 없이 high-level layout 또는 root에 `'use client'` 표시 | 차단 |
| Client Component가 DB clients, secret env, `cookies()`, `headers()`, server-only helpers import | 차단 |
| Server Components에서 Client Components로 non-serializable 또는 broad raw records 전달 | 차단 |
| Server-only helper에 `import 'server-only'` 또는 동등한 boundary clarity 없음 | 경고 |
| Provider가 필요한 범위보다 넓게 렌더링됨 | 경고. providers는 가능한 깊게 렌더링 |

## Serializable Props Rule

Server Components에서 Client Components로 전달되는 props는 serializable하고 의도적으로 작아야 합니다.

선호:

- DTOs
- 작은 view models
- 명시적 primitive props
- client refresh가 진짜 필요할 때 승인된 action 또는 route를 호출할 수 있는 IDs

피하기:

- 전체 ORM records
- class instances, functions, symbols, non-serializable values
- secrets
- UI에 필요 없는 internal fields

## Provider Placement

Context providers는 필요한 subtree만 감싸야 합니다. 이렇게 하면 tree의 더 많은 부분을 static optimization 대상으로 유지하고 client bundle을 줄일 수 있습니다.

## Server-Only and Client-Only Protection

client environment에서 절대 실행되면 안 되는 modules에는 `import 'server-only'`를 사용합니다:

- DAL modules
- DB access
- secret-bearing SDK wrappers
- server-side에 남아야 하는 authorization helpers

browser-dependent third-party components가 compatible client entry point를 제공하지 않으면 client-only wrapper 뒤에 둡니다.

## Review Checklist

- `'use client'`가 필요한 곳에만 존재
- Client Components가 server-only modules에 접근하지 않음
- server/client boundary를 넘는 props가 좁고 serializable함
- Providers가 가능한 깊게 배치됨
- third-party browser-only UI가 명확한 Client Component boundary 뒤에 있음
