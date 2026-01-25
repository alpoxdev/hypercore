---
description: tsc/eslint 오류 검사 및 하나씩 꼼꼼히 수정. @lint-fixer 에이전트 필수 사용.
allowed-tools: Task
argument-hint: [파일/디렉토리 경로...]
---

@../instructions/multi-agent/coordination-guide.md
@../instructions/multi-agent/execution-patterns.md

# Lint Fix Command

> @lint-fixer 에이전트를 사용하여 tsc/eslint 오류를 자동으로 수정.

---

<critical_requirements>

## ⚠️ CRITICAL: 작업 시작 전 필수 확인

**이 커맨드는 반드시 @lint-fixer 에이전트를 사용해야 합니다.**

### MANDATORY: Task 도구로 @lint-fixer 호출

```typescript
Task({
  subagent_type: 'lint-fixer',
  description: 'tsc/eslint 오류 수정',
  prompt: `
    $ARGUMENTS 처리:
    ${$ARGUMENTS ? `특정 경로: ${$ARGUMENTS}` : '전체 프로젝트 검사'}

    수행할 작업:
    1. tsc + eslint 병렬 검사
    2. 오류 분류 (간단/복잡)
    3. TodoWrite로 오류 목록 생성
    4. 간단한 오류: 즉시 수정
    5. 복잡한 오류: Sequential Thinking으로 분석 후 수정
    6. 전체 재검사로 완료 확인
  `
})
```

**❌ 절대 금지:**
- Bash 도구로 tsc/eslint 직접 실행 후 수동 수정
- @lint-fixer 없이 오류 수정
- 커맨드 내에서 직접 오류 분석/수정

**✅ 필수:**
- Task 도구로 @lint-fixer 에이전트 호출
- 모든 lint 작업을 에이전트에 위임
- 에이전트가 자동으로 간단/복잡 판단 후 처리

**@lint-fixer 에이전트 장점:**
- 간단한 오류는 즉시 수정 (Sequential Thinking 불필요)
- 복잡한 오류만 Sequential Thinking 사용 (효율적)
- TodoWrite로 진행 상황 자동 추적
- 우선순위 자동 정렬 (타입 오류 → 린트 오류)

---

**진행 전 자가 점검:**
```text
□ Task 도구 사용 준비?
□ @lint-fixer 에이전트로 작업 위임?
□ Bash로 tsc/eslint 직접 실행 안 함?
```

**⚠️ 위 체크리스트를 통과하지 않으면 작업을 시작하지 마세요.**

</critical_requirements>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **회피** | `any` 타입, `@ts-ignore`, `eslint-disable` 남발 |
| **전략** | 여러 오류 동시 수정, 오류 메시지만 보고 급하게 수정 |
| **분석** | Sequential Thinking 없이 수정 |

</forbidden>

---

<agent_usage>

## @lint-fixer Agent 활용

**언제 사용:**
- 10개 이상 오류
- 복잡한 타입 오류 다수
- 백그라운드에서 자동 수정 원할 때

**호출 방법:**
```bash
@lint-fixer
# 또는 자연어
"lint 오류 자동으로 수정해줘"
```

**장점:**
- 간단한 오류는 즉시 수정 (Sequential Thinking 불필요)
- 복잡한 오류만 Sequential Thinking 사용 (효율적)
- 독립적 context에서 실행 (메인 작업 병렬 가능)

**직접 수정 vs Agent:**

| 상황 | 권장 방법 |
|------|----------|
| 1-5개 오류, 간단 | 직접 수정 (command) |
| 10개 이상 오류 | @lint-fixer |
| 복잡한 타입 오류 다수 | @lint-fixer |
| 빠른 수정 필요 | 직접 수정 |
| 백그라운드 실행 | @lint-fixer |

</agent_usage>

---

<required>

| 분류 | 필수 |
|------|------|
| **Thinking** | Sequential Thinking 3-5단계 (각 오류마다) |
| **Tracking** | TodoWrite로 오류 목록 추적 |
| **Strategy** | 하나씩 수정 → 재검사 → 다음 오류 |
| **Validation** | 각 파일 수정 후 해당 파일 재검사 |
| **Parallel** | 5개 이상 독립 오류 → Task 도구로 병렬 분석 |

