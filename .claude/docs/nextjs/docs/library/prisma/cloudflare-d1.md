# Prisma - Cloudflare D1

SQLite 기반 서버리스 DB. 일반 Prisma 마이그레이션과 다른 워크플로우.

⚠️ 트랜잭션 미지원 | prisma migrate 불가 - wrangler 사용 | Preview 상태

## 설정

```prisma
// schema.prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
  runtime  = "cloudflare"  // 필수
}

datasource db {
  provider = "sqlite"
}
```

```jsonc
// wrangler.jsonc
{
  "d1_databases": [{ "binding": "DB", "database_name": "my-db", "database_id": "ID" }]
}
```

## 사용법

```typescript
import { PrismaClient } from './generated/prisma'
import { PrismaD1 } from '@prisma/adapter-d1'

export interface Env { DB: D1Database }

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const adapter = new PrismaD1(env.DB)
    const prisma = new PrismaClient({ adapter })
    const users = await prisma.user.findMany()
    return new Response(JSON.stringify(users))
  },
}
```

## 마이그레이션 워크플로우

```bash
# 1. D1 생성
npx wrangler d1 create my-database

# 2. 마이그레이션 생성
npx wrangler d1 migrations create my-database init

# 3. SQL 생성 (초기)
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script --output prisma/migrations/0001.sql

# 4. SQL 생성 (후속)
npx prisma migrate diff --from-local-d1 --to-schema-datamodel prisma/schema.prisma --script

# 5. 적용
npx wrangler d1 migrations apply my-database --local   # 로컬
npx wrangler d1 migrations apply my-database --remote  # 프로덕션

# 6. Client 생성
npx prisma generate
```

## 제한사항

| 항목 | 일반 SQLite | D1 |
|------|-------------|-----|
| 마이그레이션 | prisma migrate | wrangler d1 |
| 트랜잭션 | ✅ | ❌ |
| 접속 | 직접 | HTTP 어댑터 |
