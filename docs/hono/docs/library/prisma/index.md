# Prisma v7 - Database ORM

> Type-safe 데이터베이스 ORM

@config.md
@cloudflare-d1.md

---

## ⚠️ 버전 주의

이 문서는 **Prisma v7** 기준입니다. v6 이하와 설정이 다릅니다.

```prisma
generator client {
  provider = "prisma-client"  // ✅ v7 (prisma-client-js 아님!)
  output   = "./generated/client"  // ✅ output 필수
}
```

---

## ⛔ 금지 사항

```
❌ prisma db push 자동 실행 금지
❌ prisma migrate 자동 실행 금지
❌ prisma generate 자동 실행 금지
❌ schema.prisma 임의 변경 금지 (요청된 것만)
```

---

## 설치

```bash
npm install prisma-client
npm install -D prisma
```

---

## Schema 설정

### ⚠️ 필수: Multi-File 구조 사용

Prisma 스키마는 **반드시 Multi-File 구조**로 작성합니다.

```
prisma/
├── schema/
│   ├── +base.prisma      # datasource, generator 설정
│   ├── +enum.prisma      # 모든 enum 정의
│   ├── user.prisma       # User 모델
│   ├── post.prisma       # Post 모델
│   └── ...               # 기타 모델별 파일
```

### ⚠️ 필수: 한글 주석 작성

**Prisma Multi-File의 모든 요소에 한글 주석을 작성해야 합니다.**

```
✅ 파일별 목적 주석
✅ 모델별 설명 주석
✅ 필드별 설명 주석 (용도가 명확하지 않은 경우)
✅ 관계 설명 주석
✅ enum 값 설명 주석
```

### Multi-File 스키마 예시

#### +base.prisma (기본 설정)

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
  provider = "prisma-client"     // Prisma v7 필수
  output   = "./generated/client"
}
```

#### +enum.prisma (열거형 정의)

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
```

#### user.prisma (User 모델)

```prisma
// prisma/schema/user.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 사용자 모델
// 시스템의 모든 사용자 정보를 저장
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

model User {
  id        String   @id @default(cuid())
  email     String   @unique   // 로그인 이메일 (중복 불가)
  name      String?            // 표시 이름 (선택)
  posts     Post[]             // 작성한 게시글 목록
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

#### post.prisma (Post 모델)

```prisma
// prisma/schema/post.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 게시글 모델
// 사용자가 작성한 게시글 정보
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

model Post {
  id        String   @id @default(cuid())
  title     String              // 게시글 제목
  content   String?             // 게시글 본문 (선택)
  published Boolean  @default(false)  // 공개 여부
  author    User     @relation(fields: [authorId], references: [id])  // 작성자 관계
  authorId  String              // 작성자 ID (외래키)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

---

## Prisma Client 설정

### database/prisma.ts

```typescript
import { PrismaClient } from '../prisma/generated/client'

// 싱글톤 패턴
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

---

## CRUD 작업

### Create

```typescript
// 단일 생성
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John',
  },
})

// 관계와 함께 생성
const userWithPosts = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John',
    posts: {
      create: [
        { title: 'Post 1', content: 'Content 1' },
        { title: 'Post 2', content: 'Content 2' },
      ],
    },
  },
  include: {
    posts: true,
  },
})

// 다수 생성
const users = await prisma.user.createMany({
  data: [
    { email: 'user1@example.com', name: 'User 1' },
    { email: 'user2@example.com', name: 'User 2' },
  ],
  skipDuplicates: true,
})
```

### Read

```typescript
// 단일 조회
const user = await prisma.user.findUnique({
  where: { id: 'user-id' },
})

// 필수 조회 (없으면 에러)
const user = await prisma.user.findUniqueOrThrow({
  where: { id: 'user-id' },
})

// 조건 조회
const user = await prisma.user.findFirst({
  where: { email: { contains: '@example.com' } },
})

// 다수 조회
const users = await prisma.user.findMany({
  where: { name: { not: null } },
  orderBy: { createdAt: 'desc' },
  take: 10,
  skip: 0,
})

// 관계 포함
const userWithPosts = await prisma.user.findUnique({
  where: { id: 'user-id' },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
    },
  },
})

