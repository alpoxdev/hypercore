# Human Prose Rules for Naver Posts

> Korean version: [`human-prose.ko.md`](human-prose.ko.md)

Read this before drafting (workflow step 4) and again for the self-check in step 5. It is the complete, self-contained set of generation-time rules this skill applies so the post never acquires machine-written texture. It was absorbed from a general Korean-prose rule set and trimmed to compose mode; nothing here depends on any other skill being installed. Sentence rules live only here; decoration ceilings live only in §4 of this file, and [`post-workflow.md`](post-workflow.md) §3 and [`validation.md`](validation.md) refer back to it.

## 1. Principles

- **P1 Content first.** Put facts, claims, and numbers on the page before polishing. A sentence with real content beats a smooth sentence with none.
- **P2 Evidence sentences, not filler.** Every sentence carries a fact, a reason, a step, or a comparison. Delete any sentence that only restates the previous one.
- **P3 Genre preservation.** Write in the register the post settled on (§4); do not drift into essay neutrality or into forced chattiness.
- **P4 No over-correction.** Never force colloquial tone or artificial rhythm variation to seem human. Unnatural variation is its own tell.
- **P5 Meaning is explicit.** Korean carries meaning through particles, endings, and complete sentence shapes. Dropping components to sound casual produces telegraphic fragments that read as a different kind of machine output.

These principles outrank the rules below.

## 2. Generation rules (W-01 to W-26)

Each rule has a stable ID, a one-line rule, and one bad-to-good pair. Korean examples stay in Korean in both language versions.

**W-01** When drafting, never write translated-English connectives: write `~로` or `~-하며`, not `~를 통해`; write `~에서`, not `~에 있어서`; mark the object with `을/를`, not `~에 대해`.
- Bad: 이 연구를 통해 새로운 사실이 밝혀졌다. 경제 정책에 있어서 중요한 과제다. 보고서는 인공지능의 미래에 대해 분석한다.
- Good: 이 연구로 새로운 사실이 밝혀졌다. 경제 정책에서 중요한 과제다. 보고서는 인공지능의 미래를 분석한다.

**W-02** Never write double passives or fake possessives: ban `~되어진다`, and write `있다`, not `가지고 있다`.
- Bad: 결과가 반영되어진다. 이 모델은 높은 정확도를 가지고 있다.
- Good: 결과가 반영된다. 이 모델은 정확도가 높다.

**W-03** Never give an inanimate subject a causative verb borrowed from English; rebuild the sentence with a human actor or a plain verb.
- Bad: 이 기능은 사용자가 시간을 절약하게 한다.
- Good: 이 기능을 쓰면 시간을 절약할 수 있다.

**W-04** Unpack Sino-Korean nominalizations when drafting: turn `~적`, `~성`, `~화` nouns back into verbs or adjectives.
- Bad: 시스템의 안정성의 향상이 가능하다.
- Good: 시스템을 더 안정적으로 만들 수 있다.

**W-05** Budget sentence-initial connectives: never open consecutive sentences with `또한`, `따라서`, `즉`, `나아가`.
- Bad: 따라서 품질이 중요하다. 또한 비용도 고려해야 한다. 즉, 둘 다 필요하다.
- Good: 품질이 중요하다. 비용도 따져봐야 하므로 둘 다 필요하다.

**W-06** Budget formal nouns: keep `것이다`, `점`, `수`, `바`, `~할 필요가 있다` sparse; when drafting, replace them with direct verb endings.
- Bad: 이 점을 고려할 필요가 있다고 볼 수 있는 것이다.
- Good: 이 점도 함께 고려해야 한다.

**W-07** Allow at most one hedging step per claim; never stack `~일 수도 있다고 생각된다` style double hedges.
- Bad: 이 방법이 도움이 될 수도 있다고 생각되는 것 같다.
- Good: 이 방법이 도움이 될 수 있다.

**W-08** Skip mechanical enumeration (`첫째`, `둘째`, `셋째`) unless the genre demands it; §4 (the Naver genre row) owns that exception.
- Bad: 첫째, 속도가 빠르다. 둘째, 설치가 쉽다. 셋째, 비용이 저렴하다.
- Good: 속도가 빠르고 설치도 쉽다. 비용 부담도 적다.

