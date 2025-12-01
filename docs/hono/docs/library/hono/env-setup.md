# Hono - 환경 변수 설정

> **상위 문서**: [Hono](./index.md)

환경별 `.env` 파일 설정 및 타입 안전한 환경 변수 관리 방법입니다.

---

## 환경별 .env 파일 구조

```
프로젝트/
├── .env                    # 기본 환경 변수 (공통)
├── .env.development        # 개발 환경
├── .env.production         # 프로덕션 환경
├── .env.local              # 로컬 개발 (gitignore)
├── .env.example            # 예시 파일 (커밋용)
└── src/
    └── env.ts              # 환경 변수 검증 및 타입
```

---

## 설치

```bash
npm install dotenv
npm install -D @types/node
```

---

## 환경 변수 파일 예시

### .env.example (커밋용 템플릿)

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 환경 변수 템플릿
# 복사 후 .env.local 로 저장하여 사용
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 앱 설정
NODE_ENV=development
PORT=3000

# 데이터베이스
DATABASE_URL=postgresql://user:password@localhost:5432/mydb

# 인증
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=7d

# 외부 서비스
OPENAI_API_KEY=sk-xxx
REDIS_URL=redis://localhost:6379
```

### .env.development

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 개발 환경 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NODE_ENV=development
PORT=3000

# 개발용 데이터베이스
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp_dev

# 개발용 시크릿 (짧은 값 OK)
JWT_SECRET=dev-secret-key
JWT_EXPIRES_IN=1d

# 개발용 외부 서비스
OPENAI_API_KEY=sk-dev-xxx
REDIS_URL=redis://localhost:6379

# 개발용 옵션
LOG_LEVEL=debug
CORS_ORIGIN=http://localhost:5173
```

### .env.production

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 프로덕션 환경 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NODE_ENV=production
PORT=8080

# 프로덕션 데이터베이스
DATABASE_URL=postgresql://user:strongpassword@prod-db.example.com:5432/myapp

# 프로덕션 시크릿 (강력한 값 필수)
JWT_SECRET=super-secure-production-secret-key-at-least-32-chars
JWT_EXPIRES_IN=7d

# 프로덕션 외부 서비스
OPENAI_API_KEY=sk-prod-xxx
REDIS_URL=redis://prod-redis.example.com:6379

# 프로덕션 옵션
LOG_LEVEL=info
CORS_ORIGIN=https://myapp.com
```

---

## 타입 안전한 환경 변수 (Zod)

### src/env.ts

```typescript
// src/env.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 환경 변수 검증 및 타입 정의
// 앱 시작 시 자동으로 환경 변수를 검증합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { z } from 'zod'

// 환경 변수 스키마
const envSchema = z.object({
  // 앱 설정
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),

  // 데이터베이스
  DATABASE_URL: z.string().url(),

  // 인증
  JWT_SECRET: z.string().min(16),
  JWT_EXPIRES_IN: z.string().default('7d'),

  // 외부 서비스 (선택적)
  OPENAI_API_KEY: z.string().optional(),
  REDIS_URL: z.string().url().optional(),

  // 옵션
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  CORS_ORIGIN: z.string().default('*'),
})

// 환경 변수 타입 추출
export type Env = z.infer<typeof envSchema>

// 환경 변수 파싱 및 검증
const parseEnv = (): Env => {
  const result = envSchema.safeParse(process.env)

  if (!result.success) {
    console.error('❌ 환경 변수 검증 실패:')
    console.error(result.error.format())
    process.exit(1)
  }

  return result.data
}

// 검증된 환경 변수 export
export const env = parseEnv()
```

---

## dotenv 설정

### src/index.ts (진입점)

```typescript
// src/index.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hono 앱 진입점
// dotenv는 가장 먼저 import해야 합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import 'dotenv/config'  // ⚠️ 반드시 최상단!
import { serve } from '@hono/node-server'
import { app } from './app'
import { env } from './env'

serve({
  fetch: app.fetch,
  port: env.PORT,
}, (info) => {
  console.log(`🚀 Server running on http://localhost:${info.port}`)
  console.log(`📍 Environment: ${env.NODE_ENV}`)
})
```

### 환경별 dotenv 로드

```typescript
// src/load-env.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 환경별 .env 파일 로드
// NODE_ENV에 따라 적절한 파일을 로드합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { config } from 'dotenv'
import path from 'node:path'

const loadEnv = () => {
  const nodeEnv = process.env.NODE_ENV || 'development'

  // 로드 순서: .env.local → .env.{환경} → .env
  const envFiles = [
    `.env.local`,           // 로컬 오버라이드 (gitignore)
    `.env.${nodeEnv}`,      // 환경별 설정
    `.env`,                 // 기본 설정
  ]

  envFiles.forEach((file) => {
    config({ path: path.resolve(process.cwd(), file) })
  })
}

