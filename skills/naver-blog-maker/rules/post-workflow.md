# Post Workflow

> Korean version: [`post-workflow.ko.md`](post-workflow.ko.md)

**Purpose**: The ordered procedure for one Naver blog post, from brief to a draft the user pastes into SmartEditor ONE. Ranking rules live in [`naver-ranking-contract.md`](naver-ranking-contract.md); hook patterns in [`../references/hook-library.md`](../references/hook-library.md); prose rules are in [`human-prose.md`](../rules/human-prose.md).

## 0. Mode decision (state it in one clause)

| Mode | Trigger | Inputs required | Output shape |
|---|---|---|---|
| **정보/경험형** | No brand, product, or service to promote; the user wants a post that ranks and reads as a person's experience or a researched explainer | a keyword or topic at minimum; the author's experience/facts and images when they have them | title candidates + post (with inline image slots) + tags |
| **전환형** | A brand, business, or offer is named and the user wants inquiries, visits, or purchases | 브랜드명, 주제, 가치입증 내용 (verbatim facts), 참고내용 (may be empty); the commercial relationship (own business / sponsored / affiliate) | same as above + one CTA + disclosure line |

전환형 inherits every rule of 정보/경험형 and adds: disclosure in the opening (R6), brand facts verbatim, a single end-of-post CTA. It never gets a looser evidence bar because it sells.

If the brief mixes both (a personal review that ends with a shop link), it is 전환형.

The mode is **derived, not asked**. A commercial relationship recorded at intake (own business / sponsored / affiliate) together with a goal of 문의·예약·구매·재방문 makes it 전환형; every other brief is 정보/경험형. State the derived mode in one clause either way.

## 1. Intake — the fact pack

First complete [`intake.md`](intake.md) and await the reply. Then research from the keyword without demanding a fact pack.

- **Given a keyword/topic only, or brand + topic + 가치입증 with no experience** (the seed prompt shape): run [`topic-research.md`](topic-research.md) in full. It returns the fact pack below with sourced facts, `[확인 필요]` slots where only the author's own experience can go, and inline image slots. Intake already settled the mode and format.
- **Given experience, facts, or images**: record them verbatim into the pack, then run the gap check and image-slot steps of `topic-research.md` (§4-§5). When a decision field still needs a number, run only that field's lanes in `topic-research.md` §3 — supplied material never cancels an unresolved quantitative field.
- **Given an existing post** (the user pastes a Naver draft and asks that it read human): keep the supplied text as the base, record its register and its anchors, run the repair path in [`repair-method.md`](repair-method.md), and keep this format contract. Do not restructure the post unless the user asks; a `[확인 필요]` slot is added only where the supplied text leaves a hole that the post cannot stand without.

Fact pack fields (from `topic-research.md` §6): target query and reader job; blog topic lane (or `[확인 필요]`); top-3 gap (covered / missing / stale); facts with `출처 URL | 날짜 | source_grade | source_role | claim_scope | 섹션`; the decision fields (criterion, options, interval, one-time amount or limit, duration, cost range, the condition that flips the advice); `author` slots; `source-required` slots; image slots per section; 전환형 brand facts verbatim + relationship; register (`-했어요` for 경험형, `-습니다` for 전문/서비스형 when unknown).

Hard boundary: research supplies the informational spine; it never supplies a visit, a purchase, a result, or a downside the author did not report. Those are slots. For a regulated topic (의료·금융·법률·부동산), a quantitative claim needs a `quantitative_authority` source; medical work adds the rules in [`../references/regulated-topic-research.md`](../references/regulated-topic-research.md), and a medical post with no primary source for its required numbers stops here with a list of the sources to find.

## 2. Keyword and intent check

Goal: pick one query the post can win and one intent slice it will answer.

1. Expand the seed into candidates: modifiers for place, audience, model, problem, price, season. Autocomplete and 연관 terms are visible only on the live search page — collect them with browser tooling when available or ask the user to paste them.
2. Measure supply and demand separately with public tools (procedure and tool list in `../references/keyword-research.md` §3-§4):
   - Supply: the blog-document count shown for the exact phrase on the Naver blog search result page or a public keyword tool (lifetime documents; not monthly issuance).
   - Demand shape: 네이버 데이터랩 검색어트렌드 comparing candidates (relative 0-100 index; not volume).
   - Absolute monthly volume needs 네이버 검색광고 키워드도구 (login) or a third-party tool; do not invent it.
