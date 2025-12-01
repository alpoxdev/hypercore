# Nitro v3 - Cloudflare 배포

> **상위 문서**: [배포 가이드](./index.md)

Cloudflare Workers/Pages를 사용하여 Hono + Nitro 애플리케이션을 Edge에 배포합니다.

---

## 🚀 Quick Reference (복사용)

### Cloudflare Workers

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "cloudflare_module",
  compatibilityDate: "2024-09-19",
  cloudflare: {
    deployConfig: true,
    nodeCompat: true,
  },
});
```

### Cloudflare Pages

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "cloudflare_pages",
  compatibilityDate: "2024-09-19",
  cloudflare: {
    deployConfig: true,
    nodeCompat: true,
  },
});
```

```bash
# Wrangler CLI 배포
wrangler login
wrangler deploy
```

---

## Cloudflare Workers vs Pages

| 기능 | Workers | Pages |
|------|---------|-------|
| 용도 | 순수 API/서버리스 | 정적 사이트 + API |
| 정적 파일 | ❌ | ✅ |
| 무료 요청 | 100,000/일 | 무제한 정적 |
| 커스텀 도메인 | ✅ | ✅ |
| D1/KV/R2 | ✅ | ✅ |

---

## Cloudflare Workers 설정

### nitro.config.ts

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cloudflare Workers 배포용 Nitro 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // Cloudflare Workers (ES Module 형식)
  preset: "cloudflare_module",

  // 호환성 날짜 (필수)
  compatibilityDate: "2024-09-19",

  // Cloudflare 설정
  cloudflare: {
    // wrangler.toml 자동 생성
    deployConfig: true,

    // Node.js 호환성 활성화
    nodeCompat: true,
  },
});
```

### wrangler.toml

```toml
# wrangler.toml
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Cloudflare Workers 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

name = "hono-nitro-app"
main = ".output/server/index.mjs"
compatibility_date = "2024-09-19"

# Node.js 호환성 플래그
compatibility_flags = ["nodejs_compat"]

# 환경 변수
[vars]
NODE_ENV = "production"

