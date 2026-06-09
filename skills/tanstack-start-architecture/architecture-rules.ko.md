# 아키텍처 규칙 참조

> hypercore TanStack Start 프로젝트를 위한 rule taxonomy와 blocking gate 요약입니다.

일부 규칙은 공식 TanStack default보다 엄격합니다. 모든 규칙은 다음 중 하나로 이해해야 합니다:

- **Official** — TanStack이 요구하거나 문서화한 동작.
- **Safety policy** — 보안/런타임 correctness를 위한 local blocking rule.
- **Hypercore convention** — 공식 default를 넘어설 수 있는 local/team preference.

Brownfield 적용: touched files는 해당 safety rules와 현재 hypercore conventions를 만족해야 합니다. 손대지 않은 legacy style drift는 safety boundary issue가 아닌 한 migration backlog로 기록할 수 있습니다.

## Source Priority

1. `references/official/current-docs-2026-06-02.ko.md`
2. `references/official/tanstack-start-2026-04-30.ko.md`
3. `references/official/tanstack-router-2026-04-30.ko.md`
4. `references/official/api-drift-notes.ko.md`
5. `rules/` 아래 topic rules
6. Installed versions가 다르면 project-local package types와 tests

## Blocking Safety Gates

| Surface | Classification | Block 또는 fix 조건 |
|---|---|---|
| Loader boundaries | Official + Safety policy | Loader가 server-only execution을 가정하거나 secrets/DB/filesystem을 직접 읽음 |
| Server functions | Official + Safety policy | Mutation input이 runtime에 validate되지 않거나 handler가 없거나 installed package/API version을 따르지 않거나 auth-required RPC가 자체 auth boundary를 갖지 않음 |
| Import protection | Official + Safety policy | Import protection을 disable하거나 config를 overwrite하거나 server/client-only imports가 compiler-recognized boundaries 밖으로 leak됨 |
| Middleware | Official + Safety policy | Client `sendContext`를 runtime validation 없이 server-side에서 trust함 |
| SSR/hydration | Official + Safety policy | Stabilization/fallback strategy 없이 first render에 unstable values 포함 |
| Server routes | Official + Hypercore convention | Explicit justification 없이 internal app RPC를 server functions 대신 server routes로 구현 |
| Route export | Official | File routes가 route instance를 `Route`로 export하지 않음 |
| Route organization | Hypercore convention | Touched app pages가 flat files를 쓰거나 필요한 route-local hooks/components를 생략하거나 route-local `-functions/`를 server function 기본 위치처럼 취급 |
| Project structure | Official + Hypercore convention + Safety policy | Review가 custom route root를 무시하거나, `routeTree.gen.ts`를 수동 편집하거나, shared folder convention을 official law처럼 취급하거나, server-only shared code를 client에 노출하거나, server function wrapper/helper를 섞음 |
| Hooks | Hypercore convention | Touched interactive page/component logic이 `-hooks/`로 이동하지 않고 inline으로 남음 |
| Code style | Hypercore convention | Touched files가 camelCase filenames, `any`, function declarations, missing return types를 쓰거나 required Korean block comments를 생략 |

## Layer Architecture

```text
Route/Page UI
  -> route-local hooks / TanStack Query
  -> optional route-local -functions/<resource>.functions.ts
     또는 modules/<domain>/<feature>/<resource>.functions.ts
  -> modules/<domain>/<feature>/<resource>.server.ts
  -> lib/<domain>, db/<domain> repositories,
     또는 integrations/<provider> server-only clients
  -> database/ 또는 external SDK
```

Rules:

- **Safety policy:** Routes는 ORM/database clients를 직접 import하면 안 됩니다.
- **Hypercore convention:** Server functions는 사소하지 않은 business logic에 대해 domain module/lib layer code를 호출해야 합니다.
- **Hypercore convention:** 추출이 오히려 noise를 늘리는 단순 CRUD는 server function 안에 남아도 됩니다.
- **Safety policy:** Auth-required server function은 route `beforeLoad`만 믿지 않고 middleware 또는 handler-level auth check를 가져야 합니다.
- **Hypercore convention + Safety policy:** `*.functions.ts`는 `createServerFn` wrapper entrypoint, `*.server.ts`는 privileged helper로 분리하고 mixed barrel을 만들지 않습니다.

## Official-vs-Hypercore Clarifications

