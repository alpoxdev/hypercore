# SEO 감사 체크리스트

**목적**: 스캔 중 사용할 실행 가능한 항목별 체크리스트. 각 감사 phase에서 사용한다.

## 측정 및 신뢰도 체크리스트

- [ ] 접근 수준 기록: live URL, local files, Search Console, analytics, field Core Web Vitals, AI citation probe.
- [ ] 각 증거 채널에 `official`, `field`, `tool`, `lab`, `synthetic`, `heuristic` 라벨이 있음.
- [ ] 누락된 live/field/probe data는 숨기지 않고 신뢰도를 낮춤.
- [ ] 발견사항에 `evidence_grade`, `confidence`, `measurement_method`, `source_tier`가 포함됨.

## Technical SEO 체크리스트

### 크롤링 및 색인

- [ ] `robots.txt`가 root에 있고 중요한 페이지를 차단하지 않음
- [ ] `sitemap.xml`이 존재하고 유효하며 모든 색인 가능 페이지를 포함함
- [ ] `sitemap.xml`이 `robots.txt`에서 참조됨
- [ ] 색인 가능 페이지에 의도치 않은 `noindex` 지시문이 없음
- [ ] Canonical tags가 있고 올바른 URL을 가리킴
- [ ] Orphan pages가 없음(어디에서도 링크되지 않은 페이지)

### HTTPS 및 보안

- [ ] HTTPS가 사이트 전체에 강제됨
- [ ] Mixed content가 없음(HTTPS 페이지의 HTTP 리소스)
- [ ] 유효한 SSL certificate
- [ ] HTTP → HTTPS redirects가 있음(301)

### Performance 및 Core Web Vitals

- [ ] Field data가 있을 때 LCP target: p75에서 ≤ 2.5s — hero image optimization, preloading 확인
- [ ] Field data가 있을 때 INP target: p75에서 ≤ 200ms — JavaScript execution, event handlers 확인
- [ ] Field data가 있을 때 CLS target: p75에서 ≤ 0.1 — image dimensions, dynamic content insertion 확인
- [ ] Images optimized(WebP/AVIF, proper sizing, below-fold lazy loading)
- [ ] Critical CSS가 inline 또는 preloaded
- [ ] JavaScript bundle size가 합리적이고 필요 시 code-split됨

### Structured Data

- [ ] 핵심 페이지에 JSON-LD schema markup 존재
- [ ] Schema가 오류 없이 검증됨(Schema Markup Validator)
- [ ] 보이는 콘텐츠에 적합한 schema type(Article, Product, eligible FAQPage/QAPage 등)

### Mobile

- [ ] `<meta name="viewport" content="width=device-width, initial-scale=1">` 존재
- [ ] Responsive design — 모바일에서 horizontal scroll 없음
- [ ] Touch targets ≥ 48px
- [ ] Body text font size ≥ 16px

### URL Structure

- [ ] 깔끔하고 설명적인 URL(kebab-case, lowercase)
- [ ] 색인 가능 URL에 불필요한 query parameters 없음
- [ ] 이동/이름 변경 페이지에 적절한 301 redirects
- [ ] Redirect chains 없음(A→B→C가 아니라 A→C)

## 플랫폼 정책 체크리스트

- [ ] Googlebot indexing/snippet access를 AI training controls와 별도로 확인함.
- [ ] Google-Extended policy는 관련 있을 때만 확인함.
- [ ] OAI-SearchBot과 GPTBot을 ChatGPT Search와 OpenAI training 관점에서 별도로 평가함.
- [ ] `nosnippet`, `data-nosnippet`, `max-snippet`, `noindex`, canonical, X-Robots-Tag 효과를 확인함.
- [ ] High confidence로 표시된 권장사항은 official docs 또는 observed files/headers를 인용함.

## On-Page SEO 체크리스트

### Title 및 Meta

- [ ] `<title>`이 페이지별로 고유하고 60자 이하
- [ ] `<title>`에 primary keyword가 자연스럽게 포함됨
- [ ] `<meta name="description">`이 있고 150-160자
- [ ] Meta description이 설득력 있고 call to action 또는 value proposition 포함
- [ ] 페이지 간 duplicate titles 또는 descriptions 없음

### Headings

- [ ] 페이지당 하나의 `<h1>`
- [ ] `<h1>`에 primary keyword 포함
- [ ] 논리적 heading hierarchy: h1 → h2 → h3(건너뛴 level 없음)
- [ ] Headings가 설명적이고 generic하지 않음("Section 1" 아님)

### Images

- [ ] 모든 `<img>`에 descriptive `alt` attributes 있음
- [ ] 자연스러울 때 alt text에 관련 keywords 포함
- [ ] Images에 explicit `width`와 `height` 있음(CLS prevention)
- [ ] Decorative images는 `alt=""` 사용

### Social Meta Tags

