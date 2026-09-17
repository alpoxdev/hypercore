# Naver Ranking Contract

> Korean version: [`naver-ranking-contract.ko.md`](naver-ranking-contract.ko.md)

**Purpose**: The rules a Naver blog post must satisfy so it can be surfaced by Naver's current systems (C-Rank, D.I.A.+, 스마트블록, LLM UGC evaluation, AI 브리핑) and never trips an official restriction. Every rule carries an evidence tier so the writer knows what is a hard rule and what is a planning heuristic. Sources are in [`../references/naver-algorithm-timeline.md`](../references/naver-algorithm-timeline.md).

## 1. Evidence tiers

| Tier | Meaning | How to apply |
|---|---|---|
| `official` | Naver published it (검색 공식블로그, 블로그팀 공식블로그, help.naver.com, searchadvisor.naver.com). | Hard rule. Violating it is a validation failure. |
| `observed` | Repeated across independent practitioners or measured on live posts, but Naver never confirmed it. | Planning default. Deviate when the content needs it; never present it to the user as a Naver rule. |
| `folklore` | Circulates widely, contradicted or unconfirmed by Naver, or single-source. | Do not apply. If the user asks for it, say so in one sentence and offer the tier above. |

## 2. Hard rules (`official`)

### R1. Write to one search intent, in one topic lane
- Naver splits compound queries into intent units (캠핑요리 / 캠핑용품 / 캠핑장소) and ranks each 스마트블록 separately. A post answers **one** unit; a catch-all post competes in none.
- The post's topic must fit the blog's existing topic lane. C-Rank evaluates the *source's* topic-specific trust; the 2026 guide calls a channel that keeps publishing one topic a "전문 출처". Off-lane posts do not build the lane.
- Select the matching 주제 in the editor before publishing (eligibility for 홈피드/주제판; not a guarantee).

### R2. Lead with experience or verifiable information
- D.I.A. names 경험 정보, 정보 충실성, 독창성, 적시성. The 2025 LLM evaluation targets "실제 경험에 기반하지 않은 광고성 도배글". The 2026 guide asks for "직접 경험한 사람만이 알 수 있는 팁이나 주의 사항".
- Every section must carry at least one checkable circumstance (date, place, duration, price basis, quantity, condition) or a cited fact. A section that only exhorts is padding.
- Photos and captions must evidence a claim in the adjacent text (D.I.A.+ reads image information with body text).

### R3. Keyword use is natural, never inserted
- Restriction criteria (help 5626/22928, 5593/10586): "제목 및 본문에 특정 키워드를 과도하게 삽입하여 방문을 유도", "본문에 숨겨진 키워드", "제목과 본문에 특정 단어를 삽입해 … 이용자가 의도치 않은 정보를 열람케 하는 내용".
- Rule: the target query appears once in the title and wherever the sentence genuinely needs it in the body. No count target, no density target. Repetition that a reader would notice is a failure.
- Hashtags: a few precise topic or entity tags. Never a keyword inventory.

### R4. Title promise = body delivery
- Search Advisor defines 낚시성 as a mismatch between the title/body and the query, with rank loss or exclusion as the consequence, and asks that a reader can predict the core content from the title. The 2026 guide lists 낚시성 among unfavorable traits.
- Rule: the specific answer or finding the title implies appears within the first screen (roughly the first 3-5 sentences on mobile). Curiosity is allowed only when it is specific and the body pays it off immediately; concealment ("이것", "비밀", invented percentages) fails.

### R5. Original text and images only
- 유사문서 판독 separates originals from copies; copied, scraped, mechanically reworded, or supplied-manuscript content is restricted. Reused near-identical photos across posts are also flagged (홈피드 guidance).
- Rule: no pasted vendor copy, no template blocks reused across posts, no image sets recycled from earlier posts.

### R6. No deceptive links, no undisclosed commercial relationship
- Restricted: "명확히 고지되지 않은 이미지 또는 텍스트 링크로 외부 사이트로 유도". 이달의 블로그 exclusion cites 공정위 광고 표시 지침 violations.
- Rule: every external link says where it goes. Sponsorship, free product, or fee is disclosed in plain words at the opening, before any evaluation ("~로부터 제품/원고료를 제공받아 작성했습니다"). Buried tags or "지원" alone fail.

### R7. AI assistance is fine; AI mass production is not
- Official (2024-02-28, 2026-05-26, 2026-07-06): AI use itself is not penalized; "특정 기술의 활용 여부만으로는 판단하지 않습니다". Restricted: AI-only automated publishing, incoherent repetition, identical or similar templates at scale, copied or remixed material.
- Rule: this skill produces **one draft for human review**, never a batch, never an auto-publish. Disclose AI assistance when the user's blog convention or the 'AI 활용' setting calls for it.

