# 배포 가이드

> Hono 애플리케이션 배포 옵션

---

## 지원 런타임

Hono는 Web Standards 기반으로 다양한 런타임에서 동작합니다.

| 런타임 | 특징 |
|--------|------|
| **Cloudflare Workers** | 엣지 컴퓨팅, 글로벌 배포 |
| **Deno Deploy** | TypeScript 네이티브 |
| **Bun** | 빠른 실행 속도 |
| **Node.js** | 전통적인 서버 환경 |
| **AWS Lambda** | 서버리스 |
| **Vercel** | 프론트엔드 통합 |

---

## Cloudflare Workers

### 프로젝트 생성

```bash
npm create hono@latest my-app
# cloudflare-workers 템플릿 선택
```

### wrangler.toml

```toml
name = "my-hono-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
NODE_ENV = "production"
```

### 배포

```bash
# 로컬 개발
npm run dev

# 배포
npm run deploy
# 또는
npx wrangler deploy
```

### 환경 변수

```bash
# 시크릿 설정
npx wrangler secret put DATABASE_URL
npx wrangler secret put JWT_SECRET
```

### 로컬 환경 변수 (.dev.vars)

```
DATABASE_URL=postgresql://...
JWT_SECRET=your-secret
```

### GitHub Actions 배포

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

---

## Bun

### 프로젝트 생성

```bash
bun create hono@latest my-app
# bun 템플릿 선택
```

### 실행

```bash
bun run src/index.ts
```

### package.json

```json
{
  "scripts": {
    "dev": "bun run --hot src/index.ts",
    "start": "bun run src/index.ts"
  }
}
```

### Docker 배포

```dockerfile
FROM oven/bun:1 AS base
WORKDIR /app

# 의존성 설치
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

# 소스 복사
COPY . .

# 실행
EXPOSE 3000
CMD ["bun", "run", "src/index.ts"]
```

---

## Node.js

### 설치

```bash
npm install @hono/node-server
```

### Entry Point

```typescript
import { serve } from '@hono/node-server'
import app from './app'

serve({
  fetch: app.fetch,
  port: 3000,
})

console.log('Server is running on http://localhost:3000')
```

### package.json

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

---

## Deno

### 프로젝트 생성

```bash
deno init --npm hono@latest my-app
# deno 템플릿 선택
```

### deno.json

```json
{
  "tasks": {
    "dev": "deno run --allow-net --allow-env --watch src/index.ts",
    "start": "deno run --allow-net --allow-env src/index.ts"
  }
}
```

### Deno Deploy

```bash
deployctl deploy --project=my-app src/index.ts
```

---

## Vercel

### vercel.json

```json
{
  "builds": [
    {
      "src": "src/index.ts",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "src/index.ts"
    }
  ]
}
```

---

## 환경별 설정

### 환경 변수 타입

```typescript
// types/env.d.ts
type Bindings = {
  NODE_ENV: 'development' | 'production' | 'test'
  DATABASE_URL: string
  JWT_SECRET: string
}

// app.ts
const app = new Hono<{ Bindings: Bindings }>()

app.get('/', (c) => {
  const env = c.env.NODE_ENV
  return c.json({ env })
})
```

### 환경별 설정 분기

```typescript
const app = new Hono()

// 개발 환경에서만 logger
if (process.env.NODE_ENV === 'development') {
  app.use(logger())
}

// 프로덕션에서만 보안 헤더
if (process.env.NODE_ENV === 'production') {
  app.use(secureHeaders())
}
```

---

## 헬스 체크

```typescript
app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  })
})

app.get('/ready', async (c) => {
  try {
    // DB 연결 확인
    await prisma.$queryRaw`SELECT 1`
    return c.json({ status: 'ready' })
  } catch {
    return c.json({ status: 'not ready' }, 503)
  }
})
```

---

## 관련 문서

- [Cloudflare Workers 상세](./cloudflare.md)
- [Bun 상세](./bun.md)
- [Node.js 상세](./nodejs.md)
