# Bug Fix Skill

> 버그 원인 분석, 수정 옵션 제시, 구현까지 처리하는 스킬

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **타입 에러** | Property 'X' does not exist on type 'Y' |
| **런타임 에러** | Cannot read property of undefined, null reference |
| **논리 오류** | 중복 렌더링, 잘못된 계산, 상태 관리 이슈 |
| **API 에러** | 500 에러, 잘못된 응답, CORS 문제 |
| **간헐적 버그** | 특정 조건에서만 발생하는 오류 |

## 호출 방법

```bash
# 직접 처리
Skill: bug-fix <에러 메시지 또는 버그 설명>

# 병렬 수정 (여러 독립 버그)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '버그 1 수정: [설명]'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '버그 2 수정: [설명]'
})
```

## 결과물

- 버그 원인 분석
- 2-3개 수정 옵션 제시 (장단점, 리스크)
- 추천안 및 근거
- 선택 후 코드 수정 + 검증

</when_to_use>

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"어떤 버그를 수정해야 하나요? 구체적으로 알려주세요.

예시:
- 에러 메시지 및 발생 위치
- 예상 동작 vs 실제 동작
- 재현 방법
- 관련 파일 경로"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 없으면 질문 | - |
| 2. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 3. 버그 재현 | 에러 재현, 관련 파일 파악 | Read/Grep/Glob |
| 4. 원인 분석 | Task (Explore)로 관련 코드 탐색 | Task (Explore) |
| 5. 옵션 도출 | 수정 방법 2-3개 도출 | sequentialthinking (2-4단계) |
| 6. 옵션 제시 | 장단점, 영향 범위 제시 | - |
| 7. 사용자 선택 | 수정 방법 선택 대기 | - |
| 8. 구현 | 선택된 방법으로 코드 수정 | Edit |
| 9. 검증 | 테스트 실행, 빌드 확인 | Bash |

</workflow>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 복잡도 판단
- 에러 유형: syntax/runtime/logic/type
- 영향 범위: 단일 파일 vs 다중 파일
- 의존성: 외부 라이브러리, API 연동
- 재현 가능성: 항상 발생 vs 간헐적
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|------------|
| **간단** | 3 | 명확한 에러, 1-2 파일 | 복잡도 판단 → 원인 분석 → 수정 방법 |
| **보통** | 5 | 논리 오류, 3-5 파일 | 복잡도 판단 → 재현 → 원인 분석 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 간헐적 오류, 다중 모듈 | 복잡도 판단 → 재현 시도 → 심층 분석 → 옵션 탐색 → 비교 → 추천안 |

### 보통 복잡도 패턴 (5단계)

```
thought 1: 복잡도 판단 및 분석 범위
thought 2: 버그 재현 및 에러 메시지 분석
thought 3: 관련 코드 탐색 및 원인 파악
thought 4: 수정 방법 2-3개 비교 분석
thought 5: 최종 추천안 및 근거
```

### 핵심 원칙

```text
✅ 사고 과정을 출력해야 실제로 생각이 일어남
✅ 복잡도가 불확실하면 높게 책정 (3→5로 확장 가능)
✅ 각 thought에서 구체적 분석 필요 (추상적 설명 금지)
✅ 필요 시 isRevision으로 이전 사고 수정
```

</thinking_strategy>

---

<exploration>

## Task (Explore) 활용

### 탐색 전략

| 버그 유형 | 탐색 대상 | prompt 예시 |
|----------|----------|-------------|
| **타입 에러** | 타입 정의, 사용처 | "타입 X 정의 위치 및 사용 파일 탐색" |
| **런타임 에러** | 함수 호출 체인 | "함수 Y 호출 경로 및 관련 파일" |
| **논리 오류** | 상태 관리, 데이터 흐름 | "상태 Z 변경 위치 및 영향 범위" |
| **API 에러** | 엔드포인트, 요청/응답 | "API /path 관련 코드 구조" |

### Task 호출 패턴

**단일 탐색:**

```typescript
Task({
  subagent_type: 'Explore',
  description: '에러 관련 코드 탐색',
  prompt: `
    에러 발생 관련 코드 구조 파악:
    - 에러가 발생하는 정확한 위치
    - 관련 함수/컴포넌트
    - 의존하는 모듈/라이브러리
    - 최근 수정 이력 (git blame)
  `
})
```

**병렬 탐색 (복잡한 경우):**

