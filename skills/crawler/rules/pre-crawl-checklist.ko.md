# 크롤링 전 분석 체크리스트

> Playwriter 사이트 분석 시 확인 항목

---

<rendering_check>

## 렌더링 방식

```bash
playwriter -s 1 -e $'
const html = await state.page.content();
console.log("HTML:", html.length, "| SSR:", html.length > 5000 ? "가능" : "CSR");
'
```

| 방식 | 특징 | 전략 |
|------|------|------|
| SSR | HTML에 데이터 포함 | DOM 파싱 |
| CSR | JS로 로딩 | API 인터셉트 |
| Hybrid | 초기 SSR + 추가 CSR | 혼합 |

</rendering_check>

---

<bot_detection>

## 봇 탐지 확인

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
# 차단 응답 모니터링
playwriter -s 1 -e $'
state.page.on("response", res => {
  if ([403, 429, 503].includes(res.status()))
    console.log("차단:", res.status(), res.url());
});
'
```

| 코드 | 의미 | 대응 |
|------|------|------|
| 403 | 접근 차단 | Anti-Detect |
| 429 | Rate Limit | 딜레이 증가 |
| 503 | 일시 차단 | 대기 후 재시도 |

</bot_detection>

---

<honeypot>

## 허니팟 탐지

```bash
playwriter -s 1 -e $'
const hidden = await state.page.$$eval("a", links =>
  links.filter(a => {
    const s = getComputedStyle(a);
    return s.display==="none" || s.visibility==="hidden" || s.opacity==="0" || a.offsetWidth===0;
  }).map(a => a.href)
);
console.log("숨겨진 링크:", hidden.length);
'
```

| 유형 | 탐지 | 대응 |
|------|------|------|
| 숨김 링크 | `display:none`, `visibility:hidden` | 클릭 금지 |
| 함정 필드 | `name*=honeypot`, `name*=trap` | 입력 금지 |
| 0x0 요소 | `offsetWidth===0` | 무시 |

</honeypot>

---

<rate_limit>

## Rate Limiting

```bash
playwriter -s 1 -e $'
state.page.on("response", res => {
  const h = res.headers();
  if (h["x-ratelimit-limit"]) console.log("Limit:", h["x-ratelimit-limit"]);
  if (h["retry-after"]) console.log("Retry:", h["retry-after"]);
});
'
```

| 헤더 | 설명 |
|------|------|
| `X-RateLimit-Limit` | 최대 요청 수 |
| `X-RateLimit-Remaining` | 남은 요청 수 |
| `Retry-After` | 대기 시간 (초) |

</rate_limit>

---

<auth_check>

## 인증 분석

```bash
# 쿠키
playwriter -s 1 -e $'
const cookies = await context.cookies();
console.log(cookies.filter(c =>
  ["session","token","auth","jwt"].some(k => c.name.toLowerCase().includes(k))
));
'

# 토큰
playwriter -s 1 -e $'
const storage = await state.page.evaluate(() => ({
  local: Object.keys(localStorage).filter(k => k.match(/token|auth|jwt/i)),
  session: Object.keys(sessionStorage).filter(k => k.match(/token|auth|jwt/i))
}));
console.log(storage);
'

# Authorization 헤더
playwriter -s 1 -e $'
state.page.on("request", req => {
  const auth = req.headers()["authorization"];
  if (auth) console.log("Auth:", auth.slice(0, 50));
});
'
```

</auth_check>

---

<api_discovery>

## API 발견

```bash
playwriter -s 1 -e $'
state.apis = [];
state.page.on("request", req => {
  if (req.url().includes("/api/") || req.resourceType()==="fetch")
    state.apis.push({ method: req.method(), url: req.url().split("?")[0] });
});
'
# 페이지 탐색 후
playwriter -s 1 -e $'
const unique = [...new Map(state.apis.map(a => [a.url, a])).values()];
console.log(unique);
'
```

</api_discovery>

---

<dynamic_content>

## 동적 콘텐츠

```bash
# Lazy loading
playwriter -s 1 -e $'
const lazy = await state.page.$$eval("img", imgs =>
  imgs.filter(i => i.dataset.src || i.loading==="lazy").length
);
console.log("Lazy 이미지:", lazy);
'

# Shadow DOM / iframe
playwriter -s 1 -e $'
const shadow = await state.page.$$eval("*", els => els.filter(e => e.shadowRoot).length);
const iframes = await state.page.$$eval("iframe", f => f.length);
console.log("Shadow:", shadow, "| iframe:", iframes);
'
```

</dynamic_content>

---

<decision_table>

## 전략 결정

| 항목 | 결과 | 권장 |
|------|------|------|
| 렌더링 | SSR / CSR | DOM / API |
| 봇 탐지 | 없음 / 있음 | 일반 / Anti-Detect |
| 인증 | 공개 / 필요 | 직접 / 쿠키·토큰 |
| Rate Limit | 없음 / 있음 | 병렬 / 딜레이 |

</decision_table>

---

<warnings>

```text
⚠️ 허니팟 클릭 금지
⚠️ Rate Limit 초과 시 중단
⚠️ robots.txt 확인
```

</warnings>
