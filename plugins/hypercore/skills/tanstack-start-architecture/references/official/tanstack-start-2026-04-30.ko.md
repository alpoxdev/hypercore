# TanStack Start 공식 스냅샷

- last_verified_at: 2026-04-30
- packages_checked:
  - `@tanstack/react-start`: `1.167.52`
  - `@tanstack/start-plugin-core`: `1.169.7`
  - `@tanstack/router-plugin`: `1.167.29`
- source_priority: canonical guide pages > API/reference pages > examples > migration/comparison pages > release notes for drift context

Start-specific API behavior가 architecture rule에 영향을 줄 때 이 파일을 사용합니다. Hypercore conventions는 `rules/`에 두고 official facts는 여기에 둡니다.

## 이 Skill에서 사용하는 공식 사실

### Project structure

- Project structure는 current Start docs 기준으로 2026-05-24에 재확인했습니다. 위 package snapshot은 2026-04-30 version check로 유지합니다.
- Current Start docs는 typical project shape로 `src/routes`, `src/router.tsx`, generated `src/routeTree.gen.ts`, `src/styles.css`, optional `src/types`, `public/`, root `vite.config.ts`, `package.json`, `tsconfig.json`를 보여줍니다.
- Start Vite plugin은 `srcDirectory`와 `router.routesDirectory`를 customize할 수 있습니다. `src/routes`를 hard-code하지 말고 `tanstackStart()` config에서 실제 route root를 도출합니다.
- `routeTree.gen.ts`는 Start/Router tooling이 생성하며 일반 architecture work에서 수동 편집하지 않습니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/tutorial/fetching-external-api>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/routing>
  - <https://tanstack.com/start/latest/docs/framework/react/migrate-from-next-js>

### Router setup

- Start의 React routing guide는 `src/router.tsx`가 호출할 때마다 fresh router instance를 반환하는 `getRouter()` function을 export하기를 기대합니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/routing>

### Server functions

- Canonical server function examples는 `createServerFn({ method })`, optional `.inputValidator(...)`, optional `.middleware(...)`, then `.handler(...)`를 사용합니다.
- Current canonical server-functions guide에서는 Zod schemas를 `.inputValidator(...)`에 직접 전달할 수 있습니다.
- Server functions는 errors, redirects, not-found responses를 throw할 수 있고, 이는 route lifecycles 또는 `useServerFn()`을 쓰는 component calls를 통해 처리됩니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>

### Execution model

- Start code는 명시적으로 제한하지 않는 한 isomorphic입니다.
- Route loaders는 server-only가 아닙니다. SSR 중 server에서, client navigation 중 client에서 실행될 수 있습니다.
- Secrets, DB access, filesystem access, privileged SDK calls는 server-only/server-function boundaries 뒤에 있어야 합니다.
- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, `createIsomorphicFn`이 관련 execution-control primitives입니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/execution-model>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns>

### Import protection

- Import protection은 TanStack Start에서 기본 활성화됩니다.
- Defaults에는 client denial for `**/*.server.*` and Start server specifiers, server denial for `**/*.client.*`가 포함됩니다.
- File markers는 side-effect imports입니다: `@tanstack/react-start/server-only`, `@tanstack/react-start/client-only`.
- Custom project deny rules는 `tanstackStart({ importProtection: { client, server, behavior } })`를 통해 추가할 수 있습니다.
- `importProtection: { enabled: false }` 설정은 protection을 비활성화하므로 explicit user decision이 필요합니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

### Middleware

- Request middleware는 `createMiddleware()`를 사용할 수 있고 server-function middleware는 `createMiddleware({ type: 'function' })`를 사용합니다.
- Client context는 기본적으로 server에 전송되지 않습니다. `sendContext`는 명시적이어야 합니다.
- Dynamic/user-generated `sendContext` values는 trust 전에 server-side validation이 필요합니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

### Server routes

- Server routes는 HTTP endpoints를 위한 official Start feature이며 `createFileRoute(... )({ server: { handlers } })`를 통해 app routes와 나란히 정의할 수 있습니다.
- Webhooks, health/readiness, auth provider endpoints, files, machine-readable public endpoints처럼 raw HTTP semantics가 필요한 경우 server routes를 사용합니다.
- Hypercore는 internal app RPC에 server routes를 쓰는 것을 discouraged합니다. 이는 team policy이며 server functions를 사용합니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes>

### SSR and hydration

- Routes는 달리 configure하지 않으면 기본적으로 SSR로 render됩니다.
- Route-level `ssr`와 app-level `defaultSsr`가 selective SSR behavior를 제어합니다.
- Hydration errors는 locale/time-zone differences, `Date.now()`, random IDs, responsive-only logic, feature flags, user preferences에서 흔히 발생합니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/selective-ssr>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/hydration-errors>

## Refresh Triggers

다음 경우 이 snapshot을 refresh합니다:

- TanStack Start가 stable v1 guidance에 도달하거나 guidance가 변경됨.
- `createServerFn`, `.inputValidator()`, middleware, import protection, `getRouter()`, SSR options가 변경됨.
- 이 skill이 새로운 Start guide page에 의존하기 시작함.
- Start project structure, `srcDirectory`, `routesDirectory`, route tree generation guidance가 변경됨.
- Local package versions가 위 versions보다 materially 이동함.
