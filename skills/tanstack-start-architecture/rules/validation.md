# Validation and Readback

> Completion checks for TanStack Start architecture work and for this skill's own maintainability.

## Project Work Validation

Run checks appropriate to the touched surfaces:

```bash
# Route export and direct DB access checks
rg -n "const Route = createFileRoute|export const Route" src/routes 2>/dev/null
rg -n "from ['\"]@/database|from ['\"].*/database|@prisma/client|drizzle-orm" src/routes 2>/dev/null

# Server function validation and stale API checks
rg -n "\.validator\(|\.inputValidator\(|createServerFn" src 2>/dev/null

# Import boundary checks
rg -n "server-only|client-only|\.server\.|\.client\.|importProtection|tanstackStart" vite.config.* src 2>/dev/null

# Loader and hydration risk checks
rg -n "loader:|beforeLoad:|Date\.now\(|Math\.random\(|localStorage|window\." src/routes src/components 2>/dev/null

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
find skills/tanstack-start-architecture -maxdepth 3 -type f | sort
wc -l skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/SKILL.ko.md
rg -n "architecture-rules|rules/|references/official" skills/tanstack-start-architecture/SKILL.md
rg -n "last_verified_at|@tanstack/react-start|@tanstack/react-router|source_priority|validator" skills/tanstack-start-architecture/references/official
rg -n "Official|Safety policy|Hypercore convention|publishing-only|Zod v4|enabled by default" skills/tanstack-start-architecture/rules skills/tanstack-start-architecture/architecture-rules.md
rg -n "src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: \"VITE_\"|runtimeEnvStrict|emptyStringAsUndefined|Do not create `src/env/`" skills/tanstack-start-architecture/rules/platform.md
rg -n "src/config/env.ts|@t3-oss/env-core|createEnv|clientPrefix: \"VITE_\"|runtimeEnvStrict|emptyStringAsUndefined|`src/env/`" skills/tanstack-start-architecture/rules/platform.ko.md
```

Must pass:

- `SKILL.md` and `SKILL.ko.md` are lean entrypoints, not duplicated rulebooks.
- Support files referenced from the core are directly linked; there is no indirect reference chain.
- Official TanStack facts live in `references/official/`, not in long core sections.
- Hypercore-only conventions are labelled as such.
- Publishing-only route exception and hook extraction rules do not contradict each other.
- Search validation guidance handles both Zod v4 direct schemas and Zod v3 adapter usage.
- Import protection guidance says defaults exist and custom config is required when custom deny rules are needed.
- Env validation guidance uses `src/config/env.ts`, forbids new `src/env/` scaffolds, and describes `@t3-oss/env-core` / Vite public-prefix boundaries.
- English and Korean entrypoints have aligned trigger, boundary, workflow, and read order.

## Trigger Tests

Positive examples that should trigger this skill:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "Check the loader boundaries and server function structure in this TanStack Start project."

Negative examples that should not trigger this skill:

- "Review this generic React/Vite app that does not use TanStack Start."
- "Create a browser QA skill for Codex."

Boundary example:

- "Make a copy-only edit in a static TanStack Start privacy page."
  Expected: quick boundary check only; do not force empty route-local folders.

## Completion Checklist

- [ ] Project validation confirmed this skill applies, or route-away happened.
- [ ] Only relevant rule/reference files were loaded.
- [ ] Applicable rules were classified as Official, Safety policy, or Hypercore convention.
- [ ] Blocking safety gates were fixed before style conventions.
- [ ] Env scaffolds, when touched, use `src/config/env.ts` and do not create `src/env/`.
- [ ] Broad migrations were avoided unless requested.
- [ ] Verification commands were run and read.
- [ ] Remaining risks or TanStack API ambiguities cite exact sources and dates.
