# Testing과 RPC

> typed client와 테스트를 route-shape 회귀로부터 보호

---

## Stable Hono 4.13 기준

Hono RPC는 server와 client 모두 TypeScript `strict`를 요구합니다. Producer/consumer Hono version은 일치해야 하며 version skew는 excessively deep type instantiation을 일으킬 수 있습니다. 큰 contract는 editor performance도 저하시킬 수 있습니다.

- 최종 chained route value에서 `AppType`을 export하며 나중에 mutate된 app이나 partial child에서 export하지 않습니다.
- Package boundary에서는 declaration을 compile/consume하거나 project reference를 사용하고 server implementation을 deep import하지 않습니다.
- Shared global error response typing에는 `ApplyGlobalResponse`를 사용합니다.
- Client contract를 관찰 가능하게 만들 때 `parseResponse()`, `InferRequestType`, `InferResponseType`을 사용합니다.
- `hc`는 path parameter value를 자동 URL-encode하지 않습니다. Slash를 허용하면 value를 encode하거나 명시적으로 test한 regexp route를 사용합니다.
- Behavior에는 `app.request()`, server-side typed ergonomics에는 `testClient()`, serialization/base URL behavior가 중요할 때만 실제 `hc` boundary test를 사용합니다.
- Runtime binding은 `app.request()`의 세 번째 argument로 전달하고 adapter-specific behavior는 별도로 test합니다.
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

## Sources

> 이 파일에는 외부 출처를 사용하지 않았습니다. 공식 Hono 동작은 `references/official/hono-docs.ko.md`에 위임합니다(last verified 2026-08-04). 저장소 로컬 링크 확인 2026-09-21.
