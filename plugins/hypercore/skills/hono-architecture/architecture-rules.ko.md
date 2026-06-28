# 아키텍처 규칙 참조

> Hono hypercore 프로젝트를 위한 전체 규칙 세트

참고: 아래 일부 규칙은 Hono 기본값보다 엄격합니다. 이는 보편적인 프레임워크 요구사항이 아니라 hypercore 팀 컨벤션입니다.

Brownfield 적용 규칙: 손대지 않은 레거시 코드는 문제가 스타일 또는 hypercore 전용 사항이면 즉시 실패가 아니라 마이그레이션 작업으로 추적할 수 있습니다. 안전, 타입, 검증, 전송 경계 문제는 특히 변경한 코드에서 즉시 차단합니다.

---

## 금지

| 범주 | 금지 사항 |
|----------|-----------|
| Controllers | 단순 route module 또는 handler factory로 충분한데 controller 중심 class/file 도입 |
| Routes | 명확한 composition entry 없이 흩어진 등록 |
| Order | 구체 route보다 fallback/catch-all route를 먼저 등록 |
| Validation | 사소하지 않은 handler에서 raw `c.req.json()` parsing 반복 |
| Database | routes/handlers에서 DB/ORM client, Drizzle schema table, pool, migration helper 직접 import |
| Migrations | request handler에서 database migration 생성, push, 실행 |
| Typing | middleware/handler 전반의 untyped `c.set()` / `c.get()` variables |
| Errors | 사소하지 않은 API에서 중앙 error policy 누락 |
| OpenAPI | 저장소가 docs를 발행하는데 public API route 변경에 맞는 OpenAPI/Swagger contract update 누락 |
| RPC | chained type을 잃어 `AppType` / `testClient` / `hc` inference 깨뜨림 |
| Platform | runtime adapter/bootstrap code를 route module에 섞음 |
| Paths | camelCase 또는 PascalCase source folder/file (`userProfile.ts`, `createUser.ts`, `routes/UserProfile/`) |
| TypeScript | `any` type, const arrow function이 적절한 곳의 `function` declaration |
| Git | AI markers, emojis, multi-line commit messages |

---

## 레이어 아키텍처

```text
Runtime Edge / Adapter
  index.ts / server.ts / worker.ts
       |
       v
Hono App Composition
  app.ts -> app.route('/users', usersApp)
       |
       v
Route Modules / Handlers
  routes/<domain>/index.ts
       |
       v
Services / Use Cases
  services/<domain>/*.ts
       |
       v
Repositories / External Clients / Database Boundary
  repositories/<domain>/*.ts, clients/*.ts
  database/client.ts, database/schema.ts, drizzle/migrations
```

**Data flow rules:**
- Transport concerns는 routes, handlers, middleware, response shaping에 둡니다.
- Domain logic은 services/use-cases에 둡니다.
- Storage/SDK logic은 repositories 또는 clients에 둡니다.
- Database connection setup, ORM configuration, schema, migration은 database boundary에 둡니다.
- Route는 database client, Drizzle table definition, driver client, migration helper를 직접 import하지 않습니다.
- Route modules는 기본적으로 controller layer로 커지지 않아야 합니다.

---

## Route Structure Rules

### 작은 API 권장 구조

```text
src/
├── app.ts
├── index.ts
├── lib/
│   └── create-app.ts
├── middlewares/
│   ├── auth.ts
│   └── request-id.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── schemas.ts
│       └── service.ts
├── services/
├── repositories/
└── database/
    ├── client.ts
    └── schema.ts
```

작은 API와 초기 프로젝트에는 이 구조를 사용합니다. Mount table을 눈에 보이게 유지하면서 feature folder로 확장할 여지를 남깁니다.

### 중간/대형 API 권장 구조

```text
src/
├── app.ts
├── index.ts
├── lib/
│   ├── create-app.ts
│   ├── env.ts
│   └── types.ts
├── middlewares/
│   ├── auth.ts
│   ├── error-boundary.ts
│   └── request-id.ts
├── openapi/
│   ├── components.ts
│   ├── errors.ts
│   └── registry.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── routes.ts
│       ├── schemas.ts
│       ├── service.ts
│       └── tests/
├── services/
│   └── users/
├── repositories/
│   └── users/
├── database/
│   ├── client.ts
│   ├── schema.ts
│   └── types.ts
├── drizzle/
│   └── migrations/
└── clients/
```

여러 feature area, generated docs, typed client, runtime binding이 app contract에 포함되면 이 구조를 사용합니다.

