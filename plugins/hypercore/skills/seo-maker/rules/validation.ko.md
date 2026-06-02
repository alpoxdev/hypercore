# SEO 검증

**목적**: SEO 감사 완료를 선언하기 전의 품질 점검.

## 리포트 완전성

- [ ] 모든 발견사항에 severity(critical/warning/info)가 있음
- [ ] 모든 발견사항에 code example 또는 specific action이 포함된 concrete fix recommendation이 있음
- [ ] 발견사항이 category별로 묶임(Technical SEO, On-Page SEO, Content SEO, Core Web Vitals, Structured Data, AEO Readiness, GEO Readiness)
- [ ] 발견사항이 SEO impact 기준으로 우선순위화됨(high → low)
- [ ] Executive summary에 overall health score 포함
- [ ] Quick wins section이 있고 최소 1개 항목 포함

## Coverage Checks

### Simple audit

- [ ] Target page(s)를 완전히 스캔함
- [ ] 최소 하나의 category(Technical, On-Page, Content)를 분석함
- [ ] `report.md`가 `.hypercore/seo-maker/[slug]/`에 저장됨

### Complex audit

- [ ] 모든 phases가 완료되고 `flow.json`이 업데이트됨
- [ ] Technical SEO: robots.txt, sitemap, canonicals, structured data, Core Web Vitals 확인
- [ ] Platform policy: AI/search crawler controls, snippet directives, `llms.txt`, robots meta/X-Robots-Tag를 해당되는 경우 확인
- [ ] On-Page SEO: title, meta description, headings, images, internal links 확인
- [ ] Content SEO: E-E-A-T, natural keyword/entity usage, readability, freshness 평가
- [ ] Core Web Vitals: LCP, INP, CLS, method(field/lab/no-url), confidence 확인
- [ ] Structured Data: JSON-LD validity, visible-content parity, schema type fit, rich result eligibility caveats 확인
- [ ] AEO: visible Q&A/answer blocks, Featured Snippet readiness, FAQPage/QAPage eligibility caveats 확인
- [ ] GEO: GEO CORE, citation readiness, entity authority, topic-appropriate freshness, optional llms.txt, query fan-out/citation probe status 확인
- [ ] `sources.md`가 사용한 evidence와 references를 기록함
- [ ] `report.md`가 `.hypercore/seo-maker/[slug]/`에 저장됨

## Optimize Mode Checks

- [ ] Optimization changes 전에 baseline score가 기록됨
- [ ] `score_history`에 모든 iteration과 score, decision(`kept`/`discarded`), evidence가 포함됨
- [ ] `best_run`이 highest-scoring kept iteration을 가리키거나 verified plateau를 설명함
- [ ] 각 iteration이 one high-impact item 또는 tightly related recommendation set만 변경함
- [ ] Non-improving iterations가 rolled back/reverted 되었거나 명시적으로 `discarded`로 표시됨
- [ ] Stop condition이 evidence-based임: target score reached, validator/architect approval, user stop, budget exhaustion, 또는 3-iteration plateau
- [ ] Best-score loop 완료를 주장하기 전에 completion artifact 또는 validator evidence가 있음

## Evidence And Confidence Checks

- [ ] 명확하지 않은 모든 발견사항에 `evidence_grade`, `confidence`, `measurement_method`, `source_tier`가 포함됨
- [ ] Platform policy entries에 `evidence_grade`, `confidence`, `source_tier`가 포함됨
- [ ] Official requirements, tool/lab findings, synthetic AI citation probes, heuristic recommendations가 라벨 없이 섞이지 않음
- [ ] Live URL, Search Console, analytics, field Core Web Vitals, AI engine access 누락이 confidence limitation으로 공개됨
- [ ] Google AI features가 special schema, AI text files, magic markup을 요구한다고 설명되지 않음
- [ ] FAQPage recommendations가 Google rich result eligibility와 answer-friendly visible FAQ content를 구분함
- [ ] 사용자가 명시적으로 LLM-facing content map을 원하지 않는 한 llms.txt recommendations는 optional임

## Quality Checks

- [ ] 발견사항이 모호하지 않음. "improve SEO"는 유효한 recommendation이 아님
- [ ] Technical fixes에는 code examples 또는 file paths 포함
- [ ] Severity ratings가 일관됨(예: missing `<title>` = critical, missing `og:image` = warning)
- [ ] Category 간 duplicate findings 없음
- [ ] Report가 analysis notes를 다시 읽지 않아도 실행 가능함
- [ ] Optimize mode report가 baseline score, final score, score delta, perfect가 아닐 때 remaining blockers를 식별함

## Severity Guide

| Severity | Criteria | Example |
|----------|----------|---------|
| **critical** | 색인을 차단하거나 랭킹을 심각하게 해침 | Missing title, robots.txt blocks crawling, no canonical |
| **warning** | 랭킹 또는 user experience 저하 | Meta description too long, missing alt text, slow LCP |
| **info** | 결함이 아닌 improvement opportunity | Add FAQ schema, optimize anchor text, add breadcrumb markup |

## AEO/GEO Specific Checks

- [ ] AEO: Target page마다 최소 하나의 Q&A optimization finding 또는 confirmation
- [ ] GEO: GEO CORE(Context, Organization, Reliability, Exclusivity)를 각각 평가
- [ ] GEO: Content freshness를 universal fixed threshold가 아니라 topic sensitivity와 source/date evidence 기준으로 평가
- [ ] GEO: 최소 하나의 platform-specific recommendation(Google AI Overviews, ChatGPT, Perplexity)
- [ ] llms.txt를 optional content map으로 확인함. Missing file은 기본적으로 critical로 표시하지 않음
