# Naver Search and Blog Algorithm Timeline (Official Sources Only)

> Korean version: [`naver-algorithm-timeline.ko.md`](naver-algorithm-timeline.ko.md)

Read this when a request asks *why* a rule exists, when the writer or user cites an algorithm name (C-Rank, D.I.A., 스마트블록, AI 브리핑), or when checking whether a circulating claim is current. Every row is an official Naver publication; practitioner interpretation is excluded. Accessed 2026-09-16.

## 1. Ranking systems still in force

| Date | System | What Naver said it evaluates | Source |
|---|---|---|---|
| 2016-07-29 | C-Rank | Topic-specific trust and popularity of the *source* (blog). | <https://blog.naver.com/naver_search/220774795442> |
| 2017-05-17 | C-Rank FAQ | Topic inferred from title and body; topical continuity; quality; interaction; source trust. Explicitly: "단순히 문서 수가 많다고 유리한 것은 아니고". Rejects the "최적화 블로그" concept. | <https://blog.naver.com/naver_search/221008093810> |
| 2018-06-12 | D.I.A. | *Document*-level: 주제 적합도, 경험 정보, 정보 충실성, 문서 의도, 어뷰징 척도, 독창성, 적시성, 사용자 선호. Explicitly: "출처별 글 작성 주기와는 관련성이 없습니다". | <https://blog.naver.com/naver_search/221297090120> |
| 2018-10-30 | 유사문서 판독 | Separates originals from copied or near-duplicate documents; originals are preferred. | <https://blog.naver.com/naver_search/221387860477> |
| 2020-11-18 | D.I.A.+ | Query-intent clustering, query patterns, document structure, body text, image information, document expansion, user feedback, dynamic ranking. | <https://blog.naver.com/naver_search/222147478268> |
| 2021-12-02 | 스마트블록 / AiRSEARCH | Groups results into intent-specific blocks by topic and preference. | <https://blog.naver.com/naver_search/222584588816> |
| 2024-02-01 | VIEW → 스마트블록 | VIEW results fully integrated into 스마트블록; VIEW tab becomes separate 블로그 and 카페 tabs. Compound queries are split into intent units (e.g. 캠핑요리 / 캠핑용품 / 캠핑장소). | <https://blog.naver.com/naver_search/223339984506> |
| 2024-06-13 | 생성형 AI 스마트블록 | LLM re-ranks blog, cafe, video, and 지식iN documents together — "출처나 유형을 구분하지 않고 함께 랭킹". | <https://blog.naver.com/naver_search/223474959025> |
| 2025-02-28 | UGC 노출 시스템 고도화 | Names C-Rank, D.I.A.+, and 유사문서 판독 as current systems; adds LLM evaluation to surface trusted sources and to detect "자동 생성된 저품질 콘텐츠나 실제 경험에 기반하지 않은 광고성 도배글"; faster duplicate detection. | <https://blog.naver.com/naver_search/223777208497> |
| 2025-11-24 | 신뢰도 중심 통합 랭킹 A/B | Authoritative, official, or expert sources may outrank merely relevant documents for a query. Still described as a test. | <https://blog.naver.com/naver_search/224083616020> |

## 2. Surfaces a blog post can appear in (2026-09)

| Surface | Official note | Source |
|---|---|---|
| 통합검색 스마트블록 (intent slices) | Cross-format ranking with cafe, video, 지식iN. | <https://blog.naver.com/naver_search/223474959025> |
| 블로그 탭 | Replaced VIEW tab, 2024-02. | <https://blog.naver.com/naver_search/223339984506> |
| AI 브리핑 citation | Launched 2025-03-24; each generated sentence cites a source; "AI 브리핑이 언제나 검색 결과에 노출되는 것은 아닙니다". | <https://blog.naver.com/naver_search/223807628464> |
| 검색피드 (mobile, local/travel) | Recommends UGC and 클립 after a relevant search. | <https://blog.naver.com/naver_search/223676735545> |
| 앱 홈피드 | Based on subscriptions, consumed documents, search history, neighbor relations, and blog activity. | <https://blog.naver.com/blogpeople/223469921471>, <https://blog.naver.com/blogpeople/224003753265> |
| 주제판 / 블로그 추천탭 | Requires a correctly selected topic; "블로그 주제 선택이 각 추천 영역의 노출을 보장하지는 않습니다". | <https://blog.naver.com/blogpeople/223472043806> |
| 블로그 내 검색 (인기글, 이미지) | Reorganized 2025-01/02. | <https://blog.naver.com/blogpeople/223733437417> |
| 인플루언서 검색 | Program members only; topic expertise plus content relevance. | <https://blog.naver.com/naver_search/222177524822> |
| 클립 surfaces | Only when the creator separately publishes 클립; a blog post is not auto-converted. | <https://blog.naver.com/naver_search/224312639595> |

