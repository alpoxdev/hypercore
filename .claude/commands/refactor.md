---
description: 코드 리팩토링 계획 수립. @refactor-advisor 우선 활용. Sequential Thinking 3-7 필수. 기능 유지하며 개선만.
allowed-tools: Read, Glob, Grep, Bash(git:*, ast-grep:*), Task, Write, mcp__sequential-thinking__sequentialthinking
argument-hint: <target file/module or improvement goal>
---

# Refactor Command

> Establish refactoring plan for code quality improvement and present execution strategy.

**Refactoring target**: $ARGUMENTS

---

<argument_validation>

## Verify ARGUMENT is provided

```
No $ARGUMENTS → Ask immediately:

"What should we refactor? Please be specific.

Examples:
- Improve specific file/module
- Reduce complexity
- Remove duplicate code
- Improve structure
- Optimize performance"

$ARGUMENTS provided → Proceed to next step
```

</argument_validation>

---

<workflow>

## Execution Flow

| Step | Task | Tool |
|------|------|------|
| 1. Validate input | Verify ARGUMENT, ask if missing | - |
| 2. Judge agent usage | Decide whether to use @refactor-advisor | - |
| 3. Judge complexity | Determine analysis scope with Sequential Thinking | sequentialthinking (step 1) |
| 4. Analyze code | Understand current code structure, identify issues | Task (Explore) + Read/Grep |
| 5. Derive improvement options | Generate 4-5 approaches → select 2-3 main | sequentialthinking (steps 2-6) |
| 6. Present options | Present pros/cons, impact scope, recommendation | - |
| 7. Create plan document | Generate refactoring plan when selected | Write |

</workflow>

---

<agent_priority>

## Prioritize @refactor-advisor Agent Usage

**Basic principle:**
```
Refactoring request → Consider @refactor-advisor first
```

### Usage conditions

| Condition | Description |
|-----------|-------------|
| **Code quality improvement** | Improve complexity, duplication, naming, structure |
| **No feature change** | Maintain behavior, improve code only |
| **Incremental improvement** | Need step-by-step refactoring plan |

### Agent usage flow

```
1. Call @refactor-advisor
   → Analyze code, derive improvements by priority

2. Organize options based on analysis results
   → Present 2-3 options to user

3. Create plan document after selection
   → .claude/plans/refactor-[name].md
```

### Cases not using agent

```
✅ Use @refactor-advisor:
- Improve existing code
- Reduce complexity/duplication
- Improve structure

❌ Direct handling:
- Architecture change
- Refactoring with new feature addition
- Framework migration
```

</agent_priority>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 복잡도 판단
- 영향 범위: 파일 수, 함수 수
- 현재 문제: 복잡도, 중복, 명명, 구조
- 리스크: 기존 기능 영향, 테스트 커버리지
- 우선순위: High/Medium/Low
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|------------|
| **간단** | 3 | 1-2 파일, 명확한 개선점 | 복잡도 판단 → 현재 분석 → 개선 방안 |
| **보통** | 5 | 3-5 파일, 구조 변경 | 복잡도 판단 → 현재 분석 → 문제점 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 다중 모듈, 점진적 변경 필요 | 복잡도 판단 → 심층 분석 → 우선순위 → 접근 방식 → 비교 → 단계별 계획 → 추천안 |

### 보통 복잡도 패턴 (5단계)

```
thought 1: 복잡도 판단 및 분석 범위 결정
thought 2: 현재 코드 분석 (복잡도, 중복, 구조)
thought 3: 가능한 개선 방법 열거 (4-5개)
thought 4: 주요 옵션 3개 선정 및 장단점 분석
thought 5: 최종 옵션 정리 및 추천안 도출
```

### 복잡한 경우 패턴 (7단계)

```
thought 1: 복잡도 판단
thought 2: 현재 코드 심층 분석 (메트릭, 패턴)
thought 3: 개선 우선순위 정리 (High/Medium/Low)
thought 4: 가능한 접근 방식 탐색
thought 5: 각 접근 방식 비교 분석
thought 6: 옵션 3개 선정 및 상세 장단점
thought 7: 단계별 계획 및 추천안
```

### 핵심 원칙

