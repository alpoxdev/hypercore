---
name: prd
description: Product Requirements Document 생성
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# PRD Skill

> Outcome 중심 PRD 생성 (2026 Spec-Driven Development 기반)

<when_to_use>

| 시나리오 | 기준 |
|---------|------|
| **신규 기능** | 3개+ 파일 수정 예상 |
| **아키텍처 변경** | 새 시스템/모듈 추가 |
| **복잡한 요구사항** | 다중 의존성, 여러 팀 |
| **기획 문서화** | 아이디어 → 구조화 문서 |

</when_to_use>

---

<principles>

## 2026 PRD 핵심 원칙

| 원칙 | 설명 | 출처 |
|------|------|------|
| **Outcome 중심** | "기능 X 만든다" → "리텐션 10% 증가시킨다" | GitHub Spec Kit |
| **Discovery First** | PRD는 Discovery 이후 작성, 검증 없는 가정의 문서화 방지 | Marty Cagan/SVPG |
| **반복적 작성** | "완벽한 스펙" 후 전달 X → "충분한 요구사항"으로 병렬 진행 | Shreyas Doshi |
| **Living Document** | 정적 문서 X → Brief로 시작, 데이터 학습하며 진화 | OpenAI/Miqdad Jaffer |
| **문제/솔루션 분리** | 문제 공간 먼저 정의, 솔루션은 별도 섹션 | Kevin Yien, Asana |
| **간결성** | LLM으로 긴 PRD 생성 금지, 결정 중심 작성 | Aakash Gupta |
| **PRD = What, CLAUDE.md = How** | PRD는 무엇을/왜, 기술 구현은 별도 문서 | ChatPRD |

</principles>

---

<frameworks>

## PRD 프레임워크

| 프레임워크 | 핵심 | 적합한 상황 |
|-----------|------|------------|
| **PRFAQ** (Amazon) | 미래 시점 보도자료 + FAQ, Working Backwards | 신규 제품, 큰 비전 |
| **Shape Up** (Basecamp) | 6주 사이클, Appetite 기반, 적절한 추상화 | 시간 제약 명확, 자율 팀 |
| **JTBD** | 고객이 "고용"하려는 근본 목표 정의 | 사용자 니즈 중심 기획 |
| **RICE** | (Reach × Impact × Confidence) / Effort | 기능 우선순위 결정 |
| **Opportunity Solution Tree** | Outcome → Opportunity → Solution → Experiment | Discovery 단계 |
| **GitHub Spec Kit** | Specify → Plan → Tasks → Implement 4단계 | AI 에이전트 활용 개발 |

**선택 기준:** 신규 제품 → PRFAQ, 기능 추가 → JTBD+RICE, AI 구현 → Spec Kit

</frameworks>

---

<ai_optimization>

## AI 에이전트용 PRD 최적화

### 6대 필수 영역 (GitHub 2,500+ 리포지토리 분석)

| 영역 | 포함 내용 |
|------|----------|
| **Commands** | 실행 명령어 + 플래그 (`npm test`, `pytest -v`) |
| **Testing** | 프레임워크, 파일 위치, 커버리지 기대치 |
| **Project Structure** | 소스, 테스트, 문서 경로 |
| **Code Style** | 선호 패턴을 코드 스니펫으로 |
| **Git Workflow** | 브랜치 네이밍, 커밋 형식, PR 요구사항 |
| **Boundaries** | 3단계 제약: Always Do / Ask First / Never Do |

### 핵심 규칙 (Addy Osmani, David Haberlah)

| 규칙 | 설명 |
|------|------|
| **모듈화** | Phase별 30-50개 요구사항 (150-200개 초과 시 성능 저하) |
| **Non-Goals 필수** | AI는 생략에서 추론 불가 → "X를 구현하지 말 것" 명시 |
| **원자적 User Stories** | 1 스토리 = 1 요구사항 |
| **체크 가능한 AC** | Given-When-Then 또는 불릿 포인트 |
| **단계적 구현** | 의존성 순서의 테스트 가능한 Phase |
| **기존 기능 보호** | 기존 코드 영향 범위 명시 |

