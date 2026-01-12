# Nitro v3 Deployment Guide

> Hono + Nitro deployment

@docker.md
@railway.md
@vercel.md
@cloudflare.md

---

## Installation

```bash
npm install nitro@3
```

---

## Basic Configuration

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  preset: "node", // node | cloudflare_module | vercel
  compatibilityDate: "2024-09-19",
  srcDir: "src",
});
```

---

## Entry Point

```typescript
// src/server.ts
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.json({ message: "Hello" }));
app.get("/health", (c) => c.json({ status: "ok" }));

export default app;
```

---

## CLI

```bash
npx nitro dev              # Development server
npx nitro build            # Build
npx nitro preview          # Preview
node .output/server/index.mjs  # Run
```

---

## Preset Selection

| Preset | Usage |
|--------|-------|
| `node` | Node.js server, Docker |
| `cloudflare_module` | Cloudflare Workers |
| `cloudflare_pages` | Cloudflare Pages |
| `vercel` | Vercel Functions |
| `vercel-edge` | Vercel Edge |

---

## Environment Variables

```typescript
// nitro.config.ts
export default defineNitroConfig({
  runtimeConfig: {
    apiSecret: process.env.API_SECRET,
    public: {
      apiBase: process.env.API_BASE_URL || "/api",
    },
  },
});
```

```typescript
// src/server.ts
app.get("/config", (c) => {
  return c.json({
    environment: process.env.NODE_ENV,
    hasDb: !!process.env.DATABASE_URL,
  });
});
```

---

## Project Structure

```
project/
├── nitro.config.ts
├── src/
│   ├── server.ts      # Hono app
│   ├── routes/
│   └── lib/
├── .output/           # Build output
└── package.json
```

---

## Related Documentation

- [Docker](./docker.md)
- [Railway](./railway.md)
- [Vercel](./vercel.md)
- [Cloudflare](./cloudflare.md)
