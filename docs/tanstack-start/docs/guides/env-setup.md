# TanStack Start - 환경 변수 설정

> **상위 문서**: [Best Practices](./best-practices.md)

TanStack Start는 Vite 기반으로 동작하며, 환경별 `.env` 파일을 통해 환경 변수를 관리합니다.

---

## 핵심 개념

### 서버 vs 클라이언트 환경 변수

```
서버 전용     → process.env.DATABASE_URL     (노출 X)
클라이언트용  → import.meta.env.VITE_*       (노출 O)
```

| 접근 방식 | 접근 가능 위치 | 용도 |
|-----------|---------------|------|
| `process.env.*` | Server Function, 서버 코드 | DB 연결, API 키, 시크릿 |
| `import.meta.env.VITE_*` | 클라이언트 + 서버 | 공개 설정, API URL |

⚠️ **중요**: `VITE_` 접두사가 없는 변수는 클라이언트에 노출되지 않습니다.

---

## 환경 파일 구조

```
프로젝트/
├── .env                    # 기본 환경 변수 (공통, 커밋 O)
├── .env.development        # 개발 환경 (커밋 O)
├── .env.production         # 프로덕션 환경 (커밋 O)
├── .env.local              # 로컬 오버라이드 (커밋 X, gitignore)
├── .env.development.local  # 개발 로컬 오버라이드 (커밋 X)
├── .env.production.local   # 프로덕션 로컬 오버라이드 (커밋 X)
└── app/
    └── config/
        └── env.ts          # 환경 변수 검증 및 타입
```

### 로드 우선순위 (높은 순)

```
1. .env.{mode}.local    # 최우선 (gitignore)
2. .env.local           # 로컬 오버라이드 (gitignore)
3. .env.{mode}          # 환경별 설정
4. .env                 # 기본 설정
```

---

## 환경 변수 파일 예시

### .env (기본 설정, 커밋용)

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 기본 환경 변수 (모든 환경에서 공통)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 클라이언트 공개 설정 (VITE_ 접두사 필수)
VITE_APP_NAME=My TanStack App
VITE_API_URL=https://api.example.com

# 서버 설정 템플릿 (실제 값은 .env.local에서 오버라이드)
DATABASE_URL=postgresql://localhost:5432/myapp_dev
REDIS_URL=redis://localhost:6379
```

### .env.development

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 개발 환경 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NODE_ENV=development

# 클라이언트 공개 설정
VITE_APP_NAME=My App (Dev)
VITE_API_URL=http://localhost:3001/api
VITE_DEBUG=true

# 서버 설정
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp_dev
DATABASE_POOL_SIZE=5

# 개발용 설정
LOG_LEVEL=debug
CORS_ORIGIN=http://localhost:3000
```

### .env.production

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 프로덕션 환경 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NODE_ENV=production

# 클라이언트 공개 설정
VITE_APP_NAME=My App
VITE_API_URL=https://api.myapp.com
VITE_DEBUG=false

# 서버 설정 (실제 값은 CI/CD 또는 호스팅 환경에서 주입)
DATABASE_POOL_SIZE=20

# 프로덕션 설정
LOG_LEVEL=info
CORS_ORIGIN=https://myapp.com
```

### .env.local (gitignore, 실제 시크릿)

```env
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 로컬 개발용 시크릿 (절대 커밋 금지!)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 데이터베이스
DATABASE_URL=postgresql://user:realpassword@localhost:5432/myapp_local

# 인증
JWT_SECRET=your-super-secret-jwt-key-at-least-32-chars
AUTH_SECRET=your-auth-secret-key

# 외부 서비스 API 키
OPENAI_API_KEY=sk-xxx
STRIPE_SECRET_KEY=sk_test_xxx
```

---

## 타입 안전한 환경 변수 (Zod)

### app/config/env.ts

```typescript
// app/config/env.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 환경 변수 검증 및 타입 정의
// 서버/클라이언트 환경 변수를 분리하여 관리합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { z } from 'zod'

// 서버 환경 변수 스키마
const serverEnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),

  // 데이터베이스
  DATABASE_URL: z.string().url(),
  DATABASE_POOL_SIZE: z.coerce.number().default(10),

  // 인증
  JWT_SECRET: z.string().min(32),
  AUTH_SECRET: z.string().min(16).optional(),

  // 외부 서비스 (선택적)
  OPENAI_API_KEY: z.string().optional(),
  STRIPE_SECRET_KEY: z.string().optional(),

  // 설정
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  CORS_ORIGIN: z.string().default('*'),
})

// 클라이언트 환경 변수 스키마 (VITE_ 접두사)
const clientEnvSchema = z.object({
  VITE_APP_NAME: z.string(),
  VITE_API_URL: z.string().url(),
  VITE_DEBUG: z.coerce.boolean().default(false),
})

// 타입 추출
export type ServerEnv = z.infer<typeof serverEnvSchema>
export type ClientEnv = z.infer<typeof clientEnvSchema>

// 서버 환경 변수 파싱 (Server Function에서만 호출)
const parseServerEnv = (): ServerEnv => {
  const result = serverEnvSchema.safeParse(process.env)

  if (!result.success) {
    console.error('❌ 서버 환경 변수 검증 실패:')
    console.error(result.error.format())
    throw new Error('Server environment validation failed')
  }

  return result.data
}

