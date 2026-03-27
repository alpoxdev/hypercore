# AEO/GEO/LLMO Strategy Guide

**Purpose**: AI 검색 최적화 전략 레퍼런스. AEO/GEO Phase에서 참조.

## Terminology

| Term | Full Name | Definition |
|------|-----------|------------|
| **AEO** | Answer Engine Optimization | AI가 직접 답변으로 선택하도록 콘텐츠 최적화 |
| **GEO** | Generative Engine Optimization | AI 생성 응답에서 소스로 인용되도록 최적화 |
| **LLMO** | Large Language Model Optimization | LLM이 콘텐츠를 정확히 이해/추출/재사용하도록 최적화 |
| **AIO** | AI Optimization | 위 세 가지를 포괄하는 통칭 |

이 용어들은 업계에서 혼용되나, 스킬에서는 AEO(답변 선택), GEO(인용 최적화)로 구분한다.

## SEO vs AEO vs GEO

| Criteria | SEO | AEO | GEO |
|----------|-----|-----|-----|
| **목표** | 검색 결과 상위 랭킹 | 직접 답변으로 선택 | AI 생성 응답에서 인용 |
| **대상** | Google, Bing 전통 검색 | Featured Snippets, 음성 검색 | ChatGPT, Perplexity, AI Overviews |
| **측정** | 순위, CTR, 트래픽 | 답변 선택률 | AI 인용 빈도, 브랜드 멘션율 |
| **겹침** | — | SEO와 60-70% | SEO/AEO와 60-70% |

## GEO CORE Framework

AI 인용 최적화를 위한 4대 평가 기준:

### Context (맥락)
- 주제에 대한 충분한 배경과 맥락 제공
- 관련 개념, 정의, 역사적 배경 포함
- 독자가 주제를 완전히 이해할 수 있는 깊이

### Organization (구조)
- 명확한 H2/H3 계층 구조
- 각 섹션 상단에 2-3문장 직접 답변
- 짧은 단락 (2-3문장), 글머리 기호, 표 활용
- AI가 추출하기 쉬운 독립적 단락 구성

### Reliability (신뢰성)
- 검증 가능한 통계와 데이터 포함 → AI 가시성 30-40% 향상
- 명시적 출처 인용 (저자명, 기관명, 날짜)
- 전문가 의견, 사례 연구 포함
- E-E-A-T 신호 강화

### Exclusivity (독점성)
- 독점 데이터, 원본 연구, 자체 벤치마크
- 고유한 관점이나 프레임워크
- 다른 곳에서 찾을 수 없는 인사이트
- AI 엔진이 "이 소스만 인용할 수 있는" 정보

## AEO Strategy

### 직접 답변 최적화
- 주요 질문에 40-60 단어의 직접 답변을 섹션 상단에 배치
- 질문 형식의 H2/H3 제목 사용 (예: "## X란 무엇인가?")
- 정의형, 리스트형, 테이블형 Featured Snippet에 적합한 구조

