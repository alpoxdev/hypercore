---
name: tanstack-start-architecture
description: Use when working on TanStack Start projects - enforces architecture rules (layers, routes, hooks, server functions, conventions) with mandatory validation before any code change. Triggers on file creation, route work, server function writing, hook patterns, or any structural change in a TanStack Start codebase.
---

# TanStack Start Architecture Enforcement

## Overview

Enforces hypercore TanStack Start architecture rules with 100% compliance. Validates project structure, then applies strict layer/route/hook/convention rules to every code change.

**This skill is RIGID. Follow exactly. No exceptions.**

**REQUIRED:** When working on TanStack Start projects, ALWAYS use this skill together with `/oh-my-claudecode:ralph` to guarantee 100% architecture compliance. Ralph's persistence loop ensures every rule is verified and no violation slips through.

**CRITICAL:** TanStack Start import protection is mandatory. You MUST enforce client/server import boundaries, verify `vite.config.ts`, and add or extend `importProtection` when it is missing or incomplete. Do not silently rely on defaults when the project needs explicit deny rules.

**NOTE:** Some rules in this skill are stricter than TanStack Start defaults. Treat them as hypercore team conventions unless the user explicitly asks to follow official TanStack defaults instead.

## Step 1: Project Validation

Before any work, confirm TanStack Start project:

