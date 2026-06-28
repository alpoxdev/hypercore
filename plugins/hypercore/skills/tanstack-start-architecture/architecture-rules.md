# Architecture Rules Reference

> Rule taxonomy and blocking gate summary for hypercore TanStack Start projects.

Some rules are stricter than official TanStack defaults. Every rule should be understood as one of:

- **Official** — required or documented by TanStack.
- **Safety policy** — local blocking rule for security/runtime correctness.
- **Hypercore convention** — local/team preference that may exceed official defaults.

Brownfield adoption: touched files must satisfy applicable safety rules and current hypercore conventions. Untouched legacy style drift can be logged as migration backlog unless it creates a safety boundary issue.

## Source Priority

1. `references/official/current-docs-2026-06-02.md`
2. `references/official/tanstack-start-2026-04-30.md`
3. `references/official/tanstack-router-2026-04-30.md`
4. `references/official/api-drift-notes.md`
5. Topic rules under `rules/`
6. Project-local package types and tests when installed versions differ

## Blocking Safety Gates

| Surface | Classification | Block or fix when |
|---|---|---|
| Loader boundaries | Official + Safety policy | A loader assumes server-only execution or reads secrets/DB/filesystem directly |
| Server functions | Official + Safety policy | Mutation input is not validated at runtime, handler is missing, installed package/API version is not respected, or auth-required RPC lacks its own auth boundary |
| Import protection | Official + Safety policy | Import protection is disabled, config is overwritten, or server/client-only imports leak outside compiler-recognized boundaries |
| Middleware | Official + Safety policy | Client `sendContext` is trusted server-side without runtime validation |
| SSR/hydration | Official + Safety policy | First render includes unstable values without a stabilization/fallback strategy |
| Server routes | Official + Hypercore convention | Internal app RPC is implemented as server routes instead of server functions without explicit justification |
| Route export | Official | File routes do not export the route instance as `Route` |
| Route organization | Hypercore convention | Touched app pages use flat files, omit needed route-local hooks/components, or treat route-local `-functions/` as the default server-function home |
| Project structure | Official + Hypercore convention + Safety policy | Review ignores custom route roots, hand-edits `routeTree.gen.ts`, treats shared folder conventions as official law, exposes server-only shared code to clients, or mixes server function wrappers/helpers |
| Hooks | Hypercore convention | Touched interactive page/component logic remains inline instead of moving to `-hooks/` |
| Code style | Hypercore convention | Touched files use camelCase filenames, `any`, function declarations, missing return types, or omit required Korean block comments |

## Layer Architecture

```text
Route/Page UI
  -> route-local hooks / TanStack Query
  -> optional route-local -functions/<resource>.functions.ts
     or modules/<domain>/<feature>/<resource>.functions.ts
  -> modules/<domain>/<feature>/<resource>.server.ts
  -> lib/<domain>, db/<domain> repositories,
     or integrations/<provider> server-only clients
  -> database/ or external SDK
```

Rules:

- **Safety policy:** Routes must not import ORM/database clients directly.
- **Hypercore convention:** Server functions should call domain module/lib layer code for non-trivial business logic.
- **Hypercore convention:** Simple CRUD may remain in a server function only when extracting a module/lib layer would add noise.
- **Safety policy:** Auth-required server functions must not rely only on route `beforeLoad`; use middleware or handler-level auth checks.
- **Hypercore convention + Safety policy:** Split `*.functions.ts` `createServerFn` wrapper entrypoints from `*.server.ts` privileged helpers and avoid mixed barrels.

## Official-vs-Hypercore Clarifications

