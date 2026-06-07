# Validation and Readback

> Vite + TanStack Router architecture 작업과 이 skill 자체 유지보수 완료 검증.

## Project Work Validation

변경 표면에 맞는 check를 실행합니다:

```bash
rg -n '"vite"|"@tanstack/react-router"|"@tanstack/router-plugin"|"@tanstack/react-start"' package.json
find . -maxdepth 2 \( -name 'vite.config.ts' -o -name 'vite.config.mts' -o -name 'app.config.ts' -o -name 'tsr.config.json' \)
find src/routes -maxdepth 5 -type f \( -name 'index.tsx' -o -name 'route.tsx' -o -name '__root.tsx' \) 2>/dev/null
rg -n 'export const Route|const Route|createFileRoute|validateSearch|zodValidator|fallback|loader:' src/routes 2>/dev/null
rg -n 'createServerFn|useServerFn|createMiddleware|/-functions|/-components|/-hooks' src/routes src 2>/dev/null
rg -n 'fetch\(|axios\.|import\.meta\.env\.(?!VITE_)|process\.env|DB_|DATABASE_URL|SECRET|TOKEN|PASSWORD|fs\b|@prisma/client|drizzle-orm' src/routes src/hooks src/services src/lib 2>/dev/null
find src/lib src/services lib services -maxdepth 2 -type f 2>/dev/null
rg -n 'src/lib|src/services|direct leaf|explicit project exception' skills/vite-architecture/architecture-rules.md skills/vite-architecture/rules/services.md 2>/dev/null
rg -n 'tanstackRouter|@tanstack/router-plugin/vite|@vitejs/plugin-react|react\(|routeTree\.gen|createRouter|RouterProvider|ImportMetaEnv|vite/client|loadEnv|resolve:\s*\{' vite.config.* tsr.config.json src/router.tsx src/main.tsx src/vite-env.d.ts 2>/dev/null
```

grep 결과만으로 판단하지 말고 relevant topic rule files와 함께 해석합니다.

## Skill Anatomy Validation

이 skill 자체를 수정한 경우:

```bash
find skills/vite-architecture -maxdepth 3 -type f | sort
wc -l skills/vite-architecture/SKILL.md skills/vite-architecture/SKILL.ko.md
rg -n 'instruction_contract|activation_examples|routing_rule|rules/validation|current-docs-2026-06-02' skills/vite-architecture/SKILL.md skills/vite-architecture/SKILL.ko.md
rg -n 'checked_at|/websites/vite_dev|/tanstack/router|VITE_|loadEnv|tanstackRouter|routeTree.gen|validateSearch|zodValidator' skills/vite-architecture/references/official
rg -n 'src/lib|src/services|direct leaf|repo-local convention|not official Vite|not official.*TanStack Router' skills/vite-architecture/architecture-rules.md skills/vite-architecture/rules/services.md skills/vite-architecture/rules/validation.md
node skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs
```

Must pass:

- `SKILL.md`와 `SKILL.ko.md`가 routing, instruction contract, activation examples, workflow, verification, stop condition을 포함함.
- core에서 참조하는 support file은 직접 link되어 있고 indirect reference chain이 없음.
- official Vite/TanStack Router facts는 긴 core section이 아니라 `references/official/`에 있음.
- current official snapshot `references/official/current-docs-2026-06-02.ko.md`는 `SKILL.ko.md`에서 직접 link되며 API drift가 중요할 때 사용됨.
- Hypercore/repo-local conventions가 그렇게 label됨.
- `src/lib`, `src/services` 같은 shared nested folders는 official Vite 또는 TanStack Router law가 아니라 Hypercore/repo-local convention으로 label됨.
- 새 touched shared code는 explicit exception이 없는 한 `src/lib`, `src/services`, `lib`, `services` 바로 아래 direct leaf file을 만들지 않음.
- Deprecated feature-folder guidance is absent from this skill.
- Vite plugin order, generated route tree, env prefix, route export, search validation, loader safety, service layering guidance가 current-docs compatible함.
- English/Korean entrypoint의 trigger, boundary, workflow, contract, read order가 일치함.
