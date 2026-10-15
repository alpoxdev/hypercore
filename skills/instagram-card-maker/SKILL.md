---
name: instagram-card-maker
description: Use this skill when the user wants an Instagram carousel or card-news post built as a set of same-size images plus a Korean caption. A topic or brand brief goes in; an editable HTML composer, ordered card images, caption text, per-card alt text, a source ledger, and a manifest come out. Covers research-grounded card narration, photo and Korean text composed as separate layers, photo-background-only blur, left-bottom title and hook placement, and a WAI contrast check used as a design benchmark. Not for publishing, scheduling, or API upload; not for other platforms, single-image editing, or prose-only requests.
compatibility: Self-contained Markdown skill plus one dependency-free HTML asset. Web search and page fetch are used for topic research. The card composer runs in a browser with Canvas and File APIs; no login, no network call, no auto-publishing, no bundled font binary.
---

# Instagram Card Maker

> Turn one topic or brand brief into a research-grounded card-news carousel: an editable composer, a set of same-size card images in posting order, and the Korean caption that carries them.

<output_language>

Write every user-facing deliverable — the card titles and body, the caption, the alt text, the source ledger, and the completion note — in Korean. Keep product names, URLs, commands, file paths, quoted source text, JSON keys, and code identifiers in their original form. Use another language only when the user asks for it. Code, JSON, and file names stay in their original form regardless of the delivery language.

</output_language>

<purpose>

- Start from a topic, a brand, or a brief: research the subject and the reader's question first, then compose. Do not demand a fact pack from the user before the research step.
- Ground every card claim in a source with a URL and an accessed date. A first-hand claim, a price, a result, or a brand line comes only from the user; a gap becomes an explicit slot instead of an invented fact.
- Compose the carousel as a sequence where each card carries one idea and the order builds the argument. The hook and title sit at the left-bottom of the card; the photo and the text are separate layers so the Korean stays crisp.
- Blur only the photo background, and only subtly. Keep the title, the body, and any supplied logo sharp, and place a dark scrim or a solid text area behind the text so contrast does not depend on the photo.
- Deliver an HTML composer with an editable JSON input, a live gallery, per-card PNG export, and a machine-readable API an agent can call to read the exported images without a human clicking save.
- Deliver the sidecars beside the images: the post's single `caption.txt`, `alt-text.json` matching count and order, `sources.md`, and `manifest.json`.
- Label a generated photo as an illustration and keep its provenance; never present a generated image as a real site, product, receipt, certificate, or result.

</purpose>

<routing_rule>

Use `instagram-card-maker` when the deliverable is an Instagram carousel or card-news set — several same-size images plus a caption — and the user cares about a legible Korean result and a repeatable composer.

Do not activate when:

- the platform is not Instagram and the user names another channel — out of scope
- the user wants a single image edited, retouched, or converted — out of scope
- the user wants text polished or a blog post written with no card set as the deliverable — out of scope
- the user wants the post published, scheduled, or uploaded through the API — refuse the automation part (see `<forbidden>`) and deliver the images and caption for a manual post

This skill is self-contained. It owns the card contract, the composer asset, the caption and alt rules, and the validation loop. It never depends on another skill being installed and never names one.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | After intake, deliver an HTML composer with an embedded document, ordered card PNG images, `caption.txt`, `alt-text.json`, `sources.md`, and `manifest.json` under `.hyper/instagram-card-maker/<slug>/`. |
| Scope | Card content, card layout, caption, alt text, and the composer asset. No login, no publishing, no scheduling, no API upload, no other platform. |
| Authority | User request and repository instructions > the researched source ledger > this package's defaults (4:5, left-bottom title, photo-background-only blur, WAI contrast benchmark) > any third-party sizing guide. |
| Evidence | Every factual card claim traces to a source with `URL | accessed date` in `sources.md`. First-hand experience, prices paid, results, and brand lines come only from the user; gaps become slots. A generated photo is marked `generated` in `manifest.json` and named as an illustration. |
| Tools | Web search and page fetch for topic research. A browser with Canvas and File APIs to run and export the composer. Native image generation only when the environment exposes it and the user wants a photo that does not exist. Nothing else touches Instagram; no login, no scraping. |
| Loop | Compose → run the composer's own validation and the `validation` checklist → fix hard failures; at most two revision rounds, then deliver with remaining items named. The composer refuses to export while a validation error stands. |
| Output | Korean: card titles and body, caption, alt text, source ledger, completion note. Machine-readable: `manifest.json`, `alt-text.json`, and the `window.cardStudio` API result. |
| Verification | The composer's export contract (`window.cardStudio.exportCards()`) plus the `validation` checklist. On a package change, the corpus validator, the authoring validator with `--require-self-containment`, and `bun run --cwd scripts verify`. |
| Stop condition | Ask the intake items once, then work without re-asking. Deliver after checks pass; stop and name the missing sources when a required fact cannot be grounded. Never publish or schedule. |

