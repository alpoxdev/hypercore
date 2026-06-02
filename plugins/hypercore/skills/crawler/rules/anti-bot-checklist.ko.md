# 봇 탐지 대응 체크리스트

> 크롤러 코드 작성 시 봇 탐지 회피 참고

---

<fingerprint>

## 브라우저 지문

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

| 지문 | 봇 특징 | 대응 |
|------|--------|------|
| `navigator.webdriver` | `true` | Anti-Detect |
| `plugins.length` | `0` | 스푸핑 |
| UA vs platform | 불일치 | 일관성 |
| Canvas/WebGL | 일정함 | 다양화 |
| TLS/JA3 | 비표준 | Anti-Detect |

</fingerprint>

---

<behavior>

## 행동 패턴

| 패턴 | 봇 | 인간 |
|------|-----|------|
| 요청 간격 | 일정 | 불규칙 |
| 클릭 | 즉시 | 호버 후 |
| 스크롤 | 점프 | 부드럽게 |
| 체류 시간 | 짧음 | 다양 |

```bash
# 자연스러운 클릭
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

## 네트워크

| IP 유형 | 위험도 |
|---------|-------|
| 데이터센터 (AWS, GCP) | 높음 |
| VPN/프록시 | 중간 |
| 주거용 | 낮음 |

**헤더 체크:**
- `Accept-Language` 지역 일치
- `Referer` 적절히 설정
- 헤더 순서 브라우저와 일치

</network>

---

<tls_fingerprint>

## TLS / JA3 / JA4 지문

TLS 핸드셰이크는 브라우저 지문과 **별개로** 검사됩니다. 브라우저는 완벽히 stealth 처리되어 있어도 `node fetch` / Python `requests` / `httpx` / Playwright HTTP 클라이언트에서 요청을 보내면 JA3/JA4 해시가 실제 Chrome/Firefox와 어긋나고, Cloudflare/Akamai가 이 불일치를 잡아냅니다.

| 증상 | 가능성이 높은 원인 | 대응 |
|---|---|---|
| 브라우저는 `bot.sannysoft.com` 통과인데 대상 사이트는 여전히 403/503 | 직접 API 호출의 TLS/JA3 불일치 | API 경로를 **`curl_cffi`** (Python, Chrome 120+ 임퍼소네이트)로 이동 |
| 페이지 GET은 통과인데 브라우저 안 background `fetch()`만 403 | 일부 샌드박스에서 `fetch`가 브라우저 TLS 상태를 상속하지 않음 | 브라우저 컨텍스트 안에서 호출하거나, 브라우저 밖에서 `curl_cffi`로 호출 |
| 요청마다 JA3가 다름 | Chrome 110+가 요청마다 JA3를 회전 | `curl_cffi` `impersonate="chrome120"` (또는 신규 버전) — 같은 방식으로 회전합니다 |

도구 참고:
- `curl_cffi` (Python) — `requests`의 drop-in 대체. Chrome ClientHello, JA3/JA4, cipher suite 순서, ALPN, HTTP/2 설정을 그대로 흉내냅니다. HTTP/2·HTTP/3 지원, 요청 단위 proxy 회전 가능.
- `curl-impersonate` — `curl_cffi`가 감싸는 C/Rust fork.
- `curl_cffi` 기반 `Stealth API Crawler Template`은 [code-templates.md](code-templates.md) 참고.

검증 smoke endpoint: `https://tls.peet.ws/api/all` — 우리 클라이언트가 실제로 보낸 JA3/JA4를 그대로 돌려줍니다. 브라우저 지문은 통과하는데 대상이 의심스러운 동작을 보일 때 유용합니다.

</tls_fingerprint>

---

<captcha>

## CAPTCHA 대응

```bash
playwriter -s 1 -e $'
const captcha = await state.page.evaluate(() => ({
  recaptcha: !!document.querySelector(".g-recaptcha"),
  hcaptcha: !!document.querySelector(".h-captcha"),
  turnstile: !!document.querySelector(".cf-turnstile"),
}));
console.log(captcha);
'
```