**W-09** Watch repeated sentence construction: four or more consecutive sentences with the same `C/O/P` shape raise the check, then keep the shape when it carries a deliberate enumeration, parallel structure, or step sequence and vary it only when it has no rhetorical reason. Ignore tense, honorifics, and register-bound terminal endings; §5 step 3 defines the unit, the meaning-bearing parallelism test, and the edge-construction rulings.
- Bad: 서버를 확인합니다. 서버를 점검합니다. 서버를 살핍니다. 서버를 확인합니다.
- Good: 서버를 확인한 뒤 관련 로그를 읽습니다. 원인이 보이지 않으면 설정까지 점검하고, 결과는 기록으로 남깁니다.

**W-10** Vary sentence length: mix long and short sentences and avoid a machine-uniform rhythm; judge by ear, not by counting.
- Bad: 데이터를 수집한다. 데이터를 정제한다. 모델을 학습한다. 결과를 평가한다.
- Good: 먼저 데이터를 모은다. 정제가 끝나면 모델을 학습하고, 마지막으로 결과를 평가해 배포 여부를 정한다.

**W-11** Treat visual decoration (bold, emphasis quotes, dashes, emoji) as a budget owned by genre; §4 (the Naver genre row) states each row's allowance as per-post counts, and those counts are the ceiling.
- Bad: **매우 중요**합니다. 이것은 *핵심* "기능"입니다.
- Good: 이 기능이 이 버전의 핵심입니다.

**W-12** Do not copy English words that Korean can express, and do not scatter parenthetical glosses.
- Bad: 이 프레임워크는 높은 플렉서빌리티(flexibility)를 제공(provide)한다.
- Good: 이 프레임워크는 유연성이 높다.

**W-13** Never write AI stock phrases: ban `결론적으로`, `시사하는 바가 크다`, `주목할 만하다`, `혁신적인`, `획기적`.
- Bad: 결론적으로 이 결과는 시사하는 바가 크며 주목할 만하다.
- Good: 이 결과가 의미하는 바는 다음 절에서 따로 다룬다.

**W-14** Never force `그`/`그녀` pronouns: Korean naturally repeats the noun or drops the subject.
- Bad: 철수는 학교에 갔다. 그는 도서관에 들렀다. 그는 책을 빌렸다.
- Good: 철수는 학교에 갔다가 도서관에 들러 책을 빌렸다.

**W-15** Write complete sentences: do not drop meaningful components behind stacked `~의`, and end sentences with a predicate and a sentence-final ending, not with a noun phrase, an adverbial phrase, or a connective ending. Headers and list items are exempt.
- Bad: 이 기능의 설정의 변경의 절차는 아래와 같습니다. 적용 시에는 재시작이 필요하니 유의하시고요.
- Good: 이 기능의 설정을 바꾸는 절차는 아래와 같습니다. 바뀐 설정은 재시작한 뒤에 적용되므로, 재시작 시점을 미리 정해 둡니다.

**W-16** Keep particles and endings that carry meaning: drop a 조사 only when omitting it is genuinely natural, and use 부사, 보조사, and 선어말어미 to make the relations between words explicit.
- Bad: 회의는 금요일 오후로. 자료는 회의 전까지 공유.
- Good: 회의는 금요일 오후에 열기로 했습니다. 자료는 회의 전까지 공유드리겠습니다.

**W-17** Prefer a concrete Sino-Korean word in its natural slot and attach 조사 and 어미 to it, so the relations inside the sentence stay visible; do not let the 한자어 float as a bare compound.
- Bad: 쓴 비용을 구하는 함수에 문제가 생기면 바로 조치 바람.
- Good: 지출한 비용을 추론하는 함수에 오류가 발생하면 즉시 담당자가 조치합니다.

**W-18** Do not substitute figurative vocabulary where an ordinary word carries the meaning; keep a figurative expression only when it is a settled idiom in this field and the plain word would sound odd.
- Bad: 이번 조사는 기존 연구의 흐름을 밟는다.
- Good: 이번 조사는 기존 연구의 방향을 따른다.

