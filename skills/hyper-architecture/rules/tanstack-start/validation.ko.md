# Validation and Readback

> TanStack Start architecture 작업과 이 스킬 자체 유지보수 완료 검증.

## Project Work Validation

변경 표면에 맞는 check를 실행합니다:

```bash
# route export와 직접 DB 접근 검사
rg -n "const Route = createFileRoute|export const Route" src/routes 2>/dev/null
rg -n "from ['\"]@/database|from ['\"].*/database|@prisma/client|drizzle-orm" src/routes 2>/dev/null

# server function 검증과 낡은 API 검사
# 탐지 grep: 두 철자를 모두 유지합니다. `.inputValidator(`는 1.169.0에서 제거됐으므로 발견되면 legacy 스타일이 아니라 깨진 코드입니다
rg -n "\.validator\(|\.inputValidator\(|createServerFn" src 2>/dev/null

# import 경계 검사
rg -n "server-only|client-only|\.server\.|\.client\.|importProtection|tanstackStart" vite.config.* src 2>/dev/null

# loader와 hydration 위험 검사
rg -n "loader:|beforeLoad:|Date\.now\(|Math\.random\(|localStorage|window\." src/routes src/components 2>/dev/null

# per-request env 규칙: edge SSR runtime에서 module scope process.env 읽기는 틀림
rg -n "^\s*(const|let|var|export const)\s+\w+\s*=\s*process\.env\." src 2>/dev/null

# v1 업그레이드 표면: 제거된 API와 Vite 8 / Node 22.12 하한
rg -n "nitro-v2-vite-plugin|useSession|inputValidator" src vite.config.* package.json 2>/dev/null
rg -n '"(vite|node)"' package.json 2>/dev/null

# env validation을 손대거나 scaffold할 때의 env 설정 검사
test ! -d src/env
test ! -f src/env.ts
test -f src/config/env.ts
rg -n "@t3-oss/env-core|createEnv" src/config/env.ts
rg -n "clientPrefix: ['\"]VITE_|runtimeEnvStrict|runtimeEnv|emptyStringAsUndefined|isServer" src/config/env.ts
rg -n "VITE_.*(SECRET|TOKEN|PASSWORD|DATABASE_URL|PRIVATE)" src/config/env.ts .env* 2>/dev/null
```

grep 결과만으로 판단하지 말고 topic rule file과 함께 해석합니다.

## Skill Anatomy Validation

이 스킬 자체를 수정한 경우:

```bash
find skills/hyper-architecture -maxdepth 3 -type f | sort
wc -l skills/hyper-architecture/stacks/tanstack-start/core.md skills/hyper-architecture/stacks/tanstack-start/core.ko.md
rg -n 'architecture-rules|rules/tanstack-start/|references/official/tanstack-start' skills/hyper-architecture/stacks/tanstack-start/core.md
# snapshot metadata grep: `last_verified_at` 필드 모양을 검사하고 특정 날짜를 박지 않아, snapshot을 새로 받아도 이 검사가 조용히 깨지지 않습니다
rg -n 'last_verified_at: [0-9]{4}-[0-9]{2}-[0-9]{2}|checked_at|@tanstack/react-start|@tanstack/react-router|source_priority|inputValidator|validator|importProtection|createServerOnlyFn|createMiddleware|createHandlers|excludeFiles' skills/hyper-architecture/references/official/tanstack-start
rg -n 'Official|Safety policy|Hypercore convention|publishing-only|Zod v4|enabled by default|server\.handlers|createHandlers|behavior: '\''error'\''|Type-only imports' skills/hyper-architecture/rules/tanstack-start skills/hyper-architecture/stacks/tanstack-start/architecture-rules.md
rg -n 'functions\.ts|server\.ts|same-origin|CSRF|dynamic import|mixed barrel|routeFileIgnorePrefix|src/modules/<domain>|src/db/<domain>|src/integrations/<provider>' skills/hyper-architecture
rg -n 'src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: "VITE_"|runtimeEnvStrict|emptyStringAsUndefined|Do not create `src/env/`' skills/hyper-architecture/rules/tanstack-start/platform.md
rg -n 'src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: "VITE_"|runtimeEnvStrict|emptyStringAsUndefined|`src/env/`' skills/hyper-architecture/rules/tanstack-start/platform.ko.md
rg -n 'project-structure|src/routes|routeTree.gen|routesDirectory|src/modules|src/lib|src/integrations|direct leaf|repo-local convention' skills/hyper-architecture
rg -n '@rules/project-structure.md|@rules/project-structure.ko.md' skills/hyper-architecture/stacks/tanstack-start/core.md skills/hyper-architecture/stacks/tanstack-start/core.ko.md
# 고아 방지: rules/tanstack-start/conventions.md가 진입점과 주제 색인에서 직접 link된 상태를 유지해야 합니다
rg -n 'conventions(\.ko)?\.md' skills/hyper-architecture/stacks/tanstack-start/core.md skills/hyper-architecture/stacks/tanstack-start/core.ko.md skills/hyper-architecture/stacks/tanstack-start/architecture-rules.md
```

Must pass:

- `stacks/tanstack-start/core.md`와 `stacks/tanstack-start/core.ko.md`가 duplicated rulebook이 아니라 lean entrypoint임.
- core에서 참조하는 support file은 직접 링크되어 있고 indirect reference chain이 없음.
- 공식 TanStack 사실은 긴 core section이 아니라 `references/official/tanstack-start/`에 있음.
- current official snapshot `references/official/tanstack-start/current-docs-2026-11-04.ko.md`는 `stacks/tanstack-start/core.ko.md`에서 직접 link되며 API drift가 중요할 때 사용됨.
- hypercore-only convention이 그렇게 label됨.
- `rules/tanstack-start/project-structure.md`와 `rules/tanstack-start/project-structure.ko.md`가 존재하고 직접 링크됨.
- project-structure guidance가 `src/routes`, custom `routesDirectory`, generated `routeTree.gen.ts`, shared nested folders, touched shared root direct leaf file 금지, route-local/shared server function placement를 다룸.
- server-function-heavy guidance가 `.functions.ts` wrapper, `.server.ts` helper, static direct imports, no mixed barrels, auth/CSRF boundary를 다룸.
- `src/modules`, `src/lib`, `src/integrations` 같은 shared nested folders는 official TanStack law가 아니라 Hypercore/repo-local convention으로 label됨.
- publishing-only route exception과 hook extraction rule이 모순되지 않음.
- search validation guidance가 Zod v4 direct schema와 Zod v3 adapter를 다루고, peer 범위가 Zod 4를 제외하므로 Zod 4에서는 adapter를 차단함.
- import protection guidance가 default 존재, custom deny 필요 시 explicit config, option surface가 experimental이 아니라 문서화되었다는 점을 설명함.
- Middleware guidance가 request middleware `createMiddleware()`, server function middleware `createMiddleware({ type: 'function' })`, middleware `.validator(...)`, server function `.validator(...)`를 구분하며, 두 체인 모두에서 `.validator(...)`가 유일한 표기이며 `.inputValidator(...)`는 1.169.0에서 제거됨.
- Server route guidance가 `server.handlers`, `createHandlers`, route-level `server.middleware`, duplicate method collision checks, wildcard/splat route notes를 포함함.
- Import protection guidance가 type-only import behavior, `behavior: 'error'`, `excludeFiles`, diagnostic/scoping options를 포함함.
- env validation guidance가 `src/config/env.ts`를 사용하고, 새 `src/env/` scaffold를 금지하며, `@t3-oss/env-core` / Vite public-prefix boundary를 설명함.
- Deprecated feature-folder guidance가 이 스킬에 없음.
- English/Korean entrypoint의 trigger, boundary, workflow, read order가 일치함.

## Trigger Tests

Positive:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "TanStack Start 프로젝트에서 loader 경계랑 server function 구조 점검해줘."
- "TanStack Start folder structure를 검토하고 nested `src/modules` / `src/lib` grouping을 강제해줘."
- "TanStack Start에서 `src/modules/billing/invoices`와 `src/routes/billing` 구조가 맞는지 봐줘."
- "src/lib/utils.ts 말고 src/lib/auth/session.ts처럼 논리 폴더로 묶어줘."
- "TanStack Start server functions를 `src/modules/billing/invoices/invoices.functions.ts`와 `.server.ts`로 정리해줘."

Negative:

- "TanStack Start가 아닌 일반 React/Vite 앱을 리뷰해줘."
- "Codex용 browser QA skill을 새로 만들어줘."

Boundary:

- "정적인 TanStack Start privacy page의 카피만 바꿔줘."
  Expected: 빠른 boundary check만 수행하고 빈 route-local folder를 강제하지 않음.

## Completion Checklist

- [ ] project validation으로 이 스킬 적용 여부를 확인하거나 route-away함.
- [ ] 필요한 rule/reference file만 읽음.
- [ ] 적용 규칙을 Official, Safety policy, Hypercore convention으로 분류함.
- [ ] blocking safety gate를 style convention보다 먼저 수정함.
- [ ] env scaffold를 건드렸다면 `src/config/env.ts`를 사용하고 `src/env/`를 만들지 않음.
- [ ] broad migration은 요청 없으면 피함.
- [ ] verification command를 실행하고 결과를 읽음.
- [ ] server function wrapper/helper split, static imports, auth/CSRF boundary, no mixed barrels를 확인함.
- [ ] 남은 risk 또는 TanStack API ambiguity가 정확한 source/date를 인용함.

## Sources

> 출처 확인 2026-11-04: <https://tanstack.com/start/latest/docs/framework/react/migrate-from-release-candidate.md>(삭제된 API, Vite 8), <https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables.md>(request 단위 env 읽기), <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>(문서화된 option 표면), <https://registry.npmjs.org/@tanstack/react-start/latest>(Node engine 하한). 그 밖의 공식 TanStack 동작은 이 패키지 자체의 snapshot(`references/official/tanstack-start/tanstack-start-2026-11-04.md`, `references/official/tanstack-start/tanstack-router-2026-11-04.md`, `references/official/tanstack-start/current-docs-2026-11-04.md`)에 위임합니다. 공식 사실 검증 2026-11-04. 저장소 로컬 링크 확인 2026-11-04.