- [ ] `og:title`, `og:description`, `og:image`, `og:url` 존재
- [ ] `og:image`가 최소 1200×630px
- [ ] `twitter:card`가 `summary_large_image` 또는 `summary`
- [ ] `twitter:title`, `twitter:description` 존재

### Internal Links

- [ ] 중요한 페이지가 navigation 또는 content에서 링크됨
- [ ] Anchor text가 설명적임("click here" 아님)
- [ ] 콘텐츠 1,000단어당 3-5개 internal links
- [ ] Broken internal links(404) 없음

## Content SEO 체크리스트

### 품질 및 관련성

- [ ] 콘텐츠가 target keyword의 search intent와 일치
- [ ] 충분한 깊이 — indexable pages는 최소 300 words
- [ ] Original content — 다른 페이지나 사이트의 duplicate가 아님
- [ ] 시간 민감 주제는 최근 12개월 내 업데이트됨

### Keyword Usage

- [ ] Primary keyword가 title, H1, first 100 words에 있음
- [ ] Keywords와 related entities가 자연스럽게 나타남. fixed-density target 또는 stuffing 없음
- [ ] Semantic variations와 related terms가 전체에 사용됨
- [ ] Keyword cannibalization 없음(여러 페이지가 같은 keyword targeting하지 않음)

### E-E-A-T Signals

- [ ] Author information 표시(bio, credentials)
- [ ] Factual claims에 sources cited
- [ ] Contact information 접근 가능
- [ ] Privacy policy와 terms of service 존재
- [ ] Sponsored/affiliate content에 명확한 disclosure

### Readability

- [ ] 짧은 단락(2-4문장)
- [ ] 200-300단어마다 subheadings
- [ ] Bullet points와 lists로 스캔 가능
- [ ] 명확하고 jargon-free language(technical audience가 아닌 경우)

## AEO(Answer Engine Optimization) 체크리스트

### Direct Answer Structure

- [ ] 주요 질문에 대한 concise visible answer block이 섹션 상단 근처에 있음(길이 규칙은 heuristic)
- [ ] 질문형 H2/H3 headings 사용, 예: "## What is X?"
- [ ] Definition-style sentences가 "[Term] is [definition]" 패턴을 따름
- [ ] List 또는 table content가 Featured Snippet extraction을 지원함

### FAQ 및 Schema

- [ ] FAQPage와 QAPage 사용 조건을 구분하고 Google rich result eligibility를 과장하지 않음
- [ ] FAQ/Q&A answers가 visible content와 structured data에 일치함
- [ ] HowTo schema가 HowTo content에 적용됨

### Voice Search

- [ ] Natural-language question-style subheadings 사용(Who, What, Where, When, Why, How)
- [ ] Conversational answer structure 존재
- [ ] Answers가 voice assistants가 읽을 수 있을 만큼 concise and direct함

## GEO(Generative Engine Optimization) 체크리스트

### GEO CORE — Context

- [ ] 주제에 대한 충분한 context와 background 제공
- [ ] Related concepts와 definitions 포함
- [ ] Topic scope가 명확히 정의됨

### GEO CORE — Organization

- [ ] 명확한 H2/H3 hierarchy 존재
- [ ] 각 section이 2-3문장 key summary로 시작
- [ ] Short paragraphs(2-3 sentences), bullets, tables 사용
- [ ] Paragraphs가 AI systems에 의해 독립적으로 extract 가능

### GEO CORE — Reliability

- [ ] Verifiable statistics와 numeric data 포함
- [ ] Explicit source citations 포함(author name, organization, date)
- [ ] Expert opinions 또는 case studies 포함
- [ ] E-E-A-T signals 강화(author information, credentials, contact details)

### GEO CORE — Exclusivity

- [ ] Proprietary data, original research, 또는 benchmarks 포함
- [ ] Unique perspective 또는 framework 제공
- [ ] 다른 곳에서 찾을 수 없는 insights 존재

### Entity Authority

- [ ] Topic clusters 구성(pillar + cluster)
- [ ] Internal links가 related content를 연결
- [ ] Organization/Person schema가 entities를 식별
- [ ] 여러 콘텐츠 전반에 consistent expertise 표현

### Content Freshness

- [ ] Content freshness가 topic의 time sensitivity와 일치하고 `dateModified`/source dates가 정확함
- [ ] `dateModified` schema markup 포함
- [ ] Time-sensitive data에 exact dates 포함

### AI Crawler Access

- [ ] `llms.txt`를 optional content map으로 확인하고 missing file을 기본 critical로 처리하지 않음
- [ ] `robots.txt`에서 OAI-SearchBot(search), GPTBot(training), ChatGPT-User(user fetch), ClaudeBot/PerplexityBot 등 crawler별 목적 기반 차단 여부 확인
- [ ] Important content가 JavaScript rendering 없이 접근 가능
