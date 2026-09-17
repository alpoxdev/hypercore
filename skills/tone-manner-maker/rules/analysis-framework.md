# Analysis Framework Rules

How to analyze samples in step 3 (Analyze) and step 4 (Synthesize). Output of this stage is per-axis patterns with quoted evidence — not the spec itself.

## The 5 axes

Analyze every sample set on all five axes. Each axis yields patterns; every pattern carries at least one quoted evidence snippet and, where the axis supports it, a measurable count.

### Axis 1: 종결 체계 (Speech level & endings)

- Measure: ending distribution (which endings appear, in what role — declarative, question, exclamation), speech level mix (반말/존댓말/음슴체/해라체), and whether endings differ by sentence role.
- Count: endings per declarative sentence, per question, per paragraph close. Large sample sets support bands directly; small ones still support "dominant/absent" judgments.
- Evidence: quote one sentence per ending family.
- Trap: transcript speech is not writing style. Do not count a spoken aside as the written ending.

### Axis 2: 문장부호·이모티콘 (Punctuation & symbols)

- Measure: usage patterns of `ㅋㅋ`, `ㅠㅠ`, `..`, `~`, `!!`, `(?)`, emoticons, and their placement rules (after jokes? after sad statements? line-final only?).
- Count: symbol occurrences and their preceding context type; repeats per occurrence.
- Evidence: quote the line each symbol rule comes from.
- Trap: a symbol in one sample may be one author's tic, not the voice. Check recurrence across samples before assigning strength.

### Axis 3: 어휘층 (Vocabulary & lexicon)

- Measure: community slang or author-specific terms (with meanings), naming/address system for the reader, hanja-word vs native-word vs loanword preference, profanity tolerance.
- Count: term occurrences; whether terms appear in all samples or only some.
- Evidence: quote each term in its natural sentence. A term you cannot confirm in the samples is marked unverified or left out entirely.
- Trap: do not build an exhaustive slang dictionary from outside knowledge. Only the samples' own lexicon goes in the spec; outside knowledge belongs to presets, clearly labeled.

### Axis 4: 구조·서사 (Structure & narrative)

- Measure: opening move (how the piece starts), body ordering (context first? feeling first? argument first?), closing move (question? trailing off? resolution?), paragraph and line-break habits, average sentence length.
- Count: sentences per line/paragraph, line-break frequency, typical piece length.
- Evidence: outline one representative sample piece showing its skeleton.
- Trap: structure lives in the arrangement, not in any single sentence. Do not quote a sentence as structural evidence without noting where it sits in the piece.

### Axis 5: 독자 관계·태도 (Reader stance)

- Measure: how the writer positions the reader (in-group member? student? stranger?), the dominant stance (empathy-seeking, informing, mocking, formal), how disagreement or emotion is expressed, and any in-group norms the writer visibly follows.
- Evidence: quote passages where the stance is unmistakable.
- Trap: stance is the home of trait-descriptions. Capture observable behaviors ("does not soften directives", "addresses readers as peers") that Gate conversion can use.

## Quantitative measurements checklist

Run these counts when samples are long enough (roughly 3+ substantial pieces). They feed Gate 2 and the band assignments:

1. Ending distribution per sentence role
2. Symbol and emoticon frequency and repeat counts
3. Average sentence length and range
4. Line-break habit (per sentence / per thought / dense paragraphs)
5. Slang term occurrence count across samples
6. Reader-address forms and their frequency

## Analyze → Synthesize separation

Analyze produces observations per sample. Synthesize decides what the spec says. Keep them apart:

- **Common invariants**: patterns present across samples and contexts → Gate rules, strength by the spec-schema rules.
- **Contextual variation**: patterns that hold in context A but flip in context B → 맥락 변주 rows, keyed to the observed contexts.
- **Contradictions**: patterns that clash without a context split → state them in Known Limits. Never average them into a mushy middle rule.

## Conditional Confirm

Ask the user a confirming question in step 5 only when at least one of these holds:

1. **Representativeness uncertainty** — the samples might not represent the voice the user means (few samples, one context, an author's off-day style).
2. **Mixed voices** — samples plausibly contain more than one writer or register, and the split is not obvious.
3. **Unknown scope** — it is unclear whose voice or which community the spec should cover.

Otherwise proceed without stopping. In particular, do not stop to confirm when the analysis is consistent and the scope was stated in the request — report the synthesis and draft. When you do ask, ask one question that names the specific uncertainty, not a general "is this okay?".

## Averaging prohibition

Do not average samples into a composite voice. If sample 1 uses `~임` and sample 2 uses `~합니다`, the answer is a rule split by context or a Known Limit, never "~을 때도 있습니다". A composite of two voices is neither voice.
