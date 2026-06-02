# TanStack Start Current Docs Snapshot

- checked_at: 2026-06-02
- source: Context7 `/websites/tanstack_start_framework_react`, backed by TanStack official docs pages
- use_when: Start/Router API behavior, Start Vite plugin config, import protection, execution boundaries, or server-function API shape affects an architecture decision
- authority: Official TanStack docs for API facts; Hypercore conventions remain in `rules/`

## Official facts confirmed

### Project setup and router

- `vite.config.ts` uses `tanstackStart()` from `@tanstack/react-start/plugin/vite`; the React Vite plugin comes after the Start plugin in the official build-from-scratch guide.
- `src/router.tsx` defines `getRouter()` and imports the generated `routeTree` from `./routeTree.gen`.
- `src/routes/__root.tsx` is the root application route; `routeTree.gen.ts` is generated automatically on first run.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/routing>

### Source and route directory config

- Start projects commonly use `src/routes`, but architecture reviews must inspect `tanstackStart()` config before assuming the route root.
- Existing references in this skill track `srcDirectory` and `router.routesDirectory` as configurable Start plugin options. If package types or docs disagree in a target project, prefer local package types plus a dated note.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/build-from-scratch.md>

### Server functions and execution boundaries

- `createServerFn()` defines server functions. GET is the default; other HTTP methods such as POST can be specified with `createServerFn({ method: 'POST' })`.
- Server functions use `.handler(...)`; current guides show `.inputValidator(...)` for input validation and middleware before the handler when needed.
- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, and `createIsomorphicFn` are official execution-control primitives.
- Client hooks/components may call server functions; `useServerFn` is the React wrapper when hook ergonomics are needed.
- Sources:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
  - <https://tanstack.com/start/latest/docs/framework/react/guide/authentication.md>

### Import protection

- Import protection is enabled by default for Start source files.
- Development defaults use mock/warning behavior; production build defaults error on violations.
- Default client-side denial covers `*.server.*` and Start server specifiers; default server-side denial covers `*.client.*`; `node_modules` are excluded from these checks.
- Project-specific import protection can be configured with `tanstackStart({ importProtection: { behavior, client, server } })`.
- Side-effect marker imports remain available for explicit boundaries: `@tanstack/react-start/server-only` and `@tanstack/react-start/client-only`.
- Source:
  - <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>

## Drift handling

- Treat this file as a dated official-doc snapshot, not a permanent rulebook.
- If local installed package types disagree, run typecheck and record the project-specific exception.
- Keep `src/lib`, `src/services`, `src/db`, `src/server`, and `src/config` grouping as Hypercore conventions, not official TanStack requirements.
