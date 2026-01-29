# Prisma - Config 파일

> prisma.config.ts 설정 (v7)

---

## Multi-File 스키마 필수 설정

```typescript
// prisma.config.ts
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'), // 폴더 경로
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

---

## 파일 위치

```
프로젝트/
├── prisma.config.ts      # 프로젝트 루트
├── prisma/
│   ├── schema/           # Multi-File 스키마
│   │   ├── +base.prisma
│   │   ├── +enum.prisma
│   │   └── user.prisma
│   └── migrations/
└── src/
```

---

## 전체 설정 예시

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

---

## +base.prisma

```prisma
// prisma/schema/+base.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"  // v7 필수
  output   = "../../generated/prisma"
}
```

---

## 시드 스크립트

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/prisma'

const prisma = new PrismaClient()

async function main() {
  await prisma.user.create({
    data: { email: 'admin@example.com', name: '관리자' },
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

---

## Cloudflare Workers

```prisma
// prisma/schema/+base.prisma
generator client {
  provider = "prisma-client"
  output   = "../../generated/prisma"
  runtime  = "workerd"  // Workers 런타임
}

datasource db {
  provider = "sqlite"  // D1은 SQLite
  url      = env("DATABASE_URL")
}
```

---

## 관련 문서

- [Prisma 개요](./index.md)
- [Cloudflare D1](./cloudflare-d1.md)
