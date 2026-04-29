# SEO Audit Artifact Spec

SEO 감사 실행의 결과 워크스페이스를 만들거나 검토할 때 이 레퍼런스를 사용한다.

## 워크스페이스 형태

```text
.hypercore/seo-maker/[slug]/
├── dashboard.html       # 브라우저에서 열 수 있는 대시보드
├── results.json         # 구조화된 감사 결과
├── results.js           # file:// 브라우저 폴백용
├── report.md            # 마크다운 리포트 (기존)
├── sources.md           # 출처 기록 (기존)
└── flow.json            # complex path only (기존)
```

이 디렉터리는 스킬 폴더 안이 아니라 저장소 루트에 만든다.

정식 생성 자산:

- template: `skills/seo-maker/assets/dashboard-template.html`
- renderer: `skills/seo-maker/scripts/render-dashboard.sh`

## `results.json`

```json
{
  "project_name": "my-website",
  "date": "2026-03-27",
  "scope": "Full site audit",
  "status": "complete",
  "overall_grade": "B",
  "categories": [
    { "name": "Technical SEO", "score": 85 },
    { "name": "On-Page SEO", "score": 72 },
    { "name": "Content SEO", "score": 68 },
    { "name": "Core Web Vitals", "score": 90 },
    { "name": "Structured Data", "score": 88 },
    { "name": "AEO Readiness", "score": 45 },
    { "name": "GEO Readiness", "score": 38 }
  ],
  "measurement_methods": {
    "search_console": { "status": "unavailable", "confidence_impact": "medium" },
    "pagespeed_insights": { "status": "lab-only", "tool": "Lighthouse", "confidence": "medium" },
    "rich_results_test": { "status": "not-run", "fallback_method": "schema_static_scan", "confidence": "medium" },
    "ai_citation_probe": { "status": "not-run", "reason": "no engine access" },
    "crawler_policy_scan": { "status": "completed", "method": "robots/meta/header scan", "confidence": "high" }
  },
  "platform_policy": {
    "oai_searchbot": { "status": "allowed", "purpose": "ChatGPT Search inclusion", "evidence_grade": "official", "confidence": "high", "source_tier": "official-doc" },
    "gptbot": { "status": "blocked", "purpose": "OpenAI model training", "evidence_grade": "official", "confidence": "high", "source_tier": "official-doc" },
    "llms_txt": { "status": "missing", "severity": "info", "evidence_grade": "heuristic", "confidence": "medium", "source_tier": "research-backed-heuristic" }
  },
  "query_fanout": {
    "status": "not-run",
    "queries": [],
    "missing_topics": []
  },
  "citation_probe": {
    "status": "not-run",
    "engines": [],
    "sample_size": 0,
    "confidence": "low"
  },
  "findings": [
    {
      "id": "T1",
      "severity": "critical",
      "category": "Technical SEO",
      "finding": "robots.txt blocks /blog/ path",
      "location": "/robots.txt:3",
      "evidence_grade": "lab",
      "confidence": "high",
      "measurement_method": "static robots.txt scan",
      "source_tier": "observed-file",
      "recommendation": "Remove Disallow: /blog/ line"
    },
    {
      "id": "A1",
      "severity": "warning",
      "category": "AEO Readiness",
      "finding": "No direct answer in first paragraph",
      "location": "/blog/what-is-seo.html",
      "evidence_grade": "heuristic",
      "confidence": "medium",
      "measurement_method": "answer block detector",
      "source_tier": "research-backed-heuristic",
      "recommendation": "Add a concise visible answer block near the top of the section"
    }
  ],
  "quick_wins": [
    {
      "action": "Add meta descriptions to 12 pages missing them",
      "impact": "High",
      "effort": "Low"
    }
  ],
  "score_history": [
    {
      "iteration": 0,
      "score": 66,
      "grade": "C",
      "critical_count": 1,
      "decision": "baseline",
      "evidence": "Initial audit before optimization changes"
    },
    {
      "iteration": 1,
      "score": 78,
      "grade": "B",
      "critical_count": 0,
      "decision": "kept",
      "changed": "Removed robots.txt block for /blog/",
      "evidence": "Re-audit confirmed indexability restored"
    }
  ],
  "best_run": {
    "iteration": 1,
    "score": 78,
    "grade": "B",
    "reason": "Highest kept score with zero critical findings"
  },
  "validator": {
    "status": "passed",
    "summary": "Target passed or plateau condition verified"
  },
  "actions": [
    {
      "priority": 1,
      "category": "Technical SEO",
      "action": "Fix robots.txt blocking blog content",
      "impact": "High",
      "effort": "Low"
    },
    {
      "priority": 2,
      "category": "GEO Readiness",
      "action": "Add statistics and citations to top 10 pages",
      "impact": "High",
      "effort": "Medium"
    }
  ]
}
```

### Evidence and confidence fields

Every non-obvious finding should include:

- `evidence_grade`: `official`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`.
- `confidence`: `high`, `medium`, or `low`.
- `measurement_method`: the scan, tool, probe, or source used to produce the finding.
- `source_tier`: `official-doc`, `observed-file`, `field-data`, `tool-output`, `synthetic-probe`, or `research-backed-heuristic`.

Use high confidence for official docs, direct file/header observations, or field data. Use lower confidence for local-only static scans, lab-only performance, synthetic AI prompt probes, and heuristic AEO/GEO advice.

### Measurement and platform fields

- `measurement_methods` records which evidence channels were available and how they affected confidence.
- `platform_policy` records search/AI crawler and snippet controls by platform or bot. Separate `OAI-SearchBot` search inclusion from `GPTBot` training policy.
- `query_fanout` records generated subqueries and missing topical coverage.
- `citation_probe` records AI engine, prompt set, cited URLs, brand mentions, sample size, date, and confidence when run. If not run, store `status: "not-run"` and the reason.

### Optimize mode fields

When `mode` is `optimize` or the user asked for highest/max/perfect score, add these fields to `results.json`:

- `target_score` — numeric goal, default `95` unless the user specified another target.
- `score_history[]` — ordered iteration log. Each item includes `iteration`, `score`, `grade`, `critical_count`, `decision`, `changed`, and `evidence`.
- `best_run` — the highest-scoring kept iteration. Required before completion.
- `validator` — artifact-gated completion evidence, such as `{ "status": "passed" }` or an architect review verdict.
- `plateau` — optional object with `consecutive_iterations` and `reason` when completion is due to no further score gains.

Rules:

1. `score_history[0]` is always the baseline before changes.
2. Later scores are comparable only when the evaluator stayed stable. If scoring changes, record a reset event.
3. `best_run` must not point to a discarded iteration.
4. If code changes were made, validator evidence should include the relevant test/build/lint command output summary.

### 상태 값

- `running` — 감사 진행 중
- `idle` — 대기 중
- `complete` — 감사 완료

### 카테고리 기본 목록

7개 카테고리, 각각 0-100 점수. 점수와 별도로 `measurement_confidence`를 보고해야 한다:

1. Technical SEO
2. On-Page SEO
3. Content SEO
4. Core Web Vitals
5. Structured Data
6. AEO Readiness
7. GEO Readiness

### Finding ID 규칙

- `T1`, `T2`... — Technical SEO
- `O1`, `O2`... — On-Page SEO
- `C1`, `C2`... — Content SEO
- `W1`, `W2`... — Core Web Vitals
- `S1`, `S2`... — Structured Data
- `A1`, `A2`... — AEO Readiness
- `G1`, `G2`... — GEO Readiness

### Severity 값

- `critical` — 인덱싱 차단 또는 랭킹 심각 저하
- `warning` — 랭킹 또는 UX 저하
- `info` — 개선 기회

## `results.js`

`file://`로 열었을 때 `fetch`가 안 되는 브라우저를 위한 폴백:

```javascript
window.__SEO_RESULTS__ = { /* results.json과 동일한 내용 */ };
```

항상 `results.json`과 동기화한다.

## `dashboard.html`

`skills/seo-maker/assets/dashboard-template.html`에서 복사한다.

필수 동작:

- 10초마다 자동 새로고침
- `results.json` 읽기 (`file://`일 때는 `results.js` 폴백)
- 7개 카테고리 점수 레이더 차트
- Severity 분포 도넛 차트
- 카테고리별 점수 바
- Finding 테이블 (severity 색상 코딩)
- Quick Wins 테이블
- Prioritized Actions 테이블
- Overall Grade 표시 (A/B/C/D/F)

## `report.md`

기존 `assets/report.template.md`에서 생성. `results.json`의 데이터를 마크다운으로 풀어쓴 형태.

## 생명주기 규칙

1. 감사 시작 시 `.hypercore/seo-maker/[slug]/`를 만든다
2. `results.json`의 `status`를 `running`으로 설정한다
3. 각 phase 완료 시 `results.json`에 findings를 추가한다
4. 모든 phase 완료 후 `status`를 `complete`로, `overall_grade`를 계산한다
4-1. Optimize mode라면 `score_history`, `best_run`, `validator`를 채우고 최고 점수 또는 plateau 근거를 기록한다
5. `render-dashboard.sh`를 실행해 `dashboard.html`과 `results.js`를 생성한다
6. `report.md`와 `sources.md`도 함께 작성한다
7. 런타임이 안전하면 `dashboard.html`을 브라우저에서 연다

### Grade 계산

카테고리 점수 평균:

| Average | Grade |
|---------|-------|
| >= 90 | A |
| >= 75 | B |
| >= 60 | C |
| >= 40 | D |
| < 40 | F |

### 렌더 순서

```bash
skills/seo-maker/scripts/render-dashboard.sh .hypercore/seo-maker/my-site
open .hypercore/seo-maker/my-site/dashboard.html
```
