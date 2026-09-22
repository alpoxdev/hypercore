# Naver Post Tell Catalog

> Korean version: [`tell-catalog.ko.md`](tell-catalog.ko.md)

**Purpose**: the deep layer behind the family table in [`human-prose.md`](../rules/human-prose.md) §3. That table says which families matter and how severe each one is; this file holds the individual patterns inside each family, each with a bad-to-good pair and the W-ID that removes it. Load it when a draft reads machine-written but no single sentence looks broken, when a repair needs a candidate pool to diagnose against, or when the user asks why a construction was avoided.

Catalog IDs (`T-` + family letter + index) name patterns; the `W-` IDs in `human-prose.md` §2 are the prescriptions you actually apply. Where the two seem to disagree, the W-ID wins. Naver-specific S1 additions live in `human-prose.md` §4; family K below is their worked-pair layer, not a second list.

## Contents

- A Translationese syntax (번역투)
- B Loanword and vocabulary habits (어휘 습관)
- C Structural AI patterns (구조적 AI 패턴)
- D Stock phrases (AI 특유 관용구)
- E Rhythm uniformity (리듬 균일성)
- F Modification and redundancy (수식·중복)
- G Hedging (헤지 남용)
- H Connective overload (접속사 남발)
- I Empty formal nouns (형식명사 과다)
- J Visual decoration (시각 장식)
- K Naver-post tells (이 스킬 고유 S1)
- Using this catalog
- Sources

## A Translationese syntax (번역투)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-A1 | `~를 통해` as an all-purpose instrument | 인터뷰를 통해 원인을 파악했다. → 인터뷰로 원인을 파악했다. | Instrument as `~로`, or let a verb carry it | W-01 |
| T-A2 | `~에 있어서` as a topic frame | 협업에 있어서 신뢰가 중요하다. → 협업에서는 신뢰가 중요하다. | Set the topic with the particle, drop the frame | W-01 |
| T-A3 | Double passive `~되어진다`, `~보여진다` | 매출이 개선되어진다. → 매출이 개선된다. | One passive layer; active when an actor exists | W-02 |
| T-A4 | `가지고 있다` for plain possession | 세 가지 강점을 가지고 있다. → 강점은 셋이다. | Say what it is, not what it has | W-02 |
| T-A5 | Compulsive `그`/`그녀` | 담당자가 보고서를 냈다. 그는 회의도 열었다. → 담당자가 보고서를 내고 회의도 열었다. | Drop the subject or join the clauses | W-14, W-22 |
| T-A6 | Doubled particles `-에서의`, `-으로의` | 현장에서의 검증이 남았다. → 현장에서 검증하는 일이 남았다. | Unfold the particle stack into a verb | W-16 |
| T-A7 | `~에 대해` as a reflex object marker | 미래에 대해 분석한다. → 미래를 분석한다. | Mark the object directly | W-01 |
| T-A8 | `~와 관련하여` as formal surplus | 가격과 관련하여 안내드립니다. → 가격을 안내드립니다. | Name the relation with a noun or verb | W-25 |
| T-A9 | `~에 기반하여`/`~에 바탕으로` framing | 데이터에 기반하여 골랐다. → 데이터를 보고 골랐다. | Fold the basis into the case marker | W-25 |
| T-A10 | `~에 의해` as an English passive | 업체에 의해 교체되었습니다. → 업체가 교체했습니다. | Promote the actor to subject | W-25 |
| T-A11 | Repeated `~할 수 있다` | 시간을 아낄 수 있고 실수도 줄일 수 있다. → 시간이 줄고 실수도 덜하다. | Modal only for real possibility | W-26 |
| T-A12 | Repeated `~을 위해` purpose clauses | 비용 절감을 위해 도입했고 품질 확보를 위해 검증했다. → 비용을 아끼려고 도입했고 품질을 지키려고 검증했다. | Vary into `~려고`/`~고자` or fold into the verb | W-26 |
| T-A13 | Honorific passive (`합의가 이루어졌다`) | 합의가 이루어졌습니다. → 두 업체가 합의했습니다. | Name the actor, use the plain verb | W-02, W-25 |
| T-A14 | `했다. 그리고 했다.` sentence chaining | 도착했습니다. 그리고 짐을 풀었습니다. → 도착해서 짐을 풀었습니다. | Fold into `-고` or drop the link | W-05 |
| T-A15 | Abstract subject with an ornate object | 이 변화는 새로운 기회를 가져옵니다. → 이런 변화 속에서 새 기회가 열립니다. | Make the actor or event concrete | W-03 |
| T-A16 | Repeated progressive `~되고 있다` | 대기 시간이 늘어나고 있다. 비용도 오르고 있다. → 대기 시간이 늘고 비용도 오른다. | Plain present where nothing is ongoing | W-10, W-26 |

