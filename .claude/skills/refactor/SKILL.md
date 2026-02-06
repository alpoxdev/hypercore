---
name: refactor
description: 코드 품질 개선을 위한 리팩토링 계획 수립 및 실행 전략 제시
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/context-optimization/phase-based-execution.md
@../../instructions/context-optimization/sub-agent-distribution.md
@../../instructions/validation/scope-completeness.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Refactor Skill

> 코드 품질 개선을 위한 리팩토링 계획 수립 및 실행 전략 제시

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **코드 품질 개선** | 복잡도 감소, 중복 코드 제거, 명명 개선 |
| **구조 개선** | 파일/모듈 구조 정리, 관심사 분리 |
| **점진적 개선** | 단계적 리팩토링 계획 필요 |
| **성능 최적화** | 코드 효율성 개선 (기능 유지) |
| **타입 안정성** | any 제거, 명시적 타입 정의 |

## 호출 방법

```bash
# 직접 처리 (명확한 범위)
/refactor src/utils/auth.ts - 너무 복잡함

# @refactor-advisor 위임 (코드 품질 개선)
Task({
  subagent_type: 'refactor-advisor',
  model: 'sonnet',
  description: '인증 모듈 리팩토링',
  prompt: '복잡도 감소, 중복 제거, 타입 안정성 향상'
})
```

## 결과물

- 2-3개 리팩토링 옵션 제시 (장단점, 영향 범위)
- 추천안 및 근거
- 선택 후 `.claude/refactor/00.[모듈명]/` 폴더에 3개 문서 병렬 생성
  - ANALYSIS.md, PLAN.md, METRICS.md

</when_to_use>

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"무엇을 리팩토링해야 하나요? 구체적으로 알려주세요.

예시:
- 특정 파일/모듈 개선
- 복잡도 감소
- 중복 코드 제거
- 구조 개선
- 성능 최적화"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 없으면 질문 | - |
| 2. Agent 판단 | @refactor-advisor 사용 여부 결정 | - |
| 3. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 4. 코드 분석 | 현재 코드 구조, 문제점, 메트릭 파악 | Task (Explore) + Read/Grep |
| 5. 개선 옵션 도출 | 가능한 접근 4-5개 → 주요 2-3개 선정 | sequentialthinking (2-6단계) |
| 6. 옵션 제시 | 장단점, 영향 범위, 추천안 제시 | - |
| 7. 문서 생성 | 옵션 선택 대기 후 3개 문서 병렬 생성 | Task (document-writer) 병렬 |
| 8. 구현 시작 | 문서 완료 즉시 구현 진행 (확인 불필요) | Skill (execute) |

</workflow>

---

<agent_priority>

## @refactor-advisor Agent 우선 사용

**기본 원칙:**
```
리팩토링 요청 → @refactor-advisor 먼저 고려
```

### 사용 조건

| 조건 | 설명 |
|------|------|
| **코드 품질 개선** | 복잡도, 중복, 명명, 구조 개선 |
| **기능 변경 없음** | 동작은 유지하며 코드만 개선 |
| **점진적 개선** | 단계적 리팩토링 계획 필요 |

### Agent 활용 흐름

```
1. @refactor-advisor 호출
   → 코드 분석, 우선순위별 개선점 도출

2. 분석 결과 기반 옵션 정리
   → 사용자에게 2-3개 옵션 제시

3. 선택 후 계획 문서 작성
   → .claude/plan/refactor-[이름].md
```

### Agent 미사용 케이스

```
✅ @refactor-advisor 사용:
- 기존 코드 개선
- 복잡도/중복 감소
- 구조 개선

❌ 직접 처리:
- 아키텍처 변경
- 새 기능 추가와 함께 리팩토링
- 프레임워크 마이그레이션
```

</agent_priority>

---

<parallel_agent_execution>

## 병렬 에이전트 실행

