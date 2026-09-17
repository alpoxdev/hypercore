# Hook Library: Titles, Openings, Endings, and Vocabulary

> Korean version: [`hook-library.ko.md`](hook-library.ko.md)

Read this when drafting the title, the first screen, the closing, or the call to action. Every pattern is graded against two things: what Naver's own guidance permits (see [`../rules/naver-ranking-contract.md`](../rules/naver-ranking-contract.md) R4, R6, R9) and whether it reads as a person wrote it. The library generalizes a practitioner's conversion-oriented prompt and keeps only what survives both tests.

## 1. The one rule behind every hook

A hook is a **specific promise the first screen keeps**. Naver defines 낚시성 as a title/body–query mismatch and asks that readers can predict the content from the title. So:

- Promise something concrete (a decision, a number you measured, a condition, a mistake you made).
- Deliver it within the first 3-5 sentences.
- Never conceal the subject ("이것", "비밀", "충격") or invent statistics ("97%가 모르는").

## 2. Title patterns

| Pattern | Naver-ready example | Why it works | Risk |
|---|---|---|---|
| Decision boundary with a number | `직접 써 본 무선청소기 3개, 반려동물 털 기준으로 고른 1개` | Scope is scannable; the count is literal | High if the count is invented or padded |
| Specific curiosity gap | `성수역 3번 출구 카페, 재방문 전 확인할 한 가지` | Names the subject, withholds only the answer the body opens with | Medium if the gap is vague; fails if the body delays the answer |
| Self-relevant question | `아이와 비 오는 날, 실내놀이터와 박물관 중 어디가 나았을까?` | Question headlines outperformed declaratives in two field experiments; must be a real decision the body answers | Credibility drops if the question is rhetorical |
| Experience/후기 with the checked item | `제주 렌터카 2박 3일 후기: 보험보다 먼저 확인한 항목` | Signals first-hand basis; matches D.I.A. 경험 정보 | Fails if the experience is not real or is undisclosed sponsorship |
| Evidence-backed warning | `누수 업체 부르기 전, 사진으로 먼저 확인할 3가지` | Negative framing lifts clicks in news experiments; safe only when the harm is real and prevention follows | High if the harm is exaggerated or the body sells instead of preventing |
| Conclusion first | `소형 가정이면 A, 소음 때문에 B는 제외: 3개월 사용 결론` | Reduces search-intent uncertainty | Fails if body evidence contradicts the conclusion |
| Comparison with the axis named | `강남 임플란트 가격 비교, 개당 가격보다 먼저 본 3가지` | Matches 스마트블록 comparison intent | Medium in regulated fields (medical/finance): every claim needs a source |

Length: 20-35 characters, target query near the front (mobile truncation), no emoji, no `[]` brackets stacked with keywords.

## 3. Opening patterns (first screen)

Order: **empathy in one concrete sentence → the answer or finding → why you can say so → what the rest covers**.

| Move | Example | Notes |
|---|---|---|
| Concrete empathy | `저도 처음엔 주차 때문에 망설였어요.` | One sentence. Name the actual situation, not "많은 분들이 고민하시죠" |
| Answer first | `결론부터 말하면 평일 11시 전에는 괜찮았습니다. 주말은 달랐어요.` | Keep from the seed prompt: "바쁘실 여러분을 위해 결론부터" — then actually give the conclusion |
| Basis of credibility | `3주 동안 네 번 방문해서 시간대별로 확인했습니다.` | Date, duration, count, price basis, or source |
| Scope promise | `아래에서는 시간대별 주차 상황, 대안 주차장 2곳, 비용을 정리했습니다.` | The literal section list; no "3분만 집중해 주세요" pressure |
| Disclosure (when applicable) | `이 글은 ○○에서 제품을 제공받아 작성했습니다. 장점 2가지와 아쉬운 점 1가지를 그대로 적었습니다.` | Before any evaluation; plain words |

Adapted from the seed prompt (usable after rewriting):

- `지금 이 글을 보고 계신 분께서는 ~를 알아보고 계실 텐데요` → `~를 알아보는 중이라면, 제가 확인한 기준부터 보세요.`
- `제가 직접 '이것'의 정체를 알려드릴까 해요` → `제가 [기간/조건]에서 확인한 내용을 먼저 적겠습니다.`
- `딱 1분만 집중해 주시길` → `먼저 30초 요약을 적고 근거는 아래에 붙였습니다.` (only if the summary exists)
- `그리고 위와 같은 사례의 문제는 1가지 공통점을 가지고 있는데요` → keep, only when the common point is demonstrated in the next paragraph.
- `~ 이유만으로 ~하면 안 되는지, 어떤 기준으로 선택해야 하는지` → keep; strong warning-plus-criteria frame.

