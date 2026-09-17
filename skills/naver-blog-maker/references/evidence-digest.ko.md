# 근거 요약: 리서치가 찾은 것과 그것이 이 스킬 어디에 있는지

> 영어 원본: [`evidence-digest.md`](evidence-digest.md)

스킬을 유지보수할 때, 사용자가 규칙에 이의를 제기할 때("근거가 뭐야?"), 새 네이버 공지를 현행 계약과 맞춰야 할 때 읽습니다. 각 행은 2026-09-16 리서치(출처 149개, 도메인 21개, 1차 출처 79개, 스켑틱 7라운드)에서 찾은 사실, 그것이 공급하는 규칙, 다시 확인할 1차 URL을 적습니다. 확인일 2026-09-16.

## 1. 랭킹 시스템 → `rules/naver-ranking-contract.ko.md` R1, R2, R8

| 발견 | 규칙 | 1차 출처 |
|---|---|---|
| C-Rank는 *출처*를 주제별로 평가. 문서 수만으로는 유리하지 않음 | R1 주제 레인 | <https://blog.naver.com/naver_search/221008093810> |
| D.I.A.는 *문서*를 평가: 주제 적합도, 경험 정보, 정보 충실성, 문서 의도, 어뷰징, 독창성, 적시성. 작성 주기와 무관 | R2 섹션별 근거 | <https://blog.naver.com/naver_search/221297090120> |
| D.I.A.+는 구조, 본문, 이미지 정보, 사용자 피드백을 읽음 | R2, R8 | <https://blog.naver.com/naver_search/222147478268> |
| 스마트블록이 복합 검색어를 의도 단위로 분해. 2024-06 LLM이 블로그·카페·영상·지식iN을 함께 리랭킹 | R1 의도 슬라이스 하나 | <https://blog.naver.com/naver_search/223339984506>, <https://blog.naver.com/naver_search/223474959025> |
| 2025-02-28: C-Rank, D.I.A.+, 유사문서 판독을 현행으로 명시. LLM 평가 추가 | R2, R5, R7 | <https://blog.naver.com/naver_search/223777208497> |
| 2026-05-26: "전문 출처" = 한 주제를 지속 발행하는 채널. 유리 직접 경험·일관된 주제·진정성·구조·최신성, 불리 반복 키워드·낚시성·짜깁기·기계적 AI·과도한 홍보 | R1~R4, R7 | <https://blog.naver.com/naver_search/224296857688> |
| 실제 검색 결과(상위 15편): 상업 검색어는 블로그 블록이 5~11번째, 정보형은 AI 브리핑 뒤 3번째 | `topic-research.ko.md` §1, `keyword-research.ko.md` §1 | 관찰, 세션 20260916-163039 |

## 2. 제한과 "저품질" → R3, R5, R6, R9, 속설 표

| 발견 | 규칙 | 1차 출처 |
|---|---|---|
| 공식 제한 목록: 키워드 과도 삽입, 숨김 키워드, 미고지 외부 링크 유도, 기계적 대량 생성, 개인정보 | R3, R6, R7 | <https://help.naver.com/service/5626/contents/22928?lang=ko> |
| "제목과 본문에 특정 단어를 삽입해 … 의도치 않은 정보를 열람케 하는 내용" 제한 | R3, R4 | <https://help.naver.com/service/5593/contents/10586?lang=ko> |
| 낚시성 = 제목·본문과 검색어 불일치 → 순위 하락·제외. 독자가 제목으로 내용을 예측할 수 있어야 함 | R4 | <https://searchadvisor.naver.com/guide/content-abusing>, <https://searchadvisor.naver.com/guide/content-basic> |
| "저품질 블로그, 최적화 블로그, 블로그 지수 등은 네이버에서 만든 개념이 아닙니다" | 속설 표 | <https://help.naver.com/service/5593/contents/10585?lang=ko> |
| 같은 IP만으로는 스팸 판단 불가 | 속설 표 | <https://blog.naver.com/naver_search/220760111725> |
| 24시간 반영. 의도 불부합·스팸·유사문서로 판독되면 미노출 | R5, 발행 전 메모 | <https://help.naver.com/service/5593/contents/9564?lang=ko> |
| 인위적 트래픽·댓글·추천, 이웃 추가 유도는 어뷰징 | R9 | <https://blog.naver.com/naver_search/224335446939>, <https://help.naver.com/service/5593/contents/15195?lang=ko> |
| 비경험 원고, 유료 후기 공개 누락·반복은 불이익 가능 | R2, R6 | <https://blog.naver.com/naver_search/221570404745> |

