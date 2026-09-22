# Evidence Digest: What the Research Found and Where It Lives in This Skill

> Korean version: [`evidence-digest.ko.md`](evidence-digest.ko.md)

Read this when maintaining the skill, when a user challenges a rule ("근거가 뭐야?"), or when a newer Naver announcement must be reconciled with the current contract. Each row names a finding from the 2026-09-16 research run (149 sources, 21 domains, 79 primary; 7 skeptic rounds), the rule it feeds, and the primary URL to re-check. Accessed 2026-09-16.

## 1. Ranking systems → `rules/naver-ranking-contract.md` R1, R2, R8

| Finding | Rule | Primary source |
|---|---|---|
| C-Rank scores the *source* by topic; document count alone is not an advantage | R1 topic lane | <https://blog.naver.com/naver_search/221008093810> |
| D.I.A. scores the *document*: 주제 적합도, 경험 정보, 정보 충실성, 문서 의도, 어뷰징, 독창성, 적시성; publishing cadence is unrelated | R2 evidence per section | <https://blog.naver.com/naver_search/221297090120> |
| D.I.A.+ reads structure, body, image information, user feedback | R2, R8 | <https://blog.naver.com/naver_search/222147478268> |
| 스마트블록 splits compound queries into intent units; 2024-06 LLM re-ranks blog/cafe/video/지식iN together | R1 one intent slice | <https://blog.naver.com/naver_search/223339984506>, <https://blog.naver.com/naver_search/223474959025> |
| 2025-02-28: C-Rank, D.I.A.+, 유사문서 판독 named as current; LLM evaluation added | R2, R5, R7 | <https://blog.naver.com/naver_search/223777208497> |
| 2026-05-26: "전문 출처" = channel that keeps publishing one topic; favorable 직접 경험·일관된 주제·진정성·구조·최신성; unfavorable 반복 키워드·낚시성·짜깁기·기계적 AI·과도한 홍보 | R1-R4, R7 | <https://blog.naver.com/naver_search/224296857688> |
| Live SERP (15 top posts): commercial queries place the blog block 5th-11th; informational queries 3rd after AI 브리핑 | `topic-research.md` §1, `keyword-research.md` §1 | observation, session 20260916-163039 |

## 2. Restrictions and "저품질" → R3, R5, R6, R9, folklore table

| Finding | Rule | Primary source |
|---|---|---|
| Official restriction list: keyword over-insertion, hidden keywords, undisclosed external-link inducement, mechanical mass generation, personal data | R3, R6, R7 | <https://help.naver.com/service/5626/contents/22928?lang=ko> |
| "제목과 본문에 특정 단어를 삽입해 … 의도치 않은 정보를 열람케 하는 내용" is restricted | R3, R4 | <https://help.naver.com/service/5593/contents/10586?lang=ko> |
| 낚시성 = title/body–query mismatch → rank loss or exclusion; readers must predict content from the title | R4 | <https://searchadvisor.naver.com/guide/content-abusing>, <https://searchadvisor.naver.com/guide/content-basic> |
| "저품질 블로그, 최적화 블로그, 블로그 지수 등은 네이버에서 만든 개념이 아닙니다" | folklore table | <https://help.naver.com/service/5593/contents/10585?lang=ko> |
| Same IP alone cannot determine spam | folklore table | <https://blog.naver.com/naver_search/220760111725> |
| 24-hour reflection; posts judged off-intent, spam, or duplicate are not shown | R5, publish note | <https://help.naver.com/service/5593/contents/9564?lang=ko> |
| Artificial traffic, comments, recommendations, 이웃 추가 유도 are abuse | R9 | <https://blog.naver.com/naver_search/224335446939>, <https://help.naver.com/service/5593/contents/15195?lang=ko> |
| Non-experience manuscripts, missing or repeated paid-review disclosure can disadvantage a post | R2, R6 | <https://blog.naver.com/naver_search/221570404745> |

## 3. AI-content policy → R7

