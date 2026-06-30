---
name: hono-architecture
description: "[Hyper] Use when working on Hono projects or adding Hono into a codebase. Enforces Hono architecture rules for app composition, scalable route modules, middleware, validation, database/ORM boundaries, Drizzle integration, migrations, error handling, OpenAPI/Swagger documentation, testing, and typed RPC boundaries before any code change."
compatibility: Works best with repo inspection, official Hono docs verification, and direct code edits in Hono applications.
---

@architecture-rules.md
@rules/conventions.md
@rules/routes.md
@rules/handlers.md
@rules/middleware.md
@rules/validation.md
@rules/database.md
@rules/openapi.md
@rules/errors.md
@rules/testing-rpc.md
@rules/platform.md
@references/official/hono-docs.md
@references/official/drizzle-docs.md

# Hono Architecture Enforcement

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Enforce Hypercore Hono architecture rules before code changes.
- Confirm the target is actually a Hono project before applying Hono-specific gates.
- Keep route composition, handlers, middleware, validation, database/ORM, Drizzle, OpenAPI/Swagger, platform entrypoints, error handling, testing, and typed RPC boundaries coherent.
- Label stricter-than-Hono requirements as Hypercore conventions when reporting findings.

</purpose>

<routing_rule>

Use this skill for Hono app implementation, review, remediation, or architecture enforcement.

Do not force this skill onto non-Hono projects, generic Express/Fastify work, copy-only changes that do not cross an architecture boundary, or requests where the user explicitly wants official Hono defaults without Hypercore conventions.

This skill is self-contained. Do not block on global skills or external orchestration surfaces just to apply Hono rules.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Keep Hono projects architecturally safe, typed, documented, and aligned with official Hono behavior plus labelled Hypercore conventions. |
| Trigger | Hono work involving routes, handlers, middleware, validation, DB/ORM, Drizzle, OpenAPI, platform entrypoints, error handling, testing, or RPC. |
| Scope | Review and guide touched Hono source, topic rule files, official references, validation notes, and small reversible architecture fixes. |
| Authority | User/project instructions outrank this skill. Official Hono/Drizzle docs outrank Hypercore conventions for API facts. Safety, typing, validation, and data-boundary rules block unsafe changes. |
| Evidence | Use project indicators, local package/source files, touched paths, topic rules, official references when drift matters, and validation command output. |
| Tools | Use local search/read/edit/validation commands; gate migrations, credential access, production side effects, runtime adapter swaps, and broad rewrites. |
| Output | Korean architecture finding or implementation summary with rule classification, changed files if any, validation evidence, remaining risks, and official-vs-Hypercore labels. |
| Verification | Run the relevant project checks and the final checklist for touched surfaces before declaring completion. |
| Stop condition | Stop after project mode is known, applicable gates pass or are reported as blockers, and validation evidence is recorded. |

</instruction_contract>

<activation_examples>

### Positive examples:

- `Review this Hono app structure before I add more routes.`
- `Refactor a Hono API so routing, middleware, and validators follow one architecture.`
- `Add a new Hono route and make sure testClient and AppType inference still work.`
- `Wire Drizzle into this Hono API without routes talking to the database directly.`
- `Review database, migration, and OpenAPI boundaries before adding a new persisted endpoint.`
- `hono-architecture 전체 수정`
- `Run the Hono architecture skill in full-remediation mode.`

### Negative examples:

- `Create a generic Express middleware guide.`
- `Review a React SPA that does not use Hono.`

### Boundary examples:

- `Make a tiny copy-only response text change in a Hono handler.`
Direct editing can be enough if no architectural boundary is affected.

- `Use official Hono defaults only, not the extra hypercore conventions.`
This skill still applies, but relax hypercore-only strictness that exceeds the official docs.

</activation_examples>

<trigger_conditions>

## Invocation Arguments

Arguments change the remediation scope, not the core rules.

| Argument | Meaning |
|------|------|
| missing | Review and fix the requested/touched Hono scope. Untouched legacy drift may be reported as backlog when it is hypercore-only or risky to migrate. |
| `전체 수정` | Full-remediation mode. Scan the whole detected Hono application and fix every violation that is safe, local, reversible, and verifiable. Do not stop at touched files. |
| `full fix` / `fix all` | Same as `전체 수정`. |
| `공식 기본만` / `official defaults only` | Use official Hono behavior as the default surface and downgrade hypercore-only conventions to optional findings unless the user also asks for `전체 수정`. |