// 클라이언트 환경 변수 파싱
const parseClientEnv = (): ClientEnv => {
  const result = clientEnvSchema.safeParse(import.meta.env)

  if (!result.success) {
    console.error('❌ 클라이언트 환경 변수 검증 실패:')
    console.error(result.error.format())
    throw new Error('Client environment validation failed')
  }

  return result.data
}

// Export (서버 환경 변수는 lazy evaluation)
let _serverEnv: ServerEnv | null = null

export const getServerEnv = (): ServerEnv => {
  if (!_serverEnv) {
    _serverEnv = parseServerEnv()
  }
  return _serverEnv
}

export const clientEnv = parseClientEnv()
```

---

## 사용 예시

### Server Function에서 사용

```typescript
// app/server-functions/users.ts
import { createServerFn } from '@tanstack/react-start'
import { getServerEnv } from '@/config/env'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    const env = getServerEnv()

    // ✅ 서버 전용 환경 변수 사용
    const config = {
      url: env.DATABASE_URL,
      maxConnections: env.DATABASE_POOL_SIZE,
      ssl: env.NODE_ENV === 'production',
    }

    const db = await createConnection(config)
    return db.user.findMany()
  })
```

### 클라이언트 컴포넌트에서 사용

```tsx
// app/components/AppHeader.tsx
import { clientEnv } from '@/config/env'

export const AppHeader = () => {
  return (
    <header>
      {/* ✅ VITE_ 접두사 변수만 접근 가능 */}
      <h1>{clientEnv.VITE_APP_NAME}</h1>

      {clientEnv.VITE_DEBUG && (
        <span className="text-red-500">Debug Mode</span>
      )}
    </header>
  )
}
```

### 직접 접근 (검증 없이)

```tsx
// Server Function 내부
const dbUrl = process.env.DATABASE_URL  // ✅ 서버에서만

// 클라이언트 컴포넌트
const appName = import.meta.env.VITE_APP_NAME  // ✅ VITE_ 접두사만
```

---

## 인증 설정 예시

### 서버 측 인증 설정

```typescript
// app/lib/auth.ts
import { getServerEnv } from '@/config/env'

export const getAuthConfig = () => {
  const env = getServerEnv()

  return {
    secret: env.AUTH_SECRET,
    providers: {
      auth0: {
        domain: process.env.AUTH0_DOMAIN,
        clientId: process.env.AUTH0_CLIENT_ID,
        clientSecret: process.env.AUTH0_CLIENT_SECRET,  // ✅ 서버 전용
      },
    },
  }
}
```

### 클라이언트 측 인증 Provider

```tsx
// app/components/AuthProvider.tsx
export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  return (
    <Auth0Provider
      domain={import.meta.env.VITE_AUTH0_DOMAIN}
      clientId={import.meta.env.VITE_AUTH0_CLIENT_ID}
      // ❌ clientSecret은 여기에 없음 - 서버에만 존재
    >
      {children}
    </Auth0Provider>
  )
}
```

---

## 필수 환경 변수 검증

### 앱 시작 시 검증

```typescript
// app/config/validation.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 필수 환경 변수 검증
// 앱 시작 시 누락된 환경 변수를 조기에 발견합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const requiredServerEnv = [
  'DATABASE_URL',
  'JWT_SECRET',
] as const

const requiredClientEnv = [
  'VITE_APP_NAME',
  'VITE_API_URL',
] as const

export const validateEnv = () => {
  // 서버 환경 변수 검증
  for (const key of requiredServerEnv) {
    if (!process.env[key]) {
      throw new Error(`❌ Missing required server env: ${key}`)
    }
  }

  // 클라이언트 환경 변수 검증
  for (const key of requiredClientEnv) {
    if (!import.meta.env[key]) {
      throw new Error(`❌ Missing required client env: ${key}`)
    }
  }

  console.log('✅ Environment variables validated')
}
```

---

## .gitignore 설정

```gitignore
# 환경 변수 파일
.env.local
.env.*.local
.env.development.local
.env.production.local

# 커밋해도 되는 파일 (시크릿 없음)
!.env
!.env.development
!.env.production
```

⚠️ **중요**: `.env.development`와 `.env.production`에는 **실제 시크릿을 절대 넣지 마세요!**
- 실제 시크릿은 `.env.local` 또는 CI/CD 환경 변수로 관리
- `.env.*` 파일에는 플레이스홀더나 기본값만 포함

---

## 빌드 모드

### 개발 서버

```bash
# 기본 development 모드
npm run dev

# .env.development + .env 로드
```

### 프로덕션 빌드

```bash
# 기본 production 모드
npm run build

# .env.production + .env 로드
```

### 커스텀 모드

```bash
# staging 모드로 빌드
npm run build -- --mode staging

# .env.staging + .env 로드
```

```env
# .env.staging
NODE_ENV=production
VITE_APP_NAME=My App (Staging)
VITE_API_URL=https://staging-api.myapp.com
```

---

## TypeScript 타입 정의

### vite-env.d.ts

```typescript
// app/vite-env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_NAME: string
  readonly VITE_API_URL: string
  readonly VITE_DEBUG: string
  readonly VITE_AUTH0_DOMAIN?: string
  readonly VITE_AUTH0_CLIENT_ID?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

---

## 관련 문서

- [Best Practices](./best-practices.md)
- [Server Functions](../library/tanstack-start/server-functions.md)
- [Vite 환경 변수 공식 문서](https://vitejs.dev/guide/env-and-mode.html)
