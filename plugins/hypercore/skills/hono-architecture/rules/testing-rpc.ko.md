# Testing과 RPC

> typed client와 테스트를 route-shape 회귀로부터 보호

---

## 핵심 규칙

- 앱이 `testClient()` 또는 `hc`를 쓰면 route type inference를 보호
- `hc` 또는 shared RPC/client contract가 앱에 의존하면 `AppType` export
- 큰 앱에서는 sub-app composition 타입이 exported surface까지 유지되어야 함
- Typed RPC와 generated OpenAPI docs가 일치하도록 explicit response status를 유지

## 예시

```ts
export const app = new Hono()
  .get('/search', (c) => {
    const query = c.req.query('q')
    return c.json({ query })
  })

export type AppType = typeof app
```

## Large-App Contract Pattern

```ts
// app.ts
export const app = createApp()
  .route('/users', usersApp)
  .route('/billing', billingApp)

export type AppType = typeof app
```

```ts
// client.ts
import { hc } from 'hono/client'

import type { AppType } from './app'

export const client = hc<AppType>('/api')
```

Route behavior test에는 `app.request()`, typed server-side ergonomics에는 `testClient()`, shared client-contract check에는 `hc<AppType>()`를 사용합니다.

## 비준수 시그널

- Route registration이 chained route type을 지우는 detached mutation을 사용함
- Consumer가 전체 API를 기대하는데 `AppType`이 partial sub-app에서 export됨
- 여러 success/error variant가 있는 route에서 response helper가 explicit status를 빠뜨림
- Frontend typed client가 exported app type 대신 route internals를 import함
- Generated OpenAPI response schema가 RPC-inferred response variants와 다름
- Public client가 404 shape에 의존하지만 `app.notFound()` 또는 explicit JSON response contract가 테스트되지 않음

## 리뷰 체크리스트

- route type이 exported app까지 흐름
- 리팩터링 후에도 `testClient()`가 계속 유용함
- `hc<AppType>` 또는 sub-app client 추론이 유지됨
- test가 있다는 이유만이 아니라 RPC/client consumer가 있을 때 `AppType`이 export됨
- detached registration이 조용히 타입을 지우지 않음
- 변경된 동작을 `app.request()` 또는 runtime adapter의 동등한 방식으로 request-level test가 검증함
- Public route shape가 바뀌면 typed client 또는 OpenAPI contract check도 갱신됨
