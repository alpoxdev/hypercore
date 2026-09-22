---
name: seo-maker
description: SEO/AEO/GEO 통합 분석 및 최적화 리포트를 생성한다. 전통 SEO(온페이지, 기술, 콘텐츠, Core Web Vitals)에 더해 AEO(Answer Engine Optimization), GEO(Generative Engine Optimization), LLMO(LLM Optimization)까지 점검하고 개선안을 `.hyper/seo-maker/[slug]/`에 저장한다. "SEO 분석", "AEO 최적화", "GEO 점검", "AI 검색 최적화", "검색엔진 최적화", "메타태그 점검", "SEO 감사", "AI 인용 최적화", "최고 점수까지 반복", "SEO 점수 만점까지 수정" 요청 시 사용.
compatibility: 로컬 파일 검색/수정 도구와 경쟁사/SERP/AI 인용 분석용 라이브 웹 검색을 함께 쓸 때 가장 잘 동작한다.
---

@rules/seo-workflow.md
@rules/validation.md

# SEO Maker

> 프로젝트의 SEO/AEO/GEO 상태를 분석하고, 전통 검색엔진과 AI 검색엔진 모두에 대한 최적화 리포트를 산출한다.

<instruction_contract>

| 필드 | 계약 |
|---|---|
| 의도 | 이름이 지정된 대상에 대해 증거 등급이 매겨진 SEO/AEO/GEO/LLMO 감사와 우선순위화된 실행 가능 개선안 리포트를 만들고, 사용자가 도달 가능한 최고 점수를 요청하면 유한 예산의 점수 개선 루프를 돌린다. |
| 범위 | 대상 분류, 측정 방법 선택, 온페이지·기술·콘텐츠·Core Web Vitals·AEO·GEO·LLMO 평가, 점수 산정, 발견 사항, 개선안, 리포트 워크스페이스를 담당한다. 감사 대상 밖의 구현, 릴리스 게이트, 페이지·제품 디자인, 대상 사이트나 콘텐츠 집합이 없는 광범위한 시장 조사는 담당하지 않는다. |
| 권한 | 시스템/하네스와 사용자 지시 > 감사 대상 자체 파일과 라이브 관측 > 공식 플랫폼 문서 > 이 스킬 > 휴리스틱 선호. 도구·lab·synthetic·heuristic 관측은 공식 요구사항으로 승격하지 않는다. |
| 근거 | 점수를 매기기 전에 대상 자체 파일, 렌더된 페이지, 라이브 응답을 읽고, 모든 critical·warning 발견 사항에 명령 출력·URL·파일 경로·probe 결과를 붙인다. 확인할 수 없는 점검은 `unknown`, 해당 없는 점검은 `not-applicable`로 기록하고, 점수·순위·포함·인용을 지어내지 않는다. |
| 도구 | 사용 가능한 읽기/검색/브라우저 도구를 쓰고, 대시보드는 `scripts/render-dashboard.mjs <artifact-dir>`로 렌더한다. 웹 검색, 브라우저 점검, 필드 Core Web Vitals, Search Console, AI 인용 probe는 실제로 사용 가능할 때만 쓰고, 없으면 능력 한계와 더 낮은 등급의 대체 방법을 밝힌다. |
| 루프 | optimize 모드 전용으로 `audit -> 수정 또는 개선안 -> re-audit`을 유한하게 반복하며 기본 예산은 3회다. 피드백은 비교 가능한 재감사 증거, 지표는 `unknown`·`not-applicable` 카테고리를 제외한 100점 점수, 가드는 비교 가능한 카테고리 회귀 없음과 증거 등급 승격 없음, 중단은 목표 달성·예산 소진·정체·가드 실패·외부 자격 증명이나 사업 판단이 필요한 시점이다. |
| 출력 | `.hyper/seo-maker/[slug]/`에 `results.json`, `results.js`, `dashboard.html`, `report.md`, `sources.md`, complex·optimize 모드의 `flow.json`을 둔다. simple 모드는 `report.md`와 `sources.md`가 최소다. `sources.md`는 URL, 날짜, 적용 주장, 증거 등급, 한계를 적는 출처 원장이다. |
| 검증 | 완료 시 `rules/validation.md`를 적용한다. 모든 critical·warning 발견 사항에 증거가 있고, 점수는 관측 증거에서 나오며 `unknown`·`not-applicable`을 명시적으로 처리하고, optimize 모드는 기준선·평가자·예산·가드·폐기한 반복·중단 사유·비교 가능한 최고 검증 결과를 기록한다. 패키지 변경 시에는 집중 코퍼스 검증기, 저장소 표준 게이트, 패키지 테스트를 함께 실행한다. |
| 중단 조건 | 요청된 감사나 리포트가 등급이 매겨진 증거와 미해결 critical 공백 없이 끝났을 때, 또는 optimize 모드가 목표·예산·정체·가드·외부 의존에 도달했을 때 중단한다. 증거가 뒷받침하지 않는 순위·AI 기능 포함·인용을 주장하며 중단하지 않는다. |

