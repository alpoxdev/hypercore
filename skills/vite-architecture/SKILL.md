---
name: vite-architecture
description: "Use this skill when reviewing or changing an existing Vite + TanStack Router project architecture, especially routes, loaders, validateSearch, services, hooks, Vite/TanStack Router platform setup, and nested shared folders such as src/lib or src/services. Do not use for TanStack Start or generic Vite apps without TanStack Router."
---

@architecture-rules.md
@rules/conventions.md
@rules/routes.md
@rules/services.md
@rules/hooks.md
@rules/execution-model.md
@rules/platform.md
@rules/validation.md
@references/official/current-docs-2026-06-02.md

# Vite + TanStack Router Architecture Enforcement

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Confirm a repository is a Vite + TanStack Router project before enforcing architecture rules.
- Enforce safety boundaries for client-reachable loaders, route modules, service layers, env usage, generated route trees, and platform setup.
- Apply Hypercore/repo-local conventions for route folders, hooks, services, naming, and nested shared folders such as `src/lib/<domain>/` and `src/services/<domain-or-provider>/`.
- Keep current Vite and TanStack Router facts in `references/official/` so rapidly changing tool behavior can be refreshed without bloating the core skill.

</purpose>

<routing_rule>

Use this skill for architecture enforcement, implementation guidance, or review in existing Vite + TanStack Router projects. This includes route structure, route-local folders, loaders, `validateSearch`, service/query layers, custom hooks, Vite plugin setup, generated route tree handling, env/alias safety, and shared nested folder organization.

Do not use this skill when the project uses `@tanstack/react-start` / `app.config.ts`, when the project is generic Vite without TanStack Router, or when the task is a docs-only summary with no project audit or implementation guidance. Route TanStack Start work to `tanstack-start-architecture`.

When official Vite/TanStack Router guidance and Hypercore conventions differ, enforce official and safety rules first, then apply Hypercore conventions only to touched architecture surfaces.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Keep Vite + TanStack Router projects architecturally safe, maintainable, and aligned with official Vite/Router behavior plus labelled Hypercore conventions. |
| Trigger | Existing Vite + TanStack Router project work involving routes, loaders, search params, services, hooks, Vite config, router setup, env/alias boundaries, or shared folder layout. |
| Scope | Review and guide touched project architecture, topic rule files, official references, validation notes, and small reversible architecture fixes. |
| Authority | User/project instructions outrank this skill. Official Vite and TanStack Router docs outrank Hypercore conventions for API facts. Safety policy blocks risky runtime/env/import-boundary changes. |
| Evidence | Use project indicators, local package/config/router files, touched source paths, topic rules, official references, package checks, and validation command output. |
| Tools | Use local search/read/edit/validation commands; use current official docs when API drift matters; gate broad route migrations, credential access, SSR adoption, and production side effects. |
| Output | Korean architecture decision or review with rule classifications, changed files if any, validation evidence, remaining risks, and official-doc ambiguity notes. |
| Verification | Run `rules/validation.md` checks relevant to touched surfaces and `scripts/validate-vite-architecture-skill.mjs` when this skill folder changes. |
| Stop condition | Stop after project mode is known, applicable safety gates pass, Hypercore conventions are applied or explicitly deferred, validation evidence is recorded, and unresolved API drift is dated and sourced. |

</instruction_contract>

## Overview

Enforces hypercore Vite + TanStack Router architecture rules with strict validation before editing code.

**This skill is RIGID. Follow exactly. No exceptions.**

**OPERATING MODE:** This skill must stay self-contained. Do not block on external orchestration surfaces just to apply architecture rules. If a repo-local persistence loop is already active, carry these gates into that loop. Otherwise proceed directly with this skill.

**NOTE:** Some rules in this skill are stricter than TanStack Router defaults. Treat them as hypercore team conventions unless the user explicitly asks to follow official TanStack defaults instead.

<activation_examples>

Positive examples:

- "Audit this Vite + TanStack Router app for route structure, validateSearch, and service boundaries before editing."
- "Add a new route folder in a Vite + TanStack Router app and keep hooks/services compliant."
- "Refactor a TanStack Router page so the UI stays in the route and logic moves into -hooks/."
- "Vite Router 프로젝트에서 tanstackRouter plugin order와 routeTree.gen.ts 처리를 점검해줘."
- "src/lib/utils.ts 말고 src/lib/auth/session.ts, src/services/billing/queries.ts처럼 nested folders로 묶어줘."

Negative examples:

- "Create a new Codex skill for browser QA."
- "Review a TanStack Start app that uses createServerFn and @tanstack/react-start."
- "Review a generic Vite app that does not use TanStack Router."