## B Loanword and vocabulary habits (어휘 습관)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-B1 | Parenthetical gloss on every term | 주차(scalability)와 접근성(accessibility)을 갖췄다. → 주차와 접근성을 갖췄다. | Gloss once, only where the Korean is genuinely ambiguous | W-12 |
| T-B2 | Untranslated English where Korean exists | 유저 익스피리언스가 임프루브됐습니다. → 사용자 경험이 좋아졌습니다. | Keep the loanword only where the field uses it | W-12 |
| T-B3 | Acronym with no first-use expansion | A/S 접수는 전화로만 받습니다. → 애프터서비스(A/S) 접수는 전화로만 받습니다. | Expand once, then use the short form | W-12 |
| T-B4 | Loanword plus Korean synonym in one sentence | 메뉴얼(설명서)을 보세요. → 설명서를 보세요. | Pick the reader's word and stay with it | W-12 |
| T-B5 | Redundant `-들` after a quantifier | 대기 손님들이 세 분들 계십니다. → 대기 손님이 세 분 계십니다. | Drop the suffix the context already marks | W-20 |
| T-B6 | `그것은`/`해당`/`본`/`당` where the antecedent is obvious | 이 매장은 재료를 직접 손질합니다. 그것은 품질 덕분입니다. → 이 매장은 재료를 직접 손질합니다. 품질 덕분입니다. | Omit or swap for `이/그` | W-21 |
| T-B7 | `진행하다`/`실시하다`/`수행하다` over a plain verb | 시식을 진행했습니다. → 시식을 열었습니다. | Keep the plain verb the register accepts | W-24 |

## C Structural AI patterns (구조적 AI 패턴)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-C1 | Mechanical `첫째/둘째/셋째` in prose | 첫째, 가깝습니다. 둘째, 쌉니다. → 가깝고 값도 쌉니다. | Enumerate only when the count matters | W-08 |
| T-C2 | Bullets where a paragraph belongs | 세 줄 불릿으로 쪼갠 후기. → 한 문단으로 이어 쓴 후기. | Paragraphs by default; §4 says where lists fit | W-11 |
| T-C3 | A subheading every few sentences | 네 문장마다 붙은 소제목. → 논지 한 덩어리에 소제목 하나. | Headings only where a reader jumps in | W-11 |
| T-C4 | Comma after every 연결어미 | 도착했고, 짐을 풀었고, 저녁을 먹었습니다. → 도착해서 짐을 풀고 저녁을 먹었습니다. | Punctuate for breath, not for every clause | W-11 |
| T-C5 | Recap block restating the post | 요약하면 위의 세 가지가 핵심입니다. → 마지막 문장이 결론을 직접 말하게 둔다. | Cut the recap unless the post is long | W-06 |
| T-C6 | List-introducing colon `다음과 같습니다:` | 준비물은 다음과 같습니다: → 준비물은 아래와 같습니다. | End the lead-in with a period | W-11, W-15 |

## D Stock phrases (AI 특유 관용구)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-D1 | `결론적으로` opening the close | 결론적으로 이 제품이 낫습니다. → 이 제품이 낫습니다. | Delete the label, lead with the claim | W-13 |
| T-D2 | `시사하는 바가 크다` | 이번 결과가 시사하는 바가 큽니다. → 이번 결과대로면 다음 방문 때는 오전에 가야 합니다. | Replace with the consequence | W-13 |
| T-D3 | `주목할 만하다` | 대기 시간 개선이 주목할 만합니다. → 대기 시간이 40분에서 10분으로 줄었습니다. | State the fact | W-13 |
| T-D4 | `혁신적인`/`획기적인`/`압도적인` | 혁신적인 시스템을 도입했습니다. → 예약과 결제를 한 화면에 합쳤습니다. | Name the change, let the reader rank it | W-13 |
| T-D5 | `~라고 할 수 있다` as a verdict | 효율적이라고 할 수 있습니다. → 더 효율적입니다. | Close with the plain predicate | W-13 |
| T-D6 | `지금이야말로`, `~할 때다`, `~라는 뜻이다`, `~인 셈이다` | 지금이야말로 점검할 때입니다. → 지금 점검하십시오. | Close with the plain assertion | W-13 |
| T-D7 | Theatrical hooks, causal shorthand | 이 선택이 질문을 던집니다. 비용 증가로 이어집니다. → 이 선택 앞에서 답할 문제가 달라집니다. 비용이 늘었습니다. | State the question or the cause | W-13, W-03 |