Dropped from the seed prompt (concealment, invented numbers, mind-reading, pressure): `'이것'이 무엇일지 궁금해지셨을 거예요`, `97%는 … 클릭했을 겁니다`, `수천만 원의 비용을 지출할 수 있는 상황`, `저희 블로그를 참고하시면`, `3분만 집중해주세요`.

## 4. Vocabulary: keep, adapt, drop

| Seed category | Verdict | Rule |
|---|---|---|
| Hidden information (`아무도 몰랐던`, `1%만 아는`, `97%가 모르는`, `비밀`) | Drop | `[observed, T4]` invented exclusivity is the usual shape of a title whose body cannot deliver; the official 낚시성 definition is title/body-query mismatch (`evidence-digest.md` T4) |
| Urgency (`지금`, `바로`, `당장`, `하루라도`) | Drop unless a real deadline exists | False urgency is deceptive content |
| Time claims (`몇 초 만에`, `3초 안에`) | Adapt to measured duration | `설치에 12분 걸렸습니다` |
| Trust words (`책임지는`, `매일 쓰는`, `실패하지 않는`, `인생을 바꾼`, `확실한`) | Adapt or drop | Demonstrate with facts; absolutes (`인생을 바꾼`, `확실한`) drop |
| Counts (`총정리`, `TOP 3/5/7`, `한 가지`, `하나만`) | Keep if literal | The count equals the evaluated set |
| Fear (`손해 보는`, `후회하는`, `큰일 나는`, `피해야 할`) | Adapt only to a specific, evidenced harm | State the harm and its condition; deliver prevention |
| Ease (`누워서도`, `혼자서도`, `누구나`, `~없이도`) | Adapt only if tested and qualified | `혼자서도` is unsafe for expertise-required work |
| Emphasis (`단`, `절대`, `무조건`, `반드시`, `미친`, `압도적인`) | Drop | Unsupported emphasis reads as advertising and as AI |
| `무료` | Keep only if materially free | — |
| `~하지 마세요` | Keep as an evidence-backed warning title | — |
| `~살 때 자주 듣는 질문` | Keep if the questions are real | — |

Phrases from the seed's "검증된 후킹 문구" that are dropped outright: `한번 믿어보세요`, `100% 후회합니다`, `한국인 99%가 모르는`, `미친 내용을 발견했어요`, `저 오늘 100만원 벌었어요`, `고민 없애드립니다. 종결`, `3가지 비밀`, `여기, ~가 있습니다`, `충격적인 / (감동주의)`, `수준 ㄷㄷ`, `진실을 폭로합니다 (삭제예정)`.

## 5. Ending patterns

A closing does three things: restate the decision the reader can now make, name the condition under which it would differ, and offer one bounded next step. No "새로운 시각", no "성공의 첫걸음", no "행운을 빕니다".

Keep from the seed (as written or lightly trimmed):

- `여기까지 읽어보셨다면, 어떤 기준으로 ~할지 감이 조금은 오셨을 듯한데요.` then the actual criteria in one line.
- `만약 추가로 더 알고 싶으신 부분이 있다면, 아래 링크를 확인해 보시는 것도 좋습니다.` — link must be a specific primary source.
- `실제 적용해보며 느낀 점을 나중에 공유해주시면 큰 도움이 될 것 같습니다.` — asks for use feedback, not praise.
- `혹시라도 궁금한 부분이 있으시면, 추가 자료를 통해 더 깊이 알아보실 수 있습니다.` — name the resource.

Adapt: `지금 바로 적용해 보신다면` → tie `지금` to a real task; `언제든지 찾아주세요` → a bounded contact route; `눈탱이 맞는 상황을 예방` → price-comparison evidence.

Drop: `큰 변화를 경험하게 될 것입니다`, `새로운 시각을 가지셨다면`, `성공의 첫걸음`, `어느새 이 글이 끝났네요`, `더 유용한 정보로 찾아뵙겠습니다`, `확신을 가지고 … 시작은 이 글로부터`, `이제는 실행만 남았습니다. 행운을 빕니다!`.

## 6. Conversion-mode call to action (전환형 only)

- One CTA, at the end, after the value has been delivered.
- Phrased as the reader's next decision, not the brand's wish: `견적을 비교할 때 위 세 항목을 먼저 물어보세요. 저희 기준표는 [링크]에 있습니다.`
- Brand facts (가치입증) are inserted **verbatim** from the user's input; the skill never invents credentials, counts, awards, or prices.
- The commercial relationship (own business, sponsorship, affiliate) is disclosed in the opening, not discovered at the CTA.

## 7. Pre-publish red-flag pass

Fail the draft if any of these is present: an invented percentage or statistic; a hidden economic relationship; an absolute guarantee; a fake deadline; a title the first screen does not fulfil; a generic CTA (`도움이 되셨다면 공감/댓글`); markdown `**bold**` or `#` headings pasted into the Naver editor.
