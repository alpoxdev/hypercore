# t3-env

> v1.x | Type-Safe Environment Variables

<context>

**Purpose:** Zod 기반 타입 안전 환경 변수 관리
**Features:** Server/Client 분리, 런타임 검증, Transform & Defaults, 프레임워크 무관

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **노출** | Server 변수를 클라이언트에 노출 |
| **접두사** | Client 변수에 `PUBLIC_` 없이 사용 |
| **직접 접근** | `process.env` 직접 사용 (env 객체 필수) |
| **타입** | any 타입으로 env 변수 접근 |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **설치** | `@t3-oss/env-core zod` |
| **구조** | `src/env.ts` 파일 생성 |
| **접두사** | Client 변수: `PUBLIC_` 시작 |
| **Import** | `import { env } from '@/env'` |
| **검증** | Zod 스키마로 서버/클라이언트 변수 검증 |

</required>

---

<installation>

## Installation

```bash
npm install @t3-oss/env-core zod
```

</installation>

---

<setup>

## Basic Setup

`src/env.ts`:

```typescript
import { createEnv } from '@t3-oss/env-core'
import { z } from 'zod'

export const env = createEnv({
  // ✅ Server-only variables
  server: {
    DATABASE_URL: z.url(),
    CLERK_SECRET_KEY: z.string().min(1),
    OPENAI_API_KEY: z.string().min(1),
  },

  // ✅ Client-exposed variables (PUBLIC_ prefix required)
  clientPrefix: 'PUBLIC_',
  client: {
    PUBLIC_API_URL: z.url().default('http://localhost:3000'),
    PUBLIC_CLERK_PUBLISHABLE_KEY: z.string().min(1),
  },

  // ✅ Runtime environment
  runtimeEnv: {
    // Server
    DATABASE_URL: process.env.DATABASE_URL,
    CLERK_SECRET_KEY: process.env.CLERK_SECRET_KEY,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
    // Client
    PUBLIC_API_URL: import.meta.env.PUBLIC_API_URL,
    PUBLIC_CLERK_PUBLISHABLE_KEY: import.meta.env.PUBLIC_CLERK_PUBLISHABLE_KEY,
  },

  emptyStringAsUndefined: true,
})
```

## Config Options

| 옵션 | 타입 | 설명 |
|------|------|------|
| `server` | `Record<string, ZodSchema>` | 서버 전용 변수 스키마 |
| `client` | `Record<string, ZodSchema>` | 클라이언트 공개 변수 스키마 |
| `clientPrefix` | `string` | 클라이언트 변수 접두사 (기본: `PUBLIC_`) |
| `runtimeEnv` | `Record<string, any>` | 실제 환경 변수 매핑 |
| `emptyStringAsUndefined` | `boolean` | 빈 문자열 → undefined 처리 |

</setup>

---

<usage>

## Server Function

```typescript
import { createServerFn } from '@tanstack/start'
import { env } from '@/env'

export const getUsers = createServerFn({ method: 'GET' }).handler(async () => {
  const db = await prisma.$connect(env.DATABASE_URL)
  //                                    ^? string (타입 안전)
  return db.user.findMany()
})
```

## Client Component

```typescript
import { env } from '@/env'

export const ApiClient = () => {
  const apiUrl = env.PUBLIC_API_URL
  //                  ^? string (타입 안전)

  // ❌ Error: server 변수는 클라이언트에서 접근 불가
  // const dbUrl = env.DATABASE_URL
}
```

</usage>

---

<validation>

## Validation Patterns

### Email

```typescript
server: {
  ADMIN_EMAIL: z.email(),
  SUPPORT_EMAIL: z.email().default('support@example.com'),
}
```

### URL

```typescript
server: {
  API_URL: z.url(),
  WEBHOOK_URL: z.url().optional(),
}
```

### Enum

```typescript
server: {
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']),
  DATABASE_PROVIDER: z.enum(['postgresql', 'mysql', 'sqlite']),
}
```

### Number

```typescript
server: {
  PORT: z.coerce.number().positive().default(3000),
  MAX_UPLOAD_SIZE: z.coerce.number().max(10485760), // 10MB
}
```

### Boolean

```typescript
server: {
  ENABLE_CACHE: z.coerce.boolean().default(true),
  DEBUG_MODE: z.coerce.boolean().default(false),
}
```

</validation>

