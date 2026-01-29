# Prisma

> **Version 7.x** | Node.js/TypeScript ORM

---

<context>

**Purpose:** Node.js/TypeScript용 타입 안전 ORM

**Key Features:**
- 타입 안전 데이터베이스 클라이언트
- Multi-File 스키마 지원 (v7)
- 마이그레이션 관리
- 관계형/NoSQL 데이터베이스 지원

**Breaking Changes (v7):**
- `generator client { provider = "prisma-client" }` (~~prisma-client-js~~)
- `output` 필드 필수
- Multi-File 스키마 구조 (`prisma/schema/` 폴더)

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **자동 실행** | ❌ `prisma db push` 자동 실행 |
| | ❌ `prisma migrate` 자동 실행 |
| | ❌ `prisma generate` 자동 실행 |
| **스키마 변경** | ❌ `schema.prisma` 임의 변경 (사용자 확인 없이) |
| **구조** | ❌ Single-File 스키마 (`schema.prisma`) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **구조** | ✅ Multi-File 스키마 (`prisma/schema/` 폴더) |
| **주석** | ✅ 모든 모델/필드/enum에 한글 주석 |
| **v7 설정** | ✅ `generator client { provider = "prisma-client" }` |
| | ✅ `output` 필드 명시 (`../generated/prisma`) |
| **Import** | ✅ `import { PrismaClient } from './generated/prisma'` |

</required>

---

<version_v7>

## v7 Breaking Changes

### 1. Generator Provider

```prisma
// ❌ v6 (이전)
generator client {
  provider = "prisma-client-js"
}

// ✅ v7 (필수)
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"  // output 필수!
}
```

### 2. Multi-File Schema

```
// ❌ v6 구조
prisma/
└── schema.prisma

// ✅ v7 구조
prisma/
├── schema/
│   ├── +base.prisma   # datasource, generator
│   ├── +enum.prisma   # 모든 enum
│   ├── user.prisma    # User 모델
│   └── post.prisma    # Post 모델
└── migrations/
```

### 3. Import Path

```typescript
// ❌ v6
import { PrismaClient } from '@prisma/client'

// ✅ v7
import { PrismaClient } from './generated/prisma'
```

### 4. Config File

```typescript
// prisma.config.ts (v7 필수)
import 'dotenv/config'
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'),  // 폴더!
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

</version_v7>

---

<setup>

## 설치 및 설정

### 설치

```bash
yarn add @prisma/client@7
yarn add -D prisma@7
npx prisma init
```

### Multi-File Schema 구조 생성

```
프로젝트/
├── prisma.config.ts
├── prisma/
│   ├── schema/
│   │   ├── +base.prisma
│   │   ├── +enum.prisma
│   │   └── user.prisma
│   ├── migrations/
│   └── seed.ts
└── generated/
    └── prisma/
```

### Prisma Client 초기화

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: ['query', 'error', 'warn']
})

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

### TanStack Start 연동

```typescript
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/lib/prisma'

// GET
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany({ include: { posts: true } }))

// POST with validation
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))
```

</setup>

---

<configuration>

## Configuration (prisma.config.ts)

### 기본 설정

```typescript
// prisma.config.ts
import 'dotenv/config'
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'),
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### 옵션

| 옵션 | 설명 | 필수 |
|------|------|------|
| `schema` | 스키마 폴더 경로 | ✅ |
| `datasource.url` | 데이터베이스 URL | ✅ |
| `datasource.shadowDatabaseUrl` | Shadow DB URL (개발용) | |
| `migrations.path` | 마이그레이션 폴더 | |
| `migrations.seed` | 시드 명령어 | |

### +base.prisma

```prisma
datasource db {
  provider = "postgresql"  // postgresql | mysql | sqlite | mongodb
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "../../generated/prisma"
}
```

### Seed 파일

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/prisma'

const prisma = new PrismaClient()

async function main() {
  // 관리자 계정 생성
  await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: '관리자',
      role: 'ADMIN',
    },
  })

  console.log('Seed completed')
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

