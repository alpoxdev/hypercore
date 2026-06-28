# 라우트 구조

> Hono route composition 규칙

---

## 작은 구조

```text
src/
├── app.ts
├── index.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── schemas.ts
│       └── service.ts
```

## 큰 구조

```text
src/routes/
├── index.ts
├── health.ts
├── users/
│   ├── index.ts
│   ├── routes.ts
│   ├── handlers.ts
│   ├── schemas.ts
│   ├── service.ts
│   └── tests/
└── billing/
    ├── index.ts
    ├── routes.ts
    ├── handlers.ts
    ├── schemas.ts
    ├── middleware.ts
    └── service.ts
```

`routes/index.ts` 또는 `app.ts`는 유일한 mount table로 남깁니다. Feature folder는 local route definition, handler, schema, feature-only middleware를 소유합니다.

## 규칙

- `app.ts`가 루트 app composition을 소유
- `routes/index.ts` 또는 `app.ts`가 mount table의 단일 진입점
- `app.route('/users', usersApp)` 같은 sub-app mount를 우선
- 기능이 두 파일 이상이면 route folder 사용
- health 같은 작은 운영 endpoint만 single-file route 허용
- handler가 두 개 이상이거나 request schema, feature middleware, OpenAPI metadata, service orchestration이 있으면 folder로 분리합니다.
- `basePath()`와 API version prefix는 composition boundary에 둡니다.
- Route module에서 database client, Drizzle schema table, ORM driver, migration helper를 import하지 않습니다. Service/repository를 사용합니다.
- 한 feature route module이 다른 feature route module을 import하지 않습니다.
- Hono dispatch는 registration order를 따르므로 fallback과 catch-all route는 마지막에 둡니다.

## 마운트 패턴

```ts
import { createApp } from '@/lib/create-app'
import { healthApp } from '@/routes/health'
import { usersApp } from '@/routes/users'

export const app = createApp()
  .route('/health', healthApp)
  .route('/users', usersApp)
```

## Scale-Up Pattern

```ts
// routes/users/index.ts
import { createApp } from '@/lib/create-app'

import { createUserHandlers, listUserHandlers } from './handlers'

export const usersApp = createApp()
  .get('/', ...listUserHandlers)
  .post('/', ...createUserHandlers)
```

```ts
// routes/index.ts
import { usersApp } from './users'
import { billingApp } from './billing'

export const routesApp = createApp()
  .route('/users', usersApp)
  .route('/billing', billingApp)
```

## 비준수 시그널

- Route registration이 단일 mount table 없이 관련 없는 파일들에 흩어져 있음
- Multi-feature app인데 `app.route()`가 없음
- Feature route folder가 service 대신 database/SDK client를 직접 import함
- Route handler가 DB connection, Drizzle client, pool, migration을 직접 생성함
- 한 route file에 schemas, 긴 handlers, feature middleware, business logic이 모두 섞여 있음
- fallback, `*`, `/:id` route가 더 구체적인 route보다 앞에 있음
- Version prefix가 한 곳에서 정의되지 않고 모든 feature 안에서 반복됨

## 리뷰 체크리스트

- composition 진입점이 하나로 명확함
- route mount 순서가 의도적임
- fallback route가 마지막에 위치
- 큰 기능은 flat giant file 대신 sub-app folder 사용
- 새 route가 들어갈 위치가 명확할 만큼 feature boundary가 분명함
- Persistence 작업이 사소하지 않다면 service/repository boundary를 거침
- Route structure가 tests, RPC, OpenAPI generation을 위한 typed app inference를 보존함
