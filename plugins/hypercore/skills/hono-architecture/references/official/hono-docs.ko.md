# Hono 공식 문서 요약

검증일: 2026-06-28

코어 스킬이나 규칙 파일에서 공식 문서 재확인이 필요할 때 이 참조를 사용합니다.

## 공식 문서로 확인한 핵심 포인트

1. Best practices는 작은 app과 `app.route()` 조합을 선호하며, 가능하면 controller를 만들지 말라고 명시합니다.
출처: [Best Practices](https://hono.dev/docs/guides/best-practices)

2. `createFactory()`, `createHandlers()`, `createApp()`는 핸들러와 미들웨어를 분리해도 타입을 유지하기 위한 공식 도구입니다.
출처: [Factory Helper](https://hono.dev/docs/helpers/factory)

3. `Context`는 요청마다 새로 만들어집니다. 요청 범위 값, 헤더, 상태 코드를 담을 수 있고, `c.set()` / `c.get()`를 쓸 때는 app generics를 통해 `Variables` 타입을 주는 것이 맞습니다.
출처: [Context API](https://hono.dev/docs/api/context)

4. 미들웨어와 핸들러는 등록 순서대로 실행됩니다. 따라서 fallback이나 catch-all 위치가 중요합니다.
출처: [Routing API](https://hono.dev/docs/api/routing), [Middleware Guide](https://hono.dev/docs/guides/middleware)

5. Hono의 validation은 middleware 기반입니다. 공식 문서는 third-party validator 사용을 권장하고, `@hono/zod-validator`와 `@hono/standard-validator`를 공식 생태계 옵션으로 제공합니다.
출처: [Validation Guide](https://hono.dev/docs/guides/validation)

6. `HTTPException.getResponse()`는 `Context`를 모릅니다. 이미 `Context`에 세팅한 헤더가 있다면 새 응답에 명시적으로 보존해야 합니다.
출처: [HTTPException API](https://hono.dev/docs/api/exception)

7. `testClient()`는 route가 Hono 인스턴스에 체이닝된 형태로 정의되어야 타입 추론이 제대로 됩니다.
출처: [Testing Helper](https://hono.dev/docs/helpers/testing)

8. 큰 앱에서 RPC를 쓸 때는 type inference가 유지되도록 sub-app 조합을 조심해야 하고, typed client는 안정적인 `AppType` 또는 sub-app export에 의존합니다.
출처: [RPC Guide](https://hono.dev/docs/guides/rpc)

9. `app.request()`는 request/response 테스트를 지원하고, Hono는 route contract용 typed testing helper도 제공합니다.
출처: [Testing Guide](https://hono.dev/docs/guides/testing), [Testing Helper](https://hono.dev/docs/helpers/testing)

10. `@hono/zod-openapi`는 `OpenAPIHono`, `createRoute()`, `app.openapi()`, `app.doc()` / `app.doc31()`를 사용해 route schema에서 OpenAPI 문서를 생성합니다.
출처: [Zod OpenAPI Example](https://hono.dev/examples/zod-openapi), [`@hono/zod-openapi` README](https://github.com/honojs/middleware/tree/main/packages/zod-openapi)

11. `hono-openapi`는 `describeRoute()`, `validator()`, `resolver()`, `openAPIRouteHandler()`를 통한 middleware-driven OpenAPI 생성을 지원하며 여러 validator ecosystem에 맞습니다.
출처: [Hono OpenAPI Example](https://hono.dev/examples/hono-openapi), [`hono-openapi` README](https://github.com/rhinobase/hono-openapi)

12. `@hono/swagger-ui`는 Hono route에서 Swagger UI를 제공하고 generated spec endpoint를 가리켜야 합니다. 이 패키지 자체가 spec을 생성하지는 않습니다.
출처: [Swagger UI Example](https://hono.dev/examples/swagger-ui), [`@hono/swagger-ui` README](https://github.com/honojs/middleware/tree/main/packages/swagger-ui)

13. OpenAPI operation은 responses와 reusable components를 명시해야 합니다. Security schemes는 `components.securitySchemes`에 두고, examples도 reusable components로 둘 수 있습니다.
출처: [OpenAPI Specification 3.1.0](https://spec.openapis.org/oas/v3.1.0.html), [Swagger Authentication Docs](https://swagger.io/docs/specification/v3_0/authentication/), [Swagger `$ref` Docs](https://swagger.io/docs/specification/v3_0/using-ref/), [Swagger Examples Docs](https://swagger.io/docs/specification/v3_0/adding-examples/)

14. Hono environment binding은 app generics로 type 지정하고 `c.env`로 접근합니다. Cloudflare Workers 문서는 D1 등 binding을 `Bindings` 모델로 다루고, Factory Helper 문서는 `initApp`에서 `c.env`로 Drizzle D1 database를 만들고 typed `Variables`에 저장하는 예시를 제공합니다.
출처: [Context API](https://hono.dev/docs/api/context), [Cloudflare Workers](https://hono.dev/docs/getting-started/cloudflare-workers), [Factory Helper](https://hono.dev/docs/helpers/factory)

## 이 스킬에 미치는 영향

- hypercore의 route composition 규칙은 공식 `app.route()` / factory 가이드를 근거로 삼아야 합니다.
- hypercore validation 규칙은 기존 저장소 표준을 먼저 보고, 새 검증 표면을 함부로 발명하면 안 됩니다.
- hypercore error handling 규칙은 `HTTPException.getResponse()`가 context-set header를 자동 보존한다고 가정하면 안 됩니다.
- hypercore testing/RPC 규칙은 detached registration을 가볍게 보지 말고 체이닝된 app typing을 보호해야 합니다.
- hypercore OpenAPI 규칙은 runtime validation, typed RPC responses, generated OpenAPI responses가 서로 맞도록 보호해야 합니다.
- Swagger UI 노출은 spec generation과 별개의 platform/security 결정입니다.
- 큰 앱에서는 route modules, typed clients, OpenAPI metadata가 같은 app boundary에서 조합되도록 해야 drift를 줄일 수 있습니다.
- Database binding과 request-scoped database variable은 `Bindings` / `Variables`로 type 지정하고, route module은 provider-specific setup에서 독립적으로 유지해야 합니다.
