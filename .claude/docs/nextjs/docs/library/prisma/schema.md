# Prisma - 스키마 정의 (Multi-File)

## ⚠️ 필수 규칙

1. **Multi-File 구조** 사용
2. **모든 요소에 한글 주석** (파일, 모델, 필드, enum)

## 구조

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # 모든 enum
├── user.prisma     # User 모델
└── post.prisma     # Post 모델
```

## 예시

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
  USER   // 일반 사용자
  ADMIN  // 관리자
}

// user.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique  // 로그인 이메일
  name      String?           // 표시 이름
  role      Role     @default(USER)
  posts     Post[]            // 작성 게시글 (1:N)
  profile   Profile?          // 프로필 (1:1)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## 관계 유형

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

// M:N (암묵적)
model Post { categories Category[] }
model Category { posts Post[] }

// M:N (명시적)
model CategoriesOnPosts {
  post       Post     @relation(fields: [postId], references: [id])
  postId     Int
  category   Category @relation(fields: [categoryId], references: [id])
  categoryId Int
  @@id([postId, categoryId])
}
```

## 기타

```prisma
// 선택적 관계
author   User? @relation(fields: [authorId], references: [id])
authorId Int?

// 인덱스
@@index([authorId])
@@index([createdAt])

// 복합 키
@@id([postId, tagId])

// 매핑
@map("user_id")
@@map("users")
```
