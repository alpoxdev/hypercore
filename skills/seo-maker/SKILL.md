---
name: seo-maker
description: SEO/AEO/GEO 통합 분석 및 최적화 리포트를 생성한다. 전통 SEO(온페이지, 기술, 콘텐츠, Core Web Vitals)에 더해 AEO(Answer Engine Optimization), GEO(Generative Engine Optimization), LLMO(LLM Optimization)까지 점검하고 개선안을 `.hypercore/seo-maker/[slug]/`에 저장한다. "SEO 분석", "AEO 최적화", "GEO 점검", "AI 검색 최적화", "검색엔진 최적화", "메타태그 점검", "SEO 감사", "AI 인용 최적화" 요청 시 사용.
compatibility: Works best with local file search/edit tools and live web search for competitor/SERP/AI citation analysis.
---

@rules/seo-workflow.md
@rules/validation.md

# SEO Maker

> 프로젝트의 SEO/AEO/GEO 상태를 분석하고, 전통 검색엔진과 AI 검색엔진 모두에 대한 최적화 리포트를 산출한다.

<purpose>

- 웹사이트나 프로젝트의 SEO 현황을 체계적으로 감사(audit)한다.
- 온페이지 SEO, 기술 SEO, 콘텐츠 SEO, Core Web Vitals를 종합 점검한다.
- AEO(Answer Engine Optimization) — Featured Snippet, 음성 검색, AI 직접 답변 선택 최적화를 점검한다.
- GEO(Generative Engine Optimization) — AI 생성 응답에서의 인용 가능성을 점검한다.
- 우선순위가 매겨진 개선안 리포트를 `.hypercore/seo-maker/[slug]/`에 저장한다.
- 기존 리포트를 업데이트하여 SEO 개선 이력을 추적한다.

</purpose>

<routing_rule>

Use `seo-maker` when the main output is an SEO analysis, audit, or optimization report.

Use `research` instead when the job is general market/competitor research without an SEO deliverable.

Use `prd-maker` instead when the output is a product requirements document, not an SEO report.

Use `pre-deploy` instead when the job is deployment validation, not SEO-specific analysis.

Do not use `seo-maker` when:

- the user only wants general web performance optimization without SEO focus
- the user wants content writing without SEO analysis
- the user wants implementation of code changes without prior SEO analysis

</routing_rule>

<activation_examples>

Positive requests:

- "이 사이트의 SEO를 분석해줘."
- "메타태그랑 구조화 데이터 점검해줘."
- "SEO 감사 리포트 만들어줘."
- "검색엔진 최적화 상태를 확인하고 개선안을 알려줘."
- "Core Web Vitals 점수 개선 방안을 정리해줘."
- "AI 검색에서 우리 콘텐츠가 인용되도록 최적화해줘."
- "ChatGPT나 Perplexity에서 우리 브랜드가 노출되는지 점검해줘."
- "AEO/GEO 관점에서 사이트 분석해줘."

Negative requests:

- "랜딩 페이지 디자인해줘." → use `designer`
- "경쟁사 시장조사 해줘." → use `research`
- "배포 전 체크리스트 확인해줘." → use `pre-deploy`

Boundary request:

- "이 페이지 성능 최적화해줘."
  Use `seo-maker` only if the optimization focus is search engine visibility. If it's pure loading performance, route to other tools.
- "AI 검색 트렌드 조사해줘."
  Use `seo-maker` only if the output should be an actionable optimization report. If it's pure research, route to `research`.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|------|------|
| 새 프로젝트/사이트의 SEO 전체 감사 | create |
| 특정 페이지의 온페이지 SEO 점검 | create |
| 기존 SEO 리포트에 새 분석 결과 추가 | update |
| Core Web Vitals 또는 기술 SEO 집중 분석 | create |
| SEO 개선 후 재점검 | update |
| AI 검색 인용 최적화 (AEO/GEO) 분석 | create |
| 기존 리포트에 AEO/GEO 분석 추가 | update |

</trigger_conditions>

