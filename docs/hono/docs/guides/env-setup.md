# Environment Variables

> Managing Hono environment variables (Node.js, Cloudflare Workers)

<instructions>
@../library/t3-env/index.md
</instructions>

---

<runtime_differences>

| Runtime | Environment Access | Use Case |
|---------|-------------------|----------|
| **Node.js** | `process.env.*` | General server |
| **Cloudflare Workers** | `c.env.*` (Bindings) | Edge Runtime |
| **Deno** | `Deno.env.get()` | Deno Runtime |
| **Bun** | `process.env.*` | Bun Runtime |

</runtime_differences>

---

<file_structure>

## Environment File Structure

```
├── .env                    # Defaults (commit YES)
├── .env.development        # Development (commit YES)
├── .env.production         # Production (commit YES)
├── .env.local              # Local override (commit NO)
└── src/lib/env.ts          # Validation & types (t3-env)
```

| Priority | File | Description |
|----------|------|-------------|
| 1 | `.env.{mode}.local` | Highest priority (gitignore) |
| 2 | `.env.local` | Local override |
| 3 | `.env.{mode}` | Environment-specific |
| 4 | `.env` | Defaults |

</file_structure>

---

<patterns>

## Environment File Examples

### .env.local (gitignore, secrets)

```env
DATABASE_URL=postgresql://user:password@localhost:5432/myapp
JWT_SECRET=your-super-secret-jwt-key-at-least-32-chars
OPENAI_API_KEY=sk-xxx
```

### .env.development

```env
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
```

### .env.production

```env
NODE_ENV=production
PORT=8080
LOG_LEVEL=info
```

## Node.js Environment Variables

### Type-safe Environment Variables (t3-env)

```typescript
// src/lib/env.ts
import { createEnv } from '@t3-oss/env-core'
import { z } from 'zod'

export const env = createEnv({
  server: {
    NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
    DATABASE_URL: z.string().url(),
    JWT_SECRET: z.string().min(32),
    OPENAI_API_KEY: z.string().optional(),
    PORT: z.coerce.number().default(3000),
  },

  runtimeEnv: process.env,
})
```

### Usage Example

```typescript
// src/index.ts
import { Hono } from 'hono'
import { env } from './lib/env'

const app = new Hono()

app.get('/', (c) => {
  return c.json({
    env: env.NODE_ENV,
    port: env.PORT,
  })
})

export default {
  port: env.PORT,
  fetch: app.fetch,
}
```

## Cloudflare Workers Environment Variables

### Bindings Type Definition

```typescript
// src/types/index.ts
export type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
  OPENAI_API_KEY?: string
}
```

### wrangler.toml

```toml
name = "my-hono-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
NODE_ENV = "production"

# Set secrets with wrangler secret put command
# wrangler secret put DATABASE_URL
# wrangler secret put JWT_SECRET
```

### Usage Example

```typescript
// src/index.ts
import { Hono } from 'hono'
import type { Bindings } from './types'

const app = new Hono<{ Bindings: Bindings }>()

app.get('/', (c) => {
  // Access environment variables via c.env
  const dbUrl = c.env.DATABASE_URL
  const jwtSecret = c.env.JWT_SECRET

  return c.json({
    hasDb: !!dbUrl,
    hasJwt: !!jwtSecret,
  })
})

export default app
```

### Using in Middleware

```typescript
// src/middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'
import type { Bindings } from '@/types'

type Variables = {
  userId: string
}

export const authMiddleware = createMiddleware<{
  Bindings: Bindings
  Variables: Variables
}>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  if (!token) throw new HTTPException(401, { message: 'Unauthorized' })

  // Use JWT Secret
  const jwtSecret = c.env.JWT_SECRET
  // JWT verification logic...

  c.set('userId', 'user-id')
  await next()
})
```

## Cloudflare Workers Secrets Management

```bash
# Add secret
wrangler secret put DATABASE_URL
wrangler secret put JWT_SECRET

# List secrets
wrangler secret list

# Delete secret
wrangler secret delete DATABASE_URL
```

</patterns>

---

<gitignore>

## .gitignore

```gitignore
# Contains secrets (NEVER commit)
.env.local
.env.*.local

# Cloudflare Workers
.dev.vars

# Public config (commit OK)
!.env
!.env.development
!.env.production
```

</gitignore>

---

<typescript_types>

## TypeScript Types

### Node.js

```typescript
// src/env.d.ts
declare global {
  namespace NodeJS {
    interface ProcessEnv {
      NODE_ENV: 'development' | 'production' | 'test'
      DATABASE_URL: string
      JWT_SECRET: string
      OPENAI_API_KEY?: string
      PORT?: string
    }
  }
}

export {}
```

### Cloudflare Workers

```typescript
// src/types/index.ts
export type Bindings = {
  // Database
  DATABASE_URL: string

  // Auth
  JWT_SECRET: string

  // External APIs
  OPENAI_API_KEY?: string

  // KV Namespaces (Cloudflare)
  MY_KV: KVNamespace

  // D1 Database (Cloudflare)
  DB: D1Database
}
```

</typescript_types>

---

<best_practices>

| Principle | Description |
|-----------|-------------|
| **Separate Secrets** | Store secrets only in `.env.local`, never commit |
| **Type Safety** | Validate with t3-env or Zod |
| **Defaults** | Set safe defaults in `.env` |
| **Documentation** | Provide required variables list via `.env.example` |
| **Runtime Differences** | Node.js uses `process.env`, Cloudflare uses `c.env` |

</best_practices>

---

<cloudflare_specific>

## Cloudflare Workers Additional Features

### KV Namespace

```typescript
// wrangler.toml
[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-id"

// Usage
app.get('/cache/:key', async (c) => {
  const key = c.req.param('key')
  const value = await c.env.MY_KV.get(key)
  return c.json({ key, value })
})
```

### D1 Database

```typescript
// wrangler.toml
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-db-id"

// Usage
app.get('/users', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM users').all()
  return c.json({ users: results })
})
```

</cloudflare_specific>

---

<sources>

- [Hono Environment Variables](https://hono.dev/guides/env)
- [Cloudflare Workers Environment Variables](https://developers.cloudflare.com/workers/configuration/environment-variables/)
- [t3-env Documentation](https://env.t3.gg/docs/introduction)

</sources>
