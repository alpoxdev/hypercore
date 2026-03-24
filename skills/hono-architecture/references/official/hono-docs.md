# Hono Official Docs Summary

Verified on: 2026-03-24

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

## How this affects the skill

- Hypercore route composition rules are grounded in official `app.route()` and factory guidance.
- Hypercore validation rules should not invent a custom validation surface before checking the existing repo standard.
- Hypercore error handling rules must not claim `HTTPException.getResponse()` preserves context-set headers automatically.
- Hypercore testing and RPC rules must protect chained app typing instead of treating detached registration as harmless.

