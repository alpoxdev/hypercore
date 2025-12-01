# Prisma

> **Version**: 7.x | Node.js/TypeScript ORM

---

## 🚀 Quick Reference (복사용)

```typescript
// Prisma Client 설정
import { PrismaClient } from './generated/prisma'  // v7 경로!

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
```

### v7 schema.prisma (⚠️ 중요)

```prisma
generator client {
  provider = "prisma-client"        // v7! (prisma-client-js 아님)
  output   = "../generated/prisma"  // output 필수!
}
```

### ⛔ Claude Code 금지

```
❌ prisma db push 자동 실행 금지
❌ prisma migrate 자동 실행 금지
❌ prisma generate 자동 실행 금지
❌ schema.prisma 임의 변경 금지
```

---

## 문서 구조

- [Config 파일](./config.md) - prisma.config.ts 설정 ⭐
- [설치 및 설정](./setup.md) - Prisma Client 설정
- [스키마 정의 (Multi-File)](./schema.md) - 모델, 관계, Enum 정의
- [CRUD 작업](./crud.md) - Create, Read, Update, Delete
- [관계 쿼리](./relations.md) - 중첩 생성, 관계 포함 조회
- [트랜잭션](./transactions.md) - 배열 기반 트랜잭션, 인터랙티브 트랜잭션
- [Cloudflare D1](./cloudflare-d1.md) - D1 서버리스 데이터베이스 연동

## 빠른 시작

```bash
# npm
npm install @prisma/client@7
npm install -D prisma@7

# yarn
yarn add @prisma/client@7
yarn add -D prisma@7

# 초기화
npx prisma init
```

## v7 주요 변경사항

### 새로운 Generator Provider

```prisma
// schema.prisma
generator client {
  provider = "prisma-client"        // prisma-client-js → prisma-client
  output   = "../generated/prisma"  // output 필드 필수
}
```

### 새로운 옵션들

```prisma
generator client {
  provider        = "prisma-client"
  output          = "../generated/prisma"
  runtime         = "nodejs"        // nodejs, deno, bun, workerd, vercel-edge, react-native
  moduleFormat    = "esm"           // esm 또는 cjs
  previewFeatures = ["queryCompiler", "driverAdapters"]
}
```

## 핵심 개념

### Prisma Client 설정

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: ['query'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

### 기본 쿼리

```typescript
// 조회
const users = await prisma.user.findMany()

// 생성
const user = await prisma.user.create({
  data: { email: 'alice@prisma.io', name: 'Alice' },
})

// 수정
const updated = await prisma.user.update({
  where: { id: 1 },
  data: { name: 'Updated Name' },
})

// 삭제
const deleted = await prisma.user.delete({
  where: { id: 1 },
})
```

## 마이그레이션 명령어

```bash
# 개발 환경 마이그레이션
npx prisma migrate dev --name init

# 프로덕션 마이그레이션
npx prisma migrate deploy

# 스키마 동기화 (개발용)
npx prisma db push

# Prisma Client 생성
npx prisma generate

# Prisma Studio (GUI)
npx prisma studio
```

## 참고 자료

- [Prisma 공식 문서](https://www.prisma.io/docs)
- [Prisma GitHub](https://github.com/prisma/prisma)
