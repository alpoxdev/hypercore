# Architecture Rules Reference

> Complete rule set for Hono hypercore projects

Note: some rules below are stricter than Hono defaults. They are hypercore team conventions, not universal framework requirements.

Brownfield adoption rule: untouched legacy code may be tracked as migration work instead of an immediate failure if the issue is stylistic or hypercore-specific. Safety, typing, validation, and transport-boundary issues still block immediately, especially in touched code.

---

## Forbidden

| Category | Forbidden |
|----------|-----------|
| Controllers | Introducing controller-heavy classes/files when simple route modules or handler factories are enough |
| Routes | Scattered registration with no clear composition entry |
| Order | Registering fallback/catch-all routes before specific routes |
| Validation | Repeated raw `c.req.json()` parsing in non-trivial handlers |
| Database | Importing DB/ORM clients, Drizzle schema tables, pools, or migration helpers directly from routes/handlers |
| Migrations | Generating, pushing, or running database migrations from request handlers |
| Typing | Untyped `c.set()` / `c.get()` variables across middleware/handlers |
| Errors | Missing central error policy in non-trivial APIs |
| OpenAPI | Public API route changes without matching OpenAPI/Swagger contract updates when the repo publishes docs |
| RPC | Breaking `AppType` / `testClient` / `hc` inference by losing chained types |
| Platform | Mixing runtime adapter/bootstrap code into route modules |
| Filenames | camelCase (`userProfile.ts`, `createUser.ts`) |
| TypeScript | `any` type, `function` declaration when a const arrow function is appropriate |
| Git | AI markers, emojis, multi-line commit messages |

---

## Layer Architecture

```text
Runtime Edge / Adapter
  index.ts / server.ts / worker.ts
       |
       v
Hono App Composition
  app.ts -> app.route('/users', usersApp)
       |
       v
Route Modules / Handlers
  routes/<domain>/index.ts
       |
       v
Services / Use Cases
  services/<domain>/*.ts
       |
       v
Repositories / External Clients / Database Boundary
  repositories/<domain>/*.ts, clients/*.ts
  database/client.ts, database/schema.ts, drizzle/migrations
```

**Data flow rules:**
- Transport concerns stay in routes, handlers, middleware, and response shaping
- Domain logic stays in services/use-cases
- Storage/SDK logic stays in repositories or clients
- Database connection setup, ORM configuration, schemas, and migrations stay in the database boundary
- Routes do not import database clients, Drizzle table definitions, driver clients, or migration helpers directly
- Route modules should not grow into controller layers by default

---

## Route Structure Rules

### Recommended small API structure

```text
src/
├── app.ts
├── index.ts
├── lib/
│   └── create-app.ts
├── middlewares/
│   ├── auth.ts
│   └── request-id.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── schemas.ts
│       └── service.ts
├── services/
├── repositories/
└── database/
    ├── client.ts
    └── schema.ts
```

Use this shape for small APIs and early projects. It keeps the mount table visible while leaving room for feature folders.

### Recommended medium/large API structure

```text
src/
├── app.ts
├── index.ts
├── lib/
│   ├── create-app.ts
│   ├── env.ts
│   └── types.ts
├── middlewares/
│   ├── auth.ts
│   ├── error-boundary.ts
│   └── request-id.ts
├── openapi/
│   ├── components.ts
│   ├── errors.ts
│   └── registry.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── routes.ts
│       ├── schemas.ts
│       ├── service.ts
│       └── tests/
├── services/
│   └── users/
├── repositories/
│   └── users/
├── database/
│   ├── client.ts
│   ├── schema.ts
│   └── types.ts
├── drizzle/
│   └── migrations/
└── clients/
```

Use this shape when multiple feature areas, generated docs, typed clients, or runtime bindings are part of the app contract.

### Feature growth thresholds

| Size | Structure |
|------|-----------|
| Tiny operational endpoint | One file such as `routes/health.ts` is acceptable. |
| Small feature | `routes/<feature>/index.ts` plus local `schemas.ts` or `handlers.ts`. |
| Medium feature | Split `handlers.ts`, `schemas.ts`, and `service.ts`; mount the feature through `routes/index.ts` or `app.ts`. |
| Large feature | Add local `routes.ts` / OpenAPI metadata, local middleware if needed, tests near the feature, and repository/service boundaries for persistence work. |

### Rules

- Keep one obvious app composition path
- Prefer domain sub-apps mounted with `app.route()`
- Allow single-file route modules only for small endpoints such as health checks
- Use route folders when a feature needs schemas, handlers, middleware, or service helpers
- Keep runtime-specific bootstrap outside route modules
- Keep database clients, ORM schema tables, and migrations outside route modules
- For large APIs, keep `app.ts` / `routes/index.ts` as the mount table and avoid feature-to-feature route imports
- Keep shared OpenAPI components outside feature folders, but keep feature operation metadata near the route it describes

## Scalability Rules

