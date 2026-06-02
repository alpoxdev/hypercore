# Playwriter 명령어

> 크롤링 분석용 핵심 명령어

워크플로가 Playwriter 기반 discovery로 정해진 뒤, 실제 세션 제어, 상호작용, 구조 파악, selector 검증 명령이 필요할 때 `pre-crawl-checklist.md` 다음으로 이 파일을 사용합니다. 더 적은 토큰으로 네트워크/인증 근거를 수집할 때는 `cdp-capture.md`를 사용합니다.

---

<session>

## 세션

```bash
playwriter session new      # 생성 → ID 반환
playwriter session list     # 목록
playwriter session reset 1  # 리셋
```

</session>

---

<execution>

## 실행

```bash
playwriter -s 1 -e "<code>"
playwriter -s 1 --timeout 20000 -e "<code>"  # 타임아웃 증가
```

</execution>

---

<page>

## 페이지

```javascript
// 생성 + 이동
state.page = await context.newPage();
await state.page.goto('https://example.com', { waitUntil: 'domcontentloaded' });

// 기존 페이지 찾기
state.page = context.pages().find(p => p.url().includes('example.com'));
```

</page>

---

<structure>

## 구조 파악

```javascript
// 접근성 트리 (권장)
await accessibilitySnapshot({ page: state.page })
await accessibilitySnapshot({ page: state.page, search: /button|link/ })

// 시각적 확인
await screenshotWithAccessibilityLabels({ page: state.page })

// HTML
await getCleanHTML({ locator: state.page.locator('body') })
```

</structure>

---

<interaction>

## 상호작용

```javascript
// 클릭
await page.locator('aria-ref=e14').click()
await page.getByRole('button', { name: 'Submit' }).click()

// 입력
await page.locator('input[name="email"]').fill('test@example.com')

// 스크롤
await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight))
```

</interaction>

---

<selector>

## Selector 추출

```javascript
// aria-ref → Playwright selector
const sel = await getLocatorStringForElement(page.locator('aria-ref=e14'));
// => "getByRole('button', { name: 'Save' })"
```

</selector>

---

<network>

## 네트워크 인터셉트 fallback

```javascript
state.requests = []; state.responses = [];
page.on('request', req => {
  if (req.url().includes('/api/'))
    state.requests.push({ url: req.url(), method: req.method(), headers: req.headers() });
});
page.on('response', async res => {
  if (res.url().includes('/api/'))
    try { state.responses.push({ url: res.url(), body: await res.json() }); } catch {}
});

// 분석
state.responses.forEach(r => console.log(r.url));

// 정리
page.removeAllListeners('request');
page.removeAllListeners('response');
```

CDP를 쓸 수 없거나 간단한 브라우저 측 fallback이면 이 방식을 사용합니다.

</network>

---

<screenshot>

## 스크린샷

```javascript
await page.screenshot({ path: 'shot.png', scale: 'css' })
await page.screenshot({ path: 'full.png', scale: 'css', fullPage: true })
await page.locator('.card').screenshot({ path: 'card.png', scale: 'css' })
```

</screenshot>

---

<wait>

## 대기

```javascript
await page.waitForLoadState('domcontentloaded')
await page.waitForSelector('.loaded')
await waitForPageLoad({ page: state.page, timeout: 5000 })
```

</wait>

---

<utils>

## 유틸리티

| 함수 | 용도 |
|------|------|
| `accessibilitySnapshot({ page })` | 접근성 트리 |
| `screenshotWithAccessibilityLabels({ page })` | 레이블 스크린샷 |
| `getCleanHTML({ locator })` | 정제된 HTML |
| `getLocatorStringForElement(locator)` | Selector 추출 |
| `waitForPageLoad({ page })` | 로드 대기 |

</utils>
