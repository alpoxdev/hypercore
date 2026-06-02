# Route Structure

> Hono route composition rules

---

## Preferred Structure

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

## Rules

- `app.ts` owns root app composition
- `routes/index.ts` or `app.ts` is the single obvious mount table
- Prefer sub-apps mounted with `app.route('/users', usersApp)`
- Use a route folder when a feature needs more than one file
- Single-file routes are acceptable for tiny operational endpoints

## Mounting Pattern

```ts
import { createApp } from '@/lib/create-app'
import { healthApp } from '@/routes/health'
import { usersApp } from '@/routes/users'

export const app = createApp()
  .route('/health', healthApp)
  .route('/users', usersApp)
```

## Review Checklist

- One obvious composition entry exists
- Route mounting order is intentional
- Fallback routes come last
- Large features use sub-app folders, not giant flat files

