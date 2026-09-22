# Community Tone Presets

Approximation presets for well-known Korean community styles, for use when the user has no samples. Every preset here is `preset_approximation`: a schema-shaped summary from secondary research, not an extraction from verified primary samples.

## Contents

- How to use presets
- Preset: 디시인사이드 (DC Inside)
- Preset: 네이트판 (Nate Pan)
- Preset: 더쿠 · 인스티즈 (Theqoo / Instiz)
- Preset: 펨코 (Femco)
- Preset: 블라인드 (Blind)
- Preset: 맘카페 (Mom Cafe)
- Preset: 스레드 (Threads Korea)

## How to use presets

- Presets are starting points. `sample_count: 0` means no primary sample supports them; treat every rule as PREFER-grade unless labeled otherwise, and never claim author or subcommunity fidelity — only the community-wide approximation.
- When the user later supplies samples, the samples override the preset (`rules/sample-quality.md` preset → sample upgrade) and the mode becomes `hybrid`.
- Slang ages fast. `valid_at` on each preset is the observation basis; check freshness for anything time-sensitive, and mark uncertain items 미검증 (unverified).
- Profanity and slang appear as tolerance rules (how often, in what mood), never as a mandatory vocabulary list.

## Preset: 디시인사이드 (DC Inside)

- profile_mode: preset_approximation
- source_scope: DC Inside gallery posts and replies, general gallery culture — not any single gallery's full culture
- sample_count: 0
- observed_contexts: gallery main posts, reply threads
- valid_at: 2026-09
- unsupported_contexts: gallery-specific slang dictionaries, other platforms
- Basis: research claims C2, U1; slang inventory incomplete (source blocked) — treat any listed slang as examples, not a dictionary

- MUST: 음슴체 endings — declarative sentences close with ~임/~음; questions with ~냐/~거든
- MUST: short sentences, one thought per line (per-line line breaks)
- PREFER: 반말 throughout; direct declarative claims first, reaction second
- PREFER: `ㅋㅋ` runs (2–6 repeats) after jokes or mockery; `;;` for awkwardness
- PREFER: ironic, mocking stance toward the topic; "correctness" framed as gallery common sense
- AVOID: polite 해요체/합니다체 in casual posts; hedged or softened directives
- Profanity: habitual mild-to-strong slang is part of the register (PREFER in casual anger), quoted insults follow the community's own patterns — not a fixed list
- 미검증: gallery-specific slang inventory (U1); era-dependent slang

## Preset: 네이트판 (Nate Pan)

- profile_mode: preset_approximation
- source_scope: Nate Pan board posts (사회·연예·이슈 boards), general board culture — not a specific board
- sample_count: 0
- observed_contexts: event posts (사건글), advice posts, hot-issue reactions
- valid_at: 2026-09
- unsupported_contexts: board-specific in-jokes, other platforms
- Basis: research claims C3

- MUST: 음슴체 + 호소체 mix — ~남/~임/~듯 narration alternating with ~거든요/~네요 in emotional passages
- MUST: frequent line breaks, long emotional narrative with situational detail (정황 묘사)
- PREFER: `ㅠㅠ` for sadness or frustration; titles short and attention-grabbing
- PREFER: empathy-seeking framing; readers addressed as fellow board users
- PREFER: slang like 썰 (story/tale) for narrative framing
- AVOID: dry factual reporting style; formal 존댓말 narration in event posts
- Profanity: mild expressions in strong passages, sparing in narration

## Preset: 더쿠 · 인스티즈 (Theqoo / Instiz)

- profile_mode: preset_approximation
- source_scope: Theqoo and Instiz post+comment culture (female-majority communities) — not a specific board
- sample_count: 0
- observed_contexts: hot-issue reaction posts, comment threads
- valid_at: 2026-09
- unsupported_contexts: other female-majority boards, board-specific slang
- Basis: research claims C4

- MUST: friendly 반말, ~해/~임 mixed; readers addressed as peers (언냐 register)
- MUST: `ㅋㅋ`/`ㅠㅠ`/`!!` frequent; `(?)` appended to soften or snark a claim
- PREFER: empathy-seeking openers ("나만 ~한 거 아니야?" style)
- PREFER: anti-blame norms — criticism softened, attacks on the post's subject restrained
- AVOID: aggressive confrontation; formal speech in reaction posts
- Profanity: low tolerance; express intensity with punctuation and exaggeration instead

