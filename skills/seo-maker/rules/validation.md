# SEO Validation

**Purpose**: Quality checks before declaring an SEO audit complete.

## Report Completeness

- [ ] Every finding has severity (critical/warning/info)
- [ ] Every finding has a concrete fix recommendation with code example or specific action
- [ ] Findings are grouped by category (Technical SEO, On-Page SEO, Content SEO, Core Web Vitals, Structured Data, AEO Readiness, GEO Readiness)
- [ ] Findings are prioritized by SEO impact (high → low)
- [ ] Executive summary includes overall health score
- [ ] Quick wins section exists with at least 1 item

## Coverage Checks

### Simple audit

- [ ] Target page(s) fully scanned
- [ ] At least one category (Technical, On-Page, or Content) analyzed
- [ ] `report.md` saved to `.hypercore/seo-maker/[slug]/`

### Complex audit

- [ ] All phases completed and `flow.json` updated
- [ ] Technical SEO: robots.txt, sitemap, canonicals, structured data, Core Web Vitals checked
- [ ] Platform policy: AI/search crawler controls, snippet directives, `llms.txt`, and robots meta/X-Robots-Tag checked where applicable
- [ ] On-Page SEO: title, meta description, headings, images, internal links checked
- [ ] Content SEO: E-E-A-T, natural keyword/entity usage, readability, freshness evaluated
- [ ] Core Web Vitals: LCP, INP, CLS, method (field/lab/no-url), and confidence checked
- [ ] Structured Data: JSON-LD validity, visible-content parity, schema type fit, and rich result eligibility caveats checked
- [ ] AEO: visible Q&A/answer blocks, Featured Snippet readiness, and FAQPage/QAPage eligibility caveats checked
- [ ] GEO: GEO CORE, citation readiness, entity authority, topic-appropriate freshness, optional llms.txt, query fan-out/citation probe status checked
- [ ] `sources.md` captures evidence and references used
- [ ] `report.md` saved to `.hypercore/seo-maker/[slug]/`

## Optimize Mode Checks

- [ ] Baseline score is recorded before any optimization changes.
- [ ] `score_history` contains every iteration with score, decision (`kept`/`discarded`), and evidence.
- [ ] `best_run` points to the highest-scoring kept iteration or explains a verified plateau.
- [ ] Each iteration changes only one high-impact item or one tightly related recommendation set.
- [ ] Non-improving iterations are rolled back/reverted or explicitly marked `discarded`.
- [ ] Stop condition is evidence-based: target score reached, validator/architect approval, user stop, budget exhaustion, or 3-iteration plateau.
- [ ] Completion artifact or validator evidence exists before claiming the best-score loop is complete.

## Evidence And Confidence Checks

- [ ] Every non-obvious finding includes `evidence_grade`, `confidence`, `measurement_method`, and `source_tier`.
- [ ] Platform policy entries include `evidence_grade`, `confidence`, and `source_tier`.
- [ ] Official requirements, tool/lab findings, synthetic AI citation probes, and heuristic recommendations are not mixed without labels.
- [ ] Missing live URL, Search Console, analytics, field Core Web Vitals, or AI engine access is disclosed as a confidence limitation.
- [ ] Google AI features are not described as requiring special schema, AI text files, or magic markup.
- [ ] FAQPage recommendations distinguish Google rich result eligibility from answer-friendly visible FAQ content.
- [ ] llms.txt recommendations are optional unless the user explicitly wants an LLM-facing content map.

## Quality Checks

- [ ] No finding is vague — "improve SEO" is not a valid recommendation
- [ ] Code examples or file paths are included for technical fixes
- [ ] Severity ratings are consistent (e.g., missing `<title>` = critical, missing `og:image` = warning)
- [ ] No duplicate findings across categories
- [ ] Report is actionable without needing to re-read analysis notes
- [ ] Optimize mode report identifies baseline score, final score, score delta, and remaining blockers if not perfect

## Severity Guide

| Severity | Criteria | Example |
|----------|----------|---------|
| **critical** | Blocks indexing or severely hurts ranking | Missing title, robots.txt blocks crawling, no canonical |
| **warning** | Degrades ranking or user experience | Meta description too long, missing alt text, slow LCP |
| **info** | Improvement opportunity, not a deficiency | Add FAQ schema, optimize anchor text, add breadcrumb markup |

## AEO/GEO Specific Checks

- [ ] AEO: At least one Q&A optimization finding or confirmation per target page
- [ ] GEO: GEO CORE (Context, Organization, Reliability, Exclusivity) each evaluated
- [ ] GEO: Content freshness assessed against topic sensitivity and source/date evidence, not a universal fixed threshold
- [ ] GEO: At least one platform-specific recommendation (Google AI Overviews, ChatGPT, or Perplexity)
- [ ] llms.txt checked as optional content map; missing file is not marked critical by default