// 특정 필드만 선택
const userEmail = await prisma.user.findUnique({
  where: { id: 'user-id' },
  select: {
    id: true,
    email: true,
  },
})
```

### Update

```typescript
// 단일 수정
const user = await prisma.user.update({
  where: { id: 'user-id' },
  data: { name: 'New Name' },
})

// 다수 수정
const users = await prisma.user.updateMany({
  where: { name: null },
  data: { name: 'Anonymous' },
})

// 없으면 생성 (Upsert)
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { name: 'Updated Name' },
  create: { email: 'user@example.com', name: 'New User' },
})
```

### Delete

```typescript
// 단일 삭제
const user = await prisma.user.delete({
  where: { id: 'user-id' },
})

// 다수 삭제
const users = await prisma.user.deleteMany({
  where: { email: { contains: '@test.com' } },
})
```

---

## 필터링

### 비교 연산자

```typescript
await prisma.user.findMany({
  where: {
    age: { gt: 18 },      // >
    age: { gte: 18 },     // >=
    age: { lt: 65 },      // <
    age: { lte: 65 },     // <=
    age: { not: 30 },     // !=
    name: { equals: 'John' },
  },
})
```

### 문자열 필터

```typescript
await prisma.user.findMany({
  where: {
    email: { contains: '@gmail.com' },
    email: { startsWith: 'admin' },
    email: { endsWith: '.com' },
    name: { mode: 'insensitive' }, // 대소문자 무시
  },
})
```

### 논리 연산자

```typescript
await prisma.user.findMany({
  where: {
    AND: [
      { email: { contains: '@' } },
      { name: { not: null } },
    ],
    OR: [
      { role: 'admin' },
      { role: 'moderator' },
    ],
    NOT: {
      status: 'banned',
    },
  },
})
```

### 배열 필터

```typescript
await prisma.user.findMany({
  where: {
    id: { in: ['id1', 'id2', 'id3'] },
    role: { notIn: ['banned', 'suspended'] },
  },
})
```

---

## 관계 쿼리

### Include (전체 데이터)

```typescript
const user = await prisma.user.findUnique({
  where: { id: 'user-id' },
  include: {
    posts: true,
    profile: true,
  },
})
```

### Select (특정 필드)

```typescript
const user = await prisma.user.findUnique({
  where: { id: 'user-id' },
  select: {
    id: true,
    email: true,
    posts: {
      select: { id: true, title: true },
    },
  },
})
```

### 관계 필터링

```typescript
// 관계 조건으로 필터
const usersWithPublishedPosts = await prisma.user.findMany({
  where: {
    posts: {
      some: { published: true },  // 하나라도 만족
      // every: { published: true }, // 모두 만족
      // none: { published: true },  // 하나도 없음
    },
  },
})
```

---

## 트랜잭션

### Sequential 트랜잭션

```typescript
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: 'user@example.com' } }),
  prisma.post.create({ data: { title: 'New Post', authorId: 'user-id' } }),
])
```

### Interactive 트랜잭션

```typescript
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id: 'user-id' } })

  if (!user) {
    throw new Error('User not found')
  }

  const post = await tx.post.create({
    data: {
      title: 'New Post',
      authorId: user.id,
    },
  })

  return { user, post }
})
```

---

## Hono와 함께 사용

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { HTTPException } from 'hono/http-exception'
import { prisma } from '@/database/prisma'

const app = new Hono()

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).optional(),
})

app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')

  // 중복 체크
  const existing = await prisma.user.findUnique({
    where: { email: data.email },
  })

  if (existing) {
    throw new HTTPException(409, { message: 'Email already exists' })
  }

  const user = await prisma.user.create({ data })
  return c.json({ user }, 201)
})

app.get('/users/:id', async (c) => {
  const id = c.req.param('id')
  const user = await prisma.user.findUnique({
    where: { id },
    include: { posts: true },
  })

  if (!user) {
    throw new HTTPException(404, { message: 'User not found' })
  }

  return c.json({ user })
})

export default app
```

---

## 관련 문서

- [Config 파일](./config.md) - prisma.config.ts 설정 ⭐
- [Schema 정의](./schema.md)
- [Relations](./relations.md)
- [Transactions](./transactions.md)
- [Cloudflare D1](./cloudflare-d1.md) - D1 서버리스 데이터베이스 연동
