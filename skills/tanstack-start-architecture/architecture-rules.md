# Architecture Rules Reference

> Rule taxonomy and blocking gate summary for hypercore TanStack Start projects.

Some rules are stricter than official TanStack defaults. Every rule should be understood as one of:

- **Official** — required or documented by TanStack.
- **Safety policy** — local blocking rule for security/runtime correctness.
- **Hypercore convention** — local/team preference that may exceed official defaults.

Brownfield adoption: touched files must satisfy applicable safety rules and current hypercore conventions. Untouched legacy style drift can be logged as migration backlog unless it creates a safety boundary issue.

## Source Priority

1. `references/official/tanstack-start-2026-04-30.md`
2. `references/official/tanstack-router-2026-04-30.md`
3. `references/official/api-drift-notes.md`
4. Topic rules under `rules/`
5. Project-local package types and tests when installed versions differ

## Blocking Safety Gates

| Surface | Classification | Block or fix when |
|---|---|---|
| Loader boundaries | Official + Safety policy | A loader assumes server-only execution or reads secrets/DB/filesystem directly |
| Server functions | Official + Safety policy | Mutation input is not validated at runtime, handler is missing, or `.validator()` is introduced despite current canonical `.inputValidator()` guidance |
| Import protection | Official + Safety policy | Import protection is disabled, config is overwritten, or server/client-only imports leak outside compiler-recognized boundaries |
| Middleware | Official + Safety policy | Client `sendContext` is trusted server-side without runtime validation |
| SSR/hydration | Official + Safety policy | First render includes unstable values without a stabilization/fallback strategy |
| Server routes | Official + Hypercore convention | Internal app RPC is implemented as server routes instead of server functions without explicit justification |
| Route export | Official | File routes do not export the route instance as `Route` |
| Route organization | Hypercore convention | Touched app pages use flat files or omit route-local folders when logic/server integration is present |
| Hooks | Hypercore convention | Touched interactive page/component logic remains inline instead of moving to `-hooks/` |
| Code style | Hypercore convention | Touched files use camelCase filenames, `any`, function declarations, missing return types, or omit required Korean block comments |

## Layer Architecture

```text
Route/Page UI
  -> route-local hooks / TanStack Query
  -> TanStack Start server functions
  -> features/<domain> or services/<provider>
  -> database/ or external SDK
```

Rules:

- **Safety policy:** Routes must not import ORM/database clients directly.
- **Hypercore convention:** Server functions should call feature/service layer code for non-trivial business logic.
- **Hypercore convention:** Simple CRUD may remain in a server function only when extracting a feature layer would add noise.

## Official-vs-Hypercore Clarifications

- TanStack Router officially supports flat, directory, and mixed route structures. Hypercore prefers route directories for app pages.
- TanStack Start import protection is enabled by default. Hypercore requires explicit extension when project-specific deny rules are needed.
- TanStack Router with Zod v4 can pass schemas directly to `validateSearch`; Zod v3 uses `@tanstack/zod-adapter`.
- Server routes are an official Start feature; hypercore reserves them for HTTP semantics, not internal app RPC.
- Publishing-only static pages do not require `-hooks/`, `-components/`, or `-functions/` unless logic/server integration is introduced.

## Topic Files

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

- Add missing route-local folders for pages with logic/server integration.
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
| Server function mutation without runtime validation | Add `.inputValidator(...)` |
| `createMiddleware()` for server function middleware | Use `createMiddleware({ type: 'function' })` |
| Server/client imports leaking across environments | Split file, add marker, or wrap in environment function |
| Static publishing page forced into empty folders | Do not add folders until logic/server integration exists |
| Internal app RPC under server route | Prefer server function unless HTTP semantics are required |

## Completion Rule

A change is complete only when `rules/validation.md` passes and any remaining official API ambiguity is recorded with exact date and source.
