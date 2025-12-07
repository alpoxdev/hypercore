# Railway 배포

## Quick Reference

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'node',
  compatibilityDate: '2024-09-19',
})
```

```json
// package.json
{
  "scripts": {
    "build": "vite build && tsc --noEmit",
    "start": "node .output/server/index.mjs"
  },
  "engines": { "node": ">=20.0.0" }
}
```

```bash
railway login && railway init && railway up
```

---

## Railway 설정

```json
// railway.json
{
  "build": { "builder": "NIXPACKS", "buildCommand": "yarn install && yarn build" },
  "deploy": {
    "startCommand": "node .output/server/index.mjs",
    "healthcheckPath": "/health",
    "restartPolicyType": "ON_FAILURE"
  }
}
```

---

## 배포 방법

### GitHub 연동 (권장)
1. Railway 대시보드 → "Deploy from GitHub repo"
2. 자동으로 `build`, `start` 스크립트 사용

### CLI
```bash
npm install -g @railway/cli
railway login
railway init
railway up
railway variables set DATABASE_URL="postgresql://..."
```

### Docker
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.output ./.output
ENV PORT=3000 NODE_ENV=production
CMD ["node", ".output/server/index.mjs"]
```

---

## 환경변수

| 변수 | 설명 |
|------|------|
| `PORT` | 서버 포트 (자동) |
| `RAILWAY_ENVIRONMENT` | production/staging |
| `RAILWAY_SERVICE_NAME` | 서비스 이름 |

---

## 데이터베이스

```bash
# Railway 대시보드: New → Database → PostgreSQL/Redis
# DATABASE_URL, REDIS_URL 자동 연결
```

---

## 헬스체크

```typescript
// server/api/health.ts
export default defineHandler(() => ({
  status: 'ok',
  timestamp: new Date().toISOString(),
}))
```

---

## CI/CD

```yaml
# .github/workflows/railway.yml
- run: npm install -g @railway/cli
- run: railway up
  env:
    RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## 모니터링

```bash
railway logs       # 로그 확인
railway logs -f    # 실시간 로그
railway status     # 서비스 상태
railway variables  # 환경변수 확인
```

---

## 트러블슈팅

| 문제 | 해결 |
|------|------|
| 빌드 실패 | `yarn.lock` 커밋 확인 |
| 포트 바인딩 | `process.env.PORT` 사용 |
| 메모리 초과 | 리소스 제한 증가 |
| 헬스체크 실패 | `/health` 엔드포인트 추가 |

```typescript
// ❌ const port = 3000
// ✅ const port = process.env.PORT || 3000
```
