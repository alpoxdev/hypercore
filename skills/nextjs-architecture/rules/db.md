# Database and Drizzle Boundaries

> Drizzle schema, config, migrations, connection lifecycle, relations, validation integrations, and Next.js server-boundary placement.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Drizzle schema is TypeScript source of truth | Official Drizzle fact | Keep schema exported and discoverable by `drizzle.config.ts` |
| `drizzle.config.ts` owns `schema` and `out` | Official Drizzle fact | Verify config points at the chosen schema and migration folder |
| `generate` + `migrate` committed SQL flow | Official Drizzle workflow | Prefer unless the repo explicitly uses `push`, `pull`, or another workflow |
| Connections/prepared statements outside handler scope | Official Drizzle serverless guidance | Apply where runtime can reuse module scope |
| DB folder placement under `src/db` | Hypercore local convention | Label as local convention, not official Next.js or Drizzle law |
| DB access from client hooks/components | Safety policy | Block |

## Default Next.js + Drizzle Shape

This is a Hypercore local convention:

```text
src/
├── db/
│   ├── client.server.ts
│   ├── schema/
│   │   ├── users.ts
│   │   ├── invoices.ts
│   │   └── relations.ts
│   ├── repositories/
│   │   └── users.server.ts
│   └── migrations/             # only if the repo chooses src-local output
├── modules/
├── services/
└── integrations/
drizzle.config.ts
drizzle/                        # default Drizzle Kit migration out
```

Next.js does not mandate `src/db`, and Drizzle does not mandate a Next.js folder shape. The invariant is that schema files are exported and reachable by Drizzle Kit, runtime DB access is server-only, and migration output matches local policy.

## Schema and Config

- Drizzle schema is the TypeScript source of truth for queries and migrations.
- Schema may be single-file or multi-file. Multi-file schemas must export tables, enums, relations, and other models needed by Drizzle Kit.
- `drizzle.config.ts` must point `schema` at the chosen schema file, folder, glob, or array.
- `out` controls migration output and defaults to `drizzle`.
- If the repo uses multiple databases or dialects, use explicit config names and do not hide cross-database assumptions in one generic `db.ts`.

## Migrations

Default committed SQL flow:

```bash
drizzle-kit generate
drizzle-kit migrate
```

Rules:

- Commit generated SQL migrations when the repo follows codebase-first migrations.
- Treat `drizzle-kit push` as a schema-push alternative for explicit local/dev or project-approved workflows, not as a silent replacement for reviewed migrations.
- Treat `drizzle-kit pull` as a database-first/introspection workflow and record when it is the project standard.
- Do not run production migrations from a Route Handler, Server Action, hook, or request lifecycle path.

## Runtime and Connection Lifecycle

- Put Drizzle client creation in a server-only module such as `src/db/client.server.ts`.
- Add `import 'server-only'` or an equivalent boundary to DB client and repository modules.
- Declare connection objects and prepared statements outside request handler scope when the runtime can reuse module scope.
- Verify runtime compatibility before using DB code in Edge runtime surfaces. Many SQL drivers require Node.js runtime or provider-specific serverless drivers.
- Server Components may call server-only DAL/repository functions. Client Components and hooks must not import DB modules.

## Relations, RQB, and Repositories

- If using Drizzle relational queries, initialize `drizzle()` with the schema/tables/relations required by RQB.
- Keep relation definitions near schema exports or in a clearly named schema relation file.
- Repository helpers should hide query details and return DTO-ready data, not raw broad rows for client output.
- Transaction-capable helpers should accept a transaction/client parameter when shared by multi-step writes.

## Validation Integrations

Drizzle validation integrations include zod, valibot, typebox, arktype, typebox-legacy, and effect-schema. Use them to derive or align request validation, insert/update validation, and DTO schemas when that reduces drift.

Do not treat Drizzle table definitions as sufficient user-input validation by themselves. Server Actions and Route Handlers still validate untrusted input at their boundary.

## Review Checklist

- [ ] `drizzle.config.ts` points to exported schema files and the intended migration `out` folder.
- [ ] Schema source of truth is clear, whether single-file or multi-file.
- [ ] Migration workflow is explicit: `generate` + `migrate`, `push`, `pull`, or documented project alternative.
- [ ] DB client, repositories, schema-sensitive helpers, and prepared statements stay server-only.
- [ ] Connections/prepared statements are not recreated inside request handlers when module reuse is available.
- [ ] RQB usage registers the required schema/tables/relations at `drizzle()` initialization.
- [ ] Validation integrations are used deliberately and do not replace boundary validation.
- [ ] Folder placement is labelled Hypercore local convention, not official Next.js law.

## Sources

> No external sources were used in this file. Drizzle behavior is delegated to `references/official/drizzle-docs.md`, and Next.js server-boundary behavior to `references/official/nextjs-docs.md` (last verified 2026-05-24). Repository-local links checked 2026-09-21.
