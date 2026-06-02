# Project Structure and Shared Code Organization

> Official Next.js project structure rules plus repo-local organization guidance for nested shared folders such as `src/lib` and `src/services`.

---

## Top-Level Structure

| Folder | Meaning |
|---|---|
| `app/` or `src/app/` | App Router route tree and App Router special files |
| `pages/` or `src/pages/` | Pages Router route tree for legacy or Pages-only surfaces |
| `public/` | Static assets served from the site root |
| `src/` | Optional application source root that separates source code from project configuration |
| `lib/`, `src/lib/`, `services/`, or `src/services/` | Repo-local shared code convention, not a Next.js routing convention |

Keep `next.config.*`, `package.json`, `tsconfig.json`, lockfiles, and `.env*` files at the project root unless the tool's own docs say otherwise. Do not assume `.env*` files load from `src/`.

## Routing vs Organization

Next.js routing is file-system based, but not every folder has the same meaning:

- In `app/` or `src/app/`, folders define route segments unless they are route groups, private folders, or special non-routing conventions.
- A folder such as `(marketing)` is a route group. It organizes routes and layouts without changing the URL.
- A folder such as `_components`, `_lib`, `_actions`, or `_queries` is a private folder. Use private folders for segment-local implementation details that must not be treated as routes.
- Files can be colocated inside App Router segments, but private folders make intent clearer and reduce future naming conflicts.

Do not expose implementation-only folders as URL segments. If a helper folder lives under `app/`, prefer `_folder` naming unless the folder is meant to be a route segment or a route group.

## Shared Code Placement

For code shared across multiple routes, use the repo's existing convention first while keeping runtime and domain boundaries visible. Common valid shapes include:

```text
src/
├── app/
├── components/
├── lib/
│   ├── auth/
│   └── cache/
├── services/
│   ├── billing/
│   └── stripe/
├── server/
└── db/
```

or, in a root-based project:

```text
app/
components/
lib/
services/
server/
db/
```

Treat these shared folders as repo-local conventions, not framework law. When reporting or reviewing, say "repo-local convention" for preferences such as `src/lib/auth` or `src/services/billing` unless the official Next.js docs require the behavior. This nested shared-folder shape is not official Next.js requirement.

## Nested Shared Folder Grouping Policy

Do not add new direct leaf files such as `src/lib/foo.ts`, `src/services/foo.ts`, `lib/foo.ts`, or `services/foo.ts` when touched shared code is added or reorganized unless an explicit project exception is recorded. Prefer nested grouping that makes ownership, runtime boundaries, provider integrations, or domain logic clear.

Use ownership paths such as `src/lib/<domain>/...` and `src/services/<domain-or-provider>/...` for new touched shared code unless the project records a narrower convention.

Prefer nested grouping when any of these are true:

- any new touched shared code would otherwise be placed as a direct file under `src/lib`, `src/services`, `lib`, `services`, `src/server`, or `src/db`
- the folder has three or more files with different responsibilities
- files naturally split by domain, provider, layer, or external integration
- server-only modules, DAL code, schemas, DTOs, cache tags, and permissions are mixed together
- repeated action/query/helper patterns are emerging across routes
- imports become ambiguous because unrelated helpers sit side by side

Example nested shared shape:

```text
src/
├── lib/
│   ├── auth/
│   │   ├── session.ts
│   │   ├── permissions.ts
│   │   └── dto.ts
│   └── cache/
│       ├── tags.ts
│       └── revalidate.ts
├── services/
│   ├── billing/
│   │   ├── actions.ts
│   │   ├── queries.ts
│   │   └── schema.ts
│   └── stripe/
│       └── client.server.ts
└── db/
    ├── client.server.ts
    └── repositories/
        └── user-repository.ts
```

Small existing folders may remain flat when that is simpler, but new touched shared files should still be grouped unless an explicit exception is recorded. Do not create deep hierarchy only for unrelated one-off files.

## Boundary Naming Guidance

Use names that reveal runtime and architectural boundaries:

| Pattern | Use for |
|---|---|
| `_components/` | segment-local UI implementation under `app/` |
| `_lib/` | segment-local helpers under `app/` |
| `_actions/` | segment-local Server Actions under `app/` |
| `actions.ts` | reusable or domain-specific Server Actions |
| `queries.ts` | server-side read helpers |
| `schema.ts` | validation or data shape definitions |
| `dto.ts` | client-safe view models and return values |
| `permissions.ts` | authorization checks |
| `cache/tags.ts` | cache tag names and invalidation helpers |

Add `import 'server-only'` to modules that must never enter the client graph, especially DB clients, DAL modules, secret-bearing SDK wrappers, and authorization helpers.

## Hard Rules

| Check | Rule |
|---|---|
| Implementation-only folder under `app/` is exposed as a route segment | BLOCKED unless it is intentionally routable |
| Touched shared root would add a direct leaf file such as `src/lib/foo.ts` or `src/services/foo.ts` without an exception | WARNING. Move into a logical nested folder |
| Flat `lib` / `services` layout hides mixed server/client, domain, provider, or security boundaries in touched code | WARNING. Prefer nested grouping |
| Shared code placement is presented as official Next.js law when it is only a repo-local convention | BLOCKED |
| New nested folders create circular imports or unclear public entry points | WARNING/BLOCKED by risk |
| Server-only shared code lacks a clear server boundary | WARNING, or BLOCKED if client import risk exists |

## Review Checklist

- Top-level `app`, `pages`, `public`, and optional `src` usage matches the detected router mode.
- `app` segment internals use private folders when they are not route segments.
- Route groups are used for organization or layout sharing, not URL changes.
- New touched shared code avoids direct leaf files under `src/lib`, `src/services`, `lib`, `services`, `src/server`, or `src/db` unless an explicit exception is recorded.
- Shared `src/lib` / `src/services` code uses nested domain, provider, or layer grouping when it improves boundaries.
- Flat shared folders are not forced when nested grouping would be clearer, and the choice is labelled as repo-local convention.
- Framework-required rules and repo-local conventions are labeled separately.
- Server-only shared modules have `import 'server-only'` or an equally clear boundary.