```typescript
// 단일 메시지에 다중 Task 호출
Task({
  subagent_type: 'Explore',
  prompt: '프론트엔드 에러 발생 컴포넌트 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '백엔드 API 엔드포인트 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '타입 정의 및 인터페이스 분석'
})

// → 결과 취합 후 원인 파악
```

### 탐색 체크리스트

```text
✅ 에러 발생 정확한 위치
✅ 관련 함수/클래스/컴포넌트
✅ 데이터 흐름 및 상태 변경
✅ 외부 의존성 (라이브러리, API)
✅ 최근 변경 사항 (git log/blame)
```

</exploration>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 2-3개 제시

```markdown
## 버그 분석 결과

**원인:** [원인 설명]

**영향 범위:** [파일 및 모듈 목록]

---

### 옵션 1: [수정 방법] (추천)

**수정 내용:**
- 변경 사항 1
- 변경 사항 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**수정 파일:**
- `src/file1.ts:line`
- `src/file2.ts:line`

**리스크:** 낮음

---

### 옵션 2: [수정 방법]

**수정 내용:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**수정 파일:**
...

**리스크:** 중간

---

### 옵션 3: [수정 방법] (임시 해결)

**수정 내용:**
...

**리스크:** 높음 (근본 해결 아님)

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션으로 수정하시겠습니까? (1/2/3)
```

</option_presentation>

---

<implementation>

## 구현 가이드

### 수정 단계

```
1. 사용자 옵션 선택 대기
2. Edit 도구로 코드 수정
3. 수정 내용 설명
4. 테스트/빌드 실행 (선택)
5. 결과 확인
```

### 수정 후 검증

```bash
# 타입 체크
npm run typecheck
# 또는
tsc --noEmit

# 테스트 실행
npm test
# 또는
npm test -- <관련 테스트 파일>

# 빌드 확인
npm run build
```

### 검증 체크리스트

```text
✅ 에러 해결 확인
✅ 기존 기능 영향 없음
✅ 타입 에러 없음
✅ 테스트 통과
✅ 빌드 성공
```

</implementation>

---

<parallel_agent_execution>

## Parallel Agent Execution

### Smart Model Routing

| 복잡도 | 버그 유형 | 모델 | 작업 예시 |
|--------|----------|------|----------|
| **LOW** | 단순 버그 | haiku | 오타, 명백한 로직 오류, 누락된 import |
| **MEDIUM** | 일반 버그 | sonnet | 기능 오작동, 상태 관리 이슈, API 에러 |
| **HIGH** | 복잡한 버그 | opus | 아키텍처 설계 결함, 성능 이슈, 보안 취약점 |

**에이전트 호출 시 항상 `model` 파라미터 명시:**

```typescript
Task(subagent_type="implementation-executor", model="sonnet", ...)
Task(subagent_type="explore", model="haiku", ...)
Task(subagent_type="architect", model="opus", ...)
```

### Recommended Agents

| 도메인 | 에이전트 | 권장 모델 | 용도 |
|--------|---------|----------|------|
| 탐색 | explore | haiku | 버그 재현 경로, 관련 파일 탐색 |
| 아키텍처 | architect | sonnet/opus | 근본 원인 분석, 설계 논의 (READ-ONLY) |
| 구현 | implementation-executor | sonnet | 버그 수정 구현 |
| 검증 | code-reviewer | opus | 수정 후 코드 리뷰, 회귀 검증 |
| 린트 | lint-fixer | sonnet | tsc/eslint 오류 수정 |
| 문서 | document-writer | haiku/sonnet | 버그 리포트, 수정 내역 문서화 |

### Bug Severity별 병렬 처리

| 심각도 | 특징 | 병렬 처리 전략 |
|--------|------|---------------|
| **CRITICAL** | 서비스 중단, 데이터 손실 | 즉시 수정 (순차) + 영향도 분석 (병렬) |
| **HIGH** | 주요 기능 오작동 | 독립 버그 동시 수정 (병렬) |
| **MEDIUM** | 사소한 오류 | 여러 버그 일괄 수정 (병렬) |

**CRITICAL 버그:**

```typescript
// ❌ 병렬 실행 금지 - 즉시 수정
Task({
  subagent_type: 'implementation-executor',
  model: 'opus',
  prompt: 'CRITICAL: 인증 우회 취약점 즉시 패치'
})

// ✅ 수정 완료 후 영향도 분석 병렬 실행
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '유사 취약점 전체 코드베이스 스캔'
})
Task({
  subagent_type: 'document-writer',
  model: 'sonnet',
  prompt: '보안 인시던트 리포트 작성'
})
```