## Preset: 펨코 (Femco)

- profile_mode: preset_approximation
- source_scope: Femco board posts and comments, general culture — not a specific board
- sample_count: 0
- observed_contexts: hot-issue reactions, community meta-posts
- valid_at: 2026-09
- unsupported_contexts: board-specific slang, other platforms
- Basis: research claims C5

- MUST: short, assertive sentences; ~임/~다 endings
- MUST: 초성체 abbreviations (ㄱㄱ, ㅁㅁ, ㅇㅈ, ㄹㅇ) as the normal register
- PREFER: `ㅋㅋ` after punchlines; factoid-dropping ("팩트") followed by a quip
- PREFER: rhetorical taunts like ~지않냐; dry humor over emotional narration
- AVOID: long emotional narratives; empathy-seeking framings
- Profanity: habitual mild slang is normal (PREFER); direct slurs follow community norms — not listed here

## Preset: 블라인드 (Blind)

- profile_mode: preset_approximation
- source_scope: Blind workplace posts, general company-culture register — not a specific company board
- sample_count: 0
- observed_contexts: career advice, salary/transfer topics, workplace complaints
- valid_at: 2026-09
- unsupported_contexts: non-workplace topics, company-specific slang
- Basis: research claims C6

- MUST: polite 존댓말 (~합니다/~요) despite anonymity
- MUST: workplace register — workplace nouns and titles (부장님, 선배, 동료) as natural vocabulary
- PREFER: restrained tone, few emoticons; practical detail over venting
- PREFER: salary, transfer, evaluation topics treated matter-of-factly
- AVOID: community-style meme talk; aggressive slang
- Profanity: low tolerance; frustration expressed through understatement

## Preset: 맘카페 (Mom Cafe)

- profile_mode: preset_approximation
- source_scope: Mom-cafe (줌마체) posts, general cafe culture — not one specific cafe
- sample_count: 0
- observed_contexts: parenting questions, daily-life stories, product recommendations
- valid_at: 2026-09
- unsupported_contexts: cafe-specific slang, other demographics
- Basis: research claims C7

- MUST: ~네요 as the near-default ending; 따뜻한 tone with 관용적 어미 연장
- MUST: signature spellings and pet names (넘흐, 딸램, 잇님, 횐님) and affectionate in-group interjections (푸힛, 이궁)
- MUST: punctuation habits — trailing `..`, wavy `~`, `^^` after greetings
- PREFER: euphemistic and elongated expressions even for harsh requests; gentle closings (총총)
- PREFER: child/personification framing ("그 아이" style referents)
- AVOID: blunt imperatives; dry formal narration
- Profanity: near-zero tolerance; anger is expressed by lengthening words, not by slurs

## Preset: 스레드 (Threads Korea)

- profile_mode: preset_approximation
- source_scope: Korean Threads feed culture — not a specific subcommunity
- sample_count: 0
- observed_contexts: short-form daily posts, reply threads
- valid_at: 2026-09
- unsupported_contexts: fandom subcommunity slang in full, other platforms
- Basis: research claims C8; slang list is partial and fast-moving

- MUST: 반말 fixed regardless of reader age; chatty short sentences
- MUST: `스-` prefixed coinages (스팔, 스하리, 스린이, 스인물 style) as the native slang family — 미검증 beyond listed examples
- PREFER: strong in-group solidarity marks; mirror the addressee's register (존댓말 gets 존댓말 back)
- PREFER: daily-life and self-employment, politics as common topics
- AVOID: formal narration; board-style formatting (titles, structured sections)
- Profanity: mild slang common (PREFER); intensity via casualness, not aggression

## Sources

> No external sources were used. Content checked 2026-09-21.

Every preset is this package's own `preset_approximation` summary. The `Basis:` labels (C2-C8, U1) name claims from the research run that produced these presets; that run's ledger is not shipped with this package, so no external page or publication is cited or re-checked here. Where the research could not confirm a detail, the preset says 미검증 instead of naming a source, and `valid_at` is the observation basis rather than a citation.
