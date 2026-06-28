# TanStack Start Current Docs Snapshot

- checked_at: 2026-06-09
- source: Context7 `/websites/tanstack_start_framework_react`, backed by TanStack official docs pages and direct TanStack official page checks
- use_when: Start/Router API behavior, Start Vite plugin config, import protection, execution boundaries, or server-function API shape affects an architecture decision
- authority: Official TanStack docs for API facts; Hypercore conventions remain in `rules/`

## Official facts confirmed

### Project setup and router

- `vite.config.ts` uses `tanstackStart()` from `@tanstack/react-start/plugin/vite`; the React Vite plugin comes after the Start plugin in the official build-from-scratch guide.
- Current Getting Started guidance recommends TanStack Builder or the CLI path `npx @tanstack/cli@latest create`; older scaffolding commands in examples should not be treated as the primary current setup path.
- `src/router.tsx` defines `getRouter()` and imports the generated `routeTree` from `./routeTree.gen`.
- `src/routes/__root.tsx` is the root application route; `routeTree.gen.ts` is generated automatically when Start runs, including `npm run dev` or `npm run start`.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/getting-started>
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/routing>

### Source and route directory config

- Start projects commonly use `src/routes`, but architecture reviews must inspect `tanstackStart()` config before assuming the route root.
- Existing references in this skill track `srcDirectory` and `router.routesDirectory` as configurable Start plugin options. If package types or docs disagree in a target project, prefer local package types plus a dated note.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>

### Server functions and execution boundaries

- `createServerFn()` defines server functions. GET is the default; other HTTP methods such as POST can be specified with `createServerFn({ method: 'POST' })`.
- Server functions use `.inputValidator(...)` for input validation and `.handler(...)` for execution; current server-function guides show middleware before the handler when needed.
- Treat server functions as same-origin app RPC endpoints. Browser-origin server function requests are protected with Fetch Metadata, Origin, Referer checks, and CSRF middleware. If a project defines custom `src/start.ts`, it must preserve server function CSRF middleware explicitly.
- Server functions can be called from loaders, components, hooks, other server functions, and event handlers. Components/hooks can use `useServerFn()` with TanStack Query; route loaders can call server functions directly.
- Larger-app file organization guidance splits `*.functions.ts` for `createServerFn` wrappers, `*.server.ts` for DB/internal server-only helpers, and unsuffixed `.ts` for client-safe schemas/types/constants. Static imports of server functions are described as safe; dynamic imports are warned against.
- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, and `createIsomorphicFn` are official execution-control primitives.
- Client hooks/components may call server functions; `useServerFn` is the React wrapper when hook ergonomics are needed.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/authentication.md>

### Middleware

- TanStack Start has two middleware types. Request middleware uses `createMiddleware()`; `createMiddleware({ type: 'request' })` is allowed but the request type is the default.
- Server function middleware uses `createMiddleware({ type: 'function' })` and can define `.client(...)` and `.server(...)` phases.
- Server function middleware input transformation/validation also uses `.inputValidator(...)`; do not confuse middleware `.inputValidator(...)` with server-function `.inputValidator(...)` because they belong to different chain objects and data contexts.
- `sendContext` is explicit. Values sent from client middleware to server middleware must be treated as client-provided data and validated server-side before trust.
- Global request middleware is configured through `createStart(() => ({ requestMiddleware: [...] }))` in `src/start.ts`.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

### Import protection

- Import protection is enabled by default for Start source files.
- Development defaults use mock/warning behavior; production build defaults error on violations.
- Default client-side denial covers `*.server.*` and Start server specifiers; default server-side denial covers `*.client.*`; `node_modules` are excluded from these checks.
- Type-only imports and re-exports are ignored by import protection because they are erased from the runtime bundle; mixed imports still count when they include runtime values.
- Project-specific import protection can be configured with `tanstackStart({ importProtection: { behavior, client, server } })`.
- `behavior` can be a mode such as `behavior: 'error'` or a per-mode object such as `{ dev: 'mock', build: 'error' }`.
- Current options include `enabled`, `behavior`, `log`, `include`, `exclude`, `ignoreImporters`, `maxTraceDepth`, environment-specific `client`/`server` `files` and `specifiers`, `excludeFiles`, and `onViolation`.
- `excludeFiles: []` can opt an environment back into checking resolved files under locations that defaults exclude, such as `node_modules`, but this should be used deliberately to avoid false positives.
- Side-effect marker imports remain available for explicit boundaries: `@tanstack/react-start/server-only` and `@tanstack/react-start/client-only`.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

### Server routes

- Server routes are declared in route files by adding `server` to `createFileRoute(...)(...)`.
- The current shape uses a `server.handlers` object for simple method handlers or a `createHandlers` function for handlers that need middleware composition.
- `server.middleware` can apply route-level middleware to all handlers.
- Server routes follow Router file-route conventions; duplicate route paths with duplicate HTTP methods are invalid, and wildcard/splat routes use the trailing `$` file-route convention.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes>

## Drift handling

- Treat this file as a dated official-doc snapshot, not a permanent rulebook.
- If local installed package types disagree, run typecheck and record the project-specific exception.
- Keep `src/modules`, `src/lib`, `src/db`, `src/server`, `src/integrations`, and `src/config` grouping as Hypercore conventions, not official TanStack requirements.
- The `.functions.ts` / `.server.ts` split is an official server-function organization pattern; enforcing that split inside `src/modules/<domain>/<feature>/` nested folders is a Hypercore convention.
