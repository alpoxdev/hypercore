---
name: hono-architecture
description: "[Hyper] Use when working on Hono projects or adding Hono into a codebase. Enforces Hono architecture rules for app composition, scalable route modules, middleware, validation, database/ORM boundaries, Drizzle integration, migrations, error handling, OpenAPI/Swagger documentation, testing, and typed RPC boundaries before any code change."
compatibility: Works best with repo inspection, official Hono docs verification, and direct code edits in Hono applications.
---

# Hono Architecture Enforcement

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

## Overview

Enforces hypercore Hono architecture rules before code changes. Validate that the target is actually a Hono project, then apply strict rules for route composition, scalable folder structure, handlers, middleware, validation, database/ORM boundaries, Drizzle connection and migration placement, error handling, OpenAPI/Swagger documentation, platform entrypoints, and typed testing/RPC.

**This skill is strict.** Follow the rules exactly unless the user explicitly asks to prefer official Hono defaults over hypercore-specific conventions.

**OPERATING MODE:** This skill is self-contained. Do not block on global skills or external orchestration surfaces. If the user asks for exhaustive verification, keep verifying. Otherwise proceed directly with this skill's own validation flow.

**IMPORTANT:** Some rules in this skill are stricter than Hono itself. Treat those as hypercore conventions and label them clearly when reporting violations.

## Trigger Examples

### Positive

- `Review this Hono app structure before I add more routes.`
- `Refactor a Hono API so routing, middleware, and validators follow one architecture.`
- `Add a new Hono route and make sure testClient and AppType inference still work.`
- `Wire Drizzle into this Hono API without routes talking to the database directly.`
- `Review database, migration, and OpenAPI boundaries before adding a new persisted endpoint.`
- `hono-architecture 전체 수정`
- `Run the Hono architecture skill in full-remediation mode.`

### Negative

- `Create a generic Express middleware guide.`
- `Review a React SPA that does not use Hono.`

### Boundary

- `Make a tiny copy-only response text change in a Hono handler.`
Direct editing can be enough if no architectural boundary is affected.

- `Use official Hono defaults only, not the extra hypercore conventions.`
This skill still applies, but relax hypercore-only strictness that exceeds the official docs.

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

## Step 3: Pre-Change Validation Checklist

Validate planned changes against these gates.

### Brownfield Adoption Rule

- Do not treat every legacy deviation as a project-wide failure.
- Safety, typing, and validation issues still block immediately, especially in touched files.
- Hypercore-specific structure drift in untouched legacy code can be recorded as migration backlog.
- Any file you touch should be brought into compliance unless that would require a materially risky migration.
- If the user invoked `전체 수정`, the whole detected Hono app becomes the touched scope. Fix all safe violations instead of deferring hypercore-only drift just because it was previously untouched.

### Non-Compliance Discovery Signals

Use these signals to decide where to inspect before editing:

| Signal | Inspect |
|------|------|
| Multiple files call `new Hono()` and mount routes without a single exported app/composition path | `app.ts`, `routes/index.ts`, runtime entrypoint, and all route exports |
| A route file imports database clients, SDK clients, ORM schema tables, or runtime adapters directly | route module, matching service/repository/client/database folders |
| Repeated `c.req.json()`, `c.req.query()`, or ad hoc param parsing appears in handlers | validation schemas and route middleware |
| `drizzle-orm`, `drizzle.config.ts`, `schema.ts`, migration folders, `DATABASE_URL`, `D1Database`, `Pool`, `neon`, or `@libsql/client` appears | database rule file, connection boundary, schema/migration placement, repositories |
| `AppType`, `hc`, `testClient`, or frontend `InferResponseType` exists | exported app type, sub-app mounting pattern, explicit response statuses |
| `OpenAPIHono`, `createRoute`, `describeRoute`, `openAPIRouteHandler`, `swaggerUI`, `/doc`, or `/ui` exists | OpenAPI rule file, docs endpoint, Swagger UI exposure, route metadata coverage |
| API version prefixes such as `/api`, `/v1`, or `basePath()` appear in more than one place | platform entrypoint and route composition boundary |

### Gate 1: Composition and Layers

| Check | Rule |
|------|------|
| Root app mixes transport, business logic, and persistence directly? | BLOCKED. Keep composition in app/route modules and move domain logic down. |
| Route modules bypass services and talk to DB/ORM/SDK directly without a clear reason? | BLOCKED by hypercore convention. Prefer `routes -> services -> repositories/clients/database`. |
| Controller-style class or giant controller file introduced for simple handlers? | BLOCKED. Hono best practices prefer smaller apps and route composition over controller-heavy structure. |
| Large feature area mounted manually without sub-app composition? | WARNING. Prefer `app.route()` / `basePath()` composition. |

### Gate 2: Route Modules

| Check | Rule |
|------|------|
| Route registration scattered across unrelated files? | BLOCKED. Keep one obvious composition path. |
| Larger route module missing a dedicated folder with local schemas/handlers? | BLOCKED by hypercore convention. |
| Medium or large feature still lives in one flat route file with mixed schemas, handlers, and services? | WARNING or BLOCKED depending on touched scope. Split by feature folder before adding more behavior. |
| Catch-all or fallback route registered before specific routes? | BLOCKED. Registration order matters in Hono. |
| Route module cannot be mounted cleanly with `app.route()` or a typed sub-app? | BLOCKED. |

