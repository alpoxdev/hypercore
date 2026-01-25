# Multi-Agent Coordination

다중 에이전트 협업을 통한 효율성 극대화 및 품질 보증 시스템.

---

## Overview

**목표:** 14개 에이전트의 최적 조합, 병렬/순차 실행, 컨텍스트 보존, 에러 처리 자동화.

**핵심:**
- 병렬 실행으로 5-15배 속도 향상
- 모델 라우팅으로 40-60% 비용 절감
- 도메인별 전문 에이전트로 품질 보증
- 4단계 검증 프로세스로 무결성 확보

---

## Document Catalog

### 1. coordination-guide.md
**다중 에이전트 협업의 핵심 원칙 및 실행 전략**

| 항목 | 내용 |
|------|------|
| 목적 | 에이전트 간 협업 패턴 정의 |
| 대상 | 복잡한 작업 분해 및 조정이 필요한 경우 |
| 핵심 내용 | 4가지 협업 패턴, 병렬vs순차 결정 기준, 실전 시나리오 |

**포함 사항:**
- 에이전트 협업 4가지 패턴 (순차, 병렬, 팬아웃팬인, 라우터)
- 모델 선택 및 라우팅 기준
- 컨텍스트 보존 전략 (공유 상태, 문서 기반, 핸드오프)
- 에러 처리 및 복구 (재시도, 서킷브레이커, 모니터링)

**사용 시점:**
- 여러 에이전트를 조합해야 하는 복잡한 작업
- 병렬/순차 실행 판단이 필요할 때
- 컨텍스트 손실 위험 시

```markdown
@./coordination-guide.md
```

---

### 2. agent-roster.md
**14개 에이전트 전체 카탈로그 및 사용 가이드**

| 항목 | 내용 |
|------|------|
| 목적 | 각 에이전트의 역할, 모델 권장, 사용 사례 정리 |
| 대상 | 어떤 작업을 누가 할지 결정할 때 |
| 핵심 내용 | 14개 에이전트 상세 설명, 모델 및 복잡도, 병렬화 가능성 |

**포함 사항:**
- 에이전트 분류 (4 Tier: 계획, 구현, 검증, 지원)
- 14개 에이전트별 상세 정보:
  - Tier 1 (계획): planner, architect, analyst
  - Tier 2 (구현): implementation-executor, designer, dependency-manager
  - Tier 3 (검증): code-reviewer, deployment-validator, lint-fixer
  - Tier 4 (지원): git-operator, document-writer, ko-to-en-translator, refactor-advisor, explore
- 각 에이전트별 추천 모델, 병렬화 가능성, 주요 사용 사례
- 에이전트 간 의존성 맵

**사용 시점:**
- 작업에 적절한 에이전트 선택이 필요할 때
- 에이전트 능력과 한계를 파악하고 싶을 때
- 병렬화 가능한 작업 찾기

```markdown
@./agent-roster.md
```

---

### 3. execution-patterns.md
**5가지 실행 패턴 + 3가지 조정 패턴 + 실전 예제**

| 항목 | 내용 |
|------|------|
| 목적 | 실제 작업 구현을 위한 구체적 패턴 제공 |
| 대상 | 실제 코드/프롬프트 작성이 필요할 때 |
| 핵심 내용 | 5가지 실행 패턴, 3가지 조정 패턴, 4가지 실전 예제 |

**포함 사항:**
- 5가지 실행 패턴:
  1. 단일 메시지 병렬 실행 (독립 작업)
  2. Fan-Out Fan-In (분산 수집)
  3. 계층적 위임 (메인 + 서브)
  4. 배치 처리 (유사 작업 묶음)
  5. 백그라운드 실행 (장시간 작업)
- 3가지 조정 패턴:
  1. 서브에이전트 패턴 (stateless)
  2. 순차 파이프라인 (의존성)
  3. 라우터/디스패처 (조건부 라우팅)
- 4가지 실전 예제:
  1. 풀스택 기능 구현
  2. 대규모 리팩토링
  3. 멀티 스테이지 파이프라인
  4. 에러 복구 시나리오

**사용 시점:**
- 구체적인 Task/Tool 호출 방법을 알고 싶을 때
- 실제 프롬프트 구성 예시가 필요할 때

```markdown
@./execution-patterns.md
```

---

### 4. performance-optimization.md
**성능 최적화 체크리스트, 지표, 안티패턴**

| 항목 | 내용 |
|------|------|
| 목적 | 성능 측정 및 최적화를 위한 체크리스트 제공 |
| 대상 | 성능 모니터링 및 개선이 필요할 때 |
| 핵심 내용 | 7항목 체크리스트, 4가지 성능 지표, 5가지 안티패턴 |

**포함 사항:**
- 최적화 체크리스트 (7항목):
  1. 독립 작업 → 병렬 실행
  2. 10개+ 유사 작업 → 배치
  3. 10분+ 작업 → 백그라운드
  4. 복잡도별 모델 선택
  5. 컨텍스트 크기 모니터링
  6. 재시도 제한 (3회)
  7. 상태 문서화
