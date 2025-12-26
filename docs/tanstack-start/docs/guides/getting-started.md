# Getting Started

TanStack Start 프로젝트 시작 가이드.

## Prerequisites

- Node.js 18+
- Yarn

## 프로젝트 생성

```bash
npx create-tsrouter-app@latest my-app --template start
cd my-app
yarn install
```

## 필수 패키지 설치

```bash
# Database (Prisma 7.x)
yarn add @prisma/client@7
yarn add -D prisma@7

# Validation (Zod 4.x)
yarn add zod

# TanStack Query
yarn add @tanstack/react-query
```

## 초기 설정

### app.config.ts

```typescript
import { defineConfig } from '@tanstack/react-start/config'

export default defineConfig({
  server: {
    preset: 'node-server',
  },
})
```

### Root Route

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

### Home Route

```tsx
// src/routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: HomePage,
})

const HomePage = (): JSX.Element => {
  return (
    <div>
      <h1 className="text-2xl font-bold">Welcome</h1>
    </div>
  )
}
```

### Query Client

```typescript
// src/lib/query-client.ts
import { QueryClient } from '@tanstack/react-query'

export const createQueryClient = (): QueryClient => {
  return new QueryClient({
    defaultOptions: {
      queries: { staleTime: 60 * 1000, retry: 1 },
    },
  })
}
```

## 개발 명령어

| Command | Description |
|---------|-------------|
| `yarn dev` | 개발 서버 시작 |
| `yarn build` | 프로덕션 빌드 |
| `yarn start` | 프로덕션 서버 |

## 다음 단계

- [conventions.md](./conventions.md) - 코드 컨벤션
- [routes.md](./routes.md) - 라우트 구조
- [hooks.md](./hooks.md) - Custom Hook 패턴
- [services.md](./services.md) - Service Layer
