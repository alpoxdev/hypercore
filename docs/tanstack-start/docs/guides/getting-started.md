# Getting Started

> TanStack Start 프로젝트 빠른 시작

<instructions>
@conventions.md
@routes.md
@services.md
</instructions>

---

<prerequisites>

| 요구사항 | 버전 |
|----------|------|
| Node.js | 18+ |
| 패키지 관리자 | Yarn / npm / pnpm |

</prerequisites>

---

<installation>

## 프로젝트 생성

```bash
npx create-tsrouter-app@latest my-app --template start
cd my-app
yarn install
```

## 필수 패키지

```bash
# Database (Prisma 7.x)
yarn add @prisma/client@7
yarn add -D prisma@7

# Validation (Zod 4.x)
yarn add zod

# TanStack Query
yarn add @tanstack/react-query
```

</installation>

---

<project_setup>

## 프로젝트 구조

```
src/
├── routes/
│   ├── __root.tsx       # Root Layout
│   └── index.tsx        # Home Page
├── lib/
│   └── query-client.ts  # Query Client 설정
└── app.config.ts        # TanStack Start 설정
```

## app.config.ts

```typescript
import { defineConfig } from '@tanstack/react-start/config'

export default defineConfig({
  server: {
    preset: 'node-server',
  },
})
```

## Root Route

```tsx
// src/routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: RootComponent,
})

const RootComponent = (): JSX.Element => {
  return (
    <div className="min-h-screen">
      <nav className="border-b p-4">
        <a href="/" className="font-bold">My App</a>
      </nav>
      <main className="container mx-auto p-4">
        <Outlet />
      </main>
    </div>
  )
}
```

## Home Route

```tsx
// src/routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: HomePage,
})

const HomePage = (): JSX.Element => {
  return (
    <div>
      <h1 className="text-2xl font-bold">Welcome to TanStack Start</h1>
      <p className="mt-4 text-gray-600">
        Full-stack React framework powered by TanStack Router
      </p>
    </div>
  )
}
```

## Query Client 설정

```typescript
// src/lib/query-client.ts
import { QueryClient } from '@tanstack/react-query'

export const createQueryClient = (): QueryClient => {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,  // 1분
        retry: 1,
      },
    },
  })
}
```

</project_setup>

---

<commands>

| Command | Description |
|---------|-------------|
| `yarn dev` | 개발 서버 시작 (http://localhost:3000) |
| `yarn build` | 프로덕션 빌드 |
| `yarn start` | 프로덕션 서버 실행 |

</commands>

---

<next_steps>

| 문서 | 내용 |
|------|------|
| [conventions.md](./conventions.md) | 코드 컨벤션, 파일명 규칙 |
| [env-setup.md](./env-setup.md) | 환경 변수 설정 |
| [routes.md](./routes.md) | 라우트 구조, 파일 기반 라우팅 |
| [services.md](./services.md) | Server Functions, 데이터 레이어 |
| [hooks.md](./hooks.md) | Custom Hook 패턴 |

</next_steps>

---

<sources>

- [TanStack Start Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
- [TanStack Router Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
- [TanStack Start Middleware](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)

</sources>
