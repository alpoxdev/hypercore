# Prisma - Config File

Prisma v7 `prisma.config.ts` configuration.

## Multi-File Schema (Required)

```typescript
// prisma.config.ts
import 'dotenv/config'
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'),  // folder path!
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## Folder Structure

```
project/
├── prisma.config.ts
├── prisma/
│   ├── schema/
│   │   ├── +base.prisma   # datasource, generator
│   │   ├── +enum.prisma   # enum definitions
│   │   └── user.prisma    # models
│   └── migrations/
```

## +base.prisma

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "../../generated/prisma"
}
```

## Configuration Options

| Option | Description |
|--------|-------------|
| `schema` | Schema folder path |
| `datasource.url` | Database URL (required) |
| `datasource.shadowDatabaseUrl` | Shadow database URL |
| `migrations.path` | Migrations folder |
| `migrations.seed` | Seed command |

## Seed File

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/prisma'

const prisma = new PrismaClient()

async function main() {
  await prisma.user.create({
    data: { email: 'admin@example.com', name: 'Admin', role: 'ADMIN' },
  })
}

main().catch(console.error).finally(() => prisma.$disconnect())
```