## E Rhythm uniformity (리듬 균일성)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-E1 | Near-identical sentence lengths | 갔습니다. 봤습니다. 먹었습니다. → 갔습니다. 사람이 많아서 한참 기다린 끝에 겨우 봤고, 밥은 서둘러 먹었습니다. | Let content set the length, then read the paragraph by eye | W-10 |
| T-E2 | Four or more identical `C/O/P` shapes | 가격을 확인합니다. 재고를 확인합니다. 배송을 확인합니다. → 가격을 확인하고 재고가 있으면 바로 주문합니다. → keep deliberate enumerations, vary unmotivated molds; the unit is defined in `human-prose.md` §5 step 3 | W-09 |
| T-E3 | Register drifting mid-post | 먼저 예약합니다. 그다음 결제한다. → 먼저 예약합니다. 그다음 결제합니다. | Settle the ending before the first sentence | W-09 |
| T-E4 | Every paragraph the same size | 세 문장짜리 단락이 여섯 번. → 무거운 대목은 길게, 전환은 한두 문장으로. | Size each paragraph to its work | W-10 |

## F Modification and redundancy (수식·중복)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-F1 | Stacked intensifiers `매우`/`정말` | 매우 정말 맛있습니다. → 국물이 진합니다. | Cut the intensifier, let the noun or number carry it | W-04 |
| T-F2 | Synonym pairs doing one job | 신속하고 빠른 안내. → 빠른 안내. | Keep one | W-04 |
| T-F3 | `~적`/`~성`/`~화` sprayed across nouns | 청결성의 향상이 가능합니다. → 더 깨끗하게 관리할 수 있습니다. | Unfold into a verb or adjective | W-04 |
| T-F4 | Modifier the noun already implies | 미리 사전 예약. → 사전 예약. | Delete the modifier | W-04 |
| T-F5 | Three or more stacked 관형절 | 지난달에 새로 들여온 개선된 자동화된 예약 시스템. → 지난달에 예약 시스템을 새로 들였고 자동으로 돌아갑니다. | Break the chain into a clause with its own verb | W-04 |

## G Hedging (헤지 남용)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-G1 | Stacked softeners on one claim | 좋을 수도 있다고 생각됩니다. → 좋습니다. | One hedge per claim at most | W-07 |
| T-G2 | Hedging a fact you checked | 오류가 줄어든 것으로 보입니다. → 오류가 두 건에서 한 건으로 줄었습니다. | Assert what you verified | W-07 |
| T-G3 | `일반적으로`/`대체로` with no exception | 일반적으로 대체로 저녁이 붐빕니다. → 평일 저녁 7시부터 9시까지 붐빕니다. | State the condition | W-07 |
| T-G4 | Anonymous authority `~라고 알려져 있다` | 이 방법이 안전하다고 알려져 있습니다. → 이 방법은 원본을 그대로 남겨서 안전합니다. | Give the reason or the source | W-07 |
| T-G5 | Reflexive both-sides balancing | 두 방법 모두 일리가 있습니다. → 시간이 우선이면 A, 비용이 우선이면 B입니다. | Report the trade-off with its condition | W-07 |

## H Connective overload (접속사 남발)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-H1 | Consecutive sentences opening with a connective | 따라서 붐빕니다. 또한 주차도 어렵습니다. → 붐비고 주차도 어렵습니다. | Never two connective openings in a row | W-05 |
| T-H2 | `즉` restating a clear sentence | 예약이 밀렸습니다. 즉, 대기가 길었습니다. → 예약이 밀렸습니다. | Cut the version that says less | W-05 |
| T-H3 | `나아가` on a step that never escalates | 나아가 카드도 됩니다. → 카드도 됩니다. | Reserve escalation for a real jump | W-05 |
| T-H4 | `한편` as a paragraph spacer | 한편 주차장도 넓습니다. → 주차장도 넓습니다. | Use it only for a genuine contrast | W-05 |

