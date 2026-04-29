---
name: seo-maker
description: SEO/AEO/GEO 통합 분석 및 최적화 리포트를 생성한다. 전통 SEO(온페이지, 기술, 콘텐츠, Core Web Vitals)에 더해 AEO(Answer Engine Optimization), GEO(Generative Engine Optimization), LLMO(LLM Optimization)까지 점검하고 개선안을 `.hypercore/seo-maker/[slug]/`에 저장한다. "SEO 분석", "AEO 최적화", "GEO 점검", "AI 검색 최적화", "검색엔진 최적화", "메타태그 점검", "SEO 감사", "AI 인용 최적화", "최고 점수까지 반복", "SEO 점수 만점까지 수정" 요청 시 사용.
compatibility: 로컬 파일 검색/수정 도구와 경쟁사/SERP/AI 인용 분석용 라이브 웹 검색을 함께 쓸 때 가장 잘 동작한다.
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
- 사용자가 최고 점수/만점/무한 반복을 요청하면 점수 최적화 루프로 audit → fix recommendation/application → re-audit를 반복하고 최고 결과만 유지한다.

</purpose>

<routing_rule>

SEO 분석, 감사, 최적화 리포트가 주된 산출물일 때 `seo-maker`를 사용한다.

경쟁사/시장 조사처럼 SEO 산출물이 아닌 일반 리서치면 `research`를 사용한다.

결과물이 PRD면 `prd-maker`를 사용한다.

배포 전 검증이 목적이면 `pre-deploy`를 사용한다.

다음 경우에는 `seo-maker`를 사용하지 않는다:

- 순수한 웹 성능 최적화만 원하고 SEO 초점이 없을 때
- SEO 분석 없이 콘텐츠 작성만 원할 때
- 사전 분석 없이 바로 코드 변경 구현만 원할 때

</routing_rule>

<activation_examples>

긍정 요청:

- "이 사이트의 SEO를 분석해줘."
- "메타태그랑 구조화 데이터 점검해줘."
- "SEO 감사 리포트 만들어줘."
- "검색엔진 최적화 상태를 확인하고 개선안을 알려줘."
- "Core Web Vitals 점수 개선 방안을 정리해줘."
- "AI 검색에서 우리 콘텐츠가 인용되도록 최적화해줘."
- "ChatGPT나 Perplexity에서 우리 브랜드가 노출되는지 점검해줘."
- "AEO/GEO 관점에서 사이트 분석해줘."
- "SEO 점수 최고 점수 나올 때까지 계속 반복해서 고쳐줘."
- "검색 최적화 점수가 만점에 가까워질 때까지 audit하고 수정하고 재검증해줘."

부정 요청:

- "랜딩 페이지 디자인해줘." → `designer` 사용
- "경쟁사 시장조사 해줘." → `research` 사용
- "배포 전 체크리스트 확인해줘." → `pre-deploy` 사용

경계 요청:

- "이 페이지 성능 최적화해줘."
  검색 가시성이 중심이면 `seo-maker`를 쓰고, 순수 로딩 성능이면 다른 도구로 보낸다.
- "AI 검색 트렌드 조사해줘."
  실무 최적화 리포트가 목표일 때만 `seo-maker`를 쓰고, 일반 조사면 `research`로 보낸다.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|------|------|
| 새 프로젝트/사이트의 SEO 전체 감사 | create |
| 특정 페이지의 온페이지 SEO 점검 | create |
| 기존 SEO 리포트에 새 분석 결과 추가 | update |
| Core Web Vitals 또는 기술 SEO 집중 분석 | create |
| SEO 개선 후 재점검 | update |
| 최고 점수/만점 목표로 반복 개선 | optimize |
| AI 검색 인용 최적화 (AEO/GEO) 분석 | create |
| 기존 리포트에 AEO/GEO 분석 추가 | update |

</trigger_conditions>

<supported_targets>

