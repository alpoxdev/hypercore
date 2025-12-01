# Nitro v3 - Railway 배포

> **상위 문서**: [배포 가이드](./index.md)

Railway를 사용하여 Hono + Nitro 애플리케이션을 간편하게 배포합니다.

---

## 🚀 Quick Reference (복사용)

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "node",
  compatibilityDate: "2024-09-19",
});
```

```json
// package.json scripts
{
  "scripts": {
    "build": "nitro build",
    "start": "node .output/server/index.mjs"
  }
}
```

```bash
# Railway CLI 배포
railway login
railway init
railway up
```

---

## Railway 설정

### 1. Nitro 설정

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Railway 배포용 Nitro 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // Node.js 서버 preset
  preset: "node",

  // 호환성 날짜
  compatibilityDate: "2024-09-19",

  // Railway는 PORT 환경 변수 자동 제공
  // 별도 설정 불필요
});
```

### 2. package.json 설정

```json
{
  "name": "hono-nitro-app",
  "type": "module",
  "scripts": {
    "dev": "nitro dev",
    "build": "nitro build",
    "start": "node .output/server/index.mjs",
    "preview": "nitro preview"
  },
  "dependencies": {
    "hono": "^4.0.0",
    "nitro": "^3.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

---

## 배포 방법

### 방법 1: GitHub 연동 (권장)

1. **Railway 프로젝트 생성**
   - [Railway 대시보드](https://railway.app) 접속
   - "New Project" → "Deploy from GitHub repo" 선택
   - 저장소 연결

2. **자동 감지**
   - Railway가 자동으로 Node.js 프로젝트 감지
   - `package.json`의 `build`, `start` 스크립트 사용

3. **환경 변수 설정**
   - Railway 대시보드에서 Variables 탭 선택
   - 필요한 환경 변수 추가

### 방법 2: Railway CLI

```bash
# Railway CLI 설치
npm install -g @railway/cli

# 로그인
railway login

# 프로젝트 초기화
railway init

# 배포
railway up

# 환경 변수 설정
railway variables set DATABASE_URL="postgresql://..."
railway variables set API_SECRET="your-secret"

# 로그 확인
railway logs
```

### 방법 3: Docker 배포

Railway는 Dockerfile을 자동으로 감지합니다.

```dockerfile
# Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install
COPY . .
RUN pnpm build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.output ./.output
ENV PORT=3000 NODE_ENV=production
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
```

---

## railway.toml 설정 (선택)

```toml
# railway.toml
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Railway 배포 설정 (선택적)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[build]
# 빌드 명령어
builder = "nixpacks"
buildCommand = "pnpm install && pnpm build"

[deploy]
# 시작 명령어
startCommand = "node .output/server/index.mjs"

# 헬스체크
healthcheckPath = "/health"
healthcheckTimeout = 300

# 재시작 정책
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3
```

---

## 환경 변수

### Railway 대시보드에서 설정

```
DATABASE_URL=postgresql://user:pass@host:5432/db
API_SECRET=your-secret-key
NODE_ENV=production
```

### 코드에서 사용

```typescript
// src/server.ts
import { Hono } from "hono";

const app = new Hono();

app.get("/health", (c) => {
  return c.json({
    status: "ok",
    environment: process.env.NODE_ENV,
    // Railway 자동 제공 변수
    railway: {
      environment: process.env.RAILWAY_ENVIRONMENT,
      service: process.env.RAILWAY_SERVICE_NAME,
    },
  });
});

export default app;
```

### Railway 자동 제공 변수

| 변수 | 설명 |
|------|------|
| `PORT` | 서버 포트 (자동 할당) |
| `RAILWAY_ENVIRONMENT` | 환경 (production, staging 등) |
| `RAILWAY_SERVICE_NAME` | 서비스 이름 |
| `RAILWAY_PROJECT_ID` | 프로젝트 ID |
| `RAILWAY_DEPLOYMENT_ID` | 배포 ID |

---

## 데이터베이스 연동

### PostgreSQL 추가

1. Railway 대시보드에서 "New" → "Database" → "PostgreSQL" 선택
2. 자동으로 `DATABASE_URL` 환경 변수 연결

```typescript
// src/lib/db.ts
import { PrismaClient } from "@prisma/client";

// Railway의 DATABASE_URL 자동 사용
export const prisma = new PrismaClient();
```

### Redis 추가

1. Railway 대시보드에서 "New" → "Database" → "Redis" 선택
2. `REDIS_URL` 환경 변수 자동 연결

```typescript
// src/lib/redis.ts
import { createClient } from "redis";

const client = createClient({
  url: process.env.REDIS_URL,
});

export default client;
```

---

## 도메인 설정

### 자동 도메인

Railway는 자동으로 도메인을 생성합니다:
- `your-app-production.up.railway.app`

### 커스텀 도메인

1. Railway 대시보드 → Settings → Domains
2. "Add Custom Domain" 클릭
3. DNS 설정:
   ```
   CNAME your-domain.com → your-app-production.up.railway.app
   ```

---

## CI/CD 설정

### GitHub Actions 연동

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

      - name: Install Railway CLI
        run: npm install -g @railway/cli

      - name: Deploy
        run: railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

### 환경별 배포

```yaml
# .github/workflows/railway-env.yml
name: Deploy to Railway (Multi-Environment)

on:
  push:
    branches:
      - main
      - staging

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Railway CLI
        run: npm install -g @railway/cli

      - name: Deploy to Production
        if: github.ref == 'refs/heads/main'
        run: railway up --environment production
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}

      - name: Deploy to Staging
        if: github.ref == 'refs/heads/staging'
        run: railway up --environment staging
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## 모니터링

### 로그 확인

```bash
# CLI로 로그 확인
railway logs

# 실시간 로그
railway logs -f

# 특정 서비스 로그
railway logs --service my-service
```

### 메트릭 확인

Railway 대시보드에서 확인 가능:
- CPU 사용량
- 메모리 사용량
- 네트워크 트래픽
- 요청 수

---

## 비용 최적화

### Hobby Plan 활용

```toml
# railway.toml
[deploy]
# 유휴 시 슬립 (Hobby Plan)
sleepAfterInactivity = 300  # 5분 후 슬립
```

### 리소스 제한

Railway 대시보드에서 설정:
- Memory Limit: 512MB (시작점)
- Replicas: 1 (시작점)

---

## 문제 해결

### 일반적인 문제

| 문제 | 원인 | 해결 |
|------|------|------|
| 빌드 실패 | 의존성 오류 | `pnpm-lock.yaml` 커밋 확인 |
| 포트 바인딩 실패 | 하드코딩된 포트 | `process.env.PORT` 사용 |
| 메모리 초과 | 메모리 누수 | 리소스 제한 증가 또는 코드 최적화 |
| 헬스체크 실패 | 엔드포인트 없음 | `/health` 엔드포인트 추가 |

### 디버깅

```bash
# 로컬에서 Railway 환경 시뮬레이션
railway run pnpm dev

# 환경 변수 확인
railway variables

# 서비스 상태 확인
railway status
```

---

## 관련 문서

- [배포 가이드 개요](./index.md)
- [Docker 배포](./docker.md)
- [Vercel 배포](./vercel.md)
- [Cloudflare 배포](./cloudflare.md)
- [Railway 공식 문서](https://docs.railway.app)
