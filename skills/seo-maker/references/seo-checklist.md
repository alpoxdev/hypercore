# SEO Audit Checklist

**Purpose**: Actionable item-by-item checklist for scanning. Use during each audit phase.

## Technical SEO Checklist

### Crawling & Indexing

- [ ] `robots.txt` exists at root and doesn't block important pages
- [ ] `sitemap.xml` exists, is valid, and includes all indexable pages
- [ ] `sitemap.xml` is referenced in `robots.txt`
- [ ] No unintentional `noindex` directives on indexable pages
- [ ] Canonical tags present and pointing to correct URLs
- [ ] No orphan pages (pages not linked from anywhere)

### HTTPS & Security

- [ ] HTTPS enforced site-wide
- [ ] No mixed content (HTTP resources on HTTPS pages)
- [ ] Valid SSL certificate
- [ ] HTTP → HTTPS redirects in place (301)

### Performance & Core Web Vitals

- [ ] LCP target: < 2.5s — check hero image optimization, preloading
- [ ] INP target: < 200ms — check JavaScript execution, event handlers
- [ ] CLS target: < 0.1 — check image dimensions, dynamic content insertion
- [ ] Images optimized (WebP/AVIF, proper sizing, lazy loading for below-fold)
- [ ] Critical CSS inlined or preloaded
- [ ] JavaScript bundle size reasonable, code-split where possible

### Structured Data

- [ ] JSON-LD schema markup present on key pages
- [ ] Schema validates without errors (Schema Markup Validator)
- [ ] Appropriate schema types for content (Article, Product, FAQ, etc.)

### Mobile

- [ ] `<meta name="viewport" content="width=device-width, initial-scale=1">` present
- [ ] Responsive design — no horizontal scroll on mobile
- [ ] Touch targets ≥ 48px
- [ ] Font size ≥ 16px for body text

### URL Structure

- [ ] Clean, descriptive URLs (kebab-case, lowercase)
- [ ] No unnecessary query parameters in indexable URLs
- [ ] Proper 301 redirects for moved/renamed pages
- [ ] No redirect chains (A→B→C, should be A→C)

## On-Page SEO Checklist

### Title & Meta

- [ ] `<title>` unique per page, under 60 characters
- [ ] `<title>` includes primary keyword naturally
- [ ] `<meta name="description">` exists, 150–160 characters
- [ ] Meta description is compelling and includes a call to action or value proposition
- [ ] No duplicate titles or descriptions across pages

### Headings

- [ ] Single `<h1>` per page
- [ ] `<h1>` includes primary keyword
- [ ] Logical heading hierarchy: h1 → h2 → h3 (no skipped levels)
- [ ] Headings are descriptive, not generic ("Section 1")

### Images

- [ ] All `<img>` have descriptive `alt` attributes
- [ ] Alt text includes relevant keywords where natural
- [ ] Images have explicit `width` and `height` (CLS prevention)
- [ ] Decorative images use `alt=""`

### Social Meta Tags

- [ ] `og:title`, `og:description`, `og:image`, `og:url` present
- [ ] `og:image` is at least 1200×630px
- [ ] `twitter:card` set to `summary_large_image` or `summary`
- [ ] `twitter:title`, `twitter:description` present

### Internal Links

- [ ] Important pages are linked from navigation or content
- [ ] Anchor text is descriptive (not "click here")
- [ ] 3–5 internal links per 1,000 words of content
- [ ] No broken internal links (404s)

## Content SEO Checklist

### Quality & Relevance

- [ ] Content matches search intent for target keyword
- [ ] Sufficient depth — minimum 300 words for indexable pages
- [ ] Original content — no duplicate from other pages or sites
- [ ] Updated within last 12 months for time-sensitive topics

### Keyword Usage

- [ ] Primary keyword in title, H1, first 100 words
- [ ] Keyword density 1–2% (natural, not stuffed)
- [ ] Semantic variations and related terms used throughout
- [ ] No keyword cannibalization (multiple pages targeting same keyword)

### E-E-A-T Signals

- [ ] Author information visible (bio, credentials)
- [ ] Sources cited for factual claims
- [ ] Contact information accessible
- [ ] Privacy policy and terms of service present
- [ ] Clear disclosure for sponsored/affiliate content

### Readability

- [ ] Short paragraphs (2–4 sentences)
- [ ] Subheadings every 200–300 words
- [ ] Bullet points and lists for scannable content
- [ ] Clear, jargon-free language (unless technical audience)

## AEO (Answer Engine Optimization) Checklist

### Direct Answer Structure

- [ ] 주요 질문에 40-60 단어 직접 답변이 섹션 상단에 배치
- [ ] 질문 형식 H2/H3 제목 사용 (예: "## X란 무엇인가?")
- [ ] 정의형 문장: "[용어]는 [정의]이다" 패턴 포함
- [ ] 리스트형/테이블형 콘텐츠로 Featured Snippet 대응

### FAQ & Schema

- [ ] FAQ 섹션에 JSON-LD FAQPage 스키마 적용
- [ ] FAQ 답변 길이 40-60 단어
- [ ] HowTo 콘텐츠에 HowTo 스키마 적용

### Voice Search

- [ ] 자연어 질문 형식의 소제목 (Who, What, Where, When, Why, How)
- [ ] 대화체 답변 구조
- [ ] 간결하고 직접적인 답변 (음성 어시스턴트가 읽을 수 있는 길이)

## GEO (Generative Engine Optimization) Checklist

### GEO CORE — Context

- [ ] 주제에 대한 충분한 맥락과 배경 제공
- [ ] 관련 개념과 정의 포함
- [ ] 주제의 범위가 명확히 정의됨

### GEO CORE — Organization

- [ ] 명확한 H2/H3 계층 구조
- [ ] 각 섹션 상단에 2-3문장 핵심 요약
- [ ] 짧은 단락 (2-3문장), 글머리 기호, 표 활용
- [ ] AI가 독립적으로 추출 가능한 단락 구성

### GEO CORE — Reliability

- [ ] 검증 가능한 통계와 수치 데이터 포함
- [ ] 명시적 출처 인용 (저자명, 기관명, 날짜)
- [ ] 전문가 의견 또는 사례 연구 포함
- [ ] E-E-A-T 신호 강화 (저자 정보, 자격, 연락처)

### GEO CORE — Exclusivity

- [ ] 독점 데이터, 자체 연구, 벤치마크 포함
- [ ] 고유한 관점이나 프레임워크 제공
- [ ] 다른 곳에서 찾을 수 없는 인사이트 존재

### Entity Authority

- [ ] 토픽 클러스터 구성 (pillar + cluster)
- [ ] 관련 콘텐츠 간 내부 링크 연결
- [ ] Organization/Person 스키마로 엔터티 명시
- [ ] 여러 콘텐츠에 걸친 일관된 전문성 표현

### Content Freshness

- [ ] 주요 콘텐츠가 3개월 이내 업데이트됨
- [ ] `dateModified` 스키마 마크업 포함
- [ ] 시간에 민감한 데이터에 정확한 날짜 명시

### AI Crawler Access

- [ ] `llms.txt` 존재 여부 확인
- [ ] `robots.txt`에서 AI 크롤러 (GPTBot, ClaudeBot, Bytespider 등) 차단 여부 확인
- [ ] 주요 콘텐츠가 JavaScript 렌더링 없이 접근 가능
