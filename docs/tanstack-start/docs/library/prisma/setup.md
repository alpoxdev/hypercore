# Prisma - Installation and Setup

## Installation

```bash
yarn add @prisma/client@7
yarn add -D prisma@7
npx prisma init
```

## v6 → v7 Upgrade

```prisma
// v6 (old)
generator client {
  provider = "prisma-client-js"
}

// v7 (required)
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}
```

## Prisma Client

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined }
export const prisma = globalForPrisma.prisma ?? new PrismaClient({ log: ['query'] })
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

## TanStack Start Integration

```typescript
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/lib/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany({ include: { posts: true } }))

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator((data: { email: string; name: string }) => data)
  .handler(async ({ data }) => prisma.user.create({ data }))
```
