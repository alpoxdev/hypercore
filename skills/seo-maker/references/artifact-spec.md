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
    { "name": "AEO Readiness", "score": 45 },
    { "name": "GEO Readiness", "score": 38 }
  ],
  "findings": [
    {
      "id": "T1",
      "severity": "critical",
      "category": "Technical SEO",
      "finding": "robots.txt blocks /blog/ path",
      "location": "/robots.txt:3",
      "recommendation": "Remove Disallow: /blog/ line"
    },
    {
      "id": "A1",
      "severity": "warning",
      "category": "AEO",
      "finding": "No direct answer in first paragraph",
      "location": "/blog/what-is-seo.html",
      "recommendation": "Add 40-60 word direct answer at top of content"
    }
  ],
  "quick_wins": [
    {
      "action": "Add meta descriptions to 12 pages missing them",
      "impact": "High",
      "effort": "Low"
    }
  ],
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
      "category": "GEO",
      "action": "Add statistics and citations to top 10 pages",
      "impact": "High",
      "effort": "Medium"
    }
  ]
}
```

### 상태 값

- `running` — 감사 진행 중
- `idle` — 대기 중
- `complete` — 감사 완료

### 카테고리 기본 목록

6개 카테고리, 각각 0-100 점수:

1. Technical SEO
2. On-Page SEO
3. Content SEO
4. Core Web Vitals
5. AEO Readiness
6. GEO Readiness

### Finding ID 규칙

- `T1`, `T2`... — Technical SEO
- `O1`, `O2`... — On-Page SEO
- `C1`, `C2`... — Content SEO
- `A1`, `A2`... — AEO
- `G1`, `G2`... — GEO

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
- 6개 카테고리 점수 레이더 차트
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
