# Prisma - Cloudflare D1

> **상위 문서**: [Prisma](./index.md)

---

## ⚠️ 주의사항

Cloudflare D1은 **SQLite 기반 서버리스 데이터베이스**입니다. 일반 Prisma 마이그레이션과 **다른 워크플로우**를 사용합니다.

```
⚠️ D1은 트랜잭션을 지원하지 않음 (ACID 보장 X)
⚠️ prisma migrate dev 사용 불가 - wrangler CLI 사용
⚠️ Prisma ORM D1 지원은 Preview 상태
```

---

## 🚀 Quick Reference

```typescript
// Hono + D1 Adapter 설정
import { Hono } from 'hono'
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

type Bindings = {
  DB: D1Database
}

const app = new Hono<{ Bindings: Bindings }>()

app.get('/users', async (c) => {
  const adapter = new PrismaD1(c.env.DB)
  const prisma = new PrismaClient({ adapter })

  const users = await prisma.user.findMany()
  return c.json(users)
})

export default app
```

### schema.prisma (D1용)

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
  runtime  = "cloudflare"  // D1 필수!
}

datasource db {
  provider = "sqlite"  // D1은 SQLite 기반
}

model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
}
```

---

## 설치

```bash
# 필수 패키지
npm install hono @prisma/client @prisma/adapter-d1
npm install -D prisma wrangler

# Prisma 초기화
npx prisma init --datasource-provider sqlite
```

---

## D1 데이터베이스 생성

```bash
# Cloudflare D1 데이터베이스 생성
npx wrangler d1 create my-database

# 출력 예시:
# ✅ Successfully created DB 'my-database'
# database_id = "xxxx-xxxx-xxxx-xxxx"
```

---

## wrangler.jsonc 설정

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "hono-d1-app",
  "main": "src/index.ts",
  "compatibility_date": "2025-01-01",
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "my-database",
      "database_id": "YOUR_DATABASE_ID"
    }
  ]
}
```

---

## Schema 설정

### schema.prisma

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
  runtime  = "cloudflare"
}

datasource db {
  provider = "sqlite"
}

model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
  posts Post[]
}

model Post {
  id        Int     @id @default(autoincrement())
  title     String
  content   String?
  published Boolean @default(false)
  author    User    @relation(fields: [authorId], references: [id])
  authorId  Int
}
```

---

## 마이그레이션 워크플로우

D1은 일반 Prisma 마이그레이션(`prisma migrate dev`)을 사용하지 않습니다.

### 1단계: 마이그레이션 디렉토리 생성

```bash
mkdir -p prisma/migrations
```

### 2단계: 마이그레이션 파일 생성 (wrangler)

```bash
npx wrangler d1 migrations create my-database create_user_table
```

### 3단계: SQL 생성 (prisma migrate diff)

```bash
# 초기 마이그레이션 (빈 스키마에서)
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script \
  --output prisma/migrations/0001_create_user_table.sql

# 후속 마이그레이션 (로컬 D1에서)
npx prisma migrate diff \
  --from-local-d1 \
  --to-schema-datamodel prisma/schema.prisma \
  --script \
  --output prisma/migrations/0002_add_post_table.sql
```

### 4단계: 마이그레이션 적용

```bash
# 로컬 데이터베이스에 적용
npx wrangler d1 migrations apply my-database --local

# 원격(프로덕션) 데이터베이스에 적용
npx wrangler d1 migrations apply my-database --remote
```

### 생성된 SQL 예시

```sql
-- 0001_create_user_table.sql
-- CreateTable
CREATE TABLE "User" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "email" TEXT NOT NULL,
    "name" TEXT
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
```

---

## Hono + Prisma D1 통합

### 기본 설정

```typescript
// src/index.ts
import { Hono } from 'hono'
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

type Bindings = {
  DB: D1Database
}

const app = new Hono<{ Bindings: Bindings }>()

// Prisma 미들웨어
app.use('*', async (c, next) => {
  const adapter = new PrismaD1(c.env.DB)
  c.set('prisma', new PrismaClient({ adapter }))
  await next()
})

export default app
```

### CRUD API 구현

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

type Bindings = {
  DB: D1Database
}

type Variables = {
  prisma: PrismaClient
}

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// Prisma 미들웨어
app.use('*', async (c, next) => {
  const adapter = new PrismaD1(c.env.DB)
  c.set('prisma', new PrismaClient({ adapter }))
  await next()
})

// 스키마 정의
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).optional(),
})

const updateUserSchema = z.object({
  name: z.string().min(1).optional(),
})

// GET /users - 전체 사용자 조회
app.get('/users', async (c) => {
  const prisma = c.get('prisma')
  const users = await prisma.user.findMany({
    include: { posts: true },
  })
  return c.json(users)
})

// GET /users/:id - 단일 사용자 조회
app.get('/users/:id', async (c) => {
  const prisma = c.get('prisma')
  const id = parseInt(c.req.param('id'))

  const user = await prisma.user.findUnique({
    where: { id },
    include: { posts: true },
  })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json(user)
})

// POST /users - 사용자 생성
app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const prisma = c.get('prisma')
  const data = c.req.valid('json')

  // 중복 체크
  const existing = await prisma.user.findUnique({
    where: { email: data.email },
  })

  if (existing) {
    throw new HTTPException(409, { message: 'Email already exists' })
  }

  const user = await prisma.user.create({ data })
  return c.json(user, 201)
})

// PATCH /users/:id - 사용자 수정
app.patch('/users/:id', zValidator('json', updateUserSchema), async (c) => {
  const prisma = c.get('prisma')
  const id = parseInt(c.req.param('id'))
  const data = c.req.valid('json')

  const user = await prisma.user.update({
    where: { id },
    data,
  })

  return c.json(user)
})

// DELETE /users/:id - 사용자 삭제
app.delete('/users/:id', async (c) => {
  const prisma = c.get('prisma')
  const id = parseInt(c.req.param('id'))

  await prisma.user.delete({ where: { id } })
  return c.json({ message: 'User deleted' })
})

export default app
```

