# CDP 수집

> Playwriter로 대상 플로우를 재현한 뒤, 구조화된 근거 수집 채널로 CDP를 사용합니다.

---

<purpose>

- Playwriter는 페이지 플로우, 로그인, 클릭, selector 검증에 집중합니다.
- CDP는 더 적은 토큰으로 네트워크, 쿠키, 토큰, 저장소, rate-limit 근거를 수집합니다.
- `API.md`, `NETWORK.md`를 쓰기 전에 정규화된 raw 근거를 먼저 저장합니다.

</purpose>

---

<workflow>

```text
1. Playwriter로 필요한 페이지 플로우를 재현
2. 현재 페이지에 CDP 세션 연결
3. Network + Runtime + Storage 도메인 활성화
4. 정규화된 요청/응답/인증 근거 수집
5. endpoint family 중복 제거와 auth signal 요약
6. `.hypercore/crawler/[site]/raw/` 아래 raw JSON 저장
```

</workflow>

---

<attach>

## 현재 페이지에 연결

```javascript
const client = await state.page.context().newCDPSession(state.page);
await client.send('Network.enable');
await client.send('Runtime.enable');
await client.send('Page.enable');
```

이 연결 단계가 실패하면 그 제한을 `ANALYSIS.md`에 기록하고, Playwriter 인터셉트 fallback으로 전환한 뒤, CDP 기반이 아니라 fallback 기반 실행으로 취급합니다.

</attach>

---

<network>

## 네트워크 근거

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

## 인증 신호

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

## Body 샘플링 규칙

- 기본값으로 모든 response body를 수집하지 않습니다.
- JSON endpoint, pagination 후보, detail endpoint, auth/bootstrap payload, anti-bot 응답만 샘플링합니다.
- body가 크거나 중복되면 body보다 headers, URL family, status를 우선합니다.

</body_sampling>

---

<raw_artifacts>

## Raw 아티팩트 대상

CDP 근거가 있으면 다음 파일을 기록합니다.

- `.hypercore/crawler/[site]/raw/network-summary.json`
- `.hypercore/crawler/[site]/raw/auth-signals.json`
- `.hypercore/crawler/[site]/raw/endpoint-candidates.json`

이 파일들은 최종 산출물이 아니라 근거 파일입니다. `API.md`, `NETWORK.md`의 근거로 사용합니다.

이 파일들이 기록되면 `.hypercore/crawler/<ACTION>.json.evidence.raw_files`에도 함께 반영합니다.

</raw_artifacts>

---

<decision_notes>

## 결정 메모

- 네트워크/인증 discovery에서는 큰 Playwriter snapshot 반복보다 CDP를 우선합니다.
- 페이지 플로우와 selector 검증은 계속 Playwriter가 기준입니다.
- CDP를 쓸 수 없으면 Playwriter 인터셉트로 fallback하고, 그 제한을 `ANALYSIS.md`에 기록합니다.
- CDP 연결에 성공하면 `ACTION.json`에 `capture_mode: "cdp"`를 기록합니다.
- CDP 연결에 실패했지만 fallback 근거가 충분하면 `capture_mode: "fallback"`을 기록하고 그 제한을 manifest에 남깁니다.

</decision_notes>