**HIGH/MEDIUM 버그:**

```typescript
// ✅ 독립적인 버그 동시 수정
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '로그인 토큰 만료 처리 버그 수정'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '결제 금액 계산 오류 수정'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '프로필 이미지 업로드 실패 수정'
})
```

### 영향도 분석 + 수정 동시 실행

버그 발견 시 탐색과 수정을 병렬로 진행:

```typescript
// ✅ 패턴: 수정 + 영향도 분석 병렬
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '사용자 목록 중복 렌더링 버그 수정 (useEffect 의존성)'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '동일한 useEffect 패턴 사용 컴포넌트 전체 탐색'
})

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '유사 렌더링 버그 가능성 검토'
})

// → 수정과 동시에 다른 곳에 같은 버그가 없는지 확인
```

### 다중 파일 버그 병렬 수정

여러 파일에 걸친 버그를 동시에 수정:

```typescript
// ✅ 독립적인 파일 동시 수정
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'src/routes/posts/-components/PostList.tsx: key prop 누락 추가'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'src/routes/comments/-components/CommentList.tsx: key prop 누락 추가'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'src/routes/users/-components/UserList.tsx: key prop 누락 추가'
})

// → 3개 파일을 동시에 수정 (순차 대비 3배 빠름)
```

### 테스트 병렬 실행

버그 수정 후 여러 종류의 테스트를 동시에 실행:

```typescript
// ✅ 다양한 테스트 레벨 병렬 실행
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'Unit 테스트 실행: npm test -- src/functions/auth.test.ts'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'Integration 테스트 실행: npm test -- tests/integration/auth.test.ts'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'E2E 테스트 실행: npm run test:e2e -- auth.spec.ts'
})

// → 3가지 테스트 레벨을 동시에 검증
```

### Parallel Execution Patterns

#### 패턴 1: 탐색 + 분석 병렬

```typescript
// ❌ 순차 실행 (느림)
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '간헐적 500 에러 재현 경로 탐색'
})
// 대기...
Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '500 에러 근본 원인 분석'
})

// ✅ 병렬 실행 (빠름)
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '간헐적 500 에러 재현 경로 탐색 및 재현 조건 파악'
})
Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '500 에러 패턴 분석 및 근본 원인 파악 (로그, 스택 트레이스 기반)'
})

// → 탐색 결과와 분석 결과를 종합하여 수정 방향 결정
```

#### 패턴 2: 수정 + 문서화 병렬

```typescript
// ✅ 코드 수정과 동시에 문서화
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '인증 버그 수정: 토큰 재발급 로직 개선'
})
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: '버그 리포트 작성: 원인, 수정 내용, 영향 범위'
})
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: 'CHANGELOG.md 업데이트: 버그 수정 항목 추가'
})
```

#### 패턴 3: 다중 검증 병렬

```typescript
// ✅ 수정 후 여러 관점에서 동시 검토
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '보안 검토: 수정으로 인한 새로운 취약점 확인'
})
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '성능 검토: 수정이 성능에 미치는 영향 분석'
})
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '회귀 검토: 다른 기능에 부작용 없는지 확인'
})
```

### Practical Examples (시간 비교 포함)

#### 예시 1: 여러 독립 버그 동시 수정

**상황:** 3개의 독립적인 버그 발견 (로그인, 결제, 프로필)

**순차 실행:**
```typescript
// ❌ 순차 실행: 15-20분 소요
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '로그인 버그 수정: 토큰 만료 처리 누락'
})
// 대기... (5-7분)

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '결제 버그 수정: 금액 계산 오류'
})
// 대기... (5-7분)

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '프로필 버그 수정: 이미지 업로드 실패'
})
// 대기... (5-7분)

// → 총 소요 시간: 15-20분
```

**병렬 실행:**
```typescript
// ✅ 병렬 실행: 5-7분 소요 (3배 빠름)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '로그인 버그 수정: src/auth/login.ts 토큰 만료 처리 추가'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '결제 버그 수정: src/payment/checkout.ts 금액 계산 로직 수정'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '프로필 버그 수정: src/routes/profile/-functions/upload.ts 파일 검증 추가'
})

// → 총 소요 시간: 5-7분 (동시 실행)
```