---

<examples>

## Database + Auth

```typescript
// src/env.ts
export const env = createEnv({
  server: {
    DATABASE_URL: z.url(),
    DIRECT_URL: z.url().optional(), // Prisma connection pooling
    CLERK_SECRET_KEY: z.string().min(1),
    RESEND_API_KEY: z.string().min(1),
  },
  clientPrefix: 'PUBLIC_',
  client: {
    PUBLIC_CLERK_PUBLISHABLE_KEY: z.string().min(1),
  },
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    DIRECT_URL: process.env.DIRECT_URL,
    CLERK_SECRET_KEY: process.env.CLERK_SECRET_KEY,
    RESEND_API_KEY: process.env.RESEND_API_KEY,
    PUBLIC_CLERK_PUBLISHABLE_KEY: import.meta.env.PUBLIC_CLERK_PUBLISHABLE_KEY,
  },
  emptyStringAsUndefined: true,
})
```

## API Integration

```typescript
// src/env.ts
export const env = createEnv({
  server: {
    OPENAI_API_KEY: z.string().min(1),
    STRIPE_SECRET_KEY: z.string().min(1),
    STRIPE_WEBHOOK_SECRET: z.string().min(1),
  },
  clientPrefix: 'PUBLIC_',
  client: {
    PUBLIC_STRIPE_PUBLISHABLE_KEY: z.string().min(1),
    PUBLIC_APP_URL: z.url(),
  },
  runtimeEnv: {
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,
    STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
    STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET,
    PUBLIC_STRIPE_PUBLISHABLE_KEY: import.meta.env.PUBLIC_STRIPE_PUBLISHABLE_KEY,
    PUBLIC_APP_URL: import.meta.env.PUBLIC_APP_URL,
  },
  emptyStringAsUndefined: true,
})
```

## Multi-Environment

```typescript
// src/env.ts
export const env = createEnv({
  server: {
    NODE_ENV: z.enum(['development', 'production', 'test']),
    DATABASE_URL: z.url(),
    REDIS_URL: z.url().optional(), // Production only
  },
  clientPrefix: 'PUBLIC_',
  client: {
    PUBLIC_API_URL: z.url(),
    PUBLIC_SENTRY_DSN: z.string().optional(), // Production only
  },
  runtimeEnv: {
    NODE_ENV: process.env.NODE_ENV,
    DATABASE_URL: process.env.DATABASE_URL,
    REDIS_URL: process.env.REDIS_URL,
    PUBLIC_API_URL: import.meta.env.PUBLIC_API_URL,
    PUBLIC_SENTRY_DSN: import.meta.env.PUBLIC_SENTRY_DSN,
  },
  emptyStringAsUndefined: true,
})
```

</examples>

---

<transforms>

## Transform Values

```typescript
server: {
  // ✅ String → Number
  PORT: z.string().transform((val) => parseInt(val, 10)).pipe(z.number().positive()),

  // ✅ Coerce number
  MAX_CONNECTIONS: z.coerce.number().default(10),

  // ✅ Environment-specific defaults
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
}
```

## Optional with Fallback

```typescript
client: {
  PUBLIC_ANALYTICS_ID: z.string().optional(),
  PUBLIC_FEATURE_FLAG: z.coerce.boolean().default(false),
}
```

</transforms>

---

<tips>

| 상황 | 방법 |
|------|------|
| **Vercel** | `process.env.VERCEL_URL` → PUBLIC_APP_URL |
| **Monorepo** | 각 패키지마다 별도 `env.ts` |
| **Testing** | `.env.test` + `NODE_ENV=test` |
| **CI/CD** | GitHub Secrets → Environment Variables |
| **빌드 시점** | 빌드 시 모든 env 검증 완료 |
| **런타임 에러** | 잘못된 env 즉시 에러 발생 (앱 시작 전) |

</tips>

---

<patterns>

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|----------|
| `env.DATABASE_URL` 사용 | `process.env.DATABASE_URL` 직접 접근 |
| `PUBLIC_` 접두사 클라이언트 변수 | 접두사 없이 클라이언트 변수 |
| Zod 스키마로 타입 정의 | any 타입 사용 |
| 서버 변수는 서버에서만 | 클라이언트에 서버 변수 노출 |
| `emptyStringAsUndefined: true` | 빈 문자열 허용 |

</patterns>