**W-19** Do not reach for the em dash as a default joiner; pick the 콜론 or 연결어미 that names the relation, and spend a dash only inside the genre row's allowance in §4 (the Naver genre row).
- Bad: 회의 결과는 한 줄이다 — 예산 승인이다.
- Good: 회의 결과는 예산 승인 한 줄이다.

**W-20** Drop the plural marker `-들` when a quantifier or the context already marks the plural; keep it only when it carries emphasis, contrast, or generalization. A mechanical blanket ban is not adopted.
- Bad: 많은 사용자들이 세 가지 기능들을 요청했다. 기능들은 다음 분기에 나온다.
- Good: 많은 사용자가 세 가지 기능을 요청했다. 기능은 다음 분기에 나온다.

**W-21** Do not waste pronouns or demonstratives: drop `그것은`/`이것은` when the antecedent is obvious, and replace `해당`, `본`, `당` with `이/그`, the bare noun, or omission.
- Bad: 이 프로젝트는 성공했다. 그것은 팀원들의 노력 덕분이다. 해당 방식은 앞으로도 유지된다.
- Good: 이 프로젝트는 팀원들의 노력 덕분에 성공했다. 우리는 이 방식을 앞으로도 유지한다.

**W-22** Drop the subject when it carries over from the previous sentence; keep it when the actor changes or two actors contrast.
- Bad: 나는 아침에 일어났다. 나는 커피를 마셨다. 나는 출근했다.
- Good: 아침에 일어나 커피를 마시고 출근했다.

**W-23** Break the three-beat habit: do not force every list and every sentence run into exactly three parallel items; vary the count or split the third item off.
- Bad: 이 솔루션은 빠르고, 효율적이며, 안전합니다. 우리는 계획하고, 실행하고, 평가했습니다.
- Good: 이 솔루션은 빠르고 효율적입니다. 계획하고 실행한 뒤 평가했고, 부족한 부분은 개선했습니다.

**W-24** When the settled register accepts a plain Korean verb, do not dress the action in a formal Sino-Korean verb such as `진행하다`, `실시하다`, `수행하다`.
- Bad: 우리는 파일럿을 진행하고, 설문을 실시하며, 결과를 검토했습니다.
- Good: 파일럿을 돌리고 설문을 거쳐 결과를 살폈습니다.

**W-25** Do not lean on formal framing phrases as filler: write the direct noun or verb instead of `~와 관련하여`, write `~로`/`~을 보고`/`~을 토대로` instead of `~에 기반하여`/`~에 바탕으로`, and make the actor the subject instead of writing `~에 의해`.
- Bad: 보안과 관련하여 예산을 늘렸고, 사용자 데이터에 기반하여 우선순위를 정했으며, 운영팀에 의해 반영되었습니다.
- Good: 보안 예산을 늘렸고, 사용자 데이터를 보고 우선순위를 정했으며, 운영팀이 반영했습니다.

**W-26** Use `~할 수 있다` only for real possibility, ability, or permission, and never repeat a modal or purpose frame across consecutive sentences: diversify `~을 위해` into `~려고`/`~고자` or fold the purpose into the verb.
- Bad: 이 도구는 배포를 자동화할 수 있다. 시간을 아낄 수 있고 실수도 줄일 수 있다. 도입은 비용 절감을 위해 추진했고, 검증은 품질 확보를 위해 강화했다.
- Good: 이 도구는 배포를 자동화한다. 시간이 줄고 실수도 덜한다. 비용을 아끼려고 도입했고, 품질을 지키려고 검증을 강화했다.

The individual patterns inside each family, each with a bad-to-good pair and the W-ID that removes it, live in [`../references/tell-catalog.md`](../references/tell-catalog.md). Reach for it when a draft reads machine-written but no single sentence looks broken.

## 3. Tell families and why they read as AI

Severity is about drafting cost: **S1** never write it; **S2** one occurrence is fine, three or more in one post is a tell; **S3** harmless alone, a tell only when stacked with others.

