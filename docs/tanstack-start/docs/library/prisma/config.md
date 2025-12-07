# Prisma - Config 파일

Prisma v7 `prisma.config.ts` 설정.

## Multi-File 스키마 (필수)

```typescript
// prisma.config.ts
import 'dotenv/config'
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: path.join('prisma', 'schema'),  // 폴더 경로!
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

## 폴더 구조

```
프로젝트/
├── prisma.config.ts
├── prisma/
│   ├── schema/
│   │   ├── +base.prisma   # datasource, generator
│   │   ├── +enum.prisma   # enum 정의
│   │   └── user.prisma    # 모델
│   └── migrations/
```

## +base.prisma

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "../../generated/prisma"
}
```

## 설정 옵션

| 옵션 | 설명 |
|------|------|
| `schema` | 스키마 폴더 경로 |
| `datasource.url` | DB URL (필수) |
| `datasource.shadowDatabaseUrl` | Shadow DB URL |
| `migrations.path` | 마이그레이션 폴더 |
| `migrations.seed` | 시드 명령어 |

## 시드 파일

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/prisma'

const prisma = new PrismaClient()

async function main() {
  await prisma.user.create({
    data: { email: 'admin@example.com', name: '관리자', role: 'ADMIN' },
  })
}

main().catch(console.error).finally(() => prisma.$disconnect())
```
