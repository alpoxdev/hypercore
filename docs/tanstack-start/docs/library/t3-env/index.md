# t3-env - Type-Safe Environment Variables

> Zod-based type-safe environment variable management

<context>

**Purpose:** Server/client environment variable separation, runtime validation, type safety

**Features:**
- Zod schema validation + type inference
- Prevent server variables from being exposed to client
- Transform & default value support
- Framework-agnostic

</context>

---

<forbidden>

| Category | Forbidden |
|------|------|
| **Exposure** | Exposing server variables to client |
| **Prefix** | Using client variables without `PUBLIC_` |
| **Direct Access** | Direct `process.env` access (use env object) |
| **Type** | Accessing env variables with any type |

</forbidden>

---

<required>

| Category | Required |
|------|------|
| **Install** | `@t3-oss/env-core zod` |
| **Structure** | Create `src/env.ts` file |
| **Prefix** | Client variables: Start with `PUBLIC_` |
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
  // Server-only variables
  server: {
    DATABASE_URL: z.url(),
    CLERK_SECRET_KEY: z.string().min(1),
    OPENAI_API_KEY: z.string().min(1),
  },

  // Client-exposed variables (PUBLIC_ prefix required)
  clientPrefix: 'PUBLIC_',
  client: {
    PUBLIC_API_URL: z.url().default('http://localhost:3000'),
    PUBLIC_CLERK_PUBLISHABLE_KEY: z.string().min(1),
  },

  // Runtime environment
  runtimeEnv: {
    // Server
    DATABASE_URL: process.env.DATABASE_URL,
    CLERK_SECRET_KEY: process.env.CLERK_SECRET_KEY,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
    // Client
    PUBLIC_API_URL: import.meta.env.PUBLIC_API_URL,
    PUBLIC_CLERK_PUBLISHABLE_KEY: import.meta.env.PUBLIC_CLERK_PUBLISHABLE_KEY,
  },

  emptyStringAsUndefined: true,
})
```

</setup>

---

<patterns>

## Common Patterns

### Server Function

```typescript
import { createServerFn } from '@tanstack/start'
import { env } from '@/env'

export const getUsers = createServerFn({ method: 'GET' }).handler(async () => {
  const db = await prisma.$connect(env.DATABASE_URL)
  //                                    ^? string (type-safe)
  return db.user.findMany()
})
```

### Client Component

```typescript
import { env } from '@/env'

export const ApiClient = () => {
  const apiUrl = env.PUBLIC_API_URL
  //                  ^? string (type-safe)

  // ❌ Error: server variables cannot be accessed in client
  // const dbUrl = env.DATABASE_URL
}
```

### Environment-Specific Defaults

```typescript
server: {
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
}
```

### Transform Values

```typescript
server: {
  PORT: z.string().transform((val) => parseInt(val, 10)).pipe(z.number().positive()),
  MAX_CONNECTIONS: z.coerce.number().default(10),
}
```

### Optional with Fallback

```typescript
client: {
  PUBLIC_ANALYTICS_ID: z.string().optional(),
  PUBLIC_FEATURE_FLAG: z.coerce.boolean().default(false),
}
```

</patterns>

---

<tips>

## Tips

| Situation | Method |
|------|------|
| **Vercel** | `process.env.VERCEL_URL` → PUBLIC_APP_URL |
| **Monorepo** | Separate `env.ts` per package |
| **Testing** | `.env.test` + `NODE_ENV=test` |
| **CI/CD** | GitHub Secrets → Environment Variables |

</tips>
