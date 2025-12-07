# Nitro v3 배포 레이어

> Nitro 3.x

## Quick Reference

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',  // v3 필수
})
```

```bash
yarn add nitro@3
yarn build
```

---

## Vite 통합

```typescript
// vite.config.ts
import { nitro } from 'nitro/vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro({ preset: 'vercel' }),  // preset 직접 지정 가능
    viteReact(),
  ],
})
```

---

## Preset 목록

### 서버리스/Edge

| Preset | 플랫폼 |
|--------|--------|
| `vercel` | Vercel Functions |
| `vercel-edge` | Vercel Edge Functions |
| `cloudflare_pages` | Cloudflare Pages |
| `cloudflare_module` | Cloudflare Workers |
| `netlify` | Netlify Functions |
| `aws_lambda` | AWS Lambda |

### Node.js 서버

| Preset | 플랫폼 |
|--------|--------|
| `node` | 범용 (Railway, Docker) |
| `node-cluster` | 클러스터 모드 |
| `bun` | Bun 런타임 |
| `deno` | Deno 런타임 |

---

## 설정 예시

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',
  output: { dir: '.output' },
  minify: true,

  // 외부 패키지 처리
  externals: ['pg', 'mysql2', 'sharp'],

  // Cloudflare Node.js 호환성
  cloudflare: { nodeCompat: true },

  // 라우트 규칙
  routeRules: {
    '/': { prerender: true },
    '/products/**': { isr: { expiration: 60 } },
    '/api/**': { cors: true },
  },
})
```

---

## 빌드

```bash
yarn build
NITRO_PRESET=vercel yarn build
DEBUG=nitro:* yarn build  # 상세 로그
```

## 출력 구조

```
.output/
├── server/index.mjs   # 서버 엔트리
├── public/            # 정적 파일
└── nitro.json
```