</configuration>

---

<schema>

## Schema Definition (Multi-File)

### 구조

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # 모든 enum 정의
├── user.prisma     # User 모델
├── post.prisma     # Post 모델
└── category.prisma # Category 모델
```

### +enum.prisma

```prisma
// +enum.prisma
// 사용자 역할
enum Role {
  USER   // 일반 사용자
  ADMIN  // 관리자
}

// 게시글 상태
enum PostStatus {
  DRAFT      // 임시 저장
  PUBLISHED  // 발행됨
  ARCHIVED   // 보관됨
}
```

### 모델 정의

```prisma
// user.prisma
// 사용자 모델
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique  // 로그인 이메일
  name      String?           // 표시 이름
  role      Role     @default(USER)  // 권한
  posts     Post[]            // 작성 게시글 (1:N)
  profile   Profile?          // 프로필 (1:1)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")
}

// post.prisma
// 게시글 모델
model Post {
  id         Int        @id @default(autoincrement())
  title      String     // 제목
  content    String?    // 본문
  status     PostStatus @default(DRAFT)
  author     User       @relation(fields: [authorId], references: [id])
  authorId   Int        // 작성자 ID
  categories Category[] // 카테고리 (M:N)
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt

  @@index([authorId])
  @@index([status])
  @@map("posts")
}
```

### 관계 패턴

| 관계 | 패턴 |
|------|------|
| **1:1** | `Profile? @relation(fields: [userId], references: [id])` + `userId Int @unique` |
| **1:N** | `posts Post[]` (부모) / `author User @relation(...)` (자식) |
| **M:N (암묵적)** | `categories Category[]` (양쪽) |
| **M:N (명시적)** | 중간 테이블 + `@@id([id1, id2])` |

### 1:1 관계

```prisma
// profile.prisma
model Profile {
  id     Int    @id @default(autoincrement())
  bio    String?  // 소개
  user   User   @relation(fields: [userId], references: [id])
  userId Int    @unique  // unique 필수!
}
```

### 1:N 관계

```prisma
// user.prisma
model User {
  posts Post[]  // 관계 배열
}

// post.prisma
model Post {
  author   User @relation(fields: [authorId], references: [id])
  authorId Int  // Foreign Key
}
```

### M:N 관계 (암묵적)

```prisma
// post.prisma
model Post {
  categories Category[]  // 중간 테이블 자동 생성
}

// category.prisma
model Category {
  posts Post[]
}
```

### M:N 관계 (명시적)

```prisma
// category-on-post.prisma
model CategoriesOnPosts {
  post       Post     @relation(fields: [postId], references: [id])
  postId     Int
  category   Category @relation(fields: [categoryId], references: [id])
  categoryId Int
  assignedAt DateTime @default(now())  // 추가 필드 가능

  @@id([postId, categoryId])
  @@index([postId])
  @@index([categoryId])
}
```

### 선택적 관계

```prisma
author   User? @relation(fields: [authorId], references: [id])
authorId Int?  // nullable
```

### 인덱스 & 매핑

```prisma
// 단일 인덱스
@@index([email])
@@index([createdAt])

// 복합 인덱스
@@index([authorId, status])

// 복합 키
@@id([postId, categoryId])

// 필드 매핑
userId Int @map("user_id")

// 테이블 매핑
@@map("users")
```

</schema>

---

<crud>

## CRUD Operations

### Create

```typescript
// 단일 생성
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    name: 'Alice',
    role: 'USER',
  },
})

// 관계 포함 생성
const user = await prisma.user.create({
  data: {
    email: 'bob@prisma.io',
    name: 'Bob',
    posts: {
      create: [
        { title: 'Hello World', status: 'PUBLISHED' },
        { title: 'Second Post', status: 'DRAFT' },
      ],
    },
  },
  include: { posts: true },
})

