# Current Official Vite + TanStack Router Docs Snapshot — 2026-06-02

> drift-sensitive Vite + TanStack Router architecture decision을 위한 Context7 확인 official docs facts입니다.

checked_at: 2026-06-02
library_ids: `/websites/vite_dev`, `/tanstack/router`
source_priority: Context7를 통한 official Vite docs 및 official TanStack Router docs.

## Current Official Vite Facts

- Vite는 `VITE_` prefix가 붙은 env variables만 `import.meta.env`를 통해 client-side code에 노출합니다. `DB_PASSWORD` 같은 unprefixed values는 browser code에 노출되지 않습니다.
- `import.meta.env` values는 application code가 parse하지 않는 한 string입니다.
- Custom Vite env typings는 `vite-env.d.ts`에서 `ImportMetaEnv`를 augment할 수 있습니다. `vite/client` types는 asset imports, `import.meta.env`, HMR APIs shim을 제공합니다.
- Config 자체가 env values를 필요로 할 때 `vite.config.*` 안에서 `loadEnv(mode, process.cwd(), '')`를 사용할 수 있습니다. Config에서 모든 env를 load한다고 해서 모든 value가 client code에 안전하다는 뜻은 아닙니다.
- `defineConfig`는 standard Vite config helper입니다. Architecture가 의존하는 `resolve.alias`, plugins, server/build options는 explicit하게 유지합니다.
- `public/` assets는 static public assets로 served됩니다. `src/lib`, `src/services` 같은 application source organization은 project convention이며 official Vite requirement가 아닙니다.

## Current Official TanStack Router Facts

- Vite에서 TanStack Router plugin은 `@tanstack/router-plugin/vite`에서 가져오며 `@vitejs/plugin-react` / `react()`보다 앞에 배치해야 합니다.
- Official Vite examples는 `tanstackRouter({ target: 'react', autoCodeSplitting: true })` 다음에 `react()`를 둡니다.
- Plugin은 file-based routing, route tree generation, route-level code splitting을 활성화합니다.
- `routeTree.gen.ts`는 source route files에서 generated됩니다. 일반 architecture work는 generated output을 hand-edit하지 말고 source routes/config를 고칩니다.
- React router setup은 `./routeTree.gen`에서 `routeTree`를 import하고 `createRouter({ routeTree, ... })`로 router를 만든 뒤 `RouterProvider`에 전달합니다.
- File routes는 `export const Route = createFileRoute(...)({ ... })` 같은 exported route objects를 사용합니다.
- Search params는 `validateSearch`로 검증합니다. Zod v4에서는 schema를 직접 전달할 수 있고, Zod v3에서는 `zodValidator`, `fallback` 같은 `@tanstack/zod-adapter` helpers를 사용합니다.
- Route loaders는 private backend boundary가 아닙니다. Loader code와 route modules는 client-reachable로 취급하고 secrets, DB clients, filesystem access, privileged SDKs는 real backend/API boundary 뒤에 둡니다.

## Hypercore Interpretation

- `src/lib/<domain>/`, `src/services/<domain-or-provider>/`는 ownership/runtime boundaries를 위한 Hypercore/repo-local conventions이며 official Vite 또는 TanStack Router requirements가 아닙니다.
- explicit project exception이 없으면 touched shared roots에 `src/lib/foo.ts`, `src/services/foo.ts` 같은 new direct leaf files를 추가하지 않습니다.
- Vite SPA에서는 public client-side API wrappers로 Services를 선호합니다. 이 skill에서 TanStack Start server functions(`createServerFn`, `useServerFn`, Start middleware APIs`)를 도입하지 않습니다.

## Source URLs Checked

- `https://vite.dev/guide/env-and-mode`
- `https://vite.dev/config/`
- `https://vite.dev/guide/features`
- `https://vite.dev/guide/api-hmr`
- `https://tanstack.com/router/latest/docs/framework/react/installation/with-vite`
- `https://tanstack.com/router/latest/docs/framework/react/guide/file-based-routing`
- `https://tanstack.com/router/latest/docs/framework/react/guide/search-params`
- `https://tanstack.com/router/latest/docs/framework/react/guide/data-loading`
