# Topic Research (keyword-only entry)

> Korean version: [`topic-research.ko.md`](topic-research.ko.md)

**Purpose**: When the user gives only a keyword, topic, or a brand plus a topic — no experience, no sources, no images — this rule builds the fact pack the draft needs. It is the research-first branch that [`post-workflow.md`](post-workflow.md) §1 runs by default; it is one bounded research pass and it never manufactures first-hand experience: what research cannot verify becomes a `[확인 필요]` slot the author fills, not a sentence the skill invents.

## 0. When this runs

Run after the intake reply.

| Input the user gave | Path |
|---|---|
| Keyword or topic only (`"누수 탐지 비용으로 글 써줘"`) | Run §1-§5 in full |
| Brand + topic + 가치입증, no experience (the seed prompt shape) | Run §1-§5; brand facts stay verbatim; research supplies the informational spine |
| Experience or sources already supplied | Record them, then run §4 (gap check) and §5; do not re-research what the user gave. **Exception:** when a decision field still needs a number, run only that field's lanes in §3. |

Budget: one research pass, up to the query caps in §3. Research is not the deliverable; a post is. Stop when every section has one sourced fact or a marked slot **and** each decision field the intent turns on — the criterion, the sourced options, the operating number, the condition that flips the advice, the next step — is settled as `확인됨`, `의도적 생략`, or `출처 부족으로 막힘`. When the query cap is spent and a regulated number still has no primary source, stop searching and record it as a research gap.

## 1. Query and reader job (5 minutes)

1. Expand the keyword per [`../references/keyword-research.md`](../references/keyword-research.md) §2 into 3-6 candidates.
2. Read the live SERP for the top candidate when browser tooling exists; otherwise web-search `"<candidate>" site:blog.naver.com` and read the top results.
3. Draft the research memo: the query, the intent slice, and the basis. The post's final one-line decision is the six-field line written in `post-workflow.md` §2 (`검색어 / 의도 슬라이스 / 주 유형 / 보조 유형 / 목표 / 근거`); this step only feeds it.

## 2. What the top posts already say (gap analysis)

Read the three highest-ranked blog posts for the chosen query (titles, first screen, section headings, whether they name a price basis, a downside, a date). Record:

- **Covered**: claims all three make — the post must at least match these.
- **Missing**: what none of them gives (a failure case, a condition under which the advice flips, a price breakdown, a dated source, a step-by-step with a photo). The missing item is the post's angle and its title promise.
- **Stale**: any fact older than the topic's freshness window (prices, policies, models) — the post updates it with a dated source.

Copy nothing. Record the URLs in the fact pack for the publish note, not for the body.

## 3. Facts with sources

Collect only what the outline needs, in this order of trust:

1. Primary: the maker, operator, government, standards body, or professional society (제조사 스펙, 허가사항, 고시, 관공서 안내, 공식 요금표, 학회 지침).
2. Dated secondary: news or trade coverage with a date.
3. Practitioner: blog or cafe posts — `lead_only`. Usable for "what people ask" and for the gap analysis, never as a fact source for prices, safety, or law.

**Grade and role are separate.** Grade is how trustworthy a source is; role is what it may support. A peer-reviewed review has a high grade and still may not be the sole basis for a number.

| Role | What it may support |
|---|---|
| `quantitative_authority` | The number itself: a dose, a maximum, an interval, a duration, an eligibility limit. |
| `recommendation_basis` | That an authority recommends a course, with its stated scope. |
| `supporting_context` | Why a value is uncertain or contested. Never the number alone. |
| `lead_only` | A search lead. Never a price, safety, or legal basis. |

`quantitative_authority` = a first-party source that **issues, regulates, or publishes that number** (a regulatory approval or 고시, a manufacturer's own label or price list, a statute, or a government notice), and only when the **same claim scope** — product, population, period, condition — is stated with it. Any other source is `supporting_context` or `lead_only` however high its grade. Medical work inherits this definition and narrows it in [`../references/regulated-topic-research.md`](../references/regulated-topic-research.md) §2.

Each fact is stored as `사실 | 출처 URL | 날짜 | source_grade | source_role | claim_scope | 어디에 쓸지`. Regulated fields (의료, 금융, 법률, 부동산) require a `quantitative_authority` source for every quantitative claim. Run that field's query lanes before falling back — the medical lanes are in `regulated-topic-research.md` §3 — and when no source is found the sentence becomes `[확인 필요: <what the number is> — <which source to find>]`. A missing number does not empty its section: keep the sourced criteria, the process, and the conditions around the slot.

Search budget: 6-10 queries, English or Korean as the topic demands, varying `site:`, `filetype:pdf`, and date operators. A regulated or quantitative topic that still has an open decision field after that pass gets up to 4 additional targeted queries through the lanes above — 14 total, hard cap.

## 4. The experience gap — never fabricated

Research can supply the informational spine. It cannot supply the author's own visit, use, purchase, or result. So:

Slots come in two kinds. An `author slot` holds what only the author can supply — their own experience, the amount they actually paid, a real case — and does not block publishing. A `source-required slot` holds an approved dose, a medical interval, or an eligibility limit; only a governing first-party source fills it, and it **blocks publishing**. The author's recollection never answers a `source-required slot`.

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
- Follow [`image-slots.md`](image-slots.md) for density and generated illustrations; deliver matching JSON and never substitute for proof photos.
- Before choosing anything, classify each slot: **real material** (a photo the author can shoot or already has) or **generated explanation** (a diagram, chart, comparison, or concept visual). The classification fixes the marker kind, and a real location, entrance, receipt, 견적서, instrument reading, result, certificate, or before/after photo is NEVER routed to a generated template.
- For every generated slot, record its section role and template ID in the fact pack, taken from [`../references/image-prompt-templates.md`](../references/image-prompt-templates.md) §2: the role from the section's job in the skeleton, the template from that role's row. The compile order and the field rules live in [`image-slots.md`](image-slots.md) §6.

## 6. Fact pack shape (handed to the workflow)

```
검색어 / 의도 슬라이스 / 주 유형 / 보조 유형 / 목표 / 근거: …
독자 과제: …
주제 레인: (사용자 블로그 최근 글 주제; 모르면 [확인 필요])
상위 3편 갭: 공통 / 빠진 것 / 오래된 것
사실 (출처 포함): 
  - … | URL | 날짜 | source_grade | source_role | claim_scope | 섹션
결정 필드: 판단 기준 | 선택지(출처 있음/없음) | 주기 | 1회량·한도 | 지속 기간 | 비용 범위 | 뒤집히는 조건
경험 슬롯(author): [확인 필요: …] × N
출처 필요 슬롯(source-required): [확인 필요: … — 찾을 출처] × N
이미지 슬롯: 섹션별 마커 목록 (real evidence | generated + section_role/template)
브랜드 (전환형): 가치입증 원문 / 관계
어미: -했어요 | -습니다
```

The workflow's §3 skeleton is filled from this pack. If the pack has zero primary or dated sources for a regulated topic, stop and tell the user which sources are required before a draft can be responsible.

## Sources

> No external sources; content checked 2026-09-21.

This file states this package's own research procedure and source-role taxonomy. The live-SERP observation it describes is recorded in [`../references/evidence-digest.md`](../references/evidence-digest.md); it cites no external URL of its own.