In `전체 수정` mode:

- Treat all Hono app files, route modules, handlers, middleware, validation schemas, OpenAPI files, database/repository boundaries, tests/RPC surfaces, and runtime entrypoints as in scope.
- Scan folder and file names across the detected Hono source tree. Folders and files must be kebab-case except framework/tool-required names such as `package.json`, `tsconfig.json`, `drizzle.config.ts`, lockfiles, generated declarations, and explicitly configured migration artifacts.
- Rename camelCase or PascalCase folders/files to kebab-case when imports, test paths, route references, and configuration references can be updated safely in the same change.
- Apply all low-risk auto-remediations listed in Step 3.5 across the app, not only touched files.
- For risky changes that cannot be completed safely in the same run, leave a precise blocker/backlog item with file paths and the rule that failed. Do not silently ignore it.

</trigger_conditions>

<workflow>

## Step 1: Project Validation

Before doing any work, confirm the target is a Hono project:

```bash
rg -n '"hono"|@hono/' package.json
rg -n "from 'hono'|from \"hono\"" src app .
rg -n "new Hono\\(|createFactory\\(|testClient\\(|hc<|OpenAPIHono|swaggerUI" src app .
```

If none of those indicators exist, stop and route back to the normal implementation or review path instead of forcing Hono rules.

When database work is in scope, also inspect database indicators:

```bash
rg -n '"drizzle-orm"|drizzle-kit|DATABASE_URL|D1Database|@neondatabase|@libsql|pg|postgres' package.json drizzle.config.ts src app .
rg -n "from 'drizzle-orm|from \"drizzle-orm|db\\.|transaction\\(|migrate\\(|schema|repositories?" src app .
```

When `전체 수정` mode is active, run broad discovery before editing:

```bash
rg --files src app routes 2>/dev/null
rg -n "new Hono\\(|app\\.route\\(|basePath\\(|validator\\(|zValidator\\(|standardValidator\\(|OpenAPIHono|swaggerUI|testClient\\(|hc<|drizzle-orm|DATABASE_URL|D1Database|@neondatabase|@libsql" src app .
```

## Step 2: Read Architecture Rules

<support_file_read_order>

Read the detailed rules before editing:

- `architecture-rules.md`
- `rules/conventions.md`
- `rules/routes.md`
- `rules/handlers.md`
- `rules/middleware.md`
- `rules/validation.md`
- `rules/database.md`
- `rules/openapi.md`
- `rules/errors.md`
- `rules/testing-rpc.md`
- `rules/platform.md`

When the change depends on current framework behavior or you need to justify a rule from the official docs, read:

- `references/official/hono-docs.md`
- `references/official/drizzle-docs.md`

### Task-to-Rule Routing

Use the next file based on the change you are making:

- For route composition, mount order, fallback placement, or sub-app structure, read `rules/routes.md`
- For handler extraction, `createFactory()`, `createHandlers()`, or typed context flow, read `rules/handlers.md`
- For shared request boundaries, auth/logging/request-id flow, or `c.set()` / `c.get()` usage, read `rules/middleware.md`
- For params/query/json/form validation choices, read `rules/validation.md`
- For database clients, repositories, ORM boundaries, Drizzle schema, migrations, transactions, D1, Neon, Turso/libSQL, or `DATABASE_URL`, read `rules/database.md`
- For OpenAPI generation, Swagger UI, operation metadata, schema drift, docs endpoints, or API contract publishing, read `rules/openapi.md`
- For `HTTPException`, `app.onError()`, or response-shaping problems, read `rules/errors.md`
- For `testClient()`, `hc<AppType>`, `AppType`, or larger-app inference, read `rules/testing-rpc.md`
- For adapters, entrypoints, bindings, env/config typing, or `basePath()` boundaries, read `rules/platform.md`

### Official-Defaults Override Mode

When the user explicitly asks for official Hono defaults instead of hypercore-only conventions:

- Start from `references/official/hono-docs.md` first
- Apply official Hono behavior as the default decision surface
- Treat stricter hypercore rules as optional overlays and only enforce them when the user did not opt out
- In findings and final reports, label which rules are official Hono behavior and which are hypercore-only conventions

</support_file_read_order>

## Step 3: Pre-Change Validation Checklist

Validate planned changes against `architecture-rules.md` and the topic rule files before editing.

