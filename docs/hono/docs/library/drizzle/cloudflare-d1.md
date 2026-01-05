# Drizzle - Cloudflare D1

> SQLite 기반 서버리스 데이터베이스

---

## 주의사항

```
D1은 트랜잭션 미지원 (ACID 보장 X)
Drizzle Kit 마이그레이션 → wrangler CLI로 적용
```

---

## Quick Setup

### 설치

```bash
npm install drizzle-orm
npm install -D drizzle-kit wrangler
```

### 스키마 정의

```typescript
// src/db/schema.ts
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core'

export const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  email: text('email').notNull().unique(),
  name: text('name'),
})

export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert
```

### drizzle.config.ts

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'sqlite',
  schema: './src/db/schema.ts',
  out: './drizzle/migrations',
  driver: 'd1-http',
  dbCredentials: {
    accountId: process.env.CLOUDFLARE_ACCOUNT_ID!,
    databaseId: process.env.CLOUDFLARE_DATABASE_ID!,
    token: process.env.CLOUDFLARE_D1_TOKEN!,
  },
})
```

### Hono + D1

```typescript
import { Hono } from 'hono'
import { drizzle } from 'drizzle-orm/d1'
import * as schema from './db/schema'

type Bindings = { DB: D1Database }

const app = new Hono<{ Bindings: Bindings }>()

app.get('/users', async (c) => {
  const db = drizzle(c.env.DB, { schema })
  const users = await db.select().from(schema.users)
  return c.json(users)
})

export default app
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
  "compatibility_flags": ["nodejs_compat"],
  "d1_databases": [{
    "binding": "DB",
    "database_name": "my-database",
    "database_id": "YOUR_DATABASE_ID",
    "migrations_dir": "drizzle/migrations"
  }]
}
```

---

## 마이그레이션 워크플로우

```bash
# 1. 마이그레이션 파일 생성
npx drizzle-kit generate

# 2. 로컬 적용
npx wrangler d1 migrations apply my-database --local

# 3. 원격 적용
npx wrangler d1 migrations apply my-database --remote
```

---

## 완전한 CRUD API

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'
import { drizzle } from 'drizzle-orm/d1'
import { eq } from 'drizzle-orm'
import * as schema from './db/schema'

type Bindings = { DB: D1Database }
type Variables = { db: ReturnType<typeof drizzle> }

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>()

// Drizzle 미들웨어
app.use('*', async (c, next) => {
  c.set('db', drizzle(c.env.DB, { schema }))
  await next()
})

app.get('/users', async (c) => {
  const db = c.get('db')
  const users = await db.select().from(schema.users)
  return c.json(users)
})

app.post('/users',
  zValidator('json', z.object({ email: z.email(), name: z.string().optional() })),
  async (c) => {
    const db = c.get('db')
    const data = c.req.valid('json')

    const existing = await db.select().from(schema.users).where(eq(schema.users.email, data.email))
    if (existing.length > 0) {
      throw new HTTPException(409, { message: 'Email already exists' })
    }

    const [user] = await db.insert(schema.users).values(data).returning()
    return c.json(user, 201)
  }
)

app.get('/users/:id', async (c) => {
  const db = c.get('db')
  const id = Number(c.req.param('id'))

  const [user] = await db.select().from(schema.users).where(eq(schema.users.id, id))
  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json(user)
})

app.put('/users/:id',
  zValidator('json', z.object({ name: z.string() })),
  async (c) => {
    const db = c.get('db')
    const id = Number(c.req.param('id'))
    const data = c.req.valid('json')

    const [user] = await db.update(schema.users)
      .set(data)
      .where(eq(schema.users.id, id))
      .returning()

    if (!user) {
      throw new HTTPException(404, { message: 'User not found' })
    }

    return c.json(user)
  }
)

app.delete('/users/:id', async (c) => {
  const db = c.get('db')
  const id = Number(c.req.param('id'))

  await db.delete(schema.users).where(eq(schema.users.id, id))
  return c.json({ success: true })
})

export default app
```

---

## 로컬 개발

```bash
# Worker 실행
npx wrangler dev

# D1 조회
npx wrangler d1 execute my-database --local \
  --command "SELECT * FROM users;"
```

---

## 배포

```bash
npx drizzle-kit generate
npx wrangler d1 migrations apply my-database --remote
npx wrangler deploy
```

---

## 제한사항

| 항목 | D1 |
|------|-----|
| 트랜잭션 | 미지원 |
| 마이그레이션 | wrangler 사용 |
| 접속 방식 | HTTP (D1 binding) |

---

## 관련 문서

- [Drizzle 개요](./index.md)
- [Cloudflare 배포](../../deployment/cloudflare.md)
