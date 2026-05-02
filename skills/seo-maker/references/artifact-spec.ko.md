# SEO 감사 산출물 명세

SEO 감사 실행의 결과 워크스페이스를 만들거나 검토할 때 이 레퍼런스를 사용한다.

## 워크스페이스 형태

```text
.hypercore/seo-maker/[slug]/
├── dashboard.html       # 브라우저에서 열 수 있는 대시보드
├── results.json         # 구조화된 감사 결과
├── results.js           # file:// 브라우저 폴백용
├── report.md            # Markdown 리포트(기존)
├── sources.md           # 출처 기록(기존)
└── flow.json            # complex path only(기존)
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

### 증거 및 신뢰도 필드

명확하지 않은 모든 발견사항은 다음을 포함해야 한다:

- `evidence_grade`: `official`, `field`, `tool`, `lab`, `synthetic`, `heuristic`.
- `confidence`: `high`, `medium`, `low`.
- `measurement_method`: 발견사항을 만든 스캔, 도구, probe, 출처.
- `source_tier`: `official-doc`, `observed-file`, `field-data`, `tool-output`, `synthetic-probe`, `research-backed-heuristic`.

공식 문서, 직접 파일/헤더 관찰, field data에는 높은 신뢰도를 사용한다. 로컬 전용 정적 스캔, lab-only performance, synthetic AI prompt probe, heuristic AEO/GEO 조언에는 더 낮은 신뢰도를 사용한다.

### 측정 및 플랫폼 필드

- `measurement_methods`는 사용 가능한 증거 채널과 그것이 신뢰도에 미친 영향을 기록한다.
- `platform_policy`는 플랫폼 또는 봇별 검색/AI crawler 및 snippet controls를 기록한다. `OAI-SearchBot` 검색 포함과 `GPTBot` 학습 정책을 분리한다.
- `query_fanout`은 생성된 하위 쿼리와 누락된 주제 커버리지를 기록한다.
- `citation_probe`는 실행 시 AI 엔진, 프롬프트 세트, 인용 URL, 브랜드 언급, 표본 크기, 날짜, 신뢰도를 기록한다. 실행하지 않았다면 `status: "not-run"`과 이유를 저장한다.

### Optimize mode 필드

`mode`가 `optimize`이거나 사용자가 highest/max/perfect score를 요청했을 때 `results.json`에 다음 필드를 추가한다:

- `target_score` — 숫자 목표. 사용자가 다른 목표를 지정하지 않으면 기본값은 `95`.
- `score_history[]` — 순서가 있는 iteration log. 각 항목은 `iteration`, `score`, `grade`, `critical_count`, `decision`, `changed`, `evidence`를 포함한다.
- `best_run` — 가장 높은 점수를 받은 kept iteration. 완료 전 필수.
- `validator` — `{ "status": "passed" }` 또는 architect review verdict 같은 artifact-gated completion evidence.
- `plateau` — 점수 향상이 더 없어 완료할 때 `consecutive_iterations`와 `reason`을 담는 선택 객체.

규칙:

1. `score_history[0]`은 항상 변경 전 baseline이다.
2. 이후 점수는 evaluator가 안정적으로 유지될 때만 비교 가능하다. scoring이 바뀌면 reset event를 기록한다.
3. `best_run`은 discarded iteration을 가리키면 안 된다.
4. 코드 변경이 있었다면 validator evidence에는 관련 test/build/lint 명령 출력 요약이 포함되어야 한다.

### 상태 값

- `running` — 감사 진행 중
- `idle` — 대기 중
- `complete` — 감사 완료

### 기본 카테고리 목록

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

- `critical` — 색인을 차단하거나 랭킹을 심각하게 해침
- `warning` — 랭킹 또는 UX 저하
- `info` — 개선 기회

## `results.js`

`file://`로 열었을 때 `fetch`가 작동하지 않는 브라우저를 위한 폴백:

```javascript
window.__SEO_RESULTS__ = { /* results.json과 동일한 내용 */ };
```

항상 `results.json`과 동기화한다.

## `dashboard.html`

`skills/seo-maker/assets/dashboard-template.html`에서 복사한다.

필수 동작:

- 10초마다 자동 새로고침
- `results.json` 읽기(`file://`에서는 `results.js` 폴백)
- 7개 카테고리 점수 레이더 차트
- Severity 분포 도넛 차트
- 카테고리 점수 바
- Severity 색상 코딩이 있는 Findings 테이블
- Quick Wins 테이블
- Prioritized Actions 테이블
- Overall Grade 표시(A/B/C/D/F)

## `report.md`

기존 `assets/report.template.md`에서 생성한다. `results.json` 데이터를 Markdown으로 렌더링한 형태다.

## 생명주기 규칙

1. 감사 시작 시 `.hypercore/seo-maker/[slug]/`를 만든다.
2. `results.json`의 `status`를 `running`으로 설정한다.
3. 각 phase 완료 시 `results.json`에 findings를 추가한다.
4. 모든 phase 완료 후 `status`를 `complete`로 설정하고 `overall_grade`를 계산한다.
4-1. Optimize mode에서는 `score_history`, `best_run`, `validator`를 채우고 최고 점수 또는 plateau 근거를 기록한다.
5. `render-dashboard.sh`를 실행해 `dashboard.html`과 `results.js`를 생성한다.
6. `report.md`와 `sources.md`도 작성한다.
7. 런타임이 안전하면 `dashboard.html`을 브라우저에서 연다.

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
