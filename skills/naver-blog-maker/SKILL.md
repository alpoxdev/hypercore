---
name: naver-blog-maker
description: "[Hyper] Write or revise one Naver blog post: confirm blog URL, the post's goal, the brand relationship, and plain/rich format first, then pick a post type, research a keyword, draft natural Korean with a decision layer that carries sourced operating numbers, place real-image slots and copy-ready image prompt JSON, and deliver plain text or body HTML. Use for Naver blog drafts, reviews, guides, and business posts; not other platforms, API-only requests, or automatic publishing."
compatibility: Self-contained Markdown skill; needs only web search and page fetch for topic research. Browser tooling for live SERP inspection is optional. No login, scraping, or auto-publishing.
---

# Naver Blog Maker

> Write one Naver blog post that Naver's current systems can surface, that a searcher clicks and finishes, and that a reader takes for a person's own writing.

<output_language>

Default every user-facing deliverable — title candidates, the post block with its image and slot markers, hashtags, notes, and self-check summaries — to Korean. Preserve product names, URLs, commands, file paths, and quoted source text in their original form. Use another language only when the user asks; that request usually means a different skill.

</output_language>

<purpose>

- Start from a keyword: research the query, the top-ranked posts' gaps, and sourced facts, then draft — without asking the user for a fact pack first.
- Produce a post that follows Naver's published rules (source topic lane, document experience and originality, intent-slice fit, no inserted keywords, no deceptive titles or links, disclosure) and never trips an official restriction.
- Place image slots inline where each photo must appear, naming what to shoot and what the caption proves; mark what only the author can know as `[확인 필요]` slots instead of inventing it.
- Deliver the chosen format: a text block for plain, or body HTML with separate title and tags for rich.
- Hook with a specific promise in the title and keep it within the first screen, using the adapted pattern library instead of clickbait vocabulary.
- Draft under the embedded prose rules in `rules/human-prose.md`, and in the voice this run settled on (the user's own tone text, then the blog read, then the type's default — `rules/tone-manner.md`), so the text has no machine-written texture from the start.
- Separate what Naver said (`official`) from what practitioners observe (`observed`) and from folklore, and say which is which when the user asks for a "rule".
- Support two modes: 정보/경험형 for ranking-and-reading posts without a brand, and 전환형 for posts that must generate inquiries or visits for a named brand using the user's own 가치입증 facts. The mode is derived from the brand relationship and the post's goal, never asked as a separate question.
- Pick the post type before outlining: classify the customer intent, the post format, and the business goal, choose one primary type (at most one secondary) from `references/post-type-library.md`, and record the choice in the decision line. The type shapes the section order and never replaces the single intent slice.
- Carry a decision layer whenever the intent asks what to do, what to choose, how often, how much, how long, or at what price: a sourced criterion, the sourced options, the operating numbers, the condition that flips the advice, and exactly one next step — and never a number the sources do not support.
- Treat a regulated number as sourced only when a first-party source issues it. In medical work read `references/regulated-topic-research.md` for the grade and role split, the claim scope, and the advertising boundary.
- Repair a Naver post the user already wrote: keep its register and its content anchors and remove the machine-written texture under `rules/repair-method.md`, instead of rewriting the post.
- Deepen the prose pass by walking `references/tell-catalog.md`, the individual patterns behind the family table, each with a bad-to-good pair and the W-ID that removes it.
- Give every generated image a portable complete visual brief: a section role and template, a first → second → background hierarchy, colour roles, material and rendering, exact rendered text, series invariants, and inspection checks — delivered with a paste-ready natural-language prompt beside the structured object.

</purpose>

<routing_rule>

Use `naver-blog-maker` when the deliverable is a Naver blog post (or its title/outline/rework) and the user cares about exposure in Naver search or the Naver app.

Do not activate when:

- the target is Google, a company website, or a technical SEO audit — out of scope
- the user wants only raw Naver data (search counts, DataLab trends) with no post — out of scope
- the user supplies Korean text to polish with no Naver post as the deliverable — out of scope
- the platform is Tistory, WordPress, Brunch, or a newsletter — out of scope
- the user wants a batch of posts, scheduled auto-publishing, or comment/neighbor automation — refuse the automation part (see `<forbidden>`) and offer one reviewed draft

A Naver post the user already wrote is in scope: that brief opens the repair path in `rules/repair-method.md` rather than the compose path, and never the reverse.

This skill is self-contained: it owns the post structure, the Naver rules, and the sentence-level naturalness rules (`rules/human-prose.md`). It never depends on another skill being installed.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | After intake, deliver one post, title candidates, inline image slots and generation JSON, the chosen body format, and keyword/slot/publish notes. |
| Scope | Post content and structure only. No login, no publishing, no engagement actions, no scraping. |
| Authority | User request and repository instructions > `rules/naver-ranking-contract.md` (official rows) > `observed` defaults > user-supplied prompt templates > any third-party SEO guide. |
| Evidence | Every Naver-behavior claim traces to an `official` row in `references/naver-algorithm-timeline.md` (mapped in `references/evidence-digest.md`); observed and folklore items are labeled. Informational facts come from research with `URL | 날짜`; first-hand experience, results, prices paid, and brand lines come only from the user; gaps become `[확인 필요]`. |
| Tools | Web search and page fetch for topic research; optional browser tooling for live SERP inspection; public Naver pages (DataLab, 통합검색) read as a visitor. Nothing else touches Naver; no login, no scraping. |
| Loop | Draft → `rules/validation.md` self-check → fix hard-rule failures; at most two revision rounds, then deliver with remaining items named. |
| Output | Korean: titles → chosen-format body → generation JSON → keyword → slots → publish note. Keep rich title/tags separate from body HTML. |
| Verification | Draft checklist in `rules/validation.md`; package checklist when the skill changes (corpus validator, `bun run --cwd scripts verify`, KO/EN parity, README catalog only when this change adds a skill or changes a skill's name or catalog exposure; otherwise confirm `README.md` is unchanged). |
| Stop condition | Await intake answers before work. Deliver after checks pass; stop and name missing required sources for regulated topics. No batch or auto-publishing. |

</instruction_contract>

<activation_examples>

Positive:

- "누수 탐지 비용으로 네이버 블로그 글 하나 써줘." (keyword only — research fills the rest)
- "강남 임플란트 가격 비교 주제로 네이버 블로그 글 써줘, 상위노출 되게."
- "우리 누수탐지 업체 문의 늘리는 네이버 블로그 포스팅 써줘. 브랜드명은 ○○, 가치입증은 이거야."
- "제주 3박4일 여행 후기를 네이버 블로그에 올릴 건데 사람이 쓴 것처럼 써줘."
- "Write a Naver blog post about a 에어프라이어 review that can rank in Naver search."
- "이 네이버 블로그 글 제목이랑 서두만 다시 잡아줘, 낚시 같지 않게."
- "이미 쓴 네이버 블로그 글인데 AI 티가 나. 사람이 쓴 것처럼 다듬어줘. (글 전문 붙여넣음)" (repair path — anchors recorded, register kept)

Negative:

- "우리 회사 홈페이지 SEO 점검해줘." → out of scope (website SEO)
- "네이버 데이터랩에서 두 키워드 추이만 뽑아줘." → out of scope (data only, no post)
- "이 글 번역투만 고쳐줘." (no Naver post) → out of scope (prose polishing only)
- "티스토리에 올릴 애드센스 글 써줘." → out of scope

Boundary:

- "블로그 글 하나 써줘." — ask which platform; activate only when it is Naver.
- "네이버 블로그 글 50개 자동으로 만들어서 올려줘." — activate for one reviewed draft; decline the batch and auto-publishing (R7).
- "협찬 받은 제품인데 광고처럼 안 보이게 써줘." — activate; disclosure stays in the opening (R6), and the post is written as a real review with a downside.
- "네이버 블로그 글인데 노출은 상관없고 문장만 사람 냄새 나게 다듬어줘." — activate in the repair path; the ranking steps are skipped, the format contract and the anchors still apply.

</activation_examples>

<workflow>

| Step | Work | Output |
|---|---|---|
| 0. Intake | Confirm blog URL, the post's goal, the optional brand/product and the relationship to it, optional URL/material, plain/rich, and optional tone and manner in one message; await reply. The tone is asked here once and never re-asked. Do not repeat answered items. | Confirmed brief |
| 1. Research | Given a keyword (or brand + topic + 가치입증), run `rules/topic-research.md`: query candidates, top-3 gap analysis, sourced facts, experience slots, inline image slots. Given experience or images, record them and run only the gap and image-slot steps — plus a decision field's lanes in `rules/topic-research.md` §3 when a number is still missing. | Fact pack |
| 2. Keyword | Pick one query and one intent slice per `references/keyword-research.md`; compare supply and demand with public tools; read the live SERP when possible; choose the post type from `references/post-type-library.md`. | `검색어 / 의도 슬라이스 / 주 유형 / 보조 유형 / 목표 / 근거` line |
| 3. Structure | Fill the skeleton in `rules/post-workflow.md` §3: title, cover image slot, first screen (empathy → answer → basis → scope), 3-6 evidence sections each with a fact or slot and an inline image marker, the decision layer when the intent needs one, a downside section, close, [disclosure, brand block, CTA]. | Outline |
| 4. Draft | Write under `rules/human-prose.md` and the settled voice card (`rules/tone-manner.md`) with this skill's format contract; titles and openings from `references/hook-library.md`; facts verbatim; image markers in the prose flow; `[확인 필요]` left open. | Draft |
| 5. Check | Run `rules/validation.md` draft checklist, walking `references/tell-catalog.md` family by family against the draft; fix hard-rule failures (≤ 2 rounds). | Checked draft |
| 6. Deliver | Titles → plain text or rich body HTML → one JSON per generated-image slot → keyword → slots → publish note. | Korean deliverable |

</workflow>

A supplied draft replaces steps 1 to 3: record its register and its anchors, then run `rules/repair-method.md`. Steps 5 and 6 are unchanged, and the delivery adds a one-to-three-line change summary outside the text block.

<required>

- Before research or drafting, ask the intake items in one message and await the reply; do not repeat answered items. The six items are blog URL, the post's goal, the optional brand/product and the relationship, optional URL/material, the format, and the optional tone and manner, which is asked once and never re-asked; the mode is derived from the relationship and the goal, never asked separately.
- State the post type in the decision line and follow that type's skeleton, with at most one secondary type.
- After intake, research from the keyword without demanding a fact pack; missing optional business details become slots.
- Write to one intent slice inside the author's topic lane; select the matching editor 주제 in the publish note.
- Place real-material `[이미지: 대상 | 캡션]` or illustration `[이미지 생성: 대상 | 캡션 | 프롬프트 #n]` markers at their body positions; provide matching generation JSON outside the body.
- Choose each generated image's section role and template from `references/image-prompt-templates.md` §2, then compile that object in the order `rules/image-slots.md` §6 fixes. An inapplicable conditional field is absent — never `null`, `"N/A"`, or a placeholder.
- Write each rendered string exactly once inside `text[]` and have `prompt` carry every one of them byte-identical, and repeat a real series' invariants in every object of that series.
- When the subject, the exact rendered text, or an edit's preserve/change boundary is missing, do not emit a finished prompt for that image; ask or leave the slot open.
- Plain uses one text fence; rich uses body HTML plus separate title/tags. Distinguish copying HTML source from copying HTML clipboard content.
- Follow the body rhythm contract in `rules/post-workflow.md` §3 for both formats: text blocks of 1-5 lines with 12-25-character explicit line breaks, 1-3-sentence paragraph blocks, at most 2 text blocks in a row, and (rich) center-aligned paragraphs with `line-height:1.8` inline and blank-paragraph spacers — never `p` `margin`.
- Put the title's promise in the first 3-5 sentences; every section carries a checkable circumstance or a source; at least one section names a downside.
- Use the target query once in the title and only where sentences need it in the body; no count or density target.
- Disclose sponsorship, own-business, or affiliate relationships in the first paragraph in plain words.
- Insert 전환형 brand facts verbatim and end with exactly one CTA phrased as the reader's next decision.
- Label numeric sizing as defaults, and folklore as folklore, whenever the user asks for a rule.
- Apply `rules/human-prose.md` while drafting; keep one register throughout.
- Carry the decision layer when the intent needs one, with every number attributed to a source whose role is `quantitative_authority`; a review, blog, or cafe post is never the sole basis for a number.
- Keep the product and indication scope on every regulated number; a value whose scope differs from the source is not used.
- In a regulated topic, a qualitative judgment the advice turns on — the criterion, the condition that flips it — needs a `recommendation_basis` with its scope or a directly supporting first-party source; otherwise it stays a slot.
- Keep key numbers, prices, conditions, and steps in body text; an image never carries them alone.
- Repair path only, when the user supplied a post: record the anchors before the first edit, hold the supplied register, and never let a tell fix cost a fact, an image marker, a `[확인 필요]` slot, the disclosure line, a hashtag, or a subheading.
- Walk the matching family in `references/tell-catalog.md` before delivery: S1 items there are removed wherever they appear, and S2 or S3 work follows the dominant-pattern diagnosis rather than a span-by-span sweep.

</required>

<forbidden>

- Naming, requiring, or reading another skill, or depending on any path outside this package.
- Inventing experiences, statistics, quotes, prices, credentials, or sources — gaps are marked `[확인 필요]`, never filled.
- Demanding a fact pack, images, or experience from the user before doing the research step.
- Proposing stock images, screenshots of other posts, or reused image sets in an image marker.
- Clickbait vocabulary from the seed library (`이것`, `비밀`, `97%가 모르는`, `100% 후회`, `충격`, `삭제예정`) or invented urgency.
- Keyword insertion, hidden keywords, hashtag inventories, or reused template blocks and image sets.
- Presenting `1,500자`, `이미지 5장`, `키워드 3-5회`, `블로그 지수`, `1일 1포`, `같은 IP 저품질`, or `체류시간 임계값` as Naver rules.
- Producing batch variants, scheduling, auto-publishing, comment/like/neighbor bait, or any engagement manipulation.
- Logging into Naver, calling Naver API endpoints, or scraping.
- Markdown `**bold**` or `#` headings inside the deliverable body meant for the Naver editor.
- Annotating the output with rule IDs, evidence tiers, or the tells that were avoided.
- A provider, model, quality, tier, or resolution flag inside a generation brief, or any claim that a prompt is a generated artifact.
- `null`, `"N/A"`, `"없음"`, `"위와 동일"`, `"same as above"`, or a brace placeholder filling an inapplicable field.
- Borrowing a living artist, a real person, or a trademark as a style shortcut instead of describing visible properties.
- Presenting a generated image as a real site, product, place, receipt, 견적서, instrument reading, result, certificate, or before/after photo; using a generated map for real geography.
- Invoking an image tool merely because a generation marker exists.
- Swapping the register of a supplied post in either direction, or dropping a fact, a `[확인 필요]` slot, the disclosure line, a hashtag, or a heading to remove a tell.
- Filling a hole in a supplied post by inventing content the author never wrote.
- Leaving the decision layer empty while the title or the intent asks what to do, choose, how often, how much, how long, or at what price.
- Publishing a regulated quantitative claim whose source role is not `quantitative_authority`, or letting a review, blog, or cafe post stand in for a primary source.
- Putting a key number, price, condition, or step only inside an image.
- Confirming a booking, discount, or purchase CTA while the topic's legal boundary is unconfirmed.
- Stating a regulated number without its product or indication scope, or generating a regulated qualitative judgment the sources do not support.
- Confirming a guaranteed-effect claim, a superiority comparison, a patient testimonial, or a statement that drops a serious downside while the advertising boundary is unconfirmed.

</forbidden>

<runtime_fallback>

If support files cannot be read, disclose the skipped detailed checks in the publish note and execute this minimum contract without claiming those files were read. Coding-agent and web runtimes use only currently exposed read/search/file/render capabilities.

1. Ask blog URL, the post's goal, the optional brand/product and the relationship (자사 / 협찬 / 제휴 / 없음), optional URL/material, and plain/rich in one message and await the reply. Reuse supplied answers; optional items stay optional. Derive the mode from the relationship and the goal.
2. Then select one keyword and reader question and one post type; when available read three top posts and official or dated sources. Record source URLs and dates. Without search, use supplied evidence only and disclose unverified research/freshness. Mark gaps [확인 필요]. For a regulated topic, a number needs a first-party source (role `quantitative_authority`); with none, publish the decision-complete structure with slots and a list of the sources to find instead of a quantitative draft. Never ask a second intake question.
3. Write three title candidates, an opening answer, 3-6 evidence sections, the action layer, limitations, and a close. Keep one register; remove filler, repetition, and hype. Never invent experience, prices, or credentials. Disclose commercial relationships early; use one conversion CTA. Repairs preserve facts, register, markers, and structure.
4. Place a cover and visual explanations between short paragraphs: real-material [이미지: 대상 | 캡션] or [이미지 생성: 설명 그림 | 캡션 | 프롬프트 #n]. Use comparisons, processes, and mechanism illustrations without padding to a count. Label generated illustrations; never use them as proof of a real site, certificate, or result.
5. Give each generation marker exactly one JSON object outside the body. Always include id, section_role, template, use, hierarchy (first, second, background), subject, composition, style, must_include, must_exclude, inspection_checks, aspect, caption_note, and prompt. Add only when they carry meaning: scene, lighting, color (dominant, support, accent, contrast), material_and_rendering, text (string, role, placement, reading_order, priority, scale, contrast, clearance), series_invariants, reference (role: inspiration or edit_source), assumptions. An inapplicable field is absent — never null, "N/A", or a placeholder. section_role and template are paired as follows: cover (cover-key-visual), first-screen (first-screen-key-takeaway), mechanism (mechanism-cutaway or mechanism-flow), comparison (comparison-table, comparison-split, or before-after-schematic), process (process-flow), cost (cost-breakdown), checklist (checklist-card), caution (failure-caution), data (data-chart), timeline (timeline), route (route-schematic), scale (scale-dimension), closing (closing-next-step), concept (concept-mood). Take the template from that role's parenthesis, and use this pairing even when `references/image-prompt-templates.md` cannot be read. Each text[].string appears exactly once in text[] and prompt carries every one of them byte-identical. Repeat a real series' invariants in every object of that series. prompt derives only from the structured fields and adds no fact beyond them. A prompt is not a generated artifact.
6. Plain: one text fence containing title/body/hashtags. Rich: separate title/tags and simple inline-styled body HTML using p/h2/h3/strong/u/span/lists/blockquote/hr/tables/a and real HTTPS img sources. Exclude data:image, scripts, and event handlers. Without file capability, provide HTML source and explain that styled paste needs rendered content copied as text/html. Strike-through, source-code, and special components require manual editor work. Keep the line rhythm even in the fallback: short explicit line breaks (12-25 characters), 1-3-sentence blocks, blank-paragraph spacers instead of margins, and `line-height:1.8` inline on rich paragraphs.
7. Check facts, disclosure, links, marker/JSON correspondence, and chosen format; revise at most twice. Do not claim unavailable detailed prose checks passed. No login, upload, or publication.
8. Medical safety survives the loss of every support file. These five lines hold whether or not `references/regulated-topic-research.md` was read:
   - A medical quantitative value may be based only on a governing first-party source (approval or 허가사항, manufacturer label) with the same claim scope. A peer-reviewed review is context, never the sole basis for a number.
   - A review, a blog, or a cafe post is not a pass because it has a URL.
   - When the product, indication, site, or population scope differs from the source, do not use that number.
   - A regulated qualitative judgment — a decision criterion, or the condition that flips the advice — needs a `recommendation_basis` with its scope or a first-party source that directly supports it; otherwise it is a slot, not a sentence.
   - While an applicable medical-advertising boundary is unconfirmed, do not confirm a booking, discount, or purchase CTA, a guaranteed-effect claim, a superiority comparison, a patient testimonial, or a statement that drops a serious downside. Leave the element as a slot and mark the draft blocked for publishing.

</runtime_fallback>

<support_file_read_order>

For rich files, read [`references/rich-html-template.md`](references/rich-html-template.md), retain the formatted-copy button in [`assets/rich-post.html`](assets/rich-post.html), and reuse [`assets/rich-blocks.html`](assets/rich-blocks.html). If assets cannot be read, provide complete HTML with body-only DOM selection and `document.execCommand('copy')` inside the button click; on blocking, leave the body selected and explain manual copying.

Read only one language version per run. Paths are relative to this installed skill directory, never a hard-coded checkout or plugin cache. File reads are explicit actions, not automatic includes. For bare filenames, resolve the unique matching file in this navigation list; do not interpret them relative to the current support document.

- Before research or drafting, read [`rules/intake.md`](rules/intake.md). Ask the six intake items together and await the reply unless already answered: blog URL, the post's goal, the optional brand/product and the relationship, optional business/product URL or material, plain/rich format, and optional tone and manner.
- Before choosing the type, read [`references/post-type-library.md`](references/post-type-library.md) §1-§2; after choosing, read only the chosen type's §3 playbook (plus a secondary type's, when one was chosen).
- When the topic is medical or a quantitative safety, dosage, interval, duration, eligibility, or legal-limit claim is involved, read [`references/regulated-topic-research.md`](references/regulated-topic-research.md).
- While placing images, read [`rules/image-slots.md`](rules/image-slots.md); when compiling generation prompts, read [`references/image-prompt-templates.md`](references/image-prompt-templates.md).
- After format selection, read [`references/format-options.md`](references/format-options.md) for plain delivery or body-only HTML, separate title/tags, and HTML clipboard requirements.

1. After intake, read [`rules/post-workflow.md`](rules/post-workflow.md) for the remaining run: mode decision, intake, structure skeleton, delivery order.
2. Read [`rules/topic-research.md`](rules/topic-research.md) whenever the brief lacks experience, sources, or images (the usual case): research procedure, experience slots, inline image slots, fact-pack shape.
3. Read [`rules/naver-ranking-contract.md`](rules/naver-ranking-contract.md) before drafting: hard rules R1-R10, observed defaults, folklore list, Google contrast.
4. Read [`references/hook-library.md`](references/hook-library.md) when writing the title, first screen, closing, or CTA.
5. Read [`references/keyword-research.md`](references/keyword-research.md) when the query is not fixed or looks too broad or commercial; it holds the supply/demand procedure and tool list.
6. Read [`references/naver-algorithm-timeline.md`](references/naver-algorithm-timeline.md) when the user cites an algorithm name or a circulating claim needs a date and source.
7. Read [`references/evidence-digest.md`](references/evidence-digest.md) when a rule is challenged or a newer Naver announcement must be reconciled with the contract.
8. Read [`rules/human-prose.md`](rules/human-prose.md) before drafting and again for the self-check: principles, W-01 to W-26, tell families, Naver genre rows, self-check protocol.
9. Read [`rules/repair-method.md`](rules/repair-method.md) in full when the user supplies an existing post: anchors, dominant-pattern diagnosis, repair procedure, over-correction guard, exit criteria.
10. Read [`references/tell-catalog.md`](references/tell-catalog.md) when a draft reads machine-written but no single sentence looks broken, when a repair needs a candidate pool to diagnose against, or before the delivery scan: the per-pattern layer behind the family table.
11. Read [`rules/validation.md`](rules/validation.md) before delivery and whenever this package changes.
12. Use [`assets/evals/naver-blog-maker-cases.jsonl`](assets/evals/naver-blog-maker-cases.jsonl) when changing trigger, workflow, or output behavior.
13. Read [`rules/tone-manner.md`](rules/tone-manner.md) before drafting, and again for the voice-card comparison: the three input shapes, the voice card, the precedence ladder, the floor, and the publish-note line.

</support_file_read_order>

<validation>

- [ ] Mode stated and consistent with the deliverable (전환형 has disclosure, verbatim brand block, one CTA).
- [ ] Research step ran when the brief lacked facts: fact pack has sourced facts with URL and date, gap analysis of the top 3, and no fabricated experience.
- [ ] Intake was answered and delivery matches the selected format; rich title/tags are separate and generation markers map one-to-one to JSON objects.
- [ ] Every generation object carries the 14 always-fields; conditional fields appear only where they carry meaning and inapplicable ones are truly absent (no `null`, `"N/A"`, `"없음"`, `"위와 동일"`).
- [ ] Each object's `section_role` is one of the 14 roles and `template` is a template ID from that role's row.
- [ ] Each rendered string appears once in `text[]`, and `prompt` carries every one of them byte-identical; a real series' invariants repeat in every object of that series.
- [ ] No generated image stands in for a real site, place, receipt, 견적서, reading, result, certificate, or before/after photo; no generated map for real geography.
- [ ] No provider, model, quality, or resolution flag appears in a brief; `prompt` adds no fact beyond the structured fields.
- [ ] One query, one intent slice, inside the blog's topic lane; keyword decision line present.
- [ ] Title promise appears in the first 3-5 sentences; no concealment words or invented numbers.
- [ ] Every section has a checkable circumstance or source; one section names a downside; `[확인 필요]` marks any gap.
- [ ] Target query natural: once in title, no noticeable repetition, hashtags ≤ 7.
- [ ] No engagement bait, no batch output, no automation.
- [ ] `rules/human-prose.md` self-check passed (zero S1 hits); one register; no Naver-specific tells; no markdown formatting in the body.
- [ ] When file reads work, check the tell catalog; otherwise apply the core prose checks and disclose the skipped detailed scan.
- [ ] Repair path only: anchors recorded before editing and re-verified after (`rules/repair-method.md` §2), diagnosis limited to three to six quoted families, register unchanged in both directions, the over-correction guard passed, and the change summary outside the block in one to three lines.
- [ ] Deliverable follows the order in `rules/post-workflow.md` §5 with no rule IDs or tier labels.
- [ ] The body rhythm contract in `rules/post-workflow.md` §3 passed: blocks 1-5 lines of 12-25-character breaks, paragraph blocks 1-3 sentences, ≤ 2 text blocks in a row with a visible gap or visual block between, rich paragraphs centered with `line-height:1.8` inline and spaced by blank-paragraph spacers (no `p` `margin`).
- [ ] (Repository maintenance only; not a runtime dependency) package changes keep KO/EN parity, pass the corpus validator scoped to this package (`validate-skills-corpus.mjs --root skills --only naver-blog-maker --json`) and `bun run --cwd scripts verify`, and keep `README.md` unchanged — unless this change adds a skill or changes a skill's name or catalog exposure, in which case `README.md`'s count and catalog row are updated.
- [ ] The post type is declared in the decision line and the body follows that type's skeleton, with at most one secondary type.
- [ ] The decision layer exists when the intent or the title asks what to do, choose, how often, how much, how long, or at what price: criterion ≥ 1, every source-backed option, the operating number, the flip condition ≥ 1, exactly one next step.
- [ ] Every regulated quantitative claim traces to a `quantitative_authority` source with a claim scope; `source-required` slots block publishing; the medical boundary gate passed.
- [ ] No key number, price, condition, or step is carried only by an image.

- [ ] The voice matched the settled card: endings, sentence length, lexis, and ornament habit agree, and a tone request the floor rejected appears in the publish note (`rules/tone-manner.md` §5).
</validation>
