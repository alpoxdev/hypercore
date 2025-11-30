# Cloudflare 배포

> **상위 문서**: [배포](./index.md)

Cloudflare는 Workers와 Pages 두 가지 배포 옵션을 제공합니다.

## 배포 옵션 비교

| 옵션 | Preset | 특징 |
|------|--------|------|
| **Workers** | `cloudflare_module` | 서버리스 컴퓨팅, KV/D1 통합 |
| **Pages** | `cloudflare_pages` | 정적 사이트 + Functions |

## Cloudflare Workers

### 1. 패키지 설치

```bash
yarn add @cloudflare/vite-plugin wrangler -D
```

### 2. Vite 설정 (직접 통합)

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { cloudflare } from '@cloudflare/vite-plugin'

export default defineConfig({
  plugins: [
    cloudflare({ viteEnvironment: { name: 'ssr' } }),
    tanstackStart(),
    react(),
  ],
})
```

### 3. Wrangler 설정

```jsonc
// wrangler.jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "my-tanstack-app",
  "compatibility_date": "2025-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "main": "@tanstack/react-start/server-entry"
}
```

### 4. 배포

```bash
# 빌드
yarn build

# 배포
wrangler deploy
```

## Cloudflare Pages

### 1. Nitro 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'cloudflare_pages',
  // Nitro v3 필수: Static Assets 지원을 위해 2024-09-19 이상 필요
  compatibilityDate: '2024-09-19',
  cloudflare: {
    deployConfig: true,  // wrangler.json 자동 생성
    nodeCompat: true,    // Node.js API 호환성
  },
})
```

### 2. Vite 설정 (Nitro 통합)

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

### 3. 배포

```bash
# 빌드
NITRO_PRESET=cloudflare_pages yarn build

# Pages 배포
wrangler pages deploy .output/public
```

## Wrangler 설정 상세

### wrangler.toml (Workers)

```toml
name = "my-app"
main = ".output/server/index.mjs"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

[vars]
MY_VAR = "value"

[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-id"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-database-id"
```

### wrangler.toml (Pages)

```toml
name = "my-pages-app"
pages_build_output_dir = ".output/public"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-database-id"
```

## KV 스토리지 사용

### KV 네임스페이스 생성

```bash
# KV 네임스페이스 생성
wrangler kv:namespace create "MY_KV"

# wrangler.toml에 바인딩 추가
```

### 코드에서 사용

```typescript
// server/api/kv-example.ts
import { defineHandler } from 'nitro/h3'

export default defineHandler(async (event) => {
  const env = event.context.cloudflare.env

  // KV 읽기
  const value = await env.MY_KV.get('key')

  // KV 쓰기
  await env.MY_KV.put('key', 'value')

  return { value }
})
```

## D1 데이터베이스 사용

### D1 데이터베이스 생성

```bash
# 데이터베이스 생성
wrangler d1 create my-database

# 마이그레이션 실행
wrangler d1 migrations apply my-database
```

### 코드에서 사용

```typescript
// server/api/d1-example.ts
import { defineHandler } from 'nitro/h3'

export default defineHandler(async (event) => {
  const env = event.context.cloudflare.env

  // 쿼리 실행
  const results = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?'
  ).bind(1).all()

  return results
})
```

## 환경변수 관리

### 로컬 개발

```bash
# .dev.vars 파일 생성
DATABASE_URL=your-local-url
API_SECRET=your-secret
```

### 프로덕션

```bash
# 시크릿 설정
wrangler secret put API_SECRET

# 일반 변수 (wrangler.toml)
[vars]
NODE_ENV = "production"
```

## 커스텀 도메인

### Pages

```bash
# 커스텀 도메인 추가
wrangler pages project add-custom-domain my-app example.com
```

### Workers

Cloudflare 대시보드에서 설정하거나:

```toml
# wrangler.toml
routes = [
  { pattern = "example.com/*", zone_name = "example.com" }
]
```

## 개발 서버

```bash
# 로컬 개발 (Workers)
wrangler dev

# Pages 로컬 개발
wrangler pages dev .output/public

# 미니플레어 사용
wrangler dev --local
```

## 트러블슈팅

### Node.js API 호환성

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'cloudflare_pages',
  compatibilityDate: '2024-09-19',
  cloudflare: {
    nodeCompat: true,
  },
  // 또는 특정 폴리필 설정
  unenv: {
    alias: {
      'node:buffer': 'buffer',
    },
  },
})
```

### 번들 크기 최적화

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'cloudflare_pages',
  compatibilityDate: '2024-09-19',
  // 외부화할 패키지
  externals: ['@prisma/client'],
  // 트리 쉐이킹
  minify: true,
})
```

### 로그 확인

```bash
# 실시간 로그
wrangler tail

# 특정 배포 로그
wrangler tail --deployment-id [id]
```

## CI/CD 설정

### GitHub Actions

```yaml
name: Deploy to Cloudflare

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: yarn install
      - run: yarn build
        env:
          NITRO_PRESET: cloudflare_pages

      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          command: pages deploy .output/public --project-name=my-app
```

## 참고 자료

- [Cloudflare Workers 문서](https://developers.cloudflare.com/workers/)
- [Cloudflare Pages 문서](https://developers.cloudflare.com/pages/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)
- [Nitro Cloudflare Preset](https://nitro.build/deploy/providers/cloudflare)
