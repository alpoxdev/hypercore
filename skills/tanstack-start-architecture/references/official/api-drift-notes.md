# TanStack API Drift Notes

- last_verified_at: 2026-09-22
- purpose: Record official-doc conflicts and source-priority decisions so core skill rules do not overfit stale examples.

## Contents

- [Source Priority](#source-priority)
- [`.inputValidator()` vs stale `.validator()` examples — SUPERSEDED 2026-09-22](#inputvalidator-vs-stale-validator-examples--superseded-2026-09-22)
- [Server function `.inputValidator()` vs middleware `.inputValidator()` — SUPERSEDED 2026-09-22](#server-function-inputvalidator-vs-middleware-inputvalidator--superseded-2026-09-22)
- [Search validation and Zod adapters](#search-validation-and-zod-adapters)
- [Import protection defaults](#import-protection-defaults)
- [Official vs Hypercore routing structure](#official-vs-hypercore-routing-structure)
- [Corrected 2026-09-22: `.validator()` is canonical, `.inputValidator()` is deprecated](#corrected-2026-09-22-validator-is-canonical-inputvalidator-is-deprecated)
- [Sources](#sources)

## Source Priority

1. Current canonical guide for the exact API area.
2. Current API/reference page for the exact symbol.
3. Package types/source in the installed project.
4. Recent release notes that explain a rename or migration.
5. Examples, comparisons, migration guides, and blog posts.

When sources conflict, do not silently pick the convenient one. Record the conflict with exact date and source links.

## `.inputValidator()` vs stale `.validator()` examples — SUPERSEDED 2026-09-22 (see the corrected decision below)

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

## Server function `.inputValidator()` vs middleware `.inputValidator()` — SUPERSEDED 2026-09-22 (see the corrected decision below)

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

## Corrected 2026-09-22: `.validator()` is canonical, `.inputValidator()` is deprecated

Decision as of 2026-09-22. This supersedes both 2026-06-09 decisions above.

- Policy: `.validator(...)` is canonical, and `.inputValidator(...)` is a deprecated alias that still works.
- Evidence, three independent surfaces, all re-checked 2026-09-22:
  1. Docs: `guide/server-functions.md` uses `.validator(...)` throughout (7 occurrences, zero `inputValidator`); `guide/middleware.md:34` reads ``Input Validation | No | Yes (`.validator()`)``, and `:232` is headed "The `.validator` method".
  2. Pinned source at `fe7f1fd0e6ef73c3f341dd2338b406749538a85d`: `packages/start-client-core/src/createServerFn.ts:511` carries ``/** @deprecated Use `validator` instead. */`` above `inputValidator`, `createMiddleware.ts:182-183` carries the same marker, and `createServerFn.ts:921` reads `const validator = options.validator ?? options.inputValidator`. The alias is still resolved at runtime, which is why it still works.
  3. Release: PR #7566 "rename inputValidator to validator" merged 2026-06-06T21:05:57Z with 212 changed files, and shipped in `@tanstack/react-start@1.168.25`, published 2026-06-06T21:43:40Z.
- The skill recorded the opposite three days AFTER the rename merged: `last_verified_at` was 2026-06-09, and the two decisions above call `.validator(...)` examples version drift. That pass was wrong, not merely stale. The inverted decisions stay above, marked SUPERSEDED, because how the skill got this wrong is the useful part of this log.
- `rules/services.md:18` links this file, so that link now points at the corrected direction rather than the inverted one.

## Sources

> Sources checked 2026-09-22, the date this file records as `last_verified_at`; each decision above is dated and names the TanStack page it rests on. The 2026-09-22 pass re-fetched every source cited in the corrected section and claims no source outside this file.