@../../instructions/agent-patterns/delegation-patterns.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md

### Refactor 스킬 고유 패턴

- **코드 분석 병렬화**: refactor-advisor + architect 에이전트로 코드 구조 분석과 아키텍처 검토를 동시 실행
- **영향도 평가**: 여러 리팩토링 옵션에 대해 code-reviewer 에이전트로 각각 영향도를 병렬 평가
- **구현 + 검증 분리**: implementation-executor로 리팩토링 실행, deployment-validator로 동시에 기존 테스트 검증

</parallel_agent_execution>

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

## 리팩토링 영역

### 6가지 개선 영역

| 영역 | 문제 | 개선 방향 |
|------|------|----------|
| **복잡도** | 긴 함수, 깊은 중첩 | 함수 분리, Early Return |
| **중복** | 동일/유사 코드 반복 | 공통 함수/모듈 추출 |
| **명명** | 모호한 변수/함수명 | 의도 명확한 이름 |
| **구조** | 파일/모듈 구조 불명확 | 관심사 분리, 계층화 |
| **패턴** | 안티패턴 사용 | 디자인 패턴 적용 |
| **타입** | any 남용, 타입 불안정 | 명시적 타입 정의 |

### 체크리스트

```text
✅ 함수 길이: 20줄 이하 목표
✅ 중첩 깊이: 3단계 이하 목표
✅ 파일 길이: 200-300줄 권장
✅ 순환 의존성: 제거
✅ 매직 넘버: 상수화
✅ 주석: 코드로 설명 불가능한 것만
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

<state_management>

## 상태 관리 및 문서화

### 폴더 구조

옵션 선택 후 `.claude/refactor/00.[모듈명]/` 폴더 생성:

```
.claude/refactor/00.인증_모듈/
├── ANALYSIS.md   # 현재 상태, 문제점, 옵션 비교
├── PLAN.md       # 단계별 리팩토링 계획, 롤백 가이드
└── METRICS.md    # 품질 메트릭 Before/After
```

**폴더명 형식:** `00.[모듈명]` (넘버링 + 한글 설명, 언더스코어로 구분)
**넘버링:** 기존 refactor 폴더 목록 조회 → 다음 번호 자동 부여 (00, 01, 02...)

### 문서 역할

| 파일 | 내용 | 담당 에이전트 |
|------|------|--------------|
| **ANALYSIS.md** | 현재 상태 분석, 문제점 우선순위, 옵션 비교, 선택된 옵션 및 이유 | document-writer (haiku) |
| **PLAN.md** | 단계별 리팩토링 계획, 작업 체크리스트, 롤백 가이드, 검증 방법 | document-writer (sonnet) |
| **METRICS.md** | 품질 메트릭 Before/After, 측정 방법, 성공 기준 | document-writer (haiku) |

### 문서 작성

**우선순위: document-writer 에이전트 병렬 실행**

| 작업 | 방법 | 모델 |
|------|------|------|
| 3개 문서 동시 생성 | `Task(subagent_type="document-writer", ...)` 병렬 호출 | haiku (2개), sonnet (1개) |
| 복잡한 PLAN.md | `Task(subagent_type="document-writer", model="sonnet", ...)` | sonnet |

**병렬 실행 패턴:**

```typescript
// ✅ 3개 문서 동시 작성 (빠름)
Task(subagent_type="document-writer", model="haiku",
     prompt="ANALYSIS.md 생성: 현재 상태, 문제점, 옵션 비교")
Task(subagent_type="document-writer", model="sonnet",
     prompt="PLAN.md 생성: 단계별 계획, 체크리스트, 롤백 가이드")
Task(subagent_type="document-writer", model="haiku",
     prompt="METRICS.md 생성: Before/After 메트릭, 성공 기준")

