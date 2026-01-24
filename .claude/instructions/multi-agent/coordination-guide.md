# Multi-Agent Coordination Guide

병렬 에이전트 실행 및 조정을 통한 성능 최적화와 작업 효율 극대화.

---

<overview>

## 목적 및 개요

**Goal:** 독립적인 작업을 동시에 처리하여 대기 시간 최소화, 처리량 극대화, 비용 절감.

**Performance:** 순차 실행 → 병렬 실행으로 5-15배 성능 향상.

### 사용 시점

| 상황 | 설명 | 예상 효과 |
|------|------|----------|
| **독립적인 작업** | 서로 의존하지 않는 여러 작업 | 대기 시간 → 동시 실행 시간 |
| **여러 파일 수정** | 다른 파일 동시 작업 | 순차 작업 → 병렬 처리 |
| **탐색 + 구현** | 코드베이스 분석 + 기능 구현 | 별도 컨텍스트 활용 |
| **다중 도메인** | API + UI + 문서 동시 작업 | 전문 에이전트 활용 |
| **배치 처리** | 여러 아이템 동일 작업 | 토큰 70-90% 절감 |

</overview>

---

<core_principles>

## 3대 핵심 원칙

| 원칙 | 실행 방법 | 기대 효과 |
|------|----------|----------|
| **PARALLEL** | 단일 메시지에서 여러 Tool 동시 호출 | 5-15배 속도 향상 |
| **BACKGROUND** | 10개 이상 작업 시 `run_in_background=true` | 대기 시간 제거 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | 컨텍스트 격리, 품질 향상 |

### 핵심 룰

```typescript
// ❌ 순차 실행 (느림)
Task(...) // 60초 대기
Task(...) // 60초 대기
// 총 120초

// ✅ 병렬 실행 (빠름)
Task(...) // 단일 메시지에서
Task(...) // 동시 호출
// 총 60초 (가장 긴 작업 기준)
```

</core_principles>

---

<model_routing>

## 스마트 모델 라우팅

**원칙:** 작업 복잡도에 따라 모델 선택, 비용 최적화.

### 복잡도별 모델 선택

| 복잡도 | 모델 | 작업 예시 | 비용 | 속도 |
|--------|------|----------|------|------|
| **LOW** | haiku | 파일 읽기, 정의 조회, 간단한 탐색 | 💰 | ⚡⚡⚡ |
| **MEDIUM** | sonnet | 기능 구현, 버그 수정, 리팩토링 | 💰💰 | ⚡⚡ |
| **HIGH** | opus | 아키텍처 설계, 복잡한 디버깅, 보안 | 💰💰💰 | ⚡ |

### 에이전트별 권장 모델

| 에이전트 | 권장 모델 | 용도 | 병렬 가능 |
|---------|----------|------|----------|
| **planner** | opus | 작업 계획 수립, 인터뷰, .claude/plans/ 생성 | ❌ (조정자) |
| **analyst** | sonnet | 데이터 분석, 패턴 발견 | ✅ |
| **architect** | opus | 아키텍처 설계, 시스템 디자인 | ❌ (의사결정) |
| **explore** | haiku | 코드베이스 빠른 탐색, 파일/패턴 검색 | ✅ |
| **implementation-executor** | sonnet | 즉시 구현, 옵션 제시 없이 최적 방법 실행 | ✅ |
| **designer** | sonnet/opus | UI/UX 구현, 컴포넌트 작성 | ✅ |
| **deployment-validator** | sonnet | typecheck/lint/build 검증 | ❌ (순차) |
| **lint-fixer** | sonnet | tsc/eslint 에러 자동 수정 | ✅ |
| **code-reviewer** | opus | 코드 리뷰, 보안/성능 검토 | ✅ |
| **document-writer** | haiku/sonnet | 문서 작성, 주석, README | ✅ |
| **ko-to-en-translator** | sonnet | 한글 → 영어 번역 (커밋 메시지) | ✅ |
| **git-operator** | sonnet | Git 작업 (commit, branch, merge) | ❌ (순차) |
| **dependency-manager** | sonnet | package.json 의존성 관리 | ❌ (의존성) |
| **refactor-advisor** | opus | 리팩토링 전략 제안 | ❌ (의사결정) |

**모델 명시 예시:**

```typescript
Task(subagent_type="explore", model="haiku", ...)      // 빠르고 저렴
Task(subagent_type="implementation-executor", model="sonnet", ...)
Task(subagent_type="planner", model="opus", ...)       // 복잡하지만 정확
```

</model_routing>

---

<context_preservation>

## 컨텍스트 보존 전략

