# CLAUDE.md - Hono

> Ultra-lightweight framework based on Web Standards

<instructions>
@../../commands/git.md
@docs/guides/getting-started.md
@docs/library/hono/index.md
@docs/library/prisma/index.md
@docs/library/t3-env/index.md
@docs/library/zod/index.md
</instructions>

---

<forbidden>

| Category | Prohibited |
|----------|------------|
| **Git** | `Generated with Claude Code`, `🤖`, `Co-Authored-By:`, multi-line commits, emojis |
| **Prisma** | Auto-run `db push/migrate/generate`, arbitrary schema changes |
| **API** | Manual validation/auth in handlers, throwing generic Error |
| **Search** | grep, rg, find |

</forbidden>

---

<required>

| Task | Required |
|------|----------|
| Before work | Read related docs (API→hono, DB→prisma) |
| Code search | ast-grep |
| Complex tasks | Sequential Thinking MCP |
| 3+ file changes | gemini-review |
| Validation | zValidator, HTTPException error handling |
| Code writing | UTF-8, Korean comments per code block, Prisma Multi-File all elements commented |

</required>

---

<tech_stack>

| Technology | Version | Notes |
|------------|---------|-------|
| Hono | Latest | - |
| TypeScript | 5.x | strict |
| Prisma | **7.x** | `prisma-client`, output required |
| Zod | **4.x** | `z.email()`, `z.url()` |

</tech_stack>

---

<structure>
```
src/
├── routes/
│   ├── index.ts       # Root routes
│   ├── users.ts       # /users/*
│   └── posts.ts       # /posts/*
├── middleware/        # Auth, CORS, Logger
├── services/          # Business logic
├── lib/
│   ├── prisma.ts
│   └── env.ts
└── types/
```

Common logic → `src/services/`, route-specific logic → individual route files
</structure>

---

<conventions>

File naming: kebab-case
TypeScript: const declarations, explicit return types, interface (objects)/type (unions), any→unknown
Import order: external → internal → relative paths → types

Prisma Multi-File:
```
prisma/schema/
├── +base.prisma   # datasource, generator
├── +enum.prisma   # enums
└── [model].prisma # per-model files (Korean comments!)
```

</conventions>

---

<quick_patterns>

```typescript
// App + Error handler
import { Hono } from 'hono'
import { HTTPException } from 'hono/http-exception'

type Bindings = { DATABASE_URL: string }

const app = new Hono<{ Bindings: Bindings }>()

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: err.message }, err.status)
  }
  console.error(err)
  return c.json({ error: 'Internal Server Error' }, 500)
})

export default app
```

```typescript
// Zod v4 + Validation
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional()
})

app.post('/users', zValidator('json', schema), (c) => {
  const data = c.req.valid('json')
  return c.json({ user: data }, 201)
})
```

```typescript
// Middleware
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

export const authMiddleware = createMiddleware(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  if (!token) throw new HTTPException(401, { message: 'Unauthorized' })

  c.set('userId', decoded.sub)
  await next()
})

// Usage
app.use('/api/*', authMiddleware)
```

```prisma
// +base.prisma (Prisma 7.x)
generator client {
  provider = "prisma-client"
  output   = "./generated/client"
}
```

</quick_patterns>

---

<docs_structure>
```
docs/
├── guides/       # getting-started, conventions, env-setup
├── library/      # hono, prisma, t3-env, zod
└── deployment/   # cloudflare, docker, railway, vercel
```
</docs_structure>