```text
✅ 사고 과정을 출력해야 실제로 생각이 일어남
✅ 복잡도가 불확실하면 높게 책정 (5→7로 확장 가능)
✅ 각 thought에서 구체적 분석 필요 (추상적 설명 금지)
✅ 필요 시 isRevision으로 이전 사고 수정
```

</thinking_strategy>

---

<refactoring_areas>

## Refactoring areas

### Six improvement areas

| Area | Problem | Improvement |
|------|---------|-------------|
| **Complexity** | Long functions, deep nesting | Split functions, Early Return |
| **Duplication** | Identical/similar code repeats | Extract common functions/modules |
| **Naming** | Unclear variable/function names | Clear intent names |
| **Structure** | Unclear file/module structure | Separation of concerns, layering |
| **Patterns** | Using anti-patterns | Apply design patterns |
| **Types** | Excessive any, type instability | Explicit type definition |

### Checklist

```text
✅ Function length: target <= 20 lines
✅ Nesting depth: target <= 3 levels
✅ File length: recommended 200-300 lines
✅ Circular dependencies: eliminate
✅ Magic numbers: constants
✅ Comments: only what can't be explained by code
```

</refactoring_areas>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 3개 제시 (표준)

```markdown
## 분석 결과

### 현재 상태
- 문제점 1
- 문제점 2
- 개선 필요 영역

---

### 옵션 1: [옵션 이름] (추천)

**개선 방법:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/module/`
- 예상 작업량: 중간
- 리스크: 낮음
- 테스트 영향: 최소

---

### 옵션 2: [옵션 이름]

**개선 방법:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**영향 범위:**
...

---

### 옵션 3: [옵션 이름]

**개선 방법:**
...

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션을 선택하시겠습니까? (1/2/3)
```

### 옵션 2개 제시 (개선점이 명확한 경우)

```markdown
## 분석 결과

두 가지 접근 방식이 있습니다:

### 옵션 A: [옵션 이름]
...

### 옵션 B: [옵션 이름]
...

어떤 옵션을 선택하시겠습니까? (A/B)
```

</option_presentation>

---

<document_generation>

## 계획 문서 작성

### 문서 작성 질문

```
옵션 [N]을 선택하셨습니다.

리팩토링 계획 문서를 작성할까요?
- Y: .claude/plans/refactor-[이름].md 생성
- N: 바로 구현 시작

선택해주세요. (Y/N)
```

### Refactoring plan document template

**File location:** `.claude/plans/refactor-[name].md`

```markdown
# [Module name] Refactoring Plan

## Overview

**Goal:** [What will be improved]
**Selected approach:** [Option N]
**Expected impact scope:** [Files/modules list]

## Current state

### Issues

| Issue | Impact | Priority |
|-------|--------|----------|
| Issue 1 | Description | High |
| Issue 2 | Description | Medium |

### Metrics

- Complexity: [current value]
- Duplication rate: [current value]
- Test coverage: [current value]

## Improvement stages

### Stage 1: [Stage name]

**Goal:** [What will be achieved in this stage]

**Tasks:**
- [ ] Task 1
- [ ] Task 2

**Changed files:**
- `src/file1.ts`
- `src/file2.ts`

**Validation:**
- Tests pass
- Build success

### Stage 2: [Stage name]

**Goal:** [What will be achieved in this stage]

**Tasks:**
- [ ] Task 3

**Changed files:**
- `src/file3.ts`

### Stage 3: [Stage name]
...

## Expected improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|------------|
| Complexity | X | Y | -Z% |
| Duplication rate | X | Y | -Z% |
| Code lines | X | Y | -Z% |

## Risk management

### Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Risk 1 | High | Plan 1 |
| Risk 2 | Medium | Plan 2 |

### Rollback plan

If issues occur:
1. Use stage-by-stage commits
2. Revert to previous stage
3. Rerun tests

## Validation methods

### Functional validation
- [ ] Verify existing features work
- [ ] Regression tests pass
- [ ] Integration tests pass

### Quality validation
- [ ] Verify complexity reduction
- [ ] Verify duplication removal
- [ ] Verify type safety

## References

