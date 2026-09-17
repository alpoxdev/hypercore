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

## 1. Intake — the fact pack

The minimum input is a keyword or topic. Do not interrogate the user; take what the brief contains, then let research fill the rest.

- **Given a keyword/topic only, or brand + topic + 가치입증 with no experience** (the seed prompt shape): run [`topic-research.md`](topic-research.md) in full. It returns the fact pack below with sourced facts, `[확인 필요]` slots where only the author's own experience can go, and inline image slots. Ask the user at most one question, and only if its answer changes the mode or the topic lane.
- **Given experience, facts, or images**: record them verbatim into the pack and run only the gap check and image-slot steps of `topic-research.md` (§4-§5).

Fact pack fields (from `topic-research.md` §6): target query and reader job; blog topic lane (or `[확인 필요]`); top-3 gap (covered / missing / stale); facts with `출처 URL | 날짜 | 섹션`; experience slots; image slots per section; 전환형 brand facts verbatim + relationship; register (`-했어요` for 경험형, `-습니다` for 전문/서비스형 when unknown).

Hard boundary: research supplies the informational spine; it never supplies a visit, a purchase, a result, or a downside the author did not report. Those are slots. A regulated topic (의료·금융·법률·부동산) with no primary or dated source in the pack stops here with a list of the sources needed.

## 2. Keyword and intent check

Goal: pick one query the post can win and one intent slice it will answer.

1. Expand the seed into candidates: modifiers for place, audience, model, problem, price, season. Autocomplete and 연관 terms are visible only on the live search page — collect them with browser tooling when available or ask the user to paste them.
2. Measure supply and demand separately with public tools (procedure and tool list in `../references/keyword-research.md` §3-§4):
   - Supply: the blog-document count shown for the exact phrase on the Naver blog search result page or a public keyword tool (lifetime documents; not monthly issuance).
   - Demand shape: 네이버 데이터랩 검색어트렌드 comparing candidates (relative 0-100 index; not volume).
   - Absolute monthly volume needs 네이버 검색광고 키워드도구 (login) or a third-party tool; do not invent it.
3. Inspect the live SERP for the chosen query (user screenshot or browser tool): which 스마트블록 headings appear (인기글, 후기, 비교, 가격…), whether Shopping/Place/ads crowd out blog results, what the top 3 posts promise. Write to the slice where blog posts actually appear.
4. Record the decision in one line: `검색어 / 의도 슬라이스 / 근거 (문서수·트렌드·SERP)`. Numeric bands such as "200-1,000 monthly searches" or "docs/searches ≤ 1" are single-source heuristics — usable for triage, never stated as rules.

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
[브랜드 가치입증 — 사용자 입력 그대로, 관련 섹션 안]
마무리: 이제 내릴 수 있는 결정 → 달라지는 조건 → 다음 단계 1개
[CTA 1개 — 독자의 다음 행동으로 표현]
해시태그 3-7개 (정확한 주제·개체)
```

Image slots live **inside the body** at the position where the picture must appear, in the form `[이미지: 무엇을 찍을지 | 캡션]` (rules in `topic-research.md` §5). The user replaces each marker with the photo in SmartEditor; the caption text stays. No separate image plan is delivered.

Experience slots live inside the body too, as `[확인 필요: …]` with a concrete example of what to write. They are never filled by the skill.

Sizing defaults (observed, non-blocking): body 1,500-3,000 characters; stop when the intent is answered. Never pad to a number.

The seed prompt's 7 steps map onto this: 공감대 → first sentence; 소개글 → first screen; 문제점/WHY → first subheading; 반박자료 → evidence inside sections; 주제 정보 → remaining sections; 후킹 → title + first screen only, never a vocabulary sprinkle; 브랜드 가치입증 → verbatim block + CTA.

## 4. Draft — under the embedded prose rules

Draft the prose under [`human-prose.md`](../rules/human-prose.md) with this skill's format contract as the outer constraint. Practically:

- Genre row from `human-prose.md` §4: 경험·후기·일상, 정보·비교·가이드, or 전문·서비스; one register for the whole post.
- Apply W-01 to W-26 at generation time; the Naver-specific S1 additions are: `첫째/둘째/셋째` scaffolding, `결론적으로`, `도움이 되셨다면 공감과 댓글`, `지금 바로`, invented percentages, emoji as section markers, every paragraph the same length.
- Ornament budget: the per-post ceilings of the chosen row in [`human-prose.md`](human-prose.md) §4, applied in the Naver editor (never markdown `**`).
- Keep every fact, number, price, date, and brand line exactly as supplied or sourced. If a section needs a fact the pack lacks, leave `[확인 필요: …]` in place; do not fill it.
- Write the image markers as part of the prose flow: a marker follows the sentence whose claim it proves, and the next sentence may refer to it (`위 사진의 온도 차이처럼…`).

## 5. Self-check, then deliver

Run the self-check protocol in `human-prose.md` §5, then [`validation.md`](validation.md). Fix hard-rule failures before delivery; at most two revision rounds, then report what remains.

Deliver in this order:

1. **3 title candidates** (decision / question / warning or comparison), recommended one marked.
2. **The post as one copy-ready block**: the recommended title on the first line, then the full body with its inline `[이미지: …]` and `[확인 필요: …]` markers, then a blank line and the hashtags on the last line. Wrap the whole block in a fenced code block tagged `text` so the user copies it in one motion and nothing renders as markdown. Inside the block: plain text only — no `#`, no `**`, no bullet syntax; use blank lines between paragraphs and a bare line for each subheading.
3. **Keyword decision** in one line.
4. **Slots to fill** — the list of `[확인 필요]` markers in order, each with what to write.
5. **Publish note** (2-4 lines): mode; editor 주제 to select; disclosure check; link check; a length note only when the body is outside the 1,500-3,000 default; the source URLs used for research (for the author's reference, not for the body).

Nothing else: no rule IDs, no tier labels, no rubric dump, no mention of the tells avoided. The mode statement and every note live outside the text block; the block is what gets pasted.

## 6. Forbidden

- Producing more than one post per request, batch variants, or anything meant for automated publishing (R7).
- Inventing experiences, statistics, quotes, credentials, prices, or filling a `[확인 필요]` slot with plausible text.
- Interrogating the user for a fact pack when a keyword was given: research first, ask at most one mode- or lane-changing question.
- Stating observed defaults or folklore as Naver rules.
- Pasting the seed prompt's hook vocabulary; only the adapted forms in the hook library.
- Targeting dwell time, comments, likes, or neighbors as goals.
- Logging into Naver, calling Naver API endpoints, or scraping.
