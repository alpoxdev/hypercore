# Spec Schema Rules

How to fill every field of `assets/tone-profile-template.md`. The template is the contract; this file says what a good fill looks like and what to do when the evidence is missing.

## Provenance meta rules

Each field records where the voice claim comes from. Fill all seven; "unknown" is a valid value, an omission is not.

| Field | What to write | When it cannot be determined |
|---|---|---|
| profile_mode | `extracted` when built from supplied samples, `preset_approximation` when built from a community preset with no samples, `hybrid` when both. If samples were used at all, the mode is never `preset_approximation`. | Never left empty — the mode is a decision you make, not an observation. |
| source_scope | The population the voice claim covers, as concretely as the evidence allows: "one author's blog posts", "posts in one gallery, not the site overall". Naming a whole platform from a handful of posts is out of scope. | Write the narrowest honest scope you can support, and add the uncertainty to Known Limits. |
| sample_count | The integer number of samples analyzed. | `0` only for `preset_approximation`. |
| observed_contexts | The distinct situations samples came from (topic types, formats, audiences). Two contexts that differ only in topic are still two. | List what you can see. One context is allowed but weakens the spec — see Known Limits. |
| valid_at | Year-month the samples were observed (from the samples themselves or the user's statement). | Unknown date: use the session date and note it is the extraction date, not the observation date. |
| unsupported_contexts | Situations the samples do not cover, named positively ("long-form essays", "formal announcements") so the consumer knows where to distrust the spec. | If everything imaginable seems covered, you have not thought hard enough — list the adjacent contexts anyway. |
| 규칙 충돌 우선순위 | The conflict order the spec assumes. Standard: user's explicit instructions and facts/safety > platform or document owner's constraints > this profile > the consumer writer's defaults. | Keep the standard order unless the user overrode it; record any override verbatim. |

## Rule strength rules

Every rule outside the Meta block carries exactly one strength. The strength is part of the contract the consumer applies.

| Strength | Assign when | Example |
|---|---|---|
| MUST | The pattern is identity-carrying or near-universal in the samples: the voice stops being recognizable without it. | "MUST: end declarative sentences with ~임/~음" for an 음슴체 community |
| PREFER | The pattern is typical but the voice survives its absence in places; a reasonable default the consumer should follow unless something overrides it. | "PREFER: soften a directive with ~(?) when it could read hostile" |
| AVOID | The pattern is absent or actively wrong for this voice — writing it would break the imitation. | "AVOID: 존댓말 endings in casual posts" |

Strength assignment test: if dropping the rule from the spec would make a consumer's writing drift noticeably, it is MUST or PREFER, not decoration. If a rule appears in fewer than the band below allows, downgrade it.

## Band rules

Quantities use bands, not invented percentages. Percentages require a sample count that supports them; most extraction runs do not.

| Band | Means | Assign when |
|---|---|---|
| 주력 (dominant) | The default in most sentences/passages. | The pattern appears in the clear majority of applicable slots across samples. |
| 빈번 (frequent) | Appears in most passages, not every sentence. | Recurring across samples but clearly not the default. |
| 간헐 (occasional) | Real but sparse. | Seen at least twice, or once in a large sample set. |
| 미관측 (unobserved) | Not in the samples. | Never fabricate it. Used mainly in AVOID rows to say "not part of this voice". |

Do not upgrade a band to a number because it feels more precise. A spec that says "~임 80%" from three samples is lying with precision.

## Divergence-only rule

A consumer AI already writes like a default LLM: clear, neutral, polite-ish, well-structured. Restating defaults is noise and buries the real rules.

The divergence test, per rule: "If a competent AI wrote from the Meta block alone with no voice instruction, would it already do this?" If yes, delete the rule.

- "명확하게 쓴다", "문법에 맞춘다", "논리적 순서로 쓴다" — defaults. Delete.
- "문장마다 개행한다", "반말 고정", "ㅋㅋ을 웃긴 말 뒤에 붙인다" — divergences. Keep.
- Exception: a rule that contradicts a default is a divergence by definition — keeping it is required even if it feels obvious.

## Process gate grammar (Gates 1, 4, 5)

Gates hold instructions the consumer adopts, not personality labels. Convert every trait-shaped observation before writing it down.

| Trait (bad) | Process gate (good) |
|---|---|
| "따뜻하고 캐주얼한 톤" | "독자를 친한 이웃으로 대우한다. 설명이 필요하면 공감 한 스푼을 먼저 둔다." |
| "공격적이고 비꼬는 글쓰기" | "주장을 단정문으로 먼저 놓고, 반대 의견은 조롱 프레임으로 받는다. 정중한 완충 표현을 쓰지 않는다." |
| "감성적인 마무리" | "본문의 감정 선을 끌어올린 뒤, 마지막 줄에서 질문이나 여백으로 닫는다." |

A process gate passes this test: a consumer could follow it mechanically without knowing the adjective you started from.

Gate 2 and Gate 3 are different: they are the mechanical rules (endings, punctuation, lexicon) where tables and concrete tokens are the point. The process-gate conversion applies to 1, 4, 5.

## Empty-field handling

- A gate with no supportable rule: keep the heading, write one line stating why it is empty, and record the gap in Known Limits. Do not invent filler.
- A pattern that contradicts itself across samples: record it as a contextual adaptation (맥락 변주) if the split follows contexts, otherwise state the contradiction in Known Limits. Do not average the patterns.

## Language policy

- Default: write the spec in Korean, because the primary targets are Korean voices and Korean-speaking consumers.
- If the samples are in another language, write the spec in that language.
- The user's explicit language request outranks both defaults.
- Mechanical tokens (종결어미, symbols, slang terms) stay in their original form regardless of the spec's language.
