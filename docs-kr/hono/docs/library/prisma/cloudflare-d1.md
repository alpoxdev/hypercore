# Prisma - Cloudflare D1

> SQLite 기반 서버리스 데이터베이스

---

## 주의사항

```
D1은 트랜잭션 미지원 (ACID 보장 X)
prisma migrate dev 사용 불가 → wrangler CLI 사용
Prisma ORM D1 지원은 Preview 상태
```

---

## Quick Setup

### schema.prisma

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
  runtime  = "cloudflare"  // D1 필수
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

## 설치

```bash
npm install hono @prisma/client @prisma/adapter-d1
npm install -D prisma wrangler
npx prisma init --datasource-provider sqlite
```

---

## D1 데이터베이스 생성

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

## 마이그레이션 워크플로우

```bash
# 1. 마이그레이션 파일 생성
npx wrangler d1 migrations create my-database create_user_table

# 2. SQL 생성 (초기)
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script \
  --output prisma/migrations/0001_create_user_table.sql

# 3. 로컬 적용
npx wrangler d1 migrations apply my-database --local

# 4. 원격 적용
npx wrangler d1 migrations apply my-database --remote
```

---

## 완전한 CRUD API

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

// Prisma 미들웨어
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

## 로컬 개발

```bash
# Worker 실행
npx wrangler dev

# D1 조회
npx wrangler d1 execute my-database --local \
  --command "SELECT * FROM User;"
```

---

## 배포

```bash
npx prisma generate
npx wrangler d1 migrations apply my-database --remote
npx wrangler deploy
```

---

## 제한사항

| 항목 | D1 |
|------|-----|
| 트랜잭션 | ❌ 미지원 |
| 마이그레이션 | wrangler 사용 |
| 접속 방식 | HTTP (어댑터) |

---

## 관련 문서

- [Prisma 개요](./index.md)
- [Cloudflare 배포](../../deployment/cloudflare.md)
