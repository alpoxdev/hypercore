# Validation

> Korean version: [`validation.ko.md`](validation.ko.md)

**Purpose**: The self-check run on every draft before delivery, and the package checks run when this skill changes. Each item is something a model can count or see; no scoring, no scripts.

## 1. Draft checklist

### Hard rules (any failure blocks delivery)

- [ ] **One intent, one lane.** The post answers a single named query slice and the topic fits the author's blog lane recorded at intake. (R1)
- [ ] **Evidence in every section.** Each section has at least one checkable circumstance (date, place, duration, price basis, quantity, condition) or a cited source; at least one section names a downside, exception, or failure. (R2)
- [ ] **Decision-complete action layer.** When the intent or the title asks what to do, what to choose, how often, how much, how long, or at what price, the action layer exists: a criterion ≥ 1 · every source-backed option in the fact pack · the operating number that applies · the condition that flips the advice ≥ 1 · exactly one next step. The type is stated in the decision line and the body follows that type's skeleton, with at most one secondary type.
- [ ] **Actionable decision data.** When the verified, distinct quantitative fields in the fact pack are two or more, the action layer uses at least two of them. When only one is verified, it uses that one and names the unresolved fields in the publish note. No number is invented and no sentence is lengthened to reach a count. **This is this skill's own completeness rule, not a Naver rule.**
- [ ] **Regulated-number traceability.** Every quantitative claim in a regulated topic traces to a first-party row whose `source_role` is `quantitative_authority` (URL, date, and `claim_scope` present). A `supporting_context` source such as a peer-reviewed review is never the sole basis for a number. A `source-required` slot is a publish blocker, not evidence. Medical topics also pass the boundary gate in `../references/regulated-topic-research.md` §7-§8.
- [ ] **No facts hidden in images.** Every key number, price, condition, or step exists as body text. Nothing the reader needs is carried only by an image.

- [ ] **Type declared and followed.** The post type is stated in the decision line and the body follows that type's skeleton, with at most one secondary type.
- [ ] **No inserted keywords.** The target query appears in the title once and in the body only where the sentence needs it. Read the body aloud: no repetition a reader would notice; no hidden or unrelated keywords; hashtags ≤ 7 and all precise. (R3)
- [ ] **Title promise kept.** The specific answer or finding the title implies is present in the first 3-5 sentences. No concealment words (`이것`, `비밀`, `충격`), no invented statistic, no fake deadline. (R4)
- [ ] **Original only.** No supplied vendor copy, no template block that appears in another post, no image marker that points at another post's photo set. (R5)
- [ ] **Disclosure and links.** 전환형 or any sponsored/affiliate relationship is disclosed in the first paragraph in plain words; every external link says where it goes. (R6)
- [ ] **Research ran, nothing fabricated.** When the brief lacked facts, the fact pack lists sourced facts (`URL | 날짜`) and a top-3 gap analysis; every first-hand claim the author did not supply is a `[확인 필요: …]` slot with an example, not a sentence.
- [ ] **Inline image markers.** A cover marker after the title and one `[이미지: 무엇을 찍을지 | 캡션]` per photo-provable claim, at their positions in the body; no stock, screenshot, or reused-set proposals.
- [ ] **Chosen format.** Intake answered. Plain uses one text fence; rich separates title/tags from body HTML. Check HTML clipboard requirements, HTTPS images, table spans; exclude data:image, scripts, event handlers.
- [ ] **One human-reviewed draft.** Exactly one post; no variants for batch publishing; `[확인 필요]` markers left wherever a fact was missing rather than filled in. (R7)
- [ ] **Brand facts verbatim.** 전환형: every 가치입증 line matches the user's input character for character; no added credentials, counts, awards, or prices.
- [ ] **No manufactured engagement.** No comment/like/subscribe bait, no reciprocal-neighbor call, no length added "for dwell time". (R9)
- [ ] **Prose self-check passed.** Zero S1 hits under `human-prose.md` §5; one register throughout; no `첫째/둘째/셋째` scaffolding, `결론적으로`, `도움이 되셨다면 공감과 댓글`, `지금 바로`; no markdown `**`/`#` in the deliverable body.
- [ ] **Voice matched.** Endings, sentence length, lexis, and ornament habit match the settled voice card, card-forbidden lexis appears 0 times, and any tone request the floor rejected is recorded in the publish note ([`tone-manner.md`](tone-manner.md) §4, §5). A tone that replaced the genre row's register is not a failure.
- [ ] **Tell catalogue walked.** `references/tell-catalog.md` was checked family by family against the draft before delivery: S1 items removed wherever they appeared, and S2 or S3 edits confined to the families the dominant-pattern diagnosis named.

### Generated visual brief (any failure blocks delivery)

