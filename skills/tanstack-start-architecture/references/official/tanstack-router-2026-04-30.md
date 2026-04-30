# TanStack Router Official Snapshot

- last_verified_at: 2026-04-30
- packages_checked:
  - `@tanstack/react-router`: `1.168.26`
  - Context7 indexed version observed: `v1_114_3` for repository docs, cross-checked with live latest docs.
- source_priority: latest docs pages > API pages > examples

Use this file when Router behavior affects route, search, loader, context, or SSR rules.

## Official Facts Used By This Skill

### File routes and `Route` export

- File-based routes are configured with `createFileRoute(path)(options)`.
- The generated file route instance must be exported using the `Route` identifier for `tsr generate` and `tsr watch` to work correctly.
- Sources:
  - <https://tanstack.com/router/latest/docs/api/router/createFileRouteFunction>
  - <https://tanstack.com/router/latest/docs/routing/routing-concepts>

### Flat and directory routes

- Router officially supports directory routes, flat routes, and mixed flat/directory structures.
- Hypercore may still prefer route directories for app pages, but that is a team convention, not an official Router requirement.
- Source: <https://tanstack.com/router/latest/docs/routing/file-based-routing>

### Route lifecycle and loading

- The loading lifecycle proceeds through matching/search validation, serial `beforeLoad`, and parallel route loading with `loader` and component preload.
- `beforeLoad` is appropriate for context, auth, and redirects that need serial ordering.
- `loader` is appropriate for data loading and participates in Router caching/preloading semantics.
- Slow loader UI can use `pendingComponent`; the default pending threshold is configurable.
- Source: <https://tanstack.com/router/latest/docs/guide/data-loading>

### Search parameter validation

- TanStack Router supports schema-based search validation.
- With Zod v4, a Zod schema can be used directly in `validateSearch`.
- With Zod v3, use `@tanstack/zod-adapter` (`zodValidator`, `fallback`).
- If a project intentionally standardizes on `zodValidator` for both versions, label that as a hypercore convention.
- Sources:
  - <https://tanstack.com/router/latest/docs/how-to/validate-search-params>
  - <https://tanstack.com/router/latest/docs/how-to/setup-basic-search-params>

### Router context

- Root route context can be typed with `createRootRouteWithContext`.
- `beforeLoad` can extend route context and the resulting context is available to loaders and child routes.
- Source: <https://tanstack.com/router/latest/docs/guide/router-context>

### SSR

- TanStack Start is the recommended SSR setup for React Router users who need full-stack framework behavior.
- Manual Router SSR exists, but Start handles most setup details.
- Source: <https://tanstack.com/router/latest/docs/how-to/setup-ssr>

## Refresh Triggers

Refresh this snapshot when:

- Router file naming conventions or route generation requirements change.
- Search validation guidance changes for Zod/adapter usage.
- Loader/beforeLoad lifecycle or pending behavior changes.
- Local package versions move materially beyond the versions above.
