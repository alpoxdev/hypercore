# TanStack Start 공식 스냅샷

- last_verified_at: 2026-09-22
- next_re_verification: 2027-03-22 (또는 아래 Refresh Trigger가 먼저 발동하면 그때)
- packages_checked:
  - `@tanstack/react-start`: `1.168.57`
  - `@tanstack/start-client-core`: `1.170.32`
  - `@tanstack/start-server-core`: `1.169.37`
  - `@tanstack/start-plugin-core`: `1.171.47`
  - `@tanstack/router-plugin`: `1.168.40`
  - `@tanstack/router-cli`: `1.167.38`
  - `@tanstack/zod-adapter`: `1.167.0`
  - `@tanstack/cli`: `0.71.0`
- source_priority: canonical guide pages > API/reference pages > examples > migration/comparison pages > release notes for drift context
- supersedes: 은퇴한 2026-04-30 Start 스냅샷

Start-specific API behavior가 architecture rule에 영향을 줄 때 이 파일을 사용합니다. 아래 모든 사실에는 `Official` 라벨이 붙습니다. 즉 TanStack 자체 guide page, source tree, package metadata에서 온 내용입니다. Hypercore conventions는 `rules/`에 두고 official facts는 여기에 둡니다.

## Contents

- [Corrected from the 2026-04-30 snapshot](#corrected-from-the-2026-04-30-snapshot)
- [Release status](#release-status)
- [Project structure](#project-structure)
- [Router setup](#router-setup)
- [Server functions](#server-functions)
- [Execution model](#execution-model)
- [Import protection](#import-protection)
- [Middleware](#middleware)
- [Server routes](#server-routes)
- [SSR, hydration, and rendering](#ssr-hydration-and-rendering)
- [Platform and tooling](#platform-and-tooling)
- [Refresh Triggers](#refresh-triggers)
- [Sources](#sources)

## Corrected from the 2026-04-30 snapshot

- **`.validator(...)`가 정본입니다. `.inputValidator(...)`는 런타임에서 여전히 동작하는 폐기 별칭입니다.** 은퇴한 2026-04-30 스냅샷은 이 별칭을 정본으로 가르쳤고, 그것이 이 파일에서 바로잡는 유일한 동작 역전 항목입니다. 별칭은 위반이 아니고 기존 코드도 계속 동작합니다. 이미 손대는 코드에서만 마이그레이션합니다.
- 은퇴한 스냅샷의 pinned version도 함께 이동했습니다. 위 version 목록은 2026-09-22에 npm `latest` dist-tag에서 다시 측정했습니다.

## Release status

- Start overview page 원문입니다. "TanStack Start is currently in the **Release Candidate** stage! This means it is considered feature-complete and its API is considered stable." 같은 안내는 이어서 "**This does not mean it is bug-free or without issues**, which is why we invite you to try it out and provide feedback"라고 밝힙니다.
- v1 GA 발표는 없습니다. Start를 pre-1.0으로 다루고, experimental surface(import protection, deferred hydration, static server functions, RSC)는 불안정한 것으로 봅니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/overview.md>

## Project structure

- Start plugin은 `srcDirectory` 기본값을 `'src'`로 두고, routes directory는 `tanstackStart({ router: { routesDirectory } })`로 덮어쓰지 않는 한 `<srcDirectory>/routes`로 해석됩니다. 따라서 `src/routes`를 hard-code하지 말고 config에서 실제 route root를 도출합니다.
- 문서가 보여주는 typical shape는 `src/routes`, `src/router.tsx`, generated `src/routeTree.gen.ts`, `src/styles.css`, optional `src/types`, `public/`, root bundler config(`vite.config.ts` 또는 `rsbuild.config.ts`), `package.json`, `tsconfig.json`입니다.
- `routeTree.gen.ts`는 Router tooling이 생성합니다. Router FAQ는 이 파일을 커밋하라고 말합니다. "it is essentially part of your application's runtime, not a build artifact." file-based-routing API page는 생성된 path를 linter와 formatter에서 무시하도록 권고합니다. 손으로 고치지 않습니다(Hypercore convention).
- File organization: server-functions guide는 `*.functions.ts`(server function wrapper, 어디서든 import해도 안전) / `*.server.ts`(server-only helper) / 접미사 없는 `*.ts`(client-safe) 분리를 "one approach"로 제시할 뿐 의무로 두지 않습니다.
- `.functions.ts`는 import protection이 **강제하지 않습니다.** import-protection guide의 기본 file pattern은 `**/*.server.*`와 `**/*.client.*`뿐이고, `.functions.ts`는 server-functions guide의 file-organization 절에만 나옵니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>
  - <https://tanstack.com/router/latest/docs/faq>
  - <https://tanstack.com/router/latest/docs/api/file-based-routing>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-plugin-core/src/schema.ts>

## Router setup

- `src/router.tsx`는 호출할 때마다 새 router instance를 반환하는 `getRouter` function을 export해야 합니다. 공식 예시는 function declaration을 씁니다. `export function getRouter() { ... }`
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/routing.md>

## Server functions

- `createServerFn()`이 server function을 정의합니다. `method` 기본값은 `'GET'`이고, `Method`는 정확히 `'GET' | 'POST'`입니다. 다른 verb는 없습니다(`packages/start-client-core/src/createServerFn.ts:449`, `:84-86`).
- `.validator(...)`가 정본입니다. `.inputValidator(...)`는 폐기 별칭이며 런타임에서 여전히 해석됩니다. source는 `/** @deprecated Use \`validator\` instead. */` 마커를 달고 `const validator = options.validator ?? options.inputValidator`를 읽습니다.
- Zod schema는 `.validator(...)`에 직접 전달합니다. validator input type은 serializable해야 하고, `FormData`도 `POST` server function에서 허용됩니다.
- builder가 담는 validator는 **하나**입니다. `.validator(...)`는 그 하나를 설정하고(나중 호출이 앞 호출을 대체) `.middleware([...])`는 반복 호출이 가능하며 이전 middleware와 merge됩니다.
- `strict` 옵션이 있고 기본값은 `strict: true`입니다. TypeScript 수준 serialization 검사를 관장하며, `createServerFn({ strict: false })`와 세분화 형태 `strict: { input: false }` / `strict: { output: false }`로 opt out합니다. 문서는 `strict: false`가 type 검사만 완화한다고 경고합니다. 값은 여전히 runtime serialization layer가 제대로 처리해야 합니다.
- Server function은 same-origin app RPC endpoint입니다. loaders, components, hooks, 다른 server function, event handler에서 호출할 수 있고, hook ergonomics가 필요하면 `useServerFn()`을 씁니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createServerFn.ts>

## Execution model

- Start code는 기본적으로 isomorphic입니다. 명시적으로 제한하지 않으면 두 환경에서 실행되고 양쪽 bundle에 포함됩니다. route loader도 isomorphic이며 server-only가 아닙니다. SSR 중에는 server에서, client navigation 중에는 client에서 실행됩니다.
- Execution-control primitive는 `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, `createIsomorphicFn`입니다.
- `createIsomorphicFn()`은 `.server(...)`와 `.client(...)`로 환경별 구현을 하나의 function에 합성합니다. 한쪽이 없으면 error가 아니라 `undefined`를 반환하는 no-op입니다. Environment function은 bundle별로 tree-shaken됩니다.
- `createServerOnlyFn(...)`과 `createClientOnlyFn(...)`은 환경에 묶인 실행을 강제하고, 잘못된 환경에서 호출하면 설명이 담긴 runtime error를 던집니다.
- Secrets, DB access, filesystem access, privileged SDK calls는 server-only 또는 server-function boundary 뒤에 있어야 합니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/execution-model.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/environment-functions.md>

## Import protection

- **Status: Experimental.** 페이지는 `> **Experimental:** Import protection is experimental and subject to change.`로 시작합니다. option surface를 불안정한 것으로 다룹니다.
- 기본 활성화입니다. 문서화된 기본값: `enabled: true`; `behavior: { dev: 'mock', build: 'error' }`; `log: 'once'`(반복 위반을 deduplicate); `include` = Start의 `srcDirectory`; `exclude: []`; `maxTraceDepth: 20`.
- 기본 deny rule: `client.files` = `['**/*.server.*']`, `server.files` = `['**/*.client.*']`, `client.specifiers` = framework server specifiers, `server.specifiers` = `[]`, 양쪽 `excludeFiles` = `['**/node_modules/**']`.
- **replace와 additive를 헷갈리는 것이 함정입니다.** option table 기준으로 `client.specifiers`는 **기본값에 additive**이고, `client.files`, `client.excludeFiles`, `server.files`, `server.specifiers`, `server.excludeFiles`는 기본값을 **replace**합니다. `excludeFiles`는 `['**/node_modules/**']`를 **완전히 replace**하므로, `node_modules`를 계속 건너뛰면서 경로를 더 제외하려면 둘 다 넘깁니다. `client.files`를 `'**/*.server.*'` 없이 설정하면 기본 deny rule이 조용히 사라집니다.
- Type-only import와 re-export는 런타임에 지워지므로 무시됩니다. mixed import는 runtime 값을 하나라도 담으면 여전히 검사 대상입니다.
- 명시적 boundary를 위한 side-effect marker import는 그대로 쓸 수 있습니다. `@tanstack/react-start/server-only`와 `@tanstack/react-start/client-only`입니다.
- `mockAccess`(`'error' | 'warn' | 'off'`)는 `packages/start-plugin-core/src/schema.ts:42`에 있지만 **import-protection guide의 option table에는 없습니다.** 실제로 존재하되 문서화되지 않은 schema option이므로, 인용할 때는 그렇게 라벨하고 문서화된 옵션처럼 제시하지 않습니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-plugin-core/src/schema.ts>

## Middleware

- Middleware type은 둘입니다. **Request middleware**는 모든 server request를 customize하고, **server function middleware**는 그 부분집합으로서 input validation과 client-side logic처럼 server function 전용 기능을 더합니다. Request middleware는 `createMiddleware()`(또는 `createMiddleware({ type: 'request' })`)를, server function middleware는 `createMiddleware({ type: 'function' })`를 씁니다.
- Middleware input validation도 `.validator(...)`를 씁니다. 같은 rename이 적용되며, `packages/start-client-core/src/createMiddleware.ts:182-183`이 `inputValidator`에 같은 `@deprecated` 마커를 답니다.
- `sendContext`는 명시적이고 hop마다 단방향입니다. Client context는 기본적으로 server에 전송되지 않고 `next({ sendContext: {...} })`로 넘겨야 합니다. Client가 보낼 수 있는 값은 client가 거짓으로 만들 수 있습니다.
- **"Shape validation is not authorization."** 파싱된 UUID나 number는 잘 형성된 identifier일 뿐 authorized identifier가 아닙니다. 그 값이 어떤 row를 읽거나 쓸지 고르는 경우(query key, filter, path parameter)에는 session principal의 접근 권한을 따로 검증해야 합니다. 그렇지 않으면 로그인한 사용자가 자기 요청에서 값을 바꿔 다른 tenant의 data에 닿습니다.
- 문서가 요구하는 패턴입니다. "Always derive the session itself from a server-trusted source (a cookie + DB lookup in `authMiddleware`), never from `sendContext`."
- **CSRF.** `createCsrfMiddleware()`가 server function을 cross-site request에서 보호합니다. option은 `filter`, `origin`, `allowRequestsWithoutOriginCheck`입니다. 기본적으로 `Origin`과 `Referer`를 들어온 request URL origin과 비교하고, `Sec-Fetch-Site`, `Origin`, `Referer`를 모두 싣지 않은 request는 거부합니다.
- **CSRF 함정:** app이 `src/start.ts`를 정의하지 않으면 Start가 server function용 CSRF middleware를 자동으로 설치합니다. `src/start.ts`를 정의하는 순간 그 자동 설치가 조용히 사라지므로, 그 파일이 `requestMiddleware: [createCsrfMiddleware()]`를 직접 추가해야 합니다. `src/start.ts`가 있는데 이 middleware가 없으면 Start가 server function request에 대해 development warning을 기록합니다. CSRF를 다른 방식으로 처리하는 app은 `disableCsrfMiddlewareWarning: true`로 그 warning을 끕니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/middleware.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createCsrfMiddleware.ts>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createMiddleware.ts>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-plugin-core/src/schema.ts>

## Server routes

- Server route는 route file의 `createFileRoute(...)(...)` 호출에 `server`를 더해 선언하고, Router의 file-based routing 관례를 따릅니다.
- `handlers`는 HTTP method를 handler function에 매핑한 object이거나, middleware 구성을 직접 해야 하는 handler를 위해 `createHandlers`를 받는 function입니다. 선택적인 route-level `middleware` 배열은 모든 handler에 적용되고 handler별 middleware보다 먼저 실행됩니다.
- Pathless layout route와 break-out route로 server route middleware를 묶을 수 있습니다. Pathless layout은 route 묶음에 middleware를 더하고, break-out route는 parent middleware에서 빠져나옵니다.
- GET과 POST를 넘어 `PUT`, `PATCH`, `DELETE`도 server route에서 지원됩니다.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes.md>

## SSR, hydration, and rendering

- 초기 request에 match되는 route는 기본적으로 server에서 render됩니다. route별 `ssr` 기본값은 `true`이고, `createStart({ defaultSsr: false })`가 그 기본값을 바꿉니다.
- Hydration mismatch는 `Intl` locale/time-zone 차이, `Date.now()`, random ID, responsive-only logic, feature flag, user preference에서 옵니다. 문서가 제시하는 해법은 cookie(우선)나 `Accept-Language` header로 server에서 한 번 계산해 그것을 initial state로 hydrate하는 것입니다.
- **Deferred hydration은 experimental입니다.** `<Hydrate>`와 `@tanstack/react-start/hydration`에서 import하는 strategy를 씁니다.
- ISR을 쓸 수 있습니다. Static prerendering에 표준 HTTP cache header와 revalidation을 더한 방식이며, 의도적으로 CDN에 종속되지 않습니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/selective-ssr.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/hydration-errors.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/deferred-hydration.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/isr.md>

## Platform and tooling

- 공식 bundler는 둘입니다. Vite(기본)와 **Rsbuild**이며, Rsbuild는 `rsbuild.config.ts`에서 `@tanstack/react-start/plugin/rsbuild`로 import합니다. Rsbuild production build는 client asset을 `dist/client`에, server bundle을 `dist/server/index.js`에 냅니다.
- `autoCodeSplitting`은 기본값 `false`인 bundler-plugin option입니다(v2에서는 `true`가 기본이 될 예정). Start plugin의 config schema는 이를 제외하므로(`configSchema.omit({ autoCodeSplitting: true, target: true })`) `tanstackStart()`를 통해 **전달할 수 없습니다.**
- Client에 노출되는 environment variable은 build tool의 public prefix를 씁니다. Vite는 `VITE_`, Rsbuild는 `PUBLIC_`입니다.
- `src/server.ts`는 선택적인 server entry point이고 fetch 형태의 `ServerEntry`를 씁니다. 없으면 Start가 기본값을 공급합니다.
- Static server function은 **experimental입니다**(`@tanstack/start-static-server-functions`의 `staticFunctionMiddleware`).
- Scaffolding은 `npx @tanstack/cli@latest create`(`@tanstack/cli` `0.71.0`) 또는 TanStack Builder입니다. Legacy alias `create-tsrouter-app`, `create-start-app`, `create-tanstack-app`, `create-tanstack`, `@tanstack/create-start`는 deprecation warning을 출력합니다.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/hosting.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-entry-point.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/static-server-functions.md>
  - <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-plugin-core/src/schema.ts>

## Refresh Triggers

다음 경우 이 snapshot을 refresh합니다.

- Sources 아래에 나열한 Start guide page가 본문, option table, 문서화된 기본값을 바꿀 때.
- 이 skill이 의존하는 Start guide page가 이름을 바꾸거나 사라지거나 새 page로 대체될 때.
- security advisory가 pinned package에 영향을 줄 때. 저장소 advisory(`gh api repos/TanStack/router/security-advisories`)와 npm advisory database를 확인합니다. 선례: advisory `GHSA-g7cv-rxg3-hmpx`(2026-05-11)는 42개 `@tanstack/*` package의 악성 version을 공표했습니다. 따라서 advisory 확인은 모든 재검증 pass에 들어갑니다.
- Start가 pre-1.0 단계를 벗어나거나 v1 GA를 발표할 때.

**이 trigger를 version number만으로 걸지 않습니다.** Router와 Start는 `1.x`에 머물면서 PATCH release에서 breaking change를 흡수합니다. patch인 `@tanstack/react-router@1.170.19`가 export 약 20개를 제거한 것이 그 예입니다. 그래서 "local package version이 pinned 목록을 지나갔다"는 trigger는 과하게도, 모자라게도 발동합니다. 위 version 목록은 2026-09-22에 무엇을 측정했는지 남기는 provenance 기록이지 trigger가 아닙니다.

## Sources

> 출처 확인 2026-09-22. 이 snapshot이 검증 날짜로 기록한 날짜이며, 파일 이름의 날짜와 그 기록은 구조상 일치합니다. 아래 출처는 모두 2026-09-22에 이 snapshot을 위해 가져왔습니다. `guide/` path segment는 필수이고, 같은 page에서 이 segment를 빼면 404가 납니다. 인용한 line number는 2026-09-22에 가져온 사본에서의 위치이므로 page가 바뀌면 함께 이동합니다. 안정된 기준은 인용문 자체입니다. 위 목록 밖의 출처는 주장하지 않습니다.

- <https://tanstack.com/start/latest/docs/framework/react/overview.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/routing.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/environment-functions.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/middleware.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/execution-model.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/selective-ssr.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/hydration-errors.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/deferred-hydration.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/isr.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/hosting.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/server-entry-point.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/static-server-functions.md>
- <https://tanstack.com/router/latest/docs/faq>
- <https://tanstack.com/router/latest/docs/api/file-based-routing>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createServerFn.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createMiddleware.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createStart.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createCsrfMiddleware.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-plugin-core/src/schema.ts>
- <https://registry.npmjs.org/@tanstack/react-start/latest>
- <https://github.com/TanStack/router/security/advisories/GHSA-g7cv-rxg3-hmpx>
