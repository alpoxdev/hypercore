# Tone Profile: <name / community / author>

<!--
HOW TO USE THIS TEMPLATE
- This is the final-spec skeleton. Fill every field; delete nothing, including Known Limits.
- Each rule line carries a strength: MUST (always apply), PREFER (default when nothing overrides), AVOID (do not do).
- Quantities: write a band (dominant / frequent / occasional / unobserved) unless the sample count supports a firmer claim. Never invent percentages.
- Divergence-only: a consumer AI already writes like a default LLM. Only record what differs from generic defaults. If a rule would say "write clearly", delete it.
- Evidence quotes and reliability notes are analysis scaffolding: they stay in your working notes and are removed before delivery. Provenance (the meta block) stays.
- Language: write the spec in Korean by default, in the samples' language when they are non-Korean, and in the user's requested language when they ask.
-->

## Meta

<!-- This block is the spec's provenance. It must survive into the final document unchanged. -->
<!-- profile_mode: extracted (built from supplied samples) | preset_approximation (community preset, no samples) | hybrid (samples + preset) -->
- profile_mode: <extracted | preset_approximation | hybrid>
<!-- source_scope: what the voice claim covers — e.g. "one author's blog posts", "one gallery's posts, not DC Inside overall" -->
- source_scope: <what population of writing this voice represents>
<!-- sample_count: number of samples used. 0 means preset_approximation. -->
- sample_count: <N>
<!-- observed_contexts: the distinct situations the samples came from (e.g. recipe posts + comment replies). One context = weaker generalization. -->
- observed_contexts: <context list>
<!-- valid_at: when the voice was observed. Community slang ages fast; a spec without a date silently goes stale. -->
- valid_at: <YYYY-MM>
<!-- unsupported_contexts: situations the samples do NOT cover — the consumer must not trust the spec there. -->
- unsupported_contexts: <context list>
<!-- conflict precedence: what wins when rules clash. Keep the standard order unless the user overrode it: user explicit/facts+safety > platform/owner constraints > this profile > consumer writer defaults. Record any override here. -->
- 규칙 충돌 우선순위: <standard order, or the user's override>

## Gate 1: 생성 태도 (Generative Orientation)

<!-- The stance to adopt before writing: how the writer sees the reader, what comes first, what the writing is for. Write it as an instruction the consumer adopts, not a personality description. -->
<!-- Bad (trait): "따뜻하고 유머러스한 톤" -->
<!-- Good (process): "독자를 같은 취향의 이웃으로 대우한다. 설명보다 공감을 먼저 구한다. 사실 나열보다 자기 경험을 앞세운다." -->

- MUST: <the stance rule that always holds>
- PREFER: <default behaviors when nothing overrides>
- AVOID: <stances this voice never takes>

## Gate 2: 문장 구조 (Sentence Architecture)

<!-- Endings, sentence length, line breaks, punctuation. This is the mechanical core — for community styles it carries identity, so be concrete. -->
<!-- Band legend: 주력 (dominant — the default in most sentences) / 빈번 (frequent — appears in most passages) / 간헐 (occasional — real but sparse) / 미관측 (unobserved — do not fabricate). -->

### 종결 체계

| 종결 | 강도 | 빈도(band) | 용례 조건 |
|---|---|---|---|
| <~임/~음> | MUST | 주력 | <when to use> |
| <~네요> | PREFER | 빈번 | <when to use> |
| <~습니다> | AVOID | 미관측 | <why avoided> |

### 문장부호·이모티콘

<!-- e.g. "ㅋㅋ: MUST after a joke, 2-4 repeats" / "마침표 2개(..): PREFER for trailing-off" -->
- <symbol>: <strength> — <usage condition, band>

### 문장 길이·개행

- MUST: <e.g. one sentence per line / short burst sentences>
- PREFER: <typical sentence length band>

## Gate 3: 어휘층 (Vocabulary & Lexicon)

<!-- Community slang and naming are identity. But slang lists go stale: mark uncertain items and rely on usage rules over inventories. -->
<!-- Profanity and slang: record tolerance level and manner as rules (e.g. "mild slang MUST appear; hard profanity PREFER only in quoted anger"), never a mandatory vocabulary list. -->

### 은어·고유어

<!-- Only terms the samples actually use. Mark anything you cannot confirm as 미검증. -->
| 표현 | 뜻 | 강도 |
|---|---|---|
| <term> | <meaning> | <MUST/PREFER/AVOID> |

### 호칭 체계

- MUST: <how the writer addresses the reader, e.g. "언냐들", "이웃님", never "여러분">

### 비속어·어휘 허용도

- <tolerance rule with strength and condition>

## Gate 4: 구조·서사 (Structure)

<!-- The skeleton of a typical piece: opening move, body order, closing move. Title habits when relevant. -->
- MUST: <structural rule that always holds, e.g. "context dump before any feeling">
- PREFER: <typical ordering>
- AVOID: <structures this voice never uses>

## Gate 5: 시그니처 (Signature Texture)

<!-- Rhetorical moves unique to this voice — the reason a reader recognizes it in one sentence. Divergence-only: if a default LLM would plausibly do it, it is not a signature. -->
- <signature move with strength>

## 맥락 변주 (Contextual Adaptations)

<!-- Required when observed_contexts has 2+ contexts; if only one context was observed, move what you would have written into Known Limits instead of guessing. -->
| 상황 | 달라지는 것 |
|---|---|
| <context A> | <which endings/lexicon/stance shift, with strength> |
| <context B> | <shifts> |

## 한계 (Known Limits)

<!-- NEVER delete this section. An empty limit list is a false claim of completeness. -->
- 이 스펙으로 재현되지 않는 것: <e.g. slang of the moment, inside jokes, the author's factual habits>
- <degradation notes: e.g. "holdout verification unavailable — sample_count < 3" / "single observed context — generalization to other contexts unsupported" / "preset fidelity not verified — preset_approximation mode">

<!--
DELIVER STEP CHECKLIST (run before handing this to anyone)
- [ ] Analysis scaffolding removed: no evidence quotes, no reliability notes, no rule IDs from the skill package.
- [ ] Meta block intact: profile_mode, source_scope, sample_count, observed_contexts, valid_at, unsupported_contexts, 규칙 충돌 우선순위 all filled.
- [ ] Every rule has a strength (MUST/PREFER/AVOID); quantities are bands unless firmer claims are supported.
- [ ] Known Limits present and honest.
- [ ] Self-contained: readable and usable without the skill package, this repository, or any external file.
-->