// ❌ 순차 실행 (느림)
Write({ file_path: "ANALYSIS.md", ... })  // 대기...
Write({ file_path: "PLAN.md", ... })      // 대기...
```

### 문서 템플릿

#### ANALYSIS.md

```markdown
# [모듈명] 코드 분석

생성: {{TIMESTAMP}}

## 현재 상태

### 파일 구조
- 주요 파일: `src/module/file.ts` (200줄)
- 관련 파일: [목록]

### 복잡도 분석
- 함수 평균 길이: [N줄]
- 최대 중첩 깊이: [N단계]
- 순환 복잡도: [값]

### 문제점 (우선순위별)

| 문제 | 영향 | 우선순위 | 설명 |
|------|------|---------|------|
| 문제 1 | High | High | 상세 설명 |
| 문제 2 | Medium | Medium | 상세 설명 |
| 문제 3 | Low | Low | 상세 설명 |

## 옵션 비교

### 옵션 1: [옵션 이름] (추천)

**개선 방법:**
- 방법 1
- 방법 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/module/`
- 예상 작업량: 중간
- 리스크: 낮음

---

### 옵션 2: [옵션 이름]

[동일 형식]

---

### 옵션 3: [옵션 이름]

[동일 형식]

## 선택된 옵션

**옵션 [N]: [옵션 이름]**

**선택 이유:**
1. 이유 1
2. 이유 2
3. 이유 3
```

#### PLAN.md

```markdown
# [모듈명] 리팩토링 계획

## 개요

**목표:** [무엇을 개선할 것인가]
**접근 방식:** [선택된 옵션]
**예상 영향 범위:** [파일/모듈 목록]

## 단계별 계획

### 1단계: [단계 이름]

**목표:** [이 단계에서 달성할 것]

**작업 체크리스트:**
- [ ] 작업 1
- [ ] 작업 2
- [ ] 작업 3

**변경 파일:**
- `src/file1.ts`: [변경 내용]
- `src/file2.ts`: [변경 내용]

**검증:**
- [ ] 테스트 통과
- [ ] 빌드 성공
- [ ] 타입 체크 통과

---

### 2단계: [단계 이름]

**목표:** [이 단계에서 달성할 것]

**작업 체크리스트:**
- [ ] 작업 4
- [ ] 작업 5

**변경 파일:**
- `src/file3.ts`: [변경 내용]

**검증:**
- [ ] 테스트 통과
- [ ] 기능 동작 확인

---

### 3단계: [단계 이름]

[동일 형식]

## 롤백 가이드

### 문제 발생 시

**단계별 롤백:**
1. 현재 단계 중단
2. `git stash` 또는 커밋 되돌리기
3. 이전 단계로 복구
4. 테스트 재실행

**완전 롤백:**
1. 모든 변경 취소: `git reset --hard [시작 커밋]`
2. 의존성 복구: `npm install`
3. 빌드 확인: `npm run build`

### 주의사항

- 각 단계 완료 후 커밋
- 커밋 메시지: "refactor: [단계명] - [변경 내용]"
- 테스트 실패 시 즉시 중단

## 검증 방법

### 기능 검증
- [ ] 기존 기능 동작 확인
- [ ] 회귀 테스트 통과
- [ ] 통합 테스트 통과
- [ ] E2E 테스트 통과

### 품질 검증
- [ ] 복잡도 감소 확인
- [ ] 중복 제거 확인
- [ ] 타입 안정성 확인
- [ ] 성능 저하 없음
```

#### METRICS.md

