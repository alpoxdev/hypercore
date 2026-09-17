---
name: naver-blog-maker
description: "[Hyper] Write or revise one Naver blog post: confirm blog URL, information/conversion mode and plain/rich format first, then research a keyword, draft natural Korean, place real-image slots and copy-ready image prompt JSON, and deliver plain text or body HTML. Use for Naver blog drafts, reviews, guides, and business posts; not other platforms, API-only requests, or automatic publishing."
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
- Draft under the embedded prose rules in `rules/human-prose.md` so the text has no machine-written texture from the start.
- Separate what Naver said (`official`) from what practitioners observe (`observed`) and from folklore, and say which is which when the user asks for a "rule".
- Support two modes: 정보/경험형 for ranking-and-reading posts without a brand, and 전환형 for posts that must generate inquiries or visits for a named brand using the user's own 가치입증 facts.
- Repair a Naver post the user already wrote: keep its register and its content anchors and remove the machine-written texture under `rules/repair-method.md`, instead of rewriting the post.
- Deepen the prose pass by walking `references/tell-catalog.md`, the individual patterns behind the family table, each with a bad-to-good pair and the W-ID that removes it.

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
| Verification | Draft checklist in `rules/validation.md`; package checklist when the skill changes (corpus validator, `bun run --cwd scripts verify`, KO/EN parity, README catalog). |
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
| 0. Intake | Confirm blog URL, information/conversion mode, optional business/product, optional URL/material, and plain/rich in one message; await reply. Do not repeat answered items. | Confirmed brief |
| 1. Research | Given a keyword (or brand + topic + 가치입증), run `rules/topic-research.md`: query candidates, top-3 gap analysis, sourced facts, experience slots, inline image slots. Given experience or images, record them and run only the gap and image-slot steps. | Fact pack |
| 2. Keyword | Pick one query and one intent slice per `references/keyword-research.md`; compare supply and demand with public tools; read the live SERP when possible. | `검색어 / 슬라이스 / 근거` line |
| 3. Structure | Fill the skeleton in `rules/post-workflow.md` §3: title, cover image slot, first screen (empathy → answer → basis → scope), 3-6 evidence sections each with a fact or slot and an inline image marker, a downside section, close, [disclosure, brand block, CTA]. | Outline |
| 4. Draft | Write under `rules/human-prose.md` with this skill's format contract; titles and openings from `references/hook-library.md`; facts verbatim; image markers in the prose flow; `[확인 필요]` left open. | Draft |
| 5. Check | Run `rules/validation.md` draft checklist, walking `references/tell-catalog.md` family by family against the draft; fix hard-rule failures (≤ 2 rounds). | Checked draft |
| 6. Deliver | Titles → plain text or rich body HTML → one JSON per generated-image slot → keyword → slots → publish note. | Korean deliverable |

</workflow>

A supplied draft replaces steps 1 to 3: record its register and its anchors, then run `rules/repair-method.md`. Steps 5 and 6 are unchanged, and the delivery adds a one-to-three-line change summary outside the text block.

<required>

- Before research or drafting, ask the intake items in one message and await the reply; do not repeat answered items.
- After intake, research from the keyword without demanding a fact pack; missing optional business details become slots.
- Write to one intent slice inside the author's topic lane; select the matching editor 주제 in the publish note.
- Place real-material `[이미지: 대상 | 캡션]` or illustration `[이미지 생성: 대상 | 캡션 | 프롬프트 #n]` markers at their body positions; provide matching generation JSON outside the body.
- Plain uses one text fence; rich uses body HTML plus separate title/tags. Distinguish copying HTML source from copying HTML clipboard content.
- Put the title's promise in the first 3-5 sentences; every section carries a checkable circumstance or a source; at least one section names a downside.
- Use the target query once in the title and only where sentences need it in the body; no count or density target.
- Disclose sponsorship, own-business, or affiliate relationships in the first paragraph in plain words.
- Insert 전환형 brand facts verbatim and end with exactly one CTA phrased as the reader's next decision.
- Label numeric sizing as defaults, and folklore as folklore, whenever the user asks for a rule.
- Apply `rules/human-prose.md` while drafting; keep one register throughout.
- Repair path only, when the user supplied a post: record the anchors before the first edit, hold the supplied register, and never let a tell fix cost a fact, an image marker, a `[확인 필요]` slot, the disclosure line, a hashtag, or a subheading.
- Walk the matching family in `references/tell-catalog.md` before delivery: S1 items there are removed wherever they appear, and S2 or S3 work follows the dominant-pattern diagnosis rather than a span-by-span sweep.

</required>

<forbidden>

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
- Swapping the register of a supplied post in either direction, or dropping a fact, a `[확인 필요]` slot, the disclosure line, a hashtag, or a heading to remove a tell.
- Filling a hole in a supplied post by inventing content the author never wrote.

</forbidden>

<runtime_fallback>

If support files cannot be read, disclose the skipped detailed checks in the publish note and execute this minimum contract without claiming those files were read. Coding-agent and web runtimes use only currently exposed read/search/file/render capabilities.

