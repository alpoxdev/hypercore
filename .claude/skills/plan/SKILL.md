---
name: plan
description: 개발 진행 방법 검토 및 옵션 제시
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/sourcing/reliable-search.md
@../../instructions/context-optimization/phase-based-execution.md
@../../instructions/context-optimization/sub-agent-distribution.md
@../../instructions/validation/scope-completeness.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Plan Skill

> 개발 진행 방법 검토 및 옵션 제시

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **새 기능 추가** | 인증 시스템, 실시간 알림, 결제 모듈 |
| **아키텍처 변경** | 상태 관리 전환, DB 마이그레이션, 모노레포 전환 |
| **리팩토링** | 코드 구조 개선, 타입 전환, 모듈 분리 |
| **기술 선택** | 라이브러리 비교, 프레임워크 선정 |
| **문제 해결** | 성능 개선, 버그 수정 전략 |

## 호출 방법

```bash
# 직접 처리 (명확한 범위)
/plan 사용자 프로필 편집 기능 추가

# planner agent 위임 (복잡한 경우)
Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '인증 시스템 재설계 계획',
  prompt: 'JWT를 세션 기반으로 전환'
})
```

## 결과물

- 2-3개 옵션 제시 (장단점, 영향 범위)
- 추천안 및 근거
- 선택 후 `.claude/plan/00.[기능명]/` 폴더에 여러 문서 자동 생성
  - OVERVIEW.md, OPTIONS.md, IMPLEMENTATION.md, RISKS.md, REFERENCES.md

</when_to_use>

---

<parallel_agent_execution>

## 병렬 에이전트 실행

@../../instructions/agent-patterns/delegation-patterns.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md

### Plan 스킬 고유 패턴

**옵션 도출 병렬화**: 여러 접근 방법을 동시에 분석할 때, 각 옵션을 별도 에이전트에게 위임하여 병렬로 평가

**문서 병렬 생성**: OVERVIEW.md, OPTIONS.md, IMPLEMENTATION.md, RISKS.md, REFERENCES.md를 동시에 작성할 때 document-writer 에이전트 병렬 활용

**Critic 검증**: 계획 완성 후 critic 에이전트로 명확성, 완전성, 검증 가능성 평가

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore/planner) |
| 3. 옵션 도출 | 가능한 접근 4-5개 → 주요 2-3개 선정 | sequentialthinking (2-6단계) |
| 4. 옵션 제시 | 장단점, 영향 범위, 추천안 제시 | - |
| 5. 문서 생성 | 옵션 선택 대기 후 계획 문서 병렬 생성 | Task (document-writer) 병렬 |
| 6. 구현 시작 | 문서 완료 즉시 구현 진행 (확인 불필요) | Skill (execute) |

### Agent 선택 기준

| 복잡도 | 조건 | 사용 Agent |
|--------|------|-----------|
| **매우 복잡** | 다중 시스템, 아키텍처 변경, 불확실성 높음 | Task (planner) 위임 |
| **복잡/보통** | 명확한 범위, 3-10 파일 | 직접 처리 (Task Explore 활용) |
| **간단** | 1-2 파일, 명확한 변경 | 직접 처리 |

### Sequential Thinking 가이드

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 3 | 1-2 파일, 명확한 변경 | 복잡도 판단 → 현재 상태 → 옵션 도출 |
| **보통** | 5 | 3-5 파일, 로직 변경 | 복잡도 판단 → 현재 상태 → 접근 방식 탐색 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 제약사항 → 접근 방식 → 비교 → 상세 분석 → 추천안 |

</workflow>

---

<state_management>

## 상태 관리 및 문서화

### 폴더 구조

옵션 선택 후 `.claude/plan/00.[기능명]/` 폴더 생성:

```
.claude/plan/00.실시간_알림/
├── OVERVIEW.md        # 개요, 현재 상태, 선택된 옵션
├── OPTIONS.md         # 모든 옵션 비교 분석 (장단점, 영향 범위)
├── IMPLEMENTATION.md  # 구현 단계 상세 계획
├── RISKS.md           # 리스크 및 완화 방안
└── REFERENCES.md      # 참조 자료, 코드베이스 분석 결과
```

**폴더명 형식:** `00.[기능명]` (넘버링 + 한글 설명, 언더스코어로 구분)
**넘버링:** 기존 plans 폴더 목록 조회 → 다음 번호 자동 부여 (00, 01, 02...)

### 문서 역할

