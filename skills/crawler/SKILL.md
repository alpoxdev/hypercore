---
name: crawler
description: Investigate websites with Playwriter to choose a crawl strategy, capture API/auth evidence, document findings under `.hypercore/crawler/[site]/`, and generate crawler code only after discovery is grounded.
---


# Crawler Skill

> Playwriter exploration -> API/Network analysis -> Documentation -> Code generation

Use `crawler` when the user wants a reusable crawling flow, site extraction plan, API reverse engineering for crawling, or analysis-backed crawler code.

Do not use `crawler` for generic browser automation, one-off page clicking, or document rewriting with no crawl deliverable.

For quick one-off extraction with no reusable crawler, keep the work lightweight and avoid forcing the full artifact set unless the request expands into crawl design.

**Templates:** [document-templates.md](rules/document-templates.md) · [code-templates.md](rules/code-templates.md)
**Checklists:** [pre-crawl-checklist.md](rules/pre-crawl-checklist.md) · [anti-bot-checklist.md](rules/anti-bot-checklist.md)
**References:** [playwriter-commands.md](rules/playwriter-commands.md) · [crawling-patterns.md](rules/crawling-patterns.md) · [selector-strategies.md](rules/selector-strategies.md) · [network-crawling.md](rules/network-crawling.md)

---

<trigger_examples>

Positive examples:

- "Scrape product cards from this shop, inspect the API first, then generate a crawler."
- "Figure out how this logged-in dashboard loads data and document the cookies and headers."
- "Analyze this Cloudflare-protected site and recommend the safest crawl approach."

Negative examples:

- "Open this site and click through the signup flow."
- "Rewrite this crawl runbook for readability."

Boundary example:

- "Grab three prices from this public page right now." Prefer lightweight extraction unless the user asks for a reusable crawler or site-wide strategy.

</trigger_examples>

---

<trigger_conditions>

| Trigger | Action |
|--------|------|
| Reusable crawling, scraping, or site-wide extraction | Run immediately |
| Site investigation or API reverse engineering for crawling | Start discovery and API interception |
| One-off extraction from a single page | Treat as a boundary case and keep the workflow lightweight unless reusable crawl work is requested |
| Anti-bot bypass or Cloudflare-heavy target | Start with risk checks and Anti-Detect guidance |

</trigger_conditions>

---

<support_file_routing>

Read support files in this order:

1. Start with [pre-crawl-checklist.md](rules/pre-crawl-checklist.md) before making crawl or code decisions.
2. Use [playwriter-commands.md](rules/playwriter-commands.md) when you need session control, inspection, or interception commands.
3. Use [network-crawling.md](rules/network-crawling.md) when cookies, tokens, headers, or bot-detection signals matter.
4. Use [selector-strategies.md](rules/selector-strategies.md) when DOM extraction is still on the table.
5. Use [crawling-patterns.md](rules/crawling-patterns.md) when pagination, authentication, lazy loading, or retries shape the approach.
6. Use [anti-bot-checklist.md](rules/anti-bot-checklist.md) when the target shows blocks, CAPTCHA, Cloudflare, or explicit anti-detect requirements.
7. Use [document-templates.md](rules/document-templates.md) when writing `.hypercore/crawler/[site]/` artifacts.
8. Use [code-templates.md](rules/code-templates.md) only after the method is chosen and the discovery evidence is documented.

</support_file_routing>

---

<mandatory_reasoning>

## Mandatory Sequential Thinking

- Always use the `sequential-thinking` tool before starting crawl design, extraction strategy, or code generation decisions.
- Run `sequential-thinking` for each major phase: discovery, method selection, and implementation planning.
- If `sequential-thinking` is unavailable, stop and report the blocker instead of continuing without structured reasoning.

</mandatory_reasoning>

---

<execution_defaults>

- Do discovery before code generation, selector lock-in, or auth assumptions.
- Prefer an API-backed crawler when discovery shows a stable endpoint and manageable auth.
- Stop and report blockers when legal constraints, repeated `403/429/503`, CAPTCHA, or strong anti-bot signals make automation unsafe.
- Do not promise `CRAWLER.ts` until the method, auth material, and rate-limit posture are documented.

