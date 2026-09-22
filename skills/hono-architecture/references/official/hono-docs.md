# Hono Official Docs Summary

last_verified_at: 2026-08-04

## Stable package snapshot

Verified from npm registry metadata on 2026-08-04. These are evidence snapshots, not automatic upgrade targets.

| Package | Stable | Compatibility observed |
|---|---:|---|
| `hono` | 4.13.0 | Node engine `>=16.9.0` in the core package |
| `@hono/node-server` | 2.1.0 | Node `>=20`, Hono `^4` |
| `@hono/zod-validator` | 0.9.0 | Hono `>=4.11.2`, Zod `^3.25.0 || ^4.0.0` |
| `@hono/standard-validator` | 0.3.0 | Hono `>=4.11.2`, Standard Schema `^1.0.0` |
| `@hono/zod-openapi` | 1.5.1 | Hono `>=4.10.0`, Zod 4 |
| `@hono/swagger-ui` | 0.6.1 | Hono `>=4.0.0` |
| `hono-openapi` | 1.3.1 | Third-party; Hono `^4.11.2` plus Standard Schema peers |

Sources: [npm registry: hono](https://registry.npmjs.org/hono), [Hono middleware repository](https://github.com/honojs/middleware), [`@hono/node-server`](https://github.com/honojs/node-server), [`hono-openapi`](https://github.com/rhinobase/hono-openapi)

Installed manifests and lockfiles win for implementation. Re-check registry metadata before changing dependencies after the verification date.

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

15. The root app provides `use`, `route`, `basePath`, `notFound`, and `onError`; `notFound` is called only from the top-level app, while route-level `onError` handlers take priority over a parent handler.
Source: [App API](https://hono.dev/docs/api/hono)

16. Middleware executes in registration order and typed variables accumulate across chained middleware. Shared middleware placement therefore affects both behavior and inferred context.
Source: [Middleware Guide](https://hono.dev/docs/guides/middleware)

17. Hono is Web-Standards based and supports multiple runtimes, while Node.js runs through `@hono/node-server`. A runtime-neutral app plus separate adapter entrypoint is a Hypercore portability convention grounded in those facts, not an official required folder layout.
Source: [Hono repository](https://github.com/honojs/hono), [Node.js Guide](https://hono.dev/docs/getting-started/nodejs), [`@hono/node-server`](https://github.com/honojs/node-server)

## How this affects the skill

- Hypercore route composition rules are grounded in official `app.route()` and factory guidance.
- Hypercore validation rules should not invent a custom validation surface before checking the existing repo standard.
- Hypercore error handling rules must not claim `HTTPException.getResponse()` preserves context-set headers automatically.
- Hypercore testing and RPC rules must protect chained app typing instead of treating detached registration as harmless.
- Hypercore OpenAPI rules should keep runtime validation, typed RPC responses, and generated OpenAPI responses aligned.
- Swagger UI exposure is a platform/security decision separate from spec generation.
- Large apps should compose route modules, typed clients, and OpenAPI metadata from the same app boundary to avoid drift.
- Database bindings and request-scoped database variables should be typed through `Bindings` / `Variables`, while route modules should stay independent from provider-specific setup.

## Sources

> Links checked 2026-08-04, the date carried by this file's own `last_verified_at` marker. No page was re-fetched in the 2026-09-21 pass, and no source outside the citations above is claimed.

| Claim | Source |
|---|---|
| The package versions and compatibility ranges in the snapshot table above | the registry and repository URLs listed beside that table |
| The official Hono and OpenAPI behavior recorded in points 1-17 above | the inline `Source:` links on each numbered point above |
