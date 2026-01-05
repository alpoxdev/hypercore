# Drizzle - 관계 정의

## 관계 유형

### 1:N (One-to-Many)

```typescript
import { pgTable, serial, text, integer } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

// 사용자
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
})

// 사용자 관계
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}))

// 게시글
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  authorId: integer('author_id').references(() => users.id),
})

// 게시글 관계
export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}))
```

### 1:1 (One-to-One)

```typescript
// 사용자
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
})

export const usersRelations = relations(users, ({ one }) => ({
  profile: one(profiles),
}))

// 프로필
export const profiles = pgTable('profiles', {
  id: serial('id').primaryKey(),
  bio: text('bio'),
  userId: integer('user_id').unique().references(() => users.id),
})

export const profilesRelations = relations(profiles, ({ one }) => ({
  user: one(users, {
    fields: [profiles.userId],
    references: [users.id],
  }),
}))
```

### M:N (Many-to-Many)

```typescript
// 사용자
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
})

export const usersRelations = relations(users, ({ many }) => ({
  usersToGroups: many(usersToGroups),
}))

// 그룹
export const groups = pgTable('groups', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
})

export const groupsRelations = relations(groups, ({ many }) => ({
  usersToGroups: many(usersToGroups),
}))

// 조인 테이블
export const usersToGroups = pgTable('users_to_groups', {
  userId: integer('user_id').notNull().references(() => users.id),
  groupId: integer('group_id').notNull().references(() => groups.id),
}, (table) => [
  primaryKey({ columns: [table.userId, table.groupId] }),
])

export const usersToGroupsRelations = relations(usersToGroups, ({ one }) => ({
  user: one(users, {
    fields: [usersToGroups.userId],
    references: [users.id],
  }),
  group: one(groups, {
    fields: [usersToGroups.groupId],
    references: [groups.id],
  }),
}))
```

## 관계 포함 조회

```typescript
// 1:N 관계 포함
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

// 관계 필터링 + 정렬
const result = await db.query.users.findFirst({
  with: {
    posts: {
      where: eq(posts.published, true),
      orderBy: desc(posts.createdAt),
      limit: 5,
    },
  },
})

// M:N 관계
const userWithGroups = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: {
    usersToGroups: {
      with: {
        group: true,
      },
    },
  },
})
```

## SQL Join으로 조회

```typescript
// Inner join
const result = await db.select({
  userId: users.id,
  userName: users.name,
  postTitle: posts.title,
})
.from(users)
.innerJoin(posts, eq(users.id, posts.authorId))
.where(eq(users.id, 1))

// Left join + count
const result = await db.select({
  userId: users.id,
  userName: users.name,
  postCount: count(posts.id),
})
.from(users)
.leftJoin(posts, eq(users.id, posts.authorId))
.groupBy(users.id)
```

## 자기 참조 관계

```typescript
import { type AnyPgColumn, pgTable, serial, text, integer } from 'drizzle-orm/pg-core'

// 사용자 (초대 관계)
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  invitedBy: integer('invited_by').references((): AnyPgColumn => users.id),
})

export const usersRelations = relations(users, ({ one, many }) => ({
  inviter: one(users, {
    fields: [users.invitedBy],
    references: [users.id],
    relationName: 'inviter',
  }),
  invitees: many(users, {
    relationName: 'inviter',
  }),
}))
```
