# 환경 변수 설정

> TanStack Start (Vite 기반) 환경 변수 관리

<instructions>
@../library/t3-env/index.md
</instructions>

---

<environment_types>

| 접근 방식 | 위치 | 용도 | 노출 |
|-----------|------|------|------|
| `process.env.*` | Server Function | DB, API 키, 시크릿 | ❌ 서버만 |
| `import.meta.env.VITE_*` | 클라이언트 + 서버 | 공개 설정 | ✅ 브라우저 노출 |

</environment_types>

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
VITE_APP_NAME=My App (Dev)
VITE_API_URL=http://localhost:3001/api
```

### .env.production

```env
NODE_ENV=production
VITE_APP_NAME=My App
VITE_API_URL=https://api.myapp.com
```

## 타입 안전한 환경 변수 (t3-env)

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
  },

  client: {
    VITE_APP_NAME: z.string(),
    VITE_API_URL: z.string().url(),
  },

  runtimeEnv: {
    // Server
    NODE_ENV: process.env.NODE_ENV,
    DATABASE_URL: process.env.DATABASE_URL,
    JWT_SECRET: process.env.JWT_SECRET,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY,

    // Client
    VITE_APP_NAME: import.meta.env.VITE_APP_NAME,
    VITE_API_URL: import.meta.env.VITE_API_URL,
  },

  clientPrefix: 'VITE_',
})
```

## 사용 예시

### Server Function

```typescript
// services/user/queries.ts
import { createServerFn } from '@tanstack/react-start'
import { env } from '@/lib/env'
import { prisma } from '@/database/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    // env.DATABASE_URL은 서버에서만 사용 가능
    console.log('DB URL:', env.DATABASE_URL)
    return prisma.user.findMany()
  })
```

### 클라이언트 컴포넌트

```tsx
// components/app-header.tsx
import { env } from '@/lib/env'

export const AppHeader = (): JSX.Element => {
  return (
    <header>
      <h1>{env.VITE_APP_NAME}</h1>
      <p>API: {env.VITE_API_URL}</p>
    </header>
  )
}
```

</patterns>

---

<gitignore>

## .gitignore

```gitignore
# 시크릿 포함 (절대 커밋 X)
.env.local
.env.*.local

# 공개 설정 (커밋 O)
!.env
!.env.development
!.env.production
```

</gitignore>

---

<typescript_types>

## TypeScript 타입 (Vite)

```typescript
// src/vite-env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_NAME: string
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

**참고:** t3-env 사용 시 자동으로 타입 추론됨

</typescript_types>

---

<best_practices>

| 원칙 | 설명 |
|------|------|
| **시크릿 분리** | `.env.local`에만 시크릿 저장, 커밋 금지 |
| **공개 변수** | `VITE_` 접두사 사용, 브라우저 노출 허용 |
| **타입 안전성** | t3-env 또는 Zod로 검증 |
| **기본값** | `.env`에 안전한 기본값 설정 |
| **문서화** | `.env.example` 파일로 필수 변수 목록 제공 |

</best_practices>

---

<sources>

- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [t3-env Documentation](https://env.t3.gg/docs/introduction)

</sources>