### 문제: 병렬 실행 시 컨텍스트 손실

**원인:**
- 서브에이전트는 독립 컨텍스트
- 메인 에이전트 컨텍스트와 분리
- 결과만 전달됨

### 해결책

#### 1. 공유 상태 관리

```typescript
// ❌ 컨텍스트 손실
Task(subagent_type="implementation-executor",
     prompt="모듈 A 구현")
Task(subagent_type="implementation-executor",
     prompt="모듈 B 구현")
// → 서로 모듈 존재 모름

// ✅ 공유 상태 명시
Task(subagent_type="implementation-executor",
     prompt=`모듈 A 구현

     공유 상태:
     - 프로젝트 구조: [설명]
     - 공통 인터페이스: [설명]
     - 의존성: [리스트]`)

Task(subagent_type="implementation-executor",
     prompt=`모듈 B 구현 (모듈 A와 통합)

     공유 상태:
     - 프로젝트 구조: [설명]
     - 공통 인터페이스: [설명]
     - 모듈 A 위치: [경로]`)
```

#### 2. 문서 기반 컨텍스트

**활용:** 상태 문서 파일로 컨텍스트 공유.

```typescript
// Step 1: 상태 문서 생성
Write(".claude/context/project-state.md", `
# Project State

## Architecture
- Auth: JWT 기반
- Database: Prisma + PostgreSQL
- API: TanStack Start Server Functions

## Modules
- User: 완료
- Auth: 진행 중
- Post: 대기
`)

// Step 2: 병렬 실행 시 문서 참조
Task(subagent_type="implementation-executor",
     prompt="@.claude/context/project-state.md 참조하여 Post 모듈 구현")
```

#### 3. 핸드오프 (Handoffs)

**정의:** 에이전트 간 명시적 정보 전달.

```typescript
// Agent A → Agent B 핸드오프
const resultA = Task(subagent_type="explore", model="haiku",
     prompt="인증 로직 위치 찾기")

// 결과 명시적 전달
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`인증 로직 수정

     이전 에이전트 결과:
     ${resultA}

     수정 내용: [...]`)
```

#### 4. 컨텍스트 컴팩션 (Context Compaction)

**문제:** 토큰 한계 도달 시 이전 작업 손실.

**해결책:**

```typescript
// 주기적 요약 및 저장
Task(subagent_type="document-writer", model="haiku",
     prompt=`현재까지 작업 요약하여 .claude/context/summary.md에 저장

     포함 내용:
     - 완료된 작업
     - 중요 의사결정
     - 다음 단계`)
```

**컨텍스트 복구:**

```text
1. pwd → 작업 디렉토리 확인
2. Read(".claude/context/summary.md") → 진행 상태 파악
3. git log --oneline -10 → 최근 작업 확인
4. 중단 지점부터 재개
```

</context_preservation>

---

<error_handling>

## 에러 처리 및 복구

### 전략

| 전략 | 설명 | 구현 |
|------|------|------|
| **Failure Isolation** | 실패 도메인 격리 | 에이전트별 독립 실행 |
| **Retry Strategy** | 제한적 재시도 | 3회 재시도 + 에스컬레이션 |
| **Circuit Breaker** | 반복 실패 시 중단 | 3회 실패 시 대안 에이전트 |
| **Redundancy** | 중요 작업 중복 실행 | 동일 작업 여러 에이전트 |
| **Graceful Degradation** | 부분 실패 허용 | 핵심 작업 우선 완료 |
| **Monitoring** | 상태 추적 | TaskList, 로그 파일 |

### 패턴 1: 실패 격리

```typescript
// ✅ 에이전트별 격리
try {
  Task(subagent_type="implementation-executor",
       prompt="기능 A 구현")
} catch (error) {
  // 기능 A 실패해도 B는 계속
}

Task(subagent_type="implementation-executor",
     prompt="기능 B 구현")
```

### 패턴 2: 재시도 전략

```typescript
// ❌ 무한 재시도
while (true) {
  Task(...) // 위험
}

// ✅ 제한적 재시도
const maxRetries = 3
let attempt = 0

while (attempt < maxRetries) {
  try {
    Task(subagent_type="implementation-executor", ...)
    break // 성공 시 탈출
  } catch (error) {
    attempt++
    if (attempt >= maxRetries) {
      // 에스컬레이션: 더 강력한 모델 사용
      Task(subagent_type="planner", model="opus",
           prompt="문제 분석 및 대안 제시")
    }
  }
}
```

### 패턴 3: 서킷 브레이커