| 카테고리 | 대표 패턴 | 왜 AI처럼 읽히는가 | 생성 시점 처방 | 심각도 |
|---|---|---|---|---|
| A 번역투 | `~를 통해`, `~에 대해`, `~에 있어서`, `~와 관련하여`, `~에 기반하여/바탕으로`, `~에 의해`, double passive `~되어진다`, honorific passive `합의가 이루어졌다`, `가지고 있다`, `~할 수 있다` repeated, `~을 위해` repeated, progressive `~되고 있다` repeated, compulsive `그/그녀`, `했다. 그리고 했다` sentence-chaining, abstract subject with ornate object, three nested 관형절, doubled particles `-에서의`/`-으로의`/`-에로의` | English and Japanese syntax wearing Korean clothes. No Korean speaker builds a sentence this way unless translating one. | Write the verb first. `~를 통해` becomes `~로` or a connecting verb; `~에 대해` and `~과 관련하여` become a direct object or noun; `~에 있어서` becomes `~에서`; `~에 기반하여` becomes `~로` or `~을 보고`; `~에 의해` promotes the actor to subject; passives stay single; `가지고 있다` becomes `있다`; modals and purpose frames are not repeated across sentences; drop pronouns Korean would drop. | S1 |
| B 어휘 습관 | Parenthetical glosses on every term, English left untranslated where a settled Korean word exists, redundant `-들`, repeated `그것은`/`이것은`, `해당`/`본`/`당` on every noun, formal Sino-Korean verbs (`진행하다`, `실시하다`, `수행하다`) where a plain verb fits | A model reaching for source-language vocabulary and officialese instead of committing to one living voice. | Gloss a term once, at first use, only when the Korean is genuinely ambiguous. Translate anything that has a normal Korean equivalent. Drop `-들`, pronouns, and 지시관형사 that the context already carries. Keep the plain verb when the register allows it. | S2 |
| C 구조적 AI 패턴 | Mechanical `첫째/둘째/셋째`, three-beat parallel lists, bullet, heading and emoji overload, a comma after every 연결어미, comma-joined independent sentences, list-introducing colons (`다음과 같습니다:`) | Answer-shaped scaffolding imposed on prose that nobody asked to be an outline. | Default to paragraphs. Enumerate only when the genre asks for it, and vary list lengths. Let 연결어미 carry the clause without a comma propping it up. End the lead-in sentence with a period. | S1~S2 |
| D AI 특유 관용구 | `결론적으로`, `시사하는 바가 크다`, `주목할 만하다`, `혁신적인`, closing formulas `지금이야말로`, `~할 때다`, `~라는 뜻이다`, `~인 셈이다`, theatrical hooks `질문을 던진다`, causal shorthand `~로 이어진다` | Stock filler that asserts significance the sentence never earned. Instantly recognizable across thousands of generated texts. | Delete the phrase and state the finding. If the point matters, the specific fact shows it; if there is no fact, there is no point. | S1 |
| E 리듬 균일성 | Sentences of near-identical length, four or more identical `C/O/P` shapes with no meaning-bearing parallelism, every paragraph the same shape and sentence count, uniform `~이다/~한다` or uniform `-습니다` cadence with no breath inside the settled register | Human writing breathes unevenly. A repeated mold becomes a tell when it carries no deliberate enumeration, parallel structure, or step sequence. | Mix lengths by content. When the shape count raises, keep meaningful parallelism and vary only an unmotivated mold. Fix the register before the first sentence and hold it; vary endings inside the register, never across registers. | S2 |
| F 수식·중복 | `매우`/`정말` stacked on adjectives, paired synonyms doing one job, `~적`/`~성`/`~화` sprayed across nouns, redundant modifier implied by the head noun | Intensity substituted for evidence, plus Sino-Korean nominalization that pads without adding meaning. | Cut the intensifier and let the noun carry weight. Keep one of any synonym pair. Unfold `~적/~성/~화` into a verb or plain noun. | S2 |
| G Hedging 남용 | Stacked softeners such as `~할 수 있을 것으로 보인다`, both-sides balancing (`양쪽 모두 일리가 있다` with no decision) | Multiple hedges on one claim read as a model insuring itself rather than a writer judging. | One hedge per claim, at most. If the uncertainty is real, name what is uncertain and why. A genuine open question is fine; a reflexive balance formula is not. | S2 |
| H 접속사 남발 | `또한`, `따라서`, `즉`, `나아가` opening consecutive sentences, repeated `하지만`/`그러나`, `즉` restating a clear sentence | Connectives narrating logic the sentences already carry, sentence after sentence. | Let sequence do the work. Open with a connective only where the turn would otherwise be missed, never twice in a row. | S2 |
| I 형식명사 과다 | `것이다`, `점`, `수`, `바`, `~할 필요가 있다`, attribution formulas `~는 분석이다`/`~는 뜻이다`, universal `필요하다`, `능력` on every noun | Empty nouns inflate a plain predicate into a bureaucratic one. Dense clusters read as generated hedging. | Say the predicate directly. `~할 필요가 있다` becomes `~해야 한다`; drop `것이다` unless it carries real emphasis. Attribute claims to a named source or drop the attribution. | S2 |
| J 시각 장식 남용 | Bold runs, quotation marks used for emphasis, dashes `—` as paragraph-level inserts, emoji, list-introducing colons, decorative horizontal rules | Decoration replaces emphasis that structure and word choice should have delivered. | Earn emphasis with sentence position and word choice. In prose genres, spend decoration sparingly; in document genres, follow that skill's formatting contract instead. | S2~S3 |