## 3. Content guidance Naver published for writers

| Date | Guidance | Source |
|---|---|---|
| 2024-02-28 | Generative-AI policy: "생성형 AI 활용 여부와는 무관하게, 다른 사용자에게 도움이 되는 정보를 담고 있는 좋은 문서들이 검색에 더 많이 노출될 수 있습니다". Good document = 신뢰성, 독창성, 직접 경험, 심층성, 가독성. Abuse = AI-only automated publishing, incoherent repetition, mass same/similar content, copied or remixed material. Disclosure of AI use recommended. | <https://blog.naver.com/naver_search/223367781299> |
| 2024-06-05 | 홈피드 title and thumbnail: concise title, cover image showing the key point; avoid 동어 반복, excessive text on covers, reused similar photos, copied or advertorial posts. | <https://blog.naver.com/blogpeople/223469921471> |
| 2026-05-26 | AI 시대 콘텐츠 작성 가이드: a channel that keeps publishing quality posts on one topic is recognized as that field's "전문 출처". Favorable: 직접 경험, 일관된 주제, 진정성 (including disclosure), 읽기 쉬운 구조, 최신성. Unfavorable: 반복 키워드, 낚시성, 짜깁기, 기계적 AI 생성, 과도한 홍보. "AI 도구를 사용했다고 해서 무조건 패널티를 받지는 않습니다". | <https://blog.naver.com/naver_search/224296857688> |
| 2026-06-04 | 실전편 self-check: 독자와 목적, 구체적 절차, 대안 비교, 실제 결과, 맥락에 맞는 미디어; "직접 경험한 사람만이 알 수 있는 팁이나 주의 사항". | <https://blog.naver.com/naver_search/224305800678> |
| 2026-07-06 | 웹 콘텐츠 스팸 사례: "특정 기술의 활용 여부만으로는 판단하지 않습니다" — the violation is meaningless mass production from identical or similar templates, artificial traffic, comments, or recommendations. | <https://blog.naver.com/naver_search/224335446939> |
| undated (accessed 2026-09-17) | 서치어드바이저 콘텐츠 작성 5원칙: 전문성과 경험을 바탕으로 작성하기, 일관된 주제로 정체성 만들기, 진정성을 담고 투명하게 소통하기, 읽기 쉬운 구조, 최신 정보 유지. 또 "검색로봇은 이미지 속 텍스트를 인식하기 어려우므로 사이트 내 핵심 정보는 가급적 텍스트로 작성해 주세요"(부득이하면 alt). **The page carries no publication or revision date.** | <https://searchadvisor.naver.com/guide/content-basic> |
| undated (accessed 2026-09-17) | 검색 의도 기반 랭킹과 제목 원칙: "네이버는 검색 사용자의 선호도를 기반으로 한 랭킹 알고리즘을 사용하여 검색 사용자의 의도를 가장 잘 반영한 문서가…", "제목은 글의 내용을 대표할 수 있는, 명확하고 간결한 것이 좋습니다". 검색어를 인위적으로 반복한 문서는 검색 사용자의 선호도가 떨어져 후순위로 밀린다는 설명. | <https://m.blog.naver.com/naver_search/220736004033> |

## 4. Claims Naver has never made

These circulate widely and have no official source. Do not present them as rules.

- A numeric weight, threshold, or "블로그 지수". Naver: "저품질 블로그, 최적화 블로그, 블로그 지수 등은 네이버에서 만든 개념이 아닙니다". <https://help.naver.com/service/5593/contents/10585?lang=ko>
- A required character count, image count, keyword count, or publishing hour.
- "C-Rank 2.0", a "March 2025 algorithm change" (the proximate official event is the 2025-02-28 notice), or the removal of D.I.A.+ (still named in 2025-02).
- Same-IP or same-Wi-Fi as a standalone penalty (officially denied 2016-07-12: <https://blog.naver.com/naver_search/220760111725>).
- Discontinuation of 연관검색어 in 2026 — reported by English-language guides only; no official notice found.
