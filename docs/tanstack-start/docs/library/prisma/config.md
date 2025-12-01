# Prisma - Config 파일 (prisma.config.ts)

> **상위 문서**: [Prisma](./index.md)

Prisma v7에서 도입된 `prisma.config.ts` 설정 파일입니다.

---

## ⚠️ 필수: Multi-File 스키마 설정

Multi-File 스키마를 사용하려면 **반드시** `prisma.config.ts`에서 스키마 폴더를 지정해야 합니다.

```typescript
// prisma.config.ts
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  // Multi-File 스키마 폴더 지정
  schema: path.join('prisma', 'schema'),
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

---

## 파일 위치 및 이름

### 지원되는 파일명

```
prisma.config.ts      # 권장 (소규모 프로젝트)
prisma.config.js
prisma.config.mjs
prisma.config.cjs
prisma.config.mts
prisma.config.cts

.config/prisma.ts     # 권장 (대규모 프로젝트)
.config/prisma.js
```

### 권장 위치

```
프로젝트/
├── prisma.config.ts      # 프로젝트 루트
├── prisma/
│   ├── schema/           # Multi-File 스키마 폴더
│   │   ├── +base.prisma
│   │   ├── +enum.prisma
│   │   └── user.prisma
│   └── migrations/       # 마이그레이션 폴더
└── package.json
```

---

## 설정 옵션

### 전체 옵션 목록

| 옵션 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `schema` | string | ❌ | 스키마 파일 또는 폴더 경로 |
| `datasource.url` | string | ✅ | 데이터베이스 연결 URL |
| `datasource.shadowDatabaseUrl` | string | ❌ | Shadow DB URL |
| `migrations.path` | string | ❌ | 마이그레이션 폴더 경로 |
| `migrations.seed` | string | ❌ | 시드 스크립트 명령어 |
| `migrations.initShadowDb` | string | ❌ | Shadow DB 초기화 SQL |
| `views.path` | string | ❌ | SQL 뷰 정의 폴더 |
| `typedSql.path` | string | ❌ | TypedSQL 파일 폴더 |
| `experimental` | object | ❌ | 실험적 기능 활성화 |

---

## 기본 설정 예시

### defineConfig 사용 (권장)

```typescript
// prisma.config.ts
import 'dotenv/config'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  // Multi-File 스키마 설정
  schema: 'prisma/schema',

  // 마이그레이션 설정
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },

  // 데이터베이스 연결
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### satisfies 사용

```typescript
// prisma.config.ts
import 'dotenv/config'
import type { PrismaConfig } from 'prisma'
import { env } from 'prisma/config'

export default {
  schema: 'prisma/schema',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
} satisfies PrismaConfig
```

---

## Multi-File 스키마 설정

### 필수 설정

```typescript
// prisma.config.ts
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  // ⚠️ 폴더 경로 지정 (파일이 아님!)
  schema: path.join('prisma', 'schema'),
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### 폴더 구조

```
prisma/
├── schema/                    # Multi-File 스키마 폴더
│   ├── +base.prisma          # datasource, generator 설정
│   ├── +enum.prisma          # 모든 enum 정의
│   ├── user.prisma           # User 모델
│   ├── post.prisma           # Post 모델
│   └── ...
└── migrations/               # ⚠️ datasource와 같은 레벨에 위치
```

### +base.prisma 예시

```prisma
// prisma/schema/+base.prisma
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Prisma 기본 설정 파일
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 데이터베이스 연결 설정
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Prisma Client 생성 설정
generator client {
  provider = "prisma-client"  // Prisma v7 필수
  output   = "../../generated/prisma"
}
```

---

## 환경 변수 설정

### dotenv 설치

```bash
npm install dotenv
```

### 환경 변수 사용

```typescript
// prisma.config.ts
import 'dotenv/config'  // ⚠️ 반드시 최상단에 import
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema',
  datasource: {
    url: env('DATABASE_URL'),  // 타입 안전한 환경 변수 접근
  },
})
```

### .env 파일

```env
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"
```

---

## 마이그레이션 설정

### 시드 스크립트

```typescript
// prisma.config.ts
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',  // 시드 명령어
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

### 시드 파일 예시

```typescript
// prisma/seed.ts
import { PrismaClient } from '../generated/prisma'

const prisma = new PrismaClient()

async function main() {
  // 초기 데이터 생성
  await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: '관리자',
      role: 'ADMIN',
    },
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

---

## Shadow Database 설정

마이그레이션 시 사용되는 임시 데이터베이스입니다.

```typescript
// prisma.config.ts
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema',
  datasource: {
    url: env('DATABASE_URL'),
    shadowDatabaseUrl: env('SHADOW_DATABASE_URL'),
  },
})
```

---

## 실험적 기능

### External Tables

외부에서 관리되는 테이블 설정:

```typescript
// prisma.config.ts
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  schema: 'prisma/schema',
  experimental: {
    externalTables: true,
  },
  tables: {
    external: ['public.users'],
  },
  enums: {
    external: ['public.role'],
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

---

## 경로 해석 규칙

### 중요 사항

- 모든 경로는 **config 파일 위치 기준**으로 해석됩니다
- CLI 명령어 실행 위치가 아닙니다!

### 예시

```
프로젝트/
├── prisma.config.ts          # 여기가 기준!
├── prisma/
│   └── schema/
└── src/
```

```typescript
// prisma.config.ts
export default defineConfig({
  // ✅ prisma.config.ts 기준 상대 경로
  schema: 'prisma/schema',

  // ❌ 이렇게 하지 마세요
  schema: './prisma/schema',  // ./ 불필요
})
```

### 커스텀 경로 지정

```bash
# --config 플래그로 config 파일 위치 지정
npx prisma validate --config ./path/to/myconfig.ts
```

---

## 전체 설정 예시

```typescript
// prisma.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Prisma v7 설정 파일
// Multi-File 스키마 및 마이그레이션 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import 'dotenv/config'
import path from 'node:path'
import { defineConfig, env } from 'prisma/config'

export default defineConfig({
  // Multi-File 스키마 폴더
  schema: path.join('prisma', 'schema'),

  // 마이그레이션 설정
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },

  // 데이터베이스 연결
  datasource: {
    url: env('DATABASE_URL'),
  },
})
```

---

## 관련 문서

- [스키마 정의 (Multi-File)](./schema.md)
- [설치 및 설정](./setup.md)
