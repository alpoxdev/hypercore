# TanStack Start Official Snapshot

- last_verified_at: 2026-04-30
- packages_checked:
  - `@tanstack/react-start`: `1.167.52`
  - `@tanstack/start-plugin-core`: `1.169.7`
  - `@tanstack/router-plugin`: `1.167.29`
- source_priority: canonical guide pages > API/reference pages > examples > migration/comparison pages > release notes for drift context

Use this file when Start-specific API behavior affects an architecture rule. Keep hypercore conventions in `rules/`; keep official facts here.

## Official Facts Used By This Skill

### Router setup

- Start's React routing guide expects `src/router.tsx` to export a `getRouter()` function that returns a fresh router instance each call.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/routing>

### Server functions

- Canonical server function examples use `createServerFn({ method })`, optional `.inputValidator(...)`, optional `.middleware(...)`, then `.handler(...)`.
- Zod schemas can be passed directly to `.inputValidator(...)` in the current canonical server-functions guide.
- Server functions can throw errors, redirects, and not-found responses that are handled through route lifecycles or component calls using `useServerFn()`.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>

### Execution model

- Start code is isomorphic unless explicitly constrained.
- Route loaders are not server-only; they may execute on the server during SSR and on the client during navigation.
- Secrets, DB access, filesystem access, and privileged SDK calls must live behind server-only/server-function boundaries.
- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, and `createIsomorphicFn` are the relevant execution-control primitives.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/execution-model>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns>

### Import protection

- Import protection is enabled by default in TanStack Start.
- Defaults include client denial for `**/*.server.*` and Start server specifiers, and server denial for `**/*.client.*`.
- File markers are side-effect imports: `@tanstack/react-start/server-only` and `@tanstack/react-start/client-only`.
- Custom project deny rules can be added through `tanstackStart({ importProtection: { client, server, behavior } })`.
- Setting `importProtection: { enabled: false }` disables protection and should require an explicit user decision.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

### Middleware

- Request middleware can use `createMiddleware()`; server-function middleware uses `createMiddleware({ type: 'function' })`.
- Client context is not sent to the server by default. `sendContext` must be explicit.
- Dynamic/user-generated `sendContext` values need server-side validation before trust.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

### Server routes

- Server routes are an official Start feature for HTTP endpoints and can be defined alongside app routes via `createFileRoute(... )({ server: { handlers } })`.
- Use server routes for raw HTTP semantics such as webhooks, health/readiness, auth provider endpoints, files, and machine-readable public endpoints.
- Hypercore discourages server routes for internal app RPC; use server functions for that team policy.
- Source: <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes>

### SSR and hydration

- Routes render with SSR by default unless configured otherwise.
- Route-level `ssr` and app-level `defaultSsr` control selective SSR behavior.
- Hydration errors commonly come from locale/time-zone differences, `Date.now()`, random IDs, responsive-only logic, feature flags, and user preferences.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/selective-ssr>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/hydration-errors>

## Refresh Triggers

Refresh this snapshot when:

- TanStack Start reaches or changes stable v1 guidance.
- `createServerFn`, `.inputValidator()`, middleware, import protection, `getRouter()`, or SSR options change.
- This skill starts relying on a new Start guide page.
- Local package versions move materially beyond the versions above.
