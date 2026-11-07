# Validation and Readback

> Completion checks for TanStack Start architecture work and for this skill's own maintainability.

## Project Work Validation

Run checks appropriate to the touched surfaces:

```bash
# Route export and direct DB access checks
rg -n "const Route = createFileRoute|export const Route" src/routes 2>/dev/null
rg -n "from ['\"]@/database|from ['\"].*/database|@prisma/client|drizzle-orm" src/routes 2>/dev/null

# Server function validation and stale API checks
# Detection grep: keep BOTH spellings. `.inputValidator(` was removed in 1.169.0, so a hit is broken code, not legacy style
rg -n "\.validator\(|\.inputValidator\(|createServerFn" src 2>/dev/null

# Import boundary checks
rg -n "server-only|client-only|\.server\.|\.client\.|importProtection|tanstackStart" vite.config.* src 2>/dev/null

# Loader and hydration risk checks
rg -n "loader:|beforeLoad:|Date\.now\(|Math\.random\(|localStorage|window\." src/routes src/components 2>/dev/null

# Per-request env rule: module-scope process.env reads are wrong on edge SSR runtimes
rg -n "^\s*(const|let|var|export const)\s+\w+\s*=\s*process\.env\." src 2>/dev/null

# v1 upgrade surface: removed APIs and the Vite 8 / Node 22.12 floors
rg -n "nitro-v2-vite-plugin|useSession|inputValidator" src vite.config.* package.json 2>/dev/null
rg -n '"(vite|node)"' package.json 2>/dev/null

# Env config checks when env validation is touched or scaffolded
test ! -d src/env
test ! -f src/env.ts
test -f src/config/env.ts
rg -n "@t3-oss/env-core|createEnv" src/config/env.ts
rg -n "clientPrefix: ['\"]VITE_|runtimeEnvStrict|runtimeEnv|emptyStringAsUndefined|isServer" src/config/env.ts
rg -n "VITE_.*(SECRET|TOKEN|PASSWORD|DATABASE_URL|PRIVATE)" src/config/env.ts .env* 2>/dev/null
```

Interpret results with the topic rule files; grep output alone is not a verdict.

## Skill Anatomy Validation

For edits to this skill itself:

```bash
find skills/hyper-architecture -maxdepth 3 -type f | sort
wc -l skills/hyper-architecture/stacks/tanstack-start/core.md skills/hyper-architecture/stacks/tanstack-start/core.ko.md
rg -n 'architecture-rules|rules/tanstack-start/|references/official/tanstack-start' skills/hyper-architecture/stacks/tanstack-start/core.md
# Snapshot metadata grep: match the `last_verified_at` field shape, never a specific date, so a snapshot refresh cannot silently break this check
rg -n 'last_verified_at: [0-9]{4}-[0-9]{2}-[0-9]{2}|checked_at|@tanstack/react-start|@tanstack/react-router|source_priority|inputValidator|validator|importProtection|createServerOnlyFn|createMiddleware|createHandlers|excludeFiles' skills/hyper-architecture/references/official/tanstack-start
rg -n 'Official|Safety policy|Hypercore convention|publishing-only|Zod v4|enabled by default|server\.handlers|createHandlers|behavior: '\''error'\''|Type-only imports' skills/hyper-architecture/rules/tanstack-start skills/hyper-architecture/stacks/tanstack-start/architecture-rules.md
rg -n 'functions\.ts|server\.ts|same-origin|CSRF|dynamic import|mixed barrel|routeFileIgnorePrefix|src/modules/<domain>|src/db/<domain>|src/integrations/<provider>' skills/hyper-architecture
rg -n 'src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: "VITE_"|runtimeEnvStrict|emptyStringAsUndefined|Do not create `src/env/`' skills/hyper-architecture/rules/tanstack-start/platform.md
rg -n 'src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: "VITE_"|runtimeEnvStrict|emptyStringAsUndefined|`src/env/`' skills/hyper-architecture/rules/tanstack-start/platform.ko.md
rg -n 'project-structure|src/routes|routeTree.gen|routesDirectory|src/modules|src/lib|src/integrations|direct leaf|repo-local convention' skills/hyper-architecture
rg -n '@rules/project-structure.md|@rules/project-structure.ko.md' skills/hyper-architecture/stacks/tanstack-start/core.md skills/hyper-architecture/stacks/tanstack-start/core.ko.md
# Orphan guard: rules/tanstack-start/conventions.md must stay directly linked from an entrypoint and the topic index
rg -n 'conventions(\.ko)?\.md' skills/hyper-architecture/stacks/tanstack-start/core.md skills/hyper-architecture/stacks/tanstack-start/core.ko.md skills/hyper-architecture/stacks/tanstack-start/architecture-rules.md
```

Must pass:

- `stacks/tanstack-start/core.md` and `stacks/tanstack-start/core.ko.md` are lean entrypoints, not duplicated rulebooks.
- Support files referenced from the core are directly linked; there is no indirect reference chain.
- Official TanStack facts live in `references/official/tanstack-start/`, not in long core sections.
- Current official snapshot `references/official/tanstack-start/current-docs-2026-11-04.md` is directly linked from `stacks/tanstack-start/core.md` and used when API drift matters.
- Hypercore-only conventions are labelled as such.
- `rules/tanstack-start/project-structure.md` and `rules/tanstack-start/project-structure.ko.md` exist and are directly linked.
- Project-structure guidance handles `src/routes`, custom `routesDirectory`, generated `routeTree.gen.ts`, shared nested folders, no-new-direct-leaf-files under touched shared roots, and route-local/shared server function placement.
- Server-function-heavy guidance covers `.functions.ts` wrappers, `.server.ts` helpers, static direct imports, no mixed barrels, and auth/CSRF boundaries.
- Shared nested folders such as `src/modules`, `src/lib`, and `src/integrations` are labelled as Hypercore/repo-local convention, not official TanStack law.
- Publishing-only route exception and hook extraction rules/tanstack-start do not contradict each other.
- Search validation guidance handles Zod v4 direct schemas and Zod v3 adapter usage, and blocks the adapter on Zod 4 because its peer range excludes it.
- Import protection guidance says defaults exist, custom config is required when custom deny rules/tanstack-start are needed, and the option surface is documented rather than experimental.
- Middleware guidance distinguishes request middleware `createMiddleware()`, server function middleware `createMiddleware({ type: 'function' })`, middleware `.validator(...)`, and server function `.validator(...)`; `.validator(...)` is the only spelling in both chains because `.inputValidator(...)` was removed in 1.169.0.
- Server route guidance includes `server.handlers`, `createHandlers`, route-level `server.middleware`, duplicate method collision checks, and wildcard/splat route notes.
- Import protection guidance includes type-only import behavior, `behavior: 'error'`, `excludeFiles`, and diagnostic/scoping options.
- Env validation guidance uses `src/config/env.ts`, forbids new `src/env/` scaffolds, and describes `@t3-oss/env-core` / Vite public-prefix boundaries.
- Deprecated feature-folder guidance is absent from this skill.
- English and Korean entrypoints have aligned trigger, boundary, workflow, and read order.

## Trigger Tests

Positive examples that should trigger this skill:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "Check the loader boundaries and server function structure in this TanStack Start project."
- "Review this TanStack Start folder structure and enforce nested `src/modules` / `src/lib` grouping."
- "Check whether `src/modules/billing/invoices` and `src/routes/billing` are organized correctly in TanStack Start."
- "src/lib/utils.ts 말고 src/lib/auth/session.ts처럼 논리 폴더로 묶어줘."
- "Organize TanStack Start server functions under `src/modules/billing/invoices/invoices.functions.ts` and `.server.ts`."

Negative examples that should not trigger this skill:

- "Review this generic React/Vite app that does not use TanStack Start."
- "Create a browser QA skill for Codex."

Boundary example:

- "Make a copy-only edit in a static TanStack Start privacy page."
  Expected: quick boundary check only; do not force empty route-local folders.

## Completion Checklist

- [ ] Project validation confirmed this skill applies, or route-away happened.
- [ ] Only relevant rule/reference files were loaded.
- [ ] Applicable rules/tanstack-start were classified as Official, Safety policy, or Hypercore convention.
- [ ] Blocking safety gates were fixed before style conventions.
- [ ] Env scaffolds, when touched, use `src/config/env.ts` and do not create `src/env/`.
- [ ] Broad migrations were avoided unless requested.
- [ ] Verification commands were run and read.
- [ ] Server function wrapper/helper split, static imports, auth/CSRF boundary, and no mixed barrels were checked.
- [ ] Remaining risks or TanStack API ambiguities cite exact sources and dates.

## Sources

> Sources checked 2026-11-04: <https://tanstack.com/start/latest/docs/framework/react/migrate-from-release-candidate.md> (removed APIs, Vite 8), <https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables.md> (per-request env reads), <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md> (documented option surface), <https://registry.npmjs.org/@tanstack/react-start/latest> (Node engine floor). Official TanStack behavior is otherwise delegated to this package's own snapshots: `references/official/tanstack-start/tanstack-start-2026-11-04.md`, `references/official/tanstack-start/tanstack-router-2026-11-04.md`, and `references/official/tanstack-start/current-docs-2026-11-04.md` (official facts verified 2026-11-04). Repository-local links checked 2026-11-04.
