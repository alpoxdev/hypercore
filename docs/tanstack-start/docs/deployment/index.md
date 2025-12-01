# 배포 (Deployment)

> **Framework**: TanStack Start + Nitro v3
> **Source**: [TanStack Start Hosting](https://tanstack.com/start/latest/docs/framework/react/hosting)

TanStack Start는 두 가지 배포 방식을 지원합니다:
1. **플랫폼 직접 통합**: Cloudflare Vite Plugin, Netlify Plugin 등
2. **Nitro 배포 레이어**: 다양한 플랫폼에 범용 배포

---

## 문서 구조

| 문서 | 내용 |
|------|------|
| [Nitro 설정](./nitro.md) | Nitro v3 배포 레이어 기본 설정 |
| [Vercel](./vercel.md) | Vercel 서버리스 배포 |
| [Cloudflare](./cloudflare.md) | Cloudflare Workers/Pages 배포 |
| [Railway](./railway.md) | Railway Node.js 서버 배포 |

---

## 배포 방식 비교

### 플랫폼 직접 통합 vs Nitro

| 구분 | 플랫폼 직접 통합 | Nitro 배포 레이어 |
|------|------------------|-------------------|
| 설정 | 플랫폼별 Vite 플러그인 | `nitro/vite` 플러그인 |
| 지원 | Cloudflare, Netlify | 모든 Nitro preset |
| 특징 | 플랫폼 최적화 | 범용성, 이식성 |
| 권장 | Cloudflare Workers | Vercel, Railway 등 |

### 플랫폼별 권장 방식

| 플랫폼 | 권장 방식 | Preset/Plugin |
|--------|-----------|---------------|
| **Cloudflare Workers** | 직접 통합 | `@cloudflare/vite-plugin` |
| **Cloudflare Pages** | Nitro | `cloudflare_pages` |
| **Vercel** | Nitro | `vercel` |
| **Railway** | Nitro | `node` |
| **Netlify** | 직접 통합 | `@netlify/vite-plugin-tanstack-start` |

---

## 방식 1: Cloudflare 직접 통합 (권장)

Cloudflare Workers 배포 시 공식 권장 방식입니다.

### 1. 패키지 설치

```bash
yarn add -D @cloudflare/vite-plugin wrangler
```

### 2. Vite 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { cloudflare } from '@cloudflare/vite-plugin'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    cloudflare({ viteEnvironment: { name: 'ssr' } }),
    tanstackStart(),
    viteReact(),
  ],
})
```

### 3. Wrangler 설정

```jsonc
// wrangler.jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "my-tanstack-app",
  "compatibility_date": "2024-09-19",
  "compatibility_flags": ["nodejs_compat"],
  "main": "@tanstack/react-start/server-entry"
}
```

### 4. 배포

```bash
# 빌드 및 배포
yarn build && wrangler deploy
```

---

## 방식 2: Nitro 배포 레이어

다양한 플랫폼에 범용으로 배포할 수 있습니다.

### 1. Nitro 설치

```bash
yarn add nitro@3
```

### 2. Vite 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro(),
    viteReact(),
  ],
})
```

### 3. Nitro 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // 플랫폼별 preset 선택
  preset: 'vercel', // vercel, cloudflare_pages, node 등

  // Nitro v3 필수 설정
  compatibilityDate: '2024-09-19',
})
```

### 4. 빌드 및 배포

```bash
# 빌드
yarn build

# 또는 환경변수로 preset 지정
NITRO_PRESET=vercel yarn build
```

---

## Preset 선택 가이드

### Edge 런타임이 필요한 경우

| 플랫폼 | 방식 | 설정 |
|--------|------|------|
| Cloudflare Workers | 직접 통합 | `@cloudflare/vite-plugin` |
| Cloudflare Pages | Nitro | `preset: 'cloudflare_pages'` |
| Vercel Edge | Nitro | `preset: 'vercel'` |

### Node.js 서버가 필요한 경우

| 플랫폼 | 방식 | 설정 |
|--------|------|------|
| Railway | Nitro | `preset: 'node'` |
| Docker | Nitro | `preset: 'node'` |
| 기타 VPS | Nitro | `preset: 'node'` |

### Bun 런타임

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro({ preset: 'bun' }),
    viteReact(),
  ],
})
```

---

## package.json 스크립트