</required>

---

<workflow>

1. **검사**
   ```bash
   npx tsc --noEmit
   npx eslint .
   ```

2. **TodoWrite 생성**
   - 오류 목록 정리

3. **순차 수정** (각 오류마다)
   - Sequential Thinking 3-5단계
   - 수정 적용
   - 해당 파일 재검사
   - TodoWrite 업데이트 (completed)

4. **전체 재검사**

</workflow>

---

<parallel_execution_critical>

## ⚠️ CRITICAL: 병렬 검사 필수

**tsc와 eslint는 반드시 단일 메시지에서 병렬로 실행해야 합니다.**

### 올바른 실행 방법

```typescript
// ✅ 단일 메시지에서 2개 Bash 동시 호출
Bash({ command: "npx tsc --noEmit", description: "TypeScript type check" })
Bash({ command: "npx eslint .", description: "ESLint check" })
```

**이렇게 하면:**
- 2개의 검사가 동시에 실행됨
- 총 실행 시간 = max(tsc 시간, eslint 시간)
- 순차 실행 대비 약 50% 시간 단축

### 잘못된 실행 방법

```typescript
// ❌ 순차 실행 (느림)
Bash({ command: "npx tsc --noEmit", description: "..." })
// 대기...
Bash({ command: "npx eslint .", description: "..." })
```

**이렇게 하면:**
- tsc 완료 후 eslint 시작
- 총 실행 시간 = tsc 시간 + eslint 시간
- 불필요한 대기 시간 발생

### 병렬 검사 체크리스트

작업 시작 전 확인:

- [ ] tsc와 eslint를 단일 메시지에서 호출하는가?
- [ ] 2개의 Bash 도구를 연속으로 작성했는가?
- [ ] 중간에 대기나 다른 작업이 없는가?

**모든 항목이 체크되어야 올바른 병렬 실행입니다.**

### 파일별 병렬 수정 패턴

**독립적인 파일의 오류는 병렬 수정 가능:**

```typescript
// ✅ 서로 다른 파일 동시 수정
Task({ subagent_type: 'lint-fixer', model: 'haiku',
       prompt: 'src/utils/format.ts 린트 오류 수정' })
Task({ subagent_type: 'lint-fixer', model: 'haiku',
       prompt: 'src/components/Button.tsx 린트 오류 수정' })

// ❌ 같은 파일 동시 수정 (충돌 위험)
Task({ prompt: 'src/utils/format.ts 타입 오류 수정' })
Task({ prompt: 'src/utils/format.ts 린트 오류 수정' })
```

**규칙:**
- 독립 파일 → 병렬 수정 가능
- 동일 파일 → 순차 수정 필수
- 타입 정의 공유 → 순차 수정 필수

### 실제 실행 워크플로우

**Step 1: 병렬 검사 (필수)**

```typescript
// 커맨드 시작 시 즉시 실행
Bash({
  command: "npx tsc --noEmit",
  description: "TypeScript type check"
})
Bash({
  command: "npx eslint .",
  description: "ESLint check"
})
```

**Step 2: 오류 분석 및 그룹핑**

- 간단한 오류: 즉시 수정 (Sequential Thinking 불필요)
- 복잡한 오류: Sequential Thinking 3-5단계로 분석

**Step 3: 독립 파일 병렬 수정**

```typescript
// 서로 다른 파일의 간단한 오류
Edit({ file_path: "src/utils/format.ts", ... })  // 파일 1
Edit({ file_path: "src/components/Button.tsx", ... })  // 파일 2
```

**Step 4: 재검사**

```typescript
// 수정된 파일들 병렬 재검사
Bash({
  command: "npx tsc --noEmit src/utils/format.ts",
  description: "Verify format.ts fixes"
})
Bash({
  command: "npx tsc --noEmit src/components/Button.tsx",
  description: "Verify Button.tsx fixes"
})
```