- TanStack Router는 flat, directory, mixed route structures를 공식 지원합니다. Hypercore는 app pages에 route directories를 선호합니다.
- TanStack Start docs는 `src/routes`, `src/router.tsx`, generated `src/routeTree.gen.ts`, `public/`, root `vite.config.ts`를 typical project shape로 보여줍니다. nested `src/modules`, `src/lib`, `src/integrations`와 비슷한 shared folders는 Hypercore/repo-local conventions입니다.
- TanStack Start import protection은 기본 활성화됩니다. Hypercore는 project-specific deny rules가 필요할 때 explicit extension을 요구합니다.
- TanStack Start server function wrapper는 static import 가능한 RPC entrypoint입니다. 큰 앱에서는 `.functions.ts` wrapper와 `.server.ts` server-only helper를 분리하는 official guidance를 Hypercore `src/modules/<domain>/<feature>/` convention으로 적용합니다.
- Zod v4와 함께 쓰는 TanStack Router는 schema를 `validateSearch`에 직접 전달할 수 있습니다. Zod v3는 `@tanstack/zod-adapter`를 사용합니다.
- Server routes는 공식 Start feature입니다. Hypercore는 internal app RPC가 아니라 HTTP semantics 용도로 제한합니다.
- Publishing-only static pages는 `-hooks/`, `-components/`, `-functions/`가 필요 없습니다. Interactive UI가 커지면 `-hooks/` 또는 `-components/`를 추가하고, route-only server action일 때만 `-functions/`를 추가합니다.

## Topic Files

- `rules/project-structure.md` — Start project shape, route-root discovery, generated route tree, shared nested folder grouping, route-local/shared server function placement.
- `rules/routes.md` — route organization, route lifecycle, search params, folder policy.
- `rules/services.md` — server functions, validation, query/mutation layering.
- `rules/hooks.md` — hook extraction and `useServerFn` wrapper policy.
- `rules/import-protection.md` — marker files, deny rules, compiler-boundary leaks.
- `rules/middleware.md` — middleware types, context propagation, `sendContext` validation.
- `rules/execution-model.md` — isomorphic/default execution model.
- `rules/server-routes.md` — server route allowlist and justifications.
- `rules/ssr-hydration.md` — SSR modes and hydration stability.
- `rules/platform.md` — router/env/alias/operational setup.
- `rules/validation.md` — final readback and trigger/resource checks.

## Auto-Remediation Policy

Issue가 local, reversible, low-risk이면 직접 auto-fix합니다:

- Interactive logic 또는 extracted UI가 있는 page에 missing route-local hooks/components 추가.
- Unrelated config를 overwrite하지 않고 custom `importProtection` deny rules를 추가 또는 확장.
- `getRouter()` fresh-instance router setup 추가.
- Marker imports 또는 explicit `createServerOnlyFn` / `createClientOnlyFn` boundaries 추가.
- Untrusted server function input 또는 `sendContext`에 runtime validation 추가.

명확한 user request 없이 broad 또는 potentially breaking migrations를 자동 적용하지 않습니다:

- Mass route/file renames.
- Sweeping server route to server function migrations.
- 여러 route에 걸친 SSR mode changes.
- Alias-wide import rewrites.
- Database schema edits 또는 migration commands.

## Common Mistakes To Fix In Touched Files

| Mistake | Preferred fix |
|---|---|
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `loader`를 server-only로 취급 | Privileged work를 `createServerFn` / `createServerOnlyFn` 뒤로 이동 |
| Zod v4 search params를 adapter에 강제로 통과 | Project convention이 adapter를 요구하지 않으면 direct schema 사용 |
| Zod v3 search params에 adapter/fallback 없음 | `@tanstack/zod-adapter`의 `zodValidator` / `fallback` 사용 |
| Runtime validation 없는 server function mutation | `.handler(...)` 전에 `.inputValidator(...)` 추가 |
| Auth-required server function이 route `beforeLoad`만 의존 | server function middleware 또는 handler-level auth check 추가 |
| `*.functions.ts`가 DB/secret helper를 handler 밖 surviving export에서 참조 | `*.server.ts`로 split하고 handler 내부 boundary로 이동 |
| `src/modules/<domain>/<feature>/index.ts`가 `.functions.ts`와 `.server.ts`를 함께 export | barrel 제거 또는 safe/server-only entrypoint 분리 |
| Server-function-only middleware behavior에 `createMiddleware()` 사용 | `createMiddleware({ type: 'function' })` 사용. Request middleware는 `createMiddleware()` 유지 |
| Server/client imports가 environments 사이로 leak | File split, marker 추가, environment function wrapping |
| Static publishing page에 empty folders 강제 | Interactive UI, extracted sections, route-only server action이 생길 때까지 route-local folder를 추가하지 않음 |
| Server route 아래 internal app RPC | HTTP semantics가 필요하지 않으면 server function 선호 |

## Completion Rule

`rules/validation.md`가 통과하고 남은 official API ambiguity가 exact date와 source로 기록되어야 change가 complete입니다.
