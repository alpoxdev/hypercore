# Platform Setup

> Keep adapter and runtime concerns at the edge

---

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