</instruction_contract>

<activation_examples>

Positive:

- "우리 카페 신메뉴 소개로 인스타 카드뉴스 6장 만들어줘. 캡션도."
- "이 주제로 인스타그램 캐러셀 카드뉴스 만들어줘. 4:5로, 사진은 배경만 살짝 흐리게."
- "브랜드 로고 넣고 카드뉴스 5장 + 한국어 캡션 뽑아줘. 사진은 생성해도 돼."
- "Build an Instagram carousel card set (1080x1350) for a skin-care brand, with a Korean caption."
- "이 원고를 카드뉴스로 쪼개서 이미지까지 내보내줘."

Negative:

- "인스타그램에 자동으로 예약 발행해줘." → out of scope (automation; deliver images and caption for a manual post)
- "이 사진 한 장 보정해줘." → out of scope (single-image edit)
- "이 글 번역투만 고쳐줘." → out of scope (prose polish, no card set)
- "유튜브 썸네일 만들어줘." → out of scope (other platform)

Boundary:

- "카드뉴스 만들어줘." — ask which platform and the format; activate only when it is Instagram.
- "카드뉴스 30장 만들어줘." — activate; the app carousel holds at most 20 items, so plan within that and say so.
- "로고는 내가 준 파일 그대로 써줘." — activate; the supplied logo is placed as-is and never redrawn or restyled.
- "사진은 생성해도 되는데 실제 매장 사진처럼 보이게 해줘." — activate; a generated photo is labeled an illustration and never presented as a real site.

</activation_examples>

<trigger_conditions>

Activate when the request names an Instagram carousel, a card-news set, or a multi-card image series plus a caption, and the deliverable is images the user can post. Also activate when the user supplies a topic, a brand, or a draft and asks for the card images and caption.

Do not activate for a non-Instagram platform, a single-image edit, a prose-only request, or a publish/schedule/upload request; handle those as the `routing_rule` states.

</trigger_conditions>

<skill_architecture>

| Part | Role | Load condition |
|---|---|---|
| `SKILL.md` | Trigger, contract, workflow, safety, validation | Always |
| `rules/workflow.md` | The end-to-end run: intake, research, compose, export, deliver | Before starting a run |
| `rules/legibility-and-typography.md` | Korean font strategy, contrast, wrapping, overflow | Before composing cards |
| `rules/validation.md` | The pre-delivery checklist and failure handling | Before delivery and on a package change |
| `references/output-contract.md` | Input schema, output layout, `window.cardStudio` API, error codes | Before building or calling the composer |
| `references/platform-specs.md` | App vs API image specs, format presets, contrast benchmark | Before choosing a format |
| `references/card-composition.md` | Card narrative, layers, blur, scrim, left-bottom placement | While composing cards |
| `references/caption-and-alt.md` | Korean caption and alt-text rules, sidecar format | While writing the caption and alt |
| `references/photo-sourcing.md` | Photo provenance, generated-photo labeling, logo handling | While sourcing photos |
| `assets/card-studio.html` | The composer: editable JSON, gallery, PNG export, API | To compose and export the cards |

</skill_architecture>

<loop_policy>

The run has one bounded loop: compose, run the composer's validation and the `validation` checklist, fix hard failures, and repeat at most twice. The feedback source is a `render` rejection (which sets `#status[data-error="true"]` and blocks `exportCards`) plus the checklist. The stop condition is a resolved `render` with every card exported, or two rounds passed with the remaining items named. There is no unbounded improvement loop and no self-grading-only loop.

</loop_policy>

<language_and_translation_default>

