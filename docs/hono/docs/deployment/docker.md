# Nitro v3 - Docker 배포

> **상위 문서**: [배포 가이드](./index.md)

Docker를 사용하여 Hono + Nitro 애플리케이션을 컨테이너로 배포합니다.

---

## 🚀 Quick Reference (복사용)

```dockerfile
# Dockerfile
FROM node:20-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN corepack enable pnpm && pnpm run build

FROM base AS runner
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 hono
COPY --from=builder --chown=hono:nodejs /app/.output ./.output
USER hono
EXPOSE 3000
ENV PORT=3000 NODE_ENV=production
CMD ["node", ".output/server/index.mjs"]
```

```bash
# 빌드 및 실행
docker build -t my-hono-app .
docker run -p 3000:3000 my-hono-app
```

---

## Nitro 설정

### nitro.config.ts

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Docker 배포용 Nitro 설정
// Node.js 서버로 빌드됩니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // Node.js 서버 preset
  preset: "node",

  // 호환성 날짜
  compatibilityDate: "2024-09-19",

  // 소스 디렉토리
  srcDir: "src",

  // 빌드 출력
  output: {
    dir: ".output",
  },

  // Node.js 설정
  node: {
    // 압축 활성화
    compress: true,
  },
});
```

---

## Dockerfile (상세)

### 멀티스테이지 빌드

```dockerfile
# Dockerfile
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Hono + Nitro 멀티스테이지 Docker 빌드
# 최적화된 프로덕션 이미지 생성
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 1: 베이스 이미지
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:20-alpine AS base

# libc6-compat: 일부 네이티브 모듈 호환성을 위해 필요
RUN apk add --no-cache libc6-compat

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 2: 의존성 설치
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM base AS deps
WORKDIR /app

# 패키지 매니저 파일 복사
COPY package.json pnpm-lock.yaml ./

# pnpm 활성화 및 의존성 설치
RUN corepack enable pnpm && \
    pnpm install --frozen-lockfile --prod=false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 3: 빌드
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM base AS builder
WORKDIR /app

# 의존성 복사
COPY --from=deps /app/node_modules ./node_modules

# 소스 코드 복사
COPY . .

# Nitro 빌드
RUN corepack enable pnpm && \
    pnpm run build && \
    pnpm store prune

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 4: 프로덕션 러너
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM base AS runner
WORKDIR /app

# 보안: 비-root 사용자 생성
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 hono

# 빌드 결과물만 복사 (최소화된 이미지)
COPY --from=builder --chown=hono:nodejs /app/.output ./.output

# 비-root 사용자로 전환
USER hono

# 포트 설정
EXPOSE 3000

# 환경 변수
ENV PORT=3000
ENV NODE_ENV=production
ENV HOST=0.0.0.0

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# 서버 실행
CMD ["node", ".output/server/index.mjs"]
```

---

## .dockerignore

```dockerignore
# .dockerignore
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Docker 빌드 시 제외할 파일
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 의존성
node_modules/

# 빌드 결과물
.output/
dist/

# 환경 파일
.env
.env.*
!.env.example

# Git
.git/
.gitignore

# IDE
.vscode/
.idea/

# 테스트
coverage/
*.test.ts
*.spec.ts
__tests__/

# 문서
*.md
docs/

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# 기타
.DS_Store
*.log
tmp/
```

---

## Docker Compose

### docker-compose.yml

```yaml
# docker-compose.yml
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Hono + Nitro 개발/프로덕션 환경 구성
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

services:
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # Hono 애플리케이션
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # PostgreSQL 데이터베이스
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # Redis 캐시 (선택적)
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

volumes:
  postgres_data:
  redis_data:
```

### 개발용 docker-compose

```yaml
# docker-compose.dev.yml
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 개발 환경 전용 구성
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      # 소스 코드 마운트 (Hot Reload)
      - ./src:/app/src
      - ./nitro.config.ts:/app/nitro.config.ts
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=mydb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### 개발용 Dockerfile

```dockerfile
# Dockerfile.dev
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 개발 환경용 Dockerfile
# Hot Reload 지원
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FROM node:20-alpine

WORKDIR /app

# 패키지 파일 복사
COPY package.json pnpm-lock.yaml ./

# pnpm 설치 및 의존성 설치
RUN corepack enable pnpm && pnpm install

# 소스 코드는 볼륨으로 마운트됨

EXPOSE 3000

# 개발 서버 실행
CMD ["pnpm", "run", "dev"]
```

---

## 빌드 및 실행 명령어

### 기본 명령어

```bash
# 이미지 빌드
docker build -t my-hono-app .

# 컨테이너 실행
docker run -p 3000:3000 my-hono-app

# 환경 변수와 함께 실행
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  -e API_SECRET="my-secret" \
  my-hono-app

# 백그라운드 실행
docker run -d --name hono-app -p 3000:3000 my-hono-app
```

### Docker Compose 명령어

```bash
# 프로덕션 시작
docker compose up -d

# 개발 환경 시작
docker compose -f docker-compose.dev.yml up

# 로그 확인
docker compose logs -f app

# 컨테이너 재빌드
docker compose up -d --build

# 종료
docker compose down

# 볼륨 포함 종료 (데이터 삭제)
docker compose down -v
```

---

## CI/CD 통합

### GitHub Actions

```yaml
# .github/workflows/docker.yml
name: Docker Build & Push

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## 최적화 팁

### 이미지 크기 최소화

```dockerfile
# Alpine 기반 이미지 사용
FROM node:20-alpine

# 불필요한 파일 제외 (.dockerignore 활용)

# 프로덕션 의존성만 설치
RUN pnpm install --prod

# 빌드 결과물만 최종 이미지에 포함
COPY --from=builder /app/.output ./.output
```

### 빌드 캐시 활용

```dockerfile
# 의존성 파일 먼저 복사 (캐시 활용)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# 소스 코드는 나중에 복사
COPY . .
RUN pnpm build
```

### 보안 강화

```dockerfile
# 비-root 사용자 사용
RUN adduser --system --uid 1001 hono
USER hono

# 읽기 전용 파일 시스템
# docker run --read-only my-hono-app

# 취약점 스캔
# docker scan my-hono-app
```

---

## 문제 해결

### 일반적인 문제

| 문제 | 원인 | 해결 |
|------|------|------|
| 포트 연결 실패 | HOST=0.0.0.0 미설정 | `ENV HOST=0.0.0.0` 추가 |
| 빌드 실패 | node_modules 누락 | .dockerignore 확인 |
| 권한 오류 | root 사용자 문제 | 비-root 사용자 사용 |
| 메모리 부족 | 이미지 크기 과다 | 멀티스테이지 빌드 사용 |

### 디버깅

```bash
# 컨테이너 쉘 접속
docker exec -it hono-app sh

# 로그 확인
docker logs -f hono-app

# 리소스 사용량 확인
docker stats hono-app
```

---

## 관련 문서

- [배포 가이드 개요](./index.md)
- [Railway 배포](./railway.md)
- [Vercel 배포](./vercel.md)
- [Cloudflare 배포](./cloudflare.md)