// connectOrCreate (있으면 연결, 없으면 생성)
const post = await prisma.post.create({
  data: {
    title: 'Post with Tags',
    categories: {
      connectOrCreate: [
        { where: { name: 'Tech' }, create: { name: 'Tech' } },
        { where: { name: 'Tutorial' }, create: { name: 'Tutorial' } },
      ],
    },
  },
})
```

### Read

```typescript
// 단일 조회 (findUnique)
const user = await prisma.user.findUnique({
  where: { email: 'alice@prisma.io' }
})

// 다중 조회 (findMany)
const users = await prisma.user.findMany({
  where: { role: 'ADMIN' },
  orderBy: { createdAt: 'desc' },
  take: 10,
})

// 관계 포함
const users = await prisma.user.findMany({
  include: {
    posts: true,
    profile: true,
  },
})

// 필드 선택 (select)
const user = await prisma.user.findUnique({
  where: { email: 'alice@prisma.io' },
  select: {
    email: true,
    posts: {
      select: { title: true, createdAt: true },
      where: { status: 'PUBLISHED' },
    },
  },
})

// 관계로 필터
const users = await prisma.user.findMany({
  where: {
    posts: {
      some: { status: 'PUBLISHED' },  // 게시글이 하나라도 있는 사용자
    },
  },
})
```

### Update

```typescript
// 단일 수정
const user = await prisma.user.update({
  where: { id: 1 },
  data: { name: 'Updated Name' },
})

// 다중 수정
await prisma.user.updateMany({
  where: { role: 'USER' },
  data: { role: 'ADMIN' },
})

// Upsert (있으면 수정, 없으면 생성)
const user = await prisma.user.upsert({
  where: { email: 'alice@prisma.io' },
  update: { name: 'Updated Alice' },
  create: { email: 'alice@prisma.io', name: 'Alice' },
})

// 증감 연산
await prisma.post.update({
  where: { id: 1 },
  data: {
    views: { increment: 1 },
    likes: { decrement: 1 },
  },
})
```

### Delete

```typescript
// 단일 삭제
await prisma.user.delete({ where: { id: 1 } })

// 다중 삭제
await prisma.post.deleteMany({ where: { status: 'DRAFT' } })

// 전체 삭제
await prisma.user.deleteMany({})
```

### 필터 연산자

| 타입 | 연산자 |
|------|--------|
| **문자열** | `contains`, `startsWith`, `endsWith`, `mode: 'insensitive'` |
| **숫자** | `gt`, `gte`, `lt`, `lte` |
| **배열** | `in`, `notIn` |
| **논리** | `OR`, `AND`, `NOT` |
| **관계** | `some`, `every`, `none` |

```typescript
// 문자열 검색
where: { email: { contains: 'prisma', mode: 'insensitive' } }

// 숫자 범위
where: { age: { gte: 18, lte: 65 } }

// 배열
where: { id: { in: [1, 2, 3] } }

// 논리 연산
where: {
  OR: [
    { role: 'ADMIN' },
    { posts: { some: { status: 'PUBLISHED' } } },
  ],
}
```

</crud>

---

<relations>

## Relation Queries

### 중첩 생성

```typescript
// 1:N 관계 생성
const user = await prisma.user.create({
  data: {
    email: 'user@prisma.io',
    posts: {
      create: [
        { title: 'Post 1', status: 'PUBLISHED' },
        { title: 'Post 2', status: 'DRAFT' },
      ],
    },
  },
  include: { posts: true },
})
```

### 관계 연결

```typescript
// connect - 기존 레코드 연결
await prisma.post.create({
  data: {
    title: 'New Post',
    author: { connect: { id: 1 } },
  },
})

// connectOrCreate
await prisma.post.create({
  data: {
    title: 'Post with Category',
    categories: {
      connectOrCreate: {
        where: { name: 'Tech' },
        create: { name: 'Tech' },
      },
    },
  },
})

// disconnect
await prisma.post.update({
  where: { id: 1 },
  data: {
    author: { disconnect: true },
  },
})
```

### 관계 포함 조회

```typescript
// include
const users = await prisma.user.findMany({
  include: {
    posts: true,
    profile: true,
  },
})

// 중첩 include
const users = await prisma.user.findMany({
  include: {
    posts: {
      include: { categories: true },
    },
  },
})