</execution_defaults>

---

<workflow>

| Phase | Task | Command/Method |
|-------|------|--------|
| **1. Session** | Create session + open page | `playwriter session new` |
| **2. Explore** | Understand structure | `accessibilitySnapshot`, `screenshotWithAccessibilityLabels` |
| **3. Analyze** | Intercept API, extract selectors | `page.on('response')`, `getLocatorStringForElement` |
| **4. Document** | Save findings under `.hypercore/crawler/[site]/` | Write |
| **5. Code** | Generate crawler implementation | [code-templates.md](rules/code-templates.md) |

</workflow>

---

<method_selection>

| Condition | Method | Notes |
|------|------|------|
| API found + simple auth | **fetch** | Fastest |
| API + cookie/token required | **fetch + Cookie** | Requires expiry handling |
| Strong bot detection | **Nstbrowser** | Anti-Detect |
| No API (SSR) | **Playwright DOM** | Parse directly |

</method_selection>

---

<output_structure>

```
.hypercore/crawler/[site-name]/
├── ANALYSIS.md      # Site structure
├── SELECTORS.md     # DOM selectors
├── API.md           # API endpoints
├── NETWORK.md       # Auth/network details
└── CRAWLER.ts       # Generated crawler code
```

Minimum artifact contract:

- `ANALYSIS.md` is always required for reusable crawl work.
- `SELECTORS.md` is required when DOM extraction is used or kept as a fallback path.
- `API.md` is required when API discovery was attempted; document discovered endpoints or the absence of a usable API.
- `NETWORK.md` is required when cookies, tokens, headers, rate limits, or bot-detection signals affect the method.
- `CRAWLER.ts` is required only after discovery evidence is written and the chosen method is justified.

Starter commands and inspection snippets live in [playwriter-commands.md](rules/playwriter-commands.md). Keep the core focused on method choice, output gates, and stop conditions.

**Templates:** [document-templates.md](rules/document-templates.md)

</output_structure>

---

<blocked_outcomes>

For blocked or unsafe runs:

- write `ANALYSIS.md` with the blocker, the evidence that triggered the stop, and the safest next step
- write `NETWORK.md` when auth signals, block responses, or anti-bot findings affected the decision
- omit `CRAWLER.ts` until the blocker is resolved or the method becomes safe to automate

</blocked_outcomes>

---

<validation>

```text
✅ Playwriter session created
✅ Structure analyzed with accessibilitySnapshot
✅ API interception attempted
✅ Selector extraction validated
✅ Findings documented under .hypercore/crawler/
✅ Crawler code generated
✅ sequential-thinking trace recorded for major phases
✅ legal, rate-limit, and bot-detection blockers documented before scaling
✅ blocked runs reported explicitly when crawler code is unsafe or premature
```

</validation>

---

<forbidden>

| Category | Forbidden |
|------|------|
| **Analysis** | Guess selectors without structure analysis |
| **Approach** | Use DOM-only flow without checking APIs |
| **Documentation** | Skip documenting analysis results |
| **Network** | Ignore rate limiting |

</forbidden>

---

<example>

```bash
# User: /crawler crawl products from https://shop.example.com

# 1. Session
playwriter session new  # => 1
playwriter -s 1 -e "state.page = await context.newPage(); await state.page.goto('https://shop.example.com/products')"

# 2. Structure analysis
playwriter -s 1 -e "console.log(await accessibilitySnapshot({ page: state.page }))"
# => list "Products" [ref=e5]: listitem [ref=e6]: link "Product A" [ref=e7]

# 3. API detection (scroll trigger)
playwriter -s 1 -e "await state.page.evaluate(() => window.scrollTo(0, 9999))"
playwriter -s 1 -e "console.log(state.responses.map(r => r.url))"
# => ["/api/products?page=2"]

# 4. Documentation -> .hypercore/crawler/shop-example-com/
# 5. Generate API-based crawler
```

</example>
