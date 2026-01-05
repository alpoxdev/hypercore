# Drizzle - CRUD 작업

## Create

```typescript
import { db } from '@/lib/db'
import { users } from '@/db/schema'

// 단일
const [user] = await db.insert(users)
  .values({ email: 'alice@example.com', name: 'Alice' })
  .returning()

// Batch insert
await db.insert(users).values([
  { email: 'alice@example.com', name: 'Alice' },
  { email: 'bob@example.com', name: 'Bob' },
])

// returning 없이
await db.insert(users).values({ email: 'alice@example.com' })
```

## Read

```typescript
import { eq, and, or, gt, like, desc, asc, count, sql } from 'drizzle-orm'

// 전체
const allUsers = await db.select().from(users)

// 조건
const [user] = await db.select().from(users).where(eq(users.id, 1))

// 복합 조건
const filtered = await db.select().from(users).where(
  and(
    eq(users.role, 'ADMIN'),
    gt(users.createdAt, new Date('2024-01-01'))
  )
)

// 특정 필드만
const emails = await db.select({ email: users.email }).from(users)

// 정렬
const sorted = await db.select().from(users).orderBy(desc(users.createdAt))

// 페이지네이션
const paginated = await db.select().from(users)
  .orderBy(asc(users.id))
  .limit(10)
  .offset(0)

// 카운트
const [{ count: total }] = await db.select({ count: count() }).from(users)
```

## Relational Query (관계 포함)

```typescript
// with 사용
const userWithPosts = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: {
    posts: true,
  },
})

// 중첩 관계
const userWithAll = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: {
    posts: {
      with: {
        comments: true,
      },
    },
  },
})

// 조건 + 정렬
const result = await db.query.users.findMany({
  where: eq(users.verified, true),
  with: {
    posts: {
      where: eq(posts.published, true),
      orderBy: desc(posts.createdAt),
      limit: 5,
    },
  },
  orderBy: asc(users.id),
  limit: 10,
})
```

## Update

```typescript
// 단일
const [updated] = await db.update(users)
  .set({ name: 'Updated Name' })
  .where(eq(users.id, 1))
  .returning()

// 다중
await db.update(users)
  .set({ verified: true })
  .where(eq(users.role, 'ADMIN'))

// Upsert (PostgreSQL)
await db.insert(users)
  .values({ email: 'alice@example.com', name: 'Alice' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: 'Alice Updated' },
  })

// Upsert - 아무것도 안 함
await db.insert(users)
  .values({ email: 'alice@example.com', name: 'Alice' })
  .onConflictDoNothing({ target: users.email })
```

## Delete

```typescript
// 단일
await db.delete(users).where(eq(users.id, 1))

// 조건부
await db.delete(users).where(eq(users.verified, false))

// 전체 (주의!)
await db.delete(users)
```

## 필터 연산자

```typescript
import {
  eq,        // =
  ne,        // !=
  gt,        // >
  gte,       // >=
  lt,        // <
  lte,       // <=
  like,      // LIKE
  ilike,     // ILIKE (대소문자 무시)
  inArray,   // IN
  notInArray,// NOT IN
  isNull,    // IS NULL
  isNotNull, // IS NOT NULL
  between,   // BETWEEN
  and,       // AND
  or,        // OR
  not,       // NOT
} from 'drizzle-orm'

// 문자열
where(like(users.name, '%John%'))
where(ilike(users.name, '%john%'))

// 숫자
where(gt(users.age, 18))
where(between(users.age, 18, 65))

// 배열
where(inArray(users.id, [1, 2, 3]))

// NULL
where(isNull(users.deletedAt))

// 논리
where(and(eq(users.role, 'admin'), eq(users.verified, true)))
where(or(eq(users.role, 'admin'), eq(users.role, 'moderator')))
```

## Join

```typescript
// Inner join
const result = await db.select({
  userId: users.id,
  userName: users.name,
  postTitle: posts.title,
})
.from(users)
.innerJoin(posts, eq(users.id, posts.authorId))

// Left join
const result = await db.select()
.from(users)
.leftJoin(posts, eq(users.id, posts.authorId))

// Aggregation
const result = await db.select({
  userId: users.id,
  userName: users.name,
  postCount: count(posts.id),
})
.from(users)
.leftJoin(posts, eq(users.id, posts.authorId))
.groupBy(users.id)
```
