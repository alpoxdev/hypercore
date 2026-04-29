---
name: vite-architecture
description: "[Hyper] Use when working on Vite + TanStack Router projects - enforces architecture rules (layers, routes, hooks, services, conventions) with mandatory validation before any code change. Triggers on file creation, route work, hook patterns, or any structural change in a Vite + TanStack Router codebase."
---

# Vite + TanStack Router Architecture Enforcement

## Overview

Enforces hypercore Vite + TanStack Router architecture rules with strict validation before editing code.

**This skill is RIGID. Follow exactly. No exceptions.**

**OPERATING MODE:** This skill must stay self-contained. Do not block on external orchestration surfaces just to apply architecture rules. If a repo-local persistence loop is already active, carry these gates into that loop. Otherwise proceed directly with this skill.

**NOTE:** Some rules in this skill are stricter than TanStack Router defaults. Treat them as hypercore team conventions unless the user explicitly asks to follow official TanStack defaults instead.

## Trigger Examples

### Positive

- `Audit this Vite + TanStack Router app for route structure, validateSearch, and service boundaries before editing.`
- `Add a new route folder in a Vite + TanStack Router app and keep hooks/services compliant.`
- `Refactor a TanStack Router page so the UI stays in the route and logic moves into -hooks/.`

### Negative

- `Create a new Codex skill for browser QA.`
- `Review a TanStack Start app that uses createServerFn and @tanstack/react-start.`

### Boundary

- `Make a tiny copy-only text change in a Vite route file.`
Direct editing can be enough if the change does not cross an architecture boundary, but touched files still need a quick compliance check.

- `The repo actually uses @tanstack/react-start.`
Route away to `tanstack-start-architecture` instead of forcing Vite rules onto a Start project.

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

**REQUIRED:** Read `architecture-rules.md` in this skill directory before writing any code.

For detailed patterns and examples, also read the relevant rule files:
- `rules/conventions.md` - naming, TypeScript, imports, comments
- `rules/routes.md` - route folder structure, `route.tsx`, loaders, search params
- `rules/services.md` - public API services, query options, mutations, client boundaries
- `rules/hooks.md` - custom hook separation and internal order
- `rules/execution-model.md` - loader/runtime boundaries, SSR-aware caveats, env safety
- `rules/platform.md` - `vite.config.ts`, router setup, generated files, env and alias rules

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

## Step 5: Post-Change Verification

After writing code, verify:

1. **Structure check**: confirm each touched page still has `-components/` and `-hooks/` and no `-functions/`
2. **Export check**: grep for `export const Route`
3. **Layer check**: no direct `fetch`/`axios` in touched route or hook files
4. **Convention check**: no camelCase filenames, no `function` keyword declarations
5. **Hook order check**: read touched hooks and verify State -> Global -> Query -> Handlers -> Memo -> Effect
6. **Execution check**: loaders and route modules do not touch secrets, DB clients, or private env values directly
7. **Platform check**: `vite.config.ts`, `src/router.tsx`, env wiring, and generated router files remain coherent

## Quick Reference: Folder Structure

```text
src/
├── routes/
│   ├── __root.tsx
│   ├── index.tsx
│   └── users/
│       ├── route.tsx          # shared layout / beforeLoad / loader
│       ├── index.tsx          # /users
│       ├── -components/
│       ├── -hooks/
│       ├── $id/
│       │   ├── index.tsx      # /users/$id
│       │   ├── -components/
│       │   └── -hooks/
│       └── -sections/         # optional for large pages
├── services/<domain>/
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
├── hooks/                     # global hooks
├── stores/
├── components/
├── config/
├── env/
├── lib/
├── src/router.tsx
└── routeTree.gen.ts           # generated, do not hand-edit
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `routes/users.tsx` for a full page | `routes/users/index.tsx` |
| `routes/users/$id.tsx` while the page owns its own UI/logic folders | `routes/users/$id/index.tsx` |
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| Direct `fetch()` in route/hook | move to `services/<domain>/queries.ts` or `mutations.ts` |
| `createServerFn(...)` or `useServerFn(...)` in this app | use services + TanStack Query |
| Page component holds `useState`, `useQuery`, mutations inline | extract to `-hooks/use-*.ts` |
| `routeTree.gen.ts` edited manually | regenerate it; do not hand-edit |
| Loader reads secrets or non-`VITE_` env values | move behind a real backend/API boundary |
| `validateSearch` uses raw unvalidated search | add `zodValidator(schema)` |

## Red Flags - STOP and Fix

- `@tanstack/react-start` is present but the Vite skill is being applied
- route or hook imports `fetch`/`axios` directly
- missing `export` on `const Route`
- page component contains inline state/query/mutation logic
- `createServerFn`, `useServerFn`, or `-functions/` appears in the route tree
- loader or route module reads secrets, DB clients, or private env values directly
- `routeTree.gen.ts` has hand edits
- search params are used without `validateSearch`