```json
{
  "scripts": {
    "dev": "vite dev",
    "build": "vite build && tsc --noEmit",
    "start": "node .output/server/index.mjs",
    "preview": "vite preview",
    "deploy": "yarn build && wrangler deploy"
  }
}
```

---

## ⚠️ 유의사항

TanStack Start의 SSR 환경에서 발생할 수 있는 주요 이슈와 해결 방법입니다.

### node:async_hooks 오류

TanStack Start의 AsyncLocalStorage 관련 모듈이 클라이언트 번들에 포함되면 다음 오류가 발생합니다:

```
Module 'node:async_hooks' has been externalized for browser
```

**해결 방법**: `vite.config.ts`에 다음 설정을 추가합니다.

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart(),
    viteReact(),
  ],
  optimizeDeps: {
    exclude: ['node:async_hooks'],
  },
  ssr: {
    external: ['node:async_hooks'],
  },
})
```

---

### Prisma 사용 시 설정

TanStack Start에서 Prisma를 사용하는 경우, 브라우저 번들링 시 모듈 해석 오류가 발생할 수 있습니다.

**해결 방법**: `vite.config.ts`에 alias 설정을 추가합니다.

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart(),
    viteReact(),
  ],
  resolve: {
    alias: {
      '.prisma/client/index-browser':
        './node_modules/.prisma/client/index-browser.js',
    },
  },
})
```

---

### SSR Context Loss (Clerk, 외부 패키지)

Clerk 등 AsyncLocalStorage를 사용하는 외부 패키지에서 SSR context 손실 오류가 발생할 수 있습니다:

```
Error: No HTTPEvent found in AsyncLocalStorage
```

**해결 방법**: 해당 패키지를 `ssr.noExternal`에 추가합니다.

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [tanstackStart(), viteReact()],
  ssr: {
    noExternal: ['@clerk/tanstack-react-start'],
  },
})
```

---

### MUI (Material UI) SSR 설정

MUI 사용 시 SSR 환경에서 스타일 또는 모듈 오류가 발생할 수 있습니다.

**해결 방법**: MUI 관련 패키지를 `ssr.noExternal`에 추가합니다.

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [tanstackStart(), viteReact()],
  ssr: {
    noExternal: [
      '@mui/material',
      '@mui/utils',
      '@mui/styled-engine',
      '@mui/icons-material',
      '@mui/system',
    ],
  },
})
```

---

### 종합 설정 예시

여러 패키지를 함께 사용하는 경우의 통합 설정:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import tsConfigPaths from 'vite-tsconfig-paths'
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
  // Prisma 사용 시
  resolve: {
    alias: {
      '.prisma/client/index-browser':
        './node_modules/.prisma/client/index-browser.js',
    },
  },
  // Node.js 내장 모듈 처리
  optimizeDeps: {
    exclude: ['node:async_hooks'],
  },
  // SSR 설정
  ssr: {
    external: ['node:async_hooks'],
    noExternal: [
      // Clerk 사용 시
      '@clerk/tanstack-react-start',
      // MUI 사용 시
      '@mui/material',
      '@mui/utils',
      '@mui/styled-engine',
      '@mui/icons-material',
      '@mui/system',
    ],
  },
```

---

### 참고 자료

- [TanStack Start SSR Context Loss Issue](https://github.com/TanStack/router/issues/4409)
- [node:async_hooks AsyncLocalStorage Bug](https://github.com/TanStack/router/issues/4729)
- [TanStack Start Material UI Example](https://tanstack.com/start/latest/docs/framework/react/examples/start-material-ui)
- [TanStack Start Clerk Example](https://tanstack.com/start/latest/docs/framework/react/examples/start-clerk-basic)

---

## 환경변수

모든 플랫폼에서 공통으로 사용:

```bash
# 빌드 시 preset 지정 (Nitro 사용 시)
NITRO_PRESET=vercel

# 런타임 환경변수
DATABASE_URL=postgresql://...
API_SECRET=your-secret-key
```

---

## 참고 자료

- [TanStack Start Hosting 공식 문서](https://tanstack.com/start/latest/docs/framework/react/hosting)
- [Nitro 공식 문서](https://nitro.build)
- [Cloudflare Vite Plugin](https://developers.cloudflare.com/workers/frameworks/framework-guides/tanstack-start/)
