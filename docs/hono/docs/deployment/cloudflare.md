# Cloudflare Workers 배포

> Hono + Cloudflare Workers 상세 가이드

---

## 프로젝트 생성

```bash
npm create hono@latest my-app
# cloudflare-workers 템플릿 선택

cd my-app
npm install
```

---

## 프로젝트 구조

```
my-app/
├── src/
│   └── index.ts
├── wrangler.toml
├── package.json
└── tsconfig.json
```

---

## 기본 설정

### wrangler.toml

```toml
name = "my-hono-app"
main = "src/index.ts"
compatibility_date = "2024-01-01"
compatibility_flags = ["nodejs_compat"]

[vars]
NODE_ENV = "production"

# KV Namespace
[[kv_namespaces]]
binding = "MY_KV"
id = "your-kv-namespace-id"

# D1 Database
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "your-database-id"

# R2 Bucket
[[r2_buckets]]
binding = "MY_BUCKET"
bucket_name = "my-bucket"
```

### src/index.ts

```typescript
import { Hono } from 'hono'

type Bindings = {
  NODE_ENV: string
  MY_KV: KVNamespace
  DB: D1Database
  MY_BUCKET: R2Bucket
}

const app = new Hono<{ Bindings: Bindings }>()

app.get('/', (c) => {
  return c.json({ message: 'Hello Cloudflare Workers!' })
})

export default app
```

---

## Bindings 사용

### KV Namespace

```typescript
app.get('/kv/:key', async (c) => {
  const key = c.req.param('key')
  const value = await c.env.MY_KV.get(key)
  return c.json({ key, value })
})

app.put('/kv/:key', async (c) => {
  const key = c.req.param('key')
  const { value } = await c.req.json()
  await c.env.MY_KV.put(key, value)
  return c.json({ success: true })
})
```

### D1 Database

```typescript
app.get('/users', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM users'
  ).all()
  return c.json({ users: results })
})

app.post('/users', async (c) => {
  const { name, email } = await c.req.json()
  const { success } = await c.env.DB.prepare(
    'INSERT INTO users (name, email) VALUES (?, ?)'
  ).bind(name, email).run()
  return c.json({ success }, 201)
})
```

### R2 Bucket

```typescript
app.put('/upload/:key', async (c) => {
  const key = c.req.param('key')
  await c.env.MY_BUCKET.put(key, c.req.body)
  return c.json({ success: true })
})

app.get('/download/:key', async (c) => {
  const key = c.req.param('key')
  const object = await c.env.MY_BUCKET.get(key)

  if (!object) {
    return c.notFound()
  }

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream',
    },
  })
})
```

---

## 환경 변수

### 로컬 개발 (.dev.vars)

```
DATABASE_URL=postgresql://...
JWT_SECRET=dev-secret
API_KEY=dev-api-key
```

### 시크릿 설정

```bash
# 시크릿 추가
npx wrangler secret put JWT_SECRET
npx wrangler secret put DATABASE_URL

# 시크릿 목록
npx wrangler secret list

# 시크릿 삭제
npx wrangler secret delete JWT_SECRET
```

---

## 타입 생성

```bash
# wrangler.toml 기반 타입 생성
npx wrangler types

# 또는 환경별 타입 생성
npx wrangler types --env-interface CloudflareBindings
```

### worker-configuration.d.ts

```typescript
interface CloudflareBindings {
  NODE_ENV: string
  MY_KV: KVNamespace
  DB: D1Database
  MY_BUCKET: R2Bucket
  JWT_SECRET: string
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "types": [
      "@cloudflare/workers-types",
      "./worker-configuration.d.ts"
    ]
  }
}
```

---

## 배포

### 개발 서버

```bash
npm run dev
# 또는
npx wrangler dev
```

### 프로덕션 배포

```bash
npm run deploy
# 또는
npx wrangler deploy
```

### 환경별 배포

```bash
# staging
npx wrangler deploy --env staging

# production
npx wrangler deploy --env production
```

### wrangler.toml (환경별)

```toml
name = "my-app"
main = "src/index.ts"

[env.staging]
name = "my-app-staging"
vars = { NODE_ENV = "staging" }

[env.production]
name = "my-app-production"
vars = { NODE_ENV = "production" }
```

---

## GitHub Actions

```yaml
name: Deploy to Cloudflare Workers

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Deploy
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          # 환경 지정 시
          # command: deploy --env production
```

### GitHub Secrets 설정

1. Cloudflare Dashboard → My Profile → API Tokens
2. "Create Token" → "Edit Cloudflare Workers" 템플릿 사용
3. GitHub Repository → Settings → Secrets → `CLOUDFLARE_API_TOKEN` 추가

---

## 로깅 및 모니터링

### 실시간 로그

```bash
npx wrangler tail
```

### 커스텀 로깅

```typescript
app.use(async (c, next) => {
  const start = Date.now()
  await next()
  const duration = Date.now() - start

  console.log({
    method: c.req.method,
    path: c.req.path,
    status: c.res.status,
    duration: `${duration}ms`,
  })
})
```

---

## 관련 문서

- [배포 개요](./index.md)
- [Hono 기본](../library/hono/index.md)
