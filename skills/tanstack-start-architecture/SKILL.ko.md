---
name: tanstack-start-architecture
description: 기존 TanStack Start/Router 프로젝트의 routes, loaders, server functions, importProtection, SSR/hydration, `src/modules`, `src/lib`, `src/integrations` 같은 nested shared folders 아키텍처를 리뷰하거나 변경할 때 사용합니다. 일반 React/Vite 프로젝트나 문서 요약 전용 요청에는 사용하지 않습니다.
---

@architecture-rules.md
@rules/project-structure.ko.md
@rules/routes.ko.md
@rules/services.ko.md
@rules/hooks.ko.md
@rules/import-protection.ko.md
@rules/middleware.ko.md
@rules/execution-model.ko.md
@rules/server-routes.ko.md
@rules/ssr-hydration.ko.md
@rules/platform.ko.md
@rules/validation.ko.md
@references/official/tanstack-start-2026-04-30.md
@references/official/tanstack-router-2026-04-30.md
@references/official/api-drift-notes.md
@references/official/current-docs-2026-06-02.ko.md

# TanStack Start Architecture Enforcement

> 공식 TanStack 요구사항과 hypercore 팀 convention을 구분하면서 TanStack Start 아키텍처를 검증합니다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- TanStack Start / TanStack Router 프로젝트인지 먼저 확인합니다.
- loader, server function, import protection, middleware, server route, SSR/hydration 안전 경계를 강제합니다.
- route folder, hook 분리, 파일명, 주석, layer 구조 같은 hypercore convention을 적용합니다.
- 변동이 잦은 TanStack 공식 API 사실은 `references/official/`에 두고 코어 스킬은 얇게 유지합니다.

</purpose>

<operating_mode>

이 스킬은 자체 완결형입니다. 적용 전에 전역 스킬이나 외부 orchestration에 의존하지 않습니다.

규칙은 다음처럼 분류합니다:

- **Official** — TanStack 공식 문서/API 요구사항.
- **Safety policy** — 보안/런타임 안전을 위한 로컬 차단 규칙.
- **Hypercore convention** — 공식 기본값보다 엄격할 수 있는 팀 표준.

사용자가 공식 TanStack default만 원한다고 명시하면 hypercore-only convention은 완화할 수 있지만 Official/Safety 규칙은 유지합니다.

</operating_mode>

<routing_rule>

요청 결과가 기존 TanStack Start / TanStack Router 프로젝트의 architecture enforcement, implementation guidance, review일 때 이 스킬을 사용합니다. 범위에는 route structure, route-local folders, loaders, server functions, server routes, middleware, import protection, SSR/hydration, platform setup, shared nested folder organization이 포함됩니다.

다음 경우에는 사용하지 않습니다.

- 프로젝트가 TanStack Start 또는 TanStack Router가 아님
- 사용자가 일반 React/Vite architecture review만 요청함
- project audit 또는 implementation guidance 없이 문서 요약만 요청함
- 주요 작업이 Start architecture와 무관한 security, deployment, test repair임

공식 TanStack guidance와 Hypercore convention이 다르면 official/safety rules를 먼저 강제하고, Hypercore convention은 touched architecture surface에만 적용합니다.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | TanStack Start 프로젝트를 official Start/Router behavior와 label된 Hypercore convention에 맞게 안전하고 유지보수 가능하게 유지합니다. |
| Trigger | routes, loaders, server functions, import boundaries, SSR/hydration, middleware, server routes, platform setup, shared folder layout을 포함한 기존 Start/Router 프로젝트 작업. |
| Scope | touched project architecture, topic rule files, official references, validation notes, 작고 되돌릴 수 있는 architecture fix를 리뷰하고 안내합니다. |
| Authority | 사용자/프로젝트 지시가 이 스킬보다 우선합니다. API 사실은 공식 TanStack 문서가 Hypercore convention보다 우선합니다. Safety policy는 위험한 runtime/import-boundary 변경을 차단합니다. |
| Evidence | project indicators, local config/package files, touched source paths, topic rules, official references, package typecheck, validation command output을 사용합니다. |
| Tools | local search/read/edit/validation commands를 사용합니다. API drift가 중요하면 최신 공식 문서를 확인합니다. destructive migration, credential access, network side effect, production change는 gate합니다. |
| Output | rule classification, 변경 파일, 검증 근거, 남은 risk, official-doc ambiguity note가 포함된 한국어 architecture decision/review. |
| Verification | touched surface에 맞는 `rules/validation.ko.md` checks와, 이 스킬 폴더 변경 시 skill-anatomy checks를 실행합니다. |
| Stop condition | applicable safety gate가 통과하고, Hypercore convention을 적용 또는 명시적으로 보류했으며, 검증 근거와 unresolved API drift의 날짜/출처를 기록하면 멈춥니다. |