- Related document links
- Reference patterns
```

</document_generation>

---

<validation>

## Validation checklist

Before execution:

```text
✅ Verify ARGUMENT (ask if missing)
✅ Judge whether to use @refactor-advisor
✅ Sequential Thinking minimum 3 steps
✅ Analyze code with Task (Explore)
✅ Minimum 2 options, recommended 3
✅ List pros/cons for each option
✅ Present impact scope and estimated work
✅ Emphasize principle of maintaining functionality
```

Absolutely forbidden:

```text
❌ Start analysis without ARGUMENT
❌ Use Edit tool (code modification forbidden)
❌ Sequential Thinking less than 3 steps
❌ Present only 1 option
❌ Suggest options by guessing without code analysis
❌ Start implementation without user choice
❌ Include feature changes
❌ List options without pros/cons
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: 복잡한 함수 분리

```bash
사용자: /refactor src/utils/auth.ts - 너무 복잡함

1. @refactor-advisor 고려:
   → 단일 파일, 복잡도 감소 → Agent 활용 추천

2. Sequential Thinking (5단계):
   thought 1: "단일 파일, 함수 복잡도 - 보통 복잡도"
   thought 2: "auth.ts 분석: 200줄, 5단계 중첩, 여러 책임"
   thought 3: "접근 방식: 함수 분리, 책임 분리, 타입 개선"
   thought 4: "옵션 3개 선정 및 장단점"
   thought 5: "점진적 분리 추천 - 단계적 검증 가능"

3. 옵션 제시:
   옵션 1: 점진적 함수 분리 (추천)
   - 장점: 안전, 단계별 검증
   - 단점: 시간 소요

   옵션 2: 모듈 분리
   - 장점: 명확한 구조
   - 단점: 큰 변경

   옵션 3: 타입 개선 우선
   - 장점: 빠른 개선
   - 단점: 근본 해결 아님

4. 사용자 선택: 1

5. 문서 작성: Y

6. .claude/plans/refactor-auth.md 생성
```

### 예시 2: 중복 코드 제거

```bash
사용자: /refactor 여러 파일에 중복 코드가 많음

1. @refactor-advisor 활용:
   → 다중 파일, 중복 분석 → Agent 활용 적합

2. Sequential Thinking (5단계):
   thought 1: "다중 파일 중복 - 보통 복잡도"
   thought 2: "중복 패턴 분석: 3가지 유형"
   thought 3: "접근: 공통 함수, 유틸리티, 훅 추출"
   thought 4: "옵션 비교: 점진적 vs 일괄"
   thought 5: "점진적 추출 추천"

3. Task 탐색:
   Task (Explore): "중복 코드 패턴 분석"
   → src/components/, src/hooks/ 파악

4. 옵션:
   옵션 1: 점진적 공통 함수 추출 (추천)
   옵션 2: 새 유틸리티 모듈 생성
   옵션 3: 커스텀 훅 추출

5. 선택 후 계획 문서 생성
```

### 예시 3: 구조 개선

```bash
사용자: /refactor 프로젝트 구조를 더 명확하게

1. @refactor-advisor 판단:
   → 구조 변경, 다중 모듈 → 직접 처리 (Agent 미사용)

2. Sequential Thinking (7단계):
   thought 1: "구조 개선 - 복잡도 높음, 다중 모듈"
   thought 2: "현재 구조 분석: src/ 내 혼재"
   thought 3: "요구사항: 관심사 분리, 계층 명확화"
   thought 4: "접근: 모듈화, 디렉토리 재구성, 경로 정리"
   thought 5: "각 접근 비교: 영향 범위, 리스크"
   thought 6: "옵션 3개 선정 및 상세 분석"
   thought 7: "점진적 재구성 추천 - 단계적 이동"

3. Task 탐색 (병렬):
   Task (Explore): "현재 디렉토리 구조 분석"
   Task (Explore): "모듈 간 의존성 파악"
   Task (Explore): "import 경로 패턴 분석"

4. 옵션:
   옵션 1: 점진적 모듈 분리 (추천)
   옵션 2: 레이어 기반 재구성
   옵션 3: 기능별 도메인 분리

5. 계획 문서 작성 (필수)
```

</examples>
