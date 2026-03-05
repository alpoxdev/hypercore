# Pre-Crawl Analysis Checklist

> Required checks before implementing a crawler for a target site.

---

<rendering_check>

## Rendering Model

```bash
playwriter -s 1 -e $'
const html = await state.page.content();
console.log("HTML:", html.length, "| SSR:", html.length > 5000 ? "likely" : "CSR/API");
'
```

| Model | Signal | Strategy |
|------|------|------|
| SSR | Data appears in initial HTML | DOM parsing first |
| CSR | Data loaded after JS execution | Intercept/call API |
| Hybrid | Initial SSR + incremental API | Mixed approach |

</rendering_check>

---

<bot_detection>

## Bot Detection Check

```bash
playwriter -s 1 -e $'
const html = await state.page.content();
console.log({
  cloudflare: html.includes("cf-ray") || html.includes("cf-challenge"),
  recaptcha: html.includes("recaptcha"),
  hcaptcha: html.includes("hcaptcha"),
  datadome: html.includes("datadome"),
  akamai: html.includes("_abck"),
});
'
```

```bash
# monitor block responses
playwriter -s 1 -e $'
state.page.on("response", res => {
  if ([403, 429, 503].includes(res.status()))
    console.log("Blocked:", res.status(), res.url());
});
'
```

| Code | Meaning | Action |
|------|------|------|
| 403 | Access denied | Anti-Detect profile |
| 429 | Rate limited | Increase delay / reduce concurrency |
| 503 | Temporary block/challenge | Backoff and retry later |

</bot_detection>

---

<honeypot>

## Honeypot Detection

```bash
playwriter -s 1 -e $'
const hidden = await state.page.$$eval("a", links =>
  links.filter(a => {
    const s = getComputedStyle(a);
    return s.display === "none" || s.visibility === "hidden" || s.opacity === "0" || a.offsetWidth === 0;
  }).map(a => a.href)
);
console.log("Hidden links:", hidden.length);
'
```

| Type | Detection | Action |
|------|------|------|
| Hidden links | `display:none`, `visibility:hidden` | Never click |
| Trap fields | `name*=honeypot`, `name*=trap` | Never fill |
| 0x0 elements | `offsetWidth===0` | Ignore |

</honeypot>

---

<rate_limit>

## Rate-Limit Analysis

| Header | Meaning |
|------|------|
| `X-RateLimit-Limit` | Max requests |
| `X-RateLimit-Remaining` | Remaining requests |
| `Retry-After` | Cooldown seconds |

</rate_limit>

---

<auth_analysis>

## Authentication Analysis

```bash
# cookies
playwriter -s 1 -e "console.log(JSON.stringify(await context.cookies(), null, 2))"

# localStorage token
playwriter -s 1 -e "console.log(await state.page.evaluate(() => localStorage.getItem('token')))"

# authorization header
playwriter -s 1 -e $'
state.page.on("request", req => {
  const auth = req.headers()["authorization"];
  if (auth) console.log(auth);
});
'
```

</auth_analysis>

---

<api_discovery>

## API Discovery

```bash
playwriter -s 1 -e $'
state.responses = [];
state.page.on("response", async res => {
  if (!res.url().includes("/api/")) return;
  state.responses.push({ url: res.url(), status: res.status() });
});
'

# after page exploration
playwriter -s 1 -e "console.log(state.responses)"
```

</api_discovery>

---

<dynamic_content>

## Dynamic Content Check

```bash
playwriter -s 1 -e $'
const lazy = await state.page.$$eval("img[loading=lazy]", imgs => imgs.length);
console.log("Lazy images:", lazy);
'
```

</dynamic_content>

---

<decision_matrix>

## Strategy Decision Matrix

| Item | Result | Recommendation |
|------|------|------|
| Rendering | SSR / CSR | DOM / API |
| Bot detection | No / Yes | Standard / Anti-Detect |
| Authentication | Public / Required | Direct / Cookie-token flow |
| Rate limit | No / Yes | Parallel / Delayed |

</decision_matrix>

---

<safety_notes>

## Safety Notes

- Do not click honeypot elements
- Stop or back off on repeated rate-limit responses
- Check `robots.txt` and legal constraints before scaling

</safety_notes>
