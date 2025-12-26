# Nitro - Docker 배포

> 컨테이너 배포

---

## nitro.config.ts

```typescript
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "node",
  compatibilityDate: "2024-09-19",
});
```

---

## Dockerfile

```dockerfile
FROM node:20-alpine AS base

FROM base AS deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

FROM base AS runner
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 hono
COPY --from=builder --chown=hono:nodejs /app/.output ./.output
USER hono
EXPOSE 3000
ENV PORT=3000 NODE_ENV=production HOST=0.0.0.0
CMD ["node", ".output/server/index.mjs"]
```

---

## .dockerignore

```dockerignore
node_modules/
.output/
.env
.env.*
!.env.example
.git/
*.test.ts
coverage/
*.md
docs/
```

---

## 빌드 및 실행

```bash
docker build -t my-hono-app .
docker run -p 3000:3000 my-hono-app

# 환경 변수
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://..." \
  my-hono-app
```

---

## Docker Compose

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy

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

volumes:
  postgres_data:
```

```bash
docker compose up -d
docker compose logs -f app
docker compose down
```

---

## 개발용

```yaml
# docker-compose.dev.yml
services:
  app:
    build:
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src
    environment:
      - NODE_ENV=development
```

```dockerfile
# Dockerfile.dev
FROM node:20-alpine
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
EXPOSE 3000
CMD ["yarn", "dev"]
```

---

## CI/CD

```yaml
# .github/workflows/docker.yml
name: Docker Build & Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## 문제 해결

| 문제 | 해결 |
|------|------|
| 포트 연결 실패 | `HOST=0.0.0.0` 설정 |
| 권한 오류 | 비-root 사용자 |
| 메모리 부족 | 멀티스테이지 빌드 |

```bash
docker exec -it hono-app sh
docker logs -f hono-app
docker stats hono-app
```

---

## 관련 문서

- [배포 가이드](./index.md)