<supported_targets>

- HTML 페이지, Next.js/React 컴포넌트의 메타태그 및 SEO 요소
- `robots.txt`, `sitemap.xml`, `llms.txt`, canonical 태그, 구조화 데이터
- Core Web Vitals (LCP, INP, CLS) 관련 코드
- `<head>` 영역의 title, meta description, Open Graph, Twitter Card
- heading 계층 구조 (h1-h6)
- 이미지 alt 텍스트, 내부 링크 구조
- Schema.org JSON-LD 마크업 (AI 신뢰 신호 역할 포함)
- AEO 요소 — Q&A 포맷, 직접 답변 구조, Featured Snippet 최적화
- GEO 요소 — 인용 가능한 문장 구조, 통계/출처 포함, 엔터티 권위
- LLMO 요소 — llms.txt, AI 크롤러 접근성, 콘텐츠 신선도

</supported_targets>

<complexity_classification>

## Complexity Classification

Classify before starting work:

| Complexity | Signals | Path |
|------------|---------|------|
| **Simple** | 단일 페이지 점검, 특정 SEO 요소만 확인, 빠른 메타태그 감사 | **Direct** — `report.md` 바로 작성 |
| **Complex** | 전체 사이트 감사, 다수 페이지 분석, 기술 SEO + 콘텐츠 SEO + Core Web Vitals 종합, 경쟁사 비교 포함 | **Tracked** — `flow.json`으로 단계 추적 |

Announce the classification:

```
Complexity: [simple/complex] — [한 줄 이유]
```

When uncertain, classify as complex.

</complexity_classification>

<document_shape>

Default output shape:

```text
.hypercore/seo-maker/[slug]/
├── dashboard.html      # 브라우저에서 열 수 있는 대시보드
├── results.json        # 구조화된 감사 결과 (JSON)
├── results.js          # file:// 브라우저 폴백용
├── report.md           # 마크다운 리포트
├── sources.md          # 출처 기록
└── flow.json           # complex path only
```

- `results.json` is the structured audit data. See [references/artifact-spec.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/references/artifact-spec.md) for the full schema.
- `dashboard.html` is a self-contained browser dashboard rendered from [assets/dashboard-template.html](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/assets/dashboard-template.html).
- `results.js` is the `file://` fallback for `results.json`.
- `report.md` is the SEO audit report with findings and recommendations.
- `sources.md` captures evidence, tool outputs, and reference links used.
- `flow.json` tracks phase progress for complex audits.
- Create report from [assets/report.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/assets/report.template.md) when the folder does not exist yet.
- Render dashboard with `scripts/render-dashboard.sh <artifact-dir>` after `results.json` is finalized.

</document_shape>

<flow_tracking>

## Flow Tracking (Complex Path Only)

When classified as complex, write `flow.json` and update as each phase progresses.

### Phase progression

| Phase | Description | Next |
|-------|-------------|------|
| `scope` | Define audit scope — target URLs, focus areas, constraints | `technical` |
| `technical` | Analyze technical SEO — robots.txt, sitemap, llms.txt, canonicals, structured data, Core Web Vitals | `onpage` |
| `onpage` | Analyze on-page SEO — titles, meta descriptions, headings, images, internal links | `content` |
| `content` | Analyze content quality — E-E-A-T, keyword usage, readability, freshness | `aeo` |
| `aeo` | Analyze AEO readiness — Q&A 포맷, 직접 답변, Featured Snippet, 음성 검색 최적화 | `geo` |
| `geo` | Analyze GEO readiness — AI 인용 가능성, GEO CORE, 엔터티 권위, 플랫폼별 최적화 | `report` |
| `report` | Compile findings into prioritized report with actionable recommendations | done |

### Resume support

If `flow.json` already exists, read it first and continue from the last incomplete phase.

</flow_tracking>

<support_file_read_order>

Read in this order:

