---
name: naver-blog-maker
description: "[Hyper] Use this skill when the user asks to write, outline, or rework a Naver blog post (네이버 블로그 글, 상위노출용 포스팅, 체험단·후기·정보글, 업체 문의 전환용 글) from as little as a keyword: it researches the topic and the top-ranked posts, drafts under Naver's published rules (C-Rank, D.I.A.+, 스마트블록, AI 브리핑), hooks with a promise the first screen keeps, places inline image slots, and delivers one copy-ready text block that reads as a person wrote it. Two modes: 정보/경험형 (no brand) and 전환형 (brand + 가치입증 + one CTA). Do not use for Google-targeted SEO audits, Tistory/WordPress posts, Naver API-only queries, or Korean prose polishing without a Naver post as the deliverable."
compatibility: Self-contained Markdown skill; needs only web search and page fetch for topic research. Browser tooling for live SERP inspection is optional. No login, scraping, or auto-publishing.
---

@rules/naver-ranking-contract.md
@rules/post-workflow.md
@rules/topic-research.md
@rules/human-prose.md
@rules/validation.md
@references/hook-library.md
@references/keyword-research.md
@references/naver-algorithm-timeline.md
@references/evidence-digest.md

# Naver Blog Maker

> Write one Naver blog post that Naver's current systems can surface, that a searcher clicks and finishes, and that a reader takes for a person's own writing.

<output_language>

Default every user-facing deliverable — title candidates, the post block with its image and slot markers, hashtags, notes, and self-check summaries — to Korean. Preserve product names, URLs, commands, file paths, and quoted source text in their original form. Use another language only when the user asks; that request usually means a different skill.

</output_language>

<purpose>

- Start from a keyword: research the query, the top-ranked posts' gaps, and sourced facts, then draft — without asking the user for a fact pack first.
- Produce a post that follows Naver's published rules (source topic lane, document experience and originality, intent-slice fit, no inserted keywords, no deceptive titles or links, disclosure) and never trips an official restriction.
- Place image slots inline where each photo must appear, naming what to shoot and what the caption proves; mark what only the author can know as `[확인 필요]` slots instead of inventing it.
- Deliver the post as one copy-ready text block the user pastes into SmartEditor ONE.
- Hook with a specific promise in the title and keep it within the first screen, using the adapted pattern library instead of clickbait vocabulary.
- Draft under the embedded prose rules in `rules/human-prose.md` so the text has no machine-written texture from the start.
- Separate what Naver said (`official`) from what practitioners observe (`observed`) and from folklore, and say which is which when the user asks for a "rule".
- Support two modes: 정보/경험형 for ranking-and-reading posts without a brand, and 전환형 for posts that must generate inquiries or visits for a named brand using the user's own 가치입증 facts.

</purpose>

<routing_rule>

Use `naver-blog-maker` when the deliverable is a Naver blog post (or its title/outline/rework) and the user cares about exposure in Naver search or the Naver app.

Do not activate when:

- the target is Google, a company website, or a technical SEO audit — out of scope
- the user wants only raw Naver data (search counts, DataLab trends) with no post — out of scope
- the user supplies Korean text to polish with no Naver post as the deliverable — out of scope
- the platform is Tistory, WordPress, Brunch, or a newsletter — out of scope
- the user wants a batch of posts, scheduled auto-publishing, or comment/neighbor automation — refuse the automation part (see `<forbidden>`) and offer one reviewed draft

