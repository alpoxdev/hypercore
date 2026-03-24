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
| Typing | Untyped `c.set()` / `c.get()` variables across middleware/handlers |
| Errors | Missing central error policy in non-trivial APIs |
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
Repositories / External Clients
  repositories/*.ts, clients/*.ts, database/*.ts
```

**Data flow rules:**
- Transport concerns stay in routes, handlers, middleware, and response shaping
- Domain logic stays in services/use-cases
- Storage/SDK logic stays in repositories or clients
- Route modules should not grow into controller layers by default

---

## Route Structure Rules

### Recommended folder structure

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
└── repositories/
```

### Rules

- Keep one obvious app composition path
- Prefer domain sub-apps mounted with `app.route()`
- Allow single-file route modules only for small endpoints such as health checks
- Use route folders when a feature needs schemas, handlers, middleware, or service helpers
- Keep runtime-specific bootstrap outside route modules

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
- `hc<typeof app>` and `AppType` exports need stable typed app composition
- In larger applications, split by sub-apps carefully and preserve typed mounting patterns
- Do not casually break route typing with detached registration

---

## Platform Setup Rules

- Keep the runtime adapter in `index.ts`, `server.ts`, `worker.ts`, or another edge bootstrap file
- Type environment bindings and config explicitly
- Keep `showRoutes()` and similar dev helpers behind explicit dev-only setup
- Use `basePath()` / version prefixes intentionally, not ad hoc per handler