1. This core `SKILL.md` to confirm the job is SEO/AEO/GEO analysis or audit.
2. [rules/seo-workflow.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/rules/seo-workflow.md) for phase-by-phase execution details.
3. [references/seo-fundamentals.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/references/seo-fundamentals.md) for E-E-A-T, Core Web Vitals, ranking factors, entity SEO, schema markup guidance.
4. [references/aeo-geo-guide.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/references/aeo-geo-guide.md) for AEO/GEO/LLMO strategy, GEO CORE framework, platform benchmarks, llms.txt guidance.
5. [references/seo-checklist.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/references/seo-checklist.md) for actionable audit checklist items (SEO + AEO + GEO).
6. [references/artifact-spec.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/references/artifact-spec.md) for `results.json` schema, dashboard lifecycle, and workspace structure.
7. [assets/report.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/assets/report.template.md) when creating a new report.
8. [assets/dashboard-template.html](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/assets/dashboard-template.html) when rendering the dashboard.
9. [rules/validation.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/rules/validation.md) before declaring the audit complete.

</support_file_read_order>

<workflow>

## Simple Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | Confirm SEO deliverable, choose `create`/`update`, classify as simple | Mode + complexity |
| 1 | Scan target files for SEO elements | Raw findings |
| 2 | Create or locate `.hypercore/seo-maker/[slug]/` | Storage target |
| 3 | Write `report.md` with findings and recommendations | SEO report |
| 4 | Validate completeness | Finalized report |

## Complex Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | Confirm SEO deliverable, choose `create`/`update`, classify as complex | Mode + complexity |
| 1 | Create or locate `.hypercore/seo-maker/[slug]/`, write `flow.json` with `scope: in_progress` | Storage + flow |
| 2 | Define audit scope → update flow `scope: completed` | Scope definition |
| 3 | Technical SEO analysis → update flow `technical: completed` | Technical findings |
| 4 | On-page SEO analysis → update flow `onpage: completed` | On-page findings |
| 5 | Content SEO analysis → update flow `content: completed` | Content findings |
| 6 | AEO readiness analysis → update flow `aeo: completed` | AEO findings |
| 7 | GEO readiness analysis → update flow `geo: completed` | GEO findings |
| 8 | Compile prioritized report → update flow `report: completed` | Final report |
| 9 | Validate and finalize | Finalized audit |

</workflow>

<required>

- Complexity classified (simple/complex) before starting work.
- Store every report under `.hypercore/seo-maker/[slug]/`.
- Prefer ASCII kebab-case slugs.
- Every finding must have a severity (critical/warning/info) and a concrete fix recommendation.
- Prioritize recommendations by SEO impact (high → low).
- Reference E-E-A-T and Core Web Vitals standards from `references/seo-fundamentals.md`.
- Reference AEO/GEO strategy from `references/aeo-geo-guide.md` when analyzing AI search readiness.
- For complex path: maintain `flow.json` and update after each phase.
- Complex path must include AEO and GEO phases unless the user explicitly requests traditional SEO only.

</required>

<deliverables>

실행이 끝나면 다음이 `.hypercore/seo-maker/[slug]/`에 남아 있어야 한다:

- `results.json` — 구조화된 감사 결과 (status: `complete`)
- `dashboard.html` — 브라우저 대시보드 (render-dashboard.sh로 생성)
- `results.js` — file:// 폴백
- `report.md` — 마크다운 리포트
- `sources.md` — 출처 기록
- `flow.json` — complex path only

파일 스키마는 [references/artifact-spec.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/seo-maker/references/artifact-spec.md)를 따른다.

렌더 순서:

```bash
skills/seo-maker/scripts/render-dashboard.sh .hypercore/seo-maker/[slug]
open .hypercore/seo-maker/[slug]/dashboard.html
```

</deliverables>

<forbidden>

- Writing an SEO report only in chat without saving the folder output
- Listing problems without actionable fix recommendations
- Skipping technical SEO when doing a full site audit
- Mixing raw analysis notes into the final report when they belong in `sources.md`
- Creating extra README or changelog files in the report folder
- Skipping `flow.json` updates in complex path

</forbidden>
