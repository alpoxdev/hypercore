# TanStack Start - 설치 및 설정

> v1.159.4 기준

---

<installation>

## 패키지 설치

```bash
npm install @tanstack/react-start @tanstack/react-router react react-dom
npm install -D vite @vitejs/plugin-react vite-tsconfig-paths typescript @types/react @types/react-dom @types/node
```

**vinxi 사용 금지**: TanStack Start v1은 Vite를 직접 사용합니다.

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `@tanstack/react-start` | 최신 | Full-stack framework |
| `@tanstack/react-router` | 최신 | File-based routing |
| `react`, `react-dom` | 19+ | React 라이브러리 |
| `vite` | 7+ | Build tool |
| `@vitejs/plugin-react` | 최신 | React JSX 처리 |
| `vite-tsconfig-paths` | 최신 | Path alias 지원 |

> **참고:** `@vitejs/plugin-react` 대신 `@vitejs/plugin-react-oxc` 또는 `@vitejs/plugin-react-swc`도 사용 가능합니다.

### 프로젝트 생성 (자동)

```bash
npm create @tanstack/start@latest my-app
cd my-app
npm install
npm run dev
```

</installation>

---

<vite_config>

## vite.config.ts

```typescript
import { defineConfig } from 'vite'
import tsConfigPaths from 'vite-tsconfig-paths'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  server: {
    port: 3000,
  },
  plugins: [
    tsConfigPaths(),
    tanstackStart(),
    // react 플러그인은 반드시 start 플러그인 뒤에 위치해야 함
    viteReact(),
  ],
})
```

**플러그인 순서 (중요):**
1. `tsConfigPaths()` - Path alias
2. `tanstackStart()` - Server Functions, SSR
3. `viteReact()` - JSX 처리 (반드시 start 뒤에!)

### Server Function ID 커스터마이징 (실험적)

```typescript
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart({
      serverFns: {
        generateFunctionId: ({ filename, functionName }) => {
          return crypto
            .createHash('sha1')
            .update(`${filename}--${functionName}`)
            .digest('hex')
        },
      },
    }),
    viteReact(),
  ],
})
```

</vite_config>

---

<typescript_config>

## tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "jsx": "react-jsx",
    "strictNullChecks": true,
    "skipLibCheck": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
```

**주의사항:**
- `strictNullChecks: true` - null/undefined 체크 필수
- `jsx: "react-jsx"` - React 17+ 문법
- `moduleResolution: "Bundler"` - Vite와 호환 (대소문자 주의)
- `verbatimModuleSyntax` **사용 금지** - 서버 번들이 클라이언트 번들로 유출될 수 있음
- `skipLibCheck: true` 권장

</typescript_config>

---

<package_json>

## package.json Scripts

```json
{
  "type": "module",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "start": "node .output/server/index.mjs",
    "preview": "vite preview",
    "type-check": "tsc --noEmit"
  }
}
```

| Script | 명령 | 설명 |
|--------|------|------|
| `dev` | `vite dev` | 개발 서버 (Hot reload) |
| `build` | `vite build` | 프로덕션 빌드 (`.output/` 생성) |
| `start` | `node .output/server/index.mjs` | 프로덕션 서버 |

> **참고:** `package.json`에 `"type": "module"` 설정이 필요합니다.

</package_json>

---

<required_files>

## 필수 파일

TanStack Start 사용에 필요한 최소 파일:

### 1. Router 설정 (src/router.tsx)

```typescript
// src/router.tsx
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

// 매번 새 router 인스턴스를 반환하는 함수를 export해야 합니다
export function getRouter() {
  const router = createRouter({
    routeTree,
    scrollRestoration: true,
  })

  return router
}
```

### 2. Root Route (src/routes/__root.tsx)

```tsx
// src/routes/__root.tsx
/// <reference types="vite/client" />
import type { ReactNode } from 'react'
import {
  Outlet,
  createRootRoute,
  HeadContent,
  Scripts,
} from '@tanstack/react-router'

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { title: 'My App' },
    ],
  }),
  component: RootComponent,
})

function RootComponent() {
  return (
    <RootDocument>
      <Outlet />
    </RootDocument>
  )
}

function RootDocument({ children }: Readonly<{ children: ReactNode }>) {
  return (
    <html>
      <head>
        <HeadContent />
      </head>
      <body>
        {children}
        <Scripts />
      </body>
    </html>
  )
}
```

**핵심 컴포넌트:**
- `<HeadContent />` - `<head>` 태그 안에 배치, meta/title/link 렌더링
- `<Outlet />` - 자식 라우트 렌더링
- `<Scripts />` - `<body>` 태그 안에 배치, 클라이언트 JavaScript 로드 (필수)

### 3. Route Tree (src/routeTree.gen.ts)

이 파일은 `npm run dev` 또는 `npm run build` 실행 시 **자동 생성**됩니다. 수동으로 생성하지 마세요.

### 4. Start 설정 (src/start.ts) - 선택적

전역 미들웨어나 Start 레벨 옵션 설정 시 필요:

```typescript
// src/start.ts
import { createStart } from '@tanstack/react-start'

