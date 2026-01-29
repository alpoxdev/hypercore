# Prisma - Cloudflare D1

> SQLite-based serverless database

---

## Caveats

```
D1 does not support transactions (no ACID guarantees)
prisma migrate dev not available → use wrangler CLI
Prisma ORM D1 support is in Preview
```

---

## Quick Setup

### schema.prisma

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
  runtime  = "cloudflare"  // Required for D1
}

datasource db {
  provider = "sqlite"  // D1 is SQLite-based
}

model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
}
```

### Hono + D1

```typescript
import { Hono } from 'hono'
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

type Bindings = { DB: D1Database }

const app = new Hono<{ Bindings: Bindings }>()

app.get('/users', async (c) => {
  const adapter = new PrismaD1(c.env.DB)
  const prisma = new PrismaClient({ adapter })
  const users = await prisma.user.findMany()
  return c.json(users)
})

export default app
```

---

## Installation

```bash
npm install hono @prisma/client @prisma/adapter-d1
npm install -D prisma wrangler
npx prisma init --datasource-provider sqlite
```

---

## Create D1 Database

```bash
npx wrangler d1 create my-database
# database_id = "xxxx-xxxx-xxxx-xxxx"
```

### wrangler.jsonc

```jsonc
{
  "name": "hono-d1-app",
  "main": "src/index.ts",
  "compatibility_date": "2025-01-01",
  "d1_databases": [{
    "binding": "DB",
    "database_name": "my-database",
    "database_id": "YOUR_DATABASE_ID"
  }]
}
```

---

## Migration Workflow

```bash
# 1. Create migration file
npx wrangler d1 migrations create my-database create_user_table

# 2. Generate SQL (initial)
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script \
  --output prisma/migrations/0001_create_user_table.sql

# 3. Apply locally
npx wrangler d1 migrations apply my-database --local

# 4. Apply remotely
npx wrangler d1 migrations apply my-database --remote
```

---

## Complete CRUD API

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

type Bindings = { DB: D1Database }
type Variables = { prisma: PrismaClient }

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// Prisma middleware
app.use('*', async (c, next) => {
  const adapter = new PrismaD1(c.env.DB)
  c.set('prisma', new PrismaClient({ adapter }))
  await next()
})

app.get('/users', async (c) => {
  const users = await c.get('prisma').user.findMany()
  return c.json(users)
})

app.post('/users',
  zValidator('json', z.object({ email: z.email(), name: z.string().optional() })),
  async (c) => {
    const prisma = c.get('prisma')
    const data = c.req.valid('json')

    const existing = await prisma.user.findUnique({ where: { email: data.email } })
    if (existing) throw new HTTPException(409, { message: 'Email already exists' })

    const user = await prisma.user.create({ data })
    return c.json(user, 201)
  }
)

export default app
```

---

## Local Development

```bash
# Run worker
npx wrangler dev

# Query D1
npx wrangler d1 execute my-database --local \
  --command "SELECT * FROM User;"
```

---

## Deployment

```bash
npx prisma generate
npx wrangler d1 migrations apply my-database --remote
npx wrangler deploy
```

---

## Limitations

| Feature | D1 |
|---------|-----|
| Transactions | ❌ Not supported |
| Migrations | Use wrangler |
| Connection | HTTP (adapter) |

---

## Related Documentation

- [Prisma Overview](./index.md)
- [Cloudflare Deployment](../../deployment/cloudflare.md)
