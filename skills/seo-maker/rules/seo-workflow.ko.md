# SEO 워크플로

**목적**: SEO 감사의 phase별 실행 규칙.

## 1. 범위 Phase

스캔 전에 감사 대상을 정의한다:

- 대상 URL 또는 file paths(single page, section, full site)
- Focus area: technical only, on-page only, content only, comprehensive
- Framework context: Next.js, static HTML, SPA 등
- Known constraints: Search Console 접근 없음, production URL 없음, local-only

출력: 대상 목록과 focus areas가 포함된 scope summary.

## 2. 측정 Phase

점수화 전에 실제로 측정 가능한 것을 확립한다:

- Access level: live URL, local-only files, Search Console, analytics, field Core Web Vitals, AI citation probe access
- 각 방법의 evidence grade: `official`, `field`, `tool`, `lab`, `synthetic`, `heuristic`
- Confidence impact: live crawl, Search Console, field data 대신 local static scans에 의존할 때 낮은 신뢰도
- `results.json.measurement_methods`에 기록할 measurement methods

Confidence difference를 기록하지 않고 field-data audit을 lab-only 또는 local-only audit과 비교하지 않는다.

## 3. Technical SEO Phase

다음을 스캔한다:

- `robots.txt` — 존재 여부, 올바른 directives, accidental blocks 없음
- `sitemap.xml` — 존재, 유효, 모든 indexable pages 포함
- Canonical tags — 존재, self-referencing 또는 올바른 cross-referencing
- Structured data — JSON-LD schema markup 존재 및 검증
- HTTPS — 강제 적용, mixed content 없음
- Core Web Vitals code patterns — image optimization, layout shift prevention, input responsiveness
- Mobile viewport — `<meta name="viewport">` 존재 및 정확성
- HTTP status codes — broken links 없음, proper redirects(301 vs 302)
- Clean URL structure — descriptive, kebab-case, query string abuse 없음

Tools: 파일 스캔에는 `Glob`, `Grep`, `Read`. 가능한 경우 live URL 분석에는 `WebFetch`.

## 4. Platform Policy Phase

플랫폼별 crawler와 AI/search visibility controls를 별도로 점검한다:

- Googlebot 및 indexing/snippets용 standard robots directives
- 관련 있을 때 Google AI training/product controls용 Google-Extended
- ChatGPT Search inclusion용 OAI-SearchBot, OpenAI training용 GPTBot, user-triggered fetches용 ChatGPT-User
- robots.txt 또는 server rules에 언급된 PerplexityBot, ClaudeBot 및 기타 AI crawlers
- `nosnippet`, `data-nosnippet`, `max-snippet`, `noindex`, canonical, X-Robots-Tag effects
- `llms.txt`는 optional machine-readable map이지 guaranteed ranking 또는 citation mechanism이 아님

Official docs 또는 직접 관찰한 files/headers가 뒷받침할 때만 policy findings를 high confidence로 기록한다.

## 5. On-Page SEO Phase

다음을 스캔한다:

- `<title>` — 존재, 페이지별 unique, 60자 이하, primary keyword 포함
- `<meta name="description">` — 존재, 150-160자, 설득력 있음, keyword 포함
- Heading hierarchy — 페이지당 하나의 `<h1>`, logical `h2`→`h3`→`h4` nesting
- Image alt text — 모든 `<img>`에 descriptive `alt` attributes
- Open Graph tags — `og:title`, `og:description`, `og:image`, `og:url`
- Twitter Card tags — `twitter:card`, `twitter:title`, `twitter:description`
- Internal links — descriptive anchor text, contextual relevance, 1,000단어당 3-5개
- URL slug — descriptive, keyword-relevant, unnecessary parameters 없음

Tools: Pattern matching에는 `Grep`(`<title>`, `<meta`, `<h1>`, `alt=`), page content에는 `Read`.

## 6. Content SEO Phase

다음을 평가한다:

- E-E-A-T signals — experience, expertise, authoritativeness, trustworthiness
- Keyword placement — title, first paragraph, headings, naturally distributed
- Keyword and entity usage — title, intro, headings, body, alt text에 자연스럽게 배치하고 stuffing 또는 fixed-density targets 없음
- Content depth — 주제에 대한 충분한 coverage, indexable pages는 최소 300+ words
- Readability — short paragraphs, clear structure, scannable with headings
- Freshness — dates present, content not stale
- Uniqueness — 페이지 간 obvious duplicate content 없음
- AI content — AI-generated인 경우 human editing과 value-add evidence

Tools: Content analysis에는 `Read`, 필요한 경우 competitor/SERP context에는 `WebSearch`.

## 7. AEO Phase(Answer Engine Optimization)

AI direct answers와 Featured Snippets 준비도를 평가한다:

- **Q&A format** — 주요 질문에 대한 concise visible answer block이 관련 콘텐츠 상단 근처에 있는가. Fixed length targets는 heuristic이다.
- **Featured Snippet optimization** — 정의, 목록, 표 snippet에 적합한 구조인가.
- **Voice search readiness** — Headings와 subheadings가 natural-language questions로 작성되었는가.
- **Answer extraction ease** — Short paragraphs(2-3 sentences)와 clear H2/H3 structure가 AI systems의 answer extraction을 쉽게 만드는가.
- **FAQ/Q&A structure** — Visible FAQ/Q&A content가 있고, Google FAQ rich result eligibility와 answer-friendly content를 구분했는가.
- **Platform-specific content fit** — ChatGPT(encyclopedic), Perplexity(community/contextual), Google AI Overviews(multimodal) preferences에 콘텐츠가 적합한가.