This skill is self-contained: it owns the post structure, the Naver rules, and the sentence-level naturalness rules (`rules/human-prose.md`). It never depends on another skill being installed.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | One Naver-ready post from a keyword upward: 3 title candidates; one fenced `text` block holding title + body with inline `[이미지: …]` and `[확인 필요: …]` markers + hashtags; keyword decision; slot list; publish note with research URLs. |
| Scope | Post content and structure only. No login, no publishing, no engagement actions, no scraping. |
| Authority | User request and repository instructions > `rules/naver-ranking-contract.md` (official rows) > `observed` defaults > user-supplied prompt templates > any third-party SEO guide. |
| Evidence | Every Naver-behavior claim traces to an `official` row in `references/naver-algorithm-timeline.md` (mapped in `references/evidence-digest.md`); observed and folklore items are labeled. Informational facts come from research with `URL | 날짜`; first-hand experience, results, prices paid, and brand lines come only from the user; gaps become `[확인 필요]`. |
| Tools | Web search and page fetch for topic research; optional browser tooling for live SERP inspection; public Naver pages (DataLab, 통합검색) read as a visitor. Nothing else touches Naver; no login, no scraping. |
| Loop | Draft → `rules/validation.md` self-check → fix hard-rule failures; at most two revision rounds, then deliver with remaining items named. |
| Output | Korean deliverable in the order fixed by `rules/post-workflow.md` §5; the post itself is a single fenced `text` block with plain text only. No rule IDs or rubric text in the user-facing output. |
| Verification | Draft checklist in `rules/validation.md`; package checklist when the skill changes (corpus validator, `bun run --cwd scripts verify`, KO/EN parity, README catalog). |
| Stop condition | Deliver when the checklist passes. Stop and ask (one question) only when the mode or topic lane is ambiguous and changes the output; stop and list required sources when a regulated topic has no primary source; decline batch or automated publishing. |

</instruction_contract>

<activation_examples>

Positive:

- "누수 탐지 비용으로 네이버 블로그 글 하나 써줘." (keyword only — research fills the rest)
- "강남 임플란트 가격 비교 주제로 네이버 블로그 글 써줘, 상위노출 되게."
- "우리 누수탐지 업체 문의 늘리는 네이버 블로그 포스팅 써줘. 브랜드명은 ○○, 가치입증은 이거야."
- "제주 3박4일 여행 후기를 네이버 블로그에 올릴 건데 사람이 쓴 것처럼 써줘."
- "Write a Naver blog post about a 에어프라이어 review that can rank in Naver search."
- "이 네이버 블로그 글 제목이랑 서두만 다시 잡아줘, 낚시 같지 않게."

Negative:

- "우리 회사 홈페이지 SEO 점검해줘." → out of scope (website SEO)
- "네이버 데이터랩에서 두 키워드 추이만 뽑아줘." → out of scope (data only, no post)
- "이 글 번역투만 고쳐줘." (no Naver post) → out of scope (prose polishing only)
- "티스토리에 올릴 애드센스 글 써줘." → out of scope

Boundary:

- "블로그 글 하나 써줘." — ask which platform; activate only when it is Naver.
- "네이버 블로그 글 50개 자동으로 만들어서 올려줘." — activate for one reviewed draft; decline the batch and auto-publishing (R7).
- "협찬 받은 제품인데 광고처럼 안 보이게 써줘." — activate; disclosure stays in the opening (R6), and the post is written as a real review with a downside.

</activation_examples>

<workflow>

| Step | Work | Output |
|---|---|---|
| 0. Mode | Decide 정보/경험형 or 전환형 from the brief; state it in one clause. A brand, offer, or link to a business means 전환형. | Mode line |
| 1. Research | Given a keyword (or brand + topic + 가치입증), run `rules/topic-research.md`: query candidates, top-3 gap analysis, sourced facts, experience slots, inline image slots. Given experience or images, record them and run only the gap and image-slot steps. Ask at most one question. | Fact pack |
| 2. Keyword | Pick one query and one intent slice per `references/keyword-research.md`; compare supply and demand with public tools; read the live SERP when possible. | `검색어 / 슬라이스 / 근거` line |
| 3. Structure | Fill the skeleton in `rules/post-workflow.md` §3: title, cover image slot, first screen (empathy → answer → basis → scope), 3-6 evidence sections each with a fact or slot and an inline image marker, a downside section, close, [disclosure, brand block, CTA]. | Outline |
| 4. Draft | Write under `rules/human-prose.md` with this skill's format contract; titles and openings from `references/hook-library.md`; facts verbatim; image markers in the prose flow; `[확인 필요]` left open. | Draft |
| 5. Check | Run `rules/validation.md` draft checklist; fix hard-rule failures (≤ 2 rounds). | Checked draft |
| 6. Deliver | Order fixed in `rules/post-workflow.md` §5: titles → one fenced `text` block (title + body + hashtags) → keyword line → slot list → publish note. | Korean deliverable |

