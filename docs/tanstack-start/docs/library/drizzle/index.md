# Drizzle ORM

> **Version**: 0.38.x | Node.js/TypeScript ORM

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
import { db } from '@/lib/db'
import { users } from '@/db/schema'
import { eq } from 'drizzle-orm'

// CRUD
const allUsers = await db.select().from(users)
const [user] = await db.insert(users).values({ email, name }).returning()
const [updated] = await db.update(users).set({ name }).where(eq(users.id, id)).returning()
await db.delete(users).where(eq(users.id, id))

// 관계 포함 (Relational Query)
const userWithPosts = await db.query.users.findFirst({
  where: eq(users.id, id),
  with: { posts: true },
})
```

### drizzle.config.ts

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

### Claude Code 금지

| 금지 사항 |
|----------|
| drizzle-kit push 자동 실행 |
| drizzle-kit migrate 자동 실행 |
| drizzle-kit generate 자동 실행 |
| 스키마 임의 변경 |

---

## Drizzle Client 설정

```typescript
// lib/db.ts
import { drizzle } from 'drizzle-orm/node-postgres'
import * as schema from '@/db/schema'

export const db = drizzle(process.env.DATABASE_URL!, { schema })
```

## CLI 명령어

```bash
npx drizzle-kit generate    # 마이그레이션 생성
npx drizzle-kit migrate     # 마이그레이션 실행
npx drizzle-kit push        # 스키마 동기화 (개발용)
npx drizzle-kit pull        # DB에서 스키마 가져오기
npx drizzle-kit studio      # GUI
```
