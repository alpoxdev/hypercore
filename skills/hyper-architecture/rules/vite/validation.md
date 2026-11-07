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

# Query prefetch API and Vite 8 bundler names
rg -n 'ensureQueryData|fetchQuery|prefetchQuery|queryClient\.query' src 2>/dev/null
rg -n 'esbuild|rollupOptions|manualChunks|rolldownOptions|codeSplitting|oxc' vite.config.* 2>/dev/null

# Layer and runtime-boundary checks
rg -n 'fetch\(|axios\.|import\.meta\.env\.(?!VITE_)|process\.env|DB_|DATABASE_URL|SECRET|TOKEN|PASSWORD|fs\b|@prisma/client|drizzle-orm' src/routes src/hooks src/services src/lib 2>/dev/null

# Shared nested folder checks
find src/lib src/services lib services -maxdepth 2 -type f 2>/dev/null
rg -n 'src/lib|src/services|direct leaf|explicit project exception' skills/hyper-architecture/stacks/vite/architecture-rules.md skills/hyper-architecture/rules/vite/services.md 2>/dev/null

# Platform checks
rg -n 'tanstackRouter|@tanstack/router-plugin/vite|@vitejs/plugin-react|react\(|routeTree\.gen|createRouter|RouterProvider|ImportMetaEnv|vite/client|loadEnv|resolve:\s*\{' vite.config.* tsr.config.json src/router.tsx src/main.tsx src/vite-env.d.ts 2>/dev/null
```

Interpret grep output with the relevant topic rule files; grep output alone is not a verdict.

## Skill Anatomy Validation

For edits to this skill itself:

```bash
find skills/hyper-architecture -maxdepth 3 -type f | sort
wc -l skills/hyper-architecture/stacks/vite/core.md skills/hyper-architecture/stacks/vite/core.ko.md
rg -n 'instruction_contract|activation_examples|routing_rule|rules/vite/validation|current-docs-2026-11-04' skills/hyper-architecture/stacks/vite/core.md skills/hyper-architecture/stacks/vite/core.ko.md
rg -n 'checked_at|/websites/vite_dev|/tanstack/router|VITE_|loadEnv|tanstackRouter|routeTree.gen|validateSearch|zodValidator|queryClient\.query' skills/hyper-architecture/references/official/vite
rg -n 'src/lib|src/services|direct leaf|repo-local convention|not official Vite|not official.*TanStack Router' skills/hyper-architecture/stacks/vite/architecture-rules.md skills/hyper-architecture/rules/vite/services.md skills/hyper-architecture/rules/vite/validation.md
bash skills/hyper-architecture/scripts/validate-vite-stack.sh
```

Must pass:

- `stacks/vite/core.md` and `stacks/vite/core.ko.md` include routing, instruction contract, activation examples, workflow, verification, and stop condition.
- Support files referenced from the core are directly linked; there is no indirect reference chain.
- Official Vite and TanStack Router facts live in `references/official/vite/`, not in long core sections.
- Current official snapshot `references/official/vite/current-docs-2026-11-04.md` is directly linked from `stacks/vite/core.md` and used when API drift matters.
- Hypercore/repo-local conventions are labelled as such.
- Shared nested folders such as `src/lib` and `src/services` are labelled as Hypercore/repo-local convention, not official Vite or TanStack Router law.
- New touched shared code avoids direct leaf files under `src/lib`, `src/services`, `lib`, or `services` unless an explicit exception is recorded.
- Deprecated feature-folder guidance is absent from this skill.
- Vite plugin order, generated route tree, env prefix, route export, search validation, loader safety, service layering, and the curated loader prefetch API guidance remain current-docs compatible.
- Deprecated TanStack Query prefetch helpers (`ensureQueryData`, `fetchQuery`, `prefetchQuery`) are named as deprecated, with `queryClient.query({ ...options, staleTime: 'static' })` as the replacement.
- Vite 8 config names (`oxc`, `build.rolldownOptions`, `output.codeSplitting`) are used when the file describes bundler options.
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
- "The repo actually uses @tanstack/react-start." Expected: a Start-boundary note that states this skill does not apply, names the Start-only surfaces, and enforces no Vite route rules.

---

## Sources

> This file's validation and readback commands are this package's own checks over project state and over the package itself. The official-snapshot reference they cite is `references/official/vite/current-docs-2026-11-04.md`, whose own verification date is 2026-11-04; no external source was used to author the commands and no page was re-fetched for this file. Command text and repository-local paths checked 2026-11-04.
