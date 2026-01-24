# Instructions

공통 지침 및 패턴 모음

## 카테고리

| 카테고리 | 설명 | 파일 수 |
|---------|------|---------|
| [agent-patterns/](./agent-patterns/) | 에이전트 활용 및 협업 | 4 |
| [workflow-patterns/](./workflow-patterns/) | 작업 흐름 및 사고 | 3 |
| [validation/](./validation/) | 검증 및 품질 기준 | 3 |
| [tech-stack/](./tech-stack/) | 기술 스택 패턴 | 3 |
| [multi-agent/](./multi-agent/) | 멀티 에이전트 조정 및 최적화 | 4 |

**총 17개 공통 문서**

---

## 에이전트 패턴 (4개)

### parallel-execution.md
**목적**: 병렬/순차 실행 판단 기준

- 병렬화 가능 조건 (4가지)
- 병렬화 금지 조건 (4가지)
- 성능 비교 데이터
- 체크리스트

```markdown
@.claude/instructions/agent-patterns/parallel-execution.md
```

### read-parallelization.md
**목적**: 파일 읽기 최적화

- 3개 이상 파일 병렬 읽기
- 실전 시나리오 3가지
- 성능 개선율 표
- 주의사항

```markdown
@.claude/instructions/agent-patterns/read-parallelization.md
```

### model-routing.md
**목적**: 모델 선택 기준 및 비용 최적화

- Haiku/Sonnet/Opus 사용 케이스
- 복잡도 판단 플로우차트
- 에이전트별 권장 모델
- 비용 절감 전략 (40-60%)

```markdown
@.claude/instructions/agent-patterns/model-routing.md
```

### agent-coordination.md
**목적**: 다중 에이전트 협업 전략

- 에이전트 역할 분류 (4 Tier)
- 협업 패턴 4가지
- 병렬 vs 순차 결정 기준
- 실전 시나리오 3가지

```markdown
@.claude/instructions/agent-patterns/agent-coordination.md
```

---

## 작업 흐름 패턴 (3개)

### sequential-thinking.md
**목적**: 구조화된 사고 프로세스

- 복잡도별 단계 수 (LOW/MEDIUM/HIGH)
- 필수 파라미터 4개 + 선택 4개
- 동적 조정, 수정, 분기 기능
- 금지 표현 및 올바른 표현

```markdown
@.claude/instructions/workflow-patterns/sequential-thinking.md
```

### phase-based-workflow.md
**목적**: 4단계 검증 프로세스

- Phase 1: 작업 실행 (Sequential Thinking, 병렬 구현)
- Phase 2: 자동 검증 (/pre-deploy, TODO)
- Phase 3: Planner 검증 (승인 필수)
- Phase 4: 완료 (문서 업데이트)

```markdown
@.claude/instructions/workflow-patterns/phase-based-workflow.md
```

### todowrite-pattern.md
**목적**: TodoWrite 패턴

```markdown
@.claude/instructions/workflow-patterns/todowrite-pattern.md
```

---

## 검증 및 품질 기준 (3개)

### forbidden-patterns.md
**목적**: 반복되는 실수 방지 (16가지 금지 패턴)

- 추측성 표현 금지 (7가지)
- 코드 작성 금지 (4가지): any, @ts-ignore, 테스트 삭제, 에러 무시
- 작업 흐름 금지 (4가지): 검증 스킵, 조기 완료, 순차 실행, 에이전트 미활용
- Git, DB, API 금지 사항 (6가지)

```markdown
@.claude/instructions/validation/forbidden-patterns.md
```

### required-behaviors.md
**목적**: 필수 행동 18가지

- 작업 시작: Sequential Thinking, Read, 병렬 읽기
- 코드 작성: UTF-8, 한글 주석, TypeScript strict
- API: Server Function 패턴, TanStack Query
- 검증: 4-Phase, /pre-deploy, Planner
- 문서화: Ralph 세션, 더블 메서드
- Git: git-operator, 커밋 형식
- 에이전트: 위임 기준, 모델 선택

```markdown
@.claude/instructions/validation/required-behaviors.md
```

### verification-checklist.md
**목적**: Phase별 검증 절차

- Phase 1 검증: 요구사항 100%, TASKS.md, 병렬 실행
- Phase 2 검증: typecheck, lint, build, TODO=0
- Phase 3 검증: Planner 호출 및 응답
- Phase 4 검증: 최종 문서, <promise> 출력

```markdown
@.claude/instructions/validation/verification-checklist.md
```

---

## 멀티 에이전트 조정 (4개)

### coordination-guide.md
**목적**: 에이전트 협업 전략 및 컨텍스트 보존

- 핵심 원칙 (PARALLEL, BACKGROUND, DELEGATE)
- 모델 라우팅 (haiku/sonnet/opus)
- 컨텍스트 보존 (4가지 전략)
- 에러 처리 (6가지 패턴)
- Best Practices

```markdown
@.claude/instructions/multi-agent/coordination-guide.md
```

