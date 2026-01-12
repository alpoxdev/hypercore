# Nitro - Docker Deployment

> Container deployment

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

## Build and Run

```bash
docker build -t my-hono-app .
docker run -p 3000:3000 my-hono-app

# Environment variables
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

## Development

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

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port connection failed | Set `HOST=0.0.0.0` |
| Permission errors | Use non-root user |
| Out of memory | Use multi-stage build |

```bash
docker exec -it hono-app sh
docker logs -f hono-app
docker stats hono-app
```

---

## Related Documentation

- [Deployment Guide](./index.md)
