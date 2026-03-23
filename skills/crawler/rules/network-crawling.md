# Network Analysis

> Turn Playwriter + CDP evidence into `API.md`, `NETWORK.md`, and raw network artifacts.

---

<workflow>

```text
1. Reproduce the relevant page flow with Playwriter
2. Capture normalized endpoint/auth/rate-limit evidence with CDP
3. Persist raw JSON under `.hypercore/crawler/[site]/raw/`
4. Summarize findings in `API.md` and `NETWORK.md`
5. Reuse network/auth details in generated crawler code
```

</workflow>

---

<cookie>

## Cookie Extraction

```bash
const cookies = await client.send('Storage.getCookies');
console.log(JSON.stringify(
  cookies.cookies.map(({ name, domain, expires }) => ({ name, domain, expires })),
  null,
  2
));
```

</cookie>

---

<token>

## Token Extraction

```bash
await client.send('Runtime.evaluate', {
  expression: 'localStorage.getItem("token")',
  returnByValue: true,
});

await client.send('Runtime.evaluate', {
  expression: 'sessionStorage.getItem("accessToken")',
  returnByValue: true,
});

client.on('Network.requestWillBeSent', (event) => {
  const auth = event.request.headers['Authorization'] || event.request.headers['authorization'];
  if (auth) console.log(JSON.stringify({ url: event.request.url, authPresent: true }));
});
```

</token>

---

<headers>

## Header Capture

```bash
client.on('Network.requestWillBeSent', (event) => {
  if (!event.request.url.includes('/api/')) return;
  console.log(JSON.stringify({
    url: event.request.url,
    headers: {
      'accept-language': event.request.headers['Accept-Language'],
      'referer': event.request.headers['Referer'],
      'user-agent': event.request.headers['User-Agent'],
    },
  }, null, 2));
});
```

</headers>

---

<bot_detection>

## Bot-Detection Signals

```bash
client.on('Network.responseReceived', (event) => {
  if ([403, 429, 503].includes(event.response.status)) {
    console.log(JSON.stringify({
      blocked: true,
      status: event.response.status,
      url: event.response.url,
      retryAfter: event.response.headers['retry-after'] || null,
    }, null, 2));
  }
});
```

</bot_detection>

---

<network_template>

## Raw JSON Targets

Write these files when evidence is available:

- `.hypercore/crawler/[site]/raw/network-summary.json`
- `.hypercore/crawler/[site]/raw/auth-signals.json`
- `.hypercore/crawler/[site]/raw/endpoint-candidates.json`

Keep them normalized and deduplicated. They support the final docs; they do not replace them.

---

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

## Evidence Source

- Playwriter flow reproduced: yes/no
- CDP capture attached: yes/no
- Fallback browser-network capture used: yes/no
- Raw artifacts written: yes/no

## Notes

- Strong anti-bot -> use Nstbrowser
- Short cookie TTL -> add refresh logic
```

</network_template>
