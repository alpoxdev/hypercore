# Network 분석

> Playwriter + CDP 근거를 `API.md`, `NETWORK.md`, raw 네트워크 아티팩트로 정리합니다.

---

<workflow>

```text
1. Playwriter로 필요한 페이지 플로우를 재현
2. CDP로 endpoint/auth/rate-limit 근거를 정규화 수집
3. `.hypercore/crawler/<ACTION>.json`의 `status`, `capture_mode`, raw 근거 포인터, blocker를 갱신
4. `.hypercore/crawler/[site]/raw/` 아래 raw JSON 저장
5. `API.md`, `NETWORK.md`에 요약
6. 크롤러 코드 작성 시 활용
```

</workflow>

---

<cookie>

## 쿠키 추출

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

## 토큰 추출

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

## 헤더 캡처

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

<bot_check>

## 봇 탐지 확인

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

</bot_check>

---

<template>

## Raw JSON 대상

근거가 있으면 다음 파일을 기록합니다.

- `.hypercore/crawler/[site]/raw/network-summary.json`
- `.hypercore/crawler/[site]/raw/auth-signals.json`
- `.hypercore/crawler/[site]/raw/endpoint-candidates.json`

이 파일들은 정규화되고 중복 제거된 근거 파일이며, 최종 문서를 대체하지 않습니다.

기록한 raw 파일 목록은 `.hypercore/crawler/<ACTION>.json.evidence.raw_files`에도 함께 반영합니다.

---

## NETWORK.md 템플릿

```markdown
# [사이트명] Network

## 인증

| 항목 | 값 | 만료 |
|------|-----|------|
| Cookie | `session=...` | 24h |
| Token | `Bearer ...` | 1h |

## 필수 헤더

\`\`\`json
{
  "Cookie": "...",
  "Authorization": "Bearer ...",
  "User-Agent": "Mozilla/5.0 ..."
}
\`\`\`

## Rate Limit

- 제한: 60 req/min
- 딜레이: 1000ms

## 봇 탐지

- [ ] Cloudflare
- [ ] reCAPTCHA

## 근거 출처

- Playwriter 플로우 재현: yes/no
- CDP 수집 연결: yes/no
- fallback 브라우저 네트워크 수집 사용: yes/no
- Raw 아티팩트 기록: yes/no

## 참고

- 봇 탐지 강함 → Nstbrowser
- 쿠키 만료 짧음 → 갱신 로직
```

</template>
