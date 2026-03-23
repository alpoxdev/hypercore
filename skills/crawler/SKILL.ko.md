---
name: crawler
description: Playwriter로 웹사이트를 조사해 크롤링 방식을 결정하고, API/인증 근거를 `.hypercore/crawler/[site]/`에 문서화한 뒤, 발견 근거가 확보된 경우에만 크롤러 코드를 생성합니다.
---


# Crawler Skill

> Playwriter 탐방 → API/Network 분석 → 문서화 → 코드 생성

사용자가 재사용 가능한 크롤링 흐름, 사이트 추출 전략, 크롤링 목적의 API 리버스 엔지니어링, 분석 근거가 있는 크롤러 코드를 원할 때 `crawler`를 사용합니다.

일반 브라우저 자동화, 일회성 클릭 작업, 크롤링 산출물이 없는 문서 수정에는 `crawler`를 쓰지 않습니다.

재사용 가능한 크롤러 없이 단발성 추출만 원하면, 요청이 확장되기 전까지 전체 아티팩트 세트를 강제하지 말고 가볍게 처리합니다.

**Templates:** [document-templates.md](rules/document-templates.md) · [code-templates.md](rules/code-templates.md)
**Checklists:** [pre-crawl-checklist.md](rules/pre-crawl-checklist.md) · [anti-bot-checklist.md](rules/anti-bot-checklist.md)
**References:** [playwriter-commands.md](rules/playwriter-commands.md) · [crawling-patterns.md](rules/crawling-patterns.md) · [selector-strategies.md](rules/selector-strategies.md) · [network-crawling.md](rules/network-crawling.md)

---

<trigger_examples>

긍정 예시:

- "이 쇼핑몰 상품 카드를 크롤링해 줘. API부터 확인하고 크롤러도 만들어."
- "로그인 필요한 대시보드가 데이터를 어떻게 불러오는지 보고 쿠키와 헤더를 문서화해 줘."
- "Cloudflare가 있는 이 사이트를 분석해서 가장 안전한 크롤링 방식을 추천해 줘."

부정 예시:

- "이 사이트 열고 회원가입 플로우만 클릭해 줘."
- "이 크롤링 런북을 읽기 좋게 다시 써 줘."

경계 예시:

- "이 공개 페이지에서 가격 3개만 바로 뽑아 줘." 재사용 가능한 크롤러나 사이트 전반 전략이 필요해질 때까지는 가벼운 추출을 우선합니다.

</trigger_examples>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| 재사용 가능한 크롤링, 스크래핑, 사이트 전반 추출 | 즉시 실행 |
| 크롤링 목적의 사이트 조사 또는 API 리버스 엔지니어링 | discovery와 API 인터셉트 시작 |
| 단일 페이지에서의 일회성 추출 | 재사용 가능한 크롤링 요구가 없으면 경계 사례로 보고 가볍게 처리 |
| 봇 탐지 우회 또는 Cloudflare가 강한 대상 | 위험 점검과 Anti-Detect 가이드부터 시작 |

</trigger_conditions>

---

<support_file_routing>

보조 파일은 다음 순서로 읽습니다.

1. 크롤링 방식이나 코드 결정을 내리기 전에 [pre-crawl-checklist.md](rules/pre-crawl-checklist.md)부터 읽습니다.
2. 세션 제어, 구조 파악, 인터셉트 명령이 필요하면 [playwriter-commands.md](rules/playwriter-commands.md)를 읽습니다.
3. 쿠키, 토큰, 헤더, 봇 탐지 신호가 중요하면 [network-crawling.md](rules/network-crawling.md)을 읽습니다.
4. DOM 추출 가능성이 남아 있으면 [selector-strategies.md](rules/selector-strategies.md)를 읽습니다.
5. 페이지네이션, 인증, lazy loading, 재시도 전략이 중요하면 [crawling-patterns.md](rules/crawling-patterns.md)를 읽습니다.
6. 차단, CAPTCHA, Cloudflare, anti-detect 요구가 보이면 [anti-bot-checklist.md](rules/anti-bot-checklist.md)를 읽습니다.
7. `.hypercore/crawler/[site]/` 아티팩트를 작성할 때 [document-templates.md](rules/document-templates.md)를 읽습니다.
8. 방식이 결정되고 발견 근거가 문서화된 뒤에만 [code-templates.md](rules/code-templates.md)를 읽습니다.