# D1 데이터베이스 바인딩
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# KV 네임스페이스 바인딩
[[kv_namespaces]]
binding = "KV"
id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# R2 버킷 바인딩
[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"

# 시크릿 (wrangler secret put 으로 설정)
# API_SECRET = "..."
```

---

## Cloudflare Pages 설정

### nitro.config.ts

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cloudflare Pages 배포용 Nitro 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // Cloudflare Pages
  preset: "cloudflare_pages",

  // 호환성 날짜
  compatibilityDate: "2024-09-19",

  // Cloudflare 설정
  cloudflare: {
    deployConfig: true,
    nodeCompat: true,

    // Pages 전용 설정
    pages: {
      // 정적 파일 디렉토리
      staticDir: "public",
    },
  },
});
```

---

## 배포 방법

### 방법 1: Wrangler CLI (Workers)

```bash
# Wrangler CLI 설치
npm install -g wrangler

# 로그인
wrangler login

# 빌드
pnpm build

# 배포
wrangler deploy

# 개발 서버
wrangler dev
```

### 방법 2: GitHub 연동 (Pages)

1. **Cloudflare Pages 프로젝트 생성**
   - [Cloudflare Dashboard](https://dash.cloudflare.com) → Pages
   - "Create a project" → "Connect to Git"
   - GitHub 저장소 선택

2. **빌드 설정**
   ```
   Framework preset: None
   Build command: pnpm build
   Build output directory: .output/public
   ```

3. **환경 변수 설정**
   - Settings → Environment variables

### 방법 3: Wrangler CLI (Pages)

```bash
# Pages 배포
wrangler pages deploy .output/public

# 프로덕션 배포
wrangler pages deploy .output/public --branch main
```

---

## Bindings (D1, KV, R2)

### D1 데이터베이스

```typescript
// src/server.ts
import { Hono } from "hono";

// Cloudflare Bindings 타입 정의
type Bindings = {
  DB: D1Database;
};

const app = new Hono<{ Bindings: Bindings }>();

// D1 쿼리
app.get("/users", async (c) => {
  const { results } = await c.env.DB.prepare(
    "SELECT * FROM users"
  ).all();

  return c.json(results);
});

app.post("/users", async (c) => {
  const { name, email } = await c.req.json();

  const result = await c.env.DB.prepare(
    "INSERT INTO users (name, email) VALUES (?, ?)"
  )
    .bind(name, email)
    .run();

  return c.json({ id: result.meta.last_row_id });
});

export default app;
```

### D1 마이그레이션

```bash
# 마이그레이션 생성
wrangler d1 migrations create my-database create_users

# 마이그레이션 적용
wrangler d1 migrations apply my-database

# 로컬 D1 실행
wrangler d1 execute my-database --local --command="SELECT * FROM users"
```

```sql
-- migrations/0001_create_users.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### KV 스토리지

```typescript
// src/server.ts
import { Hono } from "hono";

type Bindings = {
  KV: KVNamespace;
};

const app = new Hono<{ Bindings: Bindings }>();

// KV 읽기
app.get("/cache/:key", async (c) => {
  const key = c.req.param("key");
  const value = await c.env.KV.get(key);

  if (!value) {
    return c.json({ error: "Not found" }, 404);
  }

  return c.json({ key, value: JSON.parse(value) });
});

// KV 쓰기
app.put("/cache/:key", async (c) => {
  const key = c.req.param("key");
  const body = await c.req.json();

  // TTL 설정 (초 단위)
  await c.env.KV.put(key, JSON.stringify(body), {
    expirationTtl: 3600, // 1시간
  });

  return c.json({ success: true });
});

export default app;
```

### R2 스토리지

```typescript
// src/server.ts
import { Hono } from "hono";

type Bindings = {
  BUCKET: R2Bucket;
};

const app = new Hono<{ Bindings: Bindings }>();

// 파일 업로드
app.post("/upload/:filename", async (c) => {
  const filename = c.req.param("filename");
  const body = await c.req.arrayBuffer();

  await c.env.BUCKET.put(filename, body, {
    httpMetadata: {
      contentType: c.req.header("Content-Type") || "application/octet-stream",
    },
  });

  return c.json({ success: true, filename });
});

// 파일 다운로드
app.get("/download/:filename", async (c) => {
  const filename = c.req.param("filename");
  const object = await c.env.BUCKET.get(filename);

  if (!object) {
    return c.json({ error: "Not found" }, 404);
  }

  c.header("Content-Type", object.httpMetadata?.contentType || "application/octet-stream");
  return c.body(object.body);
});

export default app;
```

---

## 환경 변수

### wrangler.toml에서 설정

```toml
# wrangler.toml
[vars]
NODE_ENV = "production"
API_BASE_URL = "https://api.example.com"

# 환경별 설정
[env.staging.vars]
NODE_ENV = "staging"
API_BASE_URL = "https://staging-api.example.com"

[env.production.vars]
NODE_ENV = "production"
API_BASE_URL = "https://api.example.com"
```

### 시크릿 설정 (CLI)

```bash
# 시크릿 추가
wrangler secret put API_SECRET
wrangler secret put DATABASE_URL

# 시크릿 목록
wrangler secret list

# 시크릿 삭제
wrangler secret delete API_SECRET
```

### 코드에서 사용

```typescript
// src/server.ts
import { Hono } from "hono";

type Bindings = {
  API_SECRET: string;
  NODE_ENV: string;
};

const app = new Hono<{ Bindings: Bindings }>();

app.get("/config", (c) => {
  return c.json({
    environment: c.env.NODE_ENV,
    hasSecret: !!c.env.API_SECRET,
  });
});

export default app;
```

---

## 도메인 설정

### Workers 커스텀 도메인

```toml
# wrangler.toml
routes = [
  { pattern = "api.example.com/*", zone_name = "example.com" }
]

# 또는
[triggers]
routes = [
  "api.example.com/*"
]
```

### Pages 커스텀 도메인

1. Cloudflare Dashboard → Pages → 프로젝트 선택
2. Custom domains → Add custom domain
3. DNS 설정 자동 구성

---

## CI/CD 설정

### GitHub Actions (Workers)

```yaml
# .github/workflows/cloudflare-workers.yml
name: Deploy to Cloudflare Workers

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "pnpm"

      - name: Install dependencies
        run: pnpm install

      - name: Build
        run: pnpm build

      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### GitHub Actions (Pages)

```yaml
# .github/workflows/cloudflare-pages.yml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "pnpm"

      - name: Install dependencies
        run: pnpm install

      - name: Build
        run: pnpm build

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: my-hono-app
          directory: .output/public
          branch: main
```

---

## 성능 최적화

### 캐싱 설정

```typescript
// src/server.ts
import { Hono } from "hono";
import { cache } from "hono/cache";

const app = new Hono();

// 캐시 미들웨어
app.use(
  "/api/public/*",
  cache({
    cacheName: "hono-cache",
    cacheControl: "max-age=3600", // 1시간
  })
);

// 또는 수동으로 Cache API 사용
app.get("/cached-data", async (c) => {
  const cacheKey = new Request(c.req.url);
  const cache = caches.default;

  // 캐시 확인
  let response = await cache.match(cacheKey);
  if (response) {
    return response;
  }

  // 데이터 가져오기
  const data = await fetchData();

  // 응답 생성 및 캐시
  response = c.json(data);
  response.headers.set("Cache-Control", "max-age=3600");

  c.executionCtx.waitUntil(cache.put(cacheKey, response.clone()));

  return response;
});

export default app;
```

### Smart Placement

```toml
# wrangler.toml
# Smart Placement: 데이터 소스에 가까운 위치에서 실행
[placement]
mode = "smart"
```

---

## 로컬 개발

### Wrangler Dev

```bash
# 로컬 개발 서버
wrangler dev

# D1 로컬 모드
wrangler dev --local --persist

# 특정 포트
wrangler dev --port 3000
```

### Miniflare (고급)

```typescript
// miniflare.config.ts
import { Miniflare } from "miniflare";

const mf = new Miniflare({
  script: ".output/server/index.mjs",
  modules: true,
  d1Databases: ["DB"],
  kvNamespaces: ["KV"],
  r2Buckets: ["BUCKET"],
});
```

---

## 문제 해결

### 일반적인 문제

| 문제 | 원인 | 해결 |
|------|------|------|
| "Worker exceeded size limit" | 번들 크기 초과 | 의존성 최적화, externals 설정 |
| "D1 not found" | 바인딩 설정 오류 | wrangler.toml 확인 |
| "Compatibility date" 오류 | 날짜 형식 오류 | YYYY-MM-DD 형식 확인 |
| Node.js API 오류 | 호환성 플래그 누락 | `nodejs_compat` 플래그 추가 |

### 디버깅

```bash
# 로그 확인 (실시간)
wrangler tail

# 배포 상태 확인
wrangler deployments list

# 설정 검증
wrangler deploy --dry-run
```

### 번들 크기 최적화

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "cloudflare_module",
  compatibilityDate: "2024-09-19",

  // 외부 패키지 제외
  externals: ["@prisma/client"],

  // 압축
  minify: true,
});
```

---

## 관련 문서

- [배포 가이드 개요](./index.md)
- [Docker 배포](./docker.md)
- [Railway 배포](./railway.md)
- [Vercel 배포](./vercel.md)
- [Cloudflare Workers 공식 문서](https://developers.cloudflare.com/workers/)
- [Cloudflare Pages 공식 문서](https://developers.cloudflare.com/pages/)