Boundary examples:

- "Make a tiny copy-only text change in a Vite route file."
  Direct editing can be enough if the change does not cross an architecture boundary, but touched files still need a quick compliance check.
- "The repo actually uses @tanstack/react-start."
  Route away to `tanstack-start-architecture` instead of forcing Vite rules onto a Start project.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|---|---|
| Existing Vite + TanStack Router project work touches routes, loaders, services, hooks, router setup, env, aliases, or shared folder layout | enforce |
| `@tanstack/react-start` or `app.config.ts` is present | route away to `tanstack-start-architecture` |
| Generic Vite project without TanStack Router indicators | do not apply |
| Copy-only text change in a route file | direct edit with quick compliance check |

</trigger_conditions>

<support_file_read_order>

1. Read `architecture-rules.md` before code changes or architecture findings.
2. Read the topic rule file that matches the touched surface: `rules/routes.md`, `rules/services.md`, `rules/hooks.md`, `rules/execution-model.md`, `rules/platform.md`, `rules/conventions.md`, or `rules/validation.md`.
3. Read the directly linked official current-docs reference only when Vite, TanStack Router, plugin, env, route tree, search, or loader behavior may be API-drift sensitive.
4. Run `scripts/validate-vite-architecture-skill.mjs` after editing this skill folder.

</support_file_read_order>

<workflow>

## Step 1: Project Validation

Before any work, confirm a Vite + TanStack Router project:

```bash
# Check for Vite + TanStack Router indicators (ANY of these)
grep -r "@tanstack/react-router" package.json 2>/dev/null
grep -r "vite" package.json 2>/dev/null
ls vite.config.ts 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

If NONE found: **STOP. This skill does not apply.** Inform the user and return to the normal implementation or review path.

If `@tanstack/react-start` or `app.config.ts` is present: **STOP.** Route to `tanstack-start-architecture`.

If the repo matches Vite + TanStack Router: proceed with architecture enforcement.

## Step 2: Read Architecture Rules

Load the detailed rules reference:

**REQUIRED:** Read `architecture-rules.md` in this skill directory before writing any code. Read `references/official/current-docs-2026-06-02.md` when Vite config, env handling, TanStack Router plugin setup, routeTree generation, or search/load behavior may be API-drift sensitive.

For detailed patterns and examples, also read the relevant rule files:
- `rules/conventions.md` - naming, TypeScript, imports, comments
- `rules/routes.md` - route folder structure, `route.tsx`, loaders, search params
- `rules/services.md` - public API services, query options, mutations, client boundaries
- `rules/hooks.md` - custom hook separation and internal order
- `rules/execution-model.md` - loader/runtime boundaries, SSR-aware caveats, env safety
- `rules/platform.md` - `vite.config.ts`, router setup, generated files, env and alias rules
- `rules/validation.md` - project/skill validation and readback checks

## Step 3: Pre-Change Validation Checklist

Before writing ANY code, verify the planned change against these gates:

### Brownfield Adoption Rule

- Do not treat every untouched legacy deviation as an immediate project-wide failure.
- Safety or boundary issues still block immediately, especially in touched files.
- Hypercore-specific style or structure drift in untouched legacy code can be recorded as migration backlog.
- Any file you touch should be brought into compliance unless that would require a materially risky migration.

### Gate 1: Layer Violations

```
Routes -> Services -> External API
```

| Check | Rule |
|-------|------|
| Route calling `fetch`/`axios` directly? | BLOCKED. Must go through services |
| Hook calling `fetch`/`axios` directly? | BLOCKED. Must go through services |
| Service returning raw `Response` to routes/hooks? | BLOCKED. Return typed data |
| `createServerFn`, `useServerFn`, or Start-only middleware APIs in a Vite app? | BLOCKED |

### Gate 2: Route Structure

| Check | Rule |
|-------|------|
| Flat file route for a page that owns UI/logic? (`routes/users.tsx`) | BLOCKED. Use a folder route (`routes/users/index.tsx`) |
| Missing `-components/` folder? | BLOCKED. Every page needs it |
| Missing `-hooks/` folder? | BLOCKED. Every page needs it |
| `-functions/` folder present? | BLOCKED. Vite skill does not allow server functions |
| `const Route` without `export`? | BLOCKED. Must be `export const Route` |
| Logic in page component? | BLOCKED. Extract to `-hooks/` |
| Layout route missing `route.tsx` while it owns shared loader/beforeLoad/layout work? | BLOCKED |
| Route with search params but no `validateSearch`? | BLOCKED. Use `zodValidator` |
| Route with loader but no `pendingComponent`? | WARNING. Recommended |

### Gate 3: Services

| Check | Rule |
|-------|------|
| POST/PUT/PATCH without schema validation? | BLOCKED. Validate with Zod before calling |
| Direct `fetch`/`axios` in route or hook? | BLOCKED. Use service functions |
| `services/index.ts` barrel export? | BLOCKED. Import directly from concrete files |
| Missing explicit return type on service function? | BLOCKED |

### Gate 4: Hooks

| Check | Rule |
|-------|------|
| Hook logic left inside page component? | BLOCKED. Move to `-hooks/` |
| Wrong hook order? | BLOCKED. State -> Global -> Query -> Handlers -> Memo -> Effect |
| Missing exported return type interface? | BLOCKED |
| camelCase hook filename? | BLOCKED. Use `use-kebab-case.ts` |
| `useServerFn` in a Vite hook? | BLOCKED |

### Gate 5: Conventions

| Check | Rule |
|-------|------|
| camelCase filename? | BLOCKED. Use kebab-case |
| `function` keyword? | BLOCKED. Use const arrow functions |
| `any` type? | BLOCKED. Use `unknown` |
| Missing explicit return type? | BLOCKED |
| Wrong import order? | BLOCKED. External -> @/ -> Relative -> Type |
| Missing Korean block comments for grouped logic? | BLOCKED |
| Using `z.string().email()`? | BLOCKED. Use `z.email()` in Zod 4 |

### Gate 6: Execution Model

| Check | Rule |
|-------|------|
| Treating a route `loader` as a private server-only boundary? | BLOCKED. Loaders are client-reachable and may also participate in SSR/manual rendering |
| Secret, DB, filesystem, or privileged SDK access inside a route module or loader? | BLOCKED. Keep it behind an actual backend/API boundary |
| Browser-only APIs used at module scope or in shared route helpers without a client boundary? | BLOCKED |
| Non-`VITE_` env access in client-reachable code? | BLOCKED |

### Gate 7: Platform Setup

| Check | Rule |
|-------|------|
| `vite.config.ts` missing `tanstackRouter()` or plugin order is wrong? | BLOCKED. Router plugin must stay explicit and precede `react()` |
| `routeTree.gen.ts` hand-edited? | BLOCKED. Treat as generated output |
| Router setup hidden or inconsistent with SSR/manual rendering needs? | WARNING. Keep `src/router.tsx` explicit; use a fresh router factory when SSR/manual rendering exists |
| Path alias or env setup relies on implicit behavior only? | WARNING. Keep `tsconfig`/Vite config and runtime validation explicit |

## Step 3.5: Auto-Remediation Policy

Auto-fix directly when the issue is local, reversible, and low-risk.

- add missing `validateSearch`
- move direct route/hook network access into `services/`
- add missing `pendingComponent` or `errorComponent`
- create missing `-components/` or `-hooks/` folders for touched pages
- add or correct `tanstackRouter()` plugin setup, router scaffolding, or explicit env/alias wiring

Do not auto-apply broad or potentially breaking migrations without explicit justification.

- mass route/file renames
- sweeping route-tree restructures across many pages
- introducing SSR/manual server rendering where the repo was SPA-only
- large auth or API-client rewrites

## Step 4: Implementation

Carry these acceptance criteria into the active task:

```text
- [ ] Layer architecture respected (Routes -> Services -> External API)
- [ ] Route uses folder structure with -components/ and -hooks/
- [ ] export const Route = createFileRoute(...) used
- [ ] No Start-only server-function APIs in this Vite project
- [ ] Search params use zodValidator from @tanstack/zod-adapter
- [ ] Custom Hooks live in -hooks/ with correct internal order
- [ ] Loaders stay public-safe and SSR-safe
- [ ] Vite/router platform setup stays explicit (router plugin, router file, generated files)
- [ ] All filenames kebab-case
- [ ] Korean block comments present
- [ ] const arrow functions with explicit return types
```

</workflow>

<validation_checklist>

## Step 5: Post-Change Verification

After writing code, verify:

1. **Structure check**: confirm each touched page still has `-components/` and `-hooks/` and no `-functions/`
2. **Export check**: grep for `export const Route`
3. **Layer check**: no direct `fetch`/`axios` in touched route or hook files
4. **Convention check**: no camelCase filenames, no `function` keyword declarations
5. **Hook order check**: read touched hooks and verify State -> Global -> Query -> Handlers -> Memo -> Effect
6. **Execution check**: loaders and route modules do not touch secrets, DB clients, or private env values directly
7. **Platform check**: `vite.config.ts`, `src/router.tsx`, env wiring, and generated router files remain coherent

</validation_checklist>