3. Inspect the live SERP for the chosen query (user screenshot or browser tool): which 스마트블록 headings appear (인기글, 후기, 비교, 가격…), whether Shopping/Place/ads crowd out blog results, what the top 3 posts promise. Write to the slice where blog posts actually appear.
4. Classify the three axes and pick the post type: (i) the customer intent (알아보기 / 비교하기 / 믿을 만한지 확인하기 / 구매하기), (ii) the post format, (iii) the business goal. Choose one **primary type** from [`../references/post-type-library.md`](../references/post-type-library.md) §2 and at most one secondary type. The type shapes the section order only — it never replaces the single search-intent slice from step 3 (R1), and the post still answers that one slice.
5. Record the decision in one line: `검색어 / 의도 슬라이스 / 주 유형 / 보조 유형 / 목표 / 근거 (문서수·트렌드·SERP)`. When the user named a type themselves, record that instead of inventing a reason. Numeric bands such as "200-1,000 monthly searches" or "docs/searches ≤ 1" are single-source heuristics — usable for triage, never stated as rules. Use only the library's type names; there is no `상담 전환형`.

## 3. Structure contract

Both modes use the same skeleton; 전환형 adds the bracketed parts.

```
제목 (20-35자, 검색어 앞쪽, 구체적 보상)
[이미지: 커버 — 무엇을 찍을지 | 캡션]
[공개 문장 — 협찬/자사/제휴일 때, 첫 문단 안]
첫 화면: 구체적 공감 1문장 → 답/결론 → 근거(경험·출처) → 이 글이 다루는 범위
소제목 1..N (독자의 다음 질문 순서; 보통 3-6)
  각 섹션 = 주장 → 확인 가능한 상황/수치/출처 (또는 [확인 필요: …] 슬롯) → [이미지: … | …] 또는 표/목록
  최소 1개 섹션 = 아쉬운 점 / 안 맞는 경우 / 실패한 부분 (없으면 슬롯)
해결 계층 (의도가 방법·선택·비교·주기·용량·기간·비용을 물을 때 필수)
  판단 기준 → 출처 있는 선택지 → 선택지마다의 운영 수치 → 조언이 뒤집히는 조건 → 다음 단계 1개
  수치는 출처와 함께. role이 quantitative_authority가 아니면 [확인 필요: 수치 종류 — 찾아야 할 출처] 슬롯
[브랜드 가치입증 — 사용자 입력 그대로, 관련 섹션 안]
마무리: 이제 내릴 수 있는 결정 → 달라지는 조건 → 다음 단계 1개
[CTA 1개 — 독자의 다음 행동으로 표현]
해시태그 3-7개 (정확한 주제·개체)
```

Follow [`image-slots.md`](image-slots.md): real-material `[이미지: 대상 | 캡션]` and illustration `[이미지 생성: 대상 | 캡션 | 프롬프트 #n]` markers go inside the body; generation JSON goes outside. Every generation marker names the section role and template it needs, chosen from [`../references/image-prompt-templates.md`](../references/image-prompt-templates.md) §2, so the outline and the delivered JSON agree on the role before drafting starts. Alternate short paragraphs with comparisons, processes, and diagrams; never replace proof photos with illustrations.

Experience slots live inside the body too, as `[확인 필요: …]` with a concrete example of what to write. They are never filled by the skill.

### The decision layer

When the intent or the title asks what to do, what to choose, how often, how much, how long, or how much it costs, the post carries a decision layer. It is **not** optional in that case, and it may be its own subheading or folded into the close — but the layer itself must exist.

The layer contains, in this order:

- **A criterion** — at least one sourced condition, state, or applicable range the reader can check.
- **Options** — every option the fact pack has a source for. When only one is sourced, use that one; never invent a second option to look balanced.
- **The operating numbers** for each option — interval, one-time amount or limit, duration, cost range, whichever the topic turns on.
- **The condition that flips the advice** — at least one, and in a regulated topic it is bound to a source the same way the criterion is.
- **Exactly one next step.**

Rules that keep it honest:

- Numbers carry their source. When the verified, distinct numbers are two or more, use at least two of them. When only one is verified, use that one and name the unresolved field in the publish note. **Never invent a number, and never lengthen a sentence to reach a count.**
- In a regulated topic, the criterion and the flip condition need a `recommendation_basis` with its scope or a first-party source that directly supports that claim. Otherwise that sentence is a `source-required` slot, not prose.
- These are this skill's own completeness rules. They are not Naver ranking rules, and they are never presented to the user as ones.

| Type | Where the numbers attach |
|---|---|
| 문제 해결형 | The solution steps, as the interval, amount, or duration each step uses. |
| 비교·선택 기준형 | The comparison table, one column per sourced option. |
| FAQ·반론 해소형 | The first sentence of the answer, as the condition and its exception. |
| 고객 성공 사례형 | The measurable result, with its baseline and timeframe. |