// 필터 + 정렬
const users = await prisma.user.findMany({
  include: {
    posts: {
      where: { status: 'PUBLISHED' },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  },
})
```

### 관계로 필터링

```typescript
// some - 하나라도 만족
where: {
  posts: { some: { status: 'PUBLISHED' } },
}

// every - 모두 만족
where: {
  posts: { every: { status: 'PUBLISHED' } },
}

// none - 만족하는 것 없음
where: {
  posts: { none: { status: 'DRAFT' } },
}
```

### 관계 카운트

```typescript
const users = await prisma.user.findMany({
  include: {
    _count: {
      select: { posts: true },
    },
  },
})
// 결과: { ..., _count: { posts: 5 } }
```

### 중첩 수정/삭제

```typescript
// 중첩 수정
await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      updateMany: {
        where: { status: 'DRAFT' },
        data: { status: 'PUBLISHED' },
      },
    },
  },
})

// 중첩 삭제
await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      deleteMany: { where: { status: 'DRAFT' } },
    },
  },
})
```

</relations>

---

<transactions>

## Transactions

### 배열 기반 트랜잭션

하나라도 실패하면 전체 롤백.

```typescript
const deletePosts = prisma.post.deleteMany({ where: { authorId: 7 } })
const deleteUser = prisma.user.delete({ where: { id: 7 } })

await prisma.$transaction([deletePosts, deleteUser])
```

### 인터랙티브 트랜잭션

복잡한 로직, 조건부 처리.

```typescript
const result = await prisma.$transaction(async (tx) => {
  // 1. 잔액 확인
  const sender = await tx.account.findUnique({ where: { id: senderId } })
  if (!sender || sender.balance < amount) {
    throw new Error('Insufficient balance')
  }

  // 2. 송금자 차감
  await tx.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } },
  })

  // 3. 수신자 증가
  await tx.account.update({
    where: { id: recipientId },
    data: { balance: { increment: amount } },
  })

  return { success: true, amount }
})
```

### 트랜잭션 옵션

```typescript
await prisma.$transaction(async (tx) => {
  // 트랜잭션 로직
}, {
  maxWait: 5000,   // 최대 대기 시간 (ms)
  timeout: 10000,  // 타임아웃 (ms)
  isolationLevel: 'Serializable',  // 격리 수준
})
```

| Isolation Level | 설명 |
|----------------|------|
| `ReadUncommitted` | 가장 낮은 수준 (Dirty Read 가능) |
| `ReadCommitted` | 커밋된 데이터만 읽기 |
| `RepeatableRead` | 반복 읽기 보장 |
| `Serializable` | 가장 높은 수준 (직렬화) |

### 에러 처리

```typescript
try {
  await prisma.$transaction(async (tx) => {
    await tx.user.create({ data: { email: 'test@example.com' } })

    if (someCondition) {
      throw new Error('Rollback condition')
    }

    await tx.post.create({ data: { title: 'Post' } })
  })
} catch (error) {
  console.error('Transaction rolled back:', error)
  // 전체 작업 롤백됨
}
```

</transactions>

---

<cloudflare_d1>

## Cloudflare D1

SQLite 기반 서버리스 데이터베이스.

**Limitations:**
- ❌ 트랜잭션 미지원
- ❌ `prisma migrate` 불가 (wrangler 사용)
- ⚠️ Preview 상태

### 설정

```prisma
// +base.prisma
generator client {
  provider = "prisma-client"
  output   = "../../src/generated/prisma"
  runtime  = "cloudflare"  // 필수!
}

datasource db {
  provider = "sqlite"
}
```

```jsonc
// wrangler.jsonc
{
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "my-db",
      "database_id": "your-database-id"
    }
  ]
}
```

### 사용법

```typescript
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

export interface Env {
  DB: D1Database
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const adapter = new PrismaD1(env.DB)
    const prisma = new PrismaClient({ adapter })

    const users = await prisma.user.findMany()

