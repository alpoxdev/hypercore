# Drizzle - 스키마 정의

## 필수 규칙

1. **파일별 분리** 구조 사용
2. **모든 요소에 한글 주석** (파일, 테이블, 컬럼)

## 구조

```
src/db/schema/
├── index.ts     # export all
├── user.ts      # User 테이블
├── post.ts      # Post 테이블
└── enums.ts     # Enum 정의
```

## 예시

### index.ts

```typescript
// 모든 스키마 export
export * from './user'
export * from './post'
export * from './enums'
```

### enums.ts

```typescript
import { pgEnum } from 'drizzle-orm/pg-core'

// 사용자 역할
export const roleEnum = pgEnum('role', ['USER', 'ADMIN'])
```

### user.ts

```typescript
import { pgTable, serial, text, boolean, timestamp } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { roleEnum } from './enums'
import { posts } from './post'

// 사용자 테이블
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),  // 로그인 이메일
  name: text('name'),                        // 표시 이름
  role: roleEnum('role').default('USER'),    // 사용자 역할
  verified: boolean('verified').notNull().default(false),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
})

// 사용자 관계
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),  // 작성 게시글 (1:N)
}))

// 타입 추론
export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert
```

### post.ts

```typescript
import { pgTable, serial, text, integer, boolean, timestamp } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { users } from './user'

// 게시글 테이블
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),           // 제목
  content: text('content'),                  // 본문
  published: boolean('published').notNull().default(false),
  authorId: integer('author_id').references(() => users.id),  // 작성자
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
})

// 게시글 관계
export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}))

export type Post = typeof posts.$inferSelect
export type NewPost = typeof posts.$inferInsert
```

## 컬럼 타입 (PostgreSQL)

```typescript
import {
  serial,        // auto-increment
  integer,       // 정수
  bigint,        // 큰 정수
  text,          // 문자열
  varchar,       // 길이 제한 문자열
  boolean,       // 불린
  timestamp,     // 날짜/시간
  date,          // 날짜
  numeric,       // 소수점
  json,          // JSON
  jsonb,         // JSONB
  uuid,          // UUID
} from 'drizzle-orm/pg-core'
```

## 인덱스

```typescript
import { pgTable, serial, text, index, uniqueIndex } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
  email: text('email').notNull(),
}, (table) => [
  index('name_idx').on(table.name),
  uniqueIndex('email_idx').on(table.email),
])
```

## 복합 키

```typescript
import { pgTable, integer, primaryKey } from 'drizzle-orm/pg-core'

export const usersToGroups = pgTable('users_to_groups', {
  userId: integer('user_id').notNull(),
  groupId: integer('group_id').notNull(),
}, (table) => [
  primaryKey({ columns: [table.userId, table.groupId] }),
])
```

## 테이블 매핑

```typescript
// snake_case 컬럼명 사용
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  firstName: text('first_name'),  // DB: first_name, JS: firstName
  lastName: text('last_name'),
  createdAt: timestamp('created_at').defaultNow(),
})
```