## How the families stack

The families are not independent, and the stacking is what makes a paragraph read as generated rather than merely stiff.

- A and I feed each other. Translationese pulls in empty nouns, so a sentence carrying `~를 통해` usually carries `것이다` a few words later. Fixing the syntax often clears both.
- D and F travel together. A phrase like `시사하는 바가 크다` almost always arrives with an intensifier, because both exist to assert importance without evidence.
- C and E compound. Mechanical enumeration forces parallel sentence shapes, which flattens rhythm; the fix for one usually loosens the other.
- J is the amplifier. Alone it is a formatting preference. Layered on C's bullet scaffolding or D's stock phrases, it converts a merely stiff passage into an obviously generated one, which is exactly why it sits at S2~S3.

When a draft feels wrong but no single sentence looks broken, look for a stack rather than a violation.

## 4. Naver blog genre rows

Settle the row before the first sentence and hold its register for the whole post. Decoration ceilings below are **per post**, applied in the Naver editor (never markdown), and are ceilings, not quotas.

| Row | Register | Allowed | Decoration ceiling per post | Forbidden |
|---|---|---|---|---|
| 경험·후기·일상 | `-했어요 / -였어요` first person | Owned circumstances, a reaction the writer actually had, photo captions that state a fact, sentence-length variation by content | bold ≤ 1 short phrase per section, emphasis-quote pair ≤ 1, dash 0, emoji ≤ 2, exclamation ≤ 1 | 첫째/둘째 scaffolding, stock verdicts (`정말 만족스러웠어요`), 인사말-only openings, hype adjectives |
| 정보·비교·가이드 | `-습니다` or `-해요` (pick one) | Sourced facts with dates, tables for comparisons, bare-line subheadings | bold ≤ 1 short phrase per section, emphasis-quote pair ≤ 1, dash 0, emoji 0, exclamation 0 | 결론적으로, `~할 필요가 있다` runs, hedging stacks, list-introducing colons |
| 전문·서비스 (전환형) | `-습니다` | Case facts with checkable details, one disclosure sentence, one CTA at the end phrased as the reader's decision | bold ≤ 1 short phrase per section, emphasis-quote pair ≤ 1, dash 0, emoji 0, exclamation 0 | urgency words, fake exclusivity, invented percentages, 절대/무조건/반드시 |

