# Nitro - Cloudflare Deployment

> Cloudflare Workers/Pages Edge deployment

---

## Workers Configuration

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "cloudflare_module",
  compatibilityDate: "2024-09-19",
  cloudflare: {
    deployConfig: true,
    nodeCompat: true,
  },
});
```

---

## Pages Configuration

```typescript
// nitro.config.ts
export default defineNitroConfig({
  preset: "cloudflare_pages",
  compatibilityDate: "2024-09-19",
  cloudflare: {
    deployConfig: true,
    pages: { staticDir: "public" },
  },
});
```

---

## wrangler.toml

```toml
name = "hono-app"
main = ".output/server/index.mjs"
compatibility_date = "2024-09-19"
compatibility_flags = ["nodejs_compat"]

[vars]
NODE_ENV = "production"

[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxx"

[[kv_namespaces]]
binding = "KV"
id = "xxx"

[[r2_buckets]]
binding = "BUCKET"
bucket_name = "my-bucket"
```

---

## Deployment

```bash
wrangler login
yarn build
wrangler deploy

# Pages
wrangler pages deploy .output/public
```

---

## Using Bindings

### D1

```typescript
type Bindings = { DB: D1Database };
const app = new Hono<{ Bindings: Bindings }>();

app.get("/users", async (c) => {
  const { results } = await c.env.DB.prepare("SELECT * FROM users").all();
  return c.json(results);
});

app.post("/users", async (c) => {
  const { name, email } = await c.req.json();
  const result = await c.env.DB.prepare(
    "INSERT INTO users (name, email) VALUES (?, ?)"
  ).bind(name, email).run();
  return c.json({ id: result.meta.last_row_id });
});
```

### KV

```typescript
type Bindings = { KV: KVNamespace };
const app = new Hono<{ Bindings: Bindings }>();

app.get("/cache/:key", async (c) => {
  const value = await c.env.KV.get(c.req.param("key"));
  return value ? c.json(JSON.parse(value)) : c.json({ error: "Not found" }, 404);
});

app.put("/cache/:key", async (c) => {
  const body = await c.req.json();
  await c.env.KV.put(c.req.param("key"), JSON.stringify(body), { expirationTtl: 3600 });
  return c.json({ success: true });
});
```

### R2

```typescript
type Bindings = { BUCKET: R2Bucket };
const app = new Hono<{ Bindings: Bindings }>();

app.post("/upload/:name", async (c) => {
  await c.env.BUCKET.put(c.req.param("name"), await c.req.arrayBuffer());
  return c.json({ success: true });
});

app.get("/download/:name", async (c) => {
  const obj = await c.env.BUCKET.get(c.req.param("name"));
  return obj ? c.body(obj.body) : c.json({ error: "Not found" }, 404);
});
```

---

## Secrets

```bash
wrangler secret put API_SECRET
wrangler secret list
```

---

## D1 Migrations

```bash
wrangler d1 migrations create my-database create_users
wrangler d1 migrations apply my-database
```

```sql
-- migrations/0001_create_users.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL
);
```

---

## CI/CD

```yaml
# .github/workflows/cloudflare.yml
name: Deploy to Cloudflare

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
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Worker size limit | Configure externals, minify |
| D1 not found | Check wrangler.toml bindings |
| Node.js API errors | Add `nodejs_compat` flag |

```bash
wrangler tail          # Real-time logs
wrangler deploy --dry-run  # Validation
```

---

## Related Documentation

- [Deployment Guide](./index.md)
