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

## Tool Selection

| Condition | Recommended Tool |
|------|------|
| No bot detection | Playwright |
| Basic bot checks | Playwright + Stealth |
| Advanced anti-bot stack | Nstbrowser / Anti-Detect browser |
| Cloudflare-heavy target | Anti-Detect is mandatory |

</tool_selection>
