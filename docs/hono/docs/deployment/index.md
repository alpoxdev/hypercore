# Nitro v3 배포 가이드

> Hono + Nitro 배포

@docker.md
@railway.md
@vercel.md
@cloudflare.md

---

## 설치

```bash
npm install nitro@3
```

---

## 기본 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "node", // node | cloudflare_module | vercel
  compatibilityDate: "2024-09-19",
  srcDir: "src",
});
```

---

## 엔트리포인트

```typescript
// src/server.ts
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.json({ message: "Hello" }));
app.get("/health", (c) => c.json({ status: "ok" }));

export default app;
```

---

## CLI

```bash
npx nitro dev              # 개발 서버
npx nitro build            # 빌드
npx nitro preview          # 프리뷰
node .output/server/index.mjs  # 실행
```

---

## Preset 선택

| Preset | 용도 |
|--------|------|
| `node` | Node.js 서버, Docker |
| `cloudflare_module` | Cloudflare Workers |
| `cloudflare_pages` | Cloudflare Pages |
| `vercel` | Vercel Functions |
| `vercel-edge` | Vercel Edge |

---

## 환경 변수

```typescript
// nitro.config.ts
export default defineNitroConfig({
  runtimeConfig: {
    apiSecret: process.env.API_SECRET,
    public: {
      apiBase: process.env.API_BASE_URL || "/api",
    },
  },
});
```

```typescript
// src/server.ts
app.get("/config", (c) => {
  return c.json({
    environment: process.env.NODE_ENV,
    hasDb: !!process.env.DATABASE_URL,
  });
});
```

---

## 프로젝트 구조

```
프로젝트/
├── nitro.config.ts
├── src/
│   ├── server.ts      # Hono 앱
│   ├── routes/
│   └── lib/
├── .output/           # 빌드 결과물
└── package.json
```

---

## 관련 문서

- [Docker](./docker.md)
- [Railway](./railway.md)
- [Vercel](./vercel.md)
- [Cloudflare](./cloudflare.md)
