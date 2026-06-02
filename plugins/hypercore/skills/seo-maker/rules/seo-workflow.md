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

- **Q&A format** — Does the content place concise visible answer blocks for key questions near the top of the relevant content? Fixed length targets are heuristic.
- **Featured Snippet optimization** — Is the structure suitable for definition, list, and table snippets?
- **Voice search readiness** — Are headings and subheadings written as natural-language questions?
- **Answer extraction ease** — Do short paragraphs (2-3 sentences) and clear H2/H3 structure make answers easy for AI systems to extract?
- **FAQ/Q&A structure** — Is there visible FAQ/Q&A content, and does the audit distinguish Google FAQ rich result eligibility from answer-friendly content?
- **Platform-specific content fit** — Is the content suitable for ChatGPT (encyclopedic), Perplexity (community/contextual), and Google AI Overviews (multimodal) preferences?

Tools: `Grep` for Q&A patterns, heading structures. `Read` for content analysis. See `references/aeo-geo-guide.md` for strategy details.

## 8. GEO Phase (Generative Engine Optimization)

Evaluate readiness for AI citation in generative responses:

- **GEO CORE assessment**:
  - **Context** — Does the topic include sufficient context and background?
  - **Organization** — Does the content have clear hierarchy and extractable formatting?
  - **Reliability** — Does it include verifiable statistics, citations, and expert opinions?
  - **Exclusivity** — Does it include proprietary data, original research, or a unique perspective?
- **Entity authority** — Topic cluster structure and knowledge consistency across multiple content pieces.
- **Citable statements** — Short, independently citable statements, including statistics where relevant.
- **Content freshness** — Updated dates and source dates appropriate to the topic's time sensitivity.
- **llms.txt** — Presence of an optional LLM-facing content map and its consistency with canonical URLs and sitemaps.
- **Schema markup AI trust signal** — Whether JSON-LD matches visible entity information. This does not guarantee AI citation.

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

- Use `optimize` when the user explicitly requests the highest score, max score, perfect score, repeated iteration, or an infinite-loop-style improvement request.
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