| Finding | Primary source |
|---|---|
| 2024-02-28: AI use itself is not penalized; mass/incoherent/copied output is; disclosure recommended | <https://blog.naver.com/naver_search/223367781299> |
| 2026-05-26: "AI 도구를 사용했다고 해서 무조건 패널티를 받지는 않습니다" | <https://blog.naver.com/naver_search/224296857688> |
| 2026-07-06: "특정 기술의 활용 여부만으로는 판단하지 않습니다"; template mass production is spam | <https://blog.naver.com/naver_search/224335446939> |
| 'AI 활용' display setting; a labeled post can still be restricted for policy violations | <https://help.naver.com/service/30016/contents/24136?lang=ko> |

## 4. Numeric thresholds → observed defaults table, folklore table

- No official character, image, or keyword count exists; Search Advisor says more words do not raise rank and repetition is abuse. <https://searchadvisor.naver.com/guide/content-basic>
- The circulating recipe (5-10 images, 5-10 keyword mentions, 1,000-1,500자) traces to 2014-16 practitioner posts and later agency SOPs with incompatible numbers; no controlled experiment was found.
- Live top posts span 900-5,700 characters, 3-36 images, 0-24 hashtags. The skill's 1,500-3,000 default is a planning range, never a rule.

## 5. Engagement and dwell → R9

- "이용자 선호도" is an official consideration; the only disclosed dwell-time mechanism (2016 scroll log) ordered result *areas*, not individual posts. No per-post metric or threshold is published. <https://help.naver.com/service/5626/contents/1424?lang=ko>, <https://m.blog.naver.com/naver_search/220737870376>

## 6. Hooks and titles → `references/hook-library.md`

- Question and number titles showed engagement gains in non-Naver field experiments; credibility can drop for rhetorical questions; negativity lifts clicks but is not licence for fear claims. Treated as copywriting hypotheses, not ranking factors. (DOI sources in session ledger.)
- Seed prompt vocabulary audited item by item; concealment, invented percentages, and absolutes fall under the 낚시성 definition and are dropped.

## 7. Keyword research → `references/keyword-research.md`

- Demand-vs-supply comparison is the dominant practitioner method (5 sources); numeric bands are single-source.
- Public surfaces give a lifetime document count (blog search page) and DataLab relative trends only; autocomplete needs the live page, absolute volume needs an advertiser login, and 스마트블록 order is visible only on 통합검색.

## 8. Google vs Naver → contract §5

- Backlinks, CWV, schema, meta, Search Console are not author-controllable on blog.naver.com and are not named by Naver; blog/cafe pages are auto-reflected. <https://help.naver.com/service/30010/contents/18300?lang=ko>
- For owned websites Naver does use href links and structured data; artificial mass backlinks penalize source and target. <https://searchadvisor.naver.com/guide/resource-and-link>, <https://searchadvisor.naver.com/guide/structured-data-intro>, <https://searchadvisor.naver.com/guide/content-abusing>

## 9. Prior art → what this skill adds

Sixteen public Naver-post prompts and skills were read. None separates official from folklore, none gates fabricated experience, none validates title-promise fulfilment, none disclosed a measurement. This skill adds the evidence tiers, the `[확인 필요]` slot rule, the inline image markers, the disclosure-first rule, and the text-block delivery.

## 10. Unresolved (do not encode as fact)

- 연관검색어 discontinuation in 2026: English-language guides only; no official notice found.
- 신뢰도 중심 통합 랭킹: announced as an A/B test 2025-11; rollout status unknown.
- AI 브리핑 citation selection weights: unpublished; the 2026-05 guide lists traits, not weights.

## Sources

> Every URL cited above was re-checked 2026-09-21 (all HTTP 200). The findings themselves come from the 2026-09-16 research run recorded in `.omo/ulw-research/20260916-163039/sources-ledger.md`.

The per-row links are Naver's own posts and help pages (`blog.naver.com/naver_search`, `blog.naver.com/blogpeople`, `searchadvisor.naver.com`, `help.naver.com`). Three groups carry no external source and are marked as such in the body: §4's numeric ranges (this repository's own measurement of live top posts), §6's field experiments (DOIs in the session ledger; not re-verified here), and §10 (unresolved items). [`naver-algorithm-timeline.md`](naver-algorithm-timeline.md) holds the same official links with their publication dates.
