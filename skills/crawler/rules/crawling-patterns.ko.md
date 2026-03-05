# 크롤링 패턴

> 데이터 로딩, 페이지네이션, 인증 패턴

---

<rendering>

## 렌더링 방식

| 방식 | 특징 | 전략 |
|------|------|------|
| **SSR** | HTML에 데이터 포함 | DOM 파싱 |
| **CSR** | JS로 API 호출 | API 직접 호출 |

```javascript
// SSR/CSR 판별
const html = await page.content();
console.log(html.length > 5000 ? 'SSR 가능' : 'CSR');
```

</rendering>

---

<pagination>

## 페이지네이션

### URL 기반

```typescript
for (let page = 1; ; page++) {
  const items = await fetch(`${baseUrl}?page=${page}`).then(r => r.json());
  if (items.length === 0) break;
  allItems.push(...items);
}
```

### 커서 기반

```typescript
let cursor: string | null = null;
do {
  const data = await fetch(cursor ? `${url}?cursor=${cursor}` : url).then(r => r.json());
  allItems.push(...data.items);
  cursor = data.nextCursor;
} while (cursor);
```

### 무한 스크롤

```javascript
// API 인터셉트 후 스크롤
for (let i = 0; i < 10; i++) {
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await page.waitForTimeout(1000);
}
```

### 더보기 버튼

```javascript
const btn = page.locator('button:has-text("더보기")');
while (await btn.isVisible()) {
  await btn.click();
  await page.waitForLoadState('networkidle');
}
```

</pagination>

---

<auth>

## 인증 패턴

### 쿠키/세션

```javascript
const cookies = await context.cookies();
const session = cookies.find(c => c.name === 'session');

await fetch(url, {
  headers: { 'Cookie': `session=${session.value}` }
});
```

### Bearer 토큰

```javascript
const token = await page.evaluate(() => localStorage.getItem('token'));

await fetch(url, {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

</auth>

---

<dynamic>

## 동적 콘텐츠

### Lazy Loading

```javascript
// 스크롤로 이미지 로드
await page.evaluate(async () => {
  for (let y = 0; y < document.body.scrollHeight; y += 500) {
    window.scrollTo(0, y);
    await new Promise(r => setTimeout(r, 200));
  }
});
```

### Shadow DOM

```javascript
const content = await page.evaluate(() => {
  return document.querySelector('custom-element').shadowRoot.innerHTML;
});
```

### iframe

```javascript
const frame = page.frameLocator('#content-frame');
const items = await frame.locator('.item').allTextContents();
```

</dynamic>

---

<rate_limit>

## Rate Limiting

```typescript
// 딜레이 적용
async function rateLimitedFetch(urls: string[], delayMs = 100) {
  const results = [];
  for (const url of urls) {
    results.push(await fetch(url).then(r => r.json()));
    await new Promise(r => setTimeout(r, delayMs));
  }
  return results;
}

// 재시도
async function fetchWithRetry(url: string, retries = 3) {
  for (let i = 0; i < retries; i++) {
    const res = await fetch(url);
    if (res.status === 429) {
      await new Promise(r => setTimeout(r, (parseInt(res.headers.get('Retry-After') || '60')) * 1000));
      continue;
    }
    return res.json();
  }
}
```

</rate_limit>