### R8. Mobile-readable structure
- D.I.A.+ reads document structure; the 2026 guide names 읽기 쉬운 구조 and 맥락에 맞는 미디어.
- Rule: one idea per paragraph (1-3 sentences), subheadings only at real navigation points, tables for comparisons, lists for steps, images adjacent to the claim they support.

### R9. Never manufacture engagement
- 스팸 사례 (2026-07-06) and 이달의 블로그 exclusion list artificial traffic, comments, recommendations, and 이웃 추가 유도. "이용자 선호도" is a signal family Naver reads; the only disclosed dwell-time use (2016 scroll log) ordered result areas, never individual posts. It is not something the writer simulates or targets.
- Rule: no "댓글 남기면 ~드려요" bait, no like/subscribe pressure, no reciprocal-neighbor calls, no length added to "increase 체류시간". Optimize task completion instead.

### R10. Keep the key facts in text, not only inside images
- 서치어드바이저 콘텐츠 가이드: "검색로봇은 이미지 속 텍스트를 인식하기 어려우므로 사이트 내 핵심 정보는 가급적 텍스트로 작성해 주세요."
- Rule: 가격·수치·조건·절차처럼 독자가 검색으로 찾는 정보는 본문 문장으로 존재해야 합니다. 이미지·인포그래픽은 보조이며 그 정보를 대체하지 않습니다.
- Scope: this is Naver's published site-content guidance, applied here as this skill's own writing rule. It is not independently confirmed as a Naver Blog ranking rule, so never present it as one.
- Source: <https://searchadvisor.naver.com/guide/content-basic> (official, undated; accessed 2026-09-17)

## 3. Planning defaults (`observed`)

Use these to size a draft. State them to the user as defaults, not requirements.

| Parameter | Default | Why it is only observed |
|---|---|---|
| Body length | 1,500-3,000 characters (body only) for an informational or review post; stop when the intent is answered | Practitioners disagree (1,200-1,800 measured on top posts; 1,500-2,000; 2,000-4,000 opinions); Naver publishes no number |
| Images | Cover + one image per claim that a photo can prove; typically 5-12 | Official: image information is read; no count |
| Title | 20-35 characters, target query near the front, a concrete payoff | Input limit is 40; front-loading is a mobile truncation fact, not a rank rule |
| Subheadings | One per reader question, usually 3-6 | Structure is official; count is not |
| First screen | Answer, scope, and the basis of credibility (경험/출처) in the first 3-5 sentences | Follows from R4; the "2-3 lines" figure is practitioner |
| Publishing time | From the author's own 통계 peak, 1-2 hours before | Personal analytics only; no universal hour |
| Freshness | Update or re-date when facts change | 적시성 is official; cadence is not |

## 4. Folklore — do not apply

| Claim | Why it fails |
|---|---|
| "1,500자 이상 필수", "이미지 5장 이상", "키워드 3-5회" | No official number; sources contradict each other; only one measured sample exists |
| "블로그 지수", "최적화/준최적화 블로그" | Naver: "네이버에서 만든 개념이 아닙니다" |
| "1일 1포스팅 / 발행량이 C-Rank를 올린다" | C-Rank FAQ: document count alone is not an advantage; D.I.A. is unrelated to posting cadence |
| "AI로 쓰면 저품질" | Officially denied three times (2024-02, 2026-05, 2026-07); penalties track mass/template production |
| "같은 IP/와이파이면 저품질" | Officially denied 2016-07-12 |
| "체류시간 0이면 감점" / fixed dwell threshold | 이용자 선호도 is a signal; no metric or threshold published |
| "상업 키워드는 자동 저품질" | Actionable conditions are deception, missing disclosure, repeated paid reviews, non-experience copy, not the keyword itself |
| "C-Rank 2.0", "2025년 3월 대란" | Not official terms or events; the proximate official event is the 2025-02-28 notice |
| Backlinks, schema, meta description, Core Web Vitals | Google levers; not author-controllable on blog.naver.com and unnamed by Naver |

## 5. What is different from Google

| Google lever | On Naver blog |
|---|---|
| Backlinks / PageRank | Not a named signal; source trust is topic-lane consistency (C-Rank) |
| E-E-A-T | Analogue is first-hand experience + a coherent topic history; no author schema |
| Technical SEO (CWV, schema, canonical, sitemap, Search Console) | Naver owns the template and hosting; not controllable |
| `<title>` / meta description | Only the visible post title and first screen exist |
| Internal linking as authority flow | Links help readers continue; no graph authority claim |
| Helpful Content | Strongly aligned: experience, originality, completeness, readability |
| Result page | Not ten blue links: intent 스마트블록 mixing blog, cafe, video, 지식iN; AI 브리핑 citations; 홈피드 recommendation |
