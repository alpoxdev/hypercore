# Current Official Vite + TanStack Router Docs Snapshot — 2026-06-02

> Context7-checked official documentation facts for drift-sensitive Vite + TanStack Router architecture decisions.

checked_at: 2026-06-02
library_ids: `/websites/vite_dev`, `/tanstack/router`
source_priority: official Vite docs and official TanStack Router docs via Context7.

## Current Official Vite Facts

- Vite exposes only env variables prefixed with `VITE_` to client-side code through `import.meta.env`; unprefixed values such as `DB_PASSWORD` are not exposed to browser code.
- `import.meta.env` values are strings unless application code parses them.
- Custom Vite env typings can augment `ImportMetaEnv` in a `vite-env.d.ts` file; `vite/client` types provide shims for asset imports, `import.meta.env`, and HMR APIs.
- `loadEnv(mode, process.cwd(), '')` can be used inside `vite.config.*` when config itself needs env values. Loading all env values for config does not mean all values are safe for client code.
- `defineConfig` is the standard Vite config helper. `resolve.alias`, plugins, server options, and build options should remain explicit when architecture depends on them.
- `public/` assets are served as static public assets; application source organization such as `src/lib` or `src/services` is a project convention, not official Vite requirement.

## Current Official TanStack Router Facts

- For Vite, the TanStack Router plugin is configured from `@tanstack/router-plugin/vite` and should be placed before `@vitejs/plugin-react` / `react()`.
- Official Vite examples use `tanstackRouter({ target: 'react', autoCodeSplitting: true })` followed by `react()`.
- The plugin enables file-based routing, route tree generation, and route-level code splitting.
- `routeTree.gen.ts` is generated from source route files; normal architecture work should fix source routes/config rather than hand-edit generated output.
- React router setup imports `routeTree` from `./routeTree.gen`, creates a router with `createRouter({ routeTree, ... })`, and passes it to `RouterProvider`.
- File routes use exported route objects such as `export const Route = createFileRoute(...)({ ... })`.
- Search params should be validated with `validateSearch`. With Zod v4, a schema can be passed directly; with Zod v3, use the `@tanstack/zod-adapter` helpers such as `zodValidator` and `fallback`.
- Route loaders are not a private backend boundary. Treat loader code and route modules as client-reachable, and keep secrets, DB clients, filesystem access, and privileged SDKs behind a real backend/API boundary.

## Hypercore Interpretation

- `src/lib/<domain>/` and `src/services/<domain-or-provider>/` are Hypercore/repo-local conventions for ownership and runtime boundaries; they are not official Vite or TanStack Router requirements.
- Do not add new direct leaf files such as `src/lib/foo.ts` or `src/services/foo.ts` in touched shared roots unless an explicit project exception is recorded.
- Prefer Services for public client-side API wrappers in Vite SPAs. Do not introduce TanStack Start server functions (`createServerFn`, `useServerFn`, Start middleware APIs) in this skill.

## Source URLs Checked

- `https://vite.dev/guide/env-and-mode`
- `https://vite.dev/config/`
- `https://vite.dev/guide/features`
- `https://vite.dev/guide/api-hmr`
- `https://tanstack.com/router/latest/docs/framework/react/installation/with-vite`
- `https://tanstack.com/router/latest/docs/framework/react/guide/file-based-routing`
- `https://tanstack.com/router/latest/docs/framework/react/guide/search-params`
- `https://tanstack.com/router/latest/docs/framework/react/guide/data-loading`
