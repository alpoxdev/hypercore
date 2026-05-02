---
name: crawler
description: "[Hyper] Investigate websites with Playwriter plus CDP to choose a crawl strategy, capture API/auth evidence, document findings under `.hypercore/crawler/[site]/`, and generate crawler code only after discovery is grounded."
---


# Crawler Skill

> Playwriter exploration -> CDP evidence capture -> Documentation -> Code generation

Use `crawler` when the user wants a reusable crawling flow, site extraction plan, API reverse engineering for crawling, or analysis-backed crawler code.

For resumable or multi-step crawl work, treat `.hypercore/crawler/<ACTION>.json` as the durable context file that preserves intent, current state, evidence pointers, and the next step.

Do not use `crawler` for generic browser automation, one-off page clicking, or document rewriting with no crawl deliverable.

For quick one-off extraction with no reusable crawler, keep the work lightweight and avoid forcing the full artifact set unless the request expands into crawl design.

**Templates:** [document-templates.md](rules/document-templates.md) · [code-templates.md](rules/code-templates.md)
**Checklists:** [pre-crawl-checklist.md](rules/pre-crawl-checklist.md) · [anti-bot-checklist.md](rules/anti-bot-checklist.md)
**References:** [playwriter-commands.md](rules/playwriter-commands.md) · [chrome-devtools-mcp.md](rules/chrome-devtools-mcp.md) · [cdp-capture.md](rules/cdp-capture.md) · [crawling-patterns.md](rules/crawling-patterns.md) · [selector-strategies.md](rules/selector-strategies.md) · [network-crawling.md](rules/network-crawling.md) · [action-manifest.md](rules/action-manifest.md)

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
2. Use [playwriter-commands.md](rules/playwriter-commands.md) when you need session control, page interaction, visual inspection, or selector validation (Playwright MCP = **driving**).
3. Use [chrome-devtools-mcp.md](rules/chrome-devtools-mcp.md) when you need first-party Chrome DevTools fidelity for live network requests, console errors, performance traces, Lighthouse audits, or memory snapshots (Chrome DevTools MCP = **debugging**).
4. Use [cdp-capture.md](rules/cdp-capture.md) when you need structured network, cookie, token, storage, or rate-limit evidence with lower token cost than full Playwriter snapshots.
5. Use [network-crawling.md](rules/network-crawling.md) when turning Playwriter / chrome-devtools-mcp / CDP evidence into `API.md`, `NETWORK.md`, and raw evidence files.
6. Use [selector-strategies.md](rules/selector-strategies.md) when DOM extraction is still on the table.
7. Use [crawling-patterns.md](rules/crawling-patterns.md) when pagination, authentication, lazy loading, or retries shape the approach.
8. Use [anti-bot-checklist.md](rules/anti-bot-checklist.md) when the target shows blocks, CAPTCHA, Cloudflare, or explicit anti-detect requirements.
9. Use [action-manifest.md](rules/action-manifest.md) when the run needs a durable state file under `.hypercore/crawler/<ACTION>.json`.
10. Use [document-templates.md](rules/document-templates.md) when writing `.hypercore/crawler/[site]/` artifacts.
11. Use [code-templates.md](rules/code-templates.md) only after the method is chosen and the discovery evidence is documented.

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
- Use Playwriter to reproduce the user-visible flow, then prefer CDP for structured network/auth evidence capture.
- Prefer an API-backed crawler when CDP or fallback browser-network evidence shows a stable endpoint and manageable auth.
- Keep large DOM or accessibility snapshots rare; use them for structure checks and selector validation, not as the default capture surface.
- If CDP attach fails, document the limitation in `ANALYSIS.md` and use Playwriter interception only when the fallback evidence is still sufficient.
- Stop and report blockers when legal constraints, repeated `403/429/503`, CAPTCHA, or strong anti-bot signals make automation unsafe.
- Do not promise `CRAWLER.ts` until the method, auth material, and rate-limit posture are documented.

</execution_defaults>

---

<workflow>

| Phase | Task | Command/Method |
|-------|------|--------|
| **1. Session** | Create session + open page | `playwriter session new` |
| **2. Explore** | Reproduce the page flow with Playwriter | `accessibilitySnapshot`, `screenshotWithAccessibilityLabels` |
| **3. Capture** | Collect network/auth/perf evidence via `chrome-devtools-mcp` (preferred) or CDP fallback | `list_network_requests`, `list_console_messages`, `performance_start_trace`; CDP `Network.*`, `Storage.*`, `Runtime.evaluate` — see [chrome-devtools-mcp.md](rules/chrome-devtools-mcp.md) and [cdp-capture.md](rules/cdp-capture.md) |
| **4. Analyze** | Decide API-first vs DOM-first | [network-crawling.md](rules/network-crawling.md), [selector-strategies.md](rules/selector-strategies.md) |
| **5. Document** | Save findings under `.hypercore/crawler/[site]/` | Write |
| **6. Code** | Generate crawler implementation | [code-templates.md](rules/code-templates.md) |

</workflow>

---

<method_selection>

