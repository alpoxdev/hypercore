# TanStack API Drift Notes

- last_verified_at: 2026-09-22
- purpose: Core skill rules가 stale examples에 과적합하지 않도록 official-doc conflicts와 source-priority decisions를 기록합니다.

## Contents

- [Source Priority](#source-priority)
- [`.inputValidator()` vs stale `.validator()` examples — SUPERSEDED 2026-09-22](#inputvalidator-vs-stale-validator-examples--superseded-2026-09-22)
- [Server function `.inputValidator()` vs middleware `.inputValidator()` — SUPERSEDED 2026-09-22](#server-function-inputvalidator-vs-middleware-inputvalidator--superseded-2026-09-22)
- [Search validation and Zod adapters](#search-validation-and-zod-adapters)
- [Import protection defaults](#import-protection-defaults)
- [Official vs Hypercore routing structure](#official-vs-hypercore-routing-structure)
- [Corrected 2026-09-22: `.validator()` is canonical, `.inputValidator()` is deprecated](#corrected-2026-09-22-validator-is-canonical-inputvalidator-is-deprecated)
- [Sources](#sources)

## Source Priority

1. 정확한 API area에 대한 current canonical guide.
2. 정확한 symbol에 대한 current API/reference page.
3. Installed project의 package types/source.
4. Rename 또는 migration을 설명하는 recent release notes.
5. Examples, comparisons, migration guides, blog posts.

Sources가 충돌하면 편한 쪽을 조용히 선택하지 않습니다. Exact date와 source links로 conflict를 기록합니다.

## `.inputValidator()` vs stale `.validator()` examples — SUPERSEDED 2026-09-22 (see the corrected decision below)

2026-06-09 기준 결정:

- `createServerFn` input validation의 current official Server Functions guide API는 `.inputValidator(...)`로 취급합니다.
- 오래되었거나 lower-priority content의 `.validator(...)` examples는 project-local installed types가 다르게 증명하지 않는 한 version drift로 취급합니다.
- 실제 project를 편집할 때는 broad migration 전에 installed `@tanstack/react-start` version을 확인합니다.

Evidence:

- Current Server Functions guide는 `.inputValidator(...)`를 사용합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- Current Middleware guide는 server function middleware-owned data validation에 `.inputValidator(...)`를 사용합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>
- 일부 오래된 history와 examples는 `.validator(...)`를 언급합니다. 이것들은 current `latest` docs authority가 아니라 drift context로 사용합니다.

Skill implication:

- `rules/services.md`는 current-docs 기반 새 작업에 `.inputValidator(...)`를 권장해야 합니다.
- `rules/middleware.md`는 server function middleware-owned data validation에 `.inputValidator(...)`를 권장해야 합니다.
- Existing project에서는 `.validator(...)`를 바꾸기 전에 package types를 확인합니다. 이 skill은 docs만 근거로 broad API migration을 수행하지 않습니다.
- Core `SKILL.md`는 긴 API history를 반복하지 말고 여기로 안내합니다.

## Server function `.inputValidator()` vs middleware `.inputValidator()` — SUPERSEDED 2026-09-22 (see the corrected decision below)

2026-06-09 기준 결정:

- `createServerFn` input validation과 server-function middleware data validation 모두 current official API는 `.inputValidator(...)`입니다.
- 둘을 혼동하지 않습니다. Method name은 같지만 서로 다른 chain object에 속하고 data/context가 다릅니다.
- Local chain type 확인 없이 server-function example을 근거로 middleware-owned validation을 migrate하거나, middleware example을 근거로 server-function validation을 migrate하지 않습니다.

Evidence:

- Current Server Functions guide는 `.inputValidator(...)`를 사용합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- Current Middleware guide는 server function middleware validation을 `.inputValidator(...)`로 나열합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

Skill implication:

- `rules/services.md`는 server function `.inputValidator(...)` guidance를 담당합니다.
- `rules/middleware.md`는 middleware `.inputValidator(...)`, request middleware `createMiddleware()`, server function middleware `createMiddleware({ type: 'function' })` guidance를 담당합니다.

## Search validation and Zod adapters

2026-04-30 기준 결정:

- Zod v4는 `validateSearch`에서 schema를 직접 사용할 수 있습니다.
- Zod v3는 `@tanstack/zod-adapter`와 `zodValidator`/`fallback`을 사용해야 합니다.
- Project가 adapter를 hypercore convention으로 양쪽 version에 표준화할 수는 있지만, 공식 docs보다 엄격하다고 label해야 합니다.

Evidence:

- <https://tanstack.com/router/latest/docs/how-to/validate-search-params>
- <https://tanstack.com/router/latest/docs/how-to/setup-basic-search-params>

## Import protection defaults

2026-04-30 기준 결정:

- Import protection은 Start에서 기본 활성화됩니다.
- Database/server/client 같은 directories 또는 ORM clients 같은 packages에 additional deny rules가 필요하면 explicit config가 여전히 필요합니다.
- Import protection 비활성화는 명시 요청이 없는 한 blocking safety issue입니다.

Evidence: <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

## Official vs Hypercore routing structure

2026-04-30 기준 결정:

- Router는 flat, directory, mixed route file structures를 지원합니다.
- Hypercore의 route-directory preference는 maintainability를 위한 local convention이며 official TanStack behavior로 설명하면 안 됩니다.

Evidence: <https://tanstack.com/router/latest/docs/routing/file-based-routing>

## Corrected 2026-09-22: `.validator()` is canonical, `.inputValidator()` is deprecated

2026-09-22 기준 결정입니다. 위의 2026-06-09 결정 두 건을 대체합니다.

- 정책: `.validator(...)`가 정본이고, `.inputValidator(...)`는 런타임에서 여전히 동작하는 폐기 별칭입니다.
- 근거는 서로 독립적인 세 표면이며, 모두 2026-09-22에 다시 확인했습니다.
  1. 문서: `guide/server-functions.md`는 전체에서 `.validator(...)`를 씁니다(7회, `inputValidator` 0회). `guide/middleware.md:34`는 ``Input Validation | No | Yes (`.validator()`)``이고, `:232`의 제목은 "The `.validator` method"입니다.
  2. 고정 소스 `fe7f1fd0e6ef73c3f341dd2338b406749538a85d`: `packages/start-client-core/src/createServerFn.ts:511`이 `inputValidator` 위에 ``/** @deprecated Use `validator` instead. */``를 달고 있고, `createMiddleware.ts:182-183`도 같은 표시를 달고 있습니다. `createServerFn.ts:921`은 `const validator = options.validator ?? options.inputValidator`입니다. 별칭이 런타임에서 계속 해석되므로 계속 동작합니다.
  3. 릴리스: PR #7566 "rename inputValidator to validator"가 변경 파일 212개로 2026-06-06T21:05:57Z에 병합됐고, `@tanstack/react-start@1.168.25`로 배포됐습니다. 게시 시각은 2026-06-06T21:43:40Z입니다.
- 스킬은 리네임이 병합된 지 사흘 뒤에 그 반대를 기록했습니다. 당시 `last_verified_at`은 2026-06-09였고, 위의 결정 두 건은 `.validator(...)` 예제를 version drift로 취급하라고 적었습니다. 그 검증 pass는 낡은 것이 아니라 틀렸습니다. 뒤집힌 결정을 위에 그대로 두고 SUPERSEDED로 표시하는 이유는, 이 스킬이 어떻게 이것을 잘못 짚었는지가 이 로그의 쓸모이기 때문입니다.
- `rules/services.md:18`이 이 파일을 링크하므로, 그 링크는 이제 뒤집힌 방향이 아니라 바로잡힌 방향을 가리킵니다.

## Sources

> 출처 확인 2026-09-22. 이 파일이 `last_verified_at`으로 기록한 날짜이며, 위 각 결정은 날짜와 근거 TanStack page를 함께 밝히고 있습니다. 2026-09-22 pass는 바로잡은 절에서 인용한 모든 출처를 다시 가져왔고, 이 파일 밖의 출처는 주장하지 않습니다.
