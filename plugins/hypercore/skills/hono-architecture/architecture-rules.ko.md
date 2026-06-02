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
| Typing | middleware/handler 전반의 untyped `c.set()` / `c.get()` variables |
| Errors | 사소하지 않은 API에서 중앙 error policy 누락 |
| RPC | chained type을 잃어 `AppType` / `testClient` / `hc` inference 깨뜨림 |
| Platform | runtime adapter/bootstrap code를 route module에 섞음 |
| Filenames | camelCase (`userProfile.ts`, `createUser.ts`) |
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
Repositories / External Clients
  repositories/*.ts, clients/*.ts, database/*.ts
```

**Data flow rules:**
- Transport concerns는 routes, handlers, middleware, response shaping에 둡니다.
- Domain logic은 services/use-cases에 둡니다.
- Storage/SDK logic은 repositories 또는 clients에 둡니다.
- Route modules는 기본적으로 controller layer로 커지지 않아야 합니다.

---

## Route Structure Rules

### 권장 폴더 구조

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
└── repositories/
```

### 규칙

- 하나의 명확한 app composition path를 유지합니다.
- Domain sub-app은 `app.route()`로 mount하는 방식을 선호합니다.
- health check 같은 작은 endpoint에만 single-file route module을 허용합니다.
- feature에 schemas, handlers, middleware, service helpers가 필요하면 route folders를 사용합니다.
- Runtime-specific bootstrap은 route modules 밖에 둡니다.

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
- `hc<typeof app>`와 `AppType` exports에는 안정적인 typed app composition이 필요합니다.
- 큰 application에서는 sub-app으로 조심스럽게 나누고 typed mounting pattern을 보존합니다.
- Detached registration으로 route typing을 쉽게 깨뜨리지 않습니다.

---

## Platform Setup Rules

- Runtime adapter는 `index.ts`, `server.ts`, `worker.ts` 또는 다른 edge bootstrap file에 둡니다.
- Environment bindings와 config를 명시적으로 type 지정합니다.
- `showRoutes()` 같은 dev helper는 명시적인 dev-only setup 뒤에 둡니다.
- `basePath()` / version prefixes는 handler별 ad hoc 방식이 아니라 의도적으로 사용합니다.