    return new Response(JSON.stringify(users), {
      headers: { 'Content-Type': 'application/json' },
    })
  },
}
```

### 마이그레이션

```bash
# 1. D1 데이터베이스 생성
npx wrangler d1 create my-database

# 2. 마이그레이션 생성
npx wrangler d1 migrations create my-database init

# 3. SQL 생성 (초기)
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script \
  --output prisma/migrations/0001.sql

# 4. SQL 생성 (후속)
npx prisma migrate diff \
  --from-local-d1 \
  --to-schema-datamodel prisma/schema.prisma \
  --script

# 5. 마이그레이션 적용
npx wrangler d1 migrations apply my-database --local   # 로컬
npx wrangler d1 migrations apply my-database --remote  # 프로덕션

# 6. Client 생성
npx prisma generate
```

### 비교

| 항목 | 일반 SQLite | Cloudflare D1 |
|------|-------------|---------------|
| **마이그레이션** | ✅ `prisma migrate` | ❌ `wrangler d1` |
| **트랜잭션** | ✅ 지원 | ❌ 미지원 |
| **접속** | ✅ 직접 연결 | HTTP 어댑터 |
| **환경** | 로컬/서버 | Cloudflare Workers |

</cloudflare_d1>

---

<commands>

## CLI Commands

```bash
# 초기화
npx prisma init

# Client 생성
npx prisma generate

# 마이그레이션
npx prisma migrate dev --name init   # 개발 (스키마 변경 + 마이그레이션)
npx prisma migrate deploy            # 프로덕션 (마이그레이션 적용)
npx prisma migrate reset             # DB 초기화

# 스키마 동기화 (개발용)
npx prisma db push

# 시드
npx prisma db seed

# GUI
npx prisma studio

# 포맷팅
npx prisma format

# 유효성 검사
npx prisma validate
```

</commands>

---

<dos_and_donts>

## Do's & Don'ts

### ✅ Do

| 상황 | 방법 |
|------|------|
| **구조** | Multi-File 스키마 사용 (`prisma/schema/`) |
| **주석** | 모든 모델/필드/enum에 한글 주석 필수 |
| **Provider** | v7: `generator client { provider = "prisma-client" }` |
| **Import** | `import { PrismaClient } from './generated/prisma'` |
| **트랜잭션** | 복잡한 로직 → 인터랙티브 트랜잭션 사용 |
| **관계** | `include`로 관계 데이터 로드 |
| **인덱스** | 자주 조회하는 필드에 `@@index` 추가 |

### ❌ Don't

| 상황 | 이유 |
|------|------|
| **Single File** | ❌ `schema.prisma` 단일 파일 사용 금지 |
| **v6 Provider** | ❌ `prisma-client-js` 사용 금지 (v7) |
| **Import** | ❌ `@prisma/client` import 금지 (v7) |
| **자동 실행** | ❌ `prisma migrate/db push` 자동 실행 금지 |
| **N+1** | ❌ 루프에서 개별 쿼리 실행 → `include`/`findMany` 사용 |
| **Raw Query** | ❌ 타입 안전성 없음 → Prisma Query API 우선 |

### N+1 Problem 예방

```typescript
// ❌ N+1 Problem
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } })
}

// ✅ include 사용
const users = await prisma.user.findMany({
  include: { posts: true },
})
```

</dos_and_donts>

---

<quick_reference>

## Quick Reference

```typescript
// Client 초기화
import { PrismaClient } from './generated/prisma'
export const prisma = new PrismaClient()

// CRUD
const users = await prisma.user.findMany()
const user = await prisma.user.create({ data: { email, name } })
const updated = await prisma.user.update({ where: { id }, data: { name } })
const deleted = await prisma.user.delete({ where: { id } })

// 관계 포함
const userWithPosts = await prisma.user.findUnique({
  where: { id },
  include: { posts: true },
})

// 트랜잭션
await prisma.$transaction([
  prisma.user.create({ data: { email: 'a@example.com' } }),
  prisma.post.create({ data: { title: 'Post' } }),
])
```

</quick_reference>