For the other eight types, follow the type's playbook in [`../references/post-type-library.md`](../references/post-type-library.md) §3.

### Common formula

The type's skeleton sits inside one higher contract: **one customer situation → the answer early → real evidence → conditions and limits → the next action.** Mapped onto the skeleton above: 원문 1 is the first screen's empathy sentence, 원문 2 is the first screen's answer, 원문 3 is the evidence sections, 원문 4 is the downside section and the flip condition, 원문 5 is the close.

When a medical topic needs a booking, discount, or purchase CTA but the legal boundary is not yet confirmed, do not confirm that CTA. Leave `[법적 범위 확인 필요: <item>]` and mark the draft blocked for publishing, per [`../references/regulated-topic-research.md`](../references/regulated-topic-research.md) §8. A neutral next step is allowed and is the default.

Sizing defaults (observed, non-blocking): body 1,500-3,000 characters; stop when the intent is answered. Never pad to a number.

The seed prompt's 7 steps map onto this: 공감대 → first sentence; 소개글 → first screen; 문제점/WHY → first subheading; 반박자료 → evidence inside sections; 주제 정보 → remaining sections; 후킹 → title + first screen only, never a vocabulary sprinkle; 브랜드 가치입증 → verbatim block + CTA.

## 4. Draft — under the embedded prose rules

Draft the prose under [`human-prose.md`](../rules/human-prose.md) with this skill's format contract as the outer constraint. Practically:

- Genre row from `human-prose.md` §4: 경험·후기·일상, 정보·비교·가이드, or 전문·서비스; one register for the whole post.
- Apply W-01 to W-26 at generation time; the Naver-specific S1 additions are: `첫째/둘째/셋째` scaffolding, `결론적으로`, `도움이 되셨다면 공감과 댓글`, `지금 바로`, invented percentages, emoji as section markers, every paragraph the same length.
- Ornament budget: the per-post ceilings of the chosen row in [`human-prose.md`](human-prose.md) §4, applied in the Naver editor (never markdown `**`).
- Keep every fact, number, price, date, and brand line exactly as supplied or sourced. If a section needs a fact the pack lacks, leave `[확인 필요: …]` in place; do not fill it.
- Write the image markers as part of the prose flow: a marker follows the sentence whose claim it proves, and the next sentence may refer to it (`위 사진의 온도 차이처럼…`).
- Deepening pass: during the step-5 self-check, walk [`../references/tell-catalog.md`](../references/tell-catalog.md) family by family against the draft. It carries the individual patterns behind the family table in `human-prose.md` §3, each with a bad-to-good pair and the W-ID that removes it.

## 5. Self-check, then deliver

Run the self-check protocol in `human-prose.md` §5, then [`validation.md`](validation.md). Fix hard-rule failures before delivery; at most two revision rounds, then report what remains.

Deliver in this order:

1. **3 title candidates** (decision / question / warning or comparison), recommended one marked.
2. **Chosen-format body**: plain is one text fence with title/body/hashtags; rich is body HTML with separate title/category/tags, following [`../references/format-options.md`](../references/format-options.md). Source copying is not styled copying. Preserve markers and [확인 필요] in both formats.
3. **Generation JSON**: one numbered object per generation marker, carrying the role's fields and its paste-ready `prompt`; omit when none. The prose prompt lives inside each object, so this workflow adds no separate prose-prompt section.
4. **Keyword decision** in one line.
5. **Slots to fill** — the list of `[확인 필요]` markers in order, each with what to write.
6. **Publish note** (2-4 lines): mode; editor 주제 to select; disclosure check; link check; a length note only when the body is outside the 1,500-3,000 default; the source URLs used for research (for the author's reference, not for the body).

Nothing else: no rule IDs, no tier labels, no rubric dump, no mention of the tells avoided. The mode statement and every note live outside the text block; the block is what gets pasted. A repair run (a supplied draft) delivers the same items and adds one to three lines naming what changed, also outside the block.

## 6. Forbidden

- Producing more than one post per request, batch variants, or anything meant for automated publishing (R7).
- Inventing experiences, statistics, quotes, credentials, prices, or filling a `[확인 필요]` slot with plausible text.
- Putting a key number, price, condition, or step only inside an image; the fact must exist as body text too.
- Confirming a booking, discount, or purchase CTA while the topic's legal boundary is unconfirmed.
- Demanding a fact pack after intake or blocking on optional omissions.
- Stating observed defaults or folklore as Naver rules.
- Pasting the seed prompt's hook vocabulary; only the adapted forms in the hook library.
- Targeting dwell time, comments, likes, or neighbors as goals.
- Logging into Naver, calling Naver API endpoints, or scraping.
