# Platform Setup

> Keep adapter and runtime concerns at the edge

---
## Stable Runtime Baseline

As verified on 2026-08-04, Hono is 4.13.0. `@hono/node-server` 2.1.0 requires Node `>=20` and Hono `^4`; this package manifest is stricter than older Hono Node guide text. Installed package metadata and the selected runtime's current official guide win.

- Cloudflare/Deno/Bun runtimes commonly expose a Fetch-compatible app entry; Node uses the official adapter.
- Keep `app.fetch` or the reusable Hono app separate from process startup, listeners, WebSocket servers, static-file roots, and shutdown hooks.
- Treat Node raw request/response APIs, Cloudflare `executionCtx`/bindings, and provider-specific wait-until behavior as adapter capabilities.
- Validate environment configuration at startup where possible. Never put secrets in client-visible config, logs, or generated OpenAPI examples.
- Test the runtime adapter when code uses streaming, WebSockets, static files, raw APIs, execution context, or provider bindings; `app.request()` alone is insufficient.
- Do not change adapters, deployment manifests, compatibility dates, or runtime versions without explicit scope and provider-specific verification.

## Rules

- Runtime adapter code belongs in entry files such as `src/index.ts`, `src/server.ts`, or `src/worker.ts`
- Route modules should stay portable across adapters where possible
- Environment bindings/config should be typed explicitly
- Database bindings and connection strings should be read through the platform/config boundary, not directly from feature handlers
- Use runtime-appropriate database clients: Hono `Bindings` / `c.env` for Workers bindings such as D1, and validated config for Node/Bun server runtimes
- `showRoutes()` and similar helpers stay dev-only
- `basePath()` or API version prefixes should be defined intentionally at composition boundaries

## Review Checklist

- Adapter imports are not mixed into route modules
- Runtime-specific concerns are isolated
- Config and bindings are typed
- Database client setup matches the runtime and stays outside route modules
- Debug helpers are not left enabled accidentally

## Sources

> No external sources were used in this file. Official Hono behavior is delegated to `references/official/hono-docs.md` (last verified 2026-08-04). Repository-local links checked 2026-09-21.
