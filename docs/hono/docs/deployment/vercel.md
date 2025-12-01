# Nitro v3 - Vercel 배포

> **상위 문서**: [배포 가이드](./index.md)

Vercel을 사용하여 Hono + Nitro 애플리케이션을 서버리스로 배포합니다.

---

## 🚀 Quick Reference (복사용)

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel",
  compatibilityDate: "2024-09-19",
});
```

```json
// vercel.json
{
  "buildCommand": "nitro build",
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
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Vercel 배포용 Nitro 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // Vercel 서버리스 preset
  preset: "vercel",

  // 호환성 날짜
  compatibilityDate: "2024-09-19",
});
```

### Edge Functions 설정

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Vercel Edge Functions 설정
// 더 낮은 지연시간을 위해 Edge에서 실행
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel-edge",
  compatibilityDate: "2024-09-19",
});
```

### Bun 런타임 설정

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Vercel + Bun 런타임 설정
// 빠른 실행 속도를 위해 Bun 사용
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel",
  compatibilityDate: "2024-09-19",

  // Bun 런타임 사용
  vercel: {
    functions: {
      runtime: "bun@1",
    },
  },
});
```

---

## vercel.json 설정

### 기본 설정

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "pnpm build",
  "outputDirectory": ".vercel/output",
  "framework": null,
  "installCommand": "pnpm install"
}
```

### 고급 설정

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "pnpm build",
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
   - Build Command: `pnpm build`
   - Output Directory: `.vercel/output`
   - Install Command: `pnpm install`

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
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel",
  compatibilityDate: "2024-09-19",

  // ISR 설정
  vercel: {
    config: {
      // 정적 페이지 재생성 간격 (초)
      isr: {
        bypassToken: process.env.ISR_BYPASS_TOKEN,
      },
    },
  },
});
```

### 라우트별 ISR

```typescript
// src/server.ts
import { Hono } from "hono";

const app = new Hono();

// ISR 헤더 설정으로 캐시 제어
app.get("/posts", async (c) => {
  // 60초마다 재생성
  c.header("Cache-Control", "s-maxage=60, stale-while-revalidate");

  const posts = await fetchPosts();
  return c.json(posts);
});

// 캐시 무효화가 필요한 엔드포인트
app.get("/user/:id", async (c) => {
  // 캐시하지 않음
  c.header("Cache-Control", "no-store");

  const user = await fetchUser(c.req.param("id"));
  return c.json(user);
});

export default app;
```

---

## 환경 변수

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

### 코드에서 사용

```typescript
// src/server.ts
import { Hono } from "hono";

const app = new Hono();

app.get("/config", (c) => {
  return c.json({
    environment: process.env.VERCEL_ENV,  // production, preview, development
    region: process.env.VERCEL_REGION,    // iad1, sfo1 등
    url: process.env.VERCEL_URL,          // 배포 URL
  });
});

export default app;
```

### Vercel 자동 제공 변수

| 변수 | 설명 |
|------|------|
| `VERCEL` | Vercel 환경인지 여부 ("1") |
| `VERCEL_ENV` | 환경 (production, preview, development) |
| `VERCEL_URL` | 배포 URL |
| `VERCEL_REGION` | 실행 리전 |
| `VERCEL_GIT_COMMIT_SHA` | Git 커밋 SHA |

---

## 데이터베이스 연동

### Vercel Postgres

```typescript
// src/lib/db.ts
import { sql } from "@vercel/postgres";

export const getUsers = async () => {
  const { rows } = await sql`SELECT * FROM users`;
  return rows;
};
```

### Vercel KV (Redis)

```typescript
// src/lib/kv.ts
import { kv } from "@vercel/kv";

export const getCache = async (key: string) => {
  return await kv.get(key);
};

export const setCache = async (key: string, value: unknown, ttl?: number) => {
  if (ttl) {
    await kv.set(key, value, { ex: ttl });
  } else {
    await kv.set(key, value);
  }
};
```

### 외부 데이터베이스

```typescript
// src/lib/prisma.ts
import { PrismaClient } from "@prisma/client";

// Vercel 서버리스 환경에서 커넥션 풀 최적화
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query"] : [],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
```

---

## Edge Middleware

### middleware.ts

```typescript
// middleware.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Vercel Edge Middleware
// 요청 전처리 및 라우팅
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // 인증 체크
  const token = request.cookies.get("auth-token");

  if (!token && request.nextUrl.pathname.startsWith("/api/protected")) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // 리전 기반 라우팅
  const country = request.geo?.country || "US";
  if (country === "KR") {
    // 한국 사용자를 위한 특별 처리
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/api/:path*"],
};
```

---

## 모니터링 및 분석

### Vercel Analytics

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel",
  compatibilityDate: "2024-09-19",

  // Analytics 활성화
  vercel: {
    config: {
      analytics: true,
    },
  },
});
```

### 커스텀 로깅

```typescript
// src/server.ts
import { Hono } from "hono";
import { logger } from "hono/logger";

const app = new Hono();

// 요청 로깅
app.use("*", logger());

// Vercel 로그로 전송
app.use("*", async (c, next) => {
  const start = Date.now();
  await next();
  const duration = Date.now() - start;

  console.log(JSON.stringify({
    method: c.req.method,
    path: c.req.path,
    status: c.res.status,
    duration,
    region: process.env.VERCEL_REGION,
  }));
});

export default app;
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
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel",
  compatibilityDate: "2024-09-19",

  // 번들 최적화
  minify: true,

  // 트리 쉐이킹
  experimental: {
    wasm: true,
  },
});
```

### 응답 압축

```typescript
// src/server.ts
import { Hono } from "hono";
import { compress } from "hono/compress";

const app = new Hono();

// Gzip/Brotli 압축
app.use("*", compress());

export default app;
```

---

## 문제 해결

### 일반적인 문제

| 문제 | 원인 | 해결 |
|------|------|------|
| Function Timeout | 실행 시간 초과 | `maxDuration` 증가 또는 최적화 |
| Edge 호환성 오류 | Node.js API 사용 | Edge 호환 API로 변경 |
| 환경 변수 누락 | 설정 안됨 | Vercel 대시보드에서 설정 |
| 빌드 실패 | 의존성 문제 | `pnpm-lock.yaml` 확인 |

### 디버깅

```bash
# 로컬에서 Vercel 환경 시뮬레이션
vercel dev

# 로그 확인
vercel logs

# 환경 변수 확인
vercel env ls

# 함수 상태 확인
vercel inspect
```

### 함수 크기 제한

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel",
  compatibilityDate: "2024-09-19",

  // 외부 패키지 제외 (번들 크기 감소)
  externals: ["sharp", "prisma"],
});
```

---

## 관련 문서

- [배포 가이드 개요](./index.md)
- [Docker 배포](./docker.md)
- [Railway 배포](./railway.md)
- [Cloudflare 배포](./cloudflare.md)
- [Vercel 공식 문서](https://vercel.com/docs)
