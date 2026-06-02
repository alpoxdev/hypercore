# Source Ledger Reference

**목적**: 리서치 산출물의 출처 추적성을 `query → source → claim → caveat`로 남긴다.

---

## 1. Ledger 원칙

- 출처 목록은 bibliography가 아니라 **검증 로그**다.
- 검색 결과 snippet은 `lead`로 기록할 수 있지만, 최종 claim의 primary evidence가 될 수 없다.
- `reviewed`와 `cited`를 분리한다. reviewed source는 결론에 쓰지 않았더라도 왜 제외했는지 남긴다.
- 최신성은 `published/updated`, `accessed_at`, `retrieved_at`, `page_age`, `tool/API version`을 분리한다.

---

## 2. Source Ledger Template

```markdown
| # | Source | URL/path | Publisher | Published/updated | Accessed/retrieved | Version/freshness | Channel | Grade | Role | Relevant claim | Used? | Caveat |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  | official docs/web/github/local | S/A/B/C | lead/primary-evidence/supporting/conflict/rejected |  | yes/no |  |
```

### 필드 설명

| Field | 기준 |
|---|---|
| `Source` | 사람이 식별 가능한 제목 |
| `URL/path` | canonical URL, GitHub permalink, local path |
| `Publisher` | OpenAI, Anthropic, NIST, OWASP, repo owner 등 |
| `Published/updated` | 페이지/문서/릴리스 기준 날짜. 없으면 `not stated` |
| `Accessed/retrieved` | 조사자가 접근한 날짜, fetch timestamp, tool-provided `retrieved_at` |
| `Version/freshness` | API mode, tool version, release tag, `page_age`, cache caveat |
| `Channel` | web, official docs, GitHub, local repo, paper, standard |
| `Grade` | S/A/B/C |
| `Role` | lead, primary-evidence, supporting, conflict, rejected |
| `Relevant claim` | 이 출처가 지지/반박하는 claim 한 문장 |
| `Used?` | 최종 답변에 citation으로 사용했는지 |
| `Caveat` | 접근 불가, 오래됨, vendor bias, method gap, scope mismatch |

---

## 3. Claim-Source Matrix Template

```markdown
| Claim | Primary source(s) | Supporting/conflict source(s) | Verification | Confidence | Caveat |
|---|---|---|---|---|---|
|  |  |  | date/version checked, cross-checked, local test, etc. | high/medium/low |  |
```

### 사용 기준

- non-obvious claim은 최소 1개 primary source가 있어야 한다.
- 비교/추천 claim은 criteria별 source가 보여야 한다.
- 최신성 claim은 absolute date와 source freshness가 있어야 한다.
- high-stakes claim은 1차 출처가 없으면 confidence를 낮추고 범위를 제한한다.

---

## 4. Query Log Template

```markdown
| # | Query / command | Channel | Why this query | Result | Follow-up |
|---:|---|---|---|---|---|
```

중복 방지 기준:

- 동일 문장 또는 의미상 같은 query를 반복하지 않는다.
- 추가 query는 관점을 바꾼다: official, changelog, security, benchmark, counter-evidence, region, date.
- 이미 확보한 source floor를 채웠다면 검색을 멈추고 검증으로 이동한다.

---

## 5. Rejected / Conflict Table

```markdown
| Source | Reason | Better source / resolution |
|---|---|---|
```

기록해야 하는 제외 사유:

- 공식 문서보다 오래된 vendor blog
- 검색 snippet만 있고 원문 접근 불가
- 적용 버전이 다름
- 방법론이나 sample이 불명확함
- 홍보성/편향 가능성이 높음
- 다른 S/A 출처와 충돌함

---

## 6. Minimum Floors

| Research mode | Reviewed | Cited | Matrix |
|---|---:|---:|---|
| quick | 3+ | 2+ | 핵심 claim만 |
| default | 6+ | 4+ | 필수 |
| deep/parallel | 10+ | 6+ | 필수 + conflict/rejected table |
| official-doc update | 4+ S급 우선 | 3+ S급 우선 | 필수 |

사용자가 별도 floor를 지정하면 사용자 지정값이 우선한다.
