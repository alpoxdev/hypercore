# Analysis Document Templates

> Standard output structure for `.hypercore/crawler/[site-name]/`.

---

## Folder Structure

```text
.hypercore/crawler/
├── extract-products.json
└── example-com/
    ├── ANALYSIS.md
    ├── SELECTORS.md
    ├── API.md
    ├── NETWORK.md
    ├── raw/
    │   ├── network-summary.json
    │   ├── auth-signals.json
    │   └── endpoint-candidates.json
    └── CRAWLER.ts
```

---

## ACTION.json

```json
{
  "action": "extract-products",
  "site_name": "example-com",
  "base_url": "https://example.com/items",
  "site_dir": ".hypercore/crawler/example-com",
  "status": "running",
  "capture_mode": "cdp",
  "evidence": {
    "cdp_attached": true,
    "raw_files": [
      "raw/network-summary.json",
      "raw/auth-signals.json",
      "raw/endpoint-candidates.json"
    ]
  },
  "outputs": {
    "analysis": "ANALYSIS.md",
    "api": null,
    "network": null,
    "crawler": null
  },
  "blockers": [],
  "next_step": "write API.md from endpoint-candidates.json"
}
```

---

## ANALYSIS.md

```markdown
# [Site Name] Crawl Analysis

Created: {{TIMESTAMP}}
URL: {{BASE_URL}}

## Page Types

| Type | URL | Notes |
|------|-----|------|
| List | /items | |
| Detail | /items/[id] | |
| Search | /search?q= | |

## Data Loading

- [ ] SSR
- [ ] CSR (API-driven)
- [ ] Infinite scroll
- [ ] Pagination

## Authentication

- [ ] Public
- [ ] Login required
- [ ] API key required

## Findings

[Key constraints, edge cases, warnings]

If the run is blocked, use this section to record the blocker, the evidence that triggered the stop, and the safest next step.

## Capture Path

- CDP available: yes/no
- Fallback browser-network capture used: yes/no
```

---

## SELECTORS.md

```markdown
# [Site Name] Selectors

## List Page

| Element | Selector | Notes |
|------|------|------|
| Container | `.item-list` | |
| Card | `.item-card` | |
| Title | `.item-card h2` | |
| Link | `.item-card a` | |
| Next | `button[aria-label="Next"]` | |

## aria-ref Mapping

| ref | Selector | Meaning |
|------|------|------|
| e14 | `getByRole('button', { name: 'Load more' })` | Load more |
```

---

## API.md

```markdown
# [Site Name] API

## Endpoint Summary

| Method | Endpoint | Purpose |
|------|------|------|
| GET | /api/items | Fetch item list |
| GET | /api/items/:id | Fetch item detail |

## Query Parameters

| Parameter | Type | Description |
|------|------|------|
| page | number | Page index |
| limit | number | Page size |

## Rate Limit / Constraints

[Rate limit, anti-bot checks, auth constraints]

## Evidence Source

- Playwriter flow reproduced: yes/no
- CDP capture attached: yes/no
- Fallback browser-network capture used: yes/no
- Raw artifacts used: yes/no
```

---

## NETWORK.md

```markdown
# [Site Name] Network

## Authentication Data

| Field | Value | Expires |
|------|------|------|
| Cookie | session=... | 24h |
| Bearer Token | ey... | 1h |

## Required Headers

- User-Agent: ...
- Accept-Language: ...
- Referer: ...

## Limits

- Rate limit: 60 req/min
- Delay: 1000ms

## Bot Detection

[Cloudflare, CAPTCHA, behavioral constraints]

## Raw Evidence

- `raw/network-summary.json`
- `raw/auth-signals.json`
- `raw/endpoint-candidates.json`

If the run is blocked or unsafe, record the block signal or auth constraint that prevented `CRAWLER.ts`.
```
