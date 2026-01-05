# Drizzle - Config 파일

> drizzle.config.ts 설정

---

## 기본 설정

```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

---

## 파일 위치

```
프로젝트/
├── drizzle.config.ts     # 프로젝트 루트
├── drizzle/
│   └── migrations/       # 마이그레이션 파일
├── src/
│   └── db/
│       ├── index.ts      # Drizzle client
│       └── schema/       # 스키마 정의
│           ├── index.ts
│           ├── user.ts
│           └── post.ts
```

---

## PostgreSQL

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

---

## MySQL

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'mysql',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

---

## SQLite

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'sqlite',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dbCredentials: {
    url: './sqlite.db',
  },
})
```

---

## Cloudflare D1

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'sqlite',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  driver: 'd1-http',
  dbCredentials: {
    accountId: process.env.CLOUDFLARE_ACCOUNT_ID!,
    databaseId: process.env.CLOUDFLARE_DATABASE_ID!,
    token: process.env.CLOUDFLARE_D1_TOKEN!,
  },
})
```

---

## 설정 옵션

| 옵션 | 설명 |
|------|------|
| `dialect` | DB 종류 (postgresql, mysql, sqlite) |
| `schema` | 스키마 파일 경로 |
| `out` | 마이그레이션 출력 폴더 |
| `dbCredentials` | DB 연결 정보 |
| `driver` | 드라이버 (d1-http 등) |
| `verbose` | 상세 로그 출력 |
| `strict` | 엄격 모드 |

---

## 환경변수 로드

```typescript
// drizzle.config.ts
import 'dotenv/config'
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/db/schema/index.ts',
  out: './drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

---

## 다중 스키마 파일

```typescript
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/db/schema/*.ts',  // glob 패턴
  out: './drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

---

## 관련 문서

- [Drizzle 개요](./index.md)
- [Cloudflare D1](./cloudflare-d1.md)