#### 예시 2: 탐색 + 분석 + 수정 병렬

**상황:** 간헐적 타입 에러 발생, 원인 불명

**순차 실행:**
```typescript
// ❌ 순차 실행: 20-25분 소요
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '타입 에러 발생 위치 및 조건 탐색'
})
// 대기... (5분)

Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '타입 에러 근본 원인 분석'
})
// 대기... (7분)

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '타입 에러 수정'
})
// 대기... (8분)

// → 총 소요 시간: 20-25분
```

**병렬 실행:**
```typescript
// ✅ 병렬 실행: 10-12분 소요 (2배 빠름)
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '타입 에러 발생 위치, 재현 조건, 관련 파일 탐색'
})
Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '타입 정의 분석 및 근본 원인 파악'
})

// → 탐색 + 분석 결과 취합 후 수정 (10분)

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '[탐색 결과 기반] 타입 정의 수정 및 사용처 업데이트'
})

// → 총 소요 시간: 10-12분
```

#### 예시 3: 다중 파일 동일 버그 병렬 수정

**상황:** 10개 컴포넌트에서 동일한 패턴의 버그 발견 (React key prop 누락)

**순차 실행:**
```typescript
// ❌ 순차 실행: 30-40분 소요
// 각 파일을 하나씩 수정... (10개 × 3-4분)

// → 총 소요 시간: 30-40분
```

**병렬 실행:**
```typescript
// ✅ 병렬 실행: 3-5분 소요 (10배 빠름)
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/routes/posts/-components/PostList.tsx: key prop 추가'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/routes/comments/-components/CommentList.tsx: key prop 추가'
})
Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'src/routes/users/-components/UserList.tsx: key prop 추가'
})
// ... 10개 파일 동시 수정

// → 총 소요 시간: 3-5분 (동시 실행)
```

#### 예시 4: 수정 후 다중 검증 병렬

**상황:** 보안 버그 수정 후 전체 검증 필요

**순차 실행:**
```typescript
// ❌ 순차 실행: 25-30분 소요
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'SQL Injection 취약점 수정'
})
// 대기... (10분)

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '보안 검토: 유사 취약점 확인'
})
// 대기... (8분)

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '회귀 검토: 다른 기능 영향 확인'
})
// 대기... (7분)

// → 총 소요 시간: 25-30분
```

**병렬 실행:**
```typescript
// ✅ 병렬 실행: 15-18분 소요 (1.5배 빠름)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'SQL Injection 취약점 수정: Prisma raw query 제거 및 ORM 사용'
})

// 수정 완료 후 동시 검증 (10분)
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '보안 검토: 전체 코드베이스 SQL Injection 취약점 스캔'
})
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '회귀 검토: 쿼리 변경으로 인한 성능/기능 영향 분석'
})
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '접근성 검토: 에러 메시지 사용자 친화성 확인'
})

// → 총 소요 시간: 15-18분
```

### Bug Fix Workflow with Agents

| 단계 | 작업 | 에이전트 | 모델 | 병렬 실행 |
|------|------|---------|------|----------|
| 1 | 버그 재현 경로 탐색 | explore | haiku | ✅ (여러 영역) |
| 2 | 근본 원인 분석 | architect | sonnet/opus | ✅ (탐색과 동시) |
| 3 | 버그 수정 구현 | implementation-executor | sonnet | ✅ (독립 버그) |
| 4 | 린트/타입 수정 | lint-fixer | sonnet | ❌ (순차) |
| 5 | 코드 리뷰 | code-reviewer | opus | ✅ (다중 관점) |
| 6 | 테스트 실행 | implementation-executor | haiku | ✅ (unit/integration/e2e) |
| 7 | 문서화 | document-writer | haiku | ✅ (리포트/CHANGELOG) |

### Checklist

버그 수정 시 병렬 실행 체크리스트:

```text
✅ 여러 독립 버그 → 각 버그마다 별도 executor
✅ 탐색 + 분석 → explore + architect 동시 실행
✅ 다중 파일 수정 → 파일별 executor 병렬 실행
✅ 수정 + 문서화 → executor + document-writer 동시 실행
✅ 다중 검증 → 여러 code-reviewer 병렬 실행
✅ 테스트 병렬화 → unit/integration/e2e 동시 실행
✅ 모델 선택 → LOW: haiku / MEDIUM: sonnet / HIGH: opus
✅ 심각도 확인 → CRITICAL은 즉시 수정 (병렬 금지)

❌ 순차 의존성 있는 작업 → 병렬 실행 금지
❌ 같은 파일 동시 수정 → 충돌 위험
❌ CRITICAL 버그 → 병렬 금지, 즉시 수정
```

