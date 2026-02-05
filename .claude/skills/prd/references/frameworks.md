# PRD 프레임워크

> PRFAQ, Shape Up, JTBD, RICE, Opportunity Solution Tree, GitHub Spec Kit

---

## Amazon PRFAQ (Working Backwards)

미래 시점에서 제품이 이미 존재하는 것처럼 보도자료를 작성하고, 예상 질문/반론을 FAQ로 정리.

### 구조

| 구성요소 | 설명 | 분량 |
|----------|------|------|
| **Press Release** | 고객 관점의 제품 발표문, "oprah-speak" (누구나 이해 가능) | 1.5페이지 이내 |
| **Customer FAQ** | 고객 예상 질문 (사용법, 가격, 차별화) | 1-2페이지 |
| **Internal FAQ** | 내부 질문 (기술, 리소스, 리스크, ROI) | 1-2페이지 |

### Press Release 필수 요소
1. **Heading**: 제품명 + 타깃 고객
2. **Sub-heading**: 핵심 혜택 1문장
3. **Problem**: 현재 고객이 겪는 문제
4. **Solution**: 이 제품이 어떻게 해결하는지
5. **Quote (내부)**: 회사 대변인의 발언
6. **How It Works**: 시작하기 쉬운 3단계
7. **Quote (고객)**: 가상의 고객 추천사
8. **CTA**: "지금 시작하세요" + URL

### 적합한 상황
- 신규 제품/서비스 기획
- 큰 비전이 필요한 프로젝트
- 고객 중심 사고가 약한 팀
- 이해관계자 정렬이 필요한 상황

---

## Basecamp Shape Up

### 핵심 개념

| 개념 | 설명 |
|------|------|
| **Shaping** | 추상적 수준에서 솔루션 핵심 요소 정의 (와이어프레임 X, 개념 수준) |
| **Appetite** | "이 문제에 6주를 투자할 가치가 있는가?" (deadline이 아닌 budget) |
| **Betting** | 6주 사이클에 어떤 작업을 할지 결정 |
| **Building** | 팀이 자율적으로 6주 내 완료, 세부 구현은 팀 재량 |

### Pitch 문서 구조
1. **Problem**: 해결할 문제 (Raw Idea가 아닌 구체적 상황)
2. **Appetite**: 투자할 시간 (2주 또는 6주)
3. **Solution**: 핵심 요소만 스케치 (fat marker sketch)
4. **Rabbit Holes**: 함정 (복잡해질 수 있는 부분 사전 제거)
5. **No-gos**: 명시적으로 하지 않을 것

### 적합한 상황
- 시간 제약이 명확한 프로젝트
- 자율적인 소규모 팀
- 과도한 상세 스펙을 피하고 싶을 때

---

## Jobs-to-be-Done (JTBD)

고객이 제품을 "고용(hire)"하여 완수하려는 근본적 목표에 초점.

### JTBD 문장 형식
```
When I [상황/맥락],
I want to [동기/목표],
So I can [기대하는 결과].
```

### Opportunity Score
기회를 정량화하는 공식:

```
Opportunity = Importance + max(Importance - Satisfaction, 0)
```

- **Importance**: 이 과제가 고객에게 얼마나 중요한가 (1-10)
- **Satisfaction**: 현재 솔루션에 얼마나 만족하는가 (1-10)
- 중요도 높고 만족도 낮은 영역 = 최대 기회

### 적합한 상황
- 사용자 니즈 중심 기획
- "왜 고객이 우리 제품을 쓰는가" 이해 필요
- 기능 목록이 아닌 고객 가치 기반 우선순위

---

## RICE Scoring

| 요소 | 설명 | 측정 |
|------|------|------|
| **Reach** | 기간 내 영향받는 사용자 수 | 분기당 N명 |
| **Impact** | 개별 사용자에 대한 영향 | 3=massive, 2=high, 1=medium, 0.5=low, 0.25=minimal |
| **Confidence** | 추정치의 신뢰도 | 100%=high, 80%=medium, 50%=low |
| **Effort** | 필요한 노력 | 인월(person-months) |

```
RICE Score = (Reach × Impact × Confidence) / Effort
```

### 적합한 상황
- 백로그 우선순위 결정
- 여러 기능 간 객관적 비교
- 이해관계자 간 우선순위 합의

---

## Opportunity Solution Tree (Teresa Torres)

### 구조

```
Desired Outcome (비즈니스/제품 목표)
├── Opportunity 1 (사용자 니즈/페인)
│   ├── Solution A
│   │   └── Experiment (검증 실험)
│   └── Solution B
│       └── Experiment
├── Opportunity 2
│   ├── Solution C
│   └── Solution D
└── Opportunity 3
```

### 핵심 원칙
- **Outcome에서 시작**: 기능이 아닌 결과에서 역방향 사고
- **기회 공간 매핑**: 사용자 인터뷰에서 기회 도출
- **다수의 솔루션 탐색**: 기회당 최소 3개 솔루션 후보
- **가정 검증**: 각 솔루션의 핵심 가정을 실험으로 검증

### 적합한 상황
- Discovery 단계에서 구조화된 탐색 필요
- 솔루션 편향 방지
- 팀이 "왜 이것을 만드는가"에 대한 정렬 필요

---

## GitHub Spec Kit (2025.09~)

### 4단계 워크플로우

**1단계: Specify (명세)**
```markdown
## Overview
사용자가 [행동]을 할 수 있는 [기능] 구축

## Goals
- 목표 1: [측정 가능한 결과]
- 목표 2: [측정 가능한 결과]

## Non-Goals
- [명시적으로 하지 않을 것]

## User Experience
[사용자 관점에서 기능이 어떻게 동작하는지]
```

**2단계: Plan (계획)**
```markdown
## Technical Approach
- 기술 스택: [사용 기술]
- 아키텍처: [설계 결정]

## Constraints
- [기술적 제약]
- [비즈니스 제약]
```

**3단계: Tasks (분해)**
```markdown
## Phase 1: Foundation
- [ ] Task 1 (검증: [테스트 방법])
- [ ] Task 2 (검증: [테스트 방법])

## Phase 2: Core Features
- [ ] Task 3 (검증: [테스트 방법])
```

**4단계: Implement (구현)**
순차적으로 구현, 각 Task 완료 후 검증.

### 적합한 상황
- AI 코딩 에이전트 활용 개발
- GitHub Copilot / Claude Code 기반 워크플로우
- 명세에서 직접 코드 생성

---

## 프레임워크 선택 가이드

| 상황 | 1순위 | 2순위 |
|------|-------|-------|
| **신규 제품** | PRFAQ | JTBD |
| **기능 추가** | JTBD + RICE | Shape Up |
| **우선순위 결정** | RICE | Opportunity Score |
| **Discovery 단계** | Opportunity Solution Tree | JTBD |
| **AI 에이전트 구현** | GitHub Spec Kit | Shape Up |
| **시간 제약 명확** | Shape Up | RICE |

---

## 출처

- https://productstrategy.co/working-backwards-the-amazon-prfaq-for-product-innovation/
- https://workingbackwards.com/resources/working-backwards-pr-faq/
- https://productschool.com/blog/product-fundamentals/prfaq
- https://basecamp.com/shapeup
- https://review.firstround.com/build-products-that-solve-real-problems-with-this-lightweight-jtbd-framework/
- https://productschool.com/blog/product-fundamentals/jtbd-framework
- https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/
- https://www.producttalk.org/opportunity-solution-tree/
- https://github.com/github/spec-kit
- https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
