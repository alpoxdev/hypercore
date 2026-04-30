# Platform Setup

> Router, environment, alias, and operations-adjacent setup rules

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| `src/router.tsx` exports fresh-instance `getRouter()` | Official | Block missing setup |
| Server/client env boundaries | Safety policy | Block secret leaks |
| Runtime env validation for non-trivial apps | Hypercore convention + Safety policy | Warn or add scaffold |
| Vite-version-aware path aliases | Hypercore convention | Fix when touched |

---

## Router Setup

- `src/router.tsx` must export `getRouter()`
- `getRouter()` must create and return a fresh router instance each call
- Router-wide behavior such as `scrollRestoration`, preload defaults, and cache settings belong here

---

## Environment Rules

- Client-safe env vars use `import.meta.env` with public prefix conventions
- Server-only env vars stay in `process.env` and behind server boundaries
- Add `src/env.d.ts` when the project needs typed env access
- Add runtime env validation for required secrets and URLs

---

## Path Alias Rules

- Path aliases must be configured intentionally, not assumed
- Vite 8+: prefer `resolve.tsconfigPaths: true`
- Vite 7 and earlier: use `vite-tsconfig-paths`
- Keep one canonical alias convention in the repo

---

## Operations-Adjacent Patterns

- Health/readiness endpoints are allowed as server routes
- Sitemap/robots generation may use prerender config or server routes
- Machine-readable endpoints for integrations/LLMO are allowed when explicitly required
- Observability hooks, metrics, and Sentry-style integrations belong in operations/platform docs, not page logic

---

## Review Checklist

- `getRouter()` exists and returns a new instance
- Env usage is typed and boundary-safe
- Alias setup matches the Vite version in use
- Operational endpoints are not mixed with internal app RPC
