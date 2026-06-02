# 핸들러

> 분리된 핸들러도 타입과 조합 가능성을 유지

---

## 핵심 규칙

- 작은 라우트는 inline handler 허용
- 핸들러를 분리할 때는 `createFactory()` / `factory.createHandlers()`로 타입 유지
- handler 파일은 transport orchestration까지만 담당하고, 도메인 persistence는 아래 레이어로 내립니다

## 권장 패턴

```ts
import { createFactory } from 'hono/factory'

import type { AppEnv } from '@/lib/types'

const factory = createFactory<AppEnv>()

const listUsers = factory.createHandlers(async (c) => {
  return c.json({ users: [] })
})

export const usersApp = factory.createApp().get('/', ...listUsers)
```

## 리뷰 체크리스트

- 분리된 handler가 context typing을 유지함
- `Variables`, `Bindings`가 암묵적이지 않음
- handler가 giant controller object로 비대해지지 않음
- business logic은 service가 소유

