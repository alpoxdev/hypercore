# OpenAPI와 Swagger

> 생성된 API 문서를 typed contract boundary로 취급

---

## 핵심 규칙

Hono API가 OpenAPI/Swagger docs를 발행한다면, route 변경은 같은 변경 안에서 generated contract도 갱신해야 합니다. Contract는 runtime route가 실제로 지원하는 request, response, status code, security, example과 일치해야 합니다.

Database row는 자동으로 public API DTO가 아닙니다. Persistence 변경이 문서화된 response에 영향을 주면 publish 또는 codegen 전에 ORM row를 public response schema로 매핑합니다.

## 승인된 생성 경로

| Repo 형태 | 우선 경로 |
|------|------|
| Zod-first routes | `@hono/zod-openapi`의 `OpenAPIHono`, `createRoute()`, `app.openapi()`, `app.doc()` |
| Mixed validator 또는 Standard Schema repos | `hono-openapi`의 `describeRoute()`, `resolver()`, `validator()`, `openAPIRouteHandler()` |
| UI only | Generated spec endpoint에 연결한 `@hono/swagger-ui` |

사용자가 명시적으로 migration을 요청하지 않았다면 앱 전체의 generator를 바꾸지 않습니다.

## 폴더 구조

```text
src/
├── app.ts
├── openapi/
│   ├── components.ts
│   ├── errors.ts
│   └── registry.ts
└── routes/
    └── users/
        ├── index.ts
        ├── routes.ts
        ├── schemas.ts
        └── handlers.ts
```

- Shared components, security schemes, examples, error envelopes는 두 개 이상 feature가 재사용할 때 `src/openapi/`에 둡니다.
- Feature operation metadata는 설명하는 feature route 근처에 둡니다.
- Canonical spec은 app boundary에서 조합하고, generated fragment를 손으로 복붙하지 않습니다.
- `/doc` 또는 `/openapi.json` 같은 안정적인 spec path를 사용합니다.
- Swagger UI는 `/ui`, `/docs`, admin route 같은 별도 path에서 제공합니다.

## Operation Metadata Checklist

문서화된 모든 operation은 아래를 정의해야 합니다:

- 안정적인 `operationId`
- 일관된 `tags`
- Path params, query params, headers, request body schemas
- Status별 JSON schema가 있는 success responses
- 필요한 경우 400, 401, 403, 404, 409, 422, 500 같은 expected error responses
- Reusable `components.securitySchemes`를 통한 auth requirements
- Schema와 일치하는 request/response examples
- Public으로 노출하면 안 되는 endpoint의 deprecation 또는 hide metadata

## Contract Drift Rules

| Drift | 규칙 |
|------|------|
| Handler가 OpenAPI에 없는 validated data를 읽음 | 차단. Request schema를 추가하거나 route 문서화를 중단합니다. |
| OpenAPI가 handler가 반환하지 않는 response status를 나열함 | 경고. Codegen/client publish 전에 handler 또는 docs를 고칩니다. |
| Handler는 status-specific payload를 반환하지만 docs는 generic response만 보여줌 | 경고. 명시적 response schema를 추가합니다. |
| OpenAPI response schema가 internal/sensitive field를 포함한 raw ORM row를 노출함 | 차단. DTO mapping을 추가하고 public response contract를 문서화합니다. |
| Shared auth middleware가 있는데 OpenAPI에 security requirements가 없음 | Public/partner-facing docs에서는 차단. |
| Swagger UI가 실수로 public 노출됨 | 차단. Auth/admin/dev gating을 추가하거나 public-docs 결정을 문서화합니다. |
| Generated spec lint 실패 또는 깨진 `$ref`가 있음 | Publish 전에 차단. |

## Large-App Pattern

`@hono/zod-openapi`에서는 feature-local route definition과 app-level registration을 선호합니다:

```ts
// routes/users/routes.ts
import { createRoute } from '@hono/zod-openapi'

export const listUsersRoute = createRoute({
  method: 'get',
  path: '/',
  operationId: 'listUsers',
  tags: ['Users'],
  responses: {
    200: {
      description: 'Users returned',
      content: {
        'application/json': {
          schema: usersResponseSchema,
        },
      },
    },
  },
})

export const userRoutes = [listUsersRoute] as const
```

```ts
// app.ts
const app = new OpenAPIHono()

app.openapiRoutes([...userRoutes, ...billingRoutes] as const)
app.doc('/doc', { openapi: '3.0.0', info: { title: 'API', version: '1.0.0' } })
app.get('/ui', swaggerUI({ url: '/doc' }))
```

`hono-openapi`에서는 route-local `describeRoute()` metadata와 단일 app-level `openAPIRouteHandler()` endpoint를 선호합니다.

## Version and Package Caveats

- `@hono/zod-openapi`의 일반 예시는 `app.doc()`와 OpenAPI 3.0을 보여주지만, 3.1 output이 필요하면 `app.doc31()` / `getOpenAPI31Document()` 지원 여부를 확인합니다.
- `@hono/swagger-ui`는 spec을 생성하지 않고 UI를 제공합니다. `url`은 단일 spec, `urls`는 여러 spec에 사용합니다.
- `persistAuthorization`, `remoteAssets.baseUrl`, UI `version`, custom HTML은 deployment/UI knobs이며 spec contract knobs가 아닙니다.
- Plain `Hono` sub-app을 `OpenAPIHono` 아래에 섞으면 OpenAPI metadata가 spec에 합쳐지지 않을 수 있습니다.
- Nested OpenAPI sub-app을 mount할 때 parent `.route()` path parameter는 Hono `:param` syntax를 사용합니다.
- Header schema key는 Hono validator와 OpenAPI generator 모두에서 lowercase로 맞춥니다.

## 리뷰 체크리스트

- 하나의 generator strategy를 일관되게 사용함
- Spec endpoint와 Swagger UI endpoint가 분리되어 있고 의도적임
- Route validators와 documented schemas가 source 또는 synchronization rule을 공유함
- Database row shape가 publication 전에 public DTO schema로 매핑됨
- Reusable schemas, errors, security schemes, parameters, examples가 `components`를 사용함
- Operation ID가 안정적이고 unique함
- Error responses가 중앙 error handling과 일치함
- RPC `AppType`/typed client shape와 generated OpenAPI shape가 충돌하지 않음
- Publish 전에 CI 또는 local verification이 generated spec을 lint, bundle, validate함
