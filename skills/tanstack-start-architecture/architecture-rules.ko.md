# 아키텍처 규칙 참조

> hypercore TanStack Start 프로젝트를 위한 rule taxonomy와 blocking gate 요약입니다.

일부 규칙은 공식 TanStack default보다 엄격합니다. 모든 규칙은 다음 중 하나로 이해해야 합니다:

- **Official** — TanStack이 요구하거나 문서화한 동작.
- **Safety policy** — 보안/런타임 correctness를 위한 local blocking rule.
- **Hypercore convention** — 공식 default를 넘어설 수 있는 local/team preference.

Brownfield 적용: touched files는 해당 safety rules와 현재 hypercore conventions를 만족해야 합니다. 손대지 않은 legacy style drift는 safety boundary issue가 아닌 한 migration backlog로 기록할 수 있습니다.

## Source Priority

1. `references/official/tanstack-start-2026-04-30.md`
2. `references/official/tanstack-router-2026-04-30.md`
3. `references/official/api-drift-notes.md`
4. `rules/` 아래 topic rules
5. Installed versions가 다르면 project-local package types와 tests

## Blocking Safety Gates

| Surface | Classification | Block 또는 fix 조건 |
|---|---|---|
| Loader boundaries | Official + Safety policy | Loader가 server-only execution을 가정하거나 secrets/DB/filesystem을 직접 읽음 |
| Server functions | Official + Safety policy | Mutation input이 runtime에 validate되지 않거나 handler가 없거나, 현재 canonical `.inputValidator()` guidance에도 `.validator()`를 도입함 |
| Import protection | Official + Safety policy | Import protection을 disable하거나 config를 overwrite하거나 server/client-only imports가 compiler-recognized boundaries 밖으로 leak됨 |
| Middleware | Official + Safety policy | Client `sendContext`를 runtime validation 없이 server-side에서 trust함 |
| SSR/hydration | Official + Safety policy | Stabilization/fallback strategy 없이 first render에 unstable values 포함 |
| Server routes | Official + Hypercore convention | Explicit justification 없이 internal app RPC를 server functions 대신 server routes로 구현 |
| Route export | Official | File routes가 route instance를 `Route`로 export하지 않음 |
| Route organization | Hypercore convention | Touched app pages가 flat files를 쓰거나 logic/server integration이 있는데 route-local folders를 생략 |
| Hooks | Hypercore convention | Touched interactive page/component logic이 `-hooks/`로 이동하지 않고 inline으로 남음 |
| Code style | Hypercore convention | Touched files가 camelCase filenames, `any`, function declarations, missing return types를 쓰거나 required Korean block comments를 생략 |

## Layer Architecture

```text
Route/Page UI
  -> route-local hooks / TanStack Query
  -> TanStack Start server functions
  -> features/<domain> or services/<provider>
  -> database/ or external SDK
```

Rules:

- **Safety policy:** Routes는 ORM/database clients를 직접 import하면 안 됩니다.
- **Hypercore convention:** Server functions는 사소하지 않은 business logic에 대해 feature/service layer code를 호출해야 합니다.
- **Hypercore convention:** 추출이 오히려 noise를 늘리는 단순 CRUD는 server function 안에 남아도 됩니다.

## Official-vs-Hypercore Clarifications

- TanStack Router는 flat, directory, mixed route structures를 공식 지원합니다. Hypercore는 app pages에 route directories를 선호합니다.
- TanStack Start import protection은 기본 활성화됩니다. Hypercore는 project-specific deny rules가 필요할 때 explicit extension을 요구합니다.
- Zod v4와 함께 쓰는 TanStack Router는 schema를 `validateSearch`에 직접 전달할 수 있습니다. Zod v3는 `@tanstack/zod-adapter`를 사용합니다.
- Server routes는 공식 Start feature입니다. Hypercore는 internal app RPC가 아니라 HTTP semantics 용도로 제한합니다.
- Publishing-only static pages는 logic/server integration이 도입되기 전에는 `-hooks/`, `-components/`, `-functions/`가 필요 없습니다.

## Topic Files

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

- Logic/server integration이 있는 page에 missing route-local folders 추가.
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
| Runtime validation 없는 server function mutation | `.inputValidator(...)` 추가 |
| Server function middleware에 `createMiddleware()` 사용 | `createMiddleware({ type: 'function' })` 사용 |
| Server/client imports가 environments 사이로 leak | File split, marker 추가, environment function wrapping |
| Static publishing page에 empty folders 강제 | Logic/server integration이 생길 때까지 folder 추가하지 않음 |
| Server route 아래 internal app RPC | HTTP semantics가 필요하지 않으면 server function 선호 |

## Completion Rule

`rules/validation.md`가 통과하고 남은 official API ambiguity가 exact date와 source로 기록되어야 change가 complete입니다.