### Gate 2.5: Folder and File Naming

| Check | Rule |
|------|------|
| Source folder or file uses camelCase or PascalCase naming? | BLOCKED by hypercore convention. Rename to kebab-case and update imports/references when safe. |
| Route folder uses plural/domain naming inconsistently with the mount path? | WARNING. Prefer stable domain folder names in kebab-case, then keep mount paths explicit in route composition. |
| `전체 수정` mode finds kebab-case violations outside the originally requested files? | FIX if imports/config/test paths can be updated safely; otherwise report a blocker with the affected paths. |

### Gate 3: Handlers and Context Typing

| Check | Rule |
|------|------|
| Extracted handlers lose route typing or context typing? | BLOCKED. Use inline chaining or `createFactory()` / `factory.createHandlers()`. |
| Untyped `c.set()` / `c.get()` values used across middleware/handlers? | BLOCKED. Type `Variables` on the app/factory. |
| Request parsing and domain work mixed into a single long handler? | WARNING. Split validator, service, and response shaping. |

### Gate 4: Validation

| Check | Rule |
|------|------|
| Non-trivial request data consumed without validator middleware? | BLOCKED. |
| Raw `await c.req.json()` or manual parsing repeated inside handlers? | BLOCKED unless the payload is trivial and tightly scoped. |
| Validation strategy is inconsistent across params/query/json/form in the same feature? | WARNING. Normalize it. |
| New validation library added without need? | BLOCKED unless explicitly requested. Prefer built-in `validator()`, `@hono/zod-validator`, or `@hono/standard-validator`. |

### Gate 4.25: Database / ORM

| Check | Rule |
|------|------|
| Route or handler imports `db`, `drizzle-orm`, schema tables, driver clients, pools, or migration helpers directly? | BLOCKED by hypercore convention. Move database access behind service/repository/database boundaries. |
| Database client, pool, or Drizzle instance is created inside a request handler? | BLOCKED. Centralize connection lifecycle at the database, platform, or app initialization boundary. |
| Drizzle schema or migration files live inside route folders? | BLOCKED. Keep schema/migrations under a database or migration boundary that matches `drizzle.config.ts`. |
| Multi-step write has no transaction or explicit reason? | BLOCKED when atomic behavior is required. Put the transaction boundary in the service/use-case layer and pass `tx` into repositories. |
| Public response shape is raw ORM row shape with internal fields? | BLOCKED for public APIs. Add DTO mapping and align validation, OpenAPI, and RPC response types. |
| ORM/provider/driver switch is bundled into an unrelated route change? | BLOCKED. Treat it as an explicit migration. |

### Gate 4.5: OpenAPI / Swagger

| Check | Rule |
|------|------|
| Public or partner-facing API route added without OpenAPI coverage in a repo that publishes docs? | BLOCKED. Add operation metadata with request, responses, tags, and `operationId`. |
| Runtime validation schema and OpenAPI schema drift apart? | BLOCKED. Keep one source of truth or document a synchronization rule. |
| Swagger UI is exposed in production without auth, admin-only routing, or an explicit public-docs decision? | BLOCKED. |
| Operation omits expected error responses for auth, validation, not found, conflict, or server failure? | WARNING. Add reusable error response components where applicable. |
| Large app has per-feature OpenAPI fragments but no single canonical spec endpoint? | BLOCKED. Compose docs at the app boundary. |

### Gate 5: Middleware

| Check | Rule |
|------|------|
| Middleware order assumed incorrectly? | BLOCKED. Registration order matters. |
| Shared auth/logging/request-id logic duplicated across handlers? | WARNING. Prefer middleware. |
| Context values survive across requests by assumption? | BLOCKED. Context is request-scoped only. |
| Runtime-specific concerns leak from middleware into domain layers? | BLOCKED. |

### Gate 6: Errors and Responses

| Check | Rule |
|------|------|
| Handler throws raw generic errors for expected HTTP failures everywhere? | WARNING. Prefer `HTTPException` or one centralized translation policy. |
| `app.onError()` missing in a non-trivial API? | WARNING. Add a central error boundary. |
| Code relies on `HTTPException.getResponse()` while forgetting existing `Context` headers? | BLOCKED. Preserve context-set headers when rebuilding responses. |
| Typed RPC client depends on not-found behavior but no explicit `app.notFound()` or JSON response contract is tested? | BLOCKED. Make the 404 response shape explicit for public clients. |

### Gate 7: Testing and RPC

| Check | Rule |
|------|------|
| `testClient()` or `hc<AppType>` type inference broken by non-chained route definition? | BLOCKED. Keep route types flowing through the exported app. |
| App type not exported where `hc` or shared RPC client usage is expected? | BLOCKED. Export `AppType` for the shared client contract. |
| Large app split loses typed inference across sub-apps? | BLOCKED. Follow the larger-app chaining pattern from the Hono RPC docs. |
| Generated OpenAPI contract and `AppType`/RPC contract disagree on request or response shape? | BLOCKED. Fix the shared schema or response status first. |

### Gate 8: Platform Entry

| Check | Rule |
|------|------|
| Runtime adapter code mixed into route modules? | BLOCKED. Keep adapter/bootstrap code at the edge. |
| Environment bindings/vars used without a typed `Bindings`/config boundary? | BLOCKED. |
| Debug helpers like `showRoutes()` enabled outside explicit dev-only setup? | WARNING. |

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