- HTML 페이지, Next.js/React 컴포넌트의 메타태그 및 SEO 요소
- `robots.txt`, `sitemap.xml`, `llms.txt`, canonical 태그, 구조화 데이터
- Core Web Vitals (LCP, INP, CLS) 관련 코드
- `<head>` 영역의 title, meta description, Open Graph, Twitter Card
- heading 계층 구조 (`h1`-`h6`)
- 이미지 alt 텍스트, 내부 링크 구조
- Schema.org JSON-LD 마크업 (AI 신뢰 신호 역할 포함)
- AEO 요소 — Q&A 포맷, 직접 답변 구조, Featured Snippet 최적화
- GEO 요소 — 인용 가능한 문장 구조, 통계/출처 포함, 엔터티 권위
- LLMO 요소 — `llms.txt`, AI 크롤러 접근성, 콘텐츠 신선도

</supported_targets>

<complexity_classification>

## Complexity Classification

시작 전에 복잡도를 분류한다:

| Complexity | Signals | Path |
|------------|---------|------|
| **Simple** | 단일 페이지 점검, 특정 SEO 요소만 확인, 빠른 메타태그 감사 | **Direct** — `report.md` 바로 작성 |
| **Complex** | 전체 사이트 감사, 다수 페이지 분석, 기술 SEO + 콘텐츠 SEO + Core Web Vitals 종합, 경쟁사 비교 포함 | **Tracked** — `flow.json`으로 단계 추적 |

다음 형식으로 분류를 알린다:

```text
Complexity: [simple/complex] — [한 줄 이유]
```

애매하면 complex로 분류한다.

</complexity_classification>

<score_optimization_mode>

## 점수 최적화 모드

사용자가 최고 점수, 만점, max score, 무한 반복을 요청하면 이 모드를 사용한다. 여기서 “무한”은 위험한 무제한 루프가 아니라 안전 게이트가 있는 지속 반복으로 해석한다.

필수 루프 규율:

1. 변경 전에 baseline score를 확정한다. category score, overall grade, 현재 점수를 `results.json`에 기록한다.
2. 목표 점수를 정한다. 기본 목표는 평균 category score `>= 95` 및 `critical` finding 0개다. 사용자가 더 엄격한 목표를 주면 그것을 따른다.
3. 한 iteration에는 하나의 고영향 변경 또는 권장 조치 묶음만 선택하고, 적용 또는 명시한 뒤 영향 범위를 다시 감사한다.
4. 최고 결과를 유지한다. 새 iteration이 점수를 낮추거나 unresolved critical finding을 늘리면 rollback/revert하거나 `discarded`로 표시하고 이전 `best_run`을 유지한다.
5. 개선이 발견되는 동안 자동으로 계속한다. validator 통과, 사용자 중단, 예산 소진, 또는 3회 연속 plateau일 때만 멈춘다.
6. `results.json`에 `score_history`, `best_run`, iteration notes, validator evidence를 기록하고, `report.md`에는 사람이 읽는 요약을 남긴다.
7. 코드 변경을 동반한 최적화라면 완료 선언 전 관련 test/build/lint를 실행한다.

완료는 artifact-gated다. `results.json.status`가 `complete`이고, `best_run`이 채워져 있으며, 최종 점수 또는 plateau 조건을 증명하는 검증 evidence가 있을 때만 완료라고 말한다.

</score_optimization_mode>

<universal_intake>

## Universal Intake

어떤 프로젝트든 점수화 전에 감사 맥락을 먼저 분류한다:

- `target_type`: `live-url`, `local-static`, `nextjs`, `react-spa`, `docs-site`, `ecommerce`, `blog`, `app-with-marketing-pages`
- `access_level`: live URL, local files only, Search Console available, analytics available, AI citation probe available
- `allowed_action`: `audit-only`, `recommend`, `edit-code`, `optimize-loop`
- `measurement_confidence`: live URL, Search Console, field Core Web Vitals, AI citation probe가 없으면 confidence를 낮춘다

부족한 evidence를 숨기지 않는다. 정적 파일, lab data, synthetic probe, heuristic 기반 권장이라면 `results.json`에 그렇게 표시한다.

</universal_intake>

<document_shape>

기본 출력 형태:

```text
.hypercore/seo-maker/[slug]/
├── dashboard.html      # 브라우저에서 열 수 있는 대시보드
├── results.json        # 구조화된 감사 결과 (JSON)
├── results.js          # file:// 브라우저 폴백용
├── report.md           # 마크다운 리포트
├── sources.md          # 출처 기록
└── flow.json           # complex path only
```

