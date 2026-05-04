---
name: hono-architecture
description: "[Hyper] Use when working on Hono projects or adding Hono into a codebase. Enforces Hono architecture rules for app composition, route modules, middleware, validation, error handling, testing, and typed RPC boundaries before any code change."
compatibility: Works best with repo inspection, official Hono docs verification, and direct code edits in Hono applications.
---

# Hono Architecture Enforcement

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

## Overview

Enforces hypercore Hono architecture rules before code changes. Validate that the target is actually a Hono project, then apply strict rules for route composition, handlers, middleware, validation, error handling, platform entrypoints, and typed testing/RPC.

**This skill is strict.** Follow the rules exactly unless the user explicitly asks to prefer official Hono defaults over hypercore-specific conventions.

**OPERATING MODE:** This skill is self-contained. Do not block on global skills or external orchestration surfaces. If the user asks for exhaustive verification, keep verifying. Otherwise proceed directly with this skill's own validation flow.

**IMPORTANT:** Some rules in this skill are stricter than Hono itself. Treat those as hypercore conventions and label them clearly when reporting violations.

## Trigger Examples

### Positive

- `Review this Hono app structure before I add more routes.`
- `Refactor a Hono API so routing, middleware, and validators follow one architecture.`
- `Add a new Hono route and make sure testClient and AppType inference still work.`

### Negative

- `Create a generic Express middleware guide.`
- `Review a React SPA that does not use Hono.`

### Boundary

- `Make a tiny copy-only response text change in a Hono handler.`
Direct editing can be enough if no architectural boundary is affected.

- `Use official Hono defaults only, not the extra hypercore conventions.`
This skill still applies, but relax hypercore-only strictness that exceeds the official docs.

## Step 1: Project Validation

Before doing any work, confirm the target is a Hono project:

```bash
rg -n '"hono"|@hono/' package.json
rg -n "from 'hono'|from \"hono\"" src app .
rg -n "new Hono\\(|createFactory\\(|testClient\\(|hc<" src app .
```

If none of those indicators exist, stop and route back to the normal implementation or review path instead of forcing Hono rules.

## Step 2: Read Architecture Rules

Read the detailed rules before editing:

- `architecture-rules.md`
- `rules/conventions.md`
- `rules/routes.md`
- `rules/handlers.md`
- `rules/middleware.md`
- `rules/validation.md`
- `rules/errors.md`
- `rules/testing-rpc.md`
- `rules/platform.md`

When the change depends on current framework behavior or you need to justify a rule from the official docs, read:

- `references/official/hono-docs.md`

### Task-to-Rule Routing

Use the next file based on the change you are making:

- For route composition, mount order, fallback placement, or sub-app structure, read `rules/routes.md`
- For handler extraction, `createFactory()`, `createHandlers()`, or typed context flow, read `rules/handlers.md`
- For shared request boundaries, auth/logging/request-id flow, or `c.set()` / `c.get()` usage, read `rules/middleware.md`
- For params/query/json/form validation choices, read `rules/validation.md`
- For `HTTPException`, `app.onError()`, or response-shaping problems, read `rules/errors.md`
- For `testClient()`, `hc<typeof app>`, `AppType`, or larger-app inference, read `rules/testing-rpc.md`
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

### Gate 1: Composition and Layers

| Check | Rule |
|------|------|
| Root app mixes transport, business logic, and persistence directly? | BLOCKED. Keep composition in app/route modules and move domain logic down. |
| Route modules bypass services and talk to DB/SDK directly without a clear reason? | BLOCKED by hypercore convention. Prefer `routes -> services -> repositories/clients`. |
| Controller-style class or giant controller file introduced for simple handlers? | BLOCKED. Hono best practices prefer smaller apps and route composition over controller-heavy structure. |
| Large feature area mounted manually without sub-app composition? | WARNING. Prefer `app.route()` / `basePath()` composition. |

### Gate 2: Route Modules

| Check | Rule |
|------|------|
| Route registration scattered across unrelated files? | BLOCKED. Keep one obvious composition path. |
| Larger route module missing a dedicated folder with local schemas/handlers? | BLOCKED by hypercore convention. |
| Catch-all or fallback route registered before specific routes? | BLOCKED. Registration order matters in Hono. |
| Route module cannot be mounted cleanly with `app.route()` or a typed sub-app? | BLOCKED. |

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
| Typed RPC client is exported but the app still depends on `c.notFound()` behavior? | BLOCKED. Avoid patterns the Hono RPC docs call out as incompatible. |

### Gate 7: Testing and RPC

| Check | Rule |
|------|------|
| `testClient()` or `hc<typeof app>` type inference broken by non-chained route definition? | BLOCKED. Keep route types flowing through the exported app. |
| App type not exported where typed client/test usage is expected? | BLOCKED. Export `AppType`. |
| Large app split loses typed inference across sub-apps? | BLOCKED. Follow the larger-app chaining pattern from the Hono RPC docs. |

### Gate 8: Platform Entry

| Check | Rule |
|------|------|
| Runtime adapter code mixed into route modules? | BLOCKED. Keep adapter/bootstrap code at the edge. |
| Environment bindings/vars used without a typed `Bindings`/config boundary? | BLOCKED. |
| Debug helpers like `showRoutes()` enabled outside explicit dev-only setup? | WARNING. |

## Step 3.5: Auto-Remediation Policy

Auto-fix directly when the issue is local, reversible, and low-risk.

- Add missing validator middleware to a touched route
- Add typed `AppType` export
- Move route mounting into a single composition file
- Convert extracted untyped handlers to `createFactory()` / `factory.createHandlers()`
- Add `app.onError()` or improve HTTP exception translation
- Move runtime adapter imports out of handlers and route modules

Do not auto-apply broad or potentially breaking migrations without explicit justification.

- Mass route/module renames
- Whole-app layer rewrites
- Validation library swaps across the entire repository
- RPC shape changes that break existing clients
- Runtime adapter swaps

## Step 4: Implementation

When changing Hono code, prefer this order:

1. Validate current structure and rule breaches.
2. Fix route composition and typing boundaries first.
3. Fix validation and middleware ordering.
4. Fix error handling and response shaping.
5. Fix testing/RPC inference regressions.
6. Run verification.

## Verification Checklist

- Hono project detection confirmed
- Relevant rule files read
- Official override mode applied when the user requested official Hono defaults
- Touched files follow kebab-case naming
- Route composition is obvious and mountable
- Middleware order verified
- Validation enforced on non-trivial inputs
- Error handling policy is explicit
- `testClient` / `hc` / `AppType` inference still works when applicable
- Runtime adapter code stays at the edge
- Final findings distinguish official Hono rules from hypercore-only conventions