1. Ask blog URL, information/conversion mode, optional business/product, optional URL/material, and plain/rich in one message and await the reply. Reuse supplied answers; optional items stay optional.
2. Then select one keyword and reader question; when available read three top posts and official or dated sources. Record source URLs and dates. Without search, use supplied evidence only and disclose unverified research/freshness. Mark gaps [확인 필요]; stop if required regulated-topic sources are missing.
3. Write three title candidates, an opening answer, 3-6 evidence sections, limitations, and a close. Keep one register; remove filler, repetition, and hype. Never invent experience, prices, or credentials. Disclose commercial relationships early; use one conversion CTA. Repairs preserve facts, register, markers, and structure.
4. Place a cover and visual explanations between short paragraphs: real-material [이미지: 대상 | 캡션] or [이미지 생성: 설명 그림 | 캡션 | 프롬프트 #n]. Use comparisons, processes, and mechanism illustrations without padding to a count. Label generated illustrations; never use them as proof of a real site, certificate, or result.
5. Give each generation marker one JSON object outside the body with id, use, subject, scene, composition, style, must_include, must_exclude, aspect, caption_note; add lighting and text entries (string/role/placement) when relevant. Specify exact lettering, hierarchy, composition, color/material, and series invariants independently in each object. No placeholders or model flags; a prompt is not a generated artifact.
6. Plain: one text fence containing title/body/hashtags. Rich: separate title/tags and simple inline-styled body HTML using p/h2/h3/strong/u/span/lists/blockquote/hr/tables/a and real HTTPS img sources. Exclude data:image, scripts, and event handlers. Without file capability, provide HTML source and explain that styled paste needs rendered content copied as text/html. Strike-through, source-code, and special components require manual editor work.
7. Check facts, disclosure, links, marker/JSON correspondence, and chosen format; revise at most twice. Do not claim unavailable detailed prose checks passed. No login, upload, or publication.

</runtime_fallback>

<support_file_read_order>

Read only one language version per run. Paths are relative to this installed skill directory, never a hard-coded checkout or plugin cache. File reads are explicit actions, not automatic includes. For bare filenames, resolve the unique matching file in this navigation list; do not interpret them relative to the current support document.

- Before research or drafting, read [`rules/intake.md`](rules/intake.md). Ask the five intake items together and await the reply unless already answered: blog URL, information/conversion mode, optional business/product, optional business/product URL or material, and plain/rich format.
- While placing images, read [`rules/image-slots.md`](rules/image-slots.md); when compiling generation prompts, read [`references/image-prompt-templates.md`](references/image-prompt-templates.md).
- After format selection, read [`references/format-options.md`](references/format-options.md) for plain delivery or body-only HTML, separate title/tags, and HTML clipboard requirements.

1. After intake, read [`rules/post-workflow.md`](rules/post-workflow.md) for the remaining run: mode decision, intake, structure skeleton, delivery order.
2. Read [`rules/topic-research.md`](rules/topic-research.md) whenever the brief lacks experience, sources, or images (the usual case): research procedure, experience slots, inline image slots, fact-pack shape.
3. Read [`rules/naver-ranking-contract.md`](rules/naver-ranking-contract.md) before drafting: hard rules R1-R9, observed defaults, folklore list, Google contrast.
4. Read [`references/hook-library.md`](references/hook-library.md) when writing the title, first screen, closing, or CTA.
5. Read [`references/keyword-research.md`](references/keyword-research.md) when the query is not fixed or looks too broad or commercial; it holds the supply/demand procedure and tool list.
6. Read [`references/naver-algorithm-timeline.md`](references/naver-algorithm-timeline.md) when the user cites an algorithm name or a circulating claim needs a date and source.
7. Read [`references/evidence-digest.md`](references/evidence-digest.md) when a rule is challenged or a newer Naver announcement must be reconciled with the contract.
8. Read [`rules/human-prose.md`](rules/human-prose.md) before drafting and again for the self-check: principles, W-01 to W-26, tell families, Naver genre rows, self-check protocol.
9. Read [`rules/repair-method.md`](rules/repair-method.md) in full when the user supplies an existing post: anchors, dominant-pattern diagnosis, repair procedure, over-correction guard, exit criteria.
10. Read [`references/tell-catalog.md`](references/tell-catalog.md) when a draft reads machine-written but no single sentence looks broken, when a repair needs a candidate pool to diagnose against, or before the delivery scan: the per-pattern layer behind the family table.
11. Read [`rules/validation.md`](rules/validation.md) before delivery and whenever this package changes.
12. Use [`assets/evals/naver-blog-maker-cases.jsonl`](assets/evals/naver-blog-maker-cases.jsonl) when changing trigger, workflow, or output behavior.

</support_file_read_order>

<validation>

- [ ] Mode stated and consistent with the deliverable (전환형 has disclosure, verbatim brand block, one CTA).
- [ ] Research step ran when the brief lacked facts: fact pack has sourced facts with URL and date, gap analysis of the top 3, and no fabricated experience.
- [ ] Intake was answered and delivery matches the selected format; rich title/tags are separate and generation markers map one-to-one to JSON objects.
- [ ] One query, one intent slice, inside the blog's topic lane; keyword decision line present.
- [ ] Title promise appears in the first 3-5 sentences; no concealment words or invented numbers.
- [ ] Every section has a checkable circumstance or source; one section names a downside; `[확인 필요]` marks any gap.
- [ ] Target query natural: once in title, no noticeable repetition, hashtags ≤ 7.
- [ ] No engagement bait, no batch output, no automation.
- [ ] `rules/human-prose.md` self-check passed (zero S1 hits); one register; no Naver-specific tells; no markdown formatting in the body.
- [ ] When file reads work, check the tell catalog; otherwise apply the core prose checks and disclose the skipped detailed scan.
- [ ] Repair path only: anchors recorded before editing and re-verified after (`rules/repair-method.md` §2), diagnosis limited to three to six quoted families, register unchanged in both directions, the over-correction guard passed, and the change summary outside the block in one to three lines.
- [ ] Deliverable follows the order in `rules/post-workflow.md` §5 with no rule IDs or tier labels.
- [ ] (Repository maintenance only; not a runtime dependency) package changes keep KO/EN parity, pass `node skills/skill-tester/scripts/validate-skills-corpus.mjs --root skills --only naver-blog-maker --json` and `bun run --cwd scripts verify`, and update `README.md`.

</validation>
