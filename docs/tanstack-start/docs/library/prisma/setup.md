# Prisma - 설치 및 설정

> **상위 문서**: [Prisma](./index.md)

## 설치

```bash
# npm
npm install @prisma/client@7
npm install -D prisma@7

# yarn
yarn add @prisma/client@7
yarn add -D prisma@7

# bun
bun add @prisma/client@7
bun add prisma@7 --dev

# 초기화
npx prisma init
```

## v6에서 v7 업그레이드

```bash
# npm
npm install @prisma/client@7
npm install -D prisma@7

# yarn
yarn up prisma@7 @prisma/client@7
```

### Generator 변경 (필수)

```prisma
// schema.prisma - 이전 (v6)
generator client {
  provider = "prisma-client-js"
}

// schema.prisma - v7
generator client {
  provider = "prisma-client"        // 새로운 provider
  output   = "../generated/prisma"  // output 필수
}
```

## Prisma Client 설정

### 기본 설정

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'  // output 경로에서 import

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

### 로깅 설정

```typescript
import { PrismaClient } from './generated/prisma'

const prisma = new PrismaClient({
  log: [{ level: 'query', emit: 'event' }],
})

prisma.$on('query', (e) => {
  console.log('Query:', e.query)
  console.log('Params:', e.params)
  console.log('Duration:', e.duration, 'ms')
})
```

### QueryEvent 타입

```typescript
type QueryEvent = {
  timestamp: Date
  query: string
  params: string
  duration: number
  target: string
}
```

## TanStack Start 통합

```typescript
// lib/prisma.ts
import { PrismaClient } from './generated/prisma'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

// Server Function에서 사용
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '~/lib/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany({
      include: { posts: true },
    })
  })

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator((data: { email: string; name: string }) => data)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

## 마이그레이션

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
