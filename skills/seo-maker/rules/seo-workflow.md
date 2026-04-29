# SEO Workflow

**Purpose**: Phase-by-phase execution rules for SEO audits.

## 1. Scope Phase

Define what to audit before scanning:

- Target URLs or file paths (single page, section, or full site)
- Focus area: technical only, on-page only, content only, or comprehensive
- Framework context: Next.js, static HTML, SPA, etc.
- Known constraints: no access to Search Console, no production URL, local-only

Output: scope summary with target list and focus areas.

## 2. Measurement Phase

Establish what can actually be measured before scoring:

- Access level: live URL, local-only files, Search Console, analytics, field Core Web Vitals, AI citation probe access
- Evidence grade for each method: `official`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`
- Confidence impact: lower confidence when relying on local static scans instead of live crawl, Search Console, or field data
- Measurement methods to record in `results.json.measurement_methods`

Do not compare a field-data audit with a lab-only or local-only audit without recording the confidence difference.

## 3. Technical SEO Phase

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

## 4. Platform Policy Phase

Inspect crawler and AI/search visibility controls separately by platform:

- Googlebot and standard robots directives for indexing and snippets
- Google-Extended for Google AI training/product controls where relevant
- OAI-SearchBot for ChatGPT Search inclusion; GPTBot for OpenAI training; ChatGPT-User for user-triggered fetches
- PerplexityBot, ClaudeBot, and other AI crawlers when robots.txt or server rules mention them
- `nosnippet`, `data-nosnippet`, `max-snippet`, `noindex`, canonical, and X-Robots-Tag effects
- `llms.txt` as an optional machine-readable map, not a guaranteed ranking or citation mechanism

Record policy findings with high confidence only when backed by official docs or directly observed files/headers.

## 5. On-Page SEO Phase

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

## 6. Content SEO Phase

Evaluate for:

- E-E-A-T signals — experience, expertise, authoritativeness, trustworthiness
- Keyword placement — title, first paragraph, headings, naturally distributed
- Keyword and entity usage — natural placement in title, intro, headings, body, and alt text without stuffing or fixed-density targets
- Content depth — sufficient coverage of the topic, minimum 300+ words for indexable pages
- Readability — short paragraphs, clear structure, scannable with headings
- Freshness — dates present, content not stale
- Uniqueness — no obvious duplicate content across pages
- AI content — if AI-generated, evidence of human editing and value-add

Tools: `Read` for content analysis, `WebSearch` for competitor/SERP context if needed.

## 7. AEO Phase (Answer Engine Optimization)

Evaluate readiness for AI direct answers and Featured Snippets:

- **Q&A 포맷** — 주요 질문에 대한 concise visible answer block이 콘텐츠 상단 근처에 있는가 (고정 길이는 heuristic)
- **Featured Snippet 최적화** — 정의형, 리스트형, 테이블형 Snippet에 적합한 구조인가
- **음성 검색 대비** — 자연어 질문 형식의 제목/소제목이 있는가
- **답변 추출 용이성** — 짧은 단락(2-3문장), 명확한 H2/H3 구조로 AI가 답변을 추출하기 쉬운가
- **FAQ/Q&A 구조** — visible FAQ/Q&A가 있고, Google FAQ rich result eligibility와 answer-friendly content를 구분했는가
- **플랫폼별 콘텐츠 선호도** — ChatGPT(백과사전적), Perplexity(커뮤니티), Google AI Overviews(멀티모달) 각각에 대한 콘텐츠 적합성

Tools: `Grep` for Q&A patterns, heading structures. `Read` for content analysis. See `references/aeo-geo-guide.md` for strategy details.

## 8. GEO Phase (Generative Engine Optimization)

Evaluate readiness for AI citation in generative responses:

- **GEO CORE 평가**:
  - **Context** — 주제에 대한 충분한 맥락과 배경이 제공되는가
  - **Organization** — 명확한 계층 구조, 추출 가능한 형식인가
  - **Reliability** — 검증 가능한 통계, 인용, 전문가 의견이 포함되는가
  - **Exclusivity** — 독점 데이터, 원본 연구, 고유 관점이 있는가
- **엔터티 권위** — 토픽 클러스터 구성, 여러 콘텐츠에 걸친 지식 일관성
- **인용 가능한 문장** — 짧고 독립적으로 인용 가능한 문장 (통계 포함)
- **콘텐츠 신선도** — 주제의 시간 민감도에 맞는 갱신 일자와 source date가 있는가
- **llms.txt** — optional LLM-facing content map 존재 여부와 canonical/sitemap 정합성
- **스키마 마크업 AI 신뢰 신호** — JSON-LD가 visible entity information과 일치하는가 (AI citation 보장은 아님)

Tools: `Grep` for citation patterns, statistics. `Read` for content freshness. `Glob` for llms.txt. See `references/aeo-geo-guide.md` for GEO CORE framework and platform benchmarks.

Optional high-confidence extensions when access allows:

- **Query fan-out simulator** — generate 10-30 subqueries from the target topic and map missing coverage before recommending content expansion.
- **AI citation probe** — run or prepare a stable prompt set for ChatGPT, Perplexity, Gemini, or other engines; record engine, date, sample size, cited URLs, brand mentions, and unresolved volatility.

## 9. Score Optimization Phase (Optimize Mode Only)

Run this phase when the user asks for the highest score, max score, perfect score, or repeated improvement.

1. **Baseline first** — before changing files or recommendations, write the current category average, `overall_grade`, critical-finding count, and target score to `results.json.score_history[0]`.
2. **Stable evaluator** — keep the same scoring categories and pass/fail checks for all iterations. If the evaluator changes, record a reset event and do not compare the new score with old runs.
3. **One change per iteration** — choose one high-impact change or one tightly related recommendation set. Avoid bundling unrelated technical, content, and AEO/GEO changes in the same iteration.
4. **Re-audit after every change** — update category scores, findings, quick wins, and evidence. Append an iteration record with `iteration`, `changed`, `score`, `critical_count`, `decision`, and `evidence`.
5. **Keep best run** — if the score improves or critical findings decrease without score regression, mark the iteration `kept` and update `best_run`. If not, rollback/revert code changes where possible or mark the iteration `discarded`.
6. **Continue/stop gates** — continue while score improves. Stop only when target score passes, a validator/architect review approves, user stops, budget is exhausted, or the score plateaus for 3 consecutive iterations.
7. **Completion artifact** — finish with `results.json.status: "complete"`, populated `score_history`, populated `best_run`, and validator evidence explaining why the final score is the best available run.

Do not interpret “infinite loop” literally. The correct behavior is persistent measured continuation with rollback, plateau detection, and artifact-gated completion.

## 10. Report Phase

Compile findings into `report.md`:

1. Executive summary with overall SEO health score (A/B/C/D/F)
2. Findings grouped by category (Technical SEO, On-Page SEO, Content SEO, Core Web Vitals, Structured Data, AEO Readiness, GEO Readiness)
3. Each finding has: severity (critical/warning/info), description, location, fix recommendation
4. Prioritized action items sorted by impact
5. Quick wins section for low-effort/high-impact fixes

Write evidence and raw data to `sources.md`.

## Optimize Mode Rules

- Use `optimize` when the user explicitly requests highest score / max score / perfect score / 계속 반복 / 무한반복.
- Start from `create` or `update` audit output, then enter the Score Optimization Phase.
- Preserve the best-scoring report and dashboard even when later experiments are discarded.
- If implementation edits are allowed, verify each kept code-changing iteration with relevant project checks before treating it as `best_run`.

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
