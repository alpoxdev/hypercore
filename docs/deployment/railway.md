# Railway 배포

> **상위 문서**: [배포](./index.md)

Railway는 Node.js 서버를 간편하게 배포할 수 있는 플랫폼입니다.

## 빠른 시작

### 1. Nitro 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'node-server',
})
```

### 2. Vite 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro(),
    react(),
  ],
})
```

### 3. 빌드 스크립트

```json
// package.json
{
  "scripts": {
    "build": "vite build",
    "start": "node .output/server/index.mjs"
  }
}
```

## Railway 설정

### railway.json

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "yarn install && yarn build"
  },
  "deploy": {
    "startCommand": "node .output/server/index.mjs",
    "healthcheckPath": "/",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### nixpacks.toml (선택사항)

```toml
[phases.setup]
nixPkgs = ["nodejs_20"]

[phases.install]
cmds = ["yarn install"]

[phases.build]
cmds = ["yarn build"]

[start]
cmd = "node .output/server/index.mjs"
```

## 환경변수

### Railway 대시보드에서 설정

1. Railway 대시보드 → 프로젝트 선택
2. Variables 탭 클릭
3. 환경변수 추가:
   - `NODE_ENV=production`
   - `DATABASE_URL=...`
   - `API_SECRET=...`

### Railway CLI 사용

```bash
# Railway CLI 설치
npm install -g @railway/cli

# 로그인
railway login

# 환경변수 설정
railway variables set DATABASE_URL=postgresql://...
railway variables set API_SECRET=your-secret

# 환경변수 확인
railway variables
```

## 데이터베이스 연결

### PostgreSQL

Railway에서 PostgreSQL 서비스 추가 후:

```bash
# 자동 생성된 환경변수 사용
DATABASE_URL=${{ Postgres.DATABASE_URL }}
```

### Prisma와 함께 사용

```typescript
// server/db.ts
import { PrismaClient } from './generated/prisma'

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
})

export default prisma
```

## 포트 설정

Railway는 `PORT` 환경변수를 자동 제공합니다:

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'node-server',
  // Railway의 PORT 환경변수 사용
})
```

서버 코드에서:

```typescript
// .output/server/index.mjs (자동 생성됨)
// Nitro가 자동으로 PORT 환경변수를 사용
```

## 배포 방법

### GitHub 연동 (권장)

1. Railway 대시보드에서 "New Project" 클릭
2. "Deploy from GitHub repo" 선택
3. 저장소 선택 및 연결
4. 자동 배포 설정 완료

### Railway CLI

```bash
# 프로젝트 초기화
railway init

# 배포
railway up

# 로그 확인
railway logs
```

## 커스텀 도메인

### Railway 대시보드에서

1. 프로젝트 Settings 탭
2. Domains 섹션
3. "Generate Domain" 또는 "Custom Domain" 추가

### CLI 사용

```bash
# 도메인 추가
railway domain add example.com

# 도메인 확인
railway domain
```

## 헬스체크

### 기본 헬스체크 엔드포인트

```typescript
// server/api/health.ts
import { defineHandler } from 'nitro/h3'

export default defineHandler(() => {
  return { status: 'ok', timestamp: new Date().toISOString() }
})
```

### railway.json 헬스체크 설정

```json
{
  "deploy": {
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 100
  }
}
```

## 스케일링

### 수평 스케일링

Railway 대시보드에서:
1. Settings → Scaling
2. 인스턴스 수 조정

### 리소스 설정

```json
// railway.json
{
  "deploy": {
    "numReplicas": 2
  }
}
```

## 로깅 및 모니터링

### 로그 확인

```bash
# 실시간 로그
railway logs -f

# 최근 로그
railway logs --lines 100
```

### 메트릭 확인

Railway 대시보드에서:
- CPU 사용량
- 메모리 사용량
- 네트워크 트래픽
- 요청 수

## CI/CD 설정

### GitHub Actions

```yaml
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

### Railway 토큰 생성

1. Railway 대시보드 → Account Settings
2. Tokens 섹션에서 새 토큰 생성
3. GitHub Secrets에 `RAILWAY_TOKEN`으로 저장

## 트러블슈팅

### 빌드 실패

```bash
# 로컬에서 빌드 테스트
NITRO_PRESET=node-server yarn build

# 시작 명령 테스트
node .output/server/index.mjs
```

### 포트 바인딩 오류

Railway는 `PORT` 환경변수를 자동 설정합니다. 하드코딩된 포트가 없는지 확인:

```typescript
// ❌ 잘못된 예
const port = 3000

// ✅ 올바른 예
const port = process.env.PORT || 3000
```

### 메모리 초과

```json
// railway.json
{
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

Node.js 메모리 제한 설정:

```json
// package.json
{
  "scripts": {
    "start": "node --max-old-space-size=512 .output/server/index.mjs"
  }
}
```

## 프로젝트 구조

```
my-app/
├── app/
│   └── routes/
├── server/
│   └── api/
├── nitro.config.ts
├── vite.config.ts
├── package.json
└── railway.json
```

## 참고 자료

- [Railway 공식 문서](https://docs.railway.app)
- [Railway CLI](https://docs.railway.app/reference/cli-api)
- [Nitro Node Server Preset](https://nitro.build/deploy/providers/node)
