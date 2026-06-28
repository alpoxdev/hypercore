# Hono Official Docs Summary

Verified on: 2026-06-28

Use this reference when the core skill or rule files need an official-doc check.

## Confirmed points from official docs

1. Best practices favor smaller apps and `app.route()` composition, and explicitly say not to make controllers when possible.
Source: [Best Practices](https://hono.dev/docs/guides/best-practices)

2. `createFactory()`, `createHandlers()`, and `createApp()` exist to preserve types when extracting handlers and middleware.
Source: [Factory Helper](https://hono.dev/docs/helpers/factory)

3. `Context` is instantiated per request. It can hold request-scoped values, headers, and status, and typed `Variables` should be supplied through app generics when using `c.set()` / `c.get()`.
Source: [Context API](https://hono.dev/docs/api/context)

4. Middleware and handlers execute in registration order. Fallback and catch-all placement therefore matters.
Source: [Routing API](https://hono.dev/docs/api/routing), [Middleware Guide](https://hono.dev/docs/guides/middleware)

5. Hono validation is middleware-based. The docs recommend using a third-party validator, and the official ecosystem supports both `@hono/zod-validator` and `@hono/standard-validator`.
Source: [Validation Guide](https://hono.dev/docs/guides/validation)

6. `HTTPException.getResponse()` is not aware of `Context`; if headers were already set on `Context`, a new response must preserve them explicitly.
Source: [HTTPException API](https://hono.dev/docs/api/exception)

7. `testClient()` only infers route types correctly when routes are defined through chained methods on the Hono instance whose type is exported.
Source: [Testing Helper](https://hono.dev/docs/helpers/testing)

8. Larger-app RPC composition needs care to preserve type inference, and typed clients depend on stable `AppType` or sub-app exports.
Source: [RPC Guide](https://hono.dev/docs/guides/rpc)

9. `app.request()` supports request/response testing, and Hono also provides typed testing helpers for route contracts.
Source: [Testing Guide](https://hono.dev/docs/guides/testing), [Testing Helper](https://hono.dev/docs/helpers/testing)

10. `@hono/zod-openapi` uses `OpenAPIHono`, `createRoute()`, `app.openapi()`, and `app.doc()` / `app.doc31()` to generate OpenAPI documents from route schemas.
Source: [Zod OpenAPI Example](https://hono.dev/examples/zod-openapi), [`@hono/zod-openapi` README](https://github.com/honojs/middleware/tree/main/packages/zod-openapi)

11. `hono-openapi` supports middleware-driven OpenAPI generation with `describeRoute()`, `validator()`, `resolver()`, and `openAPIRouteHandler()` for multiple validator ecosystems.
Source: [Hono OpenAPI Example](https://hono.dev/examples/hono-openapi), [`hono-openapi` README](https://github.com/rhinobase/hono-openapi)

12. `@hono/swagger-ui` serves Swagger UI from a Hono route and should point at a generated spec endpoint; it does not generate the spec by itself.
Source: [Swagger UI Example](https://hono.dev/examples/swagger-ui), [`@hono/swagger-ui` README](https://github.com/honojs/middleware/tree/main/packages/swagger-ui)

13. OpenAPI operations should define responses and reusable components explicitly; security schemes belong under `components.securitySchemes`, and examples can be reusable components.
Source: [OpenAPI Specification 3.1.0](https://spec.openapis.org/oas/v3.1.0.html), [Swagger Authentication Docs](https://swagger.io/docs/specification/v3_0/authentication/), [Swagger `$ref` Docs](https://swagger.io/docs/specification/v3_0/using-ref/), [Swagger Examples Docs](https://swagger.io/docs/specification/v3_0/adding-examples/)

14. Hono environment bindings are typed through app generics and accessed with `c.env`. The Cloudflare Workers docs include D1 and other bindings as part of the `Bindings` model, and the Factory Helper docs show an `initApp` example that creates a Drizzle D1 database from `c.env` and stores it in typed `Variables`.
Source: [Context API](https://hono.dev/docs/api/context), [Cloudflare Workers](https://hono.dev/docs/getting-started/cloudflare-workers), [Factory Helper](https://hono.dev/docs/helpers/factory)

## How this affects the skill

- Hypercore route composition rules are grounded in official `app.route()` and factory guidance.
- Hypercore validation rules should not invent a custom validation surface before checking the existing repo standard.
- Hypercore error handling rules must not claim `HTTPException.getResponse()` preserves context-set headers automatically.
- Hypercore testing and RPC rules must protect chained app typing instead of treating detached registration as harmless.
- Hypercore OpenAPI rules should keep runtime validation, typed RPC responses, and generated OpenAPI responses aligned.
- Swagger UI exposure is a platform/security decision separate from spec generation.
- Large apps should compose route modules, typed clients, and OpenAPI metadata from the same app boundary to avoid drift.
- Database bindings and request-scoped database variables should be typed through `Bindings` / `Variables`, while route modules should stay independent from provider-specific setup.
