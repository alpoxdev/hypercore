# 환경 변수 설정

> Hono 환경 변수 관리 (Node.js, Cloudflare Workers)

<instructions>
@../library/t3-env/index.md
</instructions>

---

<runtime_differences>

| 런타임 | 환경 변수 접근 | 용도 |
|--------|---------------|------|
| **Node.js** | `process.env.*` | 일반 서버 |
| **Cloudflare Workers** | `c.env.*` (Bindings) | Edge Runtime |
| **Deno** | `Deno.env.get()` | Deno Runtime |
| **Bun** | `process.env.*` | Bun Runtime |

</runtime_differences>

---

<file_structure>

## 환경 파일 구조

```
├── .env                    # 기본 (커밋 O)
├── .env.development        # 개발 (커밋 O)
├── .env.production         # 프로덕션 (커밋 O)
├── .env.local              # 로컬 오버라이드 (커밋 X)
└── src/lib/env.ts          # 검증 및 타입 (t3-env)
```

| 우선순위 | 파일 | 설명 |
|----------|------|------|
| 1 | `.env.{mode}.local` | 최우선 (gitignore) |
| 2 | `.env.local` | 로컬 오버라이드 |
| 3 | `.env.{mode}` | 환경별 설정 |
| 4 | `.env` | 기본 설정 |

</file_structure>

---

<patterns>

## 환경 파일 예시

### .env.local (gitignore, 시크릿)

```env
DATABASE_URL=postgresql://user:password@localhost:5432/myapp
JWT_SECRET=your-super-secret-jwt-key-at-least-32-chars
OPENAI_API_KEY=sk-xxx
```

### .env.development

```env
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
```

### .env.production

```env
NODE_ENV=production
PORT=8080
LOG_LEVEL=info
```

## Node.js 환경 변수

### 타입 안전한 환경 변수 (t3-env)

```typescript
// src/lib/env.ts
import { createEnv } from '@t3-oss/env-core'
import { z } from 'zod'

export const env = createEnv({
  server: {
    NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
    DATABASE_URL: z.string().url(),
    JWT_SECRET: z.string().min(32),
    OPENAI_API_KEY: z.string().optional(),
    PORT: z.coerce.number().default(3000),
  },

  runtimeEnv: process.env,
})
```

### 사용 예시

```typescript
// src/index.ts
import { Hono } from 'hono'
import { env } from './lib/env'

const app = new Hono()

app.get('/', (c) => {
  return c.json({
    env: env.NODE_ENV,
    port: env.PORT,
  })
})

export default {
  port: env.PORT,
  fetch: app.fetch,
}
```

## Cloudflare Workers 환경 변수

### Bindings 타입 정의

```typescript
// src/types/index.ts
export type Bindings = {
  DATABASE_URL: string
  JWT_SECRET: string
  OPENAI_API_KEY?: string
}
```

### wrangler.toml

```toml
name = "my-hono-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
NODE_ENV = "production"

# 시크릿은 wrangler secret put 명령어로 설정
# wrangler secret put DATABASE_URL
# wrangler secret put JWT_SECRET
```

### 사용 예시

```typescript
// src/index.ts
import { Hono } from 'hono'
import type { Bindings } from './types'

const app = new Hono<{ Bindings: Bindings }>()

app.get('/', (c) => {
  // c.env를 통해 환경 변수 접근
  const dbUrl = c.env.DATABASE_URL
  const jwtSecret = c.env.JWT_SECRET

  return c.json({
    hasDb: !!dbUrl,
    hasJwt: !!jwtSecret,
  })
})

export default app
```

### 미들웨어에서 사용

```typescript
// src/middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'
import type { Bindings } from '@/types'

type Variables = {
  userId: string
}

export const authMiddleware = createMiddleware<{
  Bindings: Bindings
  Variables: Variables
}>(async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  if (!token) throw new HTTPException(401, { message: 'Unauthorized' })

  // JWT Secret 사용
  const jwtSecret = c.env.JWT_SECRET
  // JWT 검증 로직...

  c.set('userId', 'user-id')
  await next()
})
```

## Cloudflare Workers 시크릿 설정

```bash
# 시크릿 추가
wrangler secret put DATABASE_URL
wrangler secret put JWT_SECRET

# 시크릿 목록 확인
wrangler secret list

# 시크릿 삭제
wrangler secret delete DATABASE_URL
```

</patterns>

---

<gitignore>

## .gitignore

```gitignore
# 시크릿 포함 (절대 커밋 X)
.env.local
.env.*.local

# Cloudflare Workers
.dev.vars

# 공개 설정 (커밋 O)
!.env
!.env.development
!.env.production
```

</gitignore>

---

<typescript_types>

## TypeScript 타입

### Node.js

```typescript
// src/env.d.ts
declare global {
  namespace NodeJS {
    interface ProcessEnv {
      NODE_ENV: 'development' | 'production' | 'test'
      DATABASE_URL: string
      JWT_SECRET: string
      OPENAI_API_KEY?: string
      PORT?: string
    }
  }
}

export {}
```

### Cloudflare Workers

```typescript
// src/types/index.ts
export type Bindings = {
  // Database
  DATABASE_URL: string

  // Auth
  JWT_SECRET: string

  // External APIs
  OPENAI_API_KEY?: string

  // KV Namespaces (Cloudflare)
  MY_KV: KVNamespace

  // D1 Database (Cloudflare)
  DB: D1Database
}
```

</typescript_types>

---

<best_practices>

| 원칙 | 설명 |
|------|------|
| **시크릿 분리** | `.env.local`에만 시크릿 저장, 커밋 금지 |
| **타입 안전성** | t3-env 또는 Zod로 검증 |
| **기본값** | `.env`에 안전한 기본값 설정 |
| **문서화** | `.env.example` 파일로 필수 변수 목록 제공 |
| **런타임별 차이** | Node.js는 `process.env`, Cloudflare는 `c.env` |

</best_practices>

---

<cloudflare_specific>

## Cloudflare Workers 추가 기능

### KV Namespace

```typescript
// wrangler.toml
[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-id"

// 사용
app.get('/cache/:key', async (c) => {
  const key = c.req.param('key')
  const value = await c.env.MY_KV.get(key)
  return c.json({ key, value })
})
```

### D1 Database

```typescript
// wrangler.toml
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-db-id"

// 사용
app.get('/users', async (c) => {
  const { results } = await c.env.DB.prepare('SELECT * FROM users').all()
  return c.json({ users: results })
})
```

</cloudflare_specific>

---

<sources>

- [Hono Environment Variables](https://hono.dev/guides/env)
- [Cloudflare Workers Environment Variables](https://developers.cloudflare.com/workers/configuration/environment-variables/)
- [t3-env Documentation](https://env.t3.gg/docs/introduction)

</sources>