### Time Optimization Summary

| 작업 유형 | 순차 실행 | 병렬 실행 | 시간 절감 |
|----------|----------|----------|----------|
| 3개 독립 버그 수정 | 15-20분 | 5-7분 | **3배** |
| 탐색 + 분석 + 수정 | 20-25분 | 10-12분 | **2배** |
| 10개 파일 동일 버그 | 30-40분 | 3-5분 | **10배** |
| 수정 + 다중 검증 | 25-30분 | 15-18분 | **1.5배** |

**병렬 실행으로 평균 2-5배 빠른 버그 수정 가능.**

</parallel_agent_execution>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드 탐색
✅ 원인 분석 명확히
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 수정 파일 위치 명시 (line 포함)
```

절대 금지:

```text
❌ ARGUMENT 없이 분석 시작
❌ Sequential Thinking 3단계 미만
❌ 코드 탐색 없이 추측으로 수정
❌ 옵션 1개만 제시
❌ 사용자 선택 없이 수정 시작
❌ 수정 후 검증 생략
❌ 장단점 없이 수정 방법만 나열
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: 타입 에러

```bash
사용자: /bug-fix Property 'name' does not exist on type 'User'

1. Sequential Thinking (3단계):
   thought 1: "타입 에러 - 간단, User 타입 정의 확인"
   thought 2: "User 타입 및 사용처 탐색 필요"
   thought 3: "옵션 2개: 타입 정의 수정 vs 사용처 수정"

2. Task 탐색:
   Task (Explore): "User 타입 정의 위치 및 사용 파일 탐색"
   → src/types/user.ts, src/components/UserProfile.tsx 파악

3. 원인 분석:
   User 타입에 name 속성 누락

4. 옵션 제시:
   옵션 1: User 타입에 name 속성 추가 (추천)
   - 장점: 근본 해결
   - 단점: 없음

   옵션 2: 사용처에서 name 제거
   - 장점: 빠른 수정
   - 단점: 기능 손실

5. 사용자 선택: 1

6. Edit:
   src/types/user.ts:3
   + name: string;

7. 검증:
   npm run typecheck → 성공
```

### 예시 2: 런타임 에러

```bash
사용자: /bug-fix Cannot read property 'data' of undefined

1. Sequential Thinking (5단계):
   thought 1: "런타임 에러 - 보통 복잡도, null/undefined 체크 누락"
   thought 2: "에러 발생 위치 파악 필요, 스택 트레이스 확인"
   thought 3: "관련 코드 탐색: API 호출, 데이터 접근 패턴"
   thought 4: "수정 방법: optional chaining, null 체크, 초기화"
   thought 5: "optional chaining 추천 - 간결하고 안전"

2. Task 탐색:
   Task (Explore): "undefined 에러 발생 코드 및 데이터 흐름 분석"
   → src/hooks/useUserData.ts:15, API 응답 체크 누락

3. 원인 분석:
   API 응답 실패 시 response가 undefined

4. 옵션:
   옵션 1: optional chaining 사용 (추천)
   옵션 2: if 문으로 null 체크
   옵션 3: try-catch로 감싸기

5. 선택 후 구현 → 검증
```

### 예시 3: 논리 오류

```bash
사용자: /bug-fix 사용자 목록이 중복으로 표시됨

1. Sequential Thinking (5단계):
   thought 1: "논리 오류 - 보통 복잡도, 상태 관리 이슈"
   thought 2: "리렌더링 또는 데이터 fetch 중복 추측"
   thought 3: "관련 컴포넌트 및 상태 관리 코드 탐색"
   thought 4: "옵션: useEffect 의존성 수정, 중복 제거 로직 추가"
   thought 5: "useEffect 의존성 수정 추천"

2. Task 탐색:
   Task (Explore): "사용자 목록 렌더링 컴포넌트 및 상태 관리"
   → UserList.tsx, useEffect 의존성 배열 문제 발견

3. 원인: useEffect 의존성 배열 누락으로 매번 fetch

4. 옵션 제시 → 선택 → 구현 → 검증
```

</examples>
