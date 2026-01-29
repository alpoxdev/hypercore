# t3-env - Type-Safe Environment Variables

> Zod-based type-safe environment variable management

<context>

**Purpose:** Server environment variable validation, runtime type safety

**Features:**
- Validation + type inference with Zod schemas
- Transform & default value support
- Runtime validation
- Framework agnostic

</context>

---

<forbidden>

| Category | Prohibited |
|----------|------------|
| **Direct Access** | Using `process.env` directly (env object required) |
| **Types** | Accessing env variables with any type |
| **Bypass Validation** | Using environment variables without schema definition |

</forbidden>

---

<required>

| Category | Required |
|----------|----------|
| **Installation** | `@t3-oss/env-core zod` |
| **Structure** | Create `src/env.ts` file |
| **Import** | `import { env } from '@/env'` |

</required>

---

<setup>

## Installation

```bash
npm install @t3-oss/env-core zod
```

## Basic Setup

`src/env.ts`:

```typescript
import { createEnv } from '@t3-oss/env-core'
import { z } from 'zod'

export const env = createEnv({
  server: {
    // Database
    DATABASE_URL: z.url(),

    // API Keys
    OPENAI_API_KEY: z.string().min(1),

    // App Config
    NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
    PORT: z.coerce.number().positive().default(3000),
  },

  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
})
```

</setup>

---

<patterns>

## Common Patterns

### Hono App

```typescript
// src/index.ts
import { Hono } from 'hono'
import { env } from '@/env'

const app = new Hono()

app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    env: env.NODE_ENV,
    //        ^? "development" | "production" | "test"
  })
})

export default {
  port: env.PORT,
  //         ^? number
  fetch: app.fetch,
}
```

### Database Connection

```typescript
import { PrismaClient } from '@prisma/client'
import { env } from '@/env'

export const prisma = new PrismaClient({
  datasourceUrl: env.DATABASE_URL,
  //                  ^? string (type-safe)
})
```

### API Routes

```typescript
import { Hono } from 'hono'
import { env } from '@/env'

const api = new Hono()

api.post('/ai/generate', async (c) => {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    headers: {
      Authorization: `Bearer ${env.OPENAI_API_KEY}`,
      //                         ^? string
    },
  })
  return c.json(await response.json())
})
```

### Environment-Specific Defaults

```typescript
server: {
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  ENABLE_CORS: z.coerce.boolean().default(true),
}
```

### Transform Values

```typescript
server: {
  PORT: z.string().transform((val) => parseInt(val, 10)).pipe(z.number().positive()),
  MAX_CONNECTIONS: z.coerce.number().default(10),
  RATE_LIMIT: z.coerce.number().max(1000),
}
```

</patterns>

---

<examples>

## Real-World Examples

### Database + Auth

```typescript
// src/env.ts
export const env = createEnv({
  server: {
    DATABASE_URL: z.url(),
    DIRECT_URL: z.url().optional(), // Prisma connection pooling

    JWT_SECRET: z.string().min(32),
    JWT_EXPIRES_IN: z.string().default('7d'),

    BCRYPT_ROUNDS: z.coerce.number().min(10).default(12),
  },
  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
})
```

### API Integration

```typescript
// src/env.ts
export const env = createEnv({
  server: {
    OPENAI_API_KEY: z.string().min(1),
    STRIPE_SECRET_KEY: z.string().min(1),
    STRIPE_WEBHOOK_SECRET: z.string().min(1),

    RESEND_API_KEY: z.string().min(1),
    FROM_EMAIL: z.email().default('noreply@example.com'),
  },
  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
})
```

### Multi-Environment

```typescript
// src/env.ts
export const env = createEnv({
  server: {
    NODE_ENV: z.enum(['development', 'production', 'test']),
    PORT: z.coerce.number().positive().default(3000),

    DATABASE_URL: z.url(),
    REDIS_URL: z.url().optional(), // Production only

    CORS_ORIGIN: z.string().url().default('http://localhost:5173'),
    ENABLE_LOGGING: z.coerce.boolean().default(true),
  },
  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
})
```

### Cloudflare Workers

```typescript
// src/env.ts
import { createEnv } from '@t3-oss/env-core'
import { z } from 'zod'

export const createWorkerEnv = (bindings: Record<string, unknown>) =>
  createEnv({
    server: {
      DATABASE_URL: z.url(),
      KV_NAMESPACE: z.unknown(), // Cloudflare KV
      R2_BUCKET: z.unknown(),    // Cloudflare R2

      API_KEY: z.string().min(1),
    },
    runtimeEnv: bindings,
    emptyStringAsUndefined: true,
  })

// Usage
export default {
  fetch(request: Request, env: Env) {
    const workerEnv = createWorkerEnv(env)
    // workerEnv.DATABASE_URL is type-safe
  },
}
```

</examples>

---

<validation>

## Validation Patterns

### Email

```typescript
server: {
  ADMIN_EMAIL: z.email(),
  SUPPORT_EMAIL: z.email().default('support@example.com'),
}
```

### URL

```typescript
server: {
  API_URL: z.url(),
  WEBHOOK_URL: z.url().optional(),
}
```

### Enum

```typescript
server: {
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']),
  DATABASE_PROVIDER: z.enum(['postgresql', 'mysql', 'sqlite']),
}
```

### Number

```typescript
server: {
  PORT: z.coerce.number().positive().default(3000),
  MAX_UPLOAD_SIZE: z.coerce.number().max(10485760), // 10MB
  RATE_LIMIT_WINDOW: z.coerce.number().min(60).default(900), // 15min
}
```

### Boolean

```typescript
server: {
  ENABLE_CACHE: z.coerce.boolean().default(true),
  DEBUG_MODE: z.coerce.boolean().default(false),
}
```

### Custom Validation

```typescript
server: {
  API_VERSION: z.string().regex(/^v\d+$/), // v1, v2, etc.
  ALLOWED_ORIGINS: z.string().transform((val) => val.split(',')),
}
```

</validation>

---

<middleware>

## Hono Middleware Integration

### Environment Validation Middleware

```typescript
import { createMiddleware } from 'hono/factory'
import { env } from '@/env'

export const envMiddleware = createMiddleware(async (c, next) => {
  // Check if env object is initialized
  if (!env.DATABASE_URL) {
    return c.json({ error: 'Server misconfigured' }, 500)
  }
  await next()
})

// Usage
app.use('*', envMiddleware)
```

### CORS with Environment

```typescript
import { cors } from 'hono/cors'
import { env } from '@/env'

app.use(
  '*',
  cors({
    origin: env.CORS_ORIGIN,
    //          ^? string
  })
)
```

</middleware>

---

<tips>

## Tips

| Scenario | Method |
|----------|--------|
| **Cloudflare** | Use `createWorkerEnv(env)` pattern |
| **Monorepo** | Separate `env.ts` per package |
| **Testing** | `.env.test` + `NODE_ENV=test` |
| **Docker** | `docker run -e DATABASE_URL=...` |
| **CI/CD** | GitHub Secrets → Environment Variables |

</tips>
