# Prisma - Schema Definition (Multi-File)

## ⚠️ Required Rules

1. **Multi-File structure** required
2. **Korean comments on all elements** (files, models, fields, enums)

## Structure

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # all enums
├── user.prisma     # User model
└── post.prisma     # Post model
```

## Examples

```prisma
// +base.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

// +enum.prisma
enum Role {
  USER   // Regular user
  ADMIN  // Administrator
}

// user.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique  // Login email
  name      String?           // Display name
  role      Role     @default(USER)
  posts     Post[]            // Author posts (1:N)
  profile   Profile?          // Profile (1:1)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## Relation Types

```prisma
// 1:1
model Profile {
  id     Int  @id @default(autoincrement())
  user   User @relation(fields: [userId], references: [id])
  userId Int  @unique
}

// 1:N
model Post {
  author   User @relation(fields: [authorId], references: [id])
  authorId Int
}

// M:N (implicit)
model Post { categories Category[] }
model Category { posts Post[] }

// M:N (explicit)
model CategoriesOnPosts {
  post       Post     @relation(fields: [postId], references: [id])
  postId     Int
  category   Category @relation(fields: [categoryId], references: [id])
  categoryId Int
  @@id([postId, categoryId])
}
```

## Other Features

```prisma
// Optional relation
author   User? @relation(fields: [authorId], references: [id])
authorId Int?

// Indexes
@@index([authorId])
@@index([createdAt])

// Composite key
@@id([postId, tagId])

// Mapping
@map("user_id")
@@map("users")
```
