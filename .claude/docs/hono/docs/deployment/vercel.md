# Nitro - Vercel Deployment

> Serverless deployment

---

## Configuration

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

## Deployment

### GitHub Integration (Recommended)

1. [Vercel Dashboard](https://vercel.com) → Add New → Project
2. Build Command: `yarn build`
3. Output Directory: `.vercel/output`

### CLI

```bash
npm install -g vercel
vercel login
vercel          # Preview
vercel --prod   # Production

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

## ISR (Caching)

```typescript
app.get("/posts", async (c) => {
  c.header("Cache-Control", "s-maxage=60, stale-while-revalidate");
  return c.json(await fetchPosts());
});

app.get("/user/:id", async (c) => {
  c.header("Cache-Control", "no-store"); // No cache
  return c.json(await fetchUser(c.req.param("id")));
});
```

---

## Environment Variables

```typescript
app.get("/config", (c) => {
  return c.json({
    env: process.env.VERCEL_ENV,      // production, preview
    region: process.env.VERCEL_REGION,
  });
});
```

| Auto-provided Variables | Description |
|------------------------|-------------|
| `VERCEL` | Vercel environment ("1") |
| `VERCEL_ENV` | Environment |
| `VERCEL_URL` | Deployment URL |
| `VERCEL_REGION` | Execution region |

---

## Database

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

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Function Timeout | Increase `maxDuration` |
| Edge compatibility errors | Use Edge-compatible APIs |
| Bundle size exceeded | Configure externals |

```bash
vercel dev      # Local simulation
vercel logs     # Check logs
vercel env ls   # Check environment variables
```

---

## Related Documentation

- [Deployment Guide](./index.md)