## I Empty formal nouns (형식명사 과다)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-I1 | `것이다` closing with no emphasis | 이곳이 낫다는 것입니다. → 이곳이 낫습니다. | Drop it unless it marks a reveal | W-06 |
| T-I2 | `~할 필요가 있다` for an obligation | 예약할 필요가 있습니다. → 예약해야 합니다. | Use the obligation ending | W-06 |
| T-I3 | `~라는 점` as a noun bridge | 대기가 길다는 점이 문제입니다. → 대기가 길어서 문제입니다. | Connect with a 연결어미 | W-06 |
| T-I4 | `~할 수 있는 부분이 있다` | 개선할 수 있는 부분이 있습니다. → 예약 화면을 더 단순하게 만들 수 있습니다. | Name the specific thing | W-06 |
| T-I5 | `~하는 바이다`, `~인 바` | 안내드리는 바입니다. → 안내드립니다. | Plain request or statement form | W-06 |
| T-I6 | Attribution formulas, universal `필요하다` | 좋은 곳이라는 분석이다. 선택 능력이 필요하다. → 방문객 후기가 좋다. 직접 골라야 한다. | Name the source or drop the attribution | W-06, W-04 |

## J Visual decoration (시각 장식)

| ID | Pattern | Bad → Good | Movement | W |
|---|---|---|---|---|
| T-J1 | Bold spanning a whole sentence | **대기가 아주 짧습니다.** → 대기가 10분이면 끝납니다. | Emphasize a phrase at most, in the editor only | W-11 |
| T-J2 | Quotation marks for emphasis | 이곳은 "진짜" 좋습니다. → 이곳은 다시 갈 만합니다. | Replace the quotes with the fact | W-11 |
| T-J3 | Em dash `—` as a default joiner | 예약은 끝났다 — 결제만 남았다. → 예약은 끝났고 결제만 남았습니다. | Pick the 연결어미 that names the relation | W-19 |
| T-J4 | Emoji as section markers | 🚗 주차 / ✅ 결제 | Follow the §4 row's per-post ceiling (most rows allow none) | W-11 |
| T-J5 | Decorative horizontal rules between short blocks | 문단마다 삽입한 `---` | Separate with blank lines instead | W-11 |

## K Naver-post tells (이 스킬 고유 S1)

These are this skill's own style rules, not a Naver source; `human-prose.md` §4 owns the list and these are the worked pairs for it.

| ID | Pattern | Bad → Good | Movement |
|---|---|---|---|
| T-K1 | Greeting-only opening | 안녕하세요. 오늘은 강남 임플란트 가격에 대해 알아보겠습니다. → 임플란트 가격은 뼈 이식 유무에 따라 100만 원 안팎 차이가 납니다. | Open with the answer the title promised |
| T-K2 | Engagement bait closing | 도움이 되셨다면 공감과 댓글 부탁드려요. → (행동 유도 하나, 독자의 다음 결정으로) 견적을 받아볼 때는 뼈 이식 항목이 포함됐는지 먼저 확인하세요. | End on the reader's next decision |
| T-K3 | Invented urgency | 지금 바로 예약하지 않으면 마감됩니다. → 주말 예약은 보통 열흘 전에 찹니다. | Replace urgency with a checkable circumstance |
| T-K4 | Stock verdict | 정말 만족스러웠어요. → 세 번째 방문이었고, 그날은 대기 없이 들어갔습니다. | Name what actually happened |
| T-K5 | Invented percentages and counts | 97%가 재방문합니다. → 같은 시간대에 다시 온 손님이 여럿 있었습니다. | Only numbers the author or a source can stand behind |
| T-K6 | Numbered section markers `01.` `02.` | 01. 위치 / 02. 가격 | Bare-line subheadings at real navigation points |
| T-K7 | Repeated CTA or repeated brand name | 문의 주세요. 궁금하면 언제든 문의 주세요. | Exactly one CTA at the end |

## Using this catalog

- Read one family, not the whole file: a translationese draft needs A, not J.
- S1 items (`human-prose.md` §3 severities, plus family K) are removed wherever they appear. S2 and S3 work follows the dominant-pattern diagnosis in [`repair-method.md`](../rules/repair-method.md) §3, so one stray occurrence of the writer's own habit stays.
- Count what needs counting with the protocol in `human-prose.md` §5, and take genre allowances from its §4 rows.
- Korean examples stay in Korean in both language versions so the pattern under discussion is the same object in each.

## Sources

> No external sources; content checked 2026-09-21.

This file states this package's own tell catalog; every prescription it names is the matching `W-` ID in [`human-prose.md`](../rules/human-prose.md) §2-§5, and it cites no external publication because it makes no external claim.