### Feature 성장 기준

| 규모 | 구조 |
|------|------|
| 아주 작은 운영 endpoint | `routes/health.ts` 같은 한 파일 허용 |
| 작은 feature | `routes/<feature>/index.ts`와 local `schemas.ts` 또는 `handlers.ts` |
| 중간 feature | `handlers.ts`, `schemas.ts`, `service.ts` 분리 후 `routes/index.ts` 또는 `app.ts`에서 mount |
| 큰 feature | local `routes.ts` / OpenAPI metadata, 필요한 경우 local middleware, feature 근처 tests, persistence 작업을 위한 repository/service boundary를 둠 |

### 규칙

- 하나의 명확한 app composition path를 유지합니다.
- Domain sub-app은 `app.route()`로 mount하는 방식을 선호합니다.
- health check 같은 작은 endpoint에만 single-file route module을 허용합니다.
- Tool 또는 external contract가 고정 filename을 요구하지 않는 한 source folder/file은 kebab-case로 짓습니다.
- feature에 schemas, handlers, middleware, service helpers가 필요하면 route folders를 사용합니다.
- Runtime-specific bootstrap은 route modules 밖에 둡니다.
- Database client, ORM schema table, migration은 route modules 밖에 둡니다.
- 큰 API에서는 `app.ts` / `routes/index.ts`를 mount table로 유지하고 feature끼리 route import를 하지 않습니다.
- Shared OpenAPI components는 feature folder 밖에 두되, feature operation metadata는 설명하는 route 근처에 둡니다.

## Scalability Rules

- controller class가 아니라 feature boundary를 먼저 기준으로 확장합니다.
- Feature, route, service, repository, middleware, database-support path는 kebab-case로 유지해 큰 프로젝트에서 import, test, docs, generated artifact가 예측 가능하게 합니다.
- Route module은 transport, validation, service call, response shaping을 orchestration하고 persistence나 third-party SDK 세부사항을 소유하지 않습니다.
- Shared middleware는 `middlewares/`에 두고, feature-only middleware는 `routes/<feature>/` 아래 둘 수 있습니다.
- Shared schema, error envelope, OpenAPI component는 최소 두 feature가 재사용할 때만 중앙화합니다.
- Database client와 ORM setup은 handler가 아니라 `database/` 또는 runtime/platform factory에 둡니다.
- Repository는 query detail을 숨기고 Hono `Context`, headers, cookies, request body를 읽지 않습니다.
- 여러 write가 함께 commit/rollback되어야 하면 transaction boundary는 service/use-case에 둡니다.
- Drizzle schema와 migration folder는 `drizzle.config.ts`와 일치해야 하고 route folder 밖에 둡니다.
- Public DTO는 raw ORM row를 그대로 노출하지 말고 의도적으로 mapping합니다.
- `/api`, `/v1` 같은 version prefix는 handler마다 넣지 말고 `basePath()` 또는 하나의 mount table 같은 composition boundary에 둡니다.
- Brownfield app을 이관할 때 touched file의 safety/type/validation 문제는 즉시 고치고, 전체 split이 위험한 순수 구조 drift는 backlog로 기록합니다.
- 큰 app review는 route composition, generated docs, typed clients가 같은 exported app surface에서 파생되는지 확인해야 합니다.

---

## Handler Typing Rules

### 선호하는 small-module pattern

```ts
const usersApp = new Hono()
  .get('/', listUsers)
  .post('/', createUser)
```

### 선호하는 extracted-handler pattern

```ts
const factory = createFactory<Env>()

const handlers = factory.createHandlers(listUsers, createUser)

const usersApp = factory
  .createApp()
  .get('/', ...handlers)
```

### 핵심 규칙

- Handler를 추출했다면 `createFactory()` / `createHandlers()`로 typing을 유지합니다.
- Middleware 또는 runtime context가 의존하는 경우 `Bindings`와 `Variables`를 명시적으로 type 지정합니다.
- Request parsing, validation, service orchestration을 읽기 쉽게 유지합니다.

---

## Validation Rules

- Domain logic이 params, query, headers, form, json을 사용하기 전에 validator middleware를 사용합니다.
- 공식 Hono 문서는 더 강한 schema를 위해 third-party validator를 권장합니다.
- 선호 옵션:
  - 좁은 built-in check에는 `validator()`
  - Zod 기반 repo에는 `@hono/zod-validator`
  - repo가 Standard Schema libraries를 표준화했다면 `@hono/standard-validator`
