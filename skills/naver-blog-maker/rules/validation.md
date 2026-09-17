# Validation

> Korean version: [`validation.ko.md`](validation.ko.md)

**Purpose**: The self-check run on every draft before delivery, and the package checks run when this skill changes. Each item is something a model can count or see; no scoring, no scripts.

## 1. Draft checklist

### Hard rules (any failure blocks delivery)

- [ ] **One intent, one lane.** The post answers a single named query slice and the topic fits the author's blog lane recorded at intake. (R1)
- [ ] **Evidence in every section.** Each section has at least one checkable circumstance (date, place, duration, price basis, quantity, condition) or a cited source; at least one section names a downside, exception, or failure. (R2)
- [ ] **No inserted keywords.** The target query appears in the title once and in the body only where the sentence needs it. Read the body aloud: no repetition a reader would notice; no hidden or unrelated keywords; hashtags ≤ 7 and all precise. (R3)
- [ ] **Title promise kept.** The specific answer or finding the title implies is present in the first 3-5 sentences. No concealment words (`이것`, `비밀`, `충격`), no invented statistic, no fake deadline. (R4)
- [ ] **Original only.** No supplied vendor copy, no template block that appears in another post, no image marker that points at another post's photo set. (R5)
- [ ] **Disclosure and links.** 전환형 or any sponsored/affiliate relationship is disclosed in the first paragraph in plain words; every external link says where it goes. (R6)
- [ ] **Research ran, nothing fabricated.** When the brief lacked facts, the fact pack lists sourced facts (`URL | 날짜`) and a top-3 gap analysis; every first-hand claim the author did not supply is a `[확인 필요: …]` slot with an example, not a sentence.
- [ ] **Inline image markers.** A cover marker after the title and one `[이미지: 무엇을 찍을지 | 캡션]` per photo-provable claim, at their positions in the body; no stock, screenshot, or reused-set proposals.
- [ ] **Text block delivery.** The post is one fenced `text` block: title first line, hashtags last line, plain text only (no `#`, `**`, list syntax), all markers inside it.
- [ ] **One human-reviewed draft.** Exactly one post; no variants for batch publishing; `[확인 필요]` markers left wherever a fact was missing rather than filled in. (R7)
- [ ] **Brand facts verbatim.** 전환형: every 가치입증 line matches the user's input character for character; no added credentials, counts, awards, or prices.
- [ ] **No manufactured engagement.** No comment/like/subscribe bait, no reciprocal-neighbor call, no length added "for dwell time". (R9)
- [ ] **Prose self-check passed.** Zero S1 hits under `human-prose.md` §5; one register throughout; no `첫째/둘째/셋째` scaffolding, `결론적으로`, `도움이 되셨다면 공감과 댓글`, `지금 바로`; no markdown `**`/`#` in the deliverable body.

### Planning defaults (report, do not block)

- [ ] Body length is within roughly 1,500-3,000 characters or the deviation is explained by the intent (a short how-to may be shorter).
- [ ] Image markers: 5-12 for a standard post (one per step for a how-to); each caption states a fact, not a label.
- [ ] Title 20-35 characters, target query in the front half, no emoji.
- [ ] Paragraphs 1-3 sentences; subheadings only at real navigation points (usually 3-6).
- [ ] Ornament: within the chosen row's per-post ceilings in `human-prose.md` §4.

### Delivery shape

- [ ] Three title candidates with one recommended; the fenced `text` block; one-line keyword decision; slot list; publish note (mode, editor topic, disclosure, links, research URLs; length note only when outside the default).
- [ ] No rule IDs, tier labels, or rubric text in the user-facing output.

## 2. Package checklist (when this skill changes)

- [ ] `name` in frontmatter is `naver-blog-maker` and matches the folder.
- [ ] `description` states when to use and when not to; at least 3 positive, 2 negative, 1 boundary activation examples exist in `SKILL.md`.
- [ ] Every rule and reference file has a `*.ko.md` mirror with the same section structure; both languages of a file change together.
- [ ] Every claim that names Naver behavior traces to an `official` row in `references/naver-algorithm-timeline.md`; observed and folklore items are labeled as such.
- [ ] Local links resolve; code fences are balanced.
- [ ] `assets/evals/naver-blog-maker-cases.jsonl` covers positive, negative, boundary, regression, and adversarial cases and matches the current trigger and workflow.
- [ ] Repository maintenance only (not a runtime dependency): `node skills/skill-tester/scripts/validate-skills-corpus.mjs --root skills --only naver-blog-maker --json` passes.
- [ ] `bun run --cwd scripts verify` passes.
- [ ] `README.md` skill count and catalog row are updated.
