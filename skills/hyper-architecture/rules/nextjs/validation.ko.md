# Validation and Readback

> Next.js architecture 작업과 이 skill 자체 유지보수 완료 검증.

## Project Work Validation

변경 표면에 맞는 check를 실행합니다:

```bash
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)
find app src/app -maxdepth 5 -type f \( -name 'page.tsx' -o -name 'route.ts' -o -name 'layout.tsx' -o -name 'loading.tsx' -o -name 'error.tsx' \) 2>/dev/null
rg -n "^['\"]use client['\"]|server-only|client-only|cookies\(|headers\(|process\.env|NEXT_PUBLIC_" app src/app src/components src/lib src/services 2>/dev/null
rg -n "cacheComponents|partialPrefetching|use cache|cacheTag|cacheLife|io\(|connection\(|navigation\(|prefetch\(|ensureStatic|instant|updateTag|revalidateTag|revalidatePath|refresh\(|redirect\(" next.config.* app src/app src/lib src/services 2>/dev/null
rg -n "export const runtime|export const ensureStatic|export const instant|export const prefetch" app src/app 2>/dev/null
rg -n "export async function (GET|POST|PUT|PATCH|DELETE)|NextResponse\.next\(|RouteContext" app src/app 2>/dev/null
rg -n "drizzle|drizzle.config|schema|migrate|push|pull|check|prepared|relations|RQB" drizzle.config.* src/db db src/modules src/services 2>/dev/null
find . -maxdepth 2 \( -name 'proxy.ts' -o -name 'middleware.ts' -o -name 'middleware.js' \)
rg -n "NEXT_PUBLIC_.*(SECRET|TOKEN|PASSWORD|DATABASE_URL|PRIVATE)|process\.env\.(?!NEXT_PUBLIC_)" app src/app src/components 2>/dev/null
```

grep 결과만으로 판단하지 말고 relevant topic rules와 함께 해석합니다.

## Skill Anatomy Validation

이 skill 자체를 수정한 경우:

```bash
find skills/hyper-architecture -maxdepth 3 -type f | sort
wc -l skills/hyper-architecture/stacks/nextjs/core.md skills/hyper-architecture/stacks/nextjs/core.ko.md
rg -n 'instruction_contract|activation_examples|routing_rule|rules/nextjs/validation|current-docs-2026-11-04' skills/hyper-architecture/stacks/nextjs/core.md skills/hyper-architecture/stacks/nextjs/core.ko.md
rg -n 'rules/nextjs/services|rules/nextjs/hooks|rules/nextjs/db|drizzle-docs' skills/hyper-architecture/stacks/nextjs/core.md skills/hyper-architecture/stacks/nextjs/core.ko.md
rg -n 'checked_at|Next.js 16|cacheComponents|use cache: remote|proxy.ts|middleware|NEXT_PUBLIC|Server Actions|Route Handlers|Drizzle schema|drizzle.config.ts|drizzle-kit generate|RQB' skills/hyper-architecture/references/official/nextjs
rg -n 'src/modules|src/lib|src/services|src/db|src/server|src/integrations|src/config|direct leaf|Hypercore local convention|not official Next.js requirement' skills/hyper-architecture/rules/nextjs/project-structure.md skills/hyper-architecture/rules/nextjs/project-structure.ko.md
rg -n 'DAL|DTO|server-only service|provider|authorization' skills/hyper-architecture/rules/nextjs/services.md skills/hyper-architecture/rules/nextjs/services.ko.md
rg -n 'client orchestration|hooks|server/data layers|Drizzle schema|private env' skills/hyper-architecture/rules/nextjs/hooks.md skills/hyper-architecture/rules/nextjs/hooks.ko.md
rg -n 'Drizzle schema|drizzle.config.ts|generate|migrate|prepared statements|validation integrations|RQB' skills/hyper-architecture/rules/nextjs/db.md skills/hyper-architecture/rules/nextjs/db.ko.md
rg -n 'Deprecated feature-folder guidance is absent|src/services|src/modules|src/db|direct leaf|current-docs-2026-11-04|Korean parity|source-only|no adapter' skills/hyper-architecture/rules/nextjs/validation.md skills/hyper-architecture/rules/nextjs/validation.ko.md
bash skills/hyper-architecture/scripts/validate-nextjs-stack.sh
```

Must pass:

- `stacks/nextjs/core.md`와 `stacks/nextjs/core.ko.md`가 routing, instruction contract, activation examples, workflow, verification, stop condition을 포함함.
- core에서 참조하는 support file은 직접 link되어 있고 indirect reference chain이 없음.
- official Next.js facts는 긴 core section이 아니라 `references/official/nextjs/`에 있음.
- current official snapshot `references/official/nextjs/current-docs-2026-11-04.ko.md`는 `stacks/nextjs/core.ko.md`에서 직접 link되며 API drift가 중요할 때 사용됨.
- Hypercore/repo-local conventions가 그렇게 label됨.
- project-structure guidance가 `app`, `src/app`, `pages`, `src/pages`, private folders, shared nested folders, touched shared root direct leaf file 금지를 다룸.
- `src/modules`, `src/lib`, `src/services`, `src/db`, `src/server`, `src/integrations`, `src/config` 같은 shared nested folders는 official Next.js law가 아니라 Hypercore/repo-local convention으로 label됨.
- services guidance가 DAL/service/provider boundaries, DTO, authorization delegation, server-only helper splits를 다룸.
- hooks guidance가 Next.js client orchestration boundaries를 다루고 hooks가 server/data layers를 넘으면 안 된다고 명시함.
- DB guidance가 Drizzle schema/config/migrations, connection lifecycle, prepared statements, RQB relations/tables at `drizzle()` init, validation integrations를 다룸.
- Official Drizzle facts는 긴 core section이 아니라 `references/official/nextjs/drizzle-docs.md`와 `.ko.md`에 있음.
- Deprecated feature-folder guidance is absent from this skill.
- Cache Components, Server Actions, Route Handlers, Proxy, env, Server/Client boundary guidance가 current-docs compatible함.
- `cacheComponents`와 `partialPrefetching` 조합, `connection()`보다 `io()`를 우선하는 규칙, `runtime` export 제거가 Cache Components를 설명하는 곳마다 함께 적혀 있음.
- English/Korean entrypoint의 trigger, boundary, workflow, contract, read order가 일치함.
- English/Korean sibling files는 structurally and semantically aligned됨. Korean parity checks는 services/hooks/db/Drizzle phrases를 포함함.
- 이 skill은 `skills/hyper-architecture`에서 source-only로 검증하며 plugin mirror, symlink, adapter contract가 없습니다.

## Readback Evidence

completion을 보고하기 전에 다음을 기록합니다:

- 검증하는 scenario name과 claim
- exact invocation
- exit code, missing-file count, diff result, validator JSON 같은 binary observable
- captured artifact path

이 skill folder 변경에서는 edit 후 changed English/Korean sibling files를 read back하고 links, headings, rule responsibilities가 맞는지 확인합니다. canonical source files만 검증하며 plugin mirror, symlink, adapter 동기화는 필요하지 않습니다.

## Sources

> 이 파일에는 외부 출처를 사용하지 않았습니다. 저장소 로컬 명령과 readback 절차만 다룹니다. 프레임워크 사실은 `rules/nextjs/` 아래 topic rule 파일과 `references/official/nextjs/`에 있습니다. 저장소 로컬 링크 확인 2026-11-04.