```markdown
# [모듈명] 품질 메트릭

## Before (현재 상태)

### 복잡도
- 순환 복잡도: [현재 값]
- 함수 평균 길이: [N줄]
- 최대 중첩 깊이: [N단계]

### 중복
- 중복률: [N%]
- 중복 코드 블록 수: [N개]
- 중복 라인 수: [N줄]

### 타입 안정성
- any 사용 횟수: [N개]
- 명시적 타입 비율: [N%]
- 타입 에러 가능성: [High/Medium/Low]

### 테스트
- 테스트 커버리지: [N%]
- 단위 테스트 수: [N개]
- 통합 테스트 수: [N개]

### 성능
- 평균 응답 시간: [Nms]
- 메모리 사용량: [NMB]
- 번들 크기: [NKB]

## After (목표)

### 복잡도
- 순환 복잡도: [목표 값] (-N%)
- 함수 평균 길이: [N줄] (-N%)
- 최대 중첩 깊이: [N단계] (-N%)

### 중복
- 중복률: [N%] (-N%)
- 중복 코드 블록 수: [N개] (-N%)
- 중복 라인 수: [N줄] (-N%)

### 타입 안정성
- any 사용 횟수: [N개] (-N%)
- 명시적 타입 비율: [N%] (+N%)
- 타입 에러 가능성: [Low]

### 테스트
- 테스트 커버리지: [N%] (+N%)
- 단위 테스트 수: [N개] (+N%)
- 통합 테스트 수: [N개] (+N%)

### 성능
- 평균 응답 시간: [Nms] (-N%)
- 메모리 사용량: [NMB] (-N%)
- 번들 크기: [NKB] (-N%)

## 측정 방법

### 복잡도 측정
```bash
# ESLint complexity 규칙
npx eslint --rule 'complexity: ["error", { max: 10 }]' src/

# 또는 복잡도 분석 도구
npx plato -r -d report src/
```

### 중복 측정
```bash
# jscpd 사용
npx jscpd src/
```

### 타입 체크
```bash
# TypeScript 컴파일러
npx tsc --noEmit

# any 타입 검색
grep -r "any" src/ | wc -l
```

### 테스트 커버리지
```bash
# Jest 커버리지
npm test -- --coverage
```

### 성능 측정
```bash
# 빌드 크기
npm run build --report

# 런타임 성능
# (프로파일러, 성능 테스트 도구 사용)
```

## 성공 기준

| 메트릭 | 현재 | 목표 | 필수/선택 |
|--------|------|------|----------|
| 복잡도 | X | -20% | 필수 |
| 중복률 | X | -30% | 필수 |
| any 사용 | X | -50% | 필수 |
| 테스트 커버리지 | X | +10% | 선택 |
| 번들 크기 | X | 유지 | 필수 |
| 응답 시간 | X | 유지 | 필수 |

**최소 달성 기준:** 필수 항목 모두 목표 달성
```

</state_management>

---

<document_generation>

## 계획 문서 병렬 생성

사용자가 옵션을 선택하면 `.claude/refactor/00.[모듈명]/` 폴더에 3개 문서를 **병렬로** 생성합니다.

### 병렬 생성 워크플로우

```text
1. 넘버링 결정: ls .claude/refactor/ → 다음 번호 자동 부여
2. 폴더 생성: .claude/refactor/00.[모듈명]/
3. document-writer 에이전트 3개 병렬 호출
   - ANALYSIS.md (haiku)
   - PLAN.md (sonnet)
   - METRICS.md (haiku)
4. 모든 에이전트 완료 대기
5. 사용자에게 폴더 경로 안내
6. /execute 스킬 즉시 호출 (확인 불필요)
   - PLAN.md 기반 자동 구현 시작
```

### 에이전트 호출 예시