```typescript
// 에이전트 상태 추적
const agentFailures = new Map()

function executeWithCircuitBreaker(agentType, prompt) {
  const failures = agentFailures.get(agentType) || 0

  // 3회 이상 실패 시 차단
  if (failures >= 3) {
    console.log(`Circuit breaker: ${agentType} 차단됨`)
    // 대안 에이전트 사용
    return Task(subagent_type="alternative-agent", ...)
  }

  try {
    const result = Task(subagent_type=agentType, prompt=prompt)
    agentFailures.set(agentType, 0) // 성공 시 리셋
    return result
  } catch (error) {
    agentFailures.set(agentType, failures + 1)
    throw error
  }
}
```

### 패턴 4: 모니터링

```typescript
// 작업 상태 추적
TaskList() // pending/in_progress 작업 확인

// 실패 기록
Write(".claude/logs/failures.md", `
## Failure Log

- Time: ${timestamp}
- Agent: ${agentType}
- Task: ${taskDescription}
- Error: ${errorMessage}
- Retry: ${retryCount}
`)
```

</error_handling>

---

<best_practices>

## 모범 사례

### 실행 전 체크

```text
1. 작업 분석
   - 독립적인가? → 병렬
   - 의존적인가? → 순차
   - 유사한가? → 배치

2. 모델 선택
   - 간단 → haiku
   - 일반 → sonnet
   - 복잡 → opus

3. 컨텍스트 계획
   - 공유 상태 필요? → 문서화
   - 컨텍스트 한계? → 컴팩션

4. 에러 처리
   - 재시도 전략
   - 대안 계획
   - 모니터링
```

### 작업 분해 원칙

| 원칙 | 설명 | 예시 |
|------|------|------|
| **Single Responsibility** | 에이전트당 하나의 책임 | explore, implement, review 분리 |
| **Loose Coupling** | 에이전트 간 최소 의존성 | 공유 상태만 문서로 전달 |
| **High Cohesion** | 관련 작업 그룹화 | UI 관련 작업 → designer |

### 효율적인 프롬프트

```typescript
// ❌ 모호한 지시
Task(subagent_type="implementation-executor",
     prompt="뭔가 구현해줘")

// ✅ 명확한 지시
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`User API 엔드포인트 구현

     요구사항:
     - GET /users: 사용자 목록
     - POST /users: 사용자 생성
     - 인증: JWT 미들웨어
     - 검증: Zod 스키마

     기존 패턴:
     @functions/auth.ts 참조

     예상 결과:
     - functions/users.ts
     - 테스트 포함`)
```

### 성능 최적화 체크리스트

- [ ] 독립 작업 → 병렬 실행
- [ ] 10개 이상 유사 작업 → 배치 처리
- [ ] 10분 이상 작업 → 백그라운드 실행
- [ ] 복잡도별 모델 선택 (haiku/sonnet/opus)
- [ ] 컨텍스트 크기 모니터링 → 컴팩션
- [ ] 실패 시 재시도 제한 (3회)
- [ ] 상태 문서화 (컨텍스트 복구)

### 안티패턴

| 안티패턴 | 문제 | 올바른 방법 |
|---------|------|------------|
| **순차 실행** | 불필요한 대기 | 병렬 실행 |
| **과도한 병렬** | 컨텍스트 혼란 | 3-10개 제한 |
| **모델 미스매치** | 비용 낭비 | 복잡도별 선택 |
| **컨텍스트 미보존** | 작업 손실 | 상태 문서화 |
| **무한 재시도** | 리소스 낭비 | 3회 제한 |

</best_practices>

---

<summary>

## 핵심 요약

| 개념 | 핵심 포인트 |
|------|----------|
| **병렬 실행** | 단일 메시지에서 여러 Tool 호출 → 5-15배 향상 |
| **배치 처리** | 유사 작업 묶음 → 토큰 70-90% 절감 |
| **모델 라우팅** | haiku (간단), sonnet (일반), opus (복잡) |
| **에이전트 위임** | 전문 에이전트 즉시 위임 → 품질 향상 |
| **컨텍스트 보존** | 상태 문서화 + 핸드오프 + 컴팩션 |
| **에러 처리** | 격리 + 재시도 (3회) + 서킷 브레이커 |
| **성능 목표** | 대기 시간 80% 감소, 병렬도 3-10개 |

**시작하기:**
1. 작업 분석 → 독립/의존/유사 구분
2. 패턴 선택 → 병렬/순차/배치
3. 모델 선택 → 복잡도 기반
4. 실행 → 단일 메시지 다중 Tool
5. 모니터링 → TaskList, 로그

</summary>