</workflow>

<required>

- State the mode before any other step.
- Research before asking: a keyword alone is a complete brief.
- Write to one intent slice inside the author's topic lane; select the matching editor 주제 in the publish note.
- Place every image as an inline `[이미지: 무엇을 찍을지 | 캡션]` marker at its position; cover first, then one per photo-provable claim.
- Deliver the post inside a single fenced `text` block with plain text only.
- Put the title's promise in the first 3-5 sentences; every section carries a checkable circumstance or a source; at least one section names a downside.
- Use the target query once in the title and only where sentences need it in the body; no count or density target.
- Disclose sponsorship, own-business, or affiliate relationships in the first paragraph in plain words.
- Insert 전환형 brand facts verbatim and end with exactly one CTA phrased as the reader's next decision.
- Label numeric sizing as defaults, and folklore as folklore, whenever the user asks for a rule.
- Apply `rules/human-prose.md` while drafting; keep one register throughout.

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

</forbidden>

<support_file_read_order>

1. Read [`rules/post-workflow.md`](rules/post-workflow.md) first for every run: mode decision, intake, structure skeleton, delivery order.
2. Read [`rules/topic-research.md`](rules/topic-research.md) whenever the brief lacks experience, sources, or images (the usual case): research procedure, experience slots, inline image slots, fact-pack shape.
3. Read [`rules/naver-ranking-contract.md`](rules/naver-ranking-contract.md) before drafting: hard rules R1-R9, observed defaults, folklore list, Google contrast.
4. Read [`references/hook-library.md`](references/hook-library.md) when writing the title, first screen, closing, or CTA.
5. Read [`references/keyword-research.md`](references/keyword-research.md) when the query is not fixed or looks too broad or commercial; it holds the supply/demand procedure and tool list.
6. Read [`references/naver-algorithm-timeline.md`](references/naver-algorithm-timeline.md) when the user cites an algorithm name or a circulating claim needs a date and source.
7. Read [`references/evidence-digest.md`](references/evidence-digest.md) when a rule is challenged or a newer Naver announcement must be reconciled with the contract.
8. Read [`rules/human-prose.md`](rules/human-prose.md) before drafting and again for the self-check: principles, W-01 to W-26, tell families, Naver genre rows, self-check protocol.
9. Read [`rules/validation.md`](rules/validation.md) before delivery and whenever this package changes.
10. Use [`assets/evals/naver-blog-maker-cases.jsonl`](assets/evals/naver-blog-maker-cases.jsonl) when changing trigger, workflow, or output behavior.

</support_file_read_order>

<validation>

- [ ] Mode stated and consistent with the deliverable (전환형 has disclosure, verbatim brand block, one CTA).
- [ ] Research step ran when the brief lacked facts: fact pack has sourced facts with URL and date, gap analysis of the top 3, and no fabricated experience.
- [ ] The post is one fenced `text` block: title first line, hashtags last line, plain text only, inline `[이미지: …]` markers (cover + one per provable claim) and `[확인 필요: …]` slots in place.
- [ ] One query, one intent slice, inside the blog's topic lane; keyword decision line present.
- [ ] Title promise appears in the first 3-5 sentences; no concealment words or invented numbers.
- [ ] Every section has a checkable circumstance or source; one section names a downside; `[확인 필요]` marks any gap.
- [ ] Target query natural: once in title, no noticeable repetition, hashtags ≤ 7.
- [ ] No engagement bait, no batch output, no automation.
- [ ] `rules/human-prose.md` self-check passed (zero S1 hits); one register; no Naver-specific tells; no markdown formatting in the body.
- [ ] Deliverable follows the order in `rules/post-workflow.md` §5 with no rule IDs or tier labels.
- [ ] (Repository maintenance only; not a runtime dependency) package changes keep KO/EN parity, pass `node skills/skill-tester/scripts/validate-skills-corpus.mjs --root skills --only naver-blog-maker --json` and `bun run --cwd scripts verify`, and update `README.md`.

</validation>
