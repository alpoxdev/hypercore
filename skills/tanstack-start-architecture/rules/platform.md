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
| Installed `@tanstack/*` versions checked against the official supply-chain advisory | Safety policy | Verify before install or upgrade |

---

## Dependency Safety

- **Safety policy.** Check the installed `@tanstack/*` versions against the official advisory's affected/patched ranges before installing or upgrading. Precedent: advisory [`GHSA-g7cv-rxg3-hmpx`](https://github.com/TanStack/router/security/advisories/GHSA-g7cv-rxg3-hmpx) (published 2026-05-11, critical) — malicious versions of `@tanstack/*` packages were published and harvested cloud credentials, GitHub tokens, and SSH keys at install time. Of the packages these snapshots pin, only `@tanstack/cli` was unaffected.
- **Official.** Affected → patched ranges recorded by that advisory. Treat this table as provenance and re-read the advisory for the authoritative range check.

| Package | Malicious versions | Patched |
|---|---|---|
| `@tanstack/react-router` | 1.169.5, 1.169.8 | 1.169.9 |
| `@tanstack/react-start` | 1.167.68, 1.167.71 | 1.167.72 |
| `@tanstack/router-cli` | 1.166.46, 1.166.49 | 1.166.50 |
| `@tanstack/router-plugin` | 1.167.38, 1.167.41 | 1.167.42 |
| `@tanstack/start-client-core` | 1.168.5, 1.168.8 | 1.168.9 |
| `@tanstack/start-plugin-core` | 1.169.23, 1.169.26 | 1.169.27 |
| `@tanstack/start-server-core` | 1.167.33, 1.167.36 | 1.167.37 |
| `@tanstack/zod-adapter` | 1.166.12, 1.166.15 | 1.166.16 |

- Do not record any specific version here as "known safe". The advisory's postmortem states every currently-available published version of every TanStack package is safe to install; the authoritative range check lives in the advisory and the npm advisory database, not in this file.
- If an affected version was installed on a host, treat that host as potentially compromised and rotate the credentials reachable from it (AWS, GCP, Kubernetes, Vault, GitHub, npm, SSH) — the payload ran as an install lifecycle script.

## Release Status

- **Official.** Start is not v1 GA; it is in the **Release Candidate** stage: "TanStack Start is currently in the **Release Candidate** stage! This means it is considered feature-complete and its API is considered stable." The same note adds "**This does not mean it is bug-free or without issues**", so do not treat Start APIs as final — re-check the pinned snapshot rather than assuming an API is settled.

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

## Sources

> Safety-policy facts come from the official advisory <https://github.com/TanStack/router/security/advisories/GHSA-g7cv-rxg3-hmpx> and its postmortem <https://tanstack.com/blog/npm-supply-chain-compromise-postmortem>; the Release Candidate wording comes from <https://tanstack.com/start/latest/docs/framework/react/overview.md>. Official facts verified 2026-09-22. Everything else is delegated to this package's own snapshots: `references/official/tanstack-start-2026-09-22.md`, `references/official/tanstack-router-2026-09-22.md`, and `references/official/current-docs-2026-09-22.md`. Repository-local links checked 2026-09-22.
