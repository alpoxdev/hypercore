# Environment Variables Setup

> TanStack Start (Vite-based) Environment Variables Management

<instructions>
@../library/t3-env/index.md
</instructions>

---

<environment_types>

| Access Method | Location | Purpose | Exposure |
|---------------|----------|---------|----------|
| `process.env.*` | Server Function | DB, API keys, secrets | ❌ Server only |
| `import.meta.env.VITE_*` | Client + Server | Public configuration | ✅ Browser exposed |

</environment_types>

---

<file_structure>

## Environment File Structure

```
├── .env                    # Default (commit ✓)
├── .env.development        # Development (commit ✓)
├── .env.production         # Production (commit ✓)
├── .env.local              # Local override (commit ✗)
└── src/lib/env.ts          # Validation and types (t3-env)
```

| Priority | File | Description |
|----------|------|-------------|
| 1 | `.env.{mode}.local` | Highest priority (gitignore) |
| 2 | `.env.local` | Local override |
| 3 | `.env.{mode}` | Environment-specific config |
| 4 | `.env` | Default config |

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
VITE_APP_NAME=My App (Dev)
VITE_API_URL=http://localhost:3001/api
```

### .env.production

```env
NODE_ENV=production
VITE_APP_NAME=My App
VITE_API_URL=https://api.myapp.com
```

## Type-Safe Environment Variables (t3-env)

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
  },

  client: {
    VITE_APP_NAME: z.string(),
    VITE_API_URL: z.string().url(),
  },

  runtimeEnv: {
    // Server
    NODE_ENV: process.env.NODE_ENV,
    DATABASE_URL: process.env.DATABASE_URL,
    JWT_SECRET: process.env.JWT_SECRET,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,

    // Client
    VITE_APP_NAME: import.meta.env.VITE_APP_NAME,
    VITE_API_URL: import.meta.env.VITE_API_URL,
  },

  clientPrefix: 'VITE_',
})
```

## Usage Examples

### Server Function

```typescript
// services/user/queries.ts
import { createServerFn } from '@tanstack/react-start'
import { env } from '@/lib/env'
import { prisma } from '@/database/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    // env.DATABASE_URL is only available on server
    console.log('DB URL:', env.DATABASE_URL)
    return prisma.user.findMany()
  })
```

### Client Component

```tsx
// components/app-header.tsx
import { env } from '@/lib/env'

export const AppHeader = (): JSX.Element => {
  return (
    <header>
      <h1>{env.VITE_APP_NAME}</h1>
      <p>API: {env.VITE_API_URL}</p>
    </header>
  )
}
```

</patterns>

---

<gitignore>

## .gitignore

```gitignore
# Contains secrets (never commit)
.env.local
.env.*.local

# Public config (safe to commit)
!.env
!.env.development
!.env.production
```

</gitignore>

---

<typescript_types>

## TypeScript Types (Vite)

```typescript
// src/vite-env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_NAME: string
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

**Note:** Types are automatically inferred when using t3-env

</typescript_types>

---

<best_practices>

| Principle | Description |
|-----------|-------------|
| **Separate Secrets** | Store secrets only in `.env.local`, never commit |
| **Public Variables** | Use `VITE_` prefix, safe for browser exposure |
| **Type Safety** | Validate with t3-env or Zod |
| **Default Values** | Set safe defaults in `.env` |
| **Documentation** | Provide required variable list in `.env.example` |

</best_practices>

---

<sources>

- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [t3-env Documentation](https://env.t3.gg/docs/introduction)

</sources>