```bash
# Check for TanStack Start indicators (ANY of these)
ls app.config.ts 2>/dev/null        # TanStack Start config
grep -r "@tanstack/react-start" package.json 2>/dev/null
grep -r "@tanstack/react-router" package.json 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

If NONE found: **STOP. This skill does not apply.** Inform user.

If found: proceed with architecture enforcement.

## Step 2: Read Architecture Rules

Load the detailed rules reference:

**REQUIRED:** Read `architecture-rules.md` in this skill directory before writing any code.

For detailed patterns and examples, also read the relevant reference files:
- `rules/conventions.md` - Code conventions (naming, TypeScript, imports, comments)
- `rules/routes.md` - Route structure (folder rules, patterns, loaders)
- `rules/services.md` - Server Functions (schemas, queries, mutations, middleware)
- `rules/hooks.md` - Custom Hook patterns (separation rules, internal order)
- `rules/import-protection.md` - Client/server import boundary enforcement, markers, `vite.config.ts` configuration
- `rules/middleware.md` - Middleware validation, context propagation, and `sendContext` security
- `rules/execution-model.md` - Server/client/isomorphic execution boundaries
- `rules/server-routes.md` - When HTTP endpoints are allowed instead of Server Functions
- `rules/ssr-hydration.md` - SSR mode, `ClientOnly`, and hydration-safety rules
- `rules/platform.md` - `getRouter()`, env typing/validation, path aliases, operational endpoints

## Step 3: Pre-Change Validation Checklist

Before writing ANY code, verify your planned change against these gates:

### Brownfield Adoption Rule

- Do not treat every legacy deviation as an immediate project-wide failure
- Safety issues still block immediately, especially in touched files
- Hypercore-specific style/structure drift in untouched legacy code can be recorded as migration backlog
- Any file you touch should be brought into compliance unless that would require a materially risky migration

### Gate 1: Layer Violations

```
Routes -> Server Functions -> Features -> Database
```

| Check | Rule |
|-------|------|
| Route accessing DB directly? | BLOCKED. Must go through Server Functions -> Features |
| Route calling Prisma? | BLOCKED. Use Server Functions |
| Server Function skipping Features? | ALLOWED only for simple CRUD |
| Client calling Server Function directly? | BLOCKED. Use TanStack Query (exception: `loader`/`beforeLoad` run server-side, can call directly) |

### Gate 2: Route Structure

| Check | Rule |
|-------|------|
| Flat file route? (`routes/users.tsx`) | BLOCKED. Use folder (`routes/users/index.tsx`) |
| Missing `-components/` folder? | BLOCKED. Every page needs it |
| Missing `-hooks/` folder? | BLOCKED. Every page needs it |
| Missing `-functions/` folder? | BLOCKED. Every page needs it |
| `const Route` without `export`? | BLOCKED. Must be `export const Route` |
| Logic in page component? | BLOCKED. Extract to `-hooks/` |
| Layout route missing `route.tsx`? | BLOCKED. Routes needing beforeLoad/loader must have `route.tsx` |
| Route with search params but no `validateSearch`? | BLOCKED. Must use `zodValidator` with `validateSearch` |
| Route without `pendingComponent`? | WARNING. Recommended for all routes with loaders |
| New `/api` route for normal app logic? | BLOCKED. Use Server Functions instead |
| `/api` route required by `better-auth` or webhook/health/integration HTTP semantics? | ALLOWED with explicit justification |

### Gate 3: Server Functions

| Check | Rule |
|-------|------|
| POST/PUT/PATCH without `inputValidator`? | BLOCKED |
| Auth-required without `middleware`? | BLOCKED |
| Using `.validator()` instead of `.inputValidator()`? | BLOCKED. `.validator()` does not exist |
| handler not last in chain? | BLOCKED. handler must ALWAYS be last (middleware/inputValidator order is flexible) |
| Missing `zodValidator` adapter for search params? | BLOCKED. Use `zodValidator` from `@tanstack/zod-adapter` |
| Direct server function call in component? | BLOCKED. Use `useServerFn` hook from `@tanstack/react-start` |
| `functions/index.ts` barrel export? | BLOCKED. Tree shaking failure |

### Gate 4: Hooks

| Check | Rule |
|-------|------|
| Hook inside page component? | BLOCKED. Must be in `-hooks/` folder |
| Wrong hook order? | BLOCKED. State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect |
| Missing return type interface? | BLOCKED |
| camelCase hook filename? | BLOCKED. Use `use-kebab-case.ts` |

### Gate 5: Conventions

| Check | Rule |
|-------|------|
| camelCase filename? | BLOCKED. Use kebab-case |
| `function` keyword? | BLOCKED. Use const arrow function |
| `any` type? | BLOCKED. Use `unknown` |
| Missing explicit return type? | BLOCKED |
| Wrong import order? | BLOCKED. External -> @/ -> Relative -> Type |
| Missing Korean block comments? | BLOCKED for code groups |
| Using `z.string().email()` pattern? | BLOCKED. Use Zod 4.x `z.email()` directly |

### Gate 6: Execution Model

| Check | Rule |
|-------|------|
| Treating `loader` as server-only? | BLOCKED. `loader` is isomorphic by default |
| Secret/DB/filesystem access directly inside `loader` or other client-reachable code? | BLOCKED. Move behind `createServerFn` / `createServerOnlyFn` |
| Browser-only APIs used in server-capable code without `ClientOnly` / client-only boundary? | BLOCKED |
| Manual `typeof window` branching where environment functions are clearer? | WARNING. Prefer `createClientOnlyFn` / `createServerOnlyFn` / `createIsomorphicFn` |

### Gate 7: Import Protection

| Check | Rule |
|-------|------|
| Client-reachable code imports `*.server.*`? | BLOCKED |
| Server execution path imports `*.client.*`? | BLOCKED |
| Environment-specific file missing `.server.*` / `.client.*` suffix or marker import? | BLOCKED. Rename or add `server-only` / `client-only` marker |
| `vite.config.ts` missing `tanstackStart({ importProtection: ... })` when custom directory denies are needed? | BLOCKED. Add or extend config first |
| Existing `importProtection` config overwritten instead of extended? | BLOCKED |
| `importProtection` disabled? | BLOCKED unless user explicitly requested it |
| Server-only import survives outside `createServerFn` / `createServerOnlyFn` boundary? | BLOCKED. Split file or wrap with `createServerOnlyFn` |

**Import protection is not optional.** If `vite.config.ts` already contains `tanstackStart()`, update the existing plugin config instead of duplicating plugins or removing other options.

### Gate 8: SSR / Hydration

| Check | Rule |
|-------|------|
| First render outputs unstable values (`Date.now()`, random IDs, locale-only differences)? | BLOCKED unless stabilized |
| Browser-only widget SSR'd without `ClientOnly` or SSR restriction? | BLOCKED |
| Route uses `ssr: false` / `ssr: 'data-only'` without fallback strategy? | BLOCKED |
| Root SSR reduced without understanding `shellComponent`? | BLOCKED |

### Gate 9: Platform Setup

| Check | Rule |
|-------|------|
| `src/router.tsx` missing `getRouter()` fresh-instance pattern? | BLOCKED |
| Env values used without clear client/server boundary? | BLOCKED |
| Env typing/runtime validation missing in non-trivial app setup? | WARNING. Add `src/env.d.ts` and validation |
| Path alias setup assumes Vite behavior without explicit config? | BLOCKED. Configure for Vite version in use |

## Step 3.5: Auto-Remediation Policy

Auto-fix directly when the issue is local, reversible, and low-risk.

- Add or extend `importProtection` in `vite.config.ts`
- Add `getRouter()` fresh-instance pattern in `src/router.tsx`
- Add env typing/runtime validation scaffolding
- Add missing marker imports or explicit boundary wrappers
- Add middleware validation for untrusted `sendContext`

Do not auto-apply broad or potentially breaking migrations without explicit justification.

- Mass route/file renames
- Sweeping `/api` to Server Function refactors
- SSR mode changes across many routes
- Alias-wide import rewrites

## Step 4: Implementation (with Ralph)

When used with ralph, every PRD story MUST include these acceptance criteria:

```
- [ ] Layer architecture respected (no layer skipping)
- [ ] Route uses folder structure with -components/, -hooks/, -functions/
- [ ] export const Route = createFileRoute(...) used
- [ ] Server Functions use correct chaining (handler always last, middleware/inputValidator flexible)
- [ ] Search params use zodValidator from @tanstack/zod-adapter
- [ ] Custom Hooks in -hooks/ with correct internal order
- [ ] All filenames kebab-case
- [ ] Execution model rules verified (`loader` isomorphic, env boundaries explicit)
- [ ] Import protection rules verified (`*.server.*` / `*.client.*`, markers, no leaky imports)
- [ ] Server routes, if present, are justified by actual HTTP semantics
- [ ] SSR/hydration rules verified (`ClientOnly`, `ssr`, deterministic first render)
- [ ] `src/router.tsx` uses `getRouter()` and platform setup is explicit
- [ ] `vite.config.ts` preserves or extends `tanstackStart({ importProtection: ... })`
- [ ] Korean block comments present
- [ ] const arrow functions with explicit return types
```

## Step 5: Post-Change Verification

After writing code, verify:

1. **Structure check**: `ls` the route folder - confirm `-components/`, `-hooks/`, `-functions/` exist
2. **Export check**: grep for `export const Route` in route files
3. **Layer check**: no Prisma imports in route files
4. **Convention check**: no camelCase filenames, no `function` keyword declarations
5. **Hook order check**: read hook files, verify State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect
6. **Execution model check**: no secret/DB access in unbounded loaders, browser-only APIs stay client-only
7. **Import boundary check**: no client-reachable `*.server.*`, no server-side `*.client.*`, markers used where suffixes are absent
8. **SSR/hydration check**: unstable UI stabilized, `ClientOnly`/`ssr` used deliberately
9. **Platform check**: `src/router.tsx` uses `getRouter()`, env typing/validation and path aliases are explicit
10. **Vite config check**: confirm `vite.config.ts` keeps or extends `importProtection` and does not disable it

## Quick Reference: Folder Structure

```
src/
├── routes/                    # File-based routing
│   └── <page>/
│       ├── index.tsx          # Page (UI only)
│       ├── route.tsx          # Layout (beforeLoad, loader)
│       ├── -components/       # REQUIRED: page components
│       ├── -hooks/            # REQUIRED: page hooks (ALL logic here)
│       ├── -functions/        # REQUIRED: page server functions
│       └── -sections/         # Optional: 200+ line pages
├── features/<domain>/         # Internal domain (Prisma queries)
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
├── services/<provider>/       # External SDK wrappers
├── functions/                 # Global server functions (NO index.ts!)
│   └── middlewares/
├── database/                  # Prisma client singleton
├── stores/                    # Zustand stores
├── hooks/                     # Global hooks
├── components/                # Shared UI
│   ├── ui/                    # shadcn/ui
│   ├── layout/                # Header, Sidebar, Footer
│   └── shared/                # Common components
├── types/                     # Global types
├── env/                       # t3-env validation
├── config/                    # auth, query-client, sentry
└── lib/                       # Utilities
    ├── utils/
    ├── constants/
    └── validators/
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `routes/users.tsx` | `routes/users/index.tsx` |
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| `.validator(schema)` | `.inputValidator(schema)` |
| Logic in page component | Extract to `-hooks/use-*.ts` |
| `lib/db` or `lib/store` folders | Use `database/` and `stores/` |
| `functions/index.ts` barrel | Import directly from individual files |
| Hook with mixed order | Follow: State -> Global -> Server Fns -> Query -> Handlers -> Memo -> Effect |
| `getUserById.ts` filename | `get-user-by-id.ts` |
| `function doThing() {}` | `const doThing = (): ReturnType => {}` |
| Direct Zod schema in `validateSearch` | Use `zodValidator(schema)` from `@tanstack/zod-adapter` |
| Server function call without `useServerFn` | Use `useServerFn(serverFn)` in components |
| `createMiddleware()` without options | Use `createMiddleware({ type: 'function' })` |
| Missing `pendingComponent` on route | Add `pendingComponent` for loading state |
| Secret/DB access directly inside `loader` | Move behind `createServerFn` / `createServerOnlyFn` |
| Browser-only widget SSR'd directly | Wrap with `ClientOnly` or limit route SSR |
| Non-justified `/api` route handler for internal app RPC | Replace with Server Function |
| Server-only helper used outside compiler boundary | Split to `*.server.*` or wrap in `createServerOnlyFn` |
| Missing `importProtection` extension in `vite.config.ts` | Add or extend `tanstackStart({ importProtection: ... })` |
| Missing `getRouter()` fresh instance pattern | Fix `src/router.tsx` |
| Missing env typing/runtime validation in non-trivial setup | Add `src/env.d.ts` and validation |
| Path alias assumed without Vite config | Configure `tsconfigPaths` for the Vite version |

## Red Flags - STOP and Fix

- Route file importing from `@/database/prisma` directly
- Missing `export` on `const Route`
- Page component with `useState`, `useQuery` etc. inline (not in hook)
- Server function using `.validator()` instead of `.inputValidator()`
- `any` type anywhere
- camelCase filenames
- Non-justified `/api` route handlers for internal app RPC (use Server Functions instead)
- Non-justified server route for internal app RPC
- Missing `-hooks/` folder in any route
- Route using search params without `validateSearch`
- Component calling server function directly (not through `useServerFn`)
- `createMiddleware()` without `{ type: 'function' }` option
- Secret or DB access directly inside `loader`
- Browser-only API in server-capable code path
- Client-reachable file importing `*.server.*`
- Server execution path importing `*.client.*`
- Hydration-unsafe first render output
- Missing `getRouter()` fresh instance pattern in `src/router.tsx`
- `vite.config.ts` disabling `importProtection` or missing required deny rules
