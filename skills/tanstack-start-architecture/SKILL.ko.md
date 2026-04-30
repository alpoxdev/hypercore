---
name: tanstack-start-architecture
description: "[Hyper] TanStack Start 프로젝트의 route 구조, server functions, loader/client-server boundary, importProtection, hooks, SSR/hydration, hypercore convention을 구조 변경 전/중에 검증하고 강제합니다."
---

@architecture-rules.md
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

# TanStack Start Architecture Enforcement

> 공식 TanStack 요구사항과 hypercore 팀 convention을 구분하면서 TanStack Start 아키텍처를 검증합니다.

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

<trigger_examples>

Positive:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "TanStack Start 프로젝트에서 loader 경계랑 server function 구조 점검해줘."

Negative:

- "TanStack Start가 아닌 일반 React/Vite 앱을 리뷰해줘."
- "Codex용 browser QA skill을 새로 만들어줘."
- "프로젝트 감사 없이 TanStack Router 문서만 요약해줘."

Boundary:

- "정적인 TanStack Start privacy page의 카피만 바꿔줘."
  이 경우 빠른 boundary check만 수행합니다. publishing-only 페이지는 logic/server integration을 추가하지 않는 한 `-hooks/`, `-components/`, `-functions/` 폴더가 필요 없습니다.

</trigger_examples>

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
5. 공식 문서 충돌이나 package behavior가 불확실하면 `references/official/api-drift-notes.md`.
6. 완료 전 `rules/validation.ko.md`.

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
- server integration이 있는 페이지는 필요에 따라 `-functions/`, route-local hooks/components를 사용합니다.
- file route는 `export const Route = createFileRoute(...)`를 사용합니다.
- route/page UI -> hooks/query -> server functions -> feature/database layer 흐름을 유지합니다.
- kebab-case filename, explicit return type, no `any`, const arrow function, 의미 있는 코드 그룹의 Korean block comments를 유지합니다.

</hypercore_conventions_summary>

<validation>

완료 선언 전:

- `rules/validation.ko.md`의 작업별 검증을 실행합니다.
- 수정한 rule에 official-vs-hypercore label이 유지되는지 확인합니다.
- `SKILL.md`에서 support file이 직접 링크되고 indirect reference chain이 없는지 확인합니다.
- English/Korean entrypoint가 같은 trigger, boundary, workflow, read order를 설명하는지 확인합니다.
- 남은 TanStack API ambiguity는 source link와 정확한 날짜로 기록합니다.

</validation>
