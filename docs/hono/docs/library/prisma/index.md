# Prisma v7 - Database ORM

> Type-safe 데이터베이스 ORM

@config.md
@cloudflare-d1.md

---

## 버전 주의

```prisma
generator client {
  provider = "prisma-client"      // ✅ v7 (prisma-client-js 아님!)
  output   = "./generated/client" // ✅ output 필수
}
```

---

## 금지 사항

| 명령 | 설명 |
|------|------|
| `prisma db push` | 자동 실행 금지 |
| `prisma migrate` | 자동 실행 금지 |
| `prisma generate` | 자동 실행 금지 |
| schema 변경 | 요청된 것만 |

---

## 설치

```bash
npm install prisma-client
npm install -D prisma
```

---

## Multi-File 구조 (필수)

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # enum 정의
├── user.prisma     # User 모델 (한글 주석 필수)
└── post.prisma     # Post 모델
```

### +base.prisma

```prisma
// datasource, generator 설정
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
// 사용자 모델
model User {
  id        String   @id @default(cuid())
  email     String   @unique   // 로그인 이메일
  name      String?            // 표시 이름
  posts     Post[]             // 작성 게시글
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

// 관계와 함께
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

// 관계 포함
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

## 필터링

```typescript
await prisma.user.findMany({
  where: {
    age: { gt: 18, lte: 65 },           // 비교
    email: { contains: '@gmail.com' },  // 문자열
    AND: [{ email: { contains: '@' } }, { name: { not: null } }],
    OR: [{ role: 'admin' }, { role: 'moderator' }],
    id: { in: ['id1', 'id2'] },         // 배열
    posts: { some: { published: true } }, // 관계
  },
})
```

---

## 트랜잭션

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

## Hono와 함께 사용

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

## 관련 문서

- [Config 파일](./config.md) - prisma.config.ts 설정
- [Cloudflare D1](./cloudflare-d1.md)
