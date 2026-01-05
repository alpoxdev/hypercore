# Drizzle - Config 파일

drizzle.config.ts 설정.

## 기본 설정

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

## 폴더 구조

```
프로젝트/
├── drizzle.config.ts
├── drizzle/
│   └── migrations/
│       ├── 0000_init.sql
│       └── meta/
├── src/
│   └── db/
│       └── schema/
│           ├── index.ts
│           └── user.ts
```

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

## 설정 옵션

| 옵션 | 설명 |
|------|------|
| `dialect` | DB 종류 (postgresql, mysql, sqlite) |
| `schema` | 스키마 파일 경로 (glob 패턴 지원) |
| `out` | 마이그레이션 출력 폴더 |
| `dbCredentials` | DB 연결 정보 |
| `driver` | 드라이버 (d1-http 등) |
| `verbose` | 상세 로그 출력 |
| `strict` | 엄격 모드 |

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

## 마이그레이션 명령어

```bash
npx drizzle-kit generate    # 마이그레이션 파일 생성
npx drizzle-kit migrate     # 마이그레이션 실행
npx drizzle-kit push        # 스키마 직접 동기화 (개발용)
npx drizzle-kit pull        # DB에서 스키마 가져오기
npx drizzle-kit studio      # GUI 실행
```
