# Prisma Patterns

**목적**: Prisma 7.x 사용 패턴 및 주의사항

## 버전 정보

**Prisma 7.x 사용 중**

- 패키지명: `prisma-client` (prisma가 아님)
- output 경로 필수: `output = "./generated/client"`

## 클라이언트 초기화

```typescript
// src/database/prisma.ts
import { PrismaClient } from './generated/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

**필수:**
- [ ] PrismaClient import 경로 확인 (`./generated/client`)
- [ ] globalThis 패턴 사용 (개발 모드 hot reload 대응)

## Schema 구조

### Single File

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
  output   = "./generated/client"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
}
```

### Multi-File Structure

**명시적 요청 시에만 사용**

```
prisma/schema/
├── +base.prisma      # datasource, generator
├── +enum.prisma      # 모든 enum
├── user.prisma       # User 모델
└── post.prisma       # Post 모델
```

```prisma
// prisma/schema/+base.prisma
generator client {
  provider = "prisma-client-js"
  output   = "../generated/client"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

```prisma
// prisma/schema/+enum.prisma
/// 사용자 역할
enum UserRole {
  /// 관리자
  ADMIN
  /// 일반 사용자
  USER
}
```

```prisma
// prisma/schema/user.prisma
/// 사용자
model User {
  /// 고유 식별자
  id        Int      @id @default(autoincrement())
  /// 이메일 (고유)
  email     String   @unique
  /// 이름
  name      String
  /// 역할
  role      UserRole @default(USER)
  /// 생성 시각
  createdAt DateTime @default(now())
}
```

**Multi-File 규칙:**

- [ ] 모든 모델/필드/enum에 한글 주석 필수
- [ ] `+base.prisma`: datasource, generator
- [ ] `+enum.prisma`: 모든 enum 정의
- [ ] `[model].prisma`: 모델별 파일

## CRUD Operations

### Create

```typescript
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'User Name'
  }
})
```

### Read

```typescript
// 단일 조회
const user = await prisma.user.findUnique({
  where: { id: 1 }
})

// 목록 조회
const users = await prisma.user.findMany({
  where: { role: 'USER' },
  include: { posts: true }
})

// 페이지네이션
const users = await prisma.user.findMany({
  skip: 20,
  take: 10,
  orderBy: { createdAt: 'desc' }
})
```

### Update

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: { name: 'New Name' }
})
```

### Delete

```typescript
const user = await prisma.user.delete({
  where: { id: 1 }
})
```

## Relations

### 1:N (One-to-Many)

```prisma
model User {
  id    Int    @id @default(autoincrement())
  posts Post[]
}

model Post {
  id       Int  @id @default(autoincrement())
  authorId Int
  author   User @relation(fields: [authorId], references: [id])
}
```

```typescript
// Include posts
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: { posts: true }
})

// Create with relation
const post = await prisma.post.create({
  data: {
    title: 'Post Title',
    author: {
      connect: { id: 1 }
    }
  }
})
```

### N:N (Many-to-Many)

```prisma
model Post {
  id   Int    @id @default(autoincrement())
  tags Tag[]
}

model Tag {
  id    Int    @id @default(autoincrement())
  posts Post[]
}
```

```typescript
// Create with tags
const post = await prisma.post.create({
  data: {
    title: 'Post Title',
    tags: {
      connect: [{ id: 1 }, { id: 2 }]
    }
  }
})
```

## Transactions

```typescript
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email: 'user@example.com', name: 'User' }
  })

  const post = await tx.post.create({
    data: {
      title: 'Post Title',
      authorId: user.id
    }
  })

  return { user, post }
})
```

## 자동 실행 금지

**절대 자동 실행하지 않음:**

```bash
# ❌ 금지
prisma db push
prisma migrate dev
prisma generate

# ✅ 올바름: 사용자에게 안내
echo "schema.prisma 수정 완료. 다음 명령어 실행 필요:"
echo "  prisma db push"
```

**이유:**
- DB 변경은 중요한 작업
- 사용자가 직접 확인 후 실행
- 의도하지 않은 데이터 손실 방지

## Index 최적화

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  createdAt DateTime @default(now())

  @@index([createdAt])
  @@index([email, name])
}
```

**Index 사용 기준:**

- [ ] WHERE 조건에 자주 사용되는 필드
- [ ] JOIN에 사용되는 외래 키
- [ ] ORDER BY에 사용되는 필드

## N+1 Problem 방지

```typescript
// ❌ N+1 Problem
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { authorId: user.id }
  })
}

// ✅ Include 사용
const users = await prisma.user.findMany({
  include: { posts: true }
})

// ✅ Select 최적화
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    posts: {
      select: {
        id: true,
        title: true
      }
    }
  }
})
```

## 체크리스트

### Schema 작성

- [ ] `generator client` output 경로 확인
- [ ] Multi-File 사용 시 한글 주석 필수
- [ ] Index 적절히 설정
- [ ] Relations 올바르게 정의

### 쿼리 작성

- [ ] N+1 Problem 회피 (include/select 사용)
- [ ] 페이지네이션 적용 (skip/take)
- [ ] 트랜잭션 필요 시 `$transaction` 사용

### 자동 실행 금지

- [ ] `prisma db push` 자동 실행 금지
- [ ] `prisma migrate dev` 자동 실행 금지
- [ ] `prisma generate` 자동 실행 금지

**Prisma 패턴 준수 → 타입 안전 + 성능 최적화**