Skill-specific S1 additions on top of family D (this skill's own style rule, not a Naver source): `도움이 되셨다면 공감과 댓글 부탁드려요`, `지금 바로`, `오늘은 ~에 대해 알아보겠습니다` as the opening sentence, `~를 소개해 드리려고 합니다` as the opening sentence, and any `**bold**` or `#` markdown pasted into the editor.

The register never changes inside a post. Only the *allowed content* column may borrow: the disclosure sentence and the CTA always follow the 전문·서비스 content rules even inside an 경험 post, written in the post's own register.

## 5. Self-check protocol (run before delivery)

## 1. Draft self-check protocol

Run these in order on the draft you just produced. Steps 1 to 6 are checks; 7 and 8 govern when to stop.

1. **S1 scan.** Reread the draft for the never-write items: 번역투 구문 and the AI 관용구 목록 in §2. Every hit is removed, not softened. This step has no threshold, because one occurrence is one too many. When the draft reads wrong but no rule names it, walk [`../references/tell-catalog.md`](../references/tell-catalog.md) family by family instead of guessing.

2. **문두 접속사 count.** Count sentences opening with 또한, 따라서, 즉, or 나아가. Two or more in consecutive sentences fails `(출처: fixed)`. Fix by merging the two sentences or deleting the connective; the logic usually survives without it.

3. **Sentence-shape run count.** Walk the sentences in order and write one `C/O/P` unit for each. `C` is the number of clauses: count each main, connective, adnominal, or quoted clause once, but count a predicate with auxiliaries such as `-고 있다` as one clause. `O` is `O` when the main clause has an explicit object marked `을/를`, otherwise `-`. `P` is the final predicate class after ignoring tense, honorifics, and the register-bound terminal ending: `V` for an action verb, `A` for a state or descriptive predicate, or `C` for the copula `이다`. Four or more consecutive identical units raises the check `(출처: fixed)`; it does not by itself fail the draft. Worked example: `회의는 오전 열 시에 시작합니다. 먼저 지난주 실적을 확…

**Meaning-bearing parallelism test:** when the trigger raises, ask whether the repeated shape itself carries the meaning—a deliberate enumeration, parallel structure, or step sequence whose parallelism is the content; if yes, pass and move on, but if the sentences merely land in one mold for no rhetorical reason, vary them `(출처: judgment)`.

- PASS: `검색창은 이름과 지역을 함께 받습니다. 결과 화면은 가까운 순서로 매장을 보여 줍니다. 필터는 영업 상태와 편의 시설을 구분합니다. 지도는 각 매장의 위치를 표시합니다. 저장 목록은 관심 매장을 한곳에 모읍니다.` is `1/O/V × 5`; the five parallel feature statements carry the enumeration, so keep them.
- FAIL: `서버를 확인합니다. 서버를 점검합니다. 서버를 살핍니다. 서버를 확인합니다.` is `1/O/V × 4`; the shape adds no rhetorical work to the repeated claim, so vary or cut it.

Classify the three edge constructions this way so the count has one answer: `-(으)ㄹ 수 있다` is one modal predicate and takes the lexical predicate's class, because `수 있다` expresses possibility rather than adding an adnominal clause (`배포할 수 있습니다` = `1/-/V`); lexical `있다/없다` takes `A`, because existence or absence is a state (`자료가 있습니다` and `오류가 없습니다` = `1/-/A` each); result-state `되다`, including `-어 있다`, takes `A`, because it describes an attained condition rather than a transition (`준비가 되어 있습니다` = `1/-/A`; eventive `설정이 변경되었습니다` remains `1/-/V`).

This unit measures author-controlled construction instead of register-bound morphology. It catches the common identical-mold run, not every repetitive paragraph; step 4's rhythm eyeball covers repetitions that superficial tuple variation lets through. Terminal endings encode the required 합니다체, 한다체, or 해요체 and therefore cannot reliably signal monotony.

4. **Rhythm eyeball.** Look at the paragraph as a shape. A clean draft visibly mixes short sentences with long ones; if every sentence lands at the same length, fix it `(출처: judgment)`. Cut or combine where the content allows, and leave it alone where it does not.

5. **형식명사 density eyeball.** Scan each paragraph for 것이다, 점, 수, and 바 piling up. When they stack inside one paragraph, rewrite that paragraph `(출처: judgment)` so the nouns carry meaning instead of padding.

6. **Decoration count.** Count five things in the draft: bullet lists, bold spans, emphasis-quotation pairs, dashes, and emoji. Read the settled genre's row in §4, which states each as a per-post number. Compare count against allowance one element at a time; every element over its allowance gets cut until the count is at or under the number `(출처: fixed)`. That file owns the numbers; this one names the comparison and does not restate them.

7. **"Already good" exit.** When all six checks pass and nothing needs an edit, deliver as is `(출처: judgment)`. Do not manufacture changes to look diligent. An untouched clean draft is a pass, not a skipped step.

8. **Recheck limit.** At most two fix-and-rescan passes `(출처: fixed)`. If something still fails on the second pass, deliver the draft and state the remaining issue in one line rather than churning the wording further.

Never annotate the post itself with rule IDs.
