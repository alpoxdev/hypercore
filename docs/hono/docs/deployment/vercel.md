# Nitro - Vercel 배포

> 서버리스 배포

---

## 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "vercel", // vercel-edge for Edge Functions
  compatibilityDate: "2024-09-19",
});
```

```json
// vercel.json
{
  "buildCommand": "yarn build",
  "outputDirectory": ".vercel/output"
}
```

---

## 배포

### GitHub 연동 (권장)

1. [Vercel 대시보드](https://vercel.com) → Add New → Project
2. Build Command: `yarn build`
3. Output Directory: `.vercel/output`

### CLI

```bash
npm install -g vercel
vercel login
vercel          # 프리뷰
vercel --prod   # 프로덕션

vercel env add DATABASE_URL
```

---

## Edge Functions

```typescript
// nitro.config.ts
export default defineNitroConfig({
  preset: "vercel-edge",
  compatibilityDate: "2024-09-19",
});
```

---

## ISR (캐시)

```typescript
app.get("/posts", async (c) => {
  c.header("Cache-Control", "s-maxage=60, stale-while-revalidate");
  return c.json(await fetchPosts());
});

app.get("/user/:id", async (c) => {
  c.header("Cache-Control", "no-store"); // 캐시 안함
  return c.json(await fetchUser(c.req.param("id")));
});
```

---

## 환경 변수

```typescript
app.get("/config", (c) => {
  return c.json({
    env: process.env.VERCEL_ENV,      // production, preview
    region: process.env.VERCEL_REGION,
  });
});
```

| 자동 제공 변수 | 설명 |
|---------------|------|
| `VERCEL` | Vercel 환경 ("1") |
| `VERCEL_ENV` | 환경 |
| `VERCEL_URL` | 배포 URL |
| `VERCEL_REGION` | 실행 리전 |

---

## 데이터베이스

### Vercel Postgres

```typescript
import { sql } from "@vercel/postgres";

const getUsers = async () => {
  const { rows } = await sql`SELECT * FROM users`;
  return rows;
};
```

### Vercel KV

```typescript
import { kv } from "@vercel/kv";

await kv.set("key", value, { ex: 3600 });
const data = await kv.get("key");
```

### Prisma

```typescript
const globalForPrisma = globalThis as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
```

---

## CI/CD

```yaml
# .github/workflows/vercel.yml
name: Deploy to Vercel

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
          node-version: "20"
      - run: yarn install --frozen-lockfile
      - run: yarn build
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: ${{ github.ref == 'refs/heads/main' && '--prod' || '' }}
```

---

## 문제 해결

| 문제 | 해결 |
|------|------|
| Function Timeout | `maxDuration` 증가 |
| Edge 호환성 오류 | Edge 호환 API 사용 |
| 번들 크기 초과 | externals 설정 |

```bash
vercel dev      # 로컬 시뮬레이션
vercel logs     # 로그 확인
vercel env ls   # 환경 변수 확인
```

---

## 관련 문서

- [배포 가이드](./index.md)
