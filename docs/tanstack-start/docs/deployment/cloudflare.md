# Cloudflare 배포

## Quick Reference (Workers 직접 통합)

```typescript
// vite.config.ts
import { cloudflare } from '@cloudflare/vite-plugin'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

export default defineConfig({
  plugins: [
    cloudflare({ viteEnvironment: { name: 'ssr' } }),
    tanstackStart(),
    viteReact(),
  ],
})
```

```jsonc
// wrangler.jsonc
{
  "name": "my-app",
  "compatibility_date": "2024-09-19",
  "compatibility_flags": ["nodejs_compat"],
  "main": "@tanstack/react-start/server-entry"
}
```

```bash
yarn add -D @cloudflare/vite-plugin wrangler
yarn build && wrangler deploy
```

---

## 배포 옵션

| 옵션 | 방식 | 권장 |
|------|------|------|
| Workers | 직접 통합 | ✅ |
| Pages | Nitro `cloudflare_pages` | - |

---

## Pages (Nitro)

```typescript
// nitro.config.ts
export default defineNitroConfig({
  preset: 'cloudflare_pages',
  compatibilityDate: '2024-09-19',
  cloudflare: { deployConfig: true, nodeCompat: true },
})
```

```bash
yarn build
wrangler pages deploy .output/public
```

---

## Wrangler 설정

```jsonc
// wrangler.jsonc (Workers)
{
  "name": "my-app",
  "compatibility_date": "2024-09-19",
  "compatibility_flags": ["nodejs_compat"],
  "main": "@tanstack/react-start/server-entry",
  "vars": { "MY_VAR": "value" },
  "kv_namespaces": [{ "binding": "MY_KV", "id": "kv-id" }],
  "d1_databases": [{ "binding": "DB", "database_name": "my-db", "database_id": "db-id" }]
}
```

---

## KV / D1 사용

```typescript
// server/api/example.ts
export default defineHandler(async (event) => {
  const env = event.context.cloudflare.env
  const value = await env.MY_KV.get('key')
  await env.MY_KV.put('key', 'value')
  const results = await env.DB.prepare('SELECT * FROM users').all()
  return { value, results }
})
```

---

## 환경변수

```bash
# .dev.vars (로컬)
DATABASE_URL=your-local-url

# 프로덕션 시크릿
wrangler secret put API_SECRET
```

---

## CI/CD

```yaml
# .github/workflows/cloudflare.yml
- uses: cloudflare/wrangler-action@v3
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    command: deploy
```

---

## 트러블슈팅

```typescript
// nitro.config.ts - Node.js 호환성
cloudflare: { nodeCompat: true }

// 번들 최적화
externals: ['@prisma/client']
minify: true
```

```bash
wrangler tail  # 실시간 로그
```