loadEnv()

export {}
```

```typescript
// src/index.ts
import './load-env'  // ⚠️ 반드시 최상단!
import { serve } from '@hono/node-server'
import { app } from './app'
import { env } from './env'

// ... 나머지 코드
```

---

## Hono Bindings 타입 정의

### src/types/hono.ts

```typescript
// src/types/hono.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hono 앱 타입 정의
// Bindings, Variables 등 전역 타입을 정의합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import type { Env } from '../env'

// 환경 변수 Bindings
export type Bindings = Env

// 요청 간 공유 변수
export type Variables = {
  requestId: string
  userId?: string
  user?: {
    id: string
    email: string
    role: string
  }
}

// Hono 앱 타입
export type HonoEnv = {
  Bindings: Bindings
  Variables: Variables
}
```

### src/app.ts

```typescript
// src/app.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hono 앱 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import type { HonoEnv } from './types/hono'
import { env } from './env'

export const app = new Hono<HonoEnv>()

// 미들웨어 설정
app.use('*', logger())
app.use('*', cors({ origin: env.CORS_ORIGIN }))

// 환경 변수 바인딩 미들웨어 (Node.js용)
app.use('*', async (c, next) => {
  // Node.js에서는 process.env를 c.env로 바인딩
  Object.assign(c.env, env)
  await next()
})

// 라우트
app.get('/', (c) => {
  return c.json({
    message: 'Hello Hono!',
    environment: c.env.NODE_ENV,
  })
})

app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  })
})
```

---

## Cloudflare Workers 환경

Cloudflare Workers에서는 `wrangler.toml`과 `.dev.vars`를 사용합니다.

### wrangler.toml

```toml
name = "my-hono-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
NODE_ENV = "production"
LOG_LEVEL = "info"

# 개발 환경 오버라이드
[env.development.vars]
NODE_ENV = "development"
LOG_LEVEL = "debug"
```

### .dev.vars (개발용 시크릿)

```env
# ⚠️ 이 파일은 gitignore에 추가해야 합니다
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp_dev
JWT_SECRET=dev-secret-key
OPENAI_API_KEY=sk-dev-xxx
```

### wrangler 시크릿 설정 (프로덕션)

```bash
# 시크릿 추가
wrangler secret put DATABASE_URL
wrangler secret put JWT_SECRET
wrangler secret put OPENAI_API_KEY

# 시크릿 목록 확인
wrangler secret list
```

---

## .gitignore 설정

```gitignore
# 환경 변수 파일
.env
.env.local
.env.*.local
.dev.vars

# 커밋해도 되는 파일
!.env.example
!.env.development
!.env.production
```

⚠️ **주의**: `.env.development`와 `.env.production`에는 **실제 시크릿을 절대 넣지 마세요!**
- 실제 시크릿은 `.env.local` 또는 CI/CD 환경 변수로 관리
- `.env.development`, `.env.production`은 기본값과 플레이스홀더만 포함

---

## package.json 스크립트

```json
{
  "scripts": {
    "dev": "NODE_ENV=development tsx watch src/index.ts",
    "build": "tsc",
    "start": "NODE_ENV=production node dist/index.js",
    "start:dev": "NODE_ENV=development node dist/index.js",
    "typecheck": "tsc --noEmit"
  }
}
```

### cross-env 사용 (Windows 호환)

```bash
npm install -D cross-env
```

```json
{
  "scripts": {
    "dev": "cross-env NODE_ENV=development tsx watch src/index.ts",
    "start": "cross-env NODE_ENV=production node dist/index.js"
  }
}
```

---

## 환경 변수 사용 예시

### 라우트에서 사용

```typescript
// src/routes/users.ts
import { Hono } from 'hono'
import type { HonoEnv } from '../types/hono'
import { env } from '../env'

const users = new Hono<HonoEnv>()

users.get('/', (c) => {
  // 방법 1: env 모듈에서 직접 가져오기 (권장)
  const dbUrl = env.DATABASE_URL

  // 방법 2: context에서 가져오기
  const nodeEnv = c.env.NODE_ENV

  return c.json({ environment: nodeEnv })
})

export { users }
```

### 조건부 로직

```typescript
import { env } from '../env'

// 개발 환경에서만 실행
if (env.NODE_ENV === 'development') {
  console.log('🔧 Development mode')
  // 개발용 설정...
}

// 프로덕션에서만 실행
if (env.NODE_ENV === 'production') {
  // 프로덕션 최적화...
}
```

---

## 관련 문서

- [Hono 개요](./index.md)
- [미들웨어](./middleware.md)
- [Zod 검증](./validation.md)
- [Cloudflare 배포](../deployment/cloudflare.md)