| 파일 | 내용 | 담당 에이전트 |
|------|------|--------------|
| **OVERVIEW.md** | 개요 (목표, 범위), 현재 상태 분석, 선택된 옵션 및 이유 | document-writer (haiku) |
| **OPTIONS.md** | 모든 옵션 비교표, 장단점/영향 범위, 추천 옵션 및 근거 | document-writer (haiku) |
| **IMPLEMENTATION.md** | 구현 단계 (1단계, 2단계, ...), 작업 체크리스트, 변경 파일 목록 | document-writer (sonnet) |
| **RISKS.md** | 기술적 리스크, 일정 리스크, 완화 방안 | document-writer (haiku) |
| **REFERENCES.md** | 코드베이스 분석 결과, 관련 문서 링크, 참고 자료 | document-writer (haiku) |

### 문서 작성

**우선순위: document-writer 에이전트 병렬 실행**

| 작업 | 방법 | 모델 |
|------|------|------|
| 5개 문서 동시 생성 | `Task(subagent_type="document-writer", ...)` 병렬 호출 | haiku (4개), sonnet (1개) |
| 복잡한 IMPLEMENTATION.md | `Task(subagent_type="document-writer", model="sonnet", ...)` | sonnet |

**병렬 실행 패턴:**

```typescript
// ✅ 5개 문서 동시 작성 (빠름)
Task(subagent_type="document-writer", model="haiku",
     prompt="OVERVIEW.md 생성: 개요, 현재 상태, 선택된 옵션")
Task(subagent_type="document-writer", model="haiku",
     prompt="OPTIONS.md 생성: 옵션 비교 분석")
Task(subagent_type="document-writer", model="sonnet",
     prompt="IMPLEMENTATION.md 생성: 구현 단계 상세 계획")
Task(subagent_type="document-writer", model="haiku",
     prompt="RISKS.md 생성: 리스크 및 완화 방안")
Task(subagent_type="document-writer", model="haiku",
     prompt="REFERENCES.md 생성: 코드베이스 분석 결과")

// ❌ 순차 실행 (느림)
Write({ file_path: "OVERVIEW.md", ... })  // 대기...
Write({ file_path: "OPTIONS.md", ... })   // 대기...
```

### 문서 템플릿

#### OVERVIEW.md

```markdown
# [기능명] 계획 개요

생성: {{TIMESTAMP}}

## 목표

[무엇을 달성할 것인가]

## 범위

- 포함: [범위 1, 2, 3]
- 제외: [범위 외 항목]

## 현재 상태 분석

### 코드베이스

- 관련 파일: `src/`, `lib/`
- 현재 구조: [설명]

### 제약사항

- 제약 1
- 제약 2

## 선택된 옵션

**옵션 [N]: [옵션 이름]**

**선택 이유:**
1. 이유 1
2. 이유 2
3. 이유 3
```

#### OPTIONS.md

```markdown
# 옵션 비교 분석

## 옵션 1: [옵션 이름] (추천)

**접근 방식:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/auth/`, `src/api/`
- 예상 변경 규모: 중간
- 리스크: 낮음

---

## 옵션 2: [옵션 이름]

[동일 형식]

---

## 옵션 3: [옵션 이름]

[동일 형식]

---

## 추천 및 근거

옵션 [N]을 추천합니다.

**근거:**
1. 근거 1
2. 근거 2
3. 근거 3
```

#### IMPLEMENTATION.md

```markdown
# 구현 단계

## 1단계: [단계 이름]

**작업:**
- [ ] 작업 1
- [ ] 작업 2
- [ ] 작업 3

**변경 파일:**
- `src/file1.ts`: [변경 내용]
- `src/file2.ts`: [변경 내용]

**예상 소요 시간:** [시간]

---

## 2단계: [단계 이름]

**작업:**
- [ ] 작업 4
- [ ] 작업 5

**변경 파일:**
- `src/file3.ts`: [변경 내용]

**예상 소요 시간:** [시간]

---

## 3단계: [단계 이름]

[동일 형식]

---

## 검증 방법

- [ ] 테스트 항목 1
- [ ] 테스트 항목 2
- [ ] 통합 테스트
```

#### RISKS.md

```markdown
# 리스크 및 완화 방안

## 기술적 리스크

| 리스크 | 영향도 | 완화 방안 |
|--------|--------|----------|
| 리스크 1 | 높음 | 방안 1 |
| 리스크 2 | 중간 | 방안 2 |
| 리스크 3 | 낮음 | 방안 3 |

## 일정 리스크

| 리스크 | 영향도 | 완화 방안 |
|--------|--------|----------|
| 병목 구간 1 | 높음 | 완충 시간 확보 |
| 불확실성 1 | 중간 | 프로토타입 검증 |

## 의존성

- 외부 라이브러리: [목록]
- 다른 시스템: [목록]
- 팀 역량: [필요 기술]

## 롤백 계획

