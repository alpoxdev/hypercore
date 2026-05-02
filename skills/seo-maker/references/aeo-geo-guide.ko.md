# AEO/GEO/LLMO 전략 가이드

**목적**: AEO/GEO 단계에서 사용하는 AI 검색 최적화 레퍼런스.
**최종 확인**: 2026-04-29, Google Search Central, OpenAI 크롤러 문서, web.dev, arXiv GEO 연구, llms.txt 참고 자료 기준.

## 증거 규율

모든 AEO/GEO 권장사항에 증거 계층을 표시한다:

| 계층 | 의미 | 예시 |
|------|------|------|
| `official` | 플랫폼/벤더 문서 또는 정책 | Google AI 기능 가이드, OpenAI 크롤러 문서 |
| `field` | Search Console, 분석, 서버 로그, 검증된 AI 인용 같은 실제 사용자/검색 데이터 | Search Console 성과, AI referral 로그 |
| `tool` | 결정적 도구 출력 | Rich Results Test, PageSpeed Insights, schema validator |
| `lab` | 통제되었지만 시뮬레이션된 측정 | Lighthouse, 로컬 크롤러, 정적 렌더 체크 |
| `synthetic` | AI 엔진에 대한 프롬프트/인용 probe | 반복 ChatGPT/Perplexity/Gemini 인용 프롬프트 세트 |
| `heuristic` | 모범 사례 추론 또는 업계 관찰 | 40-80단어 answer block, 표/목록 추출 패턴 |

휴리스틱 또는 synthetic 발견사항을 보장된 랭킹/인용 요인처럼 제시하지 않는다. 심각도와 별도로 신뢰도(`high`, `medium`, `low`)를 기록한다.

## 공식 주의사항

- Google은 AI Overviews와 AI Mode가 Search와 동일한 기본 SEO 관행을 사용한다고 설명한다. 포함을 위한 추가 기술 요구사항, 특별한 schema.org 타입 또는 특별한 schema.org 마크업, AI 텍스트 파일은 없다.
- Google AI 기능에서 지원 링크로 표시되려면 페이지가 여전히 색인 가능하고 snippet 대상이어야 한다.
- OpenAI는 ChatGPT Search 포함을 위한 `OAI-SearchBot`과 모델 학습을 위한 `GPTBot`을 분리한다. 둘은 별도로 감사하고 권장해야 한다.
- `llms.txt`는 기계가 읽을 수 있는 콘텐츠 맵으로 유용하지만, 2026-04-29 기준 W3C/IETF 표준도 아니고 주요 제공자가 반드시 가져가는 fetch 계약도 아니다.

## 용어

| 용어 | 전체 이름 | 정의 |
|------|-----------|------|
| **AEO** | Answer Engine Optimization | 보이는 페이지 콘텐츠를 직접 답변으로 추출하기 쉽게 만드는 것 |
| **GEO** | Generative Engine Optimization | AI 생성 답변이 출처를 인용, 언급, 근거로 삼을 가능성을 높이는 것 |
| **LLMO** | Large Language Model Optimization | LLM과 검색 시스템이 콘텐츠를 정확히 파싱, 이해, 재사용하기 쉽게 만드는 것 |
| **AIO** | AI Optimization | 포괄 용어. AEO/GEO가 더 정확할 때는 사용을 피한다 |

## SEO vs AEO vs GEO

| 기준 | SEO | AEO | GEO |
|------|-----|-----|-----|
| **목표** | 크롤링 가능성, 색인 가능성, 랭킹, 검색 노출, CTR | 직접 답변/snippet/음성 스타일 추출 | AI 답변 인용, 브랜드 언급, 출처 선택 |
| **최선의 증거** | Search Console, crawl/index 상태, field CWV, structured data 검증 | snippet controls, 보이는 Q&A/answer blocks, FAQ/QAPage 유효성 | query/prompt probes, 인용 빈도, 공식 crawler 접근, 출처 다양성 |
| **위험** | 랭킹/색인 보장은 없음 | FAQ rich result는 사이트 유형에 따라 제한됨 | 블랙박스 시스템은 달라지므로 결과에 신뢰도 표시가 필요함 |

## AEO 전략

### 직접 답변 블록(`heuristic`)

- 질문형 쿼리를 목표로 하는 섹션 상단 근처에 간결한 답변을 둔다.
- 자연스러울 때 질문과 일치하는 H2/H3 제목을 사용한다.
- 보이는 텍스트, 짧은 단락, 목록, 비교표, 정의/절차 블록을 선호한다.
- 고정 답변 길이 규칙은 휴리스틱으로 취급한다. 40-80단어의 직접 답변은 유용한 작업 범위지만 플랫폼 보장은 아니다.

### FAQ 및 Q&A(`official` + `heuristic`)

- 페이지가 실제로 공통 질문에 답할 때 보이는 FAQ 콘텐츠를 사용한다.
- Google rich result에서 FAQPage eligibility는 제한적이며, `FAQPage` eligibility는 잘 알려진 권위 있는 정부 또는 건강 중심 사이트로 제한된다. 일반 사이트에서도 FAQ 콘텐츠는 사용자와 답변 추출에 도움이 될 수 있지만 Google FAQ rich result를 약속하지 않는다.
- 사용자가 하나의 질문에 여러 답변을 제출할 수 있으면 `FAQPage` 대신 `QAPage`를 사용한다.
- 구조화 데이터는 보이는 콘텐츠와 일치해야 하며 숨겨졌거나 무관하거나 오해를 부르는 정보를 마크업하지 않아야 한다.

## GEO 전략

GEO는 부분적으로 실험적이며 가능하면 query set 또는 citation probe로 측정해야 한다.

