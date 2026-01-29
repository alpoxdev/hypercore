# Prisma - Config File

> prisma.config.ts configuration (v7)

---

## Multi-File Schema Required Configuration

```typescript
// prisma.config.ts
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'), // Folder path
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

---

## File Location

```
project/
├── prisma.config.ts      # Project root
├── prisma/
│   ├── schema/           # Multi-File schema
│   │   ├── +base.prisma
│   │   ├── +enum.prisma
│   │   └── user.prisma
│   └── migrations/
└── src/
```

---

## Full Configuration Example

```typescript
// prisma.config.ts
import 'dotenv/config'
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'),
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

---

## +base.prisma

```prisma
// prisma/schema/+base.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"  // v7 required
  output   = "../../generated/prisma"
}
```

---

## Seed Script

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/prisma'

const prisma = new PrismaClient()

async function main() {
  await prisma.user.create({
    data: { email: 'admin@example.com', name: 'Administrator' },
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

---

## Cloudflare Workers

```prisma
// prisma/schema/+base.prisma
generator client {
  provider = "prisma-client"
  output   = "../../generated/prisma"
  runtime  = "workerd"  // Workers runtime
}

datasource db {
  provider = "sqlite"  // D1 is SQLite
  url      = env("DATABASE_URL")
}
```

---

## Related Documentation

- [Prisma Overview](./index.md)
- [Cloudflare D1](./cloudflare-d1.md)
