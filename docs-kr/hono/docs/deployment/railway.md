# Nitro - Railway 배포

> PaaS 간편 배포

---

## 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "node",
  compatibilityDate: "2024-09-19",
});
```

```json
// package.json
{
  "scripts": {
    "build": "nitro build",
    "start": "node .output/server/index.mjs"
  },
  "engines": { "node": ">=20.0.0" }
}
```

---

## 배포

### GitHub 연동 (권장)

1. [Railway 대시보드](https://railway.app) → New Project → Deploy from GitHub
2. 자동 빌드/배포 설정

### CLI

```bash
npm install -g @railway/cli
railway login
railway init
railway up

# 환경 변수
railway variables set DATABASE_URL="postgresql://..."
railway logs
```

---

## railway.toml (선택)

```toml
[build]
buildCommand = "yarn install && yarn build"

[deploy]
startCommand = "node .output/server/index.mjs"
healthcheckPath = "/health"
```

---

## 환경 변수

```typescript
app.get("/health", (c) => {
  return c.json({
    status: "ok",
    env: process.env.RAILWAY_ENVIRONMENT,
  });
});
```

| 자동 제공 변수 | 설명 |
|---------------|------|
| `PORT` | 서버 포트 |
| `RAILWAY_ENVIRONMENT` | 환경 |
| `RAILWAY_SERVICE_NAME` | 서비스명 |

---

## 데이터베이스

Railway 대시보드 → New → Database → PostgreSQL/Redis

```typescript
// DATABASE_URL 자동 연결
import { PrismaClient } from "@prisma/client";
export const prisma = new PrismaClient();
```

---

## 도메인

- 자동: `your-app.up.railway.app`
- 커스텀: Settings → Domains → Add Custom Domain

---

## CI/CD

```yaml
# .github/workflows/railway.yml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install -g @railway/cli
      - run: railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## 문제 해결

| 문제 | 해결 |
|------|------|
| 빌드 실패 | `yarn.lock` 커밋 확인 |
| 포트 오류 | `process.env.PORT` 사용 |
| 헬스체크 실패 | `/health` 엔드포인트 추가 |

```bash
railway run yarn dev  # 로컬 시뮬레이션
railway variables     # 환경 변수 확인
railway status        # 상태 확인
```

---

## 관련 문서

- [배포 가이드](./index.md)