문제 발생 시 롤백 방법:
1. 단계 1
2. 단계 2
3. 단계 3
```

#### REFERENCES.md

```markdown
# 참조 자료

## 코드베이스 분석 결과

### 현재 구조

- 파일 1: [분석 내용]
- 파일 2: [분석 내용]

### 패턴 및 규칙

- 패턴 1: [설명]
- 패턴 2: [설명]

## 관련 문서

- [문서 1](링크)
- [문서 2](링크)

## 참고 자료

- 라이브러리 문서: [링크]
- 베스트 프랙티스: [링크]
- 관련 아티클: [링크]

## 탐색 결과

### Explore Agent 1

[탐색 내용 요약]

### Explore Agent 2

[탐색 내용 요약]
```

</state_management>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 3개 제시 (표준)

```markdown
## 분석 결과

### 옵션 1: [옵션 이름] (추천)

**접근 방식:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/auth/`, `src/api/`
- 예상 변경 규모: 중간
- 리스크: 낮음

---

### 옵션 2: [옵션 이름]

**접근 방식:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**영향 범위:**
...

---

### 옵션 3: [옵션 이름]

**접근 방식:**
...

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션을 선택하시겠습니까? (1/2/3)
```

</option_presentation>

---

<document_generation>

## 계획 문서 병렬 생성

사용자가 옵션을 선택하면 `.claude/plan/[기능명]-{timestamp}/` 폴더에 여러 문서를 **병렬로** 생성합니다.

### 병렬 생성 워크플로우

```text
1. 넘버링 결정: ls .claude/plan/ → 다음 번호 자동 부여
2. 폴더 생성: .claude/plan/00.[기능명]/
3. document-writer 에이전트 5개 병렬 호출
   - OVERVIEW.md (haiku)
   - OPTIONS.md (haiku)
   - IMPLEMENTATION.md (sonnet)
   - RISKS.md (haiku)
   - REFERENCES.md (haiku)
4. 모든 에이전트 완료 대기
5. 사용자에게 폴더 경로 안내
6. /execute 스킬 즉시 호출 (확인 불필요)
   - IMPLEMENTATION.md 기반 자동 구현 시작
```

### 에이전트 호출 예시

```typescript
// 옵션 선택 후 실행
// 1. 넘버링 결정
Bash("ls .claude/plan/ | grep -E '^[0-9]+' | wc -l")
const nextNumber = "00" // 결과 기반 계산
const projectName = "실시간_알림"
const basePath = `.claude/plan/${nextNumber}.${projectName}`

// 2. 폴더 생성
Bash(`mkdir -p ${basePath}`)

// 3. 5개 문서 병렬 생성
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'OVERVIEW.md 작성',
  prompt: `
    ${basePath}/OVERVIEW.md 생성:
    - 개요: ${목표}, ${범위}
    - 현재 상태: ${코드베이스_분석}
    - 선택된 옵션: 옵션 ${선택번호}
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'OPTIONS.md 작성',
  prompt: `
    ${basePath}/OPTIONS.md 생성:
    - 옵션 1, 2, 3 비교표
    - 장단점, 영향 범위
    - 추천 근거
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  description: 'IMPLEMENTATION.md 작성',
  prompt: `
    ${basePath}/IMPLEMENTATION.md 생성:
    - 구현 단계 (1, 2, 3, ...)
    - 작업 체크리스트
    - 변경 파일 목록
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'RISKS.md 작성',
  prompt: `
    ${basePath}/RISKS.md 생성:
    - 기술적 리스크
    - 일정 리스크
    - 완화 방안
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'REFERENCES.md 작성',
  prompt: `
    ${basePath}/REFERENCES.md 생성:
    - 코드베이스 분석 결과
    - 관련 문서 링크
    - Explore 에이전트 결과 요약
  `
})

// → 모든 문서 동시 생성 완료 후 사용자 안내
```

### 문서 템플릿

문서 템플릿은 `<state_management>` 섹션 참조.

</document_generation>

---

<auto_implementation>

## 자동 구현 시작

계획 문서 생성 완료 후 **사용자 확인 없이** 즉시 구현을 시작합니다.

### 워크플로우

```text
1. 계획 문서 병렬 생성 완료
2. IMPLEMENTATION.md 존재 확인
3. /execute 스킬 즉시 호출
4. 1단계부터 순차 구현
```

### 구현 시작 패턴

```typescript
// 문서 생성 완료 후 즉시 실행
Skill({
  skill: 'execute',
  args: `@.claude/plan/${nextNumber}.${projectName}/IMPLEMENTATION.md 1단계부터 구현`
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
✅ IMPLEMENTATION.md 1단계부터 자동 시작
✅ 구현 중 문제 발생 시에만 사용자 확인
```

