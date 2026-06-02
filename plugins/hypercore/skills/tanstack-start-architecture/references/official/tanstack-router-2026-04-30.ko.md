# TanStack Router 공식 스냅샷

- last_verified_at: 2026-04-30
- packages_checked:
  - `@tanstack/react-router`: `1.168.26`
  - Context7 indexed version observed: repository docs는 `v1_114_3`, live latest docs와 cross-check함.
- source_priority: latest docs pages > API pages > examples

Route, search, loader, context, SSR rules에 Router behavior가 영향을 줄 때 이 파일을 사용합니다.

## 이 Skill에서 사용하는 공식 사실

### File routes and `Route` export

- File-based routes는 `createFileRoute(path)(options)`로 configure합니다.
- Generated file route instance는 `tsr generate`와 `tsr watch`가 올바르게 동작하도록 `Route` identifier로 export해야 합니다.
- Sources:
  - <https://tanstack.com/router/latest/docs/api/router/createFileRouteFunction>
  - <https://tanstack.com/router/latest/docs/routing/routing-concepts>

### Flat and directory routes

- Router는 directory routes, flat routes, mixed flat/directory structures를 공식 지원합니다.
- Hypercore가 app pages에 route directories를 선호할 수는 있지만 이는 team convention이지 official Router requirement가 아닙니다.
- Source: <https://tanstack.com/router/latest/docs/routing/file-based-routing>

### Route lifecycle and loading

- Loading lifecycle은 matching/search validation, serial `beforeLoad`, 그리고 `loader`와 component preload를 포함하는 parallel route loading 순서로 진행됩니다.
- `beforeLoad`는 serial ordering이 필요한 context, auth, redirects에 적합합니다.
- `loader`는 data loading에 적합하며 Router caching/preloading semantics에 참여합니다.
- Slow loader UI는 `pendingComponent`를 사용할 수 있고 default pending threshold는 configure할 수 있습니다.
- Source: <https://tanstack.com/router/latest/docs/guide/data-loading>

### Search parameter validation

- TanStack Router는 schema-based search validation을 지원합니다.
- Zod v4에서는 Zod schema를 `validateSearch`에 직접 사용할 수 있습니다.
- Zod v3에서는 `@tanstack/zod-adapter` (`zodValidator`, `fallback`)를 사용합니다.
- Project가 두 version 모두에 `zodValidator`를 의도적으로 표준화한다면 hypercore convention으로 label합니다.
- Sources:
  - <https://tanstack.com/router/latest/docs/how-to/validate-search-params>
  - <https://tanstack.com/router/latest/docs/how-to/setup-basic-search-params>

### Router context

- Root route context는 `createRootRouteWithContext`로 type 지정할 수 있습니다.
- `beforeLoad`는 route context를 확장할 수 있고 그 context는 loaders와 child routes에서 사용할 수 있습니다.
- Source: <https://tanstack.com/router/latest/docs/guide/router-context>

### SSR

- Full-stack framework behavior가 필요한 React Router users에게 TanStack Start는 권장 SSR setup입니다.
- Manual Router SSR도 존재하지만 Start가 대부분의 setup details를 처리합니다.
- Source: <https://tanstack.com/router/latest/docs/how-to/setup-ssr>

## Refresh Triggers

다음 경우 이 snapshot을 refresh합니다:

- Router file naming conventions 또는 route generation requirements가 변경됨.
- Zod/adapter usage에 대한 search validation guidance가 변경됨.
- Loader/beforeLoad lifecycle 또는 pending behavior가 변경됨.
- Local package versions가 위 versions보다 materially 이동함.
