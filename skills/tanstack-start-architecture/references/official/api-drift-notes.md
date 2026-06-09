# TanStack API Drift Notes

- last_verified_at: 2026-06-09
- purpose: Record official-doc conflicts and source-priority decisions so core skill rules do not overfit stale examples.

## Source Priority

1. Current canonical guide for the exact API area.
2. Current API/reference page for the exact symbol.
3. Package types/source in the installed project.
4. Recent release notes that explain a rename or migration.
5. Examples, comparisons, migration guides, and blog posts.

When sources conflict, do not silently pick the convenient one. Record the conflict with exact date and source links.

## `.inputValidator()` vs stale `.validator()` examples

Decision as of 2026-06-09:

- Treat `.inputValidator(...)` as the current official Server Functions guide API for `createServerFn` input validation.
- Treat `.validator(...)` examples in older or lower-priority content as version drift unless project-local installed types prove otherwise.
- If editing a real project, verify against the installed `@tanstack/react-start` version before making broad migrations.

Evidence:

- Current Server Functions guide uses `.inputValidator(...)`: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- Current Middleware guide uses `.inputValidator(...)` for server function middleware-owned data validation: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>
- Some older history and examples mention `.validator(...)`; use them as drift context, not as current `latest` docs authority.

Skill implication:

- `rules/services.md` should recommend `.inputValidator(...)` for new current-docs work.
- `rules/middleware.md` should recommend `.inputValidator(...)` for server function middleware-owned data validation.
- For existing projects, verify package types before replacing `.validator(...)`; this skill should not perform broad API migrations from docs alone.
- The core `SKILL.md` should not repeat long API history; point here instead.

## Server function `.inputValidator()` vs middleware `.inputValidator()`

Decision as of 2026-06-09:

- Treat `.inputValidator(...)` as current official API for both `createServerFn` input validation and server-function middleware data validation.
- Do not conflate the two uses. They share a method name but belong to different chain objects and receive different data/context.
- Do not migrate middleware-owned validation based on server-function examples, or server-function validation based on middleware examples, without checking the local chain type.

Evidence:

- Current Server Functions guide uses `.inputValidator(...)`: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- Current Middleware guide lists server function middleware validation as `.inputValidator(...)`: <https://tanstack.com/start/latest/docs/framework/react/guide/middleware>

Skill implication:

- `rules/services.md` owns server function `.inputValidator(...)` guidance.
- `rules/middleware.md` owns middleware `.inputValidator(...)`, request middleware `createMiddleware()`, and server function middleware `createMiddleware({ type: 'function' })` guidance.

## Search validation and Zod adapters

Decision as of 2026-04-30:

- Zod v4 can use the schema directly in `validateSearch`.
- Zod v3 should use `@tanstack/zod-adapter` with `zodValidator`/`fallback`.
- A project may standardize on the adapter as a hypercore convention, but that must be labelled as stricter than official docs.

Evidence:

- <https://tanstack.com/router/latest/docs/how-to/validate-search-params>
- <https://tanstack.com/router/latest/docs/how-to/setup-basic-search-params>

## Import protection defaults

Decision as of 2026-04-30:

- Import protection is enabled by default in Start.
- Explicit config is still required when the project needs additional deny rules for directories such as database/server/client or packages such as ORM clients.
- Disabling import protection remains a blocking safety issue unless explicitly requested.

Evidence: <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection>

## Official vs Hypercore routing structure

Decision as of 2026-04-30:

- Router supports flat, directory, and mixed route file structures.
- Hypercore's route-directory preference is a local convention for maintainability and should not be described as official TanStack behavior.

Evidence: <https://tanstack.com/router/latest/docs/routing/file-based-routing>