</instruction_contract>

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- 웹사이트나 프로젝트의 SEO 현황을 체계적으로 감사(audit)한다.
- 온페이지 SEO, 기술 SEO, 콘텐츠 SEO, Core Web Vitals를 종합 점검한다.
- AEO(Answer Engine Optimization) — Featured Snippet, 음성 검색, AI 직접 답변 선택 최적화를 점검한다.
- GEO(Generative Engine Optimization) — AI 생성 응답에서의 인용 가능성을 점검한다.
- 우선순위가 매겨진 개선안 리포트를 `.hyper/seo-maker/[slug]/`에 저장한다.
- 기존 리포트를 업데이트하여 SEO 개선 이력을 추적한다.
- 사용자가 최고 점수/만점/무한 반복을 요청하면 유한한 예산과 중단 게이트가 있는 최적화 과정으로 audit → fix recommendation/application → re-audit를 수행하고, 비교 가능한 최고 검증 결과만 유지한다. 순위, AI 기능 포함, 인용을 보장하지 않는다.

</purpose>

<routing_rule>

SEO 분석, 감사, 최적화 리포트가 주된 산출물일 때 `seo-maker`를 사용한다.

경쟁사/시장 조사처럼 SEO 산출물이 아닌 일반 리서치면 `research`를 사용한다.

결과물이 제품 요구사항 문서(PRD)면 이 스킬의 산출물이 아니다.

배포 전 검증이 목적이면 산출물이 배포 게이트 판정이므로 이 스킬이 소유하지 않는다.

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
- "배포 전 체크리스트 확인해줘." → 배포 게이트 판정이며 검색 가시성 감사가 아니다

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
- Schema.org JSON-LD 마크업 (보이는 콘텐츠와의 일치 여부 포함)
- AEO 요소 — Q&A 포맷, 직접 답변 구조, Featured Snippet 준비도
- GEO 요소 — 출처가 있는 검증 가능한 주장, 엔터티 권위, 인용 준비도. 인용을 보장하지 않는다.
- LLMO 요소 — AI 크롤러 접근성, 콘텐츠 신선도, 선택적 `llms.txt`. `llms.txt`는 표준이나 랭킹/인용 요건이 아닌 선택적 제안이다.
- Naver 검색 surface — target set이 Naver 검색 surface를 포함할 때만 점검한다. `Yeti` 크롤러 접근, 서치어드바이저 소유확인, RSS·사이트맵 소유확인 도메인 일치, `og:image` 조건, `nosourceinfo` 범위.
- Bing surface — target set이 Bing surface를 포함할 때만 점검한다. IndexNow 변경 알림(수신 코드는 색인·인용 증거가 아님), 키 파일 소유 증명, POST당 제출 상한, Bing 사이트맵 필드 처리.
- Platform policy — Googlebot, Google-Extended, OAI-SearchBot, GPTBot, ChatGPT-User를 목적별로 별도 점검하고 하나의 bot rule을 다른 bot에 적용하지 않는다. Naver surface에서는 `Yeti` 접근, 서치어드바이저 소유확인, 피드 소유 도메인 일치, `og:image` 조건, `nosourceinfo` 범위를 점검하고, `nosnippet`·`Google-Extended`·FAQPage 리치 결과·`llms.txt` 같은 Google 전용 지시자를 Naver로 전이하지 않는다.
- Google AI 기능 — 일반 SEO 기본 원칙과 관련 있는 index/snippet eligibility를 점검한다. 특별 AI schema나 text file을 요구하지 않으며, 적격한 indexed/snippet-eligible 페이지도 포함이 보장되지는 않는다.

