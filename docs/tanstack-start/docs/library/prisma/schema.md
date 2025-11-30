# Prisma - 스키마 정의

> **상위 문서**: [Prisma](./index.md)

## 기본 스키마

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

model User {
  id           Int              @id @default(autoincrement())
  email        String           @unique
  name         String?
  role         Role             @default(USER)
  posts        Post[]
  profile      ExtendedProfile?
  createdAt    DateTime         @default(now())
  updatedAt    DateTime         @updatedAt
}

model Post {
  id         Int        @id @default(autoincrement())
  title      String
  content    String?
  published  Boolean    @default(false)
  author     User       @relation(fields: [authorId], references: [id])
  authorId   Int
  categories Category[]
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt
}

model Category {
  id    Int    @id @default(autoincrement())
  name  String @unique
  posts Post[]
}

model ExtendedProfile {
  id        Int    @id @default(autoincrement())
  biography String
  user      User   @relation(fields: [userId], references: [id])
  userId    Int    @unique
}

enum Role {
  USER
  ADMIN
}
```

## 선택적 관계

```prisma
model Post {
  id       Int   @id @default(autoincrement())
  author   User? @relation(fields: [authorId], references: [id])
  authorId Int?
}
```

## 커스텀 필드/모델명 매핑

```prisma
model User {
  id    Int    @id @default(autoincrement()) @map("user_id")
  email String @unique

  @@map("users")
}
```

## 관계 유형

### 1:1 관계

```prisma
model User {
  id      Int      @id @default(autoincrement())
  profile Profile?
}

model Profile {
  id     Int  @id @default(autoincrement())
  user   User @relation(fields: [userId], references: [id])
  userId Int  @unique
}
```

### 1:N 관계

```prisma
model User {
  id    Int    @id @default(autoincrement())
  posts Post[]
}

model Post {
  id       Int  @id @default(autoincrement())
  author   User @relation(fields: [authorId], references: [id])
  authorId Int
}
```

### M:N 관계 (암묵적)

```prisma
model Post {
  id         Int        @id @default(autoincrement())
  categories Category[]
}

model Category {
  id    Int    @id @default(autoincrement())
  posts Post[]
}
```

### M:N 관계 (명시적)

```prisma
model Post {
  id         Int                @id @default(autoincrement())
  categories CategoriesOnPosts[]
}

model Category {
  id    Int                @id @default(autoincrement())
  posts CategoriesOnPosts[]
}

model CategoriesOnPosts {
  post       Post     @relation(fields: [postId], references: [id])
  postId     Int
  category   Category @relation(fields: [categoryId], references: [id])
  categoryId Int
  assignedAt DateTime @default(now())

  @@id([postId, categoryId])
}
```

## 인덱스

```prisma
model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  authorId  Int
  createdAt DateTime @default(now())

  @@index([authorId])
  @@index([createdAt])
  @@index([title, authorId])
}
```

## 복합 키

```prisma
model PostTag {
  postId Int
  tagId  Int

  @@id([postId, tagId])
}
```