</ai_optimization>

---

<anti_patterns>

## PRD 안티패턴

| 안티패턴 | 문제 | 해결 |
|----------|------|------|
| **모호한 요구사항** | "빠른 로딩" 측정 불가 | "3G에서 2초 내 로딩" |
| **기능 과적재** | 스코프 크리프 | MoSCoW/RICE 우선순위 |
| **솔루션 편향** | 문제 정의 전 솔루션 결정 | 문제 공간 먼저 정의 |
| **성공 지표 부재** | 성공 여부 판단 불가 | 현재값 → 목표값 KPI |
| **정적 문서화** | 빠르게 구식화 | 정기 리뷰 + 업데이트 |
| **LLM 긴 PRD 생성** | 내용 없이 길기만 함 | 결정 중심, 간결 작성 |
| **Discovery 생략** | 검증 없는 가정 문서화 | Discovery → PRD 순서 |
| **엣지 케이스 무시** | 사용자 불만 | Alternative Flow, Edge Case 명시 |

</anti_patterns>

---

<parallel_agent_execution>

## 병렬 Agent 실행

### Agent & Model Routing

| Agent | 용도 | LOW | MEDIUM | HIGH |
|-------|------|-----|--------|------|
| **explore** | 기존 문서/코드 조사 | haiku | haiku | haiku |
| **analyst** | 요구사항 분석, 가정 검증 | sonnet | sonnet | opus |
| **architect** | 기술 아키텍처 검토 | - | sonnet | opus |
| **designer** | UI/UX 요구사항 설계 | - | sonnet | opus |
| **planner** | PRD 구조 설계 | - | - | opus |
| **document-writer** | PRD 작성, 문서화 | haiku | sonnet | sonnet |

### 복잡도 판단

| 복잡도 | 기준 | 예시 |
|--------|------|------|
| **LOW** | CRUD, 단일 화면, 명확한 요구사항 | 프로필 편집, 목록 CRUD |
| **MEDIUM** | 다중 화면, API 연동, 2-3개 의존성 | Slack 연동, 결제 처리 |
| **HIGH** | 신규 아키텍처, 다중 의존성, 높은 불확실성 | 실시간 파이프라인, 소셜 피드 |

### 대표 병렬 패턴

**패턴 1: Persona별 사용자 스토리**
```typescript
Task(subagent_type="analyst", model="sonnet", prompt="관리자 사용자 스토리 도출")
Task(subagent_type="analyst", model="sonnet", prompt="일반 사용자 사용자 스토리 도출")
Task(subagent_type="analyst", model="sonnet", prompt="크리에이터 사용자 스토리 도출")
```

**패턴 2: 기술 영역별 동시 분석**
```typescript
Task(subagent_type="analyst", model="sonnet", prompt="Frontend 요구사항 분석")
Task(subagent_type="analyst", model="sonnet", prompt="Backend 요구사항 분석")
Task(subagent_type="architect", model="sonnet", prompt="Infrastructure 요구사항 분석")
Task(subagent_type="analyst", model="opus", prompt="Security 요구사항 분석")
```

**패턴 3: 다중 관점 검증**
```typescript
Task(subagent_type="analyst", model="sonnet", prompt="PM 관점 검증: 비즈니스 목표, KPI")
Task(subagent_type="architect", model="opus", prompt="Engineer 관점 검증: 실현 가능성, 리스크")
Task(subagent_type="designer", model="sonnet", prompt="Designer 관점 검증: UX, 접근성")
```

### 실행 순서

| 단계 | 작업 | 병렬 가능 |
|------|------|----------|
| **1** | 조사 (explore) + 경쟁사 분석 | O |
| **2** | 요구사항 분석 (analyst) + 아키텍처 (architect) | O |
| **3** | PRD 작성 (document-writer), 섹션별 분할 가능 | O |