```typescript
// 옵션 선택 후 실행
// 1. 넘버링 결정
Bash("ls .claude/refactor/ | grep -E '^[0-9]+' | wc -l")
const nextNumber = "00" // 결과 기반 계산
const moduleName = "인증_모듈"
const basePath = `.claude/refactor/${nextNumber}.${moduleName}`

// 2. 폴더 생성
Bash(`mkdir -p ${basePath}`)

// 3. 3개 문서 병렬 생성
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'ANALYSIS.md 작성',
  prompt: `
    ${basePath}/ANALYSIS.md 생성:
    - 현재 상태: ${파일_구조}, ${복잡도_분석}
    - 문제점: ${우선순위별_문제점}
    - 옵션 비교: ${모든_옵션}
    - 선택된 옵션: 옵션 ${선택번호}
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  description: 'PLAN.md 작성',
  prompt: `
    ${basePath}/PLAN.md 생성:
    - 단계별 계획: 1단계, 2단계, 3단계...
    - 작업 체크리스트
    - 롤백 가이드
    - 검증 방법
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'METRICS.md 작성',
  prompt: `
    ${basePath}/METRICS.md 생성:
    - Before 메트릭: ${현재_측정값}
    - After 목표: ${개선_목표치}
    - 측정 방법
    - 성공 기준
  `
})

// → 3개 문서 병렬 생성으로 빠르게 계획 문서화
```

**모델 선택:**
- PLAN.md는 복잡하므로 sonnet
- 나머지는 haiku로 충분

</document_generation>

---

<auto_implementation>

## 자동 구현 시작

계획 문서 생성 완료 후 **사용자 확인 없이** 즉시 구현을 시작합니다.

### 워크플로우

```text
1. 계획 문서 병렬 생성 완료
2. PLAN.md 존재 확인
3. /execute 스킬 즉시 호출
4. 1단계부터 순차 구현
```

### 구현 시작 패턴

```typescript
// 문서 생성 완료 후 즉시 실행
Skill({
  skill: 'execute',
  args: `@.claude/refactor/${nextNumber}.${moduleName}/PLAN.md 1단계부터 구현`
})
```

### 금지 사항

```text
❌ "구현을 시작할까요?" 물어보기
❌ "어떤 방식으로 진행할까요?" 선택지 제시
❌ 사용자 확인 대기
```

### 허용 사항

```text
✅ 문서 생성 완료 즉시 /execute 호출
✅ PLAN.md 1단계부터 자동 시작
✅ 구현 중 문제 발생 시에만 사용자 확인
```

</auto_implementation>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ @refactor-advisor 사용 여부 판단
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드 분석 + 메트릭 수집
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 영향 범위 및 예상 작업량 제시
✅ 넘버링 자동 결정 (ls .claude/refactor/)
✅ document-writer 에이전트 병렬 호출로 문서 생성
✅ .claude/refactor/00.[모듈명]/ 폴더 구조 사용 (한글 설명)
✅ 기능 유지 원칙 강조
```

절대 금지:

```text
❌ ARGUMENT 없이 분석 시작
❌ Edit/Write 도구 직접 사용 (문서 작성은 document-writer 에이전트)
❌ Sequential Thinking 3단계 미만
❌ 옵션 1개만 제시
❌ 코드 분석 없이 추측으로 옵션 제시
❌ 장단점 없이 옵션만 나열
❌ 문서 작성 Y/N 질문 (자동 생성)
❌ 문서 생성 후 "구현을 시작할까요?" 물어보기 (즉시 진행)
❌ 기능 변경 포함
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

5. document-writer 에이전트 3개 병렬 호출로 문서 생성
   - .claude/refactor/00.auth_유틸/
     ├── ANALYSIS.md
     ├── PLAN.md
     └── METRICS.md

6. 구현 자동 시작:
   Skill({ skill: 'execute' })
   - PLAN.md 읽고 1단계부터 구현
   - 확인 절차 없이 즉시 진행
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

5. 선택 후 3개 문서 병렬 생성
   - .claude/refactor/00.중복_제거/

6. 구현 자동 시작 (확인 불필요)
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

5. document-writer 병렬 호출로 3개 문서 생성
   - .claude/refactor/00.구조_개선/
     ├── ANALYSIS.md (현재 구조, 의존성 그래프)
     ├── PLAN.md (단계별 이동 계획)
     └── METRICS.md (복잡도, 결합도 메트릭)

6. 구현 자동 시작 (확인 불필요)
```

</examples>