### agent-roster.md
**목적**: 14개 에이전트 카탈로그

- 에이전트 분류 (7개 카테고리)
- 모델 추천 및 사용 사례
- 병렬 실행 호환성
- 조정 패턴 및 워크플로우

```markdown
@.claude/instructions/multi-agent/agent-roster.md
```

### execution-patterns.md
**목적**: 병렬 실행 패턴 (5개 + 3개)

- 5개 실행 패턴 (병렬, Fan-Out Fan-In, 계층적 위임, 배치, 백그라운드)
- 3개 조정 패턴 (서브에이전트, 순차 파이프라인, 라우터)
- 4가지 실전 예제
- Best Practices

```markdown
@.claude/instructions/multi-agent/execution-patterns.md
```

### performance-optimization.md
**목적**: 성능 최적화 및 모니터링

- 최적화 체크리스트 (7개 항목)
- 성능 지표 (대기 시간 80% 감소, 토큰 70-90% 절감)
- 안티패턴 (5가지)
- 모니터링 전략
- 참고 자료 (15개 링크)

```markdown
@.claude/instructions/multi-agent/performance-optimization.md
```

---

## 기술 스택 패턴 (3개)

### tanstack-patterns.md
**목적**: TanStack Start/Router/Query 패턴

- Server Functions (GET/POST + inputValidator/middleware)
- Route 구조 (file-based routing)
- useQuery/useMutation (TanStack Query)
- 낙관적 업데이트 (Optimistic Updates)
- 통합 예시 (전체 흐름)

```markdown
@.claude/instructions/tech-stack/tanstack-patterns.md
```

### design-standards.md
**목적**: UI/UX 및 접근성

- WCAG 2.2 AA 준수 (색상 대비 4.5:1, 키보드 네비게이션)
- 60-30-10 색상 규칙
- 8px 그리드 간격
- 2-3개 폰트 시스템
- Safe Area (iOS/Android)

```markdown
@.claude/instructions/tech-stack/design-standards.md
```

### prisma-patterns.md
**목적**: Prisma 7.x 패턴

- 클라이언트 초기화 (globalThis 패턴)
- Schema 구조 (Single/Multi-File)
- CRUD Operations
- Relations (1:N, N:N)
- Transactions
- N+1 Problem 방지
- Index 최적화
- 자동 실행 금지

```markdown
@.claude/instructions/tech-stack/prisma-patterns.md
```

---

## 사용 예시

### Agents에서 참조

```markdown
---
name: my-agent
description: 예시 에이전트
---

@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/validation/forbidden-patterns.md

# My Agent

...
```

### Skills에서 참조

```markdown
---
name: my-skill
description: 예시 스킬
---

@../../instructions/workflow-patterns/phase-based-workflow.md
@../../instructions/validation/verification-checklist.md

# My Skill

...
```

### Commands에서 참조

```markdown
---
description: 예시 커맨드
---

@../instructions/agent-patterns/parallel-execution.md
@../instructions/validation/required-behaviors.md

# My Command

...
```

---

## 장점

- **중복 제거**: 공통 패턴을 한 곳에서 관리
- **일관성**: 모든 에이전트/스킬에서 동일한 표준 적용
- **유지보수**: 한 번 수정으로 전체 반영
- **문서 간결**: @imports로 간결화된 문서 구조

---

## 빠른 참조

| 상황 | 참조 문서 |
|------|---------|
| 작업 병렬화 판단 | parallel-execution.md |
| 파일 읽기 최적화 | read-parallelization.md |
| 모델 선택 | model-routing.md |
| 에이전트 협업 | agent-coordination.md |
| **멀티 에이전트 조정** | **multi-agent/coordination-guide.md** |
| **에이전트 선택** | **multi-agent/agent-roster.md** |
| **병렬 실행 패턴** | **multi-agent/execution-patterns.md** |
| **성능 최적화** | **multi-agent/performance-optimization.md** |
| 복잡한 작업 시작 | sequential-thinking.md |
| 작업 4단계 프로세스 | phase-based-workflow.md |
| 실수 방지 | forbidden-patterns.md |
| 필수 규칙 | required-behaviors.md |
| 검증 절차 | verification-checklist.md |
| TanStack 구현 | tanstack-patterns.md |
| UI/UX 구현 | design-standards.md |
| DB 스키마 | prisma-patterns.md |

---

## 컨텍스트 로딩 전략

모든 에이전트는 시작 시 다음을 참조:

```markdown
# Core Instructions (필수)
@instructions/agent-patterns/parallel-execution.md
@instructions/workflow-patterns/sequential-thinking.md
@instructions/validation/forbidden-patterns.md
@instructions/validation/required-behaviors.md

# Task-specific Instructions (선택)
@instructions/workflow-patterns/phase-based-workflow.md
@instructions/validation/verification-checklist.md
```

**예상 토큰**: 5,000-8,000 (컨텍스트 압축됨)
