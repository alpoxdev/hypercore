# Crawler Code Templates

> Templates for generating crawler implementations from analysis results.

---

## Method Selection

| Condition | Method | Template |
|------|------|------|
| API discovered via CDP / `chrome-devtools-mcp` + simple auth | `fetch` | API crawler |
| API + cookie/token auth | `fetch` + Cookie | API crawler (authenticated) |
| API + Cloudflare / DataDome / JA3 fingerprinting | **`curl_cffi`** (Chrome impersonation) | Stealth API crawler |
| Strong anti-bot, browser required (Cloudflare Turnstile, DataDome) | **Patchright** or Playwright + **rebrowser-patches** | Stealth DOM crawler |
| Chromium-fingerprint specific detection | **Camoufox** (Firefox stealth) | Stealth DOM crawler |
| No API (SSR pages), no anti-bot | Playwright | DOM crawler |

Use API templates only after CDP / chrome-devtools-mcp / fallback browser-network evidence identifies stable endpoints, auth material, and rate-limit posture. Use stealth templates only after `pre-crawl-checklist.md` confirmed bot detection and `anti-bot-checklist.md` recorded the chosen tool and rationale.

---

## API Crawler Template

```typescript
// CRAWLER.ts - API-based
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
    // 'Cookie': '...'
  };

  async fetchPage(page: number, limit = 20): Promise<ApiResponse> {
    const res = await fetch(`${this.baseUrl}/items?page=${page}&limit=${limit}`, {
      headers: this.headers,
    });
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
      await new Promise((r) => setTimeout(r, 100)); // rate limit guard
    }

    return items;
  }
}
```

---

## DOM Crawler Template (Playwright)

```typescript
// CRAWLER.ts - DOM-based
import { chromium, Browser, Page } from 'playwright';

interface Item {
  id: string;
  title: string;
  url: string;
}

export class DomCrawler {
  private browser: Browser | null = null;
  private page: Page | null = null;

  async init() {
    this.browser = await chromium.launch({ headless: true });
    this.page = await this.browser.newPage();
  }

  async crawlList(url: string): Promise<Item[]> {
    if (!this.page) throw new Error('Crawler not initialized');

    await this.page.goto(url, { waitUntil: 'domcontentloaded' });
    await this.page.waitForSelector('.item-card');

    return this.page.$$eval('.item-card', (cards) =>
      cards.map((card) => {
        const a = card.querySelector('a');
        const h2 = card.querySelector('h2');
        return {
          id: (card as HTMLElement).dataset.id || '',
          title: h2?.textContent?.trim() || '',
          url: (a as HTMLAnchorElement)?.href || '',
        };
      })
    );
  }

  async close() {
    await this.browser?.close();
  }
}
```

---

## Stealth API Crawler Template (`curl_cffi`)

Use when the target inspects TLS/JA3 fingerprints (Cloudflare, DataDome, Akamai). `curl_cffi` impersonates the full Chrome ClientHello, JA3/JA4, cipher suite order, ALPN, and HTTP/2 settings — Node `fetch`/Python `requests` cannot.

```python
# CRAWLER.py - JA3-impersonating fetch
from curl_cffi import requests

class StealthApiCrawler:
    def __init__(self, base_url: str, proxy: str | None = None):
        self.base_url = base_url
        self.session = requests.Session(impersonate="chrome120")  # rotates per request like real Chrome 110+
        if proxy:
            self.session.proxies = {"http": proxy, "https": proxy}  # residential proxy preferred
        self.session.headers.update({
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Referer": base_url,
        })

    def fetch_page(self, page: int, limit: int = 20) -> dict:
        res = self.session.get(f"{self.base_url}/items", params={"page": page, "limit": limit})
        res.raise_for_status()
        return res.json()
```

Notes:
- `impersonate="chrome120"` (or `chrome131`, `firefox133`) selects the TLS/JA3 profile. Match the User-Agent header to the impersonate profile.
- Pair with **residential** proxy rotation; datacenter IPs leak independently of TLS.
- Cookie/token auth still uses the same `Session.cookies` jar.

---

## Stealth DOM Crawler Template (Patchright / rebrowser-patches)

Use when the target requires a real browser AND has Cloudflare / DataDome / Turnstile-grade anti-bot. Vanilla `playwright` and the legacy `playwright-extra` + `stealth-plugin` (unmaintained since Mar 2023) consistently fail current detection.

```typescript
// CRAWLER.ts - Patchright-based stealth DOM crawler
// Install: npm i patchright   (drop-in replacement for playwright)
import { chromium, Browser, Page } from 'patchright';

interface Item { id: string; title: string; url: string; }

export class StealthDomCrawler {
  private browser: Browser | null = null;
  private page: Page | null = null;

  async init(proxy?: string) {
    this.browser = await chromium.launch({
      headless: false, // headed beats most fingerprint checks; use Xvfb in CI
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

    // Behavioral mimicry — see anti-bot-checklist.md
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

Notes:
- For Puppeteer/Playwright in Node without switching to `patchright`, run `npx rebrowser-patches@latest patch` once after install — neutralises the `Runtime.Enable` CDP-detection vector that Cloudflare and DataDome use to flag automation.
- Use `Camoufox` (Firefox-based) when the target specifically fingerprints Chromium.
- Pure browser stealth is **not enough** when JA3 still leaks; either let the real browser do the network round-trip, or move the API path to `curl_cffi` above.
- For Cloudflare Turnstile, click-based solvers work paired with Patchright/Camoufox without an external solver service.

Detection-test smoke targets: `bot.sannysoft.com`, `browserleaks.com`, `pixelscan.net` — always run before scaling.