| CAPTCHA | 대응 |
|---------|------|
| reCAPTCHA v2 | 2captcha 서비스 |
| reCAPTCHA v3 | 행동 개선 |
| hCaptcha | 서비스 사용 |
| Turnstile | Anti-Detect |

</captcha>

---

<test_sites>

## 탐지 테스트

```bash
playwriter -s 1 -e $'
await state.page.goto("https://bot.sannysoft.com/");
await state.page.screenshot({ path: "bot-test.png", scale: "css", fullPage: true });
'
```

| 사이트 | 확인 |
|--------|------|
| bot.sannysoft.com | 종합 봇 탐지 |
| browserleaks.com | 브라우저 지문 |
| pixelscan.net | Anti-Detect 효과 |

</test_sites>

---

<checklist>

## 회피 체크리스트

**필수:**
```text
✅ User-Agent 실제 브라우저
✅ webdriver = false
✅ 플러그인/언어/플랫폼 일관성
✅ 쿠키 활성화
✅ 헤더 순서 일치
```

**행동:**
```text
✅ 무작위 딜레이 (1-5초)
✅ 클릭 전 호버
✅ 자연스러운 스크롤
✅ 체류 시간 다양화
```

</checklist>

---

<tool_selection>

## 도구 선택 (2026 스택)

`playwright-extra` + `puppeteer-extra-plugin-stealth`는 2023.3 이후 사실상 미관리 상태이며 최신 Cloudflare Bot Fight Mode와 DataDome 2024+ 검사를 통과하지 못합니다. 아래 패치 계열을 우선 사용합니다.

| 조건 | 권장 도구 | 사유 |
|------|------|------|
| 봇 탐지 없음 | `playwright` (또는 `playwriter` MCP) | 가장 가벼움 |
| 기본 봇 탐지 | `playwright` + **`rebrowser-patches`** | 1회성 패치. Cloudflare/DataDome가 자동화 탐지에 사용하는 `Runtime.Enable` CDP 경로를 차단 |
| 고급 anti-bot (Cloudflare Bot Fight, DataDome) | **`Patchright`** (Playwright drop-in, 빌드 타임 Chromium 패치) | 헤드리스 탐지 신호를 브라우저 자체에서 제거. 표준 `nowsecure` 헤드리스 테스트 통과 |
| Chromium 한정 지문 검사 | **`Camoufox`** (Firefox stealth 포크) | 공격 표면이 다름. 대상이 Chromium만 검사할 때 유용 |
| Cloudflare Turnstile | `Patchright` 또는 `Camoufox` + 클릭 기반 solver | 외부 solver 서비스 없이 통과되는 경우가 많음 |
| TLS/JA3 지문 검사가 있는 API 경로 | **`curl_cffi`** (Python, Chrome JA3 임퍼소네이트) | 위 [`<tls_fingerprint>`](#tls_fingerprint) 참고 |
| reCAPTCHA v2 / hCaptcha | Solver 서비스 (2captcha, Capsolver) + 재시도 | 비용·합법성 명시 |

`Runtime.Enable` 메모: 일반 Puppeteer / Playwright는 attach 시 `Runtime.Enable`을 호출하고, Cloudflare/DataDome가 그 결과로 생기는 binding 누수를 읽어 자동화를 확인합니다. `rebrowser-patches`와 `Patchright`가 그 경로를 모두 막습니다 — Chromium 바이너리 교체가 가능한지에 따라 선택합니다.

브라우저 stealth만으로는 부족합니다. JA3가 네트워크 레이어에서 누수되면 무력해집니다. 브라우저 레이어(Patchright/rebrowser/Camoufox)와 네트워크 레이어(`curl_cffi` 또는 실제 브라우저 라운드트립)을 함께 적용합니다.

</tool_selection>
