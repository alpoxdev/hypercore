# Crawling Patterns

> Common patterns for rendering model, pagination, authentication, and reliability.

---

<rendering>

## Rendering Model

| Model | Characteristic | Strategy |
|------|------|------|
| **SSR** | Data already in HTML | DOM parsing |
| **CSR** | Data fetched via JS API calls | Direct API calls |

```javascript
// Heuristic check for SSR vs CSR
const html = await page.content();
console.log(html.length > 5000 ? 'Likely SSR' : 'Likely CSR/API-driven');
```

</rendering>

---

<pagination>

## Pagination

### URL-based pagination

```typescript
for (let page = 1; ; page++) {
  const items = await fetch(`${baseUrl}?page=${page}`).then((r) => r.json());
  if (items.length === 0) break;
  allItems.push(...items);
}
```

### Cursor-based pagination

```typescript
let cursor: string | null = null;
do {
  const data = await fetch(cursor ? `${url}?cursor=${cursor}` : url).then((r) => r.json());
  allItems.push(...data.items);
  cursor = data.nextCursor;
} while (cursor);
```

### Infinite scroll

```javascript
for (let i = 0; i < 10; i++) {
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await page.waitForTimeout(1000);
}
```

### Load-more button

```javascript
const btn = page.locator('button:has-text("Load more")');
while (await btn.isVisible()) {
  await btn.click();
  await page.waitForLoadState('networkidle');
}
```

</pagination>

---

<auth>

## Authentication Patterns

### Cookie / session

```typescript
const cookies = await context.cookies();
const cookieHeader = cookies.map((c) => `${c.name}=${c.value}`).join('; ');
```

### Bearer token

```typescript
const token = await page.evaluate(() => localStorage.getItem('token'));
const headers = { Authorization: `Bearer ${token}` };
```

</auth>

---

<dynamic_content>

## Dynamic Content

```javascript
// lazy-loaded image trigger
await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
await page.waitForTimeout(1200);
```

```javascript
// wait for network completion after user action
await page.locator('button:has-text("Apply")').click();
await page.waitForLoadState('networkidle');
```

</dynamic_content>

---

<reliability>

## Reliability Controls

```typescript
// delay / throttling
await new Promise((r) => setTimeout(r, 500 + Math.random() * 1000));
```

```typescript
// simple retry helper
async function retry<T>(fn: () => Promise<T>, max = 3): Promise<T> {
  let lastErr: unknown;
  for (let i = 0; i < max; i++) {
    try {
      return await fn();
    } catch (err) {
      lastErr = err;
      await new Promise((r) => setTimeout(r, (i + 1) * 1000));
    }
  }
  throw lastErr;
}
```

</reliability>
