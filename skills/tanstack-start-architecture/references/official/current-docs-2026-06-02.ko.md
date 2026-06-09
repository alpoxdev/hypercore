# TanStack Start Current Docs Snapshot

- checked_at: 2026-06-09
- source: Context7 `/websites/tanstack_start_framework_react`, TanStack 공식 docs pages와 직접 TanStack 공식 페이지 확인 기반
- use_when: Start/Router API behavior, Start Vite plugin config, import protection, execution boundaries, server-function API shape가 architecture decision에 영향을 줄 때
- authority: API 사실은 TanStack 공식 문서가 기준이며, Hypercore convention은 `rules/`에 남긴다.

## 확인한 공식 사실

### Project setup and router

- 공식 build-from-scratch guide에서 `vite.config.ts`는 `@tanstack/react-start/plugin/vite`의 `tanstackStart()`를 사용하고, React Vite plugin은 Start plugin 뒤에 둔다.
- 현재 Getting Started guidance는 TanStack Builder 또는 CLI 경로인 `npx @tanstack/cli@latest create`를 권장한다. 예제에 남은 이전 scaffold command를 현재 primary setup path로 취급하지 않는다.
- `src/router.tsx`는 `getRouter()`를 정의하고 generated `routeTree`를 `./routeTree.gen`에서 import한다.
- `src/routes/__root.tsx`는 root application route이며, `routeTree.gen.ts`는 `npm run dev` 또는 `npm run start` 등 Start 실행 시 자동 생성된다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/getting-started>
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/routing>

### Source and route directory config

- Start project는 흔히 `src/routes`를 사용하지만 architecture review에서는 route root를 가정하기 전에 `tanstackStart()` config를 확인해야 한다.
- 이 스킬의 기존 references는 `srcDirectory`와 `router.routesDirectory`를 configurable Start plugin options로 추적한다. Target project에서 package types 또는 docs가 다르면 local package types와 dated note를 우선한다.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>

### Server functions and execution boundaries

- `createServerFn()`은 server functions를 정의한다. GET이 default이며, `createServerFn({ method: 'POST' })`처럼 다른 HTTP method를 지정할 수 있다.
- Server functions는 input validation에 `.inputValidator(...)`를 사용하고 execution에 `.handler(...)`를 사용한다. Current server-function guides는 필요하면 handler 전에 middleware를 둔다.
- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, `createIsomorphicFn`은 공식 execution-control primitives다.
- Client hooks/components는 server functions를 호출할 수 있으며, hook ergonomics가 필요하면 React wrapper인 `useServerFn`을 사용한다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/authentication.md>

### Middleware

- TanStack Start에는 두 middleware type이 있다. Request middleware는 `createMiddleware()`를 사용한다. `createMiddleware({ type: 'request' })`도 가능하지만 request type이 default다.
- Server function middleware는 `createMiddleware({ type: 'function' })`를 사용하며 `.client(...)`와 `.server(...)` phase를 정의할 수 있다.
- Server function middleware input transformation/validation도 `.inputValidator(...)`를 사용한다. Middleware `.inputValidator(...)`와 server-function `.inputValidator(...)`는 다른 chain object와 data context에 속하므로 혼동하지 않는다.
- `sendContext`는 explicit이다. Client middleware에서 server middleware로 보낸 값은 client-provided data로 보고 server-side validation 후 신뢰한다.
- Global request middleware는 `src/start.ts`에서 `createStart(() => ({ requestMiddleware: [...] }))`로 설정한다.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

### Import protection

- Start source files에는 import protection이 기본 활성화되어 있다.
- Development default는 mock/warning behavior이며, production build default는 violation에서 error다.
- 기본 client-side denial은 `*.server.*`와 Start server specifiers를 다루고, 기본 server-side denial은 `*.client.*`를 다룬다. `node_modules`는 check에서 제외된다.
- Type-only imports and re-exports are ignored by import protection because runtime bundle에서 제거된다. Runtime value를 포함한 mixed import는 여전히 검사 대상이다.
- Project-specific import protection은 `tanstackStart({ importProtection: { behavior, client, server } })`로 설정할 수 있다.
- `behavior`는 `behavior: 'error'` 같은 mode 또는 `{ dev: 'mock', build: 'error' }` 같은 per-mode object일 수 있다.
- Current options에는 `enabled`, `behavior`, `log`, `include`, `exclude`, `ignoreImporters`, `maxTraceDepth`, environment-specific `client`/`server` `files`와 `specifiers`, `excludeFiles`, `onViolation`이 포함된다.
- `excludeFiles: []`는 `node_modules`처럼 default가 제외하는 위치의 resolved files를 다시 검사하게 할 수 있지만, false positive를 피하려면 의도적으로만 사용한다.
- 명시적 boundary용 side-effect marker imports는 `@tanstack/react-start/server-only`, `@tanstack/react-start/client-only`다.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

### Server routes

- Server routes는 route file의 `createFileRoute(...)(...)`에 `server`를 추가해 선언한다.
- 현재 형태는 simple method handlers에는 `server.handlers` object를, middleware composition이 필요한 handlers에는 `createHandlers` function을 사용한다.
- `server.middleware`는 모든 handlers에 route-level middleware를 적용할 수 있다.
- Server routes는 Router file-route convention을 따른다. 같은 route path에서 duplicate HTTP methods는 invalid이며, wildcard/splat routes는 trailing `$` file-route convention을 사용한다.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes>

## Drift handling

- 이 파일은 날짜가 있는 official-doc snapshot이며 영구 rulebook이 아니다.
- Local installed package types가 다르면 typecheck를 실행하고 project-specific exception을 기록한다.
- `src/lib`, `src/services`, `src/db`, `src/server`, `src/config` grouping은 official TanStack requirement가 아니라 Hypercore convention으로 유지한다.
