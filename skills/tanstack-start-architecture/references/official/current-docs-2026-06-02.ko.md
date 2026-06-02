# TanStack Start Current Docs Snapshot

- checked_at: 2026-06-02
- source: Context7 `/websites/tanstack_start_framework_react`, TanStack 공식 docs pages 기반
- use_when: Start/Router API behavior, Start Vite plugin config, import protection, execution boundaries, server-function API shape가 architecture decision에 영향을 줄 때
- authority: API 사실은 TanStack 공식 문서가 기준이며, Hypercore convention은 `rules/`에 남긴다.

## 확인한 공식 사실

### Project setup and router

- 공식 build-from-scratch guide에서 `vite.config.ts`는 `@tanstack/react-start/plugin/vite`의 `tanstackStart()`를 사용하고, React Vite plugin은 Start plugin 뒤에 둔다.
- `src/router.tsx`는 `getRouter()`를 정의하고 generated `routeTree`를 `./routeTree.gen`에서 import한다.
- `src/routes/__root.tsx`는 root application route이며, `routeTree.gen.ts`는 첫 실행 때 자동 생성된다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/routing>

### Source and route directory config

- Start project는 흔히 `src/routes`를 사용하지만 architecture review에서는 route root를 가정하기 전에 `tanstackStart()` config를 확인해야 한다.
- 이 스킬의 기존 references는 `srcDirectory`와 `router.routesDirectory`를 configurable Start plugin options로 추적한다. Target project에서 package types 또는 docs가 다르면 local package types와 dated note를 우선한다.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>

### Server functions and execution boundaries

- `createServerFn()`은 server functions를 정의한다. GET이 default이며, `createServerFn({ method: 'POST' })`처럼 다른 HTTP method를 지정할 수 있다.
- Server functions는 `.handler(...)`를 사용한다. Current guides는 input validation에 `.inputValidator(...)`를 보여주며, 필요하면 handler 전에 middleware를 둔다.
- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, `createIsomorphicFn`은 공식 execution-control primitives다.
- Client hooks/components는 server functions를 호출할 수 있으며, hook ergonomics가 필요하면 React wrapper인 `useServerFn`을 사용한다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/authentication.md>

### Import protection

- Start source files에는 import protection이 기본 활성화되어 있다.
- Development default는 mock/warning behavior이며, production build default는 violation에서 error다.
- 기본 client-side denial은 `*.server.*`와 Start server specifiers를 다루고, 기본 server-side denial은 `*.client.*`를 다룬다. `node_modules`는 check에서 제외된다.
- Project-specific import protection은 `tanstackStart({ importProtection: { behavior, client, server } })`로 설정할 수 있다.
- 명시적 boundary용 side-effect marker imports는 `@tanstack/react-start/server-only`, `@tanstack/react-start/client-only`다.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>

## Drift handling

- 이 파일은 날짜가 있는 official-doc snapshot이며 영구 rulebook이 아니다.
- Local installed package types가 다르면 typecheck를 실행하고 project-specific exception을 기록한다.
- `src/lib`, `src/services`, `src/db`, `src/server`, `src/config` grouping은 official TanStack requirement가 아니라 Hypercore convention으로 유지한다.
