# Keyword and Intent Research for Naver Blog

> Korean version: [`keyword-research.ko.md`](keyword-research.ko.md)

Read this in step 2 of [`../rules/post-workflow.md`](../rules/post-workflow.md) when the user has not fixed the target query, or when the chosen query looks too broad or too commercial for a blog post. It documents what practitioners do, which parts are readable from public pages, and which numbers are heuristics.

## 1. What the target query has to be

- **One intent slice.** `[official, T3]` Since 2024-02 Naver splits compound queries into intent units and ranks each 스마트블록 separately (`캠핑` → 캠핑요리 / 캠핑용품 / 캠핑장소). The query must name the slice the post answers.
- **A slice where blog posts actually surface.** `[observed, T3]` For purchase or booking queries the first screen is often Shopping, Place, or ads; blog posts appear in a 후기/비교/인기글 block further down or not at all. Look before writing.
- **Inside the author's topic lane.** `[official, T1]` C-Rank trust is topic-specific; a great post in a lane the blog has never covered starts without source trust.

## 2. Procedure

1. **Expand** the seed with modifiers: place (`강남`, `제주`), audience (`아이와`, `혼자`), model or variant, problem (`누수`, `소음`), price (`가격`, `비용`), season, and job words (`후기`, `비교`, `추천`, `방법`, `주의`). Autocomplete, 연관검색어, and 함께 많이 찾는 검색어 are browser-only surfaces; collect them with browser tooling or ask the user to paste them.
2. **Measure supply and demand separately.**
   - Supply: how many blog documents already match the exact phrase.
   - Demand: relative interest over time, seasonality, device split.
   - Compare candidates on both; prefer the slice with real demand and thinner, weaker supply. A ratio is a triage aid, not a ranking probability — document counts and search counts come from different collection scopes.
3. **Read the live SERP** for the top 2-3 candidates: block order, block headings, whether the blog block is above the fold, what the top three posts promise and what they lack (missing downside, no price basis, stale date). The gap is the post's angle.
4. **Decide in one line** and keep it with the draft: the six-field decision line from `../rules/post-workflow.md` §2 — `검색어 / 의도 슬라이스 / 주 유형 / 보조 유형 / 목표 / 근거` — fed by this procedure's counts and SERP notes.

## 3. Reading supply and demand without any CLI

All three measurements are available on public pages a visitor can open:

| Need | Where | What the number means | What it is not |
|---|---|---|---|
| Supply proxy | Naver blog search result page for the exact phrase (블로그 탭 결과 수), or a public keyword tool's 문서수 column | Lifetime blog documents matching the phrase | Not monthly issuance; not a saturation score |
| Demand shape | 네이버 데이터랩 검색어트렌드 (<https://datalab.naver.com/keyword/trendSearch.naver>): compare 2-5 candidates, mobile vs PC, weekly | Relative index, max = 100 inside the compared group | Not search volume |
| Top-post survey | The first 10-20 blog results for the phrase | Titles, first screens, headings for the gap analysis in `../rules/topic-research.md` §2 | Not the 스마트블록 order shown in 통합검색 — read that separately |

Not available without login: absolute monthly search volume, clicks, CTR (네이버 검색광고 키워드도구). Never invent them.

## 4. Third-party tools practitioners use

| Tool | Gives | Access | Caveat |
|---|---|---|---|
| 네이버 검색광고 키워드도구 | PC/mobile monthly searches, clicks, CTR, competition | Advertiser login | No document counts |
| 네이버 데이터랩 검색어트렌드 | Relative trend by period, device, gender, age | Public | Relative, not volume |
| 블랙키위 | Volume, monthly issuance, saturation, related terms, section layout | Tiered (guest / free / paid) | Limits change; verify in browser |
| 키워드마스터 (WhereIsPost) | Volume, blog document count, docs/searches ratio, CSV | Public | Its own page warns the two counts have different scopes |

## 5. Heuristics and their evidence grade

| Heuristic | Grade | Note |
|---|---|---|
| Compare 검색량 vs 문서수 before choosing | observed (5 sources) | The method, not any threshold |
| Prefer monthly issuance over lifetime documents when freshness matters | observed (3 sources) | — |
| Schedule seasonal posts before the rise the trend shows | observed | DataLab is official; lead time is not |
| `docs / monthly searches ≤ 1` is a good target | single source | Internally inconsistent wording; triage only |
| `200-1,000 mobile searches` is the right band for a small blog | single source | One author's audience filter |
| A commercial query with a Shopping/Place-heavy SERP is a weak blog target unless the post is the review/comparison readers want | observed (2 sources) | Confirm on the live SERP |
