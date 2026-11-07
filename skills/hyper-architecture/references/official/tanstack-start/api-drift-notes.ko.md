# TanStack API Drift Notes

- last_verified_at: 2026-11-04
- purpose: Core skill rules가 stale examples에 과적합하지 않도록 official-doc conflicts와 source-priority decisions를 기록합니다.

## Contents

- [Source Priority](#source-priority)
- [`.inputValidator()` vs stale `.validator()` examples — SUPERSEDED 2026-09-22](#inputvalidator-vs-stale-validator-examples--superseded-2026-09-22-see-the-corrected-decision-below)
- [Server function `.inputValidator()` vs middleware `.inputValidator()` — SUPERSEDED 2026-09-22](#server-function-inputvalidator-vs-middleware-inputvalidator--superseded-2026-09-22-see-the-corrected-decision-below)
- [Search validation and Zod adapters](#search-validation-and-zod-adapters)
- [Import protection defaults](#import-protection-defaults)
- [Official vs Hypercore routing structure](#official-vs-hypercore-routing-structure)
- [Corrected 2026-09-22: `.validator()` is canonical, `.inputValidator()` is deprecated](#corrected-2026-09-22-validator-is-canonical-inputvalidator-is-deprecated-superseded-2026-11-04)
- [Corrected 2026-11-04: `.inputValidator()` is removed](#corrected-2026-11-04-inputvalidator-is-removed)
- [Search validation and Zod adapter peer range](#search-validation-and-zod-adapter-peer-range)
- [Import protection is documented, not experimental](#import-protection-is-documented-not-experimental)
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

- `rules/tanstack-start/services.md`는 current-docs 기반 새 작업에 `.inputValidator(...)`를 권장해야 합니다.
- `rules/tanstack-start/middleware.md`는 server function middleware-owned data validation에 `.inputValidator(...)`를 권장해야 합니다.
- Existing project에서는 `.validator(...)`를 바꾸기 전에 package types를 확인합니다. 이 skill은 docs만 근거로 broad API migration을 수행하지 않습니다.
- Core `stacks/tanstack-start/core.md`는 긴 API history를 반복하지 말고 여기로 안내합니다.

## Server function `.inputValidator()` vs middleware `.inputValidator()` — SUPERSEDED 2026-09-22 (see the corrected decision below)

2026-06-09 기준 결정:

- `createServerFn` input validation과 server-function middleware data validation 모두 current official API는 `.inputValidator(...)`입니다.
- 둘을 혼동하지 않습니다. Method name은 같지만 서로 다른 chain object에 속하고 data/context가 다릅니다.
- Local chain type 확인 없이 server-function example을 근거로 middleware-owned validation을 migrate하거나, middleware example을 근거로 server-function validation을 migrate하지 않습니다.

Evidence:

- Current Server Functions guide는 `.inputValidator(...)`를 사용합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- Current Middleware guide는 server function middleware validation을 `.inputValidator(...)`로 나열합니다: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

Skill implication:

- `rules/tanstack-start/services.md`는 server function `.inputValidator(...)` guidance를 담당합니다.
- `rules/tanstack-start/middleware.md`는 middleware `.inputValidator(...)`, request middleware `createMiddleware()`, server function middleware `createMiddleware({ type: 'function' })` guidance를 담당합니다.

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

## Corrected 2026-09-22: `.validator()` is canonical, `.inputValidator()` is deprecated (SUPERSEDED 2026-11-04)

2026-09-22 기준 결정입니다. 위의 2026-06-09 결정 두 건을 대체했고, 별칭 문제에서는 아래 2026-11-04 절이 이 결정을 다시 대체합니다.

- 당시 정책: `.validator(...)`가 정본이고, `.inputValidator(...)`는 **그 commit에서** 런타임에 계속 동작하던 폐기 별칭이었습니다.
- 근거는 서로 독립적인 세 표면이며, 모두 2026-09-22에 다시 확인했습니다.
  1. 문서: `guide/server-functions.md`는 전체에서 `.validator(...)`를 씁니다(7회, `inputValidator` 0회). `guide/middleware.md:34`는 ``Input Validation | No | Yes (`.validator()`)``이고, `:232`의 제목은 "The `.validator` method"입니다.
  2. 고정 소스 `fe7f1fd0e6ef73c3f341dd2338b406749538a85d`: `packages/start-client-core/src/createServerFn.ts:511`이 `inputValidator` 위에 ``/** @deprecated Use `validator` instead. */``를 달고 있고, `createMiddleware.ts:182-183`도 같은 표시를 달고 있습니다. `createServerFn.ts:921`은 `const validator = options.validator ?? options.inputValidator`입니다. 별칭이 런타임에서 계속 해석되므로 계속 동작합니다.
  3. 릴리스: PR #7566 "rename inputValidator to validator"가 변경 파일 212개로 2026-06-06T21:05:57Z에 병합됐고, `@tanstack/react-start@1.168.25`로 배포됐습니다. 게시 시각은 2026-06-06T21:43:40Z입니다.
- 스킬은 리네임이 병합된 지 사흘 뒤에 그 반대를 기록했습니다. 당시 `last_verified_at`은 2026-06-09였고, 위의 결정 두 건은 `.validator(...)` 예제를 version drift로 취급하라고 적었습니다. 그 검증 pass는 낡은 것이 아니라 틀렸습니다. 뒤집힌 결정을 위에 그대로 두고 SUPERSEDED로 표시하는 이유는, 이 스킬이 어떻게 이것을 잘못 짚었는지가 이 로그의 쓸모이기 때문입니다.
- `rules/tanstack-start/services.md:18`이 이 파일을 링크하므로, 그 링크는 이제 뒤집힌 방향이 아니라 바로잡힌 방향을 가리킵니다.

## Corrected 2026-11-04: `.inputValidator()` is removed

2026-11-04 기준 결정입니다. 2026-09-22 결정 중 "폐기 별칭" 부분을 대체하고, "`.validator()`가 정본"이라는 부분은 그대로 유효합니다.

- 정책: `.validator(...)`가 유일한 표기입니다. `.inputValidator(...)`는 `createServerFn`과 `createMiddleware`에 더 이상 없으므로, 남아 있는 호출은 참아 줄 legacy 부채가 아니라 마이그레이션할 깨진 코드입니다.
- 근거는 세 표면이며, 모두 2026-11-04에 다시 확인했습니다.
  1. `@tanstack/react-start@1.169.0`(2026-10-12 게시) release note: "Remove the deprecated `.inputValidator()` from `createServerFn` and `createMiddleware`. Use `.validator()`, which takes the same validator."
  2. Migration page(`migrate-from-release-candidate`)의 제거 API 표: "`.inputValidator()` on server functions and middleware | `.validator()`, which takes the same validator."
  3. type: `@tanstack/start-client-core@1.170.39`의 선언에 `inputValidator`가 한 번도 나오지 않습니다.
- 2026-09-22 기록에서 맞은 것과 틀린 것: `.validator(...)`가 이미 정본이라는 부분은 유효합니다. 별칭이 "런타임에서 계속 해석된다"는 주장은 commit `fe7f1fd0e6ef73c3f341dd2338b406749538a85d`의 `options.validator ?? options.inputValidator` fallback을 설명한 것이고, 그 fallback은 사라졌습니다.
- `rules/tanstack-start/services.md`와 `rules/tanstack-start/middleware.md`는 `.inputValidator(...)` 판정을 둘 다 BLOCKED로 바꿉니다. `rules/tanstack-start/validation.md`는 탐지 grep에 두 철자를 그대로 두지만, 이제 hit는 legacy 스타일이 아니라 깨진 코드를 뜻합니다.

## Search validation and Zod adapter peer range

2026-11-04 기준 결정이며 2026-04-30 결정을 확장합니다.

- Zod v4는 schema를 `validateSearch`에 직접 전달합니다. `@tanstack/zod-adapter`는 Zod v3 전용이고 `peerDependencies`가 `zod: ^3.23.8`을 고정하므로, Zod 4 프로젝트에서는 peer 충돌 없이 설치할 수 없습니다.
- Zod v3는 adapter의 `zodValidator` / `fallback`을 계속 씁니다.
- 모든 곳에서 `zodValidator`로 표준화하는 프로젝트는 Zod 3에 머무는 동안만 성립합니다. 그 관례를 Zod 4 업그레이드로 가져가면 안 됩니다.
- 알려진 문서 불일치: middleware guide의 예시 하나가 아직 `zodValidator`를 import합니다. 버전 분기의 권위는 `guide/search-params`와 `how-to/validate-search-params`에 있고, 낡은 예시를 베끼지 말고 불일치로 보고합니다.

Evidence:
- <https://tanstack.com/router/latest/docs/guide/search-params>: "With Zod v4, you should directly use the schema in `validateSearch`"
- <https://tanstack.com/router/latest/docs/how-to/validate-search-params>: "For Zod v4, the adapter is no longer necessary"
- <https://registry.npmjs.org/@tanstack/zod-adapter/latest>: `"peerDependencies": { "zod": "^3.23.8" }`

## Import protection is documented, not experimental

2026-11-04 기준 결정입니다.

- import-protection guide에는 Experimental 표시도 "subject to change" 문장도 없습니다. `enabled`, `behavior`, `log`, `include`, `exclude`, `maxTraceDepth`, 환경별 `files`/`specifiers`/`excludeFiles`, `ignoreImporters`, `onViolation`을 문서화합니다.
- `mockAccess`는 여전히 실제로 있지만 문서화되지 않은 옵션입니다. `@tanstack/start-plugin-core@1.171.55`의 `schema.d.ts`가 `mockAccess: z.enum(['error','warn','off']).optional()`을 선언하고 guide는 언급하지 않습니다. 미문서 옵션으로 인용하고 버전마다 다시 확인합니다.
- dev mode 위반은 오탐일 수 있습니다. build mode는 tree-shaking 뒤까지 검사를 미루므로 boundary를 고치기 전에 production build로 확인합니다.

## Sources

> 출처 확인 2026-11-04. 이 파일이 `last_verified_at`으로 기록한 날짜이며, 위 각 결정은 날짜와 근거 TanStack page를 함께 밝히고 있습니다. 2026-11-04 pass는 <https://tanstack.com/start/latest/docs/framework/react/overview.md>, <https://tanstack.com/start/latest/docs/framework/react/migrate-from-release-candidate.md>, <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>, <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>, <https://tanstack.com/start/latest/docs/framework/react/guide/middleware.md>, <https://tanstack.com/router/latest/docs/guide/search-params>, <https://tanstack.com/router/latest/docs/how-to/validate-search-params>, <https://registry.npmjs.org/@tanstack/react-start/latest>, <https://registry.npmjs.org/@tanstack/zod-adapter/latest>, `@tanstack/start-client-core@1.170.39`와 `@tanstack/start-plugin-core@1.171.55`의 배포 tarball을 다시 가져왔고, 이 목록 밖의 출처는 주장하지 않습니다.
