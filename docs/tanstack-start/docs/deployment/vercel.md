# Vercel 배포

> **상위 문서**: [배포](./index.md)
> **Version**: Nitro 3.x

Vercel은 TanStack Start 앱을 위한 최적화된 서버리스 배포 플랫폼입니다.

---

## 🚀 Quick Reference (복사용)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',
})
```

```json
// vercel.json
{
  "buildCommand": "yarn build",
  "outputDirectory": ".vercel/output"
}
```

```bash
# Vercel CLI 배포
vercel login
vercel
```

---

## Nitro 설정

### 기본 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // Vercel 서버리스 preset
  preset: 'vercel',

  // 호환성 날짜 (Nitro v3 필수)
  compatibilityDate: '2024-09-19',
})
```

### Edge Functions 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // Vercel Edge Functions preset
  preset: 'vercel-edge',

  // 호환성 날짜
  compatibilityDate: '2024-09-19',
})
```

### Bun 런타임 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  // Bun 런타임 사용
  vercel: {
    functions: {
      runtime: 'bun@1',
    },
  },
})
```

---

## Vite 설정

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

---

## vercel.json 설정

### 기본 설정

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "yarn build",
  "outputDirectory": ".vercel/output",
  "framework": null,
  "installCommand": "yarn install"
}
```

### 고급 설정

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "yarn build",
  "outputDirectory": ".vercel/output",

  "functions": {
    "api/**/*.ts": {
      "memory": 1024,
      "maxDuration": 30
    }
  },

  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" },
        { "key": "Access-Control-Allow-Methods", "value": "GET, POST, PUT, DELETE, OPTIONS" }
      ]
    }
  ],

  "rewrites": [
    { "source": "/(.*)", "destination": "/api" }
  ]
}
```

---

## 배포 방법

### 방법 1: GitHub 연동 (권장)

1. **Vercel 프로젝트 생성**
   - [Vercel 대시보드](https://vercel.com) 접속
   - "Add New" → "Project" → GitHub 저장소 선택

2. **빌드 설정**
   - Framework Preset: "Other"
   - Build Command: `yarn build`
   - Output Directory: `.vercel/output`
   - Install Command: `yarn install`

3. **환경 변수 설정**
   - Vercel 대시보드에서 Settings → Environment Variables

### 방법 2: Vercel CLI

```bash
# Vercel CLI 설치
npm install -g vercel

# 로그인
vercel login

# 프로젝트 연결 및 배포
vercel

# 프로덕션 배포
vercel --prod

# 환경 변수 설정
vercel env add DATABASE_URL
vercel env add API_SECRET
```

---

## ISR (Incremental Static Regeneration)

### ISR 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  // ISR 설정
  vercel: {
    config: {
      // 정적 페이지 재생성 간격 (초)
      isr: {
        bypassToken: process.env.ISR_BYPASS_TOKEN,
      },
    },
  },
})
```

### 라우트별 ISR

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  routeRules: {
    // 60초마다 재검증
    '/products/**': {
      isr: {
        expiration: 60,
      },
    },

    // 캐시하지 않음
    '/api/user/**': {
      isr: false,
    },
  },
})
```

### On-Demand ISR

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  vercel: {
    config: {
      bypassToken: process.env.VERCEL_BYPASS_TOKEN,
    },
  },
  routeRules: {
    '/products/**': {
      isr: {
        allowQuery: ['q'],  // 쿼리 파라미터 허용
        passQuery: true,
      },
    },
  },
})
```

### ISR 재검증 트리거

```typescript
// server/api/revalidate.ts
import { defineHandler, getHeader, createError } from 'nitro/h3'

