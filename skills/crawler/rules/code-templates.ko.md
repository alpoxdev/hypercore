# 크롤러 코드 템플릿

> 분석 결과 기반 자동 생성용

---

## 방식 선택

| 조건 | 방식 | 템플릿 |
|------|------|--------|
| API 발견 + 인증 단순 | fetch | API 크롤러 |
| API + 쿠키/토큰 | fetch + Cookie | API 크롤러 (인증) |
| 봇 탐지 강함 | Nstbrowser | (별도 구현) |
| API 없음 (SSR) | Playwright | DOM 크롤러 |

---

## API 크롤러

```typescript
// CRAWLER.ts - API 기반
interface ApiResponse {
  data: Item[];
  pagination: { page: number; total: number; hasNext: boolean };
}

interface Item {
  id: string;
  title: string;
}

export class ApiCrawler {
  private baseUrl = 'https://example.com/api';
  private headers: Record<string, string> = {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer ...',
    // 'Cookie': '...',
  };

  async fetchPage(page: number, limit = 20): Promise<ApiResponse> {
    const res = await fetch(
      `${this.baseUrl}/items?page=${page}&limit=${limit}`,
      { headers: this.headers }
    );
    if (!res.ok) throw new Error(`API error: ${res.status}`);
    return res.json();
  }

  async crawlAll(): Promise<Item[]> {
    const items: Item[] = [];
    let page = 1;
    let hasNext = true;

    while (hasNext) {
      const res = await this.fetchPage(page);
      items.push(...res.data);
      hasNext = res.pagination.hasNext;
      page++;
      await new Promise(r => setTimeout(r, 100)); // Rate limit
    }
    return items;
  }
}
```

---

## DOM 크롤러 (Playwright)

```typescript
// CRAWLER.ts - DOM 기반
import { chromium, Browser, Page } from 'playwright';

interface Item {
  id: string;
  title: string;
  url: string;
}

export class DomCrawler {
  private browser: Browser | null = null;
  private page: Page | null = null;

  async init(): Promise<void> {
    this.browser = await chromium.launch({ headless: true });
    this.page = await this.browser.newPage();
  }

  async crawlList(url: string): Promise<Item[]> {
    if (!this.page) throw new Error('Not initialized');
    await this.page.goto(url, { waitUntil: 'domcontentloaded' });

    return this.page.$$eval('.item-card', cards =>
      cards.map(card => ({
        id: card.getAttribute('data-id') || '',
        title: card.querySelector('h2')?.textContent?.trim() || '',
        url: card.querySelector('a')?.href || '',
      }))
    );
  }

  async crawlAllPages(baseUrl: string): Promise<Item[]> {
    const items: Item[] = [];
    let page = 1;

    while (true) {
      const result = await this.crawlList(`${baseUrl}?page=${page}`);
      if (result.length === 0) break;
      items.push(...result);
      page++;
    }
    return items;
  }

  async close(): Promise<void> {
    await this.browser?.close();
  }
}
```
