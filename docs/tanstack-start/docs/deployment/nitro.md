# Nitro v3 배포 레이어

> **상위 문서**: [배포](./index.md)
> **Version**: Nitro 3.x

Nitro는 TanStack Start의 배포 레이어로, 다양한 플랫폼에 대한 preset을 제공합니다.

---

## 🚀 Quick Reference (복사용)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel', // 플랫폼별 preset
  compatibilityDate: '2024-09-19', // Nitro v3 필수
})
```

```bash
# 설치 및 빌드
yarn add nitro@3
yarn build
```

---

## 설치

```bash
# yarn
yarn add nitro@3

# npm
npm install nitro@3

# yarn
yarn add nitro@3
```

---

## Vite 통합

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

### Preset을 Vite에서 직접 지정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro({ preset: 'vercel' }), // preset 직접 지정
    viteReact(),
  ],
})
```

---

## Nitro 설정

### nitro.config.ts (기본)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // 배포 플랫폼 preset
  preset: 'vercel',

  // 호환성 날짜 (Nitro v3 필수)
  compatibilityDate: '2024-09-19',
})
```

### nitro.config.ts (상세)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // Nitro v3 필수 설정
  compatibilityDate: '2024-09-19',

  // 배포 플랫폼 preset
  preset: 'vercel',

  // 출력 디렉토리
  output: {
    dir: '.output',
  },

  // 번들 최적화
  minify: true,
})
```

### 환경변수로 Preset 지정

```bash
# 빌드 시 환경변수로 지정
NITRO_PRESET=cloudflare_pages yarn build

# 또는 CLI 옵션
nitro build --preset cloudflare_pages
```

---

## 주요 Preset 목록

### 서버리스/Edge

| Preset | 플랫폼 | 설명 |
|--------|--------|------|
| `vercel` | Vercel | Vercel Functions |
| `vercel-edge` | Vercel | Vercel Edge Functions |
| `cloudflare_pages` | Cloudflare | Pages Functions |
| `cloudflare_module` | Cloudflare | Workers Module |
| `netlify` | Netlify | Netlify Functions |
| `aws_lambda` | AWS | Lambda Functions |

### Node.js 서버

| Preset | 플랫폼 | 설명 |
|--------|--------|------|
| `node` | 범용 | Node.js HTTP 서버 |
| `node-cluster` | 범용 | 클러스터 모드 |
| `bun` | Bun | Bun 런타임 |
| `deno` | Deno | Deno 런타임 |
| `deno-deploy` | Deno | Deno Deploy |

### 정적/기타

| Preset | 플랫폼 | 설명 |
|--------|--------|------|
| `static` | 범용 | 정적 사이트 생성 |
| `github-pages` | GitHub | GitHub Pages |
| `render-com` | Render | Render.com |

---

## 플랫폼별 설정 예시

### Vercel

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',
})
```

### Cloudflare Pages

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'cloudflare_pages',
  compatibilityDate: '2024-09-19',
})
```

### Node.js (Railway, Docker)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'node',
  compatibilityDate: '2024-09-19',
})
```

### Bun 런타임

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'bun',
  compatibilityDate: '2024-09-19',
})
```

---

## 출력 구조

빌드 후 `.output/` 디렉토리에 생성되는 파일:

```
.output/
├── server/
│   └── index.mjs      # 서버 엔트리포인트
├── public/
│   └── ...            # 정적 파일
└── nitro.json         # Nitro 설정
```

---

## 런타임 설정

### Node.js 호환성 (Cloudflare)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'cloudflare_pages',
  compatibilityDate: '2024-09-19',
  cloudflare: {
    nodeCompat: true, // Node.js API 호환성
  },
})
```

### 외부 패키지 처리

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  // 번들에서 제외할 패키지
  externals: ['pg', 'mysql2', 'sharp'],

  // 번들에 포함할 패키지
  inlineDependencies: ['my-esm-package'],
})
```

---

## 라우트 규칙

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  routeRules: {
    // 정적 페이지 캐싱
    '/': { prerender: true },

    // ISR (Incremental Static Regeneration)
    '/products/**': {
      isr: {
        expiration: 60, // 60초
      },
    },

    // API 라우트 설정
    '/api/**': {
      cors: true,
      headers: {
        'Access-Control-Allow-Origin': '*',
      },
    },

    // Edge에서 실행
    '/api/fast/**': {
      edge: true,
    },
  },
})
```

---

## 환경변수 관리

### .env 파일

```bash
# .env.production
DATABASE_URL=postgresql://...
API_SECRET=your-secret-key
NODE_ENV=production
```

### 런타임에서 사용

```typescript
// server/api/example.ts
import { defineHandler } from 'nitro/h3'

export default defineHandler(() => {
  const dbUrl = process.env.DATABASE_URL
  // ...
})
```

---

## 빌드 및 실행

### package.json 스크립트

```json
{
  "scripts": {
    "dev": "vite dev",
    "build": "vite build && tsc --noEmit",
    "start": "node .output/server/index.mjs",
    "preview": "vite preview"
  }
}
```

### 빌드 명령어

```bash
# 개발 서버
yarn dev

# 프로덕션 빌드
yarn build

# 빌드 결과 미리보기
yarn preview

# 특정 preset으로 빌드
NITRO_PRESET=vercel yarn build
```

---

## 디버깅

### 빌드 로그 확인

```bash
# 상세 로그 출력
DEBUG=nitro:* yarn build
```

### 출력 검사

```bash
# 빌드 후 출력 확인
ls -la .output/server/
cat .output/nitro.json
```

---

## 참고 자료

- [Nitro 공식 문서](https://nitro.build)
- [Nitro Preset 목록](https://nitro.build/deploy)
- [TanStack Start Hosting](https://tanstack.com/start/latest/docs/framework/react/hosting)