- 성능 지표 (4가지):
  - 대기 시간 (목표: 80% 감소)
  - 토큰 사용 (목표: 70-90% 절감)
  - 병렬도 (목표: 3-10개)
  - 성공률 (목표: 95%+)
- 5가지 안티패턴 및 올바른 방법

**사용 시점:**
- 현재 작업의 성능을 최적화하고 싶을 때
- 성능 목표 설정이 필요할 때
- 흔한 실수 피하기

```markdown
@./performance-optimization.md
```

---

## Quick Reference

### 상황별 참조 문서

| 상황 | 문서 | 섹션 |
|------|------|------|
| **여러 에이전트 협업이 필요** | coordination-guide.md | 협업 패턴 |
| **어떤 에이전트 사용할지 결정** | agent-roster.md | 에이전트 분류 |
| **구체적인 실행 방법 알고 싶음** | execution-patterns.md | 실행 패턴 |
| **성능 최적화** | performance-optimization.md | 체크리스트 |
| **모델 선택 기준** | coordination-guide.md | 모델 라우팅 |
| **컨텍스트 보존** | coordination-guide.md | 컨텍스트 전략 |
| **에러 처리** | coordination-guide.md | 에러 처리 |
| **병렬화 가능성** | agent-roster.md | 병렬화 가능성 |
| **비용 절감** | performance-optimization.md | 최적화 체크리스트 |
| **실전 예제** | execution-patterns.md | 실전 예제 |

---

## 문서 활용 순서

### 작업 시작 시

```markdown
1. agent-roster.md → 어떤 에이전트 사용할지 결정
2. coordination-guide.md → 협업 패턴 선택
3. execution-patterns.md → 구체적 구현 방법 확인
4. performance-optimization.md → 최적화 체크리스트 확인
```

### 복잡한 작업 시

```markdown
1. coordination-guide.md (전체) → 협업 전략 수립
2. agent-roster.md (해당 에이전트만) → 역할 확인
3. execution-patterns.md (해당 패턴) → 구현
4. performance-optimization.md (체크리스트) → 최적화
```

### 에러 발생 시

```markdown
1. coordination-guide.md → 에러 처리 섹션
2. performance-optimization.md → 안티패턴 확인
3. agent-roster.md → 대안 에이전트 찾기
```

---

## 크로스 레퍼런스

### 관련 Instructions

| 문서 | 관계 | 참조 이유 |
|------|------|----------|
| `parallel-agent-execution.md` | 병렬 실행 구현 | 구체적 Tool 호출 방법 |
| `sequential-thinking.md` | 복잡도 판단 | 에이전트 선택 및 모델 결정 |
| `forbidden-patterns.md` | 금지 사항 | 에러 방지 |
| `required-behaviors.md` | 필수 규칙 | Gemini Review, 4-Phase |

### Agents 문서

14개 에이전트 모두 다음 문서 참조:
```markdown
@.claude/instructions/multi-agent/coordination-guide.md
@.claude/instructions/multi-agent/agent-roster.md
```

### Skills 문서

복잡한 스킬은 다음 문서 참조:
```markdown
@.claude/instructions/multi-agent/execution-patterns.md
@.claude/instructions/multi-agent/performance-optimization.md
```

---

## 모듈 구조

```
.claude/instructions/multi-agent/
├── index.md                          # 이 파일 (개요 및 빠른 참조)
├── coordination-guide.md              # 협업 패턴 및 전략
├── agent-roster.md                    # 에이전트 카탈로그
├── execution-patterns.md              # 실행 패턴 및 예제
└── performance-optimization.md        # 최적화 및 지표
```

---

## 핵심 원칙 요약

| 원칙 | 설명 |
|------|------|
| **Right Tier** | Tier별 역할 명확화 (계획→구현→검증) |
| **Parallel First** | 독립 작업은 무조건 병렬 |
| **Model Routing** | 복잡도에 맞는 모델 선택 (haiku/sonnet/opus) |
| **Context Preservation** | 상태 문서로 컨텍스트 보존 |
| **Error Isolation** | 실패를 격리하고 재시도 제한 |
| **Performance Monitoring** | 지표로 성능 추적 |

---

## 시작하기

**첫 번째 다중 에이전트 작업:**

1. agent-roster.md 읽기 → 필요한 에이전트 2-3개 선택
2. coordination-guide.md 읽기 → 협업 패턴 이해
3. execution-patterns.md 읽기 → 구체적 예제로 학습
4. 실제 작업에 적용 → performance-optimization.md로 최적화

**예상 학습 시간:** 30-45분 (전체 문서)

---

## 구조화된 접근

```
Task 분석
  ↓
Agent 선택 (agent-roster.md)
  ↓
Pattern 선택 (coordination-guide.md)
  ↓
실행 (execution-patterns.md)
  ↓
최적화 (performance-optimization.md)
  ↓
모니터링 & 개선
```

각 단계에서 해당 문서 참조로 빠른 의사결정 가능.
