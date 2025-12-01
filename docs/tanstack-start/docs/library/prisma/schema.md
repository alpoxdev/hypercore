# Prisma - 스키마 정의 (Multi-File)

> **상위 문서**: [Prisma](./index.md)

## ⚠️ 필수: Multi-File 구조 사용

Prisma 스키마는 **반드시 Multi-File 구조**로 작성합니다.

```
prisma/
├── schema/
│   ├── +base.prisma      # datasource, generator 설정
│   ├── +enum.prisma      # 모든 enum 정의
│   ├── user.prisma       # User 모델
│   ├── post.prisma       # Post 모델
│   ├── category.prisma   # Category 모델
│   └── profile.prisma    # Profile 모델
```

## ⚠️ 필수: 한글 주석 작성

**Prisma Multi-File의 모든 요소에 한글 주석을 작성해야 합니다.**

```
✅ 파일별 목적 주석
✅ 모델별 설명 주석
✅ 필드별 설명 주석 (용도가 명확하지 않은 경우)
✅ 관계 설명 주석
✅ enum 값 설명 주석
```

---

## Multi-File 스키마 예시

### +base.prisma (기본 설정)

```prisma
// prisma/schema/+base.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Prisma 기본 설정 파일
// datasource 및 generator 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 데이터베이스 연결 설정
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Prisma Client 생성 설정
generator client {
  provider = "prisma-client"  // Prisma v7 필수
  output   = "../generated/prisma"
}
```

### +enum.prisma (열거형 정의)

```prisma
// prisma/schema/+enum.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 모든 열거형(enum) 정의 파일
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 사용자 권한 열거형
enum Role {
  USER   // 일반 사용자
  ADMIN  // 관리자
}

// 게시글 상태 열거형
enum PostStatus {
  DRAFT      // 임시저장
  PUBLISHED  // 공개됨
  ARCHIVED   // 보관됨
}
```

### user.prisma (User 모델)

```prisma
// prisma/schema/user.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 사용자 모델
// 시스템의 모든 사용자 정보를 저장
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

model User {
  id           Int              @id @default(autoincrement())
  email        String           @unique  // 로그인 이메일 (중복 불가)
  name         String?                   // 표시 이름 (선택)
  role         Role             @default(USER)  // 사용자 권한
  posts        Post[]                    // 작성한 게시글 목록
  profile      ExtendedProfile?          // 확장 프로필 (1:1)
  createdAt    DateTime         @default(now())
  updatedAt    DateTime         @updatedAt
}
```

### post.prisma (Post 모델)

```prisma
// prisma/schema/post.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 게시글 모델
// 사용자가 작성한 게시글 정보
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

model Post {
  id         Int        @id @default(autoincrement())
  title      String                    // 게시글 제목
  content    String?                   // 게시글 본문 (선택)
  published  Boolean    @default(false)  // 공개 여부
  status     PostStatus @default(DRAFT)  // 게시글 상태
  author     User       @relation(fields: [authorId], references: [id])  // 작성자 관계
  authorId   Int                       // 작성자 ID (외래키)
  categories Category[]                // 소속 카테고리 목록 (M:N)
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt
}
```

### category.prisma (Category 모델)

```prisma
// prisma/schema/category.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 카테고리 모델
// 게시글 분류를 위한 카테고리
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

model Category {
  id    Int    @id @default(autoincrement())
  name  String @unique  // 카테고리명 (중복 불가)
  posts Post[]          // 소속 게시글 목록 (M:N)
}
```

### profile.prisma (Profile 모델)

```prisma
// prisma/schema/profile.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 확장 프로필 모델
// 사용자의 추가 정보 (1:1 관계)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

model ExtendedProfile {
  id        Int    @id @default(autoincrement())
  biography String  // 자기소개
  user      User   @relation(fields: [userId], references: [id])  // 사용자 관계
  userId    Int    @unique  // 사용자 ID (외래키, 유니크)
}
```

---

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
