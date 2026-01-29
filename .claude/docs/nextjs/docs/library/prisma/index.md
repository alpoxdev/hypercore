# Prisma

> **Version**: 7.x | Node.js/TypeScript ORM

@setup.md
@config.md
@schema.md
@crud.md
@relations.md
@transactions.md
@cloudflare-d1.md

---

## Quick Reference

```typescript
import { PrismaClient } from './generated/prisma'  // v7 path!
export const prisma = new PrismaClient()

// CRUD
const users = await prisma.user.findMany()
const user = await prisma.user.create({ data: { email, name } })
const updated = await prisma.user.update({ where: { id }, data: { name } })
const deleted = await prisma.user.delete({ where: { id } })

// With relations
const userWithPosts = await prisma.user.findUnique({
  where: { id },
  include: { posts: true },
})
```

### v7 schema.prisma (⚠️ Important)

```prisma
generator client {
  provider = "prisma-client"        // v7! (not prisma-client-js)
  output   = "../generated/prisma"  // output required!
}
```

### ⛔ Claude Code Forbidden

| Forbidden Actions |
|-------------------|
| Auto-running prisma db push |
| Auto-running prisma migrate |
| Auto-running prisma generate |
| Unauthorized schema.prisma modifications |

---

## Prisma Client Setup

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined }
export const prisma = globalForPrisma.prisma ?? new PrismaClient({ log: ['query'] })
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

## Migration Commands

```bash
npx prisma migrate dev --name init   # development migration
npx prisma migrate deploy            # production migration
npx prisma db push                   # schema sync (dev only)
npx prisma generate                  # generate client
npx prisma studio                    # GUI
```