- [ ] Every `이미지 생성` marker has exactly one JSON object whose `id` matches that marker, and no object exists without a marker; each object arrives in a fence tagged `json`, never a bare untagged fence.
- [ ] Each object's `section_role` is one of the 14 roles, and its `template` is a template ID from that role's row in `references/image-prompt-templates.md` §2.
- [ ] All 14 always-fields are present, and each conditional field appears only where it carries meaning: an inapplicable field is absent, never `null`, `"N/A"`, `"없음"`, `"위와 동일"`, or a placeholder.
- [ ] Each rendered string appears exactly once inside `text[]`, and `prompt` carries every one of them byte-identical; nothing is translated, corrected, or shortened, no label is listed twice inside `text[]`, and `prompt` carries every string verbatim.
- [ ] Where two or more images form one intended series, its invariants repeat identically in every object of that series, and no object says "same as above."
- [ ] A supplied reference is marked as `inspiration` or `edit_source`, and an editing brief names the source, the preserved elements, and the allowed changes.
- [ ] No object carries a provider, model, quality, or resolution flag, and none borrows a living artist, a real person, or a trademark as a style shortcut.
- [ ] No generated image stands in for a real site, place, receipt, 견적서, instrument reading, result, certificate, or before/after photo, and no generated map depicts real geography.
- [ ] `prompt` restates the structured fields only and introduces no fact, brand, person, number, or parameter beyond them.

### Planning defaults (report, do not block)

- [ ] Body length is within roughly 1,500-3,000 characters or the deviation is explained by the intent (a short how-to may be shorter).
- [ ] Follow `image-slots.md` §1 density without padding; distinguish real evidence from illustrations and match generation markers to JSON ids one-to-one.
- [ ] Title 20-35 characters, target query in the front half, no emoji.
- [ ] Paragraphs 1-3 sentences; subheadings only at real navigation points (usually 3-6).
- [ ] Ornament: within the chosen row's per-post ceilings in `human-prose.md` §4.

### Delivery shape

- [ ] **Body rhythm contract passed** (`post-workflow.md` §3): text blocks 1-5 lines with 12-25-character explicit breaks; paragraph blocks 1-3 sentences; at most 2 text blocks consecutively, with an image/quote/table or a visible gap between blocks; rich body paragraphs center-aligned with `line-height:1.8` inline and blank-paragraph spacers (no `p` `margin`).
- [ ] Rich files include a formatted-copy button selecting only #sample; title/tags/prompts stay outside; blocked copy reports manual instructions.

- [ ] Titles → chosen-format body → generation JSON → keyword → slots → publish note.
- [ ] No rule IDs, tier labels, or rubric text in the user-facing output.

### Repair path (only when the user supplied the post)

- [ ] Anchors were recorded before the first edit and re-verified after: facts, numbers, dates, names, prices, durations, quotations, source citations, image markers, `[확인 필요]` slots, the disclosure line, brand lines, the single CTA, hashtags, headings, list and table shapes (`repair-method.md` §2).
- [ ] The diagnosis names three to six families with a quoted example each, and edits stay inside them plus located S1 items.
- [ ] Register is unchanged in both directions; contractions, asides, questions, and direct address survive.
- [ ] The over-correction guard passed, including the new-tell S1 scan on the repaired text.
- [ ] Uncertain edits were rolled back rather than pushed through.
- [ ] Deliver repairs in the chosen format; keep the change summary outside the body.

## 2. Package checklist (when this skill changes)

- [ ] `name` in frontmatter is `naver-blog-maker` and matches the folder.
- [ ] `description` states when to use and when not to; at least 3 positive, 2 negative, 1 boundary activation examples exist in `SKILL.md`.
- [ ] Every rule and reference file has a `*.ko.md` mirror with the same section structure; both languages of a file change together.
- [ ] Every claim that names Naver behavior traces to an `official` row in `references/naver-algorithm-timeline.md`; observed and folklore items are labeled as such.
- [ ] Local links resolve; code fences are balanced.
- [ ] `assets/evals/naver-blog-maker-cases.jsonl` covers positive, negative, boundary, regression, and adversarial cases and matches the current trigger and workflow.
- [ ] Repository maintenance only (not a runtime dependency): the corpus validator scoped to this package (`validate-skills-corpus.mjs --root skills --only naver-blog-maker --json`) passes.
- [ ] `bun run --cwd scripts verify` passes.
- [ ] When this change adds a skill, or changes a skill's name or catalog exposure, `README.md`'s skill count and catalog row are updated; otherwise confirm `README.md` is unchanged.

## Sources

> No external sources; content checked 2026-09-21.

This file states this package's own draft and package checklists. Every Naver-behavior item it carries traces to an `official` row in [`../references/naver-algorithm-timeline.md`](../references/naver-algorithm-timeline.md); no external source of its own is cited.
