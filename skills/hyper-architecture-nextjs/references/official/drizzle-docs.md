# Official Drizzle Docs Summary

> Version-sensitive Drizzle facts for Next.js architecture decisions. Re-check official docs before changing package-specific import paths or migration commands.

last_verified_at: 2026-07-04

## Source URLs

- `https://orm.drizzle.team/docs/sql-schema-declaration`
- `https://orm.drizzle.team/docs/drizzle-config-file`
- `https://orm.drizzle.team/docs/migrations`
- `https://orm.drizzle.team/docs/drizzle-kit-generate`
- `https://orm.drizzle.team/docs/drizzle-kit-migrate`
- `https://orm.drizzle.team/docs/drizzle-kit-push`
- `https://orm.drizzle.team/docs/drizzle-kit-pull`
- `https://orm.drizzle.team/docs/relations`
- `https://orm.drizzle.team/docs/rqb`
- `https://orm.drizzle.team/docs/perf-serverless`
- `https://orm.drizzle.team/docs/zod`
- `https://orm.drizzle.team/docs/valibot`
- `https://orm.drizzle.team/docs/typebox`
- `https://orm.drizzle.team/docs/arktype`
- `https://orm.drizzle.team/docs/effect-schema`

## Official Facts

1. Drizzle schema is declared in TypeScript and acts as the source of truth for queries and migrations.
2. Schema can be single-file or multi-file. Tables, enums, relations, and other models must be exported so Drizzle Kit can import them.
3. `drizzle.config.ts` uses `schema` for the schema file/folder/glob/array and `out` for the migration output folder.
4. `out` defaults to `drizzle`.
5. The codebase-first committed SQL flow is `drizzle-kit generate` followed by `drizzle-kit migrate`.
6. `drizzle-kit push` and `drizzle-kit pull` are documented alternatives for schema push and database-first/introspection workflows.
7. Drizzle serverless performance guidance recommends declaring connection and prepared statement objects outside handler scope when the runtime can reuse module scope.
8. Drizzle relations and RQB require the relevant schema/tables/relations to be available at `drizzle()` initialization when using relational queries.
9. Drizzle validation integrations include zod, valibot, typebox, arktype, typebox-legacy, and effect-schema.

## Next.js Architecture Implications

- `src/db/schema`, `src/db/repositories`, and `src/db/client.server.ts` are Hypercore local conventions, not Drizzle or official Next.js requirements.
- The project should choose one discoverable schema path and make `drizzle.config.ts` point at it.
- DB client creation and repository helpers belong in server-only modules. Client Components and client hooks must not import them.
- Server Components may call server-only DAL/repository functions directly. Route Handlers should be reserved for HTTP-native endpoints, not internal data bridges.
- Server Actions must still validate input and re-check auth/authz before Drizzle writes, even when Drizzle validation integrations derive insert/update schemas.
- Record whether the repo uses `generate` + `migrate`, `push`, `pull`, or another migration policy before changing migration folders or scripts.

## Drift Watchlist

- Re-check exact Drizzle Kit CLI command names and config properties against the installed `drizzle-kit` version.
- Re-check dialect-specific driver imports and runtime support before changing serverless, Edge, Neon, D1, Turso/libSQL, or Postgres connection code.
- Re-check validation integration package names and generation APIs before adding new generated schemas.

## Sources

> Links checked 2026-07-04, the date carried by this file's own `last_verified_at` marker. This snapshot records no separate page-verification date, so that marker is the date this file was last reviewed. No page was re-fetched in this pass, and no source outside the URLs listed above is claimed.

| Claim | Source |
|---|---|
| The Drizzle behavior recorded in "Official Facts" above | the `orm.drizzle.team` documentation pages listed under "Source URLs" |
| The placement and boundary guidance in "Next.js Architecture Implications" above | those same Drizzle pages plus `references/official/nextjs-docs.md` for the Next.js server-boundary rules; the `src/db/...` naming is a Hypercore local convention, not an official requirement |
