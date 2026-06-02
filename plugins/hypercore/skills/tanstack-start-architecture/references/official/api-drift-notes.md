# TanStack API Drift Notes

- last_verified_at: 2026-04-30
- purpose: Record official-doc conflicts and source-priority decisions so core skill rules do not overfit stale examples.

## Source Priority

1. Current canonical guide for the exact API area.
2. Current API/reference page for the exact symbol.
3. Package types/source in the installed project.
4. Recent release notes that explain a rename or migration.
5. Examples, comparisons, migration guides, and blog posts.

When sources conflict, do not silently pick the convenient one. Record the conflict with exact date and source links.

## `.inputValidator()` vs `.validator()`

Decision as of 2026-04-30:

- Treat `.inputValidator()` as canonical for Start server functions.
- Treat `.validator()` examples in some current docs as stale or lower-priority until package types prove otherwise.
- If editing a real project, verify against the installed `@tanstack/react-start` version before making broad migrations.

Evidence:

- Canonical Server Functions guide uses `.inputValidator(...)`: <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions>
- GitHub v1.145.1 release notes include “Rename validator to inputValidator in fetch functions”: <https://github.com/TanStack/router/releases/tag/v1.145.1>
- Some current pages still include `.validator(...)` snippets, including Server Components and comparison/migration content: <https://tanstack.com/start/latest/docs/framework/react/guide/server-components>

Skill implication:

- `rules/services.md` should block new `.validator(...)` usage unless a project-local type check proves that the installed version requires it.
- The core `SKILL.md` should not repeat long API history; point here instead.

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
