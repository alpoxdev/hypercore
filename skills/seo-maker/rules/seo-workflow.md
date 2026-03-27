# SEO Workflow

**Purpose**: Phase-by-phase execution rules for SEO audits.

## 1. Scope Phase

Define what to audit before scanning:

- Target URLs or file paths (single page, section, or full site)
- Focus area: technical only, on-page only, content only, or comprehensive
- Framework context: Next.js, static HTML, SPA, etc.
- Known constraints: no access to Search Console, no production URL, local-only

Output: scope summary with target list and focus areas.

## 2. Technical SEO Phase

Scan for:

- `robots.txt` — exists, correct directives, no accidental blocks
- `sitemap.xml` — exists, valid, includes all indexable pages
- Canonical tags — present, self-referencing or correct cross-referencing
- Structured data — JSON-LD schema markup exists and validates
- HTTPS — enforced, no mixed content
- Core Web Vitals code patterns — image optimization, layout shift prevention, input responsiveness
- Mobile viewport — `<meta name="viewport">` present and correct
- HTTP status codes — no broken links, proper redirects (301 vs 302)
- Clean URL structure — descriptive, kebab-case, no query string abuse

Tools: `Glob`, `Grep`, `Read` for file scanning. `WebFetch` for live URL analysis if available.

## 3. On-Page SEO Phase

Scan for:

- `<title>` — exists, unique per page, under 60 characters, includes primary keyword
- `<meta name="description">` — exists, 150–160 characters, compelling, includes keyword
- Heading hierarchy — single `<h1>` per page, logical `h2`→`h3`→`h4` nesting
- Image alt text — all `<img>` have descriptive `alt` attributes
- Open Graph tags — `og:title`, `og:description`, `og:image`, `og:url`
- Twitter Card tags — `twitter:card`, `twitter:title`, `twitter:description`
- Internal links — descriptive anchor text, contextual relevance, 3–5 per 1,000 words
- URL slug — descriptive, keyword-relevant, no unnecessary parameters

Tools: `Grep` for pattern matching (`<title>`, `<meta`, `<h1>`, `alt=`), `Read` for page content.

## 4. Content SEO Phase

Evaluate for:

- E-E-A-T signals — experience, expertise, authoritativeness, trustworthiness
- Keyword placement — title, first paragraph, headings, naturally distributed
- Keyword density — 1–2% natural density, no stuffing
- Content depth — sufficient coverage of the topic, minimum 300+ words for indexable pages
- Readability — short paragraphs, clear structure, scannable with headings
- Freshness — dates present, content not stale
- Uniqueness — no obvious duplicate content across pages
- AI content — if AI-generated, evidence of human editing and value-add

Tools: `Read` for content analysis, `WebSearch` for competitor/SERP context if needed.

## 5. AEO Phase (Answer Engine Optimization)

Evaluate readiness for AI direct answers and Featured Snippets:

- **Q&A 포맷** — 주요 질문에 40-60 단어의 직접 답변이 콘텐츠 상단에 있는가
- **Featured Snippet 최적화** — 정의형, 리스트형, 테이블형 Snippet에 적합한 구조인가
- **음성 검색 대비** — 자연어 질문 형식의 제목/소제목이 있는가
- **답변 추출 용이성** — 짧은 단락(2-3문장), 명확한 H2/H3 구조로 AI가 답변을 추출하기 쉬운가
- **FAQPage 스키마** — FAQ 섹션에 JSON-LD FAQPage 마크업이 있는가
- **플랫폼별 콘텐츠 선호도** — ChatGPT(백과사전적), Perplexity(커뮤니티), Google AI Overviews(멀티모달) 각각에 대한 콘텐츠 적합성

Tools: `Grep` for Q&A patterns, heading structures. `Read` for content analysis. See `references/aeo-geo-guide.md` for strategy details.

## 6. GEO Phase (Generative Engine Optimization)

Evaluate readiness for AI citation in generative responses:

- **GEO CORE 평가**:
  - **Context** — 주제에 대한 충분한 맥락과 배경이 제공되는가
  - **Organization** — 명확한 계층 구조, 추출 가능한 형식인가
  - **Reliability** — 검증 가능한 통계, 인용, 전문가 의견이 포함되는가
  - **Exclusivity** — 독점 데이터, 원본 연구, 고유 관점이 있는가
- **엔터티 권위** — 토픽 클러스터 구성, 여러 콘텐츠에 걸친 지식 일관성
- **인용 가능한 문장** — 짧고 독립적으로 인용 가능한 문장 (통계 포함)
- **콘텐츠 신선도** — 3개월 이내 업데이트 여부 (AI 인용 임계값)
- **llms.txt** — AI 크롤러 정책 파일 존재 여부
- **스키마 마크업 AI 신뢰 신호** — JSON-LD가 엔터티 검증 역할을 하는가

Tools: `Grep` for citation patterns, statistics. `Read` for content freshness. `Glob` for llms.txt. See `references/aeo-geo-guide.md` for GEO CORE framework and platform benchmarks.

## 7. Report Phase

Compile findings into `report.md`:

1. Executive summary with overall SEO health score (A/B/C/D/F)
2. Findings grouped by category (Technical, On-Page, Content, AEO, GEO)
3. Each finding has: severity (critical/warning/info), description, location, fix recommendation
4. Prioritized action items sorted by impact
5. Quick wins section for low-effort/high-impact fixes

Write evidence and raw data to `sources.md`.

## Mode Rules

### Create mode

- Full analysis from scratch
- All phases run sequentially
- Template-based report generation

### Update mode

- Read existing `report.md` first
- Only re-analyze changed or newly requested areas
- Append dated changelog entry to report
- Preserve prior findings unless superseded

## Research Rule

- If the audit needs live SERP data, competitor analysis, or current ranking info, run web searches with specific queries.
- If the user already provided sufficient context, do not force unnecessary external research.
- Record all external queries and sources in `sources.md`.