### GEO CORE 프레임워크

| 차원 | 점검 항목 | 증거 예시 |
|------|-----------|-----------|
| Context | 완전한 배경, 정의, 관련 개념 | 주제 커버리지 맵, query fan-out gap |
| Organization | 추출 가능한 계층, 표/목록, 짧은 섹션 | H2/H3 스캔, answer block detector |
| Reliability | 출처, 날짜, 작성자/사이트 신뢰, 사실 검증 가능성 | 인용, 작성자 bio, organization schema, 외부 참고자료 |
| Exclusivity | 원본 연구, 독점 데이터, 고유 사례 | 1자 벤치마크, 사례 연구, 원본 스크린샷/데이터 |

### 인용 가능한 콘텐츠(`synthetic`/`heuristic`, probe 전까지)

- 주변 맥락 없이도 인용할 수 있는 짧고 독립적인 문장을 쓴다.
- 사실 주장에는 날짜, 출처명, 링크를 추가한다.
- 원본 데이터, 비교, 벤치마크 표, 명확히 범위가 정해진 정의를 선호한다.
- AI 답변 조작만을 목적으로 페이지를 만들지 않는다. 사람에게 유용한 콘텐츠를 기본 목표로 유지한다.

### Query fan-out simulator

AI 검색을 위해 주제를 최적화할 때 다음 범주에서 10-30개의 하위 쿼리를 생성한다:

- 정의와 입문 질문
- 비교와 대안
- 가격, 위험, 제한사항, 구현 질문
- 엔터티/브랜드/제품 질문
- 관련성이 있을 때 지역, 산업, YMYL 변형

미커버 하위 주제를 `results.json.query_fanout`에 기록하고 우선순위 콘텐츠 권장사항으로 전환한다.

### AI citation probe

런타임과 사용자 권한이 허용하면 AI 검색 엔진 전반에서 안정적인 프롬프트 세트를 실행하고 다음을 기록한다:

- 엔진, 날짜, 지역/언어, 프롬프트 텍스트, 표본 크기
- 인용 URL, 브랜드 언급, sentiment, 경쟁사 share of voice
- 반복 실행 변동성과 신뢰도

Probe를 사용할 수 없으면 신호가 있는 것처럼 꾸미지 말고 prompt pack을 `not-run`으로 저장한다.

## 플랫폼 정책 매트릭스

| 플랫폼/봇 | 주요 목적 | 최적화 의미 |
|-----------|-----------|-------------|
| Googlebot | Google 크롤링/색인/검색 snippet | 의도적으로 제외하지 않는 한 중요한 색인 가능 페이지와 리소스를 허용해야 함 |
| Google-Extended | 일반 Search 크롤링 외 Google AI 제품/학습 제어 | Search visibility 결정과 분리 |
| OAI-SearchBot | ChatGPT Search 포함 | ChatGPT Search visibility를 원하면 허용 |
| GPTBot | OpenAI 모델 학습 | OAI-SearchBot과 독립적으로 허용 또는 차단 가능 |
| ChatGPT-User | 사용자 트리거 fetch | 일반 자동 search crawler가 아니므로 별도 문서화 |
| PerplexityBot / ClaudeBot | 문서화되었거나 관찰되는 AI 검색/크롤링 | robots/server rules를 감사하되 권장사항에 증거 계층 표시 |

## llms.txt

`llms.txt`를 선택적이고 저위험인 콘텐츠 맵으로 사용한다:

```text
# llms.txt
> Site: example.com
> Description: One-line site description

## Core pages
- /about: Company overview
- /docs: Technical documentation
- /blog/key-topic: Best overview of the topic
```

규칙:

- 누락된 `llms.txt`를 기본적으로 critical로 표시하지 않는다.
- 문서 사이트, 개발자 도구, API reference, 콘텐츠가 많은 제품에서 가장 강하게 권장한다.
- canonical URL 및 sitemap 우선순위와 일치시킨다.

## 측정 KPI

| KPI | 설명 | 선호 증거 |
|-----|------|-----------|
| AI Citation Frequency | 대상 URL이 AI 답변에 인용되는 빈도 | Synthetic probes 또는 AI visibility tools |
| Brand Mention Rate | 브랜드/엔터티가 언급되는 빈도 | Synthetic probes, AI referrals, third-party tools |
| Share of Voice | 경쟁사 대비 인용/언급 점유율 | 경쟁사를 포함한 반복 프롬프트 세트 |
| AI Overview Inclusion | Google AI 기능이 사이트 링크를 포함하는지 여부 | Search Console/Web 성과와 수동 SERP 증거 |
| Citation Sentiment | 긍정/중립/부정 프레이밍 | 수동 또는 도구 보조 검토 |
| AI-referred Conversion | AI/search referrer에서 온 전환 | Analytics/server logs |

## 실무 최적화 순서

1. 색인 가능성, 크롤링 가능성, canonical 정확성, snippet eligibility를 보장한다.
2. 보이는 콘텐츠 품질, 신뢰 신호, 구조화 데이터 일치성을 검증한다.
3. 사람에게 유용한 곳에 answer blocks와 Q&A 콘텐츠를 추가한다.
4. 출처, 원본 데이터, 명확한 엔터티를 갖춘 인용 가능한 섹션을 만든다.
5. OAI-SearchBot과 GPTBot 분리를 포함해 플랫폼 crawler 정책을 감사한다.
6. 콘텐츠 맵을 위해 선택적으로 `llms.txt`를 추가한다.
7. 접근 권한이 허용되면 query fan-out과 citation probes를 실행한 뒤 `score_history`와 `best_run`으로 반복 개선한다.
