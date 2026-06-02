# Anti-Bot Evasion Checklist

> Reference checklist for reducing bot detection risk when implementing crawlers.

---

<fingerprint>

## Browser Fingerprint

```bash
playwriter -s 1 -e $'
const fp = await state.page.evaluate(() => ({
  webdriver: navigator.webdriver,
  plugins: navigator.plugins.length,
  languages: navigator.languages,
  platform: navigator.platform,
}));
console.log(fp);
'
```

| Fingerprint Signal | Bot Indicator | Mitigation |
|------|------|------|
| `navigator.webdriver` | `true` | Use Anti-Detect profile |
| `plugins.length` | `0` | Plugin spoofing |
| UA vs platform | Mismatch | Keep UA/platform consistent |
| Canvas/WebGL | Too deterministic | Add controlled variance |
| TLS/JA3 | Non-standard client hello | Use real-browser networking |

</fingerprint>

---

<behavior>

## Behavioral Pattern

| Pattern | Bot-like | Human-like |
|------|------|------|
| Request interval | Fixed | Irregular |
| Click timing | Immediate | Hover then click |
| Scroll style | Jumping | Smooth |
| Dwell time | Very short | Variable |

```bash
# More human-like click flow
playwriter -s 1 -e $'
const btn = state.page.locator("button");
await btn.hover();
await state.page.waitForTimeout(100 + Math.random() * 200);
await btn.click();
'
```

</behavior>

---

<network>

## Network Profile

| IP Type | Risk |
|---------|------|
| Datacenter (AWS, GCP) | High |
| VPN/Proxy | Medium |
| Residential | Low |

**Header checks:**
- Match `Accept-Language` to region/profile
- Set realistic `Referer`
- Keep browser-like header order

</network>

---

<tls_fingerprint>

## TLS / JA3 / JA4 Fingerprint

The TLS handshake is fingerprinted **independently** from the browser. Even a perfectly stealthed Chromium leaks at the network layer when the request is made from `node fetch` / Python `requests` / `httpx` / Playwright's HTTP client — JA3/JA4 hashes diverge from real Chrome / Firefox, and Cloudflare / Akamai reject the mismatch.

| Symptom | Likely cause | Fix |
|---|---|---|
| Browser passes `bot.sannysoft.com` but real target still 403/503 | TLS/JA3 mismatch on direct API calls | Move API path to **`curl_cffi`** (Python) impersonating Chrome 120+ |
| `403` only on background `fetch()` from inside the browser, page-level GET passes | `fetch` does not inherit the browser's TLS state in some sandboxes | Issue API requests from the browser context (not Node.js) or move to `curl_cffi` outside the browser |
| Inconsistent JA3 across requests | Chrome 110+ rotates JA3 per request | Use `curl_cffi` `impersonate="chrome120"` (or newer) — it rotates the same way |

Tooling reference:
- `curl_cffi` (Python) — drop-in `requests` replacement; mirrors Chrome ClientHello, JA3/JA4, cipher suite order, ALPN, HTTP/2 settings; supports HTTP/2 and HTTP/3; proxy rotation per request.
- `curl-impersonate` — underlying C/Rust fork that `curl_cffi` wraps.
- See [code-templates.md](code-templates.md) for the `Stealth API Crawler Template` based on `curl_cffi`.

Decision-test smoke endpoint: `https://tls.peet.ws/api/all` returns the JA3/JA4 your client actually sent — useful when the target's behavior is suspicious but the browser fingerprint passes.

</tls_fingerprint>

---

<captcha>

## CAPTCHA Handling

| CAPTCHA Type | Handling |
|------|------|
| reCAPTCHA v2 | Solver service (e.g. 2captcha) |
| reCAPTCHA v3 | Improve behavior score + warm-up |
| hCaptcha | Solver service + retry logic |

</captcha>

---

<detection_test>

## Detection Test Targets

| Site | Purpose |
|------|------|
| `bot.sannysoft.com` | Overall bot fingerprint check |
| `browserleaks.com` | Browser fingerprint leakage |
| `pixelscan.net` | Anti-detect effectiveness |

</detection_test>

---

<checklist>

## Evasion Checklist

**Required baseline:**

- [ ] Realistic User-Agent
- [ ] Consistent plugin/language/platform values
- [ ] Cookies enabled
- [ ] Browser-like header set/order

**Behavioral controls:**

- [ ] Random delay (1-5s)
- [ ] Hover before click where reasonable
- [ ] Smooth scrolling patterns
- [ ] Variable dwell times

</checklist>

---

<tool_selection>

## Tool Selection (2026 stack)

`playwright-extra` + `puppeteer-extra-plugin-stealth` are effectively unmaintained (no meaningful update since Mar 2023) and consistently fail current Cloudflare Bot Fight Mode and DataDome 2024+ checks. Prefer the patches below.

| Condition | Recommended Tool | Why |
|------|------|------|
| No bot detection | `playwright` (or `playwriter` MCP) | Cheapest path |
| Basic bot checks | `playwright` + **`rebrowser-patches`** | One-shot patch; neutralises the `Runtime.Enable` CDP-detection vector that Cloudflare/DataDome use to flag automation |
| Advanced anti-bot (Cloudflare Bot Fight, DataDome) | **`Patchright`** (drop-in Playwright replacement, build-time Chromium binary patches) | Removes headless-detection from the browser itself; passes the standard `nowsecure` headless test |
| Chromium-specific fingerprinting | **`Camoufox`** (Firefox stealth fork) | Different attack surface — useful when targets fingerprint Chromium specifically |
| Cloudflare Turnstile | `Patchright` or `Camoufox` + click-based solver | No external solver service needed for many sites |
| API path with TLS/JA3 fingerprinting | **`curl_cffi`** (Python, Chrome JA3 impersonation) | See [`<tls_fingerprint>`](#tls_fingerprint) above |
| reCAPTCHA v2 / hCaptcha | Solver service (2captcha, Capsolver) + retry | Document cost & legality |

`Runtime.Enable` note: vanilla Puppeteer / Playwright call `Runtime.Enable` on attach, and Cloudflare / DataDome read the resulting binding leaks to confirm automation. `rebrowser-patches` and `Patchright` both close that vector — pick one based on whether you can afford a Chromium binary swap.

Pure browser stealth is **not enough** when JA3 leaks at the network layer. Pair browser-layer fixes (Patchright/rebrowser/Camoufox) with network-layer fixes (`curl_cffi` for API calls or let the real browser do the round-trip).

</tool_selection>
