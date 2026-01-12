# Nitro - Railway Deployment

> Simple PaaS deployment

---

## Configuration

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

## Deployment

### GitHub Integration (Recommended)

1. [Railway Dashboard](https://railway.app) → New Project → Deploy from GitHub
2. Automatic build/deploy setup

### CLI

```bash
npm install -g @railway/cli
railway login
railway init
railway up

# Environment variables
railway variables set DATABASE_URL="postgresql://..."
railway logs
```

---

## railway.toml (Optional)

```toml
[build]
buildCommand = "yarn install && yarn build"

[deploy]
startCommand = "node .output/server/index.mjs"
healthcheckPath = "/health"
```

---

## Environment Variables

```typescript
app.get("/health", (c) => {
  return c.json({
    status: "ok",
    env: process.env.RAILWAY_ENVIRONMENT,
  });
});
```

| Auto-provided Variables | Description |
|------------------------|-------------|
| `PORT` | Server port |
| `RAILWAY_ENVIRONMENT` | Environment |
| `RAILWAY_SERVICE_NAME` | Service name |

---

## Database

Railway Dashboard → New → Database → PostgreSQL/Redis

```typescript
// DATABASE_URL auto-connected
import { PrismaClient } from "@prisma/client";
export const prisma = new PrismaClient();
```

---

## Domains

- Automatic: `your-app.up.railway.app`
- Custom: Settings → Domains → Add Custom Domain

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

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build failure | Verify `yarn.lock` is committed |
| Port error | Use `process.env.PORT` |
| Healthcheck failure | Add `/health` endpoint |

```bash
railway run yarn dev  # Local simulation
railway variables     # Check environment variables
railway status        # Check status
```

---

## Related Documentation

- [Deployment Guide](./index.md)