</instruction_contract>

<activation_examples>

Positive examples:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "TanStack Start 프로젝트에서 loader 경계랑 server function 구조 점검해줘."
- "TanStack Start folder structure를 검토하고 nested src/modules 또는 src/lib grouping을 강제해줘."

Negative examples:

- "TanStack Start가 아닌 일반 React/Vite 앱을 리뷰해줘."
- "Codex용 browser QA skill을 새로 만들어줘."
- "프로젝트 감사 없이 TanStack Router 문서만 요약해줘."

Boundary examples:

- "정적인 TanStack Start privacy page의 카피만 바꿔줘."
  이 경우 빠른 boundary check만 수행합니다. publishing-only 페이지는 `-hooks/`, `-components/`, `-functions/` 폴더가 필요 없으며, interactive UI 또는 route-only server action이 생길 때만 route-local folder를 추가합니다.

</activation_examples>

<project_validation>

규칙을 적용하기 전에 아래 Start/Router indicator 중 하나 이상을 확인합니다:

```bash
ls app.config.ts 2>/dev/null
grep -r "@tanstack/react-start" package.json 2>/dev/null
grep -r "@tanstack/react-router" package.json 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

아무 것도 없으면 이 스킬 적용을 중단하고 일반 구현/리뷰 경로로 전환합니다.

</project_validation>

<support_file_read_order>

작업에 필요한 파일만 읽습니다:

1. `architecture-rules.md` — rule taxonomy와 blocking gate 요약.
2. 변경 표면별 topic rules:
   - `rules/project-structure.ko.md` — official Start project shape, `src/routes`, route tree generation, custom route directory, shared nested folders.
   - `rules/routes.ko.md` — route 조직, search validation, loader, route lifecycle.
   - `rules/services.ko.md` — server function, validation, query/mutation layering.
   - `rules/hooks.ko.md` — hook 추출, 내부 순서, `useServerFn` wrapper policy.
   - `rules/import-protection.ko.md` — client/server import boundary와 `vite.config.ts` deny rules.
   - `rules/middleware.ko.md` — function/request middleware와 `sendContext` validation.
   - `rules/execution-model.ko.md` — isomorphic loader와 environment-only functions.
   - `rules/server-routes.ko.md` — HTTP endpoint와 internal app RPC 구분.
   - `rules/ssr-hydration.ko.md` — deterministic first render, `ClientOnly`, route SSR mode.
   - `rules/platform.ko.md` — `getRouter()`, env validation, path aliases, operational endpoints.
3. Start API behavior가 중요하면 `references/official/tanstack-start-2026-04-30.md`.
4. Router/file-route/search/loading behavior가 중요하면 `references/official/tanstack-router-2026-04-30.md`.
5. current Start docs, plugin config, import protection, server functions, execution-control API가 판단에 영향을 주면 `references/official/current-docs-2026-06-02.ko.md`.
6. 공식 문서 충돌이나 package behavior가 불확실하면 `references/official/api-drift-notes.md`.
7. 완료 전 `rules/validation.ko.md`.

</support_file_read_order>

<workflow>

| Phase | Task | Output |
|---|---|---|
| 0 | TanStack Start/Router 프로젝트인지 확인 | Scope decision |
| 1 | 변경 표면을 파악하고 필요한 rule/reference만 읽기 | Minimal evidence set |
| 2 | 각 규칙을 Official, Safety policy, Hypercore convention으로 분류 | Enforcement plan |
| 3 | 안전하고 로컬이며 되돌릴 수 있는 수정을 자동 적용 | Code 또는 skill changes |
| 4 | 넓은 migration은 명시 요청이 없으면 backlog/handoff 처리 | Backlog 또는 handoff note |
| 5 | `rules/validation.ko.md` 검증 실행 | Evidence-backed completion |

</workflow>

<blocking_safety_summary>

아래가 touched code에 생기면 진행 전 반드시 차단/수정합니다:

- secret, DB client, filesystem, privileged SDK를 isomorphic loader/client-reachable code에서 직접 읽음.
- `createServerFn` 또는 `createServerOnlyFn` 같은 compiler-recognized boundary 밖에 server-only import가 살아남음.
- import protection을 비활성화하거나 기존 `tanstackStart()` 설정을 확장하지 않고 덮어씀.
- mutation server function에 runtime input validation이 없음.
- 신뢰할 수 없는 `sendContext` 값을 server에서 검증 없이 사용함.
- `Date.now()`, random ID, locale/time-zone 차이 등 hydration-unstable first render output을 안정화 전략 없이 도입함.

</blocking_safety_summary>

<hypercore_conventions_summary>

사용자가 official default만 원한다고 명시하지 않는 한 touched file에 적용합니다:

- 앱 페이지는 flat route보다 route directory를 선호합니다.
- interactive logic이 있는 page/component는 logic을 `-hooks/`로 추출합니다. publishing-only static page는 예외입니다.
- server integration이 있는 페이지는 기본적으로 `src/modules/<domain>/<feature>/`의 server functions를 route-local hooks에서 호출합니다. route-local `-functions/`는 단일 route 전용 action일 때만 예외로 사용합니다.
- file route는 `export const Route = createFileRoute(...)`를 사용합니다.
- route/page UI -> hooks/query -> route-local exception 또는 module server functions -> modules/lib/db/integrations layer 흐름을 유지합니다.
- server functions는 기본적으로 `src/modules/<domain>/<feature>/<resource>.functions.ts`에 둡니다. route-local `-functions/<resource>.functions.ts`는 단일 route 전용 action에만 사용합니다.
- server function wrapper는 `.functions.ts`, DB/secret/filesystem helper는 `.server.ts`, validation/DTO/query-key는 client-safe schema/helper file로 분리합니다.
- touched shared code를 추가하거나 재구성할 때 `src/modules/<domain>/<feature>/`, `src/lib/<domain>/`, `src/db/<area>/`, `src/server/<area>/`, `src/integrations/<provider>/`, `src/config/<area>/` 같은 nested shared folders를 강제합니다. 명시적 project exception을 기록하지 않는 한 `src/modules/foo.ts` 또는 `src/lib/foo.ts` 같은 새 direct leaf file을 만들지 않습니다.
- `functions/index.ts` 또는 `src/modules/<domain>/<feature>/index.ts`에서 safe exports와 server-only exports를 섞지 않습니다.
- kebab-case filename, explicit return type, no `any`, const arrow function, 의미 있는 코드 그룹의 Korean block comments를 유지합니다.

</hypercore_conventions_summary>

<validation>

완료 선언 전:

- `rules/validation.ko.md`의 작업별 검증을 실행합니다.
- 수정한 rule에 official-vs-hypercore label이 유지되는지 확인합니다.
- `SKILL.md`에서 support file이 직접 링크되고 indirect reference chain이 없는지 확인합니다.
- English/Korean entrypoint가 같은 trigger, boundary, workflow, contract, read order를 설명하는지 확인합니다.
- touched `src/modules`, `src/lib`, `src/integrations` 및 유사 shared folders가 logical nested grouping을 쓰는지 또는 explicit exception이 기록됐는지 확인합니다.
- server function-heavy changes가 `.functions.ts` / `.server.ts` split, static direct imports, auth/CSRF boundary를 유지하는지 확인합니다.
- 남은 TanStack API ambiguity는 source link와 정확한 날짜로 기록합니다.

</validation>
