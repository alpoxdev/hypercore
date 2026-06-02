# Validation and Readback

> Next.js architecture 작업과 이 skill 자체 유지보수 완료 검증.

## Project Work Validation

변경 표면에 맞는 check를 실행합니다:

```bash
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)
find app src/app -maxdepth 5 -type f \( -name 'page.tsx' -o -name 'route.ts' -o -name 'layout.tsx' -o -name 'loading.tsx' -o -name 'error.tsx' \) 2>/dev/null
rg -n "^['\"]use client['\"]|server-only|client-only|cookies\(|headers\(|process\.env|NEXT_PUBLIC_" app src/app src/components src/lib src/services 2>/dev/null
rg -n "cacheComponents|use cache|cacheTag|cacheLife|connection\(|updateTag|revalidateTag|revalidatePath|refresh\(|redirect\(" next.config.* app src/app src/lib src/services 2>/dev/null
rg -n "export async function (GET|POST|PUT|PATCH|DELETE)|NextResponse\.next\(|RouteContext" app src/app 2>/dev/null
find . -maxdepth 2 \( -name 'proxy.ts' -o -name 'middleware.ts' -o -name 'middleware.js' \)
rg -n "NEXT_PUBLIC_.*(SECRET|TOKEN|PASSWORD|DATABASE_URL|PRIVATE)|process\.env\.(?!NEXT_PUBLIC_)" app src/app src/components 2>/dev/null
```

grep 결과만으로 판단하지 말고 relevant topic rules와 함께 해석합니다.

## Skill Anatomy Validation

이 skill 자체를 수정한 경우:

```bash
find skills/nextjs-architecture -maxdepth 3 -type f | sort
wc -l skills/nextjs-architecture/SKILL.md skills/nextjs-architecture/SKILL.ko.md
rg -n 'instruction_contract|activation_examples|routing_rule|rules/validation|current-docs-2026-06-02' skills/nextjs-architecture/SKILL.md skills/nextjs-architecture/SKILL.ko.md
rg -n 'checked_at|Next.js 16|cacheComponents|use cache: remote|proxy.ts|middleware|NEXT_PUBLIC|Server Actions|Route Handlers' skills/nextjs-architecture/references/official
rg -n 'src/lib|src/services|direct leaf|repo-local convention|not official Next.js requirement' skills/nextjs-architecture/rules/project-structure.md skills/nextjs-architecture/rules/project-structure.ko.md
rg -n 'Deprecated feature-folder guidance is absent|src/services|direct leaf|current-docs-2026-06-02' skills/nextjs-architecture/rules/validation.md skills/nextjs-architecture/rules/validation.ko.md
node skills/nextjs-architecture/scripts/validate-nextjs-architecture-skill.mjs
```

Must pass:

- `SKILL.md`와 `SKILL.ko.md`가 routing, instruction contract, activation examples, workflow, verification, stop condition을 포함함.
- core에서 참조하는 support file은 직접 link되어 있고 indirect reference chain이 없음.
- official Next.js facts는 긴 core section이 아니라 `references/official/`에 있음.
- current official snapshot `references/official/current-docs-2026-06-02.ko.md`는 `SKILL.ko.md`에서 직접 link되며 API drift가 중요할 때 사용됨.
- Hypercore/repo-local conventions가 그렇게 label됨.
- project-structure guidance가 `app`, `src/app`, `pages`, `src/pages`, private folders, shared nested folders, touched shared root direct leaf file 금지를 다룸.
- `src/lib`, `src/services` 같은 shared nested folders는 official Next.js law가 아니라 Hypercore/repo-local convention으로 label됨.
- Deprecated feature-folder guidance is absent from this skill.
- Cache Components, Server Actions, Route Handlers, Proxy, env, Server/Client boundary guidance가 current-docs compatible함.
- English/Korean entrypoint의 trigger, boundary, workflow, contract, read order가 일치함.