## 3. AI 콘텐츠 정책 → R7

| 발견 | 1차 출처 |
|---|---|
| 2024-02-28: AI 사용 자체는 불이익 아님. 대량·앞뒤 안 맞는·복사 산출물이 문제. 공개 권장 | <https://blog.naver.com/naver_search/223367781299> |
| 2026-05-26: "AI 도구를 사용했다고 해서 무조건 패널티를 받지는 않습니다" | <https://blog.naver.com/naver_search/224296857688> |
| 2026-07-06: "특정 기술의 활용 여부만으로는 판단하지 않습니다". 템플릿 대량 생산이 스팸 | <https://blog.naver.com/naver_search/224335446939> |
| 'AI 활용' 표시 설정. 표시해도 정책 위반이면 제한 가능 | <https://help.naver.com/service/30016/contents/24136?lang=ko> |

## 4. 수치 임계값 → observed 기본값 표, 속설 표

- 공식 글자수·이미지수·키워드 횟수는 없음. 서치어드바이저: 단어가 많다고 순위가 오르지 않으며 반복은 어뷰징. <https://searchadvisor.naver.com/guide/content-basic>
- 떠도는 레시피(이미지 5~10장, 키워드 5~10회, 1,000~1,500자)는 2014~16년 실무자 글 → 서로 모순되는 에이전시 SOP로 이어짐. 통제 실험은 없음.
- 실제 상위 글은 900~5,700자, 이미지 3~36장, 해시태그 0~24개. 스킬의 1,500~3,000자는 계획 범위이지 규칙이 아님.

## 5. 반응과 체류 → R9

- "이용자 선호도"는 공식 고려 요소. 공개된 유일한 체류시간 메커니즘(2016 스크롤 로그)은 결과 *영역* 순서를 정했고 개별 글은 아님. 글 단위 지표나 임계값은 공개된 적 없음. <https://help.naver.com/service/5626/contents/1424?lang=ko>, <https://m.blog.naver.com/naver_search/220737870376>

## 6. 훅과 제목 → `references/hook-library.ko.md`

- 질문형·숫자형 제목은 네이버 밖 현장 실험에서 반응이 올랐고, 수사적 질문은 신뢰도가 떨어질 수 있으며, 부정 표현은 클릭을 올리지만 공포 주장의 면허는 아님. 랭킹 요소가 아니라 카피라이팅 가설로 취급. (DOI 출처는 세션 레저.)
- 시드 프롬프트 어휘를 항목별로 감사. 숨김, 만들어낸 퍼센트, 절대 표현은 낚시성 정의에 해당해 삭제.

## 7. 키워드 리서치 → `references/keyword-research.ko.md`

- 수요·공급 비교가 지배적 실무 방법(5개 출처). 수치 구간은 단일 출처.
- 공개 지면은 누적 문서수(블로그 검색 페이지)와 데이터랩 상대 트렌드만 줌. 자동완성은 실제 페이지, 절대 검색량은 광고주 로그인, 스마트블록 순서는 통합검색에서만 보임.

## 8. 구글 vs 네이버 → 계약 §5

- 백링크, CWV, 스키마, 메타, Search Console은 blog.naver.com에서 작성자가 제어할 수 없고 네이버가 명시하지 않음. 블로그·카페 페이지는 자동 반영. <https://help.naver.com/service/30010/contents/18300?lang=ko>
- 소유 사이트에는 href 링크와 구조화 데이터를 사용. 인위 대량 백링크는 출처와 대상 모두 불이익. <https://searchadvisor.naver.com/guide/resource-and-link>, <https://searchadvisor.naver.com/guide/structured-data-intro>, <https://searchadvisor.naver.com/guide/content-abusing>

## 9. 선행 사례 → 이 스킬이 더한 것

공개된 네이버 글 프롬프트·스킬 16개를 읽음. 공식과 속설을 분리한 것, 지어낸 경험을 막는 것, 제목 약속 이행을 검증하는 것, 측정을 공개한 것은 하나도 없음. 이 스킬은 근거 등급, `[확인 필요]` 슬롯 규칙, 인라인 이미지 마커, 공개 우선 규칙, 텍스트 블록 전달을 더함.

## 10. 미해결 (사실로 넣지 않음)

- 2026년 연관검색어 종료: 영어권 가이드만. 공식 공지 없음.
- 신뢰도 중심 통합 랭킹: 2025-11 A/B 테스트로 발표. 정식 적용 여부 불명.
- AI 브리핑 인용 선택 가중치: 미공개. 2026-05 가이드는 특성만 나열.
