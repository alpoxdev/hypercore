# Getting Started

> TanStack Start project quick start

<instructions>
@conventions.md
@routes.md
@services.md
</instructions>

---

<prerequisites>

| Requirement | Version |
|----------|------|
| Node.js | 18+ |
| Package Manager | Yarn / npm / pnpm |

</prerequisites>

---

<installation>

## Create Project

```bash
npx create-tsrouter-app@latest my-app --template start
cd my-app
yarn install
```

## Required Packages

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

## Project Structure

```
src/
├── routes/
│   ├── __root.tsx       # Root Layout
│   └── index.tsx        # Home Page
├── lib/
│   └── query-client.ts  # Query Client setup
└── app.config.ts        # TanStack Start config
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

## Query Client Setup

```typescript
// src/lib/query-client.ts
import { QueryClient } from '@tanstack/react-query'

export const createQueryClient = (): QueryClient => {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,  // 1 minute
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
| `yarn dev` | Start development server (http://localhost:3000) |
| `yarn build` | Production build |
| `yarn start` | Start production server |

</commands>

---

<next_steps>

| Document | Content |
|------|------|
| [conventions.md](./conventions.md) | Code conventions, naming rules |
| [env-setup.md](./env-setup.md) | Environment variable setup |
| [routes.md](./routes.md) | Route structure, file-based routing |
| [services.md](./services.md) | Server Functions, data layer |
| [hooks.md](./hooks.md) | Custom Hook patterns |

</next_steps>

---

<sources>

- [TanStack Start Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
- [TanStack Router Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
- [TanStack Start Middleware](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)

</sources>
