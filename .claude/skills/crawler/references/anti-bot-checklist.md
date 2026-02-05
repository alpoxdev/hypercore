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

## 도구 선택

| 조건 | 도구 |
|------|------|
| 봇 탐지 없음 | Playwright |
| 기본 탐지 | Playwright + Stealth |
| 고급 탐지 | Nstbrowser |
| Cloudflare | Anti-Detect 필수 |

</tool_selection>
