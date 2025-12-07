# 배포 (Deployment)

> TanStack Start + Nitro v3

@nitro.md
@vercel.md
@cloudflare.md
@railway.md

---

## 배포 방식

| 방식 | 설정 | 지원 |
|------|------|------|
| 플랫폼 직접 통합 | Vite 플러그인 | Cloudflare, Netlify |
| Nitro 배포 레이어 | nitro/vite | 모든 Nitro preset |

### 플랫폼별 권장

| 플랫폼 | 방식 | 설정 |
|--------|------|------|
| Cloudflare Workers | 직접 통합 | `@cloudflare/vite-plugin` |
| Cloudflare Pages | Nitro | `cloudflare_pages` |
| Vercel | Nitro | `vercel` |
| Railway | Nitro | `node` |
| Netlify | 직접 통합 | `@netlify/vite-plugin-tanstack-start` |

---

## Cloudflare Workers (직접 통합)

```bash
yarn add -D @cloudflare/vite-plugin wrangler
```

```typescript
// vite.config.ts
import { cloudflare } from '@cloudflare/vite-plugin'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    cloudflare({ viteEnvironment: { name: 'ssr' } }),
    tanstackStart(),
    viteReact(),
  ],
})
```

```jsonc
// wrangler.jsonc
{
  "name": "my-app",
  "compatibility_date": "2024-09-19",
  "compatibility_flags": ["nodejs_compat"],
  "main": "@tanstack/react-start/server-entry"
}
```

```bash
yarn build && wrangler deploy
```

---

## Nitro 배포 레이어

```bash
yarn add nitro@3
```

```typescript
// vite.config.ts
import { nitro } from 'nitro/vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [tanstackStart(), nitro(), viteReact()],
})
```

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',  // vercel, cloudflare_pages, node
  compatibilityDate: '2024-09-19',
})
```

```bash
yarn build
# 또는
NITRO_PRESET=vercel yarn build
```

---

## ⚠️ SSR 이슈 해결

### node:async_hooks 오류

```typescript
// vite.config.ts
export default defineConfig({
  optimizeDeps: { exclude: ['node:async_hooks'] },
  ssr: { external: ['node:async_hooks'] },
})
```

### Prisma 브라우저 번들링

```typescript
resolve: {
  alias: {
    '.prisma/client/index-browser': './node_modules/.prisma/client/index-browser.js',
  },
},
```

### SSR Context Loss (Clerk, MUI)

```typescript
ssr: {
  noExternal: [
    '@clerk/tanstack-react-start',
    '@mui/material', '@mui/utils', '@mui/styled-engine',
  ],
},
```

### 종합 설정

```typescript
export default defineConfig({
  plugins: [tsConfigPaths(), tanstackStart(), viteReact()],
  resolve: {
    alias: { '.prisma/client/index-browser': './node_modules/.prisma/client/index-browser.js' },
  },
  optimizeDeps: { exclude: ['node:async_hooks'] },
  ssr: {
    external: ['node:async_hooks'],
    noExternal: ['@clerk/tanstack-react-start', '@mui/material'],
  },
})
```

---

## 스크립트

```json
{
  "scripts": {
    "dev": "vite dev",
    "build": "vite build && tsc --noEmit",
    "start": "node .output/server/index.mjs",
    "deploy": "yarn build && wrangler deploy"
  }
}
```