export const startInstance = createStart(() => ({
  // 전역 미들웨어, SSR 기본값 등 설정
}))
```

</required_files>

---

<environment_variables>

## 환경 변수 설정

### .env (프로젝트 루트)

```env
# 데이터베이스
DATABASE_URL=postgresql://user:password@localhost:5432/myapp

# 서버
API_SECRET=your-secret-key-min-32-characters-long

# 클라이언트 (VITE_ prefix)
VITE_API_BASEURL=http://localhost:3000
VITE_ENVIRONMENT=development
```

### lib/env.ts (Zod 검증)

```typescript
import { z } from 'zod'

// 서버 환경변수 (process.env)
const serverEnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  API_SECRET: z.string().min(32),
})

export const serverEnv = serverEnvSchema.parse(process.env)

// 클라이언트 환경변수 (import.meta.env)
const clientEnvSchema = z.object({
  VITE_API_BASEURL: z.string().url().default('http://localhost:3000'),
  VITE_ENVIRONMENT: z.enum(['development', 'production']).default('development'),
})

export const clientEnv = clientEnvSchema.parse(import.meta.env)
```

**보안 규칙:**
- Server Function에서만 `serverEnv` 사용
- Loader에서 `process.env` 직접 접근 금지 (클라이언트 노출)
- 클라이언트에서는 `clientEnv` 사용
- `VITE_` prefix로 시작하는 환경변수만 클라이언트 노출

```typescript
// 올바른 방식: Server Function에서 검증
export const getSecretConfig = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => {
    return { secret: serverEnv.API_SECRET }
  })

// 잘못된 방식: Loader에서 직접 사용
export const Route = createFileRoute('/config')({
  loader: () => {
    const secret = process.env.API_SECRET // 클라이언트에 노출!
    return { secret }
  },
})
```

</environment_variables>

---

<project_structure>

## 초기 프로젝트 구조

```
my-app/
├── src/
│   ├── routes/
│   │   ├── __root.tsx          # Root layout (html/body)
│   │   ├── index.tsx           # /
│   │   └── $.tsx               # Catch-all (404)
│   ├── router.tsx              # Router 설정
│   ├── routeTree.gen.ts        # 자동 생성 (수정 금지)
│   ├── functions/              # 공통 Server Functions
│   ├── middleware/             # 공통 Middleware
│   ├── components/             # UI 컴포넌트
│   ├── lib/
│   │   └── env.ts             # 환경변수 검증
│   └── database/               # Prisma
├── vite.config.ts
├── tsconfig.json
├── package.json
└── .env
```

### Server Function 파일 조직 패턴

```
src/utils/
├── users.functions.ts   # Server Function 래퍼 (createServerFn) - 어디서든 import 가능
├── users.server.ts      # 서버 전용 헬퍼 (DB 쿼리 등) - handler 안에서만 import
└── schemas.ts           # 공유 검증 스키마 (클라이언트 안전)
```

> **참고:** Server Function은 정적 import가 안전합니다. 빌드 프로세스가 클라이언트 번들에서 서버 구현을 RPC 스텁으로 교체합니다. 단, 동적 import는 피하세요.

</project_structure>

---

<verification>

## 설정 확인

```bash
# 1. 개발 서버 시작
npm run dev

# 2. http://localhost:3000 접속

# 3. 타입 체크
npm run type-check

# 4. 프로덕션 빌드
npm run build
```

성공 기준:
- 개발 서버 실행
- Hot reload 작동
- TypeScript 에러 없음
- `vite build` 성공 (`.output/` 생성)
- `routeTree.gen.ts` 자동 생성됨

</verification>

---

<version_info>

**Version:** TanStack Start/Router v1.159.4

**Key Points:**
- Vite 7+ 필수 (vinxi 사용 안함)
- `.inputValidator()` 사용 (`.validator()` deprecated)
- `verbatimModuleSyntax` 사용 금지
- TypeScript `strict: true` 필수
- `package.json`에 `"type": "module"` 필수
- React 플러그인은 반드시 Start 플러그인 뒤에 위치
- `routeTree.gen.ts`는 자동 생성 (수동 생성 금지)
- Server Function 정적 import 안전, 동적 import 금지

</version_info>
