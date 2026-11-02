# Source Ledger Reference

> 영어판: [`source-ledger.md`](source-ledger.md)

**목적**: 리서치 산출물의 출처 추적성을 `query → source → claim → caveat`로 남긴다.

---

## 1. Ledger 원칙

- 출처 목록은 bibliography가 아니라 **검증 로그**다.
- 검색 결과 snippet은 `lead`로 기록할 수 있지만, 최종 claim의 primary evidence가 될 수 없다.
- `reviewed`와 `cited`를 분리한다. reviewed source는 결론에 쓰지 않았더라도 왜 제외했는지 남긴다.
- 최신성은 `published/updated`, `accessed_at`, `retrieved_at`, `page_age`, `tool/API version`을 분리한다.
- 버전이 있는 표준은 `Source` 제목에 **에디션**을 넣는다. “OWASP Top 10”이 아니라 “OWASP Top 10 for LLM Applications 2026”으로 적는다. 에디션은 세부 정보가 아니라 식별자의 일부다.
- 가리킨 페이지가 아니라 실제로 연 자료를 기록한다. 같은 표준이라도 랜딩 페이지, PDF, 항목별 HTML 페이지가 서로 다른 에디션을 담을 수 있다.
- 자료를 읽은 뒤에 행을 쓴다. agent 요약, 검색 snippet, 다른 원장에서 복사한 행은 누군가 원문을 열기 전까지 미검증이다.

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
| `Version/freshness` | API mode, tool version, release tag, 표준 에디션, `page_age`, cache caveat |
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

---

## 7. 인용 사슬

어떤 논문, 표준, 릴리스 노트의 내용을 단정하는 페이지는 **그 페이지의 주장**에 대한 증거이지, 인용된 자료의 내용에 대한 증거가 아니다.

| 단계 | 기록 |
|---|---|
| 1 | 2차 페이지를 별도 행으로 적고 role을 `lead`로 둔다 |
| 2 | 인용된 자료를 별도 행으로 적고 role을 `primary-evidence`로 두며, 연 에디션이나 버전을 적는다 |
| 3 | 그 자료가 2차 페이지가 돌린 문장을 실제로 지지하는지 `confirmed`, `partly`, `misattributed` 중 하나로 적는다 |
| 4 | `misattributed` 결과는 rejected 표에 정정된 claim과 함께 적는다 |

명시적으로 확인할 사슬 실패 유형은 다음과 같다.

- 2차 출처가 **이전 에디션**의 표준을 인용하는데 그 표준이 이미 다시 발행됐다.
- 2차 출처가 예비 결과나 벤더가 보고한 수치를 최종값으로 적는다.
- 2차 출처가 “비적응형 테스트에서”, “내부 평가 세트에서” 같은 한정어를 빼서 claim의 강도가 달라진다.
- 인용한 URL이 지목한 문서와 다른 문서로 열린다. 예를 들어 최신 릴리스가 앞에 놓인 랜딩 페이지가 그 경우다.

---

## 8. 표준, 에디션, 합성 자료

| 자료 | 등급 | 원장 처리 |
|---|---|---|
| 에디션을 밝혀 인용하고 자료를 직접 연 표준/프레임워크 | S | `Source`에 에디션을 넣고, `Version/freshness`에 에디션과 개정 상태를 적는다 |
| 개정 중이라고 공지된 프레임워크 | 현재 본문에 S | 개정 공지를 별도의 날짜 있는 행으로 남겨 독자가 둘 다 보게 한다 |
| 벤더 개요나 마케팅 페이지 | B 또는 C | 동작 claim에는 기술 문서를 우선하고, 결론이 어느 행을 썼는지 적는다 |
| 모델이 쓴 요약, 생성된 비교표, 날짜 없는 집계 페이지 | C | `role: lead`로 두고, 직접 연 자료를 별도의 1차 행으로 적는다 |
| 검색 snippet, `page_age`만 있는 자료, cache 의심 | C | 원문을 열기 전까지 `role: lead` |

조용히 고치지 말고 caveat 열에 적어야 하는 함정은 두 가지다.

- 같은 프레임워크의 항목별 페이지와 발행 PDF가 서로 다른 에디션을 담고 있다.
- DOI나 단축 링크가 이전되므로, 행에는 랜딩 페이지가 적혔는데 claim은 PDF에서 가져왔다.

---

## 9. Agent가 모은 행

subagent, 브라우저 agent, tool이 출처를 모았을 때 원장은 상위 agent가 쓴다.

- 상위 agent가 자료를 열거나, agent가 정확한 URL, 에디션, 인용 구간을 돌려주기 전까지 그 행은 `unverified`다.
- 인용 구간은 행과 함께 옮긴다. “페이지에 X라고 되어 있다”는 나중에 재현되지 않는다.
- 이미 검증된 구간이 있는 행에 agent 요약을 합치지 않는다. 행을 하나 더 만들고 관계를 적는다.
- 자료를 다시 열 수 없으면 그 행을 `lead`로 두고 그렇다고 적는다. 이 사실을 숨긴 원장은 원장이 아니라 참고문헌 목록이 된다.

---

## 출처

| # | 출처 | 발행 | URL | 발행·갱신일 | 확인일 | 등급 |
|---:|---|---|---|---|---|---|
| 1 | Reliable Search Guide §5~§7(등급, 인용, 원장 스키마) | 이 저장소 | [`../reliable-search.ko.md`](../reliable-search.ko.md) | 저장소 HEAD | 확인 2026-11-03 | 내부 표준 |
| 2 | OWASP Top 10 for LLM Applications 2026(제목에 에디션 표기 관행) | OWASP GenAI Security Project | <https://genai.owasp.org/resource/owasp-genai-llm-top-10-2026/> | 2026-08-03 | 확인 2026-11-03 | S |
| 3 | LLM01: Prompt Injection 페이지가 2025 본문을 제공 중 | OWASP GenAI Security Project | <https://genai.owasp.org/llmrisk/llm01-prompt-injection/> | 본문 표기 LLM01:2025 | 확인 2026-11-03 | S |
| 4 | Generative AI Profile, NIST AI 600-1(발행일과 페이지 갱신일이 있는 랜딩 페이지) | NIST | <https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence> | 2024-07-26, 페이지 갱신 2026-04-08 | 확인 2026-11-03 | S |
| 5 | 웹 검색 tool의 인용 annotation(`url_citation`, consulted sources 목록) | OpenAI | <https://developers.openai.com/api/docs/guides/tools-web-search> | 표기 없음 | 확인 2026-11-03 | S |
| 6 | Citations, 구간 기반 citation block | Anthropic | <https://platform.claude.com/docs/en/build-with-claude/citations> | 표기 없음 | 확인 2026-11-03 | S |

§8의 에디션 사례는 직접 확인했다. 2026 OWASP LLM Top 10이 2026-08-03에 발행된 뒤에도 항목별 페이지는 2025 본문을 제공했고 2026 슬러그는 404를 돌려줬다(확인 2026-11-03).