Tools: Q&A patterns와 heading structures에는 `Grep`, content analysis에는 `Read`. Strategy details는 `references/aeo-geo-guide.md`를 참고한다.

## 8. GEO Phase(Generative Engine Optimization)

Generative responses에서 AI citation 준비도를 평가한다:

- **GEO CORE assessment**:
  - **Context** — 주제가 충분한 context와 background를 포함하는가.
  - **Organization** — 콘텐츠에 clear hierarchy와 extractable formatting이 있는가.
  - **Reliability** — Verifiable statistics, citations, expert opinions를 포함하는가.
  - **Exclusivity** — Proprietary data, original research, unique perspective를 포함하는가.
- **Entity authority** — Topic cluster structure와 여러 콘텐츠 전반의 knowledge consistency.
- **Citable statements** — Statistics가 포함된 짧고 독립적으로 인용 가능한 문장.
- **Content freshness** — 주제의 time sensitivity에 맞는 updated dates와 source dates.
- **llms.txt** — Optional LLM-facing content map의 존재와 canonical URLs/sitemaps와의 일치.
- **Schema markup AI trust signal** — JSON-LD가 visible entity information과 일치하는지 여부. 이는 AI citation을 보장하지 않는다.

Tools: Citation patterns와 statistics에는 `Grep`, content freshness에는 `Read`, llms.txt에는 `Glob`. GEO CORE framework와 platform benchmarks는 `references/aeo-geo-guide.md`를 참고한다.

접근이 허용될 때의 선택적 high-confidence extensions:

- **Query fan-out simulator** — 대상 주제에서 10-30개 하위 쿼리를 생성하고 content expansion 권장 전에 missing coverage를 매핑한다.
- **AI citation probe** — ChatGPT, Perplexity, Gemini 또는 기타 엔진용 stable prompt set을 실행하거나 준비한다. Engine, date, sample size, cited URLs, brand mentions, unresolved volatility를 기록한다.

## 9. Score Optimization Phase(Optimize Mode Only)

사용자가 highest score, max score, perfect score, repeated improvement를 요청할 때 이 phase를 실행한다.

1. **Baseline first** — 파일이나 권장사항 변경 전에 현재 category average, `overall_grade`, critical-finding count, target score를 `results.json.score_history[0]`에 쓴다.
2. **Stable evaluator** — 모든 iteration에서 동일한 scoring categories와 pass/fail checks를 유지한다. Evaluator가 바뀌면 reset event를 기록하고 새 점수를 이전 run과 비교하지 않는다.
3. **One change per iteration** — 하나의 high-impact change 또는 긴밀히 관련된 recommendation set 하나를 선택한다. 관련 없는 technical, content, AEO/GEO changes를 같은 iteration에 묶지 않는다.
4. **Re-audit after every change** — Category scores, findings, quick wins, evidence를 업데이트한다. `iteration`, `changed`, `score`, `critical_count`, `decision`, `evidence`가 있는 iteration record를 append한다.
5. **Keep best run** — 점수가 개선되거나 score regression 없이 critical findings가 줄면 iteration을 `kept`로 표시하고 `best_run`을 업데이트한다. 그렇지 않으면 가능하면 code changes를 rollback/revert하거나 iteration을 `discarded`로 표시한다.
6. **Continue/stop gates** — 점수가 개선되는 동안 계속한다. Target score 통과, validator/architect review 승인, user stop, budget exhaustion, 또는 3 consecutive iterations plateau일 때만 중단한다.
7. **Completion artifact** — `results.json.status: "complete"`, 채워진 `score_history`, 채워진 `best_run`, final score가 best available run인 이유를 설명하는 validator evidence로 마무리한다.

“Infinite loop”를 문자 그대로 해석하지 않는다. 올바른 동작은 rollback, plateau detection, artifact-gated completion이 있는 지속적이고 측정된 continuation이다.

## 10. Report Phase

발견사항을 `report.md`로 컴파일한다:

1. Overall SEO health score(A/B/C/D/F)가 포함된 executive summary
2. Category별 findings(Technical SEO, On-Page SEO, Content SEO, Core Web Vitals, Structured Data, AEO Readiness, GEO Readiness)
3. 각 finding에는 severity(critical/warning/info), description, location, fix recommendation 포함
4. Impact 기준으로 정렬한 prioritized action items
5. Low-effort/high-impact fixes를 위한 quick wins section

Evidence와 raw data는 `sources.md`에 쓴다.

## Optimize Mode Rules

- 사용자가 highest score, max score, perfect score, repeated iteration, 또는 infinite-loop-style improvement request를 명시적으로 요청하면 `optimize`를 사용한다.
- `create` 또는 `update` audit output에서 시작한 뒤 Score Optimization Phase로 진입한다.
- 이후 experiments가 discarded되더라도 best-scoring report와 dashboard를 보존한다.
- Implementation edits가 허용되면 각 kept code-changing iteration을 `best_run`으로 취급하기 전에 관련 project checks로 검증한다.

## Mode Rules

### Create mode

- 처음부터 full analysis
- 모든 phases를 순차 실행
- Template-based report generation

### Update mode

- 기존 `report.md`를 먼저 읽음
- 변경되었거나 새로 요청된 영역만 재분석
- Report에 dated changelog entry append
- Superseded되지 않은 prior findings 보존

## Research Rule

- Audit에 live SERP data, competitor analysis, current ranking info가 필요하면 specific queries로 web searches를 실행한다.
- 사용자가 충분한 context를 이미 제공했다면 unnecessary external research를 강제하지 않는다.
- 모든 external queries와 sources를 `sources.md`에 기록한다.