**적극적으로 에이전트 활용. 혼자 하지 말 것.**

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| **1** | 복잡도 판단, PRD 프레임워크 선택 | Sequential Thinking |
| **2** | 코드베이스/문서 조사 | Task (explore) |
| **3** | 병렬 Agent 실행 (MEDIUM+ 복잡도) | Task (analyst, architect, document-writer) |
| **4** | PRD 작성 (아래 구조 준수) | Write → `.claude/plan/` 또는 `docs/prd/` |

</workflow>

---

<prd_structure>

## PRD 15개 섹션

| # | 섹션 | 핵심 내용 |
|---|------|----------|
| 1 | **메타데이터** | 제목, 작성자, 버전, 날짜, 관련 문서 |
| 2 | **비전 & 배경** | 비전 1-2문장, 왜 지금, 기존 한계 |
| 3 | **문제 정의 & 목표** | 데이터 기반 문제, 측정 가능 KPI (비즈니스/사용자) |
| 4 | **범위** | In Scope (P0/P1), **Out of Scope (Non-Goals)** |
| 5 | **타깃 유저 & 페르소나** | 세그먼트, 페르소나 (이름/역할/목표/Pain Point) |
| 6 | **사용자 여정 & 시나리오** | 여정 단계, JTBD 기반 대표 시나리오 |
| 7 | **기능 요구사항** | User Stories + Functional + Non-functional (기능별) |
| 8 | **UX/UI 요구사항** | 핵심 원칙, 필수 정보/액션, 접근성 |
| 9 | **기술/데이터 요구사항** | 스택, 통합, 데이터 구조, 보안/규제 |
| 10 | **성공 지표 & KPI** | 현재값 → 목표값, 측정 방법 |
| 11 | **리스크, 가정, 의존성** | 가정, 리스크 + 완화 방안, 의존성 |
| 12 | **릴리즈 전략** | 전략 (단계적/A·B), 마일스톤, 롤백 |
| 13 | **오픈 이슈 & Todo** | 미결정 질문, 결정자, 기한 |
| 14 | **구현 Phase** | 의존성 순서 단계 분해, 각 Phase에 테스트 체크포인트 |
| 15 | **변경 이력** | 버전별 변경 사항 추적 |

**기능 요구사항 작성법:**
```markdown
### 기능 N: [이름] (P0/P1)

**User Story**: As a [유저], I want to [행동] so that [가치]

**기능 설명**: Happy Path → Alternative Flow → Edge Case

**Acceptance Criteria** (Given-When-Then):
- Given [전제조건], When [행동], Then [결과]
- Given [전제조건], When [예외 행동], Then [에러 처리]

**Non-functional**: 성능 (응답 < Nms), 보안, 사용성
```

</prd_structure>

---

<template>

## PRD 템플릿

