# Network Analysis

> Extract cookies/tokens/headers with Playwriter and document them into `NETWORK.md`.

---

<workflow>

```text
1. Explore pages with Playwriter
2. Intercept API requests/responses and collect endpoint/header/cookie/token info
3. Document findings in NETWORK.md
4. Reuse network/auth details in generated crawler code
```

</workflow>

---

<cookie>

## Cookie Extraction

```bash
# all cookies
playwriter -s 1 -e "console.log(JSON.stringify(await context.cookies(), null, 2))"

# auth-like cookies only
playwriter -s 1 -e $'
const cookies = await context.cookies();
console.log(cookies.filter(c =>
  ["session","token","auth","sid"].some(n => c.name.toLowerCase().includes(n))
));
'
```

</cookie>

---

<token>

## Token Extraction

```bash
# localStorage token
playwriter -s 1 -e "console.log(await state.page.evaluate(() => localStorage.getItem('token')))"

# sessionStorage token
playwriter -s 1 -e "console.log(await state.page.evaluate(() => sessionStorage.getItem('accessToken')))"

# Authorization header capture
playwriter -s 1 -e $'
state.page.on("request", req => {
  const auth = req.headers()["authorization"];
  if (auth) console.log("Auth:", auth);
});
'
```

</token>

---

<headers>

## Header Capture

```bash
playwriter -s 1 -e $'
state.page.on("request", req => {
  if (req.url().includes("/api/"))
    console.log(JSON.stringify(req.headers(), null, 2));
});
'
```

</headers>

---

<bot_detection>

## Bot-Detection Signals

```bash
playwriter -s 1 -e $'
state.page.on("response", res => {
  if ([403, 429, 503].includes(res.status())) {
    console.log("Blocked:", res.status(), res.url());
  }
});
'
```

</bot_detection>

---

<network_template>

## NETWORK.md Template

```markdown
# [Site Name] Network

## Authentication

| Field | Value | Expires |
|------|------|------|
| Cookie | session=... | 24h |
| Token | ey... | 1h |

## Required Headers

- User-Agent: ...
- Accept-Language: ...
- Referer: ...

## Limits

- Rate limit: 60 req/min
- Delay: 1000ms

## Bot Detection

- Cloudflare: yes/no
- CAPTCHA: yes/no

## Notes

- Strong anti-bot -> use Nstbrowser
- Short cookie TTL -> add refresh logic
```

</network_template>