- `results.json`은 구조화된 감사 데이터다. 전체 스키마는 [references/artifact-spec.md](references/artifact-spec.md)를 따른다.
- `dashboard.html`은 [assets/dashboard-template.html](assets/dashboard-template.html)에서 렌더한 self-contained 대시보다.
- `results.js`는 `results.json`의 `file://` 폴백이다.
- `report.md`는 결과와 권장 조치를 담은 SEO 감사 리포트다.
- `sources.md`는 사용한 근거, 도구 출력, 참고 링크를 기록한다.
- `flow.json`은 complex 경로에서 단계 상태를 추적한다.
- 폴더가 아직 없으면 [assets/report.template.md](assets/report.template.md)로 report를 만든다.
- `results.json`이 확정되면 `scripts/render-dashboard.sh <artifact-dir>`로 dashboard를 렌더한다.

</document_shape>

<flow_tracking>

## Flow Tracking (Complex Path Only)

complex로 분류되면 `flow.json`을 쓰고 각 단계가 진행될 때마다 업데이트한다.

### Phase progression

| Phase | Description | Next |
|-------|-------------|------|
| `scope` | 감사 범위 정의 — 대상 URL, 초점 영역, 제약 | `measurement` |
| `measurement` | 접근 수준, evidence channel, confidence 한계, measurement method 기록 | `technical` |
| `technical` | 기술 SEO 분석 — robots.txt, sitemap, canonical, 구조화 데이터, Core Web Vitals | `platform_policy` |
| `platform_policy` | search/AI crawler control, snippet directive, AI bot access, optional llms.txt 분석 | `onpage` |
| `onpage` | 온페이지 SEO 분석 — title, meta description, headings, images, internal links | `content` |
| `content` | 콘텐츠 품질 분석 — E-E-A-T, keyword usage, readability, freshness | `aeo` |
| `aeo` | AEO 준비도 분석 — Q&A 포맷, 직접 답변, Featured Snippet, 음성 검색 최적화 | `geo` |
| `geo` | GEO 준비도 분석 — AI 인용 가능성, GEO CORE, 엔터티 권위, 플랫폼별 최적화 | `report` |
| `report` | 우선순위가 매겨진 실행 가능한 리포트 작성 | done |

### Resume support

`flow.json`이 이미 있으면 먼저 읽고, 마지막 미완료 단계부터 이어간다.

</flow_tracking>

<support_file_read_order>

다음 순서로 읽는다:

1. 코어 `SKILL.md`로 현재 작업이 SEO/AEO/GEO 분석 또는 감사인지 확정한다.
2. [rules/seo-workflow.md](rules/seo-workflow.md)로 단계별 실행 방식을 확인한다.
3. [references/seo-fundamentals.md](references/seo-fundamentals.md)로 E-E-A-T, Core Web Vitals, 랭킹 요소, entity SEO, schema markup 기준을 확인한다.
4. [references/aeo-geo-guide.md](references/aeo-geo-guide.md)로 AEO/GEO/LLMO 전략, GEO CORE 프레임워크, 플랫폼별 벤치마크, `llms.txt` 가이드를 확인한다.
5. [references/seo-checklist.md](references/seo-checklist.md)로 실무 감사 체크리스트를 확인한다.
6. [references/artifact-spec.md](references/artifact-spec.md)로 `results.json` 스키마, dashboard lifecycle, workspace 구조를 확인한다.
7. 새 report를 만들 때는 [assets/report.template.md](assets/report.template.md)를 읽는다.
8. dashboard를 렌더할 때는 [assets/dashboard-template.html](assets/dashboard-template.html)을 읽는다.
9. 완료 선언 전에는 [rules/validation.md](rules/validation.md)를 읽는다.

</support_file_read_order>

<workflow>

## Simple Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | SEO 산출물 여부 확인, `create`/`update`/`optimize` 선택, simple 분류 | Mode + complexity |
| 1 | 대상 파일에서 SEO 요소 스캔 | Raw findings |
| 2 | `.hypercore/seo-maker/[slug]/` 생성 또는 탐색 | Storage target |
| 3 | 결과와 권장 조치가 담긴 `report.md` 작성 | SEO report |
| 4 | 완결성 검증 | Finalized report |

