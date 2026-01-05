# Drizzle - 설치 및 설정

## 설치

### PostgreSQL

```bash
npm install drizzle-orm pg
npm install -D drizzle-kit @types/pg
```

### MySQL

```bash
npm install drizzle-orm mysql2
npm install -D drizzle-kit
```

### SQLite

```bash
npm install drizzle-orm better-sqlite3
npm install -D drizzle-kit @types/better-sqlite3
```

---

## 폴더 구조

```
프로젝트/
├── drizzle.config.ts
├── drizzle/
│   └── migrations/
├── src/
│   ├── db/
│   │   └── schema/
│   │       ├── index.ts    # export all
│   │       ├── user.ts
│   │       └── post.ts
│   └── lib/
│       └── db.ts           # Drizzle client
```

---

## Drizzle Client

```typescript
// src/lib/db.ts
import { drizzle } from 'drizzle-orm/node-postgres'
import * as schema from '@/db/schema'

export const db = drizzle(process.env.DATABASE_URL!, { schema })
```

---

## TanStack Start 연동

```typescript
// app/services/user.ts
import { createServerFn } from '@tanstack/react-start'
import { db } from '@/lib/db'
import { users } from '@/db/schema'
import { eq } from 'drizzle-orm'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return db.select().from(users)
  })

export const getUserById = createServerFn({ method: 'GET' })
  .validator((id: number) => id)
  .handler(async ({ data: id }) => {
    const [user] = await db.select().from(users).where(eq(users.id, id))
    return user
  })

export const createUser = createServerFn({ method: 'POST' })
  .validator((data: { email: string; name: string }) => data)
  .handler(async ({ data }) => {
    const [user] = await db.insert(users).values(data).returning()
    return user
  })
```

---

## 환경 변수

```bash
# .env
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"
```
