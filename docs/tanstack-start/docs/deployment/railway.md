# Railway 배포

> **상위 문서**: [배포](./index.md)
> **Version**: Nitro 3.x

Railway는 Node.js 서버를 간편하게 배포할 수 있는 플랫폼입니다.

---

## 🚀 Quick Reference (복사용)

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'node',
  compatibilityDate: '2024-09-19',
})
```

```json
// package.json scripts
{
  "scripts": {
    "build": "vite build && tsc --noEmit",
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

## Nitro 설정

### nitro.config.ts

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  // Node.js 서버 preset
  preset: 'node',

  // 호환성 날짜 (Nitro v3 필수)
  compatibilityDate: '2024-09-19',
})
```

---

## Vite 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro(),
    viteReact(),
  ],
})
```

---

## package.json 설정

```json
{
  "name": "tanstack-start-app",
  "type": "module",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build && tsc --noEmit",
    "start": "node .output/server/index.mjs",
    "preview": "vite preview"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

---

## Railway 설정

### railway.json

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "pnpm install && pnpm build"
  },
  "deploy": {
    "startCommand": "node .output/server/index.mjs",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
```

### railway.toml (선택)

```toml
# railway.toml
[build]
builder = "nixpacks"
buildCommand = "pnpm install && pnpm build"

[deploy]
startCommand = "node .output/server/index.mjs"
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3
```

### nixpacks.toml (선택)

```toml
[phases.setup]
nixPkgs = ["nodejs_20"]

[phases.install]
cmds = ["corepack enable pnpm", "pnpm install"]

[phases.build]
cmds = ["pnpm build"]

[start]
cmd = "node .output/server/index.mjs"
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

## 환경변수

### Railway 대시보드에서 설정

```
DATABASE_URL=postgresql://user:pass@host:5432/db
API_SECRET=your-secret-key
NODE_ENV=production
```

### 코드에서 사용

```typescript
// server/api/health.ts
import { defineHandler } from 'nitro/h3'

export default defineHandler(() => {
  return {
    status: 'ok',
    environment: process.env.NODE_ENV,
    // Railway 자동 제공 변수
    railway: {
      environment: process.env.RAILWAY_ENVIRONMENT,
      service: process.env.RAILWAY_SERVICE_NAME,
    },
  }
})
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
// server/lib/db.ts
import { PrismaClient } from '@prisma/client'

// Railway의 DATABASE_URL 자동 사용
export const prisma = new PrismaClient()
```

### Redis 추가

1. Railway 대시보드에서 "New" → "Database" → "Redis" 선택
2. `REDIS_URL` 환경 변수 자동 연결

```typescript
// server/lib/redis.ts
import { createClient } from 'redis'

const client = createClient({
  url: process.env.REDIS_URL,
})

export default client
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

## 헬스체크

### 헬스체크 엔드포인트

```typescript
// server/api/health.ts
import { defineHandler } from 'nitro/h3'

export default defineHandler(() => {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
  }
})
```

### railway.json 헬스체크 설정

```json
{
  "deploy": {
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 300
  }
}
```

---

## CI/CD 설정

### GitHub Actions

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

## 트러블슈팅

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

### 포트 바인딩

Railway는 `PORT` 환경변수를 자동 설정합니다:

```typescript
// ❌ 잘못된 예
const port = 3000

// ✅ 올바른 예
const port = process.env.PORT || 3000
```

### 메모리 설정

```json
// package.json
{
  "scripts": {
    "start": "node --max-old-space-size=512 .output/server/index.mjs"
  }
}
```

---

## 프로젝트 구조

```
my-app/
├── src/
│   └── routes/
├── server/
│   └── api/
├── nitro.config.ts
├── vite.config.ts
├── package.json
└── railway.json
```

---

## 참고 자료

- [TanStack Start Hosting](https://tanstack.com/start/latest/docs/framework/react/hosting)
- [Railway 공식 문서](https://docs.railway.app)
- [Railway CLI](https://docs.railway.app/reference/cli-api)
- [Nitro Node Preset](https://nitro.build/deploy/providers/node)
