# Route Structure

> Hono route composition rules

---

## Preferred Small Structure

```text
src/
├── app.ts
├── index.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── schemas.ts
│       └── service.ts
```

## Preferred Large Structure

```text
src/routes/
├── index.ts
├── health.ts
├── users/
│   ├── index.ts
│   ├── routes.ts
│   ├── handlers.ts
│   ├── schemas.ts
│   ├── service.ts
│   └── tests/
└── billing/
    ├── index.ts
    ├── routes.ts
    ├── handlers.ts
    ├── schemas.ts
    ├── middleware.ts
    └── service.ts
```

`routes/index.ts` or `app.ts` remains the only mount table. Feature folders own their local route definitions, handlers, schemas, and feature-only middleware.

## Rules

- `app.ts` owns root app composition
- `routes/index.ts` or `app.ts` is the single obvious mount table
- Prefer sub-apps mounted with `app.route('/users', usersApp)`
- Use a route folder when a feature needs more than one file
- Single-file routes are acceptable for tiny operational endpoints
- Split a route into a folder when it has two or more handlers, any request schema, feature middleware, OpenAPI metadata, or service orchestration
- Keep `basePath()` and API version prefixes at the composition boundary
- Do not import database clients, Drizzle schema tables, ORM drivers, or migration helpers from route modules; use services/repositories instead
- Do not import one feature route module from another feature route module
- Keep fallback and catch-all routes last because Hono dispatch follows registration order

## Mounting Pattern

```ts
import { createApp } from '@/lib/create-app'
import { healthApp } from '@/routes/health'
import { usersApp } from '@/routes/users'

export const app = createApp()
  .route('/health', healthApp)
  .route('/users', usersApp)
```

## Scale-Up Pattern

```ts
// routes/users/index.ts
import { createApp } from '@/lib/create-app'

import { createUserHandlers, listUserHandlers } from './handlers'

export const usersApp = createApp()
  .get('/', ...listUserHandlers)
  .post('/', ...createUserHandlers)
```

```ts
// routes/index.ts
import { usersApp } from './users'
import { billingApp } from './billing'

export const routesApp = createApp()
  .route('/users', usersApp)
  .route('/billing', billingApp)
```

## Non-Compliance Signatures

- Route registration is spread across unrelated files with no single mount table
- `app.route()` is absent in a multi-feature app
- Feature route folders import database/SDK clients instead of calling services
- Route handlers create DB connections, Drizzle clients, pools, or migrations directly
- A single route file contains schemas, long handlers, feature middleware, and business logic
- Fallback, `*`, or `/:id` routes appear before more specific routes
- Version prefixes are repeated inside every feature instead of defined once

## Review Checklist

- One obvious composition entry exists
- Route mounting order is intentional
- Fallback routes come last
- Large features use sub-app folders, not giant flat files
- Feature boundaries are clear enough that new routes have an obvious home
- Persistence work flows through service/repository boundaries when the route is not trivial
- Route structure still preserves typed app inference for tests, RPC, and OpenAPI generation
