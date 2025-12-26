# Hono - 환경 변수 설정

> 타입 안전한 환경 변수 관리

---

## 파일 구조

```
프로젝트/
├── .env                    # 기본 (공통)
├── .env.development        # 개발 환경
├── .env.production         # 프로덕션
├── .env.local              # 로컬 (gitignore)
├── .env.example            # 템플릿 (커밋용)
└── src/env.ts              # 검증 및 타입
```

---

## 설치

```bash
npm install dotenv zod
npm install -D @types/node
```

---

## Zod로 환경 변수 검증

### src/env.ts

```typescript
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(16),
  JWT_EXPIRES_IN: z.string().default('7d'),
  OPENAI_API_KEY: z.string().optional(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  CORS_ORIGIN: z.string().default('*'),
})

export type Env = z.infer<typeof envSchema>

const parseEnv = (): Env => {
  const result = envSchema.safeParse(process.env)
  if (!result.success) {
    console.error('환경 변수 검증 실패:', result.error.format())
    process.exit(1)
  }
  return result.data
}

export const env = parseEnv()
```

---

## dotenv 로드

### src/index.ts

```typescript
import 'dotenv/config'  // 최상단!
import { serve } from '@hono/node-server'
import { app } from './app'
import { env } from './env'

serve({ fetch: app.fetch, port: env.PORT }, (info) => {
  console.log(`Server: http://localhost:${info.port}`)
})
```

---

## Hono Bindings

### src/types/hono.ts

```typescript
import type { Env } from '../env'

export type Bindings = Env

export type Variables = {
  requestId: string
  userId?: string
}

export type HonoEnv = {
  Bindings: Bindings
  Variables: Variables
}
```

### src/app.ts

```typescript
import { Hono } from 'hono'
import type { HonoEnv } from './types/hono'
import { env } from './env'

export const app = new Hono<HonoEnv>()

// Node.js에서 env 바인딩
app.use('*', async (c, next) => {
  Object.assign(c.env, env)
  await next()
})

app.get('/', (c) => c.json({ env: c.env.NODE_ENV }))
```

---

## Cloudflare Workers

### wrangler.toml

```toml
name = "my-hono-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
NODE_ENV = "production"
LOG_LEVEL = "info"
```

### .dev.vars (시크릿, gitignore)

```env
DATABASE_URL=postgresql://localhost:5432/myapp_dev
JWT_SECRET=dev-secret-key
```

### 시크릿 설정

```bash
wrangler secret put DATABASE_URL
wrangler secret put JWT_SECRET
```

---

## .gitignore

```gitignore
.env
.env.local
.env.*.local
.dev.vars

!.env.example
!.env.development
!.env.production
```

---

## 관련 문서

- [Hono 개요](./index.md)
- [Cloudflare 배포](../../deployment/cloudflare.md)