- Scale by feature boundaries first, not by controller classes.
- A route module should orchestrate transport, validation, service calls, and response shaping; it should not own persistence or third-party SDK details.
- Shared middleware belongs in `middlewares/`; feature-only middleware can live under `routes/<feature>/`.
- Shared schemas, error envelopes, and OpenAPI components should be centralized only when at least two features reuse them.
- Database clients and ORM setup belong in `database/` or a runtime/platform factory, not in handlers.
- Repositories hide query details and should not read Hono `Context`, headers, cookies, or request bodies.
- Transaction boundaries belong in services/use-cases when multiple writes must commit or roll back together.
- Drizzle schema and migration folders must match `drizzle.config.ts` and remain outside route folders.
- Public DTOs should be mapped deliberately instead of exposing raw ORM rows.
- Version prefixes such as `/api` or `/v1` belong at the composition boundary through `basePath()` or one mount table, not inside every handler.
- When migrating a brownfield app, fix safety/type/validation issues in touched files immediately and record purely structural drift as backlog when a full split would be risky.
- Large-app reviews must confirm that route composition, generated docs, and typed clients are all derived from the same exported app surface.

---

## Handler Typing Rules

### Preferred small-module pattern

```ts
const usersApp = new Hono()
  .get('/', listUsers)
  .post('/', createUser)
```

### Preferred extracted-handler pattern

```ts
const factory = createFactory<Env>()

const handlers = factory.createHandlers(listUsers, createUser)

const usersApp = factory
  .createApp()
  .get('/', ...handlers)
```

### Core rule

- If handlers are extracted, keep typing intact with `createFactory()` / `createHandlers()`
- Type `Bindings` and `Variables` explicitly when middleware or runtime context depends on them
- Keep request parsing, validation, and service orchestration readable

---

## Validation Rules

- Use validator middleware on params, query, headers, form, or json before domain logic consumes them
- Official Hono docs recommend third-party validators for stronger schemas
- Preferred options:
  - `validator()` for narrow built-in checks
  - `@hono/zod-validator` for Zod-based repos
  - `@hono/standard-validator` when the repo already standardizes on Standard Schema libraries
- Keep validation strategy consistent within a feature

## Database / ORM Rules

- Treat persistence as a separate architecture boundary, not a route implementation detail.
- Prefer `routes -> services -> repositories -> database client` for non-trivial persisted behavior.
- Use the runtime-appropriate Drizzle driver or database client; do not hardcode Node-only database setup in edge routes.
- For Cloudflare Workers/D1, database bindings should flow through typed Hono `Bindings` / `c.env`.
- For Node/serverful runtimes, pools and clients should be created at module or bootstrap scope, not per request.
- For serverless runtimes that reuse module scope, keep reusable clients and prepared statements outside handler scope when the provider supports it.
- Keep Drizzle schema and generated migrations in a stable database/migration boundary and review generated SQL before merging.
- Use explicit service-layer transactions for multi-step writes and pass the `tx` handle into repositories.
- See `rules/database.md` for detailed Drizzle, migration, transaction, DTO, and non-compliance checks.

## OpenAPI / Swagger Rules

- Treat OpenAPI as an API contract, not a decorative docs page.
- Use `@hono/zod-openapi` for Zod-first repos or `hono-openapi` when the repo already uses multiple Standard Schema-compatible validators.
- Keep the validation schema and documented schema aligned; prefer one schema source when practical.
- Publish one canonical spec endpoint such as `/doc` or `/openapi.json`.
- Serve Swagger UI from a separate route such as `/ui` and protect it according to the environment and product decision.
- Every documented operation should include stable `operationId`, `tags`, request schema, success responses, expected error responses, and useful examples.
- Put shared schemas, parameters, responses, examples, and security schemes under reusable OpenAPI components.
- In large apps, compose per-feature OpenAPI route metadata at the app boundary instead of manually copying spec fragments.
- Validate or lint the generated spec before publishing or using it for codegen.

---

## Middleware Rules

- Registration order matters; middleware and handlers run in the order they are added
- Shared auth/logging/request-id/CORS concerns belong in middleware
- `Context` is per-request; never treat `c.set()` state as cross-request storage
- Type middleware-provided variables via app/factory generics

---

## Error Handling Rules

- Add a central `app.onError()` policy in non-trivial APIs
- Use `HTTPException` or an equivalent explicit translation path for expected HTTP failures
- When rebuilding responses from `HTTPException`, preserve headers already set on `Context`
- Keep not-found handling compatible with typed RPC when the app exports a client surface

---

## Testing / RPC Rules

- `testClient()` type inference depends on route types flowing through chained app definitions
- `hc<AppType>` and `AppType` exports need stable typed app composition
- In larger applications, split by sub-apps carefully and preserve typed mounting patterns
- Do not casually break route typing with detached registration
- Use request-level tests such as `app.request()` for route behavior and typed clients for contract behavior when the app exposes RPC surfaces
- Keep explicit response statuses so RPC clients and OpenAPI docs agree on status-specific payloads

---

## Platform Setup Rules

- Keep the runtime adapter in `index.ts`, `server.ts`, `worker.ts`, or another edge bootstrap file
- Type environment bindings and config explicitly
- Keep `showRoutes()` and similar dev helpers behind explicit dev-only setup
- Use `basePath()` / version prefixes intentionally, not ad hoc per handler
