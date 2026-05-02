# 크롤러 코드 템플릿

> 분석 결과 기반 자동 생성용

---

## 방식 선택

| 조건 | 방식 | 템플릿 |
|------|------|--------|
| CDP / `chrome-devtools-mcp`로 API 발견 + 인증 단순 | `fetch` | API 크롤러 |
| API + 쿠키/토큰 인증 | `fetch` + Cookie | API 크롤러 (인증) |
| API + Cloudflare / DataDome / JA3 지문 | **`curl_cffi`** (Chrome 임퍼소네이트) | Stealth API 크롤러 |
| 브라우저 필요 + 강한 anti-bot (Cloudflare Turnstile, DataDome) | **Patchright** 또는 Playwright + **rebrowser-patches** | Stealth DOM 크롤러 |
| Chromium 한정 지문 검사 | **Camoufox** (Firefox stealth) | Stealth DOM 크롤러 |
| API 없음 (SSR), anti-bot 없음 | Playwright | DOM 크롤러 |

CDP / chrome-devtools-mcp / fallback 네트워크 근거로 안정적인 endpoint, 인증 재료, rate-limit 대응이 확인된 뒤에만 API 템플릿을 사용합니다. stealth 템플릿은 `pre-crawl-checklist.md`로 봇 탐지가 확인되고 `anti-bot-checklist.md`에 선택 도구와 사유가 기록된 뒤에만 사용합니다.

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

---

## Stealth API 크롤러 (`curl_cffi`)

대상이 TLS/JA3 지문을 검사할 때(Cloudflare, DataDome, Akamai) 사용합니다. `curl_cffi`는 Chrome ClientHello / JA3·JA4 / cipher suite 순서 / ALPN / HTTP/2 설정을 그대로 흉내냅니다 — Node `fetch`나 Python `requests`는 흉내내지 못합니다.

```python
# CRAWLER.py - JA3 임퍼소네이트 fetch
from curl_cffi import requests

class StealthApiCrawler:
    def __init__(self, base_url: str, proxy: str | None = None):
        self.base_url = base_url
        self.session = requests.Session(impersonate="chrome120")  # Chrome 110+처럼 요청마다 회전
        if proxy:
            self.session.proxies = {"http": proxy, "https": proxy}  # residential proxy 권장
        self.session.headers.update({
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Referer": base_url,
        })

    def fetch_page(self, page: int, limit: int = 20) -> dict:
        res = self.session.get(f"{self.base_url}/items", params={"page": page, "limit": limit})
        res.raise_for_status()
        return res.json()
```

비고:
- `impersonate="chrome120"` (또는 `chrome131`, `firefox133`)이 TLS/JA3 프로필을 결정합니다. User-Agent와 일치시킵니다.
- **residential** proxy 회전과 함께 사용하세요. datacenter IP는 TLS와 별개로 누수됩니다.
- 쿠키/토큰 인증은 같은 `Session.cookies` 잼을 그대로 사용합니다.

---

## Stealth DOM 크롤러 (Patchright / rebrowser-patches)

브라우저가 반드시 필요하고 Cloudflare / DataDome / Turnstile 수준의 anti-bot이 있을 때 사용합니다. 일반 `playwright`와 레거시 `playwright-extra` + `stealth-plugin` (2023.3 이후 사실상 미관리)은 현재 탐지를 통과하지 못합니다.

```typescript
// CRAWLER.ts - Patchright 기반 stealth DOM 크롤러
// 설치: npm i patchright   (playwright drop-in 대체)
import { chromium, Browser, Page } from 'patchright';

interface Item { id: string; title: string; url: string; }

export class StealthDomCrawler {
  private browser: Browser | null = null;
  private page: Page | null = null;

  async init(proxy?: string) {
    this.browser = await chromium.launch({
      headless: false, // 헤드드 모드가 대부분의 지문 검사를 통과합니다. CI에선 Xvfb 사용
      proxy: proxy ? { server: proxy } : undefined,
      args: ['--disable-blink-features=AutomationControlled'],
    });
    const context = await this.browser.newContext({
      userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
      locale: 'ko-KR',
      viewport: { width: 1440, height: 900 },
    });
    this.page = await context.newPage();
  }

  async crawlList(url: string): Promise<Item[]> {
    if (!this.page) throw new Error('Crawler not initialized');
    await this.page.goto(url, { waitUntil: 'domcontentloaded' });

    // 행동 모방 — anti-bot-checklist.md 참고
    await this.page.mouse.move(200, 200, { steps: 10 });
    await this.page.waitForTimeout(800 + Math.floor(Math.random() * 1200));
    await this.page.evaluate(() => window.scrollBy({ top: 400, behavior: 'smooth' }));

    return this.page.$$eval('.item-card', (cards) =>
      cards.map((card) => ({
        id: (card as HTMLElement).dataset.id ?? '',
        title: card.querySelector('h2')?.textContent?.trim() ?? '',
        url: (card.querySelector('a') as HTMLAnchorElement | null)?.href ?? '',
      }))
    );
  }

  async close() { await this.browser?.close(); }
}
```

비고:
- `patchright`로 교체하지 않고 일반 Puppeteer/Playwright를 쓸 거라면, 설치 후 `npx rebrowser-patches@latest patch`를 한 번 실행합니다 — Cloudflare/DataDome가 자동화 탐지에 사용하는 `Runtime.Enable` CDP 경로를 차단합니다.
- 대상이 Chromium 자체를 지문 검사하면 `Camoufox` (Firefox 기반)를 사용합니다.
- 브라우저 stealth만으로는 부족합니다 — JA3가 누수되면 무력해집니다. 실제 브라우저로 네트워크 라운드트립을 하거나, API 경로를 위의 `curl_cffi`로 옮기세요.
- Cloudflare Turnstile은 Patchright/Camoufox + 자동 클릭으로 외부 solver 서비스 없이 통과되는 경우가 많습니다.

탐지 테스트 smoke 대상: `bot.sannysoft.com`, `browserleaks.com`, `pixelscan.net` — 확장 전에 항상 실행합니다.
