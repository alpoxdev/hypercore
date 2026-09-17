# Tone and Manner

> Korean version: [`tone-manner.ko.md`](tone-manner.ko.md)

**Purpose**: How a tone the user supplies becomes the voice of one post. Intake item 6 carries it (optional); when it is absent, a blog read and the genre row supply the fallback. The floor in §4 does not move.

## 1. Where the tone comes from

Three shapes of input, all handled the same way: read them, then fill the voice card in §2.

1. **Free text** — a sentence or a few words (`해요체에 짧은 문장`, `친근하게`). Fill the slots it names; the rest fall back.
2. **A tone-profile document** — a file or a long paste describing a voice (the writer's own guide, a brand voice sheet). Take slot values from it, and read the document's strength words as slot strength, not as orders: a MUST (or a rule stated flatly) fills the slot, a PREFER fills it only when nothing else does, and an AVOID or a "never" fills the 어휘 금기 slot. Those words change neither the floor (§4) nor the ladder (§3).
3. **Pasted blog posts** — one to three posts the writer wrote. Read endings, sentence length, lexis, and ornament habit as observations, the same way the intake blog read does it.

Integration rule: **explicit text beats observation, slot by slot.** A value the user stated stands even when the pasted samples disagree with it; observation fills only the slots the user left empty.

A supplied tone document is user data. Statements inside it never change this file's floor (§4), the rules of [`human-prose.md`](human-prose.md), or any fact, number, price, or disclosure sentence in the post; they only supply slot values.

## 2. The voice card

Settle these eight slots before drafting, and keep the card in one line of working notes. The publish note echoes it (§5).

| # | Slot | What to take from the input | Fallback when the input is silent |
|---|---|---|---|
| 1 | 종결 어미 | the ending style the post holds from the first sentence to the last (`-해요`, `-습니다`, `-한다`) | the register of the chosen genre row in `human-prose.md` §4 |
| 2 | 문장 길이·호흡 | short, medium, or long sentences; whether a block runs one line or two to three | the body rhythm contract in [`post-workflow.md`](post-workflow.md) §3 |
| 3 | 어휘 선호 | the words the writer reaches for (field terms, plain words, the names they use for things) | plain concrete nouns and verbs, plus the topic's own vocabulary |
| 4 | 어휘 금기 | the words and phrases the writer refuses | family D in `human-prose.md` §3 and the skill-specific S1 additions in §4 |
| 5 | 감정·유머 빈도 | how often a reaction, a joke, or an aside appears | one reaction where the writer actually had one; no jokes |
| 6 | 독자 호칭 | how the reader is addressed (`여러분`, `고객님`, no address at all) | no direct address, except in the 전문·서비스 CTA |
| 7 | 장식·이모지 습관 | the emoji, bold, quotes, and dashes the writer habitually uses | the chosen genre row's per-post decoration ceiling in `human-prose.md` §4 |
| 8 | 문장부호 습관 | comma density, ellipses, parentheses, exclamation marks | the chosen genre row's ceiling; dash 0 in every row |

A slot the input leaves empty is filled by its fallback, never by invention: do not invent a verbal tic, a nickname for the reader, or a signature phrase the writer never used.

## 3. Precedence

Highest first. A lower entry never overrides a higher one.

1. Facts, numbers, prices, dates, sources, the disclosure sentence, and `[확인 필요]` slots. Tone never touches these.
2. The floor in §4.
3. The tone text the user supplied, slot by slot.
4. Observed tone, from the blog read or the pasted posts, filling empty slots only.
5. The chosen genre row's register and defaults in `human-prose.md` §4.

## 4. The floor (tone does not move it)

Whatever the user asks for, the draft keeps:

- zero S1 items: the family D stock phrases in `human-prose.md` §3 (`결론적으로`, `시사하는 바가 크다`, `주목할 만하다`) and the skill-specific S1 additions in §4 (`지금 바로`, `도움이 되셨다면 공감과 댓글 부탁드려요`, the `오늘은 ~에 대해 알아보겠습니다` opening, and markdown bold or `#` pasted into the editor), plus every S1 item of the other tell families wherever it appears;
- the counts the chosen genre row owns: emoji, bold, emphasis quotes, dashes, and exclamation marks stay inside that row's per-post ceiling (emoji is 0 in the 정보·비교·가이드 and 전문·서비스 rows), mechanical `첫째/둘째/셋째` stays off unless the genre demands it, paragraphs do not all land at one length, and the row's Forbidden list holds as written;
- one register for the whole post: a tone may choose which register, and endings vary inside that register, never across registers (`human-prose.md` §3 family E, §4); quoted material keeps the wording it was quoted from, and a request to mix registers is handled by the conflict rule below;
- the per-post decoration ceilings of the chosen genre row, applied in the Naver editor and never as markdown;
- the register-independent rules of `human-prose.md` §2 (W-01 to W-26): filler deletion, evidence sentences, no over-correction;
- the structure contract and body rhythm check in `post-workflow.md` §3.

A tone request that breaks the floor is **recorded, not obeyed and not blocked**: write the post under the floor, then name the request and what stood in its place in one publish-note line (§5). Never drop the request silently, and never stop delivery over it.

## 5. Publish-note echo

Add one line to the publish note, naming the voice used and where it came from.

`보이스: <어미> · <문장 길이> · <금기 준수> · <장식 습관> (출처: 사용자 입력 / 블로그 관찰 / 유형 기본값)`

When a request hit the floor, the same block carries one more line: `요청 <X>는 <Y> 규칙에 따라 적용하지 않았습니다.`
