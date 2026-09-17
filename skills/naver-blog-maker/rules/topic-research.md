# Topic Research (keyword-only entry)

> Korean version: [`topic-research.ko.md`](topic-research.ko.md)

**Purpose**: When the user gives only a keyword, topic, or a brand plus a topic — no experience, no sources, no images — this rule builds the fact pack the draft needs. It is the research-first branch that [`post-workflow.md`](post-workflow.md) §1 runs by default; it is one bounded research pass and it never manufactures first-hand experience: what research cannot verify becomes a `[확인 필요]` slot the author fills, not a sentence the skill invents.

## 0. When this runs

| Input the user gave | Path |
|---|---|
| Keyword or topic only (`"누수 탐지 비용으로 글 써줘"`) | Run §1-§5 in full |
| Brand + topic + 가치입증, no experience (the seed prompt shape) | Run §1-§5; brand facts stay verbatim; research supplies the informational spine |
| Experience or sources already supplied | Skip to §4 (gap check) and §5; do not re-research what the user gave |

Budget: one research pass, at most the searches listed below. Research is not the deliverable; a post is. Stop when each outline section has one sourced fact or a marked slot.

## 1. Query and reader job (5 minutes)

1. Expand the keyword per [`../references/keyword-research.md`](../references/keyword-research.md) §2 into 3-6 candidates.
2. Read the live SERP for the top candidate when browser tooling exists; otherwise web-search `"<candidate>" site:blog.naver.com` and read the top results.
3. Write the one-line decision: `검색어 / 의도 슬라이스 / 근거`.

## 2. What the top posts already say (gap analysis)

Read the three highest-ranked blog posts for the chosen query (titles, first screen, section headings, whether they name a price basis, a downside, a date). Record:

- **Covered**: claims all three make — the post must at least match these.
- **Missing**: what none of them gives (a failure case, a condition under which the advice flips, a price breakdown, a dated source, a step-by-step with a photo). The missing item is the post's angle and its title promise.
- **Stale**: any fact older than the topic's freshness window (prices, policies, models) — the post updates it with a dated source.

Copy nothing. Record the URLs in the fact pack for the publish note, not for the body.

## 3. Facts with sources

Collect only what the outline needs, in this order of trust:

1. Primary: the maker, operator, government, or standards body (제조사 스펙, 고시, 관공서 안내, 공식 요금표).
2. Dated secondary: news or trade coverage with a date.
3. Practitioner: blog or cafe posts — usable for "what people ask" and for the gap analysis, never as a fact source for prices, safety, or law.

Each fact is stored as `사실 | 출처 URL | 날짜 | 어디에 쓸지`. Regulated fields (의료, 금융, 법률, 부동산) require a primary source for every quantitative claim; without one, the sentence becomes a `[확인 필요]` slot.

Search budget: 6-10 queries, English or Korean as the topic demands, varying `site:`, `filetype:pdf`, and date operators.

## 4. The experience gap — never fabricated

Research can supply the informational spine. It cannot supply the author's own visit, use, purchase, or result. So:

- Every place the skeleton calls for first-hand evidence (§3 of the workflow: "확인 가능한 상황/수치") gets a **slot**, not a sentence:
  `[확인 필요: 직접 확인한 날짜·장소·비용·결과를 한 문장으로 — 예: "2026년 8월 마포구 12층, 탐지 2시간, 25만원"]`
- The downside section gets a slot too: `[확인 필요: 실제로 안 됐던 경우 하나]`.
- In 전환형 the brand's own cases are the author's experience: if the brief contains one real case use it; if not, do not ask — the case section becomes a slot and the CTA still runs on the 가치입증 lines.
- A post whose slots outnumber its sourced facts is not ready to publish; say so in the publish note and list the slots first.

## 5. Image slots

Research also decides what each image must **prove**. For every section write an inline marker at the exact position in the body:

`[이미지: 무엇을 찍을지 | 캡션]`

Rules:

- One cover marker after the title (the subject in its real context, not a stock composition).
- One marker per claim a photo can prove: the product in use, the receipt or 견적서 with the price basis, the before/after, the reading on the instrument, the map or entrance for a place.
- A marker names what the author must shoot or already has; it never proposes a stock image, a screenshot of someone else's post, or a reused set (R5).
- Captions state the fact the picture backs (`오후 2시 방문 시 대기 4팀`), not a label (`매장 사진`).
- Typical count for a 1,500-3,000 character post: 5-12 markers; a how-to has one per step.

## 6. Fact pack shape (handed to the workflow)

```
검색어 / 슬라이스 / 근거: …
독자 과제: …
주제 레인: (사용자 블로그 최근 글 주제; 모르면 [확인 필요])
상위 3편 갭: 공통 / 빠진 것 / 오래된 것
사실 (출처 포함): 
  - … | URL | 날짜 | 섹션
경험 슬롯: [확인 필요: …] × N
이미지 슬롯: 섹션별 마커 목록
브랜드 (전환형): 가치입증 원문 / 관계
어미: -했어요 | -습니다
```

The workflow's §3 skeleton is filled from this pack. If the pack has zero primary or dated sources for a regulated topic, stop and tell the user which sources are required before a draft can be responsible.