Deliver in Korean by default: card text, caption, alt text, source ledger, and the completion note. Keep JSON keys, error codes, file names, URLs, and code identifiers in their original form. Use another language only when the user asks. The package's Markdown is maintained as English/Korean pairs; read only one language version per run.

</language_and_translation_default>

<reference_routing>

- Before building or calling the composer, or when the input shape is unclear, read `references/output-contract.md`.
- Before choosing a format or defending a size, read `references/platform-specs.md`.
- While composing cards, read `references/card-composition.md`.
- While writing the caption and alt text, read `references/caption-and-alt.md`.
- While sourcing photos or handling a supplied logo, read `references/photo-sourcing.md`.
- Before starting a run, read `rules/workflow.md`.
- Before composing cards, read `rules/legibility-and-typography.md`.
- Before delivery and whenever this package changes, read `rules/validation.md`.

</reference_routing>

<support_file_read_order>

Read only one language version per run. Paths are relative to this installed skill directory, never a hard-coded checkout or plugin cache. File reads are explicit actions, not automatic includes.

1. Read `rules/workflow.md` before starting the run.
2. Read `references/platform-specs.md` before choosing a format.
3. Read `references/output-contract.md` before building or calling the composer.
4. Read `references/card-composition.md` while composing cards.
5. Read `rules/legibility-and-typography.md` while composing cards.
6. Read `references/caption-and-alt.md` while writing the caption and alt text.
7. Read `references/photo-sourcing.md` while sourcing photos.
8. Read `rules/validation.md` before delivery and whenever this package changes.
9. Use `assets/card-studio.html` to compose and export; use `assets/evals/instagram-card-maker-cases.jsonl` when changing trigger, workflow, or output behavior.

</support_file_read_order>

<workflow>

| Step | Work | Output |
|---|---|---|
| 0. Intake | Confirm the topic, the brand and its relationship to the user (own brand / sponsored / none), the reader and goal, the photo source (supplied / generated / none), whether a logo is supplied, the format, and optional tone — asking together only the items the brief left open. | Confirmed brief |
| 1. Research | Run `rules/workflow.md` §1: query candidates, sourced facts with URL and date, the reader question per card, and photo slots. | Fact pack |
| 2. Plan | Choose the card count (2–20) and format. Order ideas as hook, sourced explanation, relevant caveat, and next step; combine roles in short sets and allocate cards to the content. | Card plan |
| 3. Compose | Build the input document per `references/output-contract.md`; compose each card per `references/card-composition.md` and `rules/legibility-and-typography.md`. When a card needs a photo that does not exist and the environment exposes an image tool, generate the photo, record it as generated, then compose the text over it as a separate layer. | Input JSON |
| 4. Export | Open `assets/card-studio.html`, load the document, run the composer's validation, and export the PNGs through the API. A `render` rejection sets `#status[data-error="true"]` and blocks `exportCards`; fix the cause before exporting. | Card PNGs |
| 5. Caption and alt | Write the Korean caption and per-card alt text per `references/caption-and-alt.md`; keep count and order matching the cards. | `caption.txt`, `alt-text.json` |
| 6. Check | Run the `validation` checklist and the composer's validation; fix hard failures (≤ 2 rounds). | Checked set |
| 7. Deliver | Write `index.html`, `cards/NN.png`, `caption.txt`, `alt-text.json`, `sources.md`, `manifest.json` under `.hyper/instagram-card-maker/<slug>/`. | Korean deliverable |

A supplied draft or an existing card set replaces steps 1–2: record its structure and anchors, then run steps 3–7.

</workflow>

<required>

