# SEO Validation

**Purpose**: Quality checks before declaring an SEO audit complete.

## Report Completeness

- [ ] Every finding has severity (critical/warning/info)
- [ ] Every finding has a concrete fix recommendation with code example or specific action
- [ ] Findings are grouped by category (Technical, On-Page, Content, AEO, GEO)
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
- [ ] Technical SEO: robots.txt, sitemap, llms.txt, canonicals, structured data, Core Web Vitals checked
- [ ] On-Page SEO: title, meta description, headings, images, internal links checked
- [ ] Content SEO: E-E-A-T, keywords, readability, freshness evaluated
- [ ] AEO: Q&A 포맷, 직접 답변 구조, Featured Snippet, FAQPage 스키마 checked
- [ ] GEO: GEO CORE 평가, 인용 가능성, 엔터티 권위, 콘텐츠 신선도, llms.txt checked
- [ ] `sources.md` captures evidence and references used
- [ ] `report.md` saved to `.hypercore/seo-maker/[slug]/`

## Quality Checks

- [ ] No finding is vague — "improve SEO" is not a valid recommendation
- [ ] Code examples or file paths are included for technical fixes
- [ ] Severity ratings are consistent (e.g., missing `<title>` = critical, missing `og:image` = warning)
- [ ] No duplicate findings across categories
- [ ] Report is actionable without needing to re-read analysis notes

## Severity Guide

| Severity | Criteria | Example |
|----------|----------|---------|
| **critical** | Blocks indexing or severely hurts ranking | Missing title, robots.txt blocks crawling, no canonical |
| **warning** | Degrades ranking or user experience | Meta description too long, missing alt text, slow LCP |
| **info** | Improvement opportunity, not a deficiency | Add FAQ schema, optimize anchor text, add breadcrumb markup |

## AEO/GEO Specific Checks

- [ ] AEO: At least one Q&A optimization finding or confirmation per target page
- [ ] GEO: GEO CORE (Context, Organization, Reliability, Exclusivity) each evaluated
- [ ] GEO: Content freshness assessed against 3-month AI citation threshold
- [ ] GEO: At least one platform-specific recommendation (Google AI Overviews, ChatGPT, or Perplexity)
- [ ] llms.txt existence checked and recommendation provided if missing