**전체 실행 시간:**
- 순차: 검사(4초) + 수정1(2초) + 재검사1(1초) + 수정2(2초) + 재검사2(1초) = 10초
- 병렬: 검사(2초) + 수정1,2 병렬(2초) + 재검사(1초) = 5초
- **개선: 50% 시간 단축**

</parallel_execution_critical>

---

<sequential_thinking>

**각 오류마다 필수:**

| 단계 | 내용 |
|------|------|
| 1 | 오류 메시지 분석 및 이해 |
| 2 | 관련 코드 컨텍스트 파악 |
| 3 | 근본 원인 식별 |
| 4 | 수정 방안 검토 (여러 옵션 고려) |
| 5 | 최적 수정 방안 선택 및 적용 |

**파라미터:**

```typescript
{
  thought: "현재 사고 내용",
  nextThoughtNeeded: true | false,
  thoughtNumber: 1, // 현재 단계
  totalThoughts: 5  // 예상 총 단계 (동적 조정 가능)
}
```

</sequential_thinking>

---

<parallel_strategy>

**5개 이상 오류 시:**

```
1. 독립적 오류 그룹 식별
2. Task 도구로 병렬 분석 (단일 메시지에 다중 Task 호출)
3. 분석 결과 취합 후 순차 수정
```

**규칙:**

| 규칙 | 설명 |
|------|------|
| 독립성 확인 | 같은 파일/연관 타입 → 순차 처리 |
| 분석만 병렬 | 수정 적용은 항상 순차 |
| 결과 검증 | 충돌 시 Sequential Thinking으로 해결 |

**subagent_type:**

| 유형 | 용도 |
|------|------|
| `Explore` | 오류 관련 코드 컨텍스트 탐색 |
| `general-purpose` | 복잡한 타입 오류 심층 분석 |

</parallel_strategy>

---

<commands>

**검사:**

```bash
# TypeScript (전체)
npx tsc --noEmit

# TypeScript (특정 파일)
npx tsc --noEmit $ARGUMENTS

# ESLint (전체)
npx eslint .

# ESLint (특정 파일/디렉토리)
npx eslint $ARGUMENTS
```

**인수 처리:**

| 인수 | 동작 |
|------|------|
| 없음 | 전체 프로젝트 검사 |
| 파일 경로 | 해당 파일만 |
| 디렉토리 | 해당 디렉토리만 |

</commands>

---

<examples>

**Example 1: Sequential Thinking 워크플로우**

```
1. npx tsc --noEmit 실행
   → TS2322: Type 'string' is not assignable to type 'number'

2. Sequential Thinking 시작:
   thought 1: "TS2322 오류. string을 number에 할당 시도"
   thought 2: "해당 파일의 변수 타입과 값 확인 필요"
   thought 3: "함수 반환 타입이 number인데 string 반환 중"
   thought 4: "수정 옵션: 1) 반환값 수정 2) 타입 수정"
   thought 5: "반환값을 올바른 number로 수정하는 것이 적절"

3. Edit으로 수정 적용

4. npx tsc --noEmit $FILE 재검사 → 해결 확인

5. TodoWrite 업데이트 (completed) → 다음 오류
```

**Example 2: 병렬 처리 (5개 이상 오류)**

```
독립적 파일 3개의 오류 발견:

Task 1: "src/utils/api.ts의 TS2322 분석 - 타입 불일치 원인과 수정 방안"
Task 2: "src/components/Form.tsx의 ESLint no-unused-vars 분석"
Task 3: "src/hooks/useAuth.ts의 TS2532 분석 - undefined 체크 위치"

→ 3개 Task 병렬 실행 (단일 메시지)
→ 결과 취합 후 Sequential Thinking으로 수정 순서 결정
→ 순차 수정 적용
```

**Example 3: 우선순위**

| 우선순위 | 유형 | 예시 |
|----------|------|------|
| 1 | 타입 오류 (컴파일 차단) | TS2322, TS2345 |
| 2 | 린트 오류 (error 레벨) | no-unused-vars |
| 3 | 린트 경고 (warning 레벨) | prefer-const |

</examples>