- Ask the intake items in one message and await the reply before research; do not repeat answered items, and do not demand a fact pack.
- After intake, research from the topic without requiring the user to supply facts; missing optional brand details become slots.
- Ground every factual card claim in a source with `URL | accessed date`; mark a first-hand claim, a price, or a result that only the user can know as a slot.
- Choose the format from `references/platform-specs.md` and state it; the default is 1080×1350 (4:5), and 1080×1440 (3:4, app-only) or 1080×1080 (1:1) only when the user asks or the evidence supports it.
- Keep the title and the hook at the left-bottom of the card; keep the photo and the text as separate layers.
- Blur only the photo background, and subtly; keep the text and any supplied logo sharp, and place a scrim or a solid text area so contrast does not depend on the photo.
- Place a supplied logo exactly as supplied and never redraw, recolor, or restyle it.
- Build the input document per `references/output-contract.md` and validate before export: reject empty, one-card, or over-20-card sets, unsupported dimensions, missing or broken images, and text that overflows its card.
- Export real PNG files at the chosen size, one per card, in posting order, through `window.cardStudio.exportCards()`.
- Write the post's single `caption.txt` and `alt-text.json` matching the card count and order.
- Record each photo's provenance in `manifest.json` and `sources.md`, and label a generated photo as an illustration.
- Embed every image and any font data as data URIs inside `index.html`; add no remote script and no network dependency.
- When a required image, fact, or export is still missing after the revision limit, report an incomplete draft and the exact blocker; do not label the set ready to post.

</required>

<forbidden>

- Naming, requiring, or reading another skill, or depending on any path outside this package.
- Publishing, scheduling, uploading, or calling the Instagram API; logging in; scraping.
- Inventing experience, statistics, quotes, prices, credentials, or sources — gaps become slots, never filled.
- Presenting a generated photo as a real site, product, place, receipt, certificate, result, or before/after photo.
- Redrawing, recoloring, cropping into, or restyling a supplied logo.
- Blurring the whole card, or blurring the text, the title, or the logo.
- Calling 4:5 the only Instagram format, or presenting a heuristic (blur amount, margin, title position, card count) as a platform rule.
- A silent shrink, truncate, ellipsis, or overflow of card text to make it fit; the composer fails instead.
- Shipping a font binary; use the system Korean sans fallback with an explicit glyph check, and embed font data only when the environment already provides it.
- Interpolating user text as HTML; use `textContent` and escape every value.
- Delivering only a gradient placeholder when a photo was required, or claiming a photo was generated when it was not.
- A `null`, `"N/A"`, or brace placeholder filling a field that carries no meaning; omit the field instead.
- Hard-coding a provider, model, quality, tier, or resolution flag, or a tool name, in the skill contract or the composer.

</forbidden>

<runtime_fallback>

If the composer asset cannot be opened, or the environment has no browser with Canvas and File APIs, do not claim the images were exported. Execute the minimum contract and disclose the skipped step.

1. Ask the intake items in one message and await the reply. Reuse supplied answers.
2. Research from the topic; without search, use supplied evidence only and disclose unverified research and freshness. Mark gaps as slots.
3. Plan the card count (2–20), the format preset, and the card order.
4. Produce the input document per `references/output-contract.md` as JSON, and produce the card text and caption so a browser session can export later.
5. If no export is possible, deliver the input JSON, the caption, the alt text, and a one-line note that the PNG export still needs a browser. Never report PNGs that were not produced.
6. Label generated photos as illustrations and keep the provenance fields.

</runtime_fallback>

<validation>

- [ ] Intake answered and delivery matches the chosen format; the format is stated and is 4:5 by default unless the user asked otherwise.
- [ ] Research ran when the brief lacked facts: sourced facts with URL and date, a reader question per card, and no fabricated experience.
- [ ] Card count is 2–20; the composer rejected any empty, one-card, or over-20-card set before export.
- [ ] Every card keeps the title and hook at the left-bottom; the photo and text are separate layers; the logo (if supplied) is unchanged.
- [ ] Only the photo background is blurred, and subtly; a scrim or solid text area keeps the text contrast independent of the photo.
- [ ] `render` resolved and `#status[data-error]` is not `true` at export; no silent shrink, truncate, or overflow occurred.
- [ ] Real PNGs exist at the chosen size, one per card, in posting order.
- [ ] `caption.txt` holds the post's single caption; `alt-text.json` matches the card count and order.
- [ ] Every photo's provenance is recorded, and each generated photo is labeled an illustration.
- [ ] `index.html` embeds all images and any font data as data URIs, with no remote script and no network dependency.
- [ ] No other skill is named, required, or read; no publish, schedule, or upload path is used.
- [ ] Package change only: KO/EN parity holds, the corpus validator and the authoring validator with `--require-self-containment` pass, and `bun run --cwd scripts verify` passes; the README count and catalog row are updated when this change adds a skill.

</validation>

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own contract. Platform sizing and contrast claims live in `references/platform-specs.md`, where each carries its source and accessed date.
