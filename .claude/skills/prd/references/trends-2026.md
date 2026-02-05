# 2026 PRD 트렌드

> Product School, Ant Murphy, Atlassian, GitHub, Thoughtworks, OpenAI

---

## 핵심 패러다임 전환

| 기존 | 2026 |
|------|------|
| 기능 목록(Feature List) | **Outcome 중심** (결과 기반) |
| 정적 문서 | **Living Document** (지속 진화) |
| 인간 정렬 도구 | **AI 실행 가능 명세서** |
| PM이 완성 후 전달 | **반복적 작성, 병렬 진행** |
| 상세할수록 좋음 | **간결하고 결정 중심** |
| 기능 출시 = 성공 | **Landing Review** (출시 후 성과 평가) |

---

## Spec-Driven Development

Thoughtworks, GitHub, Tessl이 주도하는 새 패러다임.

**정의:** "잘 작성된 소프트웨어 요구사항 명세를 프롬프트로 사용하여 AI 코딩 에이전트가 실행 가능한 코드를 생성하는 개발 패러다임"

**AGENTS.md 표준:** Google, OpenAI, Factory, Sourcegraph, Cursor가 공동 출시한 벤더 중립 마크다운 표준. AI 에이전트가 리포지토리를 이해하기 위한 공통 형식.

**비판 (Scott Logic, 2025.11):** "재발명된 워터폴?" -- 기존 워터폴과 구별하는 것은 AI의 빠른 피드백 루프.

---

## Outcome 중심 PRD

### Before (기능 중심)
```
기능: 사용자 프로필 편집 페이지 구현
- 이름, 이메일, 프로필 이미지 편집
- 실시간 검증
- 저장 버튼
```

### After (Outcome 중심)
```
목표: 사용자 프로필 완성률 40% → 75% 달성
- 문제: 사용자의 60%가 프로필을 미완성 상태로 방치
- 가설: 편집 UX 간소화 시 완성률 증가
- 성공 지표: 프로필 완성률 75%, 편집 이탈률 20% 감소
- 기능: (위 지표 달성을 위한 수단으로서의 기능)
```

### Landing Review
출시 수개월 후 실시하는 평가 의식:
- 채택률 (얼마나 많은 사용자가 실제 사용하는가?)
- 행동 변화 (사용자 행동이 의도대로 변했는가?)
- 비즈니스 성과 (KPI가 실제로 개선되었는가?)
- 학습 (예상과 다른 결과에서 무엇을 배웠는가?)

---

## Continuous PRD (지속적 PRD)

OpenAI의 Miqdad Jaffer가 제안한 **"Continuous PRM Mode"**:

| 단계 | PRD 상태 | 활동 |
|------|----------|------|
| **Discovery** | Brief (1-2페이지) | 고객 인터뷰, 가설 검증 |
| **Shaping** | Draft PRD | 요구사항 구체화, 기술 검토 |
| **Building** | Living PRD | 개발 중 발견사항 반영 |
| **Launch** | Final PRD | 출시 기준 확정 |
| **Post-Launch** | Updated PRD | Landing Review 결과 반영 |

PRD는 완성되는 것이 아니라 **지속적으로 진화**.

---

## PM 역할 변화

### AI 도구의 영향
- PRD 작성/편집/포맷에 소요되던 시간의 **40-60% 절약** (주당 6-9시간)
- 94%의 프로덕트 전문가가 AI를 자주 사용
- 절반 가까이가 워크플로우에 깊이 내장

### 역할 전환
- **문서 작성자** → **의사결정자**: AI가 초안을 작성, PM은 판단과 결정에 집중
- **기능 정의자** → **Outcome 설계자**: 무엇을 만들지보다 어떤 결과를 달성할지
- **프로세스 관리자** → **Discovery 리더**: 가설 수립, 실험 설계, 학습 루프

### 핵심 역량 변화
- **학습 속도가 곧 경쟁 우위**: AI로 누구나 제품 경험을 몇 주 만에 복제 가능
- PM의 차별화 = 고객 이해 깊이 + 전략적 판단 + 실험 설계

---

## Prompt Requirements Document (PmRD)

"Vibe Coding 시대"를 위한 새로운 개념:
- AI와 인간이 함께 이해할 수 있는 구조화된 프롬프트
- PRD의 정밀함 + 프롬프트의 실행 가능성 결합
- 아직 초기 개념이지만 Spec-Driven Development와 수렴 중

---

## AI 제품 특화 PRD (OpenAI 템플릿)

일반 PRD에 추가되는 AI 전용 Non-functional Requirements:

| 항목 | 기준 |
|------|------|
| **정확도** | >= 90% |
| **환각률** | < 2% |
| **응답시간 SLA** | < 500ms |
| **가동시간** | 99.9% |
| **편향 감사** | 월간 인간 검증 |
| **RAG 통합** | 문서 기반 응답 |
| **보안** | GDPR, OWASP 준수 |

주의: AI 제품 개발 시에만 적용. 일반 소프트웨어 PRD에는 해당 없음.

---

## 빅테크 PRD 공통 패턴 (12개 기업 분석)

| 섹션 | 포함 빈도 |
|------|-----------|
| Overview / Problem Statement | 12/12 |
| Key Features / Scope | 12/12 |
| Success Metrics / KPIs | 12/12 |
| Target Users / Personas | 11/12 |
| Technical Requirements | 10/12 |
| Timeline / Milestones | 9/12 |
| User Stories / Use Cases | 8/12 |

### 기업별 특징

| 기업 | PRD 특징 |
|------|----------|
| **Google** | 데이터 기반 문제 정의, 구체적 메트릭 (12% 만족도 향상) |
| **Amazon** | 정의된 페르소나, 3개월 내 25% 참여 증가 목표 |
| **Stripe** | 타깃 세그먼트별 정의, 99.99% 가동시간 |
| **Spotify** | 사용자 중심, 35% 발견율 증가, 85% 추천 정확도 |
| **Linear** | 거부된 대안 분석 포함, 구체적 마일스톤 (Internal → Beta → GA) |
| **Airbnb** | 전환 중심, 모바일 우선, 18% 전환율 향상 |

---

## 출처

- https://productschool.com/blog/product-fundamentals/product-management-trends
- https://antmurphy.medium.com/how-product-is-changing-in-2026-78a08f150aca
- https://www.atlassian.com/blog/announcements/state-of-product-2026
- https://www.productcompass.pm/p/ai-prd-template
- https://pmprompt.com/blog/prd-examples
- https://medium.com/@takafumi.endo/prompt-requirements-document-prd-a-new-concept-for-the-vibe-coding-era-0fb7bf339400
- https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html
- https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- https://www.news.aakashg.com/p/ai-prd
- https://www.oreateai.com/blog/ai-prd-generator/
