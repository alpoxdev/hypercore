# Drizzle ORM - Database ORM

> Type-safe, lightweight TypeScript ORM

@config.md
@cloudflare-d1.md

---

## 설치

```bash
npm install drizzle-orm pg
npm install -D drizzle-kit @types/pg
```

---

## 스키마 정의

### 폴더 구조

```
src/
├── db/
│   ├── index.ts       # Drizzle client
│   └── schema/
│       ├── index.ts   # export all
│       ├── user.ts    # User 테이블
│       └── post.ts    # Post 테이블
```

### user.ts

```typescript
import { pgTable, serial, text, timestamp, boolean } from 'drizzle-orm/pg-core'

// 사용자 테이블
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),  // 로그인 이메일
  name: text('name'),                        // 표시 이름
  verified: boolean('verified').notNull().default(false),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
})

// 타입 추론
export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert
```

---

## Drizzle Client

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/node-postgres'
import * as schema from './schema'

export const db = drizzle(process.env.DATABASE_URL!, { schema })
```

---

## CRUD

### Create

```typescript
import { db } from '@/db'
import { users } from '@/db/schema'

const user = await db.insert(users).values({
  email: 'user@example.com',
  name: 'John',
}).returning()

// Batch insert
await db.insert(users).values([
  { email: 'user1@example.com', name: 'User 1' },
  { email: 'user2@example.com', name: 'User 2' },
])
```

### Read

```typescript
import { eq, and, or, gt, like, desc, asc } from 'drizzle-orm'

// 전체 조회
const allUsers = await db.select().from(users)

// 조건 조회
const user = await db.select().from(users).where(eq(users.id, 1))

// 복합 조건
const filtered = await db.select().from(users).where(
  and(
    eq(users.verified, true),
    gt(users.createdAt, new Date('2024-01-01'))
  )
)

// 정렬 + 페이지네이션
const paginated = await db.select().from(users)
  .orderBy(desc(users.createdAt))
  .limit(10)
  .offset(0)

// 특정 필드만 선택
const emails = await db.select({ email: users.email }).from(users)
```

### Update

```typescript
await db.update(users)
  .set({ name: 'Updated Name' })
  .where(eq(users.id, 1))

// Upsert
await db.insert(users)
  .values({ email: 'user@example.com', name: 'John' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: 'John Updated' },
  })
```

### Delete

```typescript
await db.delete(users).where(eq(users.id, 1))
await db.delete(users).where(eq(users.verified, false))
```

---

## 필터링 연산자

```typescript
import { eq, ne, gt, gte, lt, lte, like, ilike, inArray, isNull, between, and, or, not } from 'drizzle-orm'

// 비교
where(eq(users.id, 1))           // =
where(ne(users.id, 1))           // !=
where(gt(users.age, 18))         // >
where(gte(users.age, 18))        // >=
where(lt(users.age, 65))         // <
where(lte(users.age, 65))        // <=

// 문자열
where(like(users.name, '%John%'))
where(ilike(users.name, '%john%'))  // 대소문자 무시

// 배열
where(inArray(users.id, [1, 2, 3]))

// NULL
where(isNull(users.deletedAt))

// 범위
where(between(users.age, 18, 65))

// 논리
where(and(eq(users.role, 'admin'), eq(users.verified, true)))
where(or(eq(users.role, 'admin'), eq(users.role, 'moderator')))
where(not(eq(users.role, 'guest')))
```

---

## 트랜잭션

```typescript
const result = await db.transaction(async (tx) => {
  const [user] = await tx.insert(users)
    .values({ email: 'user@example.com' })
    .returning()

  await tx.insert(posts).values({ title: 'First Post', authorId: user.id })

  return user
})

// 롤백
await db.transaction(async (tx) => {
  const [account] = await tx.select().from(accounts).where(eq(accounts.id, 1))
  if (account.balance < 100) {
    tx.rollback()  // 예외 발생, 트랜잭션 롤백
  }
  await tx.update(accounts).set({ balance: account.balance - 100 }).where(eq(accounts.id, 1))
})
```

---

## Hono와 함께 사용

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'
import { eq } from 'drizzle-orm'
import { db } from '@/db'
import { users } from '@/db/schema'

const app = new Hono()

app.post('/users',
  zValidator('json', z.object({ email: z.email(), name: z.string().optional() })),
  async (c) => {
    const data = c.req.valid('json')

    const existing = await db.select().from(users).where(eq(users.email, data.email))
    if (existing.length > 0) {
      throw new HTTPException(409, { message: 'Email already exists' })
    }

    const [user] = await db.insert(users).values(data).returning()
    return c.json({ user }, 201)
  }
)

app.get('/users/:id', async (c) => {
  const id = Number(c.req.param('id'))
  const [user] = await db.select().from(users).where(eq(users.id, id))

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})

export default app
```

---

## CLI 명령어

```bash
npx drizzle-kit generate    # 마이그레이션 생성
npx drizzle-kit migrate     # 마이그레이션 실행
npx drizzle-kit push        # 스키마 동기화 (개발용)
npx drizzle-kit pull        # DB에서 스키마 가져오기
npx drizzle-kit studio      # GUI 실행
```

---

## 관련 문서

- [Config 파일](./config.md) - drizzle.config.ts 설정
- [Cloudflare D1](./cloudflare-d1.md)