## Complex Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | SEO 산출물 여부 확인, `create`/`update`/`optimize` 선택, complex 분류 | Mode + complexity |
| 1 | `.hypercore/seo-maker/[slug]/` 생성 또는 탐색, `flow.json`에 `scope: in_progress` 기록 | Storage + flow |
| 2 | 감사 범위 정의 → `scope: completed` 업데이트 | Scope definition |
| 3 | Measurement setup → `measurement: completed` | Evidence channels + confidence limits |
| 4 | 기술 SEO 분석 → `technical: completed` | Technical findings |
| 4.5 | Platform policy analysis → `platform_policy: completed` | Search/AI crawler + snippet controls |
| 5 | 온페이지 SEO 분석 → `onpage: completed` | On-page findings |
| 6 | 콘텐츠 SEO 분석 → `content: completed` | Content findings |
| 7 | AEO 준비도 분석 → `aeo: completed` | AEO findings |
| 8 | GEO 준비도 분석 → `geo: completed` | GEO findings |
| 9 | 우선순위 리포트 작성 → `report: completed` | Final report |
| 10 | 검증 및 마무리 | Finalized audit |


## Optimize Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | 최고 점수/만점 의도를 확인하고 `optimize` 선택 | Target score + loop budget |
| 1 | 수정 전 baseline audit 실행 | Baseline `score_history[0]` |
| 2 | 가장 영향이 큰 개선 하나만 선택 | Iteration plan |
| 3 | 개선을 적용하거나 문서화하고 재감사 | New score + evidence |
| 4 | 점수가 오르면 keep, 아니면 rollback/revert 또는 discard | Updated `best_run` |
| 5 | 목표, validator approval, budget stop, user stop, 3회 plateau 중 하나까지 반복 | Completion artifact evidence |

</workflow>

<required>

- 작업 시작 전에 complexity(simple/complex)를 분류한다.
- 모든 report는 `.hypercore/seo-maker/[slug]/` 아래에 저장한다.
- slug는 가능하면 ASCII kebab-case를 사용한다.
- 모든 finding에는 severity(`critical`/`warning`/`info`)와 구체적 fix recommendation이 있어야 한다.
- 모든 non-obvious finding에는 `evidence_grade`, `confidence`, `measurement_method`, `source_tier`를 포함한다.
- 공식 플랫폼 요구사항, 실험적 GEO 연구, heuristic AEO/GEO 전술을 구분한다.
- Optimize mode에서는 reset event를 기록하지 않는 한 같은 eval set을 유지한다.
- Optimize mode에서는 iteration마다 하나의 변경만 적용하고, 점수 상승 변경만 유지한다. 단, 점수 회귀 없는 검증된 단순화는 유지할 수 있다.
- 권장 조치는 SEO 영향도 순으로 정렬한다. (high → low)
- E-E-A-T와 Core Web Vitals 기준은 `references/seo-fundamentals.md`를 따른다.
- AI 검색 준비도를 볼 때는 `references/aeo-geo-guide.md`를 따른다.
- complex 경로에서는 `flow.json`을 유지하고 단계별로 갱신한다.
- 사용자가 전통 SEO만 명시적으로 요청한 경우가 아니면 complex 경로에 AEO와 GEO 단계를 포함한다.

</required>

<deliverables>

실행이 끝나면 다음이 `.hypercore/seo-maker/[slug]/`에 남아 있어야 한다:

- `results.json` — 구조화된 감사 결과 (`status: complete`)
- `dashboard.html` — 브라우저 대시보드 (`render-dashboard.sh`로 생성)
- `results.js` — `file://` 폴백
- `report.md` — 마크다운 리포트
- `sources.md` — 출처 기록
- `flow.json` — complex path only
- Optimize mode에서는 `results.json` 안에 `score_history`, `best_run`, validator evidence를 추가 기록

파일 스키마는 [references/artifact-spec.md](references/artifact-spec.md)를 따른다.
