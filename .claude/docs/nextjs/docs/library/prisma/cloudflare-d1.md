# Prisma - Cloudflare D1

SQLite-based serverless database. Different workflow from standard Prisma migrations.

⚠️ No transaction support | Cannot use prisma migrate - use wrangler instead | Preview status

## Setup

```prisma
// schema.prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
  runtime  = "cloudflare"  // required
}

datasource db {
  provider = "sqlite"
}
```

```jsonc
// wrangler.jsonc
{
  "d1_databases": [{ "binding": "DB", "database_name": "my-db", "database_id": "ID" }]
}
```

## Usage

```typescript
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

export interface Env { DB: D1Database }

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const adapter = new PrismaD1(env.DB)
    const prisma = new PrismaClient({ adapter })
    const users = await prisma.user.findMany()
    return new Response(JSON.stringify(users))
  },
}
```

## Migration Workflow

```bash
# 1. Create D1
npx wrangler d1 create my-database

# 2. Create migration
npx wrangler d1 migrations create my-database init

# 3. Generate SQL (initial)
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script --output prisma/migrations/0001.sql

# 4. Generate SQL (subsequent)
npx prisma migrate diff --from-local-d1 --to-schema-datamodel prisma/schema.prisma --script

# 5. Apply
npx wrangler d1 migrations apply my-database --local   # local
npx wrangler d1 migrations apply my-database --remote  # production

# 6. Generate client
npx prisma generate
```

## Limitations

| Feature | Regular SQLite | D1 |
|---------|----------------|-----|
| Migration | prisma migrate | wrangler d1 |
| Transaction | ✅ | ❌ |
| Connection | Direct | HTTP adapter |