- Feature 내부에서 validation strategy를 일관되게 유지합니다.

## Database / ORM Rules

- Persistence는 route implementation detail이 아니라 별도 architecture boundary로 취급합니다.
- 사소하지 않은 persisted behavior에는 `routes -> services -> repositories -> database client` 흐름을 선호합니다.
- Runtime에 맞는 Drizzle driver 또는 database client를 사용합니다. Edge route에 Node 전용 database setup을 하드코딩하지 않습니다.
- Cloudflare Workers/D1에서는 database binding이 typed Hono `Bindings` / `c.env`를 통해 흐르게 합니다.
- Node/serverful runtime에서는 pool/client를 request마다 만들지 말고 module 또는 bootstrap scope에서 만듭니다.
- Module scope를 재사용하는 serverless runtime에서는 provider가 지원할 때 reusable client와 prepared statement를 handler scope 밖에 둡니다.
- Drizzle schema와 generated migration은 안정적인 database/migration boundary에 두고 generated SQL은 merge 전에 리뷰합니다.
- Multi-step write에는 service-layer transaction을 명시하고 repository에는 `tx` handle을 넘깁니다.
- 자세한 Drizzle, migration, transaction, DTO, non-compliance check는 `rules/database.ko.md`를 봅니다.

## OpenAPI / Swagger Rules

- OpenAPI는 장식용 docs page가 아니라 API contract로 취급합니다.
- Zod-first repo는 `@hono/zod-openapi`, 여러 Standard Schema-compatible validator를 이미 쓰는 repo는 `hono-openapi`를 우선 검토합니다.
- Validation schema와 documented schema를 일치시킵니다. 가능하면 하나의 schema source를 사용합니다.
- `/doc` 또는 `/openapi.json` 같은 canonical spec endpoint를 하나 둡니다.
- Swagger UI는 `/ui` 같은 별도 route에서 제공하고, 환경과 제품 결정에 맞게 보호합니다.
- 문서화된 operation에는 안정적인 `operationId`, `tags`, request schema, success responses, expected error responses, useful examples를 포함합니다.
- Shared schemas, parameters, responses, examples, security schemes는 reusable OpenAPI components에 둡니다.
- 큰 app에서는 feature별 OpenAPI route metadata를 app boundary에서 조합하고 spec fragment를 수동 복붙하지 않습니다.
- Spec을 publish하거나 codegen에 쓰기 전에 generated spec을 validate 또는 lint합니다.

---

## Middleware Rules

- Registration order가 중요합니다. Middleware와 handler는 추가된 순서대로 실행됩니다.
- Shared auth/logging/request-id/CORS concerns는 middleware에 둡니다.
- `Context`는 request별입니다. `c.set()` state를 cross-request storage처럼 다루지 않습니다.
- Middleware가 제공하는 variables는 app/factory generics로 type 지정합니다.

---

## Error Handling Rules

- 사소하지 않은 API에는 중앙 `app.onError()` policy를 추가합니다.
- 예상 가능한 HTTP failure에는 `HTTPException` 또는 동등한 explicit translation path를 사용합니다.
- `HTTPException`에서 response를 다시 만들 때는 `Context`에 이미 설정된 headers를 보존합니다.
- App이 client surface를 export한다면 not-found handling은 typed RPC와 호환되게 유지합니다.

---

## Testing / RPC Rules

- `testClient()` type inference는 route type이 chained app definitions를 통해 흐르는지에 의존합니다.
- `hc<AppType>`와 `AppType` exports에는 안정적인 typed app composition이 필요합니다.
- 큰 application에서는 sub-app으로 조심스럽게 나누고 typed mounting pattern을 보존합니다.
- Detached registration으로 route typing을 쉽게 깨뜨리지 않습니다.
- Route behavior는 `app.request()` 같은 request-level test로, RPC surface를 노출하는 경우 contract behavior는 typed client로 검증합니다.
- RPC client와 OpenAPI docs가 status-specific payload에 대해 합의하도록 explicit response status를 유지합니다.

---

## Platform Setup Rules

- Runtime adapter는 `index.ts`, `server.ts`, `worker.ts` 또는 다른 edge bootstrap file에 둡니다.
- Environment bindings와 config를 명시적으로 type 지정합니다.
- `showRoutes()` 같은 dev helper는 명시적인 dev-only setup 뒤에 둡니다.
- `basePath()` / version prefixes는 handler별 ad hoc 방식이 아니라 의도적으로 사용합니다.