| Condition | Method | Notes |
|------|------|------|
| API found via CDP or fallback browser-network evidence + simple auth | **`fetch` / `httpx`** | Fastest |
| API + cookie/token required | **`fetch` + Cookie** | Requires expiry handling |
| API + Cloudflare / DataDome / JA3 fingerprinting | **`curl_cffi` (impersonate Chrome)** | Restores TLS/JA3; pair with residential proxy |
| Discovery / live network + perf evidence | **`chrome-devtools-mcp`** | First-party CDP fidelity (network, console, perf trace, Lighthouse) — see [chrome-devtools-mcp.md](rules/chrome-devtools-mcp.md) |
| Page driving / login / lazy-load triggering | **`playwriter`** | "Make the page do the thing" |
| Strong anti-bot (Cloudflare, DataDome) | **Patchright** or **rebrowser-patches** | Patches Chromium / patches `Runtime.Enable` leakage — see [anti-bot-checklist.md](rules/anti-bot-checklist.md) |
| Chromium-specific fingerprinting | **Camoufox** | Firefox-based stealth fork |
| No API (SSR) and no anti-bot | **Playwright DOM** | Parse directly |

</method_selection>

---

<output_structure>

`.hypercore/crawler/<ACTION>.json`

- `ACTION.json` preserves intent, current status, capture mode, blockers, output pointers, and the next step.
- `.hypercore/crawler/[site-name]/` preserves detailed evidence, analysis, and generated code for that site.

```text
.hypercore/crawler/
├── <ACTION>.json              # durable action context
└── [site-name]/
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

Site artifact contract:

```
.hypercore/crawler/[site-name]/
├── ANALYSIS.md      # Site structure
├── SELECTORS.md     # DOM selectors
├── API.md           # API endpoints
├── NETWORK.md       # Auth/network details
├── raw/
│   ├── network-summary.json      # normalized request/response evidence
│   ├── auth-signals.json         # cookies/storage/header evidence
│   └── endpoint-candidates.json  # deduped API candidates
└── CRAWLER.ts       # Generated crawler code
```

Minimum artifact contract:

- `.hypercore/crawler/<ACTION>.json` is required for reusable, blocked, or resumable crawl work.
- `ANALYSIS.md` is always required for reusable crawl work.
- `SELECTORS.md` is required when DOM extraction is used or kept as a fallback path.
- `API.md` is required when API discovery was attempted; document discovered endpoints or the absence of a usable API.
- `NETWORK.md` is required when cookies, tokens, headers, rate limits, or bot-detection signals affect the method.
- `raw/network-summary.json`, `raw/auth-signals.json`, and `raw/endpoint-candidates.json` are recommended when CDP capture is available, and should back the human-readable docs instead of replacing them.
- `CRAWLER.ts` is required only after discovery evidence is written and the chosen method is justified.

Starter interaction commands live in [playwriter-commands.md](rules/playwriter-commands.md). CDP evidence capture lives in [cdp-capture.md](rules/cdp-capture.md). Durable action-state rules live in [action-manifest.md](rules/action-manifest.md). Keep the core focused on method choice, output gates, and stop conditions.

**Templates:** [document-templates.md](rules/document-templates.md)

</output_structure>

---

<blocked_outcomes>

For blocked or unsafe runs:

- write `ANALYSIS.md` with the blocker, the evidence that triggered the stop, and the safest next step
- write `NETWORK.md` when auth signals, block responses, or anti-bot findings affected the decision
- write any available raw evidence files even when the run is blocked, so the stop is auditable
- update `ACTION.json` so `status`, `capture_mode`, blockers, and output pointers match the blocked state
- omit `CRAWLER.ts` until the blocker is resolved or the method becomes safe to automate

</blocked_outcomes>

---

<validation>

```text
✅ Playwriter session created
✅ `ACTION.json` created when the run is reusable, blocked, or resumable
✅ Structure analyzed with limited Playwriter snapshots
✅ CDP capture attempted for network/auth evidence
✅ raw evidence files recorded when CDP capture is available, or the fallback limitation documented when it is not
✅ Selector extraction validated
✅ Findings documented under .hypercore/crawler/
✅ Crawler code generated
✅ sequential-thinking trace recorded for major phases
✅ legal, rate-limit, and bot-detection blockers documented before scaling
✅ blocked runs reported explicitly when crawler code is unsafe or premature
✅ `ACTION.json` status and `site_dir` match the actual run outputs
✅ completed runs leave `ACTION.json.next_step` empty or terminal and point outputs at final files
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

# 1. Create durable action context
# .hypercore/crawler/extract-products.json

# 2. Session
playwriter session new  # => 1
playwriter -s 1 -e "state.page = await context.newPage(); await state.page.goto('https://shop.example.com/products')"

# 3. Structure analysis
playwriter -s 1 -e "console.log(await accessibilitySnapshot({ page: state.page }))"
# => list "Products" [ref=e5]: listitem [ref=e6]: link "Product A" [ref=e7]

# 4. CDP capture
playwriter -s 1 -e $'
const client = await state.page.context().newCDPSession(state.page);
await client.send("Network.enable");
state.cdpHits = [];
client.on("Network.responseReceived", (event) => {
  if (event.response.url.includes("/api/")) state.cdpHits.push(event.response.url);
});
'
playwriter -s 1 -e "await state.page.evaluate(() => window.scrollTo(0, 9999))"
playwriter -s 1 -e "console.log(state.cdpHits)"
# => ["/api/products?page=2"]

# 5. Update extract-products.json -> status=running, capture_mode=cdp
# 6. Documentation -> .hypercore/crawler/shop-example-com/ + raw/network-summary.json
# 7. Generate API-based crawler
```

</example>
