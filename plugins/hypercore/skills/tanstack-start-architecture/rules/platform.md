# Platform Setup

> Router, environment, alias, and operations-adjacent setup rules

---

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| `src/router.tsx` exports fresh-instance `getRouter()` | Official | Block missing setup |
| Server/client env boundaries | Safety policy | Block secret leaks |
| Runtime env validation for non-trivial apps | Hypercore convention + Safety policy | Warn or add `src/config/env.ts` scaffold |
| Vite-version-aware path aliases | Hypercore convention | Fix when touched |

---

## Router Setup

- `src/router.tsx` must export `getRouter()`
- `getRouter()` must create and return a fresh router instance each call
- Router-wide behavior such as `scrollRestoration`, preload defaults, and cache settings belong here

---

## Environment Rules

- Do not create `src/env/`, `src/env.ts`, or `src/env.d.ts` for new TanStack Start env scaffolds.
- Keep env code under `src/config/`; the canonical validation module is `src/config/env.ts`.
- Use `@t3-oss/env-core` with `zod` for TanStack Start/Vite projects; scaffold with `createEnv`.
- Configure client variables with `clientPrefix: "VITE_"` unless the project has explicitly changed Vite `envPrefix`.
- `VITE_*` variables are client-exposed and must not contain secrets, tokens, private API keys, passwords, or database URLs.
- Server-only env vars stay in `process.env`, are accessed behind server boundaries, and are listed in `server`.
- Client-safe env vars come from `import.meta.env`, are listed in `client`, and use the public prefix.
- Prefer `runtimeEnvStrict` for explicit build-time coverage; otherwise use `runtimeEnv` only when the framework/runtime reliably provides the whole env object.
- Include `isServer: typeof window === "undefined"` when a shared config file can be imported from both server and client code.
- Set `emptyStringAsUndefined: true` for new validation modules unless the project has a documented reason not to.
- If sensitive server variable names must not ship to client bundles, split the schema under `src/config/` (for example `env.server.ts` and `env.client.ts`), not under `src/env/`.

Canonical starter shape:

```ts
// src/config/env.ts
import { createEnv } from "@t3-oss/env-core"
import * as z from "zod"

export const env = createEnv({
  server: {
    DATABASE_URL: z.url(),
  },
  clientPrefix: "VITE_",
  client: {
    VITE_PUBLIC_APP_URL: z.url(),
  },
  runtimeEnvStrict: {
    DATABASE_URL: process.env.DATABASE_URL,
    VITE_PUBLIC_APP_URL: import.meta.env.VITE_PUBLIC_APP_URL,
  },
  isServer: typeof window === "undefined",
  emptyStringAsUndefined: true,
})
```

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
