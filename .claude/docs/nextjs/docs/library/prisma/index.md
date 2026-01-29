# Prisma

> **Version**: 7.x | Node.js/TypeScript ORM

@setup.md
@config.md
@schema.md
@crud.md
@relations.md
@transactions.md
@cloudflare-d1.md

---

## Quick Reference

```typescript
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

| 금지 사항 |
|----------|
| prisma db push 자동 실행 |
| prisma migrate 자동 실행 |
| prisma generate 자동 실행 |
| schema.prisma 임의 변경 |

---

## Prisma Client 설정

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined }
export const prisma = globalForPrisma.prisma ?? new PrismaClient({ log: ['query'] })
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

## 마이그레이션 명령어

```bash
npx prisma migrate dev --name init   # 개발 마이그레이션
npx prisma migrate deploy            # 프로덕션 마이그레이션
npx prisma db push                   # 스키마 동기화 (개발용)
npx prisma generate                  # Client 생성
npx prisma studio                    # GUI
```
