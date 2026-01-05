# Drizzle - Cloudflare D1

SQLite 기반 서버리스 DB. 일반 Drizzle 마이그레이션과 다른 워크플로우.

트랜잭션 미지원 | drizzle-kit migrate 불가 - wrangler 사용

## 설정

### 스키마 (SQLite)

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

### wrangler.jsonc

```jsonc
{
  "d1_databases": [{
    "binding": "DB",
    "database_name": "my-db",
    "database_id": "YOUR_DATABASE_ID",
    "migrations_dir": "drizzle/migrations"
  }]
}
```

## 사용법

```typescript
import { drizzle } from 'drizzle-orm/d1'
import * as schema from './db/schema'

export interface Env {
  DB: D1Database
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const db = drizzle(env.DB, { schema })
    const users = await db.select().from(schema.users)
    return new Response(JSON.stringify(users))
  },
}
```

## TanStack Start + D1

```typescript
// app/services/user.ts
import { createServerFn } from '@tanstack/react-start'
import { drizzle } from 'drizzle-orm/d1'
import { eq } from 'drizzle-orm'
import { z } from 'zod'
import * as schema from '@/db/schema'

// D1 바인딩 접근 (Cloudflare Pages/Workers)
const getDb = () => {
  const env = (globalThis as any).__env__
  return drizzle(env.DB, { schema })
}

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    const db = getDb()
    return db.select().from(schema.users)
  })

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(z.object({ email: z.email(), name: z.string().optional() }))
  .handler(async ({ data }) => {
    const db = getDb()
    const [user] = await db.insert(schema.users).values(data).returning()
    return user
  })
```

## 마이그레이션 워크플로우

```bash
# 1. D1 생성
npx wrangler d1 create my-database

# 2. 마이그레이션 생성
npx drizzle-kit generate

# 3. 로컬 적용
npx wrangler d1 migrations apply my-database --local

# 4. 원격 적용
npx wrangler d1 migrations apply my-database --remote
```

## 로컬 개발

```bash
# Worker 실행
npx wrangler dev

# D1 조회
npx wrangler d1 execute my-database --local \
  --command "SELECT * FROM users;"
```

## 배포

```bash
npx drizzle-kit generate
npx wrangler d1 migrations apply my-database --remote
npx wrangler deploy
```

## 제한사항

| 항목 | 일반 SQLite | D1 |
|------|-------------|-----|
| 마이그레이션 | drizzle-kit migrate | wrangler d1 |
| 트랜잭션 | 지원 | 미지원 |
| 접속 | 직접 | HTTP (D1 binding) |