</supported_targets>

<complexity_routing>

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

</complexity_routing>

<universal_intake>

## Universal Intake

어떤 프로젝트든 점수화 전에 감사 맥락을 먼저 분류한다:

- `target_type`: `live-url`, `local-static`, `nextjs`, `react-spa`, `docs-site`, `ecommerce`, `blog`, `app-with-marketing-pages`
- `access_level`: live URL, local files only, Search Console available, analytics available, field Core Web Vitals available, AI citation probe available, available tools
- `allowed_action`: `audit-only`, `recommend`, `edit-code`, `optimize-loop`
- `measurement_confidence`: live URL, Search Console, field Core Web Vitals, AI citation probe가 없으면 confidence를 낮춘다
- `evaluator`: comparable target set, scoring rubric, tools/versions, dates, evidence channels

모든 finding과 score input은 정확히 하나의 `official`, `live`, `field`, `tool`, `lab`, `synthetic`, `heuristic`으로 분류한다. local scan은 live/field evidence가 아니며 tool/lab result는 official requirement가 아니다. 사용할 수 없는 검사는 `unknown`, 관련 없는 검사는 `not-applicable`으로 기록하고 `not-applicable`은 category denominator에서 제외한다.

부족한 evidence를 숨기지 않는다. 정적 파일, lab data, synthetic probe, heuristic 기반 권장은 `results.json`에 그렇게 표시한다. live browsing, Search Console, field data, AI probe, named tool을 쓸 수 없으면 가장 강한 낮은 등급의 방법을 사용하고 capability limitation과 fallback을 밝히며 live performance, ranking, inclusion, citation을 주장하지 않는다.

</universal_intake>

<artifact_contract>

기본 출력 형태:

```text
.hyper/seo-maker/[slug]/
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
- `sources.md`는 source ledger다. 각 external 또는 official source-sensitive claim에 URL, accessed 또는 published date, applicable claim, evidence class, scope/availability limitation을 기록한다.
- `flow.json`은 complex 경로에서 단계 상태를 추적한다.
- 폴더가 아직 없으면 기본적으로 [assets/report.template.ko.md](assets/report.template.ko.md)로 report를 만든다. 영어가 명시적으로 필요할 때만 [assets/report.template.md](assets/report.template.md)를 사용한다.
- `results.json`이 확정되면 `scripts/render-dashboard.mjs <artifact-dir>`로 dashboard를 렌더한다.


complex 또는 optimize 모드에서는 `flow.json`은 정본 순서대로 단계를 추적한다: `scope` → `measurement` → `technical` → `platform_policy` → `onpage` → `content` → `aeo` → `geo` → `report`.

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
</artifact_contract>

<support_file_read_order>

다음 순서로 읽는다:

1. 코어 `SKILL.md`로 현재 작업이 SEO/AEO/GEO 분석 또는 감사인지 확정한다.
2. [rules/seo-workflow.md](rules/seo-workflow.md)로 단계별 실행 방식을 확인한다.
3. [references/seo-fundamentals.md](references/seo-fundamentals.md)로 E-E-A-T, Core Web Vitals, 랭킹 요소, entity SEO, schema markup 기준을 확인한다.
4. [references/aeo-geo-guide.md](references/aeo-geo-guide.md)로 AEO/GEO/LLMO 전략, GEO CORE 프레임워크, 플랫폼별 벤치마크, `llms.txt` 가이드를 확인한다.
5. [references/seo-checklist.md](references/seo-checklist.md)로 실무 감사 체크리스트를 확인한다.
6. [references/artifact-spec.md](references/artifact-spec.md)로 `results.json` 스키마, dashboard lifecycle, workspace 구조를 확인한다.
7. 새 report를 만들 때는 기본적으로 [assets/report.template.ko.md](assets/report.template.ko.md)를 읽고, 영어가 명시적으로 필요할 때만 [assets/report.template.md](assets/report.template.md)를 읽는다.
8. dashboard를 렌더할 때는 [assets/dashboard-template.html](assets/dashboard-template.html)을 읽는다.
9. 완료 선언 전에는 [rules/validation.md](rules/validation.md)를 읽는다.

</support_file_read_order>

<workflow>

## Simple Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | SEO 산출물 여부 확인, `create`/`update`/`optimize` 선택, simple 분류 | Mode + complexity |
| 1 | 대상 파일에서 SEO 요소 스캔 | Raw findings |
| 2 | `.hyper/seo-maker/[slug]/` 생성 또는 탐색 | Storage target |
| 3 | 결과와 권장 조치가 담긴 `report.md` 작성 | SEO report |
| 4 | 완결성 검증 | Finalized report |

## Complex Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | SEO 산출물 여부 확인, `create`/`update`/`optimize` 선택, complex 분류 | Mode + complexity |
| 1 | `.hyper/seo-maker/[slug]/` 생성 또는 탐색, `flow.json`에 `scope: in_progress` 기록 | Storage + flow |
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

<audit_dimensions>

대상에 해당할 때 다음 차원을 감사한다: technical SEO(크롤 가능성, 색인 가능성, canonical, sitemap, robots 지시자, 응답 상태, 리다이렉트, 중복 페이지), platform policy(Googlebot, Google-Extended, OAI-SearchBot, GPTBot, ChatGPT-User를 각각 별개 제어로 보고 snippet control과 X-Robots-Tag를 점검하며, 대상에 해당할 때만 Naver·Bing/IndexNow 모듈을 추가), on-page SEO(title, description, 제목 계층, 키워드 정합, URL 가독성, 내부 링크), content SEO(검색 의도 일치, 깊이, 주제 커버리지, 최신성, 고유성, 가독성), Core Web Vitals(LCP, INP, CLS, 렌더 차단 리소스, 이미지 크기, 상호작용 지연), structured data(JSON-LD 유효성, Schema.org 적합성, 표시 콘텐츠와의 일치, 엔터티 식별자, breadcrumb, FAQ·제품·글·조직 마크업), AEO(눈에 보이는 답변 블록, Q&A 구조, snippet 대응 요약, 음성 검색 표현, 직접 답변 명확성), GEO(인용 가능한 주장, 출처가 붙은 통계, 엔터티 권위, 저자·브랜드 신뢰 신호, 안전하게 인용 가능한 콘텐츠), LLMO(선택적 `llms.txt`, AI 크롤러 접근, 정돈된 markdown 또는 시맨틱 HTML, 명확한 엔터티 관계, 최신 canonical 콘텐츠).

차원별 기준과 조건부 플랫폼 모듈은 [rules/seo-workflow.md](rules/seo-workflow.md) 3-8단계, [references/seo-checklist.md](references/seo-checklist.md), [references/seo-fundamentals.md](references/seo-fundamentals.md), [references/aeo-geo-guide.md](references/aeo-geo-guide.md)에 있다.

글자 수·제목 개수·링크 밀도·답변 길이·단어 수·플랫폼 콘텐츠 선호는 맥락 의존 휴리스틱이며 공식 통과/실패 조건이 아니다. 구조화 데이터나 `llms.txt`, 일반적인 색인·snippet 자격이 리치 결과·순위·AI 포함·인용을 보장한다고 암시하지 않는다. Google AI features는 특별한 AI 스키마나 텍스트 파일 없이 일반 SEO 기본기로 평가한다.

</audit_dimensions>

<scoring>

근거가 충분할 때 투명한 100점 점수를 쓴다:

- Technical SEO: 20
- On-page SEO: 20
- Content SEO: 15
- Core Web Vitals: 15
- Structured data: 10
- AEO readiness: 10
- GEO/LLMO readiness: 10

근거가 불완전하면 해당 범주를 `unknown`으로 표시한다. 해당 없는 범주는 `not-applicable`로 표시하고 점수 분모에서 제외한다. 확신을 지어내지 말고 휴리스틱을 공식 실패로 바꾸지 않는다.

각 finding에는 다음을 포함한다:
- Severity: `critical`, `warning`, `info` (severity 외 우선순위는 impact/effort 필드를 쓴다).
- Confidence: high, medium, low.
- `evidence_grade`: `official`, `live`, `field`, `tool`, `lab`, `synthetic`, `heuristic`.
- `measurement_method`: 사용한 scan, tool, probe, source, command.
- `source_tier`: `official-doc`, `observed-file`, `live-observation`, `field-data`, `tool-output`, `lab-result`, `synthetic-probe`, `research-backed-heuristic`.
- Evidence: command 출력, URL, 로컬 파일 경로, 브라우저 관찰, 저장한 probe 결과.
- Recommendation: 구체적 조치와 기대 영향.
- Owner surface: code, content, infrastructure, analytics, external platform.

</scoring>

<optimize_loop>

## 점수 최적화 모드

사용자가 최고 점수·만점·지속적 개선을 요청할 때만 optimize 모드를 쓰고, `audit -> 수정 또는 개선안 -> re-audit`을 유한하게 반복하는 과정으로 다룬다. 변경 전에 baseline, stable evaluator, 목표, 유한한 iteration budget(기본 3회), regression guard를 `results.json`에 기록하고, 비교 가능한 evidence가 개선되고 guard를 통과할 때만 유지하며 그렇지 않으면 가능한 경우 rollback/revert하고 `discarded`로 표시한다. 목표 달성, budget 소진, plateau, guard failure, 안전한 로컬 수정 부재, 외부 credential·business decision 필요, 사용자 중단 중 하나에서 멈추고 stop reason을 기록한다. 전체 루프 규칙은 [rules/seo-workflow.md](rules/seo-workflow.md) 9단계에 있다.

만점을 조작하지 않고, 순위·AI 기능 포함·인용을 보장하지 않는다. unknown과 capability limit, 비교 가능한 최고 검증 결과를 보고한다.

</optimize_loop>

<validation>

완료를 선언하기 전에 [rules/validation.md](rules/validation.md)를 적용한다. 모든 critical·warning finding에 evidence가 있고, recommendation은 engineer·marketer·content owner가 실행할 수 있을 만큼 구체적이며, score는 `unknown`·`not-applicable`을 명시적으로 처리한 observed evidence에서 도출하고 assumption이나 heuristic official failure에서 도출하지 않는다. Google AI 기능은 일반 SEO 기본 원칙으로 설명하고, FAQPage 권장은 Google rich-result eligibility와 answer-friendly visible FAQ content를 구분한다. `sources.md`는 URL, date, applicable claim, evidence class, limitation을 담은 source ledger여야 하며, optimize 모드는 baseline, evaluator, finite budget, guard, 변경/권장 조치, re-audit evidence, discarded iteration, stop reason, best comparable verified result를 기록한다.

함께 지킨다: 시작 전 complexity(simple/complex) 분류, 모든 report를 `.hyper/seo-maker/[slug]/`에 저장, slug는 가능하면 ASCII kebab-case, complex 경로에서 `flow.json` 유지, 사용자가 전통 SEO만 요청한 경우가 아니면 AEO·GEO 단계 포함, E-E-A-T와 Core Web Vitals 기준은 [references/seo-fundamentals.md](references/seo-fundamentals.md), AI 검색 준비도는 [references/aeo-geo-guide.md](references/aeo-geo-guide.md)를 따른다. 남아 있어야 할 `.hyper/seo-maker/[slug]/` 산출물은 `<artifact_contract>`에 있다.

</validation>
