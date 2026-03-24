# Platform Setup

> Keep adapter and runtime concerns at the edge

---

## Rules

- Runtime adapter code belongs in entry files such as `src/index.ts`, `src/server.ts`, or `src/worker.ts`
- Route modules should stay portable across adapters where possible
- Environment bindings/config should be typed explicitly
- `showRoutes()` and similar helpers stay dev-only
- `basePath()` or API version prefixes should be defined intentionally at composition boundaries

## Review Checklist

- Adapter imports are not mixed into route modules
- Runtime-specific concerns are isolated
- Config and bindings are typed
- Debug helpers are not left enabled accidentally

