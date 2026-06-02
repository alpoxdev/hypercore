# Project Structure and Shared Code Organization

> Official Next.js project structure rules plus repo-local organization guidance for nested shared folders such as `src/lib`.

---

## Top-Level Structure

| Folder | Meaning |
|---|---|
| `app/` or `src/app/` | App Router route tree and App Router special files |
| `pages/` or `src/pages/` | Pages Router route tree for legacy or Pages-only surfaces |
| `public/` | Static assets served from the site root |
| `src/` | Optional application source root that separates source code from project configuration |
| `lib/` or `src/lib/` | Repo-local shared code convention, not a Next.js routing convention |

Keep `next.config.*`, `package.json`, `tsconfig.json`, lockfiles, and `.env*` files at the project root unless the tool's own docs say otherwise. Do not assume `.env*` files load from `src/`.

## Routing vs Organization

Next.js routing is file-system based, but not every folder has the same meaning:

- In `app/` or `src/app/`, folders define route segments unless they are route groups, private folders, or special non-routing conventions.
- A folder such as `(marketing)` is a route group. It organizes routes and layouts without changing the URL.
- A folder such as `_components`, `_lib`, `_actions`, or `_queries` is a private folder. Use private folders for segment-local implementation details that must not be treated as routes.
- Files can be colocated inside App Router segments, but private folders make intent clearer and reduce future naming conflicts.

Do not expose implementation-only folders as URL segments. If a helper folder lives under `app/`, prefer `_folder` naming unless the folder is meant to be a route segment or a route group.

## Shared Code Placement

For code shared across multiple routes or features, use the repo's existing convention first. Common valid shapes include:

```text
src/
├── app/
├── components/
├── features/
├── lib/
├── server/
└── db/
```

or, in a root-based project:

```text
app/
components/
lib/
server/
db/
```

Treat these shared folders as local conventions, not framework law. When reporting or reviewing, say "repo-local convention" for preferences such as `src/features` or `src/lib/auth` unless the official Next.js docs require the behavior.

## Nested lib Grouping Policy

Do not default to a flat `lib/*.ts` or `src/lib/*.ts` layout when nested grouping would make ownership, runtime boundaries, or domain logic clearer.

Prefer nested grouping when any of these are true:

- the folder has three or more files with different responsibilities
- files naturally split by domain, feature, or external integration
- server-only modules, DAL code, schemas, DTOs, cache tags, and permissions are mixed together
- repeated action/query/helper patterns are emerging across routes
- imports become ambiguous because unrelated helpers sit side by side

Example nested `src/lib` shape:

```text
src/lib/
├── auth/
│   ├── session.ts
│   ├── permissions.ts
│   └── dto.ts
├── billing/
│   ├── actions.ts
│   ├── queries.ts
│   └── schema.ts
├── db/
│   ├── client.ts
│   └── repositories/
│       └── user-repository.ts
└── cache/
    ├── tags.ts
    └── revalidate.ts
```

Small folders may stay flat when that is simpler. Do not create deep hierarchy only for one or two unrelated files.

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
| Flat `lib` layout hides mixed server/client, domain, or security boundaries in touched code | WARNING. Prefer nested grouping |
| Shared code placement is presented as official Next.js law when it is only a repo-local convention | BLOCKED |
| New nested folders create circular imports or unclear public entry points | WARNING/BLOCKED by risk |
| Server-only shared code lacks a clear server boundary | WARNING, or BLOCKED if client import risk exists |

## Review Checklist

- Top-level `app`, `pages`, `public`, and optional `src` usage matches the detected router mode.
- `app` segment internals use private folders when they are not route segments.
- Route groups are used for organization or layout sharing, not URL changes.
- Shared `lib` / `src/lib` code may use nested domain or layer grouping when it improves boundaries.
- Flat shared folders are not forced when nested grouping would be clearer.
- Framework-required rules and repo-local conventions are labeled separately.
- Server-only shared modules have `import 'server-only'` or an equally clear boundary.
