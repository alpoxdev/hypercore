# Validation and Readback

> Completion checks for Vite + TanStack Router architecture work and for this skill's own maintainability.

## Project Work Validation

Run checks appropriate to the touched surfaces:

```bash
# Project indicators and Start route-away
rg -n '"vite"|"@tanstack/react-router"|"@tanstack/router-plugin"|"@tanstack/react-start"' package.json
find . -maxdepth 2 \( -name 'vite.config.ts' -o -name 'vite.config.mts' -o -name 'app.config.ts' -o -name 'tsr.config.json' \)

# Route tree and route files
find src/routes -maxdepth 5 -type f \( -name 'index.tsx' -o -name 'route.tsx' -o -name '__root.tsx' \) 2>/dev/null
rg -n 'export const Route|const Route|createFileRoute|validateSearch|zodValidator|fallback|loader:' src/routes 2>/dev/null
rg -n 'createServerFn|useServerFn|createMiddleware|/-functions|/-components|/-hooks' src/routes src 2>/dev/null

# Layer and runtime-boundary checks
rg -n 'fetch\(|axios\.|import\.meta\.env\.(?!VITE_)|process\.env|DB_|DATABASE_URL|SECRET|TOKEN|PASSWORD|fs\b|@prisma/client|drizzle-orm' src/routes src/hooks src/services src/lib 2>/dev/null

# Shared nested folder checks
find src/lib src/services lib services -maxdepth 2 -type f 2>/dev/null
rg -n 'src/lib|src/services|direct leaf|explicit project exception' skills/vite-architecture/architecture-rules.md skills/vite-architecture/rules/services.md 2>/dev/null

# Platform checks
rg -n 'tanstackRouter|@tanstack/router-plugin/vite|@vitejs/plugin-react|react\(|routeTree\.gen|createRouter|RouterProvider|ImportMetaEnv|vite/client|loadEnv|resolve:\s*\{' vite.config.* tsr.config.json src/router.tsx src/main.tsx src/vite-env.d.ts 2>/dev/null
```

Interpret grep output with the relevant topic rule files; grep output alone is not a verdict.

## Skill Anatomy Validation

For edits to this skill itself:

```bash
find skills/vite-architecture -maxdepth 3 -type f | sort
wc -l skills/vite-architecture/SKILL.md skills/vite-architecture/SKILL.ko.md
rg -n 'instruction_contract|activation_examples|routing_rule|rules/validation|current-docs-2026-06-02' skills/vite-architecture/SKILL.md skills/vite-architecture/SKILL.ko.md
rg -n 'checked_at|/websites/vite_dev|/tanstack/router|VITE_|loadEnv|tanstackRouter|routeTree.gen|validateSearch|zodValidator' skills/vite-architecture/references/official
rg -n 'src/lib|src/services|direct leaf|repo-local convention|not official Vite|not official.*TanStack Router' skills/vite-architecture/architecture-rules.md skills/vite-architecture/rules/services.md skills/vite-architecture/rules/validation.md
node skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs
```

Must pass:

- `SKILL.md` and `SKILL.ko.md` include routing, instruction contract, activation examples, workflow, verification, and stop condition.
- Support files referenced from the core are directly linked; there is no indirect reference chain.
- Official Vite and TanStack Router facts live in `references/official/`, not in long core sections.
- Current official snapshot `references/official/current-docs-2026-06-02.md` is directly linked from `SKILL.md` and used when API drift matters.
- Hypercore/repo-local conventions are labelled as such.
- Shared nested folders such as `src/lib` and `src/services` are labelled as Hypercore/repo-local convention, not official Vite or TanStack Router law.
- New touched shared code avoids direct leaf files under `src/lib`, `src/services`, `lib`, or `services` unless an explicit exception is recorded.
- Deprecated feature-folder guidance is absent from this skill.
- Vite plugin order, generated route tree, env prefix, route export, search validation, loader safety, and service layering guidance remain current-docs compatible.
- English and Korean entrypoints have aligned trigger, boundary, workflow, contract, and read order.

## Trigger Tests

Positive examples that should trigger this skill:

- "Audit this Vite + TanStack Router app for route structure, validateSearch, and service boundaries before editing."
- "Add a new route folder in a Vite + TanStack Router app and keep hooks/services compliant."
- "Refactor a TanStack Router page so the UI stays in the route and logic moves into -hooks/."
- "Vite Router 프로젝트에서 tanstackRouter plugin order와 routeTree.gen.ts 처리를 점검해줘."
- "src/lib/utils.ts 말고 src/lib/auth/session.ts, src/services/billing/queries.ts처럼 nested folders로 묶어줘."

Negative examples that should not trigger this skill:

- "Create a new Codex skill for browser QA."
- "Review a TanStack Start app that uses createServerFn and @tanstack/react-start."
- "Review a generic Vite app that does not use TanStack Router."

Boundary examples:

- "Make a tiny copy-only text change in a Vite route file." Expected: quick boundary check only.
- "The repo actually uses @tanstack/react-start." Expected: route away to `tanstack-start-architecture`.
