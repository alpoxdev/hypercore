# 미들웨어

> 요청 경계와 공통 관심사에 대한 미들웨어 규칙

---

## 핵심 규칙

미들웨어는 auth, request ID, CORS, logging, context enrichment처럼 요청 전반의 관심사를 명시하는 경계입니다.

Middleware가 variables를 설정하거나 bindings에 의존하면 `createMiddleware()` 같은 typed helper로 reusable middleware를 추출합니다.

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| 미들웨어 순서를 잘못 가정 | 차단 |
| 공통 요청 관심사를 handler마다 복붙 | 경고 |
| `c.set()` 값을 typed `Variables` 없이 사용 | 차단 |
| `Context`로 요청 간 상태를 유지한다고 가정 | 차단 |
| App-wide middleware가 보장하지 않는 값에 global `ContextVariableMap` 사용 | 차단 |

## Typed Middleware Pattern

```ts
import { createMiddleware } from 'hono/factory'

import type { AppEnv } from '@/lib/types'

export const authMiddleware = createMiddleware<AppEnv>(async (c, next) => {
  const user = await resolveUser(c.req)
  c.set('user', user)
  await next()
})
```

## 리뷰 체크리스트

- 등록 순서가 의도적임
- 공통 관심사가 중앙화됨
- context variable이 타입화됨
- middleware가 숨은 business-logic layer가 되지 않음
- request-scoped context value가 이를 읽는 handler보다 먼저 설정됨