- TanStack Router officially supports flat, directory, and mixed route structures. Hypercore prefers route directories for app pages.
- TanStack Start docs show `src/routes`, `src/router.tsx`, generated `src/routeTree.gen.ts`, `public/`, and root `vite.config.ts` as the typical project shape; nested `src/modules`, `src/lib`, `src/integrations`, and similar shared folders are Hypercore/repo-local conventions.
- TanStack Start import protection is enabled by default. Hypercore requires explicit extension when project-specific deny rules are needed.
- TanStack Start server function wrappers are static-importable RPC entrypoints. Hypercore applies the official larger-app split between `.functions.ts` wrappers and `.server.ts` server-only helpers inside the `src/modules/<domain>/<feature>/` convention.
- TanStack Router with Zod v4 can pass schemas directly to `validateSearch`; Zod v3 uses `@tanstack/zod-adapter`.
- Server routes are an official Start feature; hypercore reserves them for HTTP semantics, not internal app RPC.
- Publishing-only static pages do not require `-hooks/`, `-components/`, or `-functions/`. Add `-hooks/` or `-components/` when interactive UI grows; add `-functions/` only for route-only server actions.

## Topic Files

- `rules/project-structure.md` — Start project shape, route-root discovery, generated route tree, shared nested folder grouping, and route-local/shared server function placement.
- `rules/routes.md` — route organization, route lifecycle, search params, folder policy.
- `rules/services.md` — server functions, validation, query/mutation layering.
- `rules/hooks.md` — hook extraction and `useServerFn` wrapper policy.
- `rules/import-protection.md` — marker files, deny rules, compiler-boundary leaks.
- `rules/middleware.md` — middleware types, context propagation, `sendContext` validation.
- `rules/execution-model.md` — isomorphic/default execution model.
- `rules/server-routes.md` — server route allowlist and justifications.
- `rules/ssr-hydration.md` — SSR modes and hydration stability.
- `rules/platform.md` — router/env/alias/operational setup.
- `rules/validation.md` — final readback and trigger/resource checks.

## Auto-Remediation Policy

Auto-fix directly when the issue is local, reversible, and low-risk:

- Add missing route-local hooks/components for pages with interactive logic or extracted UI.
- Add or extend custom `importProtection` deny rules without overwriting unrelated config.
- Add `getRouter()` fresh-instance router setup.
- Add marker imports or explicit `createServerOnlyFn` / `createClientOnlyFn` boundaries.
- Add runtime validation for untrusted server function input or `sendContext`.

Do not auto-apply broad or potentially breaking migrations without a clear user request:

- Mass route/file renames.
- Sweeping server route to server function migrations.
- SSR mode changes across many routes.
- Alias-wide import rewrites.
- Database schema edits or migration commands.

## Common Mistakes To Fix In Touched Files

| Mistake | Preferred fix |
|---|---|
| `const Route = createFileRoute(...)` | `export const Route = createFileRoute(...)` |
| Treating `loader` as server-only | Move privileged work behind `createServerFn` / `createServerOnlyFn` |
| Zod v4 search params forced through adapter | Use direct schema unless project convention says adapter |
| Zod v3 search params without adapter/fallback | Use `zodValidator` / `fallback` from `@tanstack/zod-adapter` |
| Server function mutation without runtime validation | Add `.inputValidator(...)` before `.handler(...)` |
| Auth-required server function relies only on route `beforeLoad` | Add server function middleware or handler-level auth check |
| `*.functions.ts` references DB/secret helpers from a surviving export outside the handler | Split to `*.server.ts` and move usage inside handler boundary |
| `src/modules/<domain>/<feature>/index.ts` exports both `.functions.ts` and `.server.ts` | Remove barrel or split safe/server-only entrypoints |
| `createMiddleware()` with server-function-only middleware behavior | Use `createMiddleware({ type: 'function' })`; keep request middleware on `createMiddleware()` |
| Server/client imports leaking across environments | Split file, add marker, or wrap in environment function |
| Static publishing page forced into empty folders | Do not add route-local folders until interactive UI, extracted sections, or route-only server actions exist |
| Internal app RPC under server route | Prefer server function unless HTTP semantics are required |

## Completion Rule

A change is complete only when `rules/validation.md` passes and any remaining official API ambiguity is recorded with exact date and source.
