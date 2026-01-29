# Prisma v7 - Database ORM

> Type-safe database ORM

@config.md
@cloudflare-d1.md

---

## Version Notice

```prisma
generator client {
  provider = "prisma-client"      // ✅ v7 (not prisma-client-js!)
  output   = "./generated/client" // ✅ output required
}
```

---

## Prohibited Actions

| Command | Description |
|---------|-------------|
| `prisma db push` | Do not auto-run |
| `prisma migrate` | Do not auto-run |
| `prisma generate` | Do not auto-run |
| Schema changes | Only as requested |

---

## Installation

```bash
npm install prisma-client
npm install -D prisma
```

---

## Multi-File Structure (Required)

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # enum definitions
├── user.prisma     # User model (Korean comments required)
└── post.prisma     # Post model
```

### +base.prisma

```prisma
// datasource, generator configuration
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "./generated/client"
}
```

### user.prisma

```prisma
// User model
model User {
  id        String   @id @default(cuid())
  email     String   @unique   // Login email
  name      String?            // Display name
  posts     Post[]             // Authored posts
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

---

## Prisma Client

```typescript
import { PrismaClient } from '../prisma/generated/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

---

## CRUD

### Create

```typescript
const user = await prisma.user.create({
  data: { email: 'user@example.com', name: 'John' },
})

// With relations
const userWithPosts = await prisma.user.create({
  data: {
    email: 'user@example.com',
    posts: { create: [{ title: 'Post 1' }] },
  },
  include: { posts: true },
})
```

### Read

```typescript
const user = await prisma.user.findUnique({ where: { id } })
const user = await prisma.user.findUniqueOrThrow({ where: { id } })
const users = await prisma.user.findMany({
  where: { name: { not: null } },
  orderBy: { createdAt: 'desc' },
  take: 10,
})

// Include relations
const userWithPosts = await prisma.user.findUnique({
  where: { id },
  include: { posts: { where: { published: true } } },
})
```

### Update

```typescript
const user = await prisma.user.update({
  where: { id },
  data: { name: 'New Name' },
})

// Upsert
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { name: 'Updated' },
  create: { email: 'user@example.com', name: 'New' },
})
```

### Delete

```typescript
await prisma.user.delete({ where: { id } })
await prisma.user.deleteMany({ where: { email: { contains: '@test.com' } } })
```

---

## Filtering

```typescript
await prisma.user.findMany({
  where: {
    age: { gt: 18, lte: 65 },           // Comparison
    email: { contains: '@gmail.com' },  // String
    AND: [{ email: { contains: '@' } }, { name: { not: null } }],
    OR: [{ role: 'admin' }, { role: 'moderator' }],
    id: { in: ['id1', 'id2'] },         // Array
    posts: { some: { published: true } }, // Relations
  },
})
```

---

## Transactions

```typescript
// Sequential
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: 'user@example.com' } }),
  prisma.post.create({ data: { title: 'New Post', authorId: 'user-id' } }),
])

// Interactive
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } })
  if (!user) throw new Error('User not found')
  return tx.post.create({ data: { title: 'Post', authorId: user.id } })
})
```

---

## Usage with Hono

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'

const app = new Hono()

app.post('/users',
  zValidator('json', z.object({ email: z.email(), name: z.string().optional() })),
  async (c) => {
    const data = c.req.valid('json')

    const existing = await prisma.user.findUnique({ where: { email: data.email } })
    if (existing) {
      throw new HTTPException(409, { message: 'Email already exists' })
    }

    const user = await prisma.user.create({ data })
    return c.json({ user }, 201)
  }
)

app.get('/users/:id', async (c) => {
  const user = await prisma.user.findUnique({
    where: { id: c.req.param('id') },
    include: { posts: true },
  })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})
```

---

## Related Documentation

- [Config Files](./config.md) - prisma.config.ts configuration
- [Cloudflare D1](./cloudflare-d1.md)
