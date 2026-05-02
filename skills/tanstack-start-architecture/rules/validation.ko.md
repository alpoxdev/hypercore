# Validation and Readback

> TanStack Start architecture 작업과 이 스킬 자체 유지보수 완료 검증.

## Project Work Validation

변경 표면에 맞는 check를 실행합니다:

```bash
rg -n "const Route = createFileRoute|export const Route" src/routes 2>/dev/null
rg -n "from ['\"]@/database|from ['\"].*/database|@prisma/client|drizzle-orm" src/routes 2>/dev/null
rg -n "\.validator\(|\.inputValidator\(|createServerFn" src 2>/dev/null
rg -n "server-only|client-only|\.server\.|\.client\.|importProtection|tanstackStart" vite.config.* src 2>/dev/null
rg -n "loader:|beforeLoad:|Date\.now\(|Math\.random\(|localStorage|window\." src/routes src/components 2>/dev/null
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
find skills/tanstack-start-architecture -maxdepth 3 -type f | sort
wc -l skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/SKILL.ko.md
rg -n "architecture-rules|rules/|references/official" skills/tanstack-start-architecture/SKILL.md
rg -n "last_verified_at|@tanstack/react-start|@tanstack/react-router|source_priority|validator" skills/tanstack-start-architecture/references/official
rg -n "Official|Safety policy|Hypercore convention|publishing-only|Zod v4|enabled by default" skills/tanstack-start-architecture/rules skills/tanstack-start-architecture/architecture-rules.md
rg -n "src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: \"VITE_\"|runtimeEnvStrict|emptyStringAsUndefined|Do not create `src/env/`" skills/tanstack-start-architecture/rules/platform.md
rg -n "src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: \"VITE_\"|runtimeEnvStrict|emptyStringAsUndefined|`src/env/`" skills/tanstack-start-architecture/rules/platform.ko.md
```

Must pass:

- `SKILL.md`와 `SKILL.ko.md`가 duplicated rulebook이 아니라 lean entrypoint임.
- core에서 참조하는 support file은 직접 링크되어 있고 indirect reference chain이 없음.
- 공식 TanStack 사실은 긴 core section이 아니라 `references/official/`에 있음.
- hypercore-only convention이 그렇게 label됨.
- publishing-only route exception과 hook extraction rule이 모순되지 않음.
- search validation guidance가 Zod v4 direct schema와 Zod v3 adapter를 모두 다룸.
- import protection guidance가 default 존재와 custom deny 필요 시 explicit config를 모두 설명함.
- env validation guidance가 `src/config/env.ts`를 사용하고, 새 `src/env/` scaffold를 금지하며, `@t3-oss/env-core` / Vite public-prefix boundary를 설명함.
- English/Korean entrypoint의 trigger, boundary, workflow, read order가 일치함.

## Trigger Tests

Positive:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "TanStack Start 프로젝트에서 loader 경계랑 server function 구조 점검해줘."

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
- [ ] 남은 risk 또는 TanStack API ambiguity가 정확한 source/date를 인용함.
