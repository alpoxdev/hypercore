# Drizzle - 트랜잭션

## 기본 트랜잭션

하나라도 실패하면 모두 롤백.

```typescript
import { db } from '@/lib/db'
import { users, accounts } from '@/db/schema'
import { eq, sql } from 'drizzle-orm'

await db.transaction(async (tx) => {
  await tx.update(accounts)
    .set({ balance: sql`${accounts.balance} - 100` })
    .where(eq(accounts.userId, senderId))

  await tx.update(accounts)
    .set({ balance: sql`${accounts.balance} + 100` })
    .where(eq(accounts.userId, recipientId))
})
```

## 반환값 사용

```typescript
const newBalance = await db.transaction(async (tx) => {
  await tx.update(accounts)
    .set({ balance: sql`${accounts.balance} - 100` })
    .where(eq(accounts.userId, senderId))

  await tx.update(accounts)
    .set({ balance: sql`${accounts.balance} + 100` })
    .where(eq(accounts.userId, recipientId))

  const [account] = await tx.select({ balance: accounts.balance })
    .from(accounts)
    .where(eq(accounts.userId, senderId))

  return account.balance
})
```

## 조건부 롤백

```typescript
await db.transaction(async (tx) => {
  const [account] = await tx.select({ balance: accounts.balance })
    .from(accounts)
    .where(eq(accounts.userId, senderId))

  if (account.balance < 100) {
    tx.rollback()  // 예외 발생, 트랜잭션 롤백
  }

  await tx.update(accounts)
    .set({ balance: sql`${accounts.balance} - 100` })
    .where(eq(accounts.userId, senderId))

  await tx.update(accounts)
    .set({ balance: sql`${accounts.balance} + 100` })
    .where(eq(accounts.userId, recipientId))
})
```

## 에러 처리

```typescript
try {
  await db.transaction(async (tx) => {
    const [user] = await tx.insert(users)
      .values({ email: 'user@example.com' })
      .returning()

    if (someCondition) {
      throw new Error('Rollback')
    }

    await tx.insert(posts)
      .values({ title: 'Post', authorId: user.id })
  })
} catch (error) {
  // 전체 롤백됨
  console.error('Transaction failed:', error)
}
```

## 중첩 트랜잭션 (PostgreSQL)

```typescript
await db.transaction(async (tx) => {
  await tx.insert(users).values({ email: 'user1@example.com' })

  await tx.transaction(async (tx2) => {
    await tx2.insert(users).values({ email: 'user2@example.com' })
    // 여기서 에러 발생해도 외부 트랜잭션은 영향 없음 (savepoint)
  })
})
```

## 복잡한 예시

```typescript
import { db } from '@/lib/db'
import { users, posts, comments } from '@/db/schema'
import { eq } from 'drizzle-orm'

const createUserWithPost = async (userData: NewUser, postData: NewPost) => {
  return db.transaction(async (tx) => {
    // 사용자 생성
    const [user] = await tx.insert(users).values(userData).returning()

    // 게시글 생성
    const [post] = await tx.insert(posts)
      .values({ ...postData, authorId: user.id })
      .returning()

    // 사용자 + 게시글 반환
    return { user, post }
  })
}

// 사용
const result = await createUserWithPost(
  { email: 'user@example.com', name: 'John' },
  { title: 'First Post', content: 'Hello World' }
)
```
