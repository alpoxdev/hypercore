---
name: crawler
description: Playwriter로 웹사이트 직접 탐방하여 크롤링 설계. API/쿠키/토큰/헤더 분석 후 문서화.
---


# Crawler Skill

> Playwriter 탐방 → API/Network 분석 → 문서화 → 코드 생성

**Templates:** [document-templates.md](rules/document-templates.md) · [code-templates.md](rules/code-templates.md)
**Checklists:** [pre-crawl-checklist.md](rules/pre-crawl-checklist.md) · [anti-bot-checklist.md](rules/anti-bot-checklist.md)
**References:** [playwriter-commands.md](rules/playwriter-commands.md) · [crawling-patterns.md](rules/crawling-patterns.md) · [selector-strategies.md](rules/selector-strategies.md) · [network-crawling.md](rules/network-crawling.md)

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| 크롤링, 스크래핑, crawl, scrape | 즉시 실행 |
| 웹사이트 데이터 추출 | 즉시 실행 |
| API 리버스 엔지니어링 | API 인터셉트 |
| 봇 탐지 우회 | Anti-Detect 참고 |

</trigger_conditions>

---

<workflow>

| Phase | 작업 | 명령어 |
|-------|------|--------|
| **1. 세션** | 생성 + 페이지 열기 | `playwriter session new` |
| **2. 탐색** | 구조 파악 | `accessibilitySnapshot`, `screenshotWithAccessibilityLabels` |
| **3. 분석** | API 인터셉트, Selector 추출 | `page.on('response')`, `getLocatorStringForElement` |
| **4. 문서화** | `.claude/crawler/[사이트]/` 저장 | Write |
| **5. 코드** | 크롤러 생성 | [code-templates.md](rules/code-templates.md) |

</workflow>

---

<quick_commands>

```bash
# 세션 생성 + 페이지 열기
playwriter session new
playwriter -s 1 -e "state.page = await context.newPage(); await state.page.goto('https://target.com')"

# 구조 파악
playwriter -s 1 -e "console.log(await accessibilitySnapshot({ page: state.page }))"

# API 인터셉트
playwriter -s 1 -e $'
state.responses = [];
state.page.on("response", async res => {
  if (res.url().includes("/api/")) {
    try { state.responses.push({ url: res.url(), body: await res.json() }); } catch {}
  }
});
'

# 인증 추출
playwriter -s 1 -e "console.log(JSON.stringify(await context.cookies(), null, 2))"
playwriter -s 1 -e "console.log(await state.page.evaluate(() => localStorage.getItem('token')))"

# Selector 변환
playwriter -s 1 -e "console.log(await getLocatorStringForElement(state.page.locator('aria-ref=e14')))"
```

</quick_commands>

---

<method_selection>

| 조건 | 방식 | 비고 |
|------|------|------|
| API 발견 + 인증 단순 | **fetch** | 가장 빠름 |
| API + 쿠키/토큰 필요 | **fetch + Cookie** | 만료 관리 필요 |
| 봇 탐지 강함 | **Nstbrowser** | Anti-Detect |
| API 없음 (SSR) | **Playwright DOM** | 직접 파싱 |

</method_selection>

---

<output_structure>

```
.claude/crawler/[사이트명]/
├── ANALYSIS.md      # 사이트 구조
├── SELECTORS.md     # DOM selector
├── API.md           # API endpoint
├── NETWORK.md       # 인증 정보
└── CRAWLER.ts       # 생성 코드
```

**Templates:** [document-templates.md](rules/document-templates.md)

</output_structure>

---

<validation>

```text
✅ playwriter 세션 생성
✅ accessibilitySnapshot 구조 파악
✅ API 인터셉트 시도
✅ selector 추출 검증
✅ .claude/crawler/ 문서화
✅ 크롤러 코드 생성
```

</validation>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **분석** | 구조 파악 없이 selector 추측 |
| **방식** | API 확인 없이 DOM만 시도 |
| **문서** | 분석 결과 문서화 생략 |
| **네트워크** | Rate limiting 미고려 |

</forbidden>

---

<example>

```bash
# 사용자: /crawler https://shop.example.com 상품 크롤링

# 1. 세션
playwriter session new  # => 1
playwriter -s 1 -e "state.page = await context.newPage(); await state.page.goto('https://shop.example.com/products')"

# 2. 구조 파악
playwriter -s 1 -e "console.log(await accessibilitySnapshot({ page: state.page }))"
# => list "Products" [ref=e5]: listitem [ref=e6]: link "Product A" [ref=e7]

# 3. API 확인 (스크롤 트리거)
playwriter -s 1 -e "await state.page.evaluate(() => window.scrollTo(0, 9999))"
playwriter -s 1 -e "console.log(state.responses.map(r => r.url))"
# => ["/api/products?page=2"]

# 4. 문서화 → .claude/crawler/shop-example-com/
# 5. API 기반 크롤러 생성
```

</example>