```markdown
# [제품/기능명] PRD

## 메타데이터

| 항목 | 내용 |
|------|------|
| **작성자** | [이름] |
| **버전** | v0.1 |
| **작성일** | YYYY-MM-DD |
| **관련 문서** | [링크] |

---

## 1. 비전 & 배경

**비전**: [1-2문장]
**배경**: [왜 지금]
**기존 한계**: [간단히]

---

## 2. 문제 정의 & 목표

### 문제
[데이터 기반 문제 정의]
- 유저 피드백: [요약]
- 지표: [현재 수치]

### 목표

| 분류 | 목표 |
|------|------|
| **비즈니스** | [측정 가능한 목표] |
| **사용자** | [측정 가능한 목표] |

---

## 3. 범위

### In Scope (P0/P1)
- [ ] 기능 1 (P0)
- [ ] 기능 2 (P1)

### Non-Goals (Out of Scope)
- [명시적으로 하지 않을 것과 이유]

---

## 4. 타깃 유저 & 페르소나

**Primary Persona**: [이름]
- **역할**: [역할]
- **목표**: [JTBD - 완수하려는 근본 과제]
- **Pain Point**: [현재 문제]

---

## 5. 사용자 여정

`[진입] → [핵심 행동] → [결과]`

---

## 6. 기능 요구사항

### 기능 1: [이름] (P0)

**User Story**: As a [유저], I want to [행동] so that [가치]

**Acceptance Criteria**:
- Given [전제], When [행동], Then [결과]
- Given [전제], When [예외], Then [에러 처리]

**Non-functional**: 성능, 보안, 사용성

---

## 7. UX/UI 요구사항

| 항목 | 내용 |
|------|------|
| **핵심 원칙** | [디자인 제약] |
| **접근성** | [키보드, 대비, 다국어] |

---

## 8. 기술/데이터 요구사항

| 항목 | 내용 |
|------|------|
| **기술 스택** | [사용 기술] |
| **데이터** | [엔티티, 관계] |
| **보안** | [인증, 개인정보] |

---

## 9. 성공 지표

| 지표 | 현재값 | 목표값 | 측정 방법 |
|------|--------|--------|----------|
| ... | ... | ... | ... |

---

## 10. 리스크 & 가정

| 분류 | 내용 | 완화 방안 |
|------|------|----------|
| **가정** | [전제 조건] | [검증 방법] |
| **리스크** | [기술/비즈니스] | [완화 전략] |
| **의존성** | [외부 팀/라이브러리] | - |

---

## 11. 릴리즈 전략

**전략**: [전체/단계적/A·B]
**마일스톤**: [타임라인]
**롤백**: [Feature Flag 등]

---

## 12. 구현 Phase

### Phase 1: [기초] (Week 1-2)
- [ ] 태스크 1
- [ ] 태스크 2
- **체크포인트**: [테스트 가능한 검증 기준]

### Phase 2: [핵심] (Week 3-4)
- [ ] 태스크 3
- **체크포인트**: [검증 기준]

---

## 13. 오픈 이슈

| 질문 | 결정자 | 기한 |
|------|--------|------|
| ... | ... | ... |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| v0.1 | YYYY-MM-DD | 초안 작성 |
```

</template>

---

<evaluation>

## PRD 품질 평가

| 항목 | 기준 | 가중치 |
|------|------|--------|
| **명확성** | 모호한 용어 없이 측정 가능한 요구사항 | 높음 |
| **완전성** | 범위, 제약조건, AC, Non-Goals 포함 | 높음 |
| **전략 정렬** | 비즈니스 목표/OKR과 직접 연결 | 높음 |
| **성공 메트릭** | 정량적 KPI + 현재값 → 목표값 | 높음 |
| **사용자 중심** | 페르소나, JTBD, User Stories, AC | 중간 |
| **우선순위** | MoSCoW/RICE 기반 명확한 우선순위 | 중간 |
| **가정 명시** | 검증되지 않은 가정 문서화 | 중간 |
| **AI 실행 가능** | Phase 분해, Non-Goals, 체크포인트 | 중간 |

</evaluation>

---

<references>

## 참고 자료

| 문서 | 내용 |
|------|------|
| @references/ai-native-prd.md | AI 에이전트용 PRD 작성법 (Osmani, Haberlah, Spec Kit, ChatPRD) |
| @references/pm-leaders.md | PM 리더 인사이트 (Cagan, Doshi, Rachitsky, Yien) |
| @references/frameworks.md | PRD 프레임워크 (PRFAQ, Shape Up, JTBD, RICE, Spec Kit) |
| @references/trends-2026.md | 2026 트렌드 (Spec-Driven, Outcome 중심, 빅테크 패턴) |
| @references/anti-patterns.md | 안티패턴 & 평가 기준 (Carnegie Mellon SEI 연구 포함) |

**필요 시 해당 문서 참조. 각 문서 하단에 원본 URL 포함.**

</references>