---

## 로컬 개발

### 로컬 D1로 개발

```bash
# 로컬 Worker 실행 (D1 포함)
npx wrangler dev

# 로컬 D1에 데이터 삽입
npx wrangler d1 execute my-database --local \
  --command "INSERT INTO User (email, name) VALUES ('test@example.com', 'Test User');"

# 로컬 D1 조회
npx wrangler d1 execute my-database --local \
  --command "SELECT * FROM User;"
```

---

## 배포

```bash
# Prisma Client 생성
npx prisma generate

# 원격 D1에 마이그레이션 적용
npx wrangler d1 migrations apply my-database --remote

# Worker 배포
npx wrangler deploy
```

---

## ⚠️ 제한사항

### 트랜잭션 미지원

```typescript
// ❌ 트랜잭션이 무시됨 - ACID 보장 안됨
const prisma = c.get('prisma')

await prisma.$transaction([
  prisma.user.create({ data: { email: 'user1@example.com' } }),
  prisma.post.create({ data: { title: 'Post', authorId: 1 } }),
])

// ❌ Interactive 트랜잭션도 미지원
await prisma.$transaction(async (tx) => {
  // 각 쿼리가 독립적으로 실행됨
})
```

### D1 vs 일반 SQLite 차이점

| 항목 | 일반 SQLite | Cloudflare D1 |
|------|-------------|---------------|
| 마이그레이션 | `prisma migrate dev` | `wrangler d1 migrations` |
| 트랜잭션 | ✅ 지원 | ❌ 미지원 |
| 데이터베이스 위치 | 로컬 파일 | Cloudflare Edge |
| 접속 방식 | 직접 연결 | HTTP (어댑터) |
| 환경 | 로컬 `.wrangler/state` | 원격 Cloudflare |

---

## RPC 클라이언트와 함께 사용

```typescript
// src/index.ts
import { Hono } from 'hono'
import { hc } from 'hono/client'
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

type Bindings = {
  DB: D1Database
}

const app = new Hono<{ Bindings: Bindings }>()
  .get('/users', async (c) => {
    const adapter = new PrismaD1(c.env.DB)
    const prisma = new PrismaClient({ adapter })

    const users = await prisma.user.findMany()
    return c.json(users)
  })
  .post('/users', async (c) => {
    const adapter = new PrismaD1(c.env.DB)
    const prisma = new PrismaClient({ adapter })

    const body = await c.req.json()
    const user = await prisma.user.create({ data: body })
    return c.json(user, 201)
  })

export type AppType = typeof app
export default app
```

---

## prisma.config.ts (선택사항)

Prisma CLI에서 D1에 직접 접근이 필요한 경우:

```typescript
// prisma.config.ts
import path from 'node:path'
import type { PrismaConfig } from 'prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

export default {
  experimental: {
    adapter: true,
  },
  engine: 'js',
  schema: path.join('prisma', 'schema.prisma'),
  async adapter() {
    return new PrismaD1({
      CLOUDFLARE_D1_TOKEN: process.env.CLOUDFLARE_D1_TOKEN,
      CLOUDFLARE_ACCOUNT_ID: process.env.CLOUDFLARE_ACCOUNT_ID,
      CLOUDFLARE_DATABASE_ID: process.env.CLOUDFLARE_DATABASE_ID,
    })
  },
} satisfies PrismaConfig
```

---

## 마이그레이션 명령어 요약

```bash
# D1 데이터베이스 생성
npx wrangler d1 create my-database

# 마이그레이션 파일 생성
npx wrangler d1 migrations create my-database migration_name

# SQL 생성 (초기)
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script

# SQL 생성 (후속)
npx prisma migrate diff --from-local-d1 --to-schema-datamodel prisma/schema.prisma --script

# 로컬 적용
npx wrangler d1 migrations apply my-database --local

# 원격 적용
npx wrangler d1 migrations apply my-database --remote

# Prisma Client 생성
npx prisma generate
```

---

## 참고 자료

- [Prisma D1 공식 문서](https://www.prisma.io/docs/orm/overview/databases/cloudflare-d1)
- [Cloudflare D1 문서](https://developers.cloudflare.com/d1/)
- [Prisma D1 가이드](https://www.prisma.io/guides/cloudflare-d1)
- [Hono Cloudflare Workers](https://hono.dev/docs/getting-started/cloudflare-workers)
