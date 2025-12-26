# 환경 변수 설정

TanStack Start (Vite 기반) 환경 변수 관리.

## 핵심 개념

```
서버 전용     → process.env.DATABASE_URL     (노출 X)
클라이언트용  → import.meta.env.VITE_*       (노출 O)
```

| 접근 방식 | 위치 | 용도 |
|-----------|------|------|
| `process.env.*` | Server Function | DB, API 키, 시크릿 |
| `import.meta.env.VITE_*` | 클라이언트 + 서버 | 공개 설정 |

## 환경 파일 구조

```
├── .env                    # 기본 (커밋 O)
├── .env.development        # 개발 (커밋 O)
├── .env.production         # 프로덕션 (커밋 O)
├── .env.local              # 로컬 오버라이드 (커밋 X)
└── app/config/env.ts       # 검증 및 타입
```

### 로드 우선순위

```
1. .env.{mode}.local    # 최우선 (gitignore)
2. .env.local           # 로컬 오버라이드
3. .env.{mode}          # 환경별 설정
4. .env                 # 기본 설정
```

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
VITE_APP_NAME=My App (Dev)
VITE_API_URL=http://localhost:3001/api
DATABASE_URL=postgresql://localhost:5432/myapp_dev
```

## 타입 안전한 환경 변수 (Zod)

```typescript
// app/config/env.ts
import { z } from 'zod'

const serverEnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  OPENAI_API_KEY: z.string().optional(),
})

const clientEnvSchema = z.object({
  VITE_APP_NAME: z.string(),
  VITE_API_URL: z.string().url(),
})

export type ServerEnv = z.infer<typeof serverEnvSchema>
export type ClientEnv = z.infer<typeof clientEnvSchema>

let _serverEnv: ServerEnv | null = null

export const getServerEnv = (): ServerEnv => {
  if (!_serverEnv) {
    const result = serverEnvSchema.safeParse(process.env)
    if (!result.success) {
      console.error('❌ 서버 환경 변수 검증 실패:', result.error.format())
      throw new Error('Server environment validation failed')
    }
    _serverEnv = result.data
  }
  return _serverEnv
}

export const clientEnv = clientEnvSchema.parse(import.meta.env)
```

## 사용 예시

### Server Function

```typescript
import { createServerFn } from '@tanstack/react-start'
import { getServerEnv } from '@/config/env'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    const env = getServerEnv()
    // env.DATABASE_URL 사용
  })
```

### 클라이언트

```tsx
import { clientEnv } from '@/config/env'

export const AppHeader = () => (
  <h1>{clientEnv.VITE_APP_NAME}</h1>
)
```

## .gitignore

```gitignore
.env.local
.env.*.local

# 커밋해도 되는 파일 (시크릿 없음)
!.env
!.env.development
!.env.production
```

## TypeScript 타입

```typescript
// app/vite-env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_NAME: string
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```