### FAQPage 스키마
- FAQ 섹션에 JSON-LD FAQPage 마크업 추가
- 최적 답변 길이: 40-60 단어
- FAQPage 스키마 → AI 인용률 평균 30% 향상

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "질문 텍스트",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "40-60 단어의 명확한 답변"
    }
  }]
}
</script>
```

### 음성 검색 최적화
- 자연어 질문 형식의 제목
- 대화체 답변 (Who, What, Where, When, Why, How)
- 간결하고 직접적인 답변 구조

## GEO Strategy

### 인용 가능한 콘텐츠 작성
- 짧고 독립적으로 인용 가능한 문장
- 검증 가능한 통계 포함: "X%", "N배 증가" 등
- 명시적 출처: "[기관명]에 따르면..."
- 정의형 문장: "[용어]는 [정의]이다" 패턴

### 콘텐츠 신선도
- **3개월 임계값**: 3개월 이상 미갱신 콘텐츠는 AI 인용률 급감
- **6개월 임계값**: Google AI Overviews에서 "stale" 콘텐츠로 간주
- 분기별 콘텐츠 업데이트 권장
- `dateModified` 스키마로 갱신 일자 명시

### 엔터티 권위 (Entity Authority)
- 단일 페이지 최적화 < 완전한 토픽 클러스터
- 여러 콘텐츠에 걸친 일관된 지식 체계
- 주제를 다각도로 다루는 pillar page + cluster 구조
- Organization, Person 스키마로 엔터티 명시

## Platform-Specific Optimization

### AI 플랫폼별 인용 벤치마크

| Platform | Mention Rate | Avg Position | Content Preference |
|----------|-------------|-------------|-------------------|
| Google Gemini | 21.4% | 2.5 | 멀티모달, YouTube |
| Microsoft Copilot | 20.0% | 1.9 | 구조화, 권위 있는 소스 |
| ChatGPT | 7.9% | 2.0 | Wikipedia 스타일, 백과사전적 |
| Perplexity | — | 1.3 | Reddit, 커뮤니티 소스 |

### 플랫폼별 최적화 가이드

- **Google AI Overviews**: 상단 2-3문장 직접 답변, 질문 매칭 H2/H3, 멀티모달 콘텐츠 (이미지, 영상), E-E-A-T 강화
- **ChatGPT**: 백과사전적 톤, 객관적 사실 중심, 포괄적 주제 커버리지, 다소스 검증 필요
- **Perplexity**: 커뮤니티 기반 인용이 높으므로 Reddit/포럼 참여도 전략에 포함, 명확한 출처 링크
- **Claude**: llms.txt 지원, 구조화된 콘텐츠 선호

## LLMO (LLM Optimization)

### 두 가지 경로
1. **Training Data Pathway** — 장기적 브랜드 인지를 위한 웹 전반의 콘텐츠 영향력
2. **Live Retrieval Pathway** — 실시간 AI 응답에서 인용되기 위한 최적화

### llms.txt

AI 크롤러에게 콘텐츠 사용 규칙을 알려주는 정책 파일 (robots.txt 보완):

```text
# llms.txt
# AI 크롤러 정책

> Site: example.com
> Description: 사이트에 대한 한 줄 설명

# 핵심 페이지 (AI 인용 허용)
- /about: 회사 소개
- /docs: 기술 문서
- /blog: 블로그 콘텐츠

# 제외 페이지
- /admin: 관리자 페이지
- /internal: 내부 문서
```

**현재 상태**: 2024년 Answer.AI 제안, Claude 공식 문서에 인정됨. 대부분의 AI 크롤러가 아직 무시하므로 필수가 아닌 권장으로 다룸.

### 콘텐츠 구조화 원칙
- 글머리 기호, 번호 목록, 표 활용
- 복잡한 아이디어를 짧고 인용 가능한 문장으로 분리
- 의미적 명확성: 한 단락에 한 주제

## Measurement Tools & KPIs

### 핵심 KPI

| KPI | Description |
|-----|-------------|
| AI Citation Frequency | AI 응답에서 콘텐츠/브랜드 인용 빈도 |
| Brand Mention Rate | 관련 쿼리에서 브랜드가 언급되는 비율 |
| Share of Voice | 경쟁사 대비 AI 인용 점유율 |
| AI Overview Inclusion Rate | Google AI Overview에 포함되는 비율 |
| Citation Sentiment | AI가 브랜드를 설명하는 감정 분석 |
| AI-referred Conversion Rate | AI 유입 방문자의 전환율 |

### 주요 도구

| Tool | Purpose |
|------|---------|
| Profound | 로그 레벨 AI 크롤러 데이터 + 실시간 가시성, SOC 2 |
| AIclicks | 일일 자동 프로브 (ChatGPT, Claude, Gemini, Perplexity) |
| Otterly.ai | AI 검색 모니터링 |
| Ahrefs Brand Radar | AI 브랜드 인지도 추적 |
| OpenLens | 무료 AI 가시성 플랫폼 |
| Google Search Console | AI Overviews 노출 데이터 (제한적) |
