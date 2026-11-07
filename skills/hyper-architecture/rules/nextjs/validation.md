# Validation and Readback

> Completion checks for Next.js architecture work and for this skill's own maintainability.

## Project Work Validation

Run checks appropriate to the touched surfaces:

```bash
# Project and router mode
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)

# App Router special-file conflicts and private folders
find app src/app -maxdepth 5 -type f \( -name 'page.tsx' -o -name 'route.ts' -o -name 'layout.tsx' -o -name 'loading.tsx' -o -name 'error.tsx' \) 2>/dev/null

# Server/Client boundary and secret import checks
rg -n "^['\"]use client['\"]|server-only|client-only|cookies\(|headers\(|process\.env|NEXT_PUBLIC_" app src/app src/components src/lib src/services 2>/dev/null

# Cache, mutation freshness, and route handler checks
rg -n "cacheComponents|partialPrefetching|use cache|cacheTag|cacheLife|io\(|connection\(|navigation\(|prefetch\(|ensureStatic|instant|updateTag|revalidateTag|revalidatePath|refresh\(|redirect\(" next.config.* app src/app src/lib src/services 2>/dev/null
rg -n "export const runtime|export const ensureStatic|export const instant|export const prefetch" app src/app 2>/dev/null
rg -n "export async function (GET|POST|PUT|PATCH|DELETE)|NextResponse\.next\(|RouteContext" app src/app 2>/dev/null
rg -n "drizzle|drizzle.config|schema|migrate|push|pull|check|prepared|relations|RQB" drizzle.config.* src/db db src/modules src/services 2>/dev/null

# Proxy / env checks
find . -maxdepth 2 \( -name 'proxy.ts' -o -name 'middleware.ts' -o -name 'middleware.js' \)
rg -n "NEXT_PUBLIC_.*(SECRET|TOKEN|PASSWORD|DATABASE_URL|PRIVATE)|process\.env\.(?!NEXT_PUBLIC_)" app src/app src/components 2>/dev/null
```

Interpret grep output with the relevant topic rules; grep output alone is not a verdict.

## Skill Anatomy Validation

For edits to this skill itself:

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

- `stacks/nextjs/core.md` and `stacks/nextjs/core.ko.md` include routing, instruction contract, activation examples, workflow, verification, and stop condition.
- Support files referenced from the core are directly linked; there is no indirect reference chain.
- Official Next.js facts live in `references/official/nextjs/`, not in long core sections.
- Current official snapshot `references/official/nextjs/current-docs-2026-11-04.md` is directly linked from `stacks/nextjs/core.md` and used when API drift matters.
- Hypercore/repo-local conventions are labelled as such.
- Project-structure guidance handles `app`, `src/app`, `pages`, `src/pages`, private folders, shared nested folders, and no-new-direct-leaf-files under touched shared roots.
- Shared nested folders such as `src/modules`, `src/lib`, `src/services`, `src/db`, `src/server`, `src/integrations`, and `src/config` are labelled as Hypercore/repo-local convention, not official Next.js law.
- Services guidance covers DAL/service/provider boundaries, DTOs, authorization delegation, and server-only helper splits.
- Hooks guidance covers Next.js client orchestration boundaries and explicitly says hooks must not cross server/data layers.
- DB guidance covers Drizzle schema/config/migrations, connection lifecycle, prepared statements, RQB relations/tables at `drizzle()` init, and validation integrations.
- Official Drizzle facts live in `references/official/nextjs/drizzle-docs.md` and `.ko.md`, not in long core sections.
- Deprecated feature-folder guidance is absent from this skill.
- Cache Components, Server Actions, Route Handlers, Proxy, env, and Server/Client boundary guidance remain current-docs compatible.
- The `cacheComponents` and `partialPrefetching` pair, the `io()`-over-`connection()` preference, and the `runtime` export removal are stated together wherever Cache Components is described.
- English and Korean entrypoints have aligned trigger, boundary, workflow, contract, and read order.
- English and Korean sibling files are structurally and semantically aligned; Korean parity checks include services/hooks/db/Drizzle phrases.
- This skill is validated source-only from `skills/hyper-architecture`; it has no plugin mirror, symlink, or adapter contract.

## Readback Evidence

Before reporting completion, record:

- scenario name and claim being verified
- exact invocation
- binary observable such as exit code, missing-file count, diff result, or validator JSON
- captured artifact path

For this skill folder, read back the changed English/Korean sibling files after edits and verify that links, headings, and rule responsibilities match. Validate the canonical source files only; no plugin mirror, symlink, or adapter requires synchronization.

## Trigger Tests

Positive examples that should trigger this skill:

- "Audit this Next.js App Router feature for Server/Client boundaries and cache correctness."
- "Refactor this form to use Server Actions instead of an internal route handler."
- "Add a Route Handler for a webhook and verify it follows the current Next.js docs."
- "Next.js 16 cacheComponents 기준으로 data fetching 규칙을 점검해줘."
- "Next.js App Router에서 src/lib/auth/session.ts와 src/services/billing/mutations.ts처럼 nested shared folders로 정리해줘."

Negative examples that should not trigger this skill:

- "Create a generic React architecture guide."
- "Review a Remix or TanStack Start app."
- "Write marketing copy for a Next.js landing page without touching architecture."

Boundary examples:

- "Make a tiny copy-only text change in a Next.js page." Expected: quick boundary check only.
- "This repo is Pages Router only and I am not migrating to App Router." Expected: shared Next.js checks, no App Router-only enforcement.

## Sources

> No external sources were used in this file; it describes repository-local commands and readback steps. Framework facts live in the topic rule files under `rules/nextjs/` and in `references/official/nextjs/`. Repository-local links checked 2026-11-04.
