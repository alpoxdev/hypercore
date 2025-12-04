# TanStack Start - 설치 및 설정

> **상위 문서**: [TanStack Start](./index.md)

## 패키지 설치

```bash
yarn add @tanstack/react-start @tanstack/react-router vinxi
yarn add -D vite @vitejs/plugin-react vite-tsconfig-paths
```

## Vite 설정

```typescript
// vite.config.ts
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
    viteReact(),
  ],
})
```

## TypeScript 설정

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "jsx": "react-jsx",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"]
}
```

## 프로젝트 구조

```
project/
├── src/
│   ├── routes/
│   │   ├── __root.tsx
│   │   ├── index.tsx
│   │   └── about.tsx
│   ├── lib/
│   │   └── server-functions.ts
│   └── start.ts
├── vite.config.ts
├── tsconfig.json
└── package.json
```

## 환경 변수 검증

```typescript
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  API_SECRET: z.string().min(32),
})

export const env = envSchema.parse(process.env)
```
