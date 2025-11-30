# Vercel 배포

> **상위 문서**: [배포](./index.md)

Vercel은 TanStack Start 앱을 위한 최적화된 배포 플랫폼입니다.

## 빠른 시작

### 1. Nitro 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
})
```

### 2. 빌드 및 배포

```bash
# 빌드
yarn build

# Vercel CLI로 배포
vercel
```

## Vercel 설정

### vercel.json

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "yarn build",
  "outputDirectory": ".output",
  "framework": null
}
```

### 환경변수

Vercel 대시보드에서 설정하거나 CLI 사용:

```bash
# 환경변수 추가
vercel env add DATABASE_URL

# 환경변수 확인
vercel env ls
```

## ISR (Incremental Static Regeneration)

### 기본 ISR 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  routeRules: {
    // 60초마다 재검증
    '/products/**': {
      isr: {
        expiration: 60,
      },
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

## Bun 런타임

### nitro.config.ts 설정

```typescript
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  vercel: {
    functions: {
      runtime: 'bun1.x',
    },
  },
})
```

### vercel.json 설정

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "bunVersion": "1.x"
}
```

## Edge Functions

### Edge 런타임 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  routeRules: {
    '/api/edge/**': {
      // Edge 런타임에서 실행
      headers: {
        'x-vercel-edge': '1',
      },
    },
  },
})
```

## 환경별 설정

### 프리뷰 vs 프로덕션

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

const isProduction = process.env.VERCEL_ENV === 'production'

export default defineNitroConfig({
  preset: 'vercel',
  routeRules: {
    '/api/**': {
      cors: !isProduction,  // 개발 환경에서만 CORS 허용
    },
  },
})
```

## 모노레포 설정

### vercel.json

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "installCommand": "yarn install",
  "buildCommand": "yarn workspace web build",
  "outputDirectory": "apps/web/.output"
}
```

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

## 도메인 설정

```bash
# 커스텀 도메인 추가
vercel domains add example.com

# DNS 설정 확인
vercel domains inspect example.com
```

## 트러블슈팅

### 빌드 실패

```bash
# 로컬에서 Vercel 빌드 시뮬레이션
vercel build

# 상세 로그 확인
vercel logs [deployment-url]
```

### Function 크기 초과

```typescript
// nitro.config.ts
export default defineNitroConfig({
  preset: 'vercel',
  // 외부 패키지로 분리
  externals: ['@prisma/client', 'sharp'],
})
```

### 환경변수 누락

```bash
# 환경변수 풀 다운
vercel env pull .env.local
```

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

## 참고 자료

- [Vercel 공식 문서](https://vercel.com/docs)
- [Vercel CLI](https://vercel.com/docs/cli)
- [Nitro Vercel Preset](https://nitro.build/deploy/providers/vercel)