</support_file_routing>

---

<mandatory_reasoning>

## 필수 Sequential Thinking

- 크롤링 설계, 추출 전략, 코드 생성 결정을 시작하기 전에 항상 `sequential-thinking`을 사용합니다.
- discovery, 방식 선택, 구현 계획의 각 주요 단계마다 `sequential-thinking`을 실행합니다.
- `sequential-thinking`을 사용할 수 없으면 구조화된 추론 없이 진행하지 말고 blocker를 보고합니다.

</mandatory_reasoning>

---

<execution_defaults>

- 코드 생성, selector 고정, 인증 가정보다 discovery를 먼저 합니다.
- discovery 결과 안정적인 API와 감당 가능한 인증 방식이 보이면 API 기반 크롤러를 우선합니다.
- 법적 제약, 반복되는 `403/429/503`, CAPTCHA, 강한 봇 탐지 신호로 자동화가 위험하면 중단하고 blocker를 보고합니다.
- 방식, 인증 재료, rate-limit 대응이 문서화되기 전에는 `CRAWLER.ts` 생성을 약속하지 않습니다.

</execution_defaults>

---

<workflow>

| Phase | 작업 | 명령어 |
|-------|------|--------|
| **1. 세션** | 생성 + 페이지 열기 | `playwriter session new` |
| **2. 탐색** | 구조 파악 | `accessibilitySnapshot`, `screenshotWithAccessibilityLabels` |
| **3. 분석** | API 인터셉트, Selector 추출 | `page.on('response')`, `getLocatorStringForElement` |
| **4. 문서화** | `.hypercore/crawler/[사이트]/` 저장 | Write |
| **5. 코드** | 크롤러 생성 | [code-templates.md](rules/code-templates.md) |

</workflow>

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
.hypercore/crawler/[사이트명]/
├── ANALYSIS.md      # 사이트 구조
├── SELECTORS.md     # DOM selector
├── API.md           # API endpoint
├── NETWORK.md       # 인증 정보
└── CRAWLER.ts       # 생성 코드
```

최소 아티팩트 계약:

- 재사용 가능한 크롤링 작업이면 `ANALYSIS.md`는 항상 필요합니다.
- DOM 추출을 사용하거나 fallback으로 남기면 `SELECTORS.md`가 필요합니다.
- API 발견을 시도했다면 `API.md`가 필요하며, usable API가 없더라도 그 사실을 기록합니다.
- 쿠키, 토큰, 헤더, rate limit, 봇 탐지 신호가 방식에 영향을 주면 `NETWORK.md`가 필요합니다.
- discovery 근거가 기록되고 선택한 방식의 정당성이 설명된 뒤에만 `CRAWLER.ts`가 필요합니다.

시작 명령과 점검 스니펫은 [playwriter-commands.md](rules/playwriter-commands.md)에 두고, 코어는 방식 선택, 산출물 게이트, 중단 조건에 집중합니다.

**Templates:** [document-templates.md](rules/document-templates.md)

</output_structure>

---

<blocked_outcomes>

차단되었거나 자동화가 안전하지 않은 실행에서는:

- `ANALYSIS.md`에 중단 원인, 그 판단의 근거, 가장 안전한 다음 단계를 기록합니다
- 인증 신호, 차단 응답, 봇 탐지 결과가 의사결정에 영향을 줬다면 `NETWORK.md`를 기록합니다
- blocker가 해소되거나 자동화 가능한 방식이 정해지기 전에는 `CRAWLER.ts`를 만들지 않습니다

</blocked_outcomes>

---

<validation>

```text
✅ playwriter 세션 생성
✅ accessibilitySnapshot 구조 파악
✅ API 인터셉트 시도
✅ selector 추출 검증
✅ .hypercore/crawler/ 문서화
✅ 크롤러 코드 생성
✅ 주요 단계별 sequential-thinking 기록
✅ 확장 전에 법적 제약, rate limit, 봇 탐지 blocker 문서화
✅ 크롤러 코드가 이르거나 위험할 때 blocked run을 명시적으로 보고
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

# 4. 문서화 → .hypercore/crawler/shop-example-com/
# 5. API 기반 크롤러 생성
```

</example>