export default defineHandler(async (event) => {
  const token = getHeader(event, 'x-vercel-bypass-token')

  if (token !== process.env.VERCEL_BYPASS_TOKEN) {
    throw createError({ statusCode: 401 })
  }

  // 특정 경로 재검증
  await $fetch('/__revalidate', {
    method: 'POST',
    body: { paths: ['/products/123'] },
  })

  return { revalidated: true }
})
```

---

## 환경변수

### Vercel 대시보드에서 설정

```
DATABASE_URL=postgresql://user:pass@host:5432/db
API_SECRET=your-secret-key
NODE_ENV=production
```

### 환경별 설정

Vercel은 환경별로 다른 값 설정 가능:
- **Production**: 프로덕션 환경
- **Preview**: PR 프리뷰 환경
- **Development**: 로컬 개발 환경

### Vercel 자동 제공 변수

| 변수 | 설명 |
|------|------|
| `VERCEL` | Vercel 환경인지 여부 ("1") |
| `VERCEL_ENV` | 환경 (production, preview, development) |
| `VERCEL_URL` | 배포 URL |
| `VERCEL_REGION` | 실행 리전 |
| `VERCEL_GIT_COMMIT_SHA` | Git 커밋 SHA |

---

## 환경별 설정

### 프리뷰 vs 프로덕션

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

const isProduction = process.env.VERCEL_ENV === 'production'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  routeRules: {
    '/api/**': {
      cors: !isProduction,  // 개발 환경에서만 CORS 허용
    },
  },
})
```

---

## 모노레포 설정

### vercel.json

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "installCommand": "yarn install",
  "buildCommand": "yarn workspace web build",
  "outputDirectory": "apps/web/.vercel/output"
}
```

---

## GitHub 통합

### 자동 배포 설정

1. Vercel 대시보드에서 GitHub 저장소 연결
2. 브랜치별 배포 설정:
   - `main` → 프로덕션
   - `develop` → 프리뷰
   - PR → 프리뷰 배포

### vercel.json 브랜치 설정

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "git": {
    "deploymentEnabled": {
      "main": true,
      "develop": true
    }
  }
}
```

---

## CI/CD 설정

### GitHub Actions

```yaml
# .github/workflows/vercel.yml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'

      - name: Install dependencies
        run: yarn install --frozen-lockfile

      - name: Build
        run: yarn build

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: ${{ github.ref == 'refs/heads/main' && '--prod' || '' }}
```

---

## 최적화

### Cold Start 최소화

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  // 번들 최적화
  minify: true,

  // 트리 쉐이킹
  experimental: {
    wasm: true,
  },
})
```

### Function 크기 최소화

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',

  // 외부 패키지 제외 (번들 크기 감소)
  externals: ['sharp', 'prisma', '@prisma/client'],
})
```

---

## 도메인 설정

```bash
# 커스텀 도메인 추가
vercel domains add example.com

# DNS 설정 확인
vercel domains inspect example.com
```

---

## 트러블슈팅

### 일반적인 문제

| 문제 | 원인 | 해결 |
|------|------|------|
| Function Timeout | 실행 시간 초과 | `maxDuration` 증가 또는 최적화 |
| Edge 호환성 오류 | Node.js API 사용 | Edge 호환 API로 변경 |
| 환경 변수 누락 | 설정 안됨 | Vercel 대시보드에서 설정 |
| 빌드 실패 | 의존성 문제 | `yarn.lock` 확인 |

### 디버깅

```bash
# 로컬에서 Vercel 환경 시뮬레이션
vercel dev

# 로그 확인
vercel logs

# 환경 변수 확인
vercel env ls

# 환경 변수 풀 다운
vercel env pull .env.local

# 함수 상태 확인
vercel inspect
```

---

## 유용한 명령어

```bash
# 프로덕션 배포
vercel --prod

# 특정 프로젝트로 배포
vercel --scope my-team

# 배포 목록 확인
vercel ls

# 배포 롤백
vercel rollback [deployment-url]
```

---

## package.json 스크립트

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

---

## 참고 자료

- [TanStack Start Hosting](https://tanstack.com/start/latest/docs/framework/react/hosting)
- [Vercel 공식 문서](https://vercel.com/docs)
- [Vercel CLI](https://vercel.com/docs/cli)
- [Nitro Vercel Preset](https://nitro.build/deploy/providers/vercel)
