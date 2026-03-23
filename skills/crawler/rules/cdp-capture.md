# CDP Capture

> Use CDP as the structured evidence channel after Playwriter reproduces the target flow.

---

<purpose>

- Keep Playwriter focused on page flow, login, clicks, and selector validation.
- Use CDP for lower-token network, cookie, token, storage, and rate-limit evidence capture.
- Save normalized raw evidence before writing `API.md` and `NETWORK.md`.

</purpose>

---

<workflow>

```text
1. Reproduce the relevant page flow with Playwriter
2. Attach a CDP session to the active page
3. Enable Network + Runtime + Storage domains
4. Capture normalized request/response/auth evidence
5. Deduplicate endpoint families and summarize auth signals
6. Persist raw JSON under `.hypercore/crawler/[site]/raw/`
```

</workflow>

---

<attach>

## Attach To The Active Page

```javascript
const client = await state.page.context().newCDPSession(state.page);
await client.send('Network.enable');
await client.send('Runtime.enable');
await client.send('Page.enable');
```

If this attach step fails, record the limitation in `ANALYSIS.md`, switch to the Playwriter interception fallback, and treat the run as fallback-based rather than CDP-backed.

</attach>

---

<network>

## Network Evidence

```javascript
state.cdp = {
  requests: [],
  responses: [],
  endpointFamilies: new Map(),
};

client.on('Network.requestWillBeSent', (event) => {
  const url = event.request.url;
  const family = url.replace(/([?&](page|offset|cursor|limit)=[^&]+)/g, '');
  state.cdp.requests.push({
    url,
    family,
    method: event.request.method,
    resourceType: event.type,
  });
  state.cdp.endpointFamilies.set(family, true);
});

client.on('Network.responseReceived', (event) => {
  state.cdp.responses.push({
    url: event.response.url,
    status: event.response.status,
    mimeType: event.response.mimeType,
    headers: {
      'content-type': event.response.headers['content-type'],
      'retry-after': event.response.headers['retry-after'],
      'x-ratelimit-limit': event.response.headers['x-ratelimit-limit'],
      'x-ratelimit-remaining': event.response.headers['x-ratelimit-remaining'],
    },
  });
});
```

</network>

---

<auth>

## Auth Signals

```javascript
const cookies = await client.send('Storage.getCookies');
const localToken = await client.send('Runtime.evaluate', {
  expression: 'localStorage.getItem("token")',
  returnByValue: true,
});
const sessionToken = await client.send('Runtime.evaluate', {
  expression: 'sessionStorage.getItem("accessToken")',
  returnByValue: true,
});

console.log(JSON.stringify({
  cookieNames: cookies.cookies.map((c) => c.name),
  localTokenPresent: Boolean(localToken.result.value),
  sessionTokenPresent: Boolean(sessionToken.result.value),
}, null, 2));
```

</auth>

---

<body_sampling>

## Body Sampling Rules

- Do not capture every response body by default.
- Sample only JSON endpoints, pagination candidates, detail endpoints, auth/bootstrap payloads, and anti-bot responses.
- Prefer headers + URL family + status when body capture would be large or redundant.

</body_sampling>

---

<raw_artifacts>

## Raw Artifact Targets

Write these files when CDP evidence is available:

- `.hypercore/crawler/[site]/raw/network-summary.json`
- `.hypercore/crawler/[site]/raw/auth-signals.json`
- `.hypercore/crawler/[site]/raw/endpoint-candidates.json`

These are evidence files, not the final deliverable. Use them to back `API.md` and `NETWORK.md`.

</raw_artifacts>

---

<decision_notes>

## Decision Notes

- Prefer CDP over repeated large Playwriter snapshots for network/auth discovery.
- Keep Playwriter as the source of truth for page flow and selector validation.
- If CDP is unavailable, fall back to Playwriter interception and record that limitation in `ANALYSIS.md`.

</decision_notes>