</auto_implementation>

---

<examples>

## 실전 예시

### 예시 1: 인증 시스템 변경 (매우 복잡 - planner agent 위임)

```bash
사용자: /plan 사용자 인증을 JWT에서 세션 기반으로 변경

1. Sequential Thinking (1단계):
   thought 1: "인증 시스템 변경 - 매우 복잡함, 다중 시스템 영향,
              아키텍처 변경. planner agent로 위임하는 것이 적합"

2. planner agent 위임:
   Task({
     subagent_type: 'planner',
     description: '인증 시스템 재설계 계획',
     prompt: 'JWT 기반 인증을 세션 기반으로 전환하는 체계적 계획 수립',
     model: 'opus'
   })

3. planner agent 프로세스:
   - 인터뷰: 요구사항, 제약사항, 리스크 허용도 파악
   - 코드베이스 조사: Explore agent로 현재 구조 분석
   - 계획 생성: .claude/plan/00.세션_인증/
   - 5개 문서 병렬 생성 (OVERVIEW, OPTIONS, IMPLEMENTATION, RISKS, REFERENCES)
   - 사용자 확인 후 핸드오프

→ 복잡한 작업은 planner에게 위임하여 체계적으로 처리
```

### 예시 2: 실시간 알림 기능 (보통)

```bash
사용자: /plan 실시간 알림 기능 추가

1. Sequential Thinking (5단계):
   thought 1: "실시간 알림 - 보통 복잡도, 새 기능 추가"
   thought 2: "현재 통신 구조: REST API, 폴링 없음"
   thought 3: "접근 방식: WebSocket, SSE, Long Polling, Firebase"
   thought 4: "WebSocket이 양방향, SSE는 단방향이지만 간단"
   thought 5: "WebSocket 추천, 폴링은 비효율적"

2. Task 탐색:
   Task (Explore): "현재 API 구조 및 클라이언트 통신 방식"

3. 옵션 제시:
   옵션 1: WebSocket (추천)
   - 장점: 양방향 통신, 실시간성 우수
   - 단점: 복잡도 증가, 인프라 고려

   옵션 2: Server-Sent Events
   - 장점: 구현 단순, HTTP 기반
   - 단점: 단방향만, 브라우저 제한

   옵션 3: Short Polling
   - 장점: 구현 매우 간단
   - 단점: 비효율적, 지연 발생

4. 사용자 선택: 1

5. document-writer 에이전트 5개 병렬 호출로 문서 생성
   - .claude/plan/00.실시간_알림/
     ├── OVERVIEW.md
     ├── OPTIONS.md
     ├── IMPLEMENTATION.md
     ├── RISKS.md
     └── REFERENCES.md

6. 구현 자동 시작:
   Skill({ skill: 'execute' })
   - IMPLEMENTATION.md 읽고 1단계부터 구현
   - 확인 절차 없이 즉시 진행
```

### 예시 3: 간단한 리팩토링

```bash
사용자: /plan utils 함수를 TypeScript로 전환

1. Sequential Thinking (3단계):
   thought 1: "단순 리팩토링 - 간단, 1-2 파일"
   thought 2: "현재 utils.js 분석 필요"
   thought 3: "타입 정의 → 전환 → 테스트 검증"

2. Task 탐색:
   Read: src/utils.js
   Grep: utils 사용처 검색

3. 옵션 제시:
   옵션 A: 점진적 전환 (파일별)
   - 장점: 리스크 낮음
   - 단점: 시간 소요

   옵션 B: 일괄 전환
   - 장점: 깔끔함
   - 단점: 테스트 필요

4. 사용자 선택 → document-writer 에이전트 병렬 호출로 계획 문서 생성
   - .claude/plan/00.타입스크립트_전환/

5. 구현 자동 시작:
   Skill({ skill: 'execute' })
   - 계획 문서 기반 즉시 구현
```

</examples>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드베이스 탐색
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 영향 범위 및 예상 작업량 제시
✅ 넘버링 자동 결정 (ls .claude/plan/)
✅ document-writer 에이전트 병렬 호출로 문서 생성
✅ .claude/plan/00.[기능명]/ 폴더 구조 사용 (한글 설명)
```

절대 금지:

```text
❌ Edit/Write 도구 직접 사용 (문서 작성은 document-writer 에이전트)
❌ Sequential Thinking 3단계 미만
❌ 옵션 1개만 제시
❌ 코드 탐색 없이 추측으로 옵션 제시
❌ 장단점 없이 옵션만 나열
❌ 단일 파일로 문서 생성 (여러 파일로 분리 필수)
❌ 문서 생성 후 "구현을 시작할까요?" 물어보기 (즉시 진행)
```

</validation>
