# Nitro 배포 레이어

> **상위 문서**: [배포](./index.md)

Nitro는 TanStack Start의 배포 레이어로, 다양한 플랫폼에 대한 preset을 제공합니다.

## 설치

```bash
yarn add nitro
```

## Vite 통합

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro(),
    react(),
  ],
})
```

## Nitro 설정

### nitro.config.ts

```typescript
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // 배포 플랫폼 preset
  preset: 'vercel',

  // 호환성 설정 (Nitro v3 필수)
  compatibilityDate: '2024-09-19',
})
```

### 환경변수로 Preset 지정

```bash
# 빌드 시 환경변수로 지정
NITRO_PRESET=cloudflare_pages yarn build

# 또는 CLI 옵션
nitro build --preset cloudflare_pages
```

## 주요 Preset 목록

### 서버리스/Edge

| Preset | 플랫폼 | 설명 |
|--------|--------|------|
| `vercel` | Vercel | Vercel Functions |
| `cloudflare_pages` | Cloudflare | Pages Functions |
| `cloudflare_module` | Cloudflare | Workers Module |
| `netlify` | Netlify | Netlify Functions |
| `aws_lambda` | AWS | Lambda Functions |

### Node.js 서버

| Preset | 플랫폼 | 설명 |
|--------|--------|------|
| `node-server` | 범용 | Node.js HTTP 서버 |
| `node-cluster` | 범용 | 클러스터 모드 |
| `bun` | Bun | Bun 런타임 |
| `deno_deploy` | Deno | Deno Deploy |

### 정적/기타

| Preset | 플랫폼 | 설명 |
|--------|--------|------|
| `static` | 범용 | 정적 사이트 생성 |
| `github_pages` | GitHub | GitHub Pages |
| `render_com` | Render | Render.com |

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

## 런타임 설정

### Node.js 호환성

```typescript
// nitro.config.ts
export default defineNitroConfig({
  preset: 'cloudflare_pages',
  cloudflare: {
    nodeCompat: true,  // Node.js API 호환성
  },
})
```

### 외부 패키지 처리

```typescript
// nitro.config.ts
export default defineNitroConfig({
  // 번들에서 제외할 패키지
  externals: ['pg', 'mysql2'],

  // 번들에 포함할 패키지
  inlineDependencies: ['my-esm-package'],
})
```

## 라우트 규칙

```typescript
// nitro.config.ts
export default defineNitroConfig({
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
  },
})
```

## 환경변수 관리

### .env 파일

```bash
# .env.production
DATABASE_URL=postgresql://...
API_SECRET=your-secret-key
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

## 빌드 명령어

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

## 참고 자료

- [Nitro 공식 문서](https://nitro.build)
- [Nitro Preset 목록](https://nitro.build/deploy)