Brownfield rule:

- Untouched legacy style drift can become backlog.
- Safety, typing, validation, persistence, OpenAPI, and runtime boundary issues still block touched work.
- In `전체 수정` mode, the whole detected Hono app is the touched scope.

Critical gates:

- One obvious Hono app composition path; no scattered registration or early fallback routes.
- Touched route modules do not bypass services to import DB/ORM/schema/SDK/runtime adapter details directly.
- Non-trivial params/query/json/form data uses validator middleware before domain logic.
- Extracted handlers preserve typing with inline chaining or `createFactory()` / `createHandlers()`.
- Middleware order and typed `Bindings`/`Variables` are explicit when shared context is used.
- Drizzle schemas, migrations, clients, and transactions stay behind database/service boundaries.
- Public documented routes keep runtime validation, DTOs, OpenAPI/Swagger, and RPC response shapes aligned.
- Runtime adapter/bootstrap code stays at the platform edge.
- Source folders/files use kebab-case unless a tool or external contract requires otherwise.

Use the detailed checklists in the linked support files for findings and remediation detail; do not duplicate them in this core file.

## Step 3.5: Auto-Remediation Policy

Auto-fix directly when the issue is local, reversible, and low-risk.

- Rename touched camelCase/PascalCase source folders or files to kebab-case and update imports/references
- Add missing validator middleware to a touched route
- Add typed `AppType` export when a shared RPC/client contract depends on it
- Move route mounting into a single composition file
- Convert extracted untyped handlers to `createFactory()` / `factory.createHandlers()`
- Add `app.onError()` or improve HTTP exception translation
- Move runtime adapter imports out of handlers and route modules
- Move touched direct database calls into existing services/repositories
- Add a missing repository wrapper for a touched query
- Centralize repeated database client imports into the existing database client boundary
- Add missing OpenAPI metadata for touched public routes when the repo already publishes a spec
- Move Swagger UI exposure behind the existing docs/admin/dev boundary

Do not auto-apply broad or potentially breaking migrations without explicit justification.

- Mass route/module renames, except kebab-case-only renames in `전체 수정` mode when every import/reference/config path can be updated and verified
- Whole-app layer rewrites
- Validation library swaps across the entire repository
- RPC shape changes that break existing clients
- Runtime adapter swaps
- Database provider, ORM, dialect, or Drizzle driver swaps
- Generating, editing, applying, or deleting production migrations
- Schema table/column/index renames
- Transaction boundary rewrites without tests for the affected workflow
- Switching OpenAPI generators (`@hono/zod-openapi` vs `hono-openapi`) across a whole app

## Step 4: Implementation

When changing Hono code, prefer this order:

1. Validate current structure and rule breaches. In `전체 수정` mode, inventory the whole detected Hono app before editing.
2. Fix folder/file naming to kebab-case when safe, because later imports and tests depend on stable paths.
3. Fix route composition and typing boundaries first.
4. Fix database/repository/connection boundaries for touched persistence behavior, or the full app in `전체 수정` mode.
5. Fix validation and middleware ordering.
6. Fix OpenAPI/Swagger contract drift for touched public routes, or all documented/public routes in `전체 수정` mode.
7. Fix error handling and response shaping.
8. Fix testing/RPC inference regressions.
9. Run verification.

</workflow>

<validation_checklist>

## Verification Checklist

- Hono project detection confirmed
- Relevant rule files read
- Official override mode applied when the user requested official Hono defaults
- Touched files and folders follow kebab-case naming
- In `전체 수정` mode, the whole detected Hono source tree was scanned for kebab-case violations
- Route composition is obvious and mountable
- Middleware order verified
- Validation enforced on non-trivial inputs
- Touched routes do not import DB/ORM clients, Drizzle schema tables, or migration helpers directly
- Database client lifecycle is centralized and runtime-appropriate
- Schema and migration paths match the configured ORM/drizzle setup
- Transactions are explicit for affected multi-step writes
- OpenAPI/Swagger docs updated for touched documented routes
- Swagger UI exposure is intentional and environment-appropriate
- Error handling policy is explicit
- `testClient` / `hc` / `AppType` inference still works when applicable
- API DTOs, OpenAPI schemas, and RPC response shapes do not accidentally expose raw ORM rows
- Runtime adapter code stays at the edge
- Final findings distinguish official Hono rules from hypercore-only conventions

</validation_checklist>
