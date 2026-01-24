# Multi-Agent Execution Patterns

병렬 에이전트 실행 및 조정 패턴을 통한 성능 최적화.

---

<overview>

## 목적 및 사용 시점

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

<execution_patterns>

## 실행 패턴

### 패턴 1: 단일 메시지 병렬 실행

**원칙:** 독립적인 작업은 단일 응답에서 여러 Tool 호출.

```typescript
// ❌ 순차 실행 (느림)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="기능 A 구현")
// 대기... (60초)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="기능 B 구현")
// 대기... (60초)
// 총 시간: 120초

// ✅ 병렬 실행 (빠름)
// 단일 메시지에서 두 Task 동시 호출
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="기능 A 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="기능 B 구현")
// 총 시간: 60초 (가장 긴 작업 기준)
```

**적용 조건:**
- 작업 간 의존성 없음
- 서로 다른 파일/영역
- 결과가 서로 영향 없음

---

### 패턴 2: Fan-Out Fan-In

**정의:** 하나의 작업을 여러 하위 작업으로 분산(Fan-Out) → 결과 수집 및 통합(Fan-In).

```typescript
// Fan-Out: 여러 컴포넌트 동시 구현
Task(subagent_type="designer", model="sonnet",
     prompt="Header 컴포넌트 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="Footer 컴포넌트 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="Sidebar 컴포넌트 구현")

// Fan-In: 결과 수집 후 통합
Read("components/Header.tsx")
Read("components/Footer.tsx")
Read("components/Sidebar.tsx")
// → Layout.tsx에 통합
```

**활용 사례:**
- 여러 API 엔드포인트 동시 호출
- 다중 컴포넌트 병렬 구현
- 배치 데이터 처리

---

### 패턴 3: 계층적 위임 (Hierarchical Delegation)

**구조:** 메인 에이전트 → 계획 + 조정, 서브 에이전트 → 실행.

```typescript
// 메인 에이전트: 계획 수립
Task(subagent_type="planner", model="opus",
     prompt="전체 아키텍처 설계 및 작업 분해")

// 서브 에이전트: 병렬 실행
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Auth 모듈 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User 모듈 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Post 모듈 구현")
```

**장점:**
- 컨텍스트 격리 (각 에이전트 독립 컨텍스트)
- 전문화 (도메인별 최적화)
- 재시도 용이 (실패 시 해당 에이전트만 재실행)

---

### 패턴 4: 배치 처리 (Batching)

**원리:** 유사 작업을 묶어서 컨텍스트 공유, 토큰 70-90% 절감.

```typescript
// ❌ 개별 처리 (비효율)
Edit("file1.ts", ...) // 컨텍스트 전송
Edit("file2.ts", ...) // 컨텍스트 재전송
Edit("file3.ts", ...) // 컨텍스트 재전송

// ✅ 배치 처리 (효율)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`다음 파일들에 동일한 수정 적용:
     - file1.ts
     - file2.ts
     - file3.ts

     수정 내용: [공통 규칙]`)
```

**적용 기준:**
- 10개 이상 유사 작업
- 공통 컨텍스트 공유 가능
- 순서 무관

---

### 패턴 5: 백그라운드 실행

**사용 시점:** 10분 이상 소요 작업, 빌드/테스트.

```typescript
// ✅ 백그라운드 실행
Bash("npm install", run_in_background=true)
Bash("npm run build", run_in_background=true)
Bash("npm test", run_in_background=true)

// 메인 작업 계속 진행
Task(subagent_type="implementation-executor", ...)

// 나중에 결과 확인
TaskOutput(task_id="...")
```

**백그라운드 대상:**
- 패키지 설치 (`npm install`, `pip install`)
- 빌드 (`npm run build`, `tsc`)
- 테스트 스위트 (`npm test`, `pytest`)
- Docker 작업 (`docker build`, `docker pull`)

**포그라운드 유지:**
- 파일 읽기/쓰기 (즉시 결과 필요)
- 간단한 명령어 (`git status`, `ls`)
- 에러 즉시 처리 필요한 작업

</execution_patterns>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 서브에이전트 패턴 (Subagents)

**특징:** 메인 에이전트가 컨텍스트 유지, 서브에이전트는 stateless.

```typescript
// 메인 에이전트: 전체 흐름 조정
// 서브에이전트 1: API 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User API 엔드포인트 구현")

// 서브에이전트 2: UI 구현 (동시 실행)
Task(subagent_type="designer", model="sonnet",
     prompt="User Profile UI 구현")

// 서브에이전트 3: 테스트 작성 (동시 실행)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="API 통합 테스트 작성")
```

**장점:**
- 컨텍스트 격리 (재귀 위임 방지)
- 병렬 실행 (독립적인 작업)
- 재사용 가능 (전문화된 에이전트)

---

### 패턴 2: 순차 파이프라인 (Sequential Pipeline)

**용도:** 단계별 의존성 있는 작업.

```typescript
// Step 1: 분석 (haiku)
Task(subagent_type="explore", model="haiku",
     prompt="기존 인증 로직 분석")

// Step 2: 구현 (sonnet) - Step 1 결과 필요
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="분석 결과 바탕으로 새 인증 로직 구현")

// Step 3: 검증 (sonnet) - Step 2 완료 필요
Task(subagent_type="deployment-validator", model="sonnet",
     prompt="typecheck/lint/build 검증")
```

**주의:** 순차 실행은 의존성이 명확할 때만 사용.

---

### 패턴 3: 라우터 패턴 (Router)

**정의:** 중앙 에이전트가 작업 분석 후 전문 에이전트에게 라우팅.

```typescript
// 작업 분석
const taskType = analyzeTask(userRequest)

// 조건부 라우팅
if (taskType === "frontend") {
  Task(subagent_type="designer", model="sonnet", ...)
} else if (taskType === "backend") {
  Task(subagent_type="implementation-executor", model="sonnet", ...)
} else if (taskType === "documentation") {
  Task(subagent_type="document-writer", model="haiku", ...)
}
```

**활용:** 복잡한 요청을 도메인별로 자동 분배.

</coordination_patterns>

---

<practical_examples>

## 실전 예제

### 예제 1: 풀스택 기능 구현

```typescript
// 목표: User Profile 기능 구현 (API + UI + 테스트)

// ✅ 병렬 실행
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`User Profile API 구현

     - GET /profile: 프로필 조회
     - PUT /profile: 프로필 수정
     - 인증 필수
     - Prisma User 모델 사용`)

Task(subagent_type="designer", model="sonnet",
     prompt=`User Profile UI 구현

     - 프로필 조회 화면
     - 수정 폼
     - TanStack Query 사용
     - Tailwind 스타일`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`User Profile 통합 테스트 작성

     - API 테스트
     - UI 테스트
     - E2E 시나리오`)
```

**예상 시간:**
- 순차 실행: 180초 (60 + 60 + 60)
- 병렬 실행: 60초 (가장 긴 작업)
- 개선: 3배 향상

---

### 예제 2: 대규모 리팩토링

```typescript
// 목표: 10개 파일 동일 패턴으로 리팩토링

// ❌ 순차 실행 (비효율)
Edit("file1.ts", ...)
Edit("file2.ts", ...)
// ... (10번 반복)

// ✅ 배치 처리 (효율)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`다음 파일들 리팩토링:

     파일 목록:
     - file1.ts
     - file2.ts
     - file3.ts
     - file4.ts
     - file5.ts
     - file6.ts
     - file7.ts
     - file8.ts
     - file9.ts
     - file10.ts

     공통 규칙:
     1. const 함수 → arrow function
     2. any → unknown
     3. 명시적 return type 추가

     패턴:
     ❌ function fn() { ... }
     ✅ const fn = (): ReturnType => { ... }`)
```

**예상 효과:**
- 토큰 사용: 70-90% 절감
- 실행 시간: 단축
- 일관성: 향상

---

### 예제 3: 멀티 스테이지 파이프라인

```typescript
// Phase 1: 탐색 (병렬)
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 구조 분석")
Task(subagent_type="explore", model="haiku",
     prompt="기존 인증 로직 위치")
Task(subagent_type="explore", model="haiku",
     prompt="테스트 구조 파악")

// Phase 2: 구현 (병렬)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="새 인증 로직 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="미들웨어 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="테스트 작성")

// Phase 3: 검증 (순차)
Task(subagent_type="deployment-validator", model="sonnet",
     prompt="typecheck/lint/build 전체 검증")

// Phase 4: 리뷰 (병렬)
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 검토")
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토")
```

**구조:**
1. Phase 1, 2, 4: 병렬 실행 (독립 작업)
2. Phase 3: 순차 실행 (의존성)
3. 모델 최적화 (haiku → sonnet → opus)

---

### 예제 4: 에러 복구 시나리오

```typescript
// 목표: 복잡한 기능 구현 (실패 가능성 높음)

const maxRetries = 3
let attempt = 0

while (attempt < maxRetries) {
  try {
    // 구현 시도
    Task(subagent_type="implementation-executor", model="sonnet",
         prompt="복잡한 인증 로직 구현")

    // 검증
    Task(subagent_type="deployment-validator", model="sonnet",
         prompt="typecheck/lint/build 검증")

    // 성공 시 탈출
    break

  } catch (error) {
    attempt++

    // 실패 기록
    Write(".claude/logs/retry.md", `
    ## Retry ${attempt}
    - Error: ${error}
    - Time: ${timestamp}
    `)

    if (attempt >= maxRetries) {
      // 에스컬레이션: opus 모델 + 전문가
      Task(subagent_type="planner", model="opus",
           prompt=`구현 실패 분석

           시도 횟수: ${attempt}
           에러 로그: @.claude/logs/retry.md

           대안 제시:
           1. 다른 접근 방법
           2. 단계별 분해
           3. 예상 블로커`)
    }
  }
}
```

</practical_examples>

---

<best_practices>

## 모범 사례

### 실행 전 체크리스트

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
| **컨텍스트 보존** | 상태 문서화 + 핸드오프 |
| **에러 처리** | 격리 + 재시도 (3회) + 서킷 브레이커 |
| **성능 목표** | 대기 시간 80% 감소, 병렬도 3-10개 |

**시작하기:**
1. 작업 분석 → 독립/의존/유사 구분
2. 패턴 선택 → 병렬/순차/배치
3. 모델 선택 → 복잡도 기반
4. 실행 → 단일 메시지 다중 Tool
5. 모니터링 → TaskList, 로그

</summary>

---

<references>

## 참고 자료

**관련 문서:**
- `.claude/instructions/parallel-agent-execution.md` - 병렬 실행 전체 가이드
- `.claude/PARALLEL_AGENTS.md` - 멀티 에이전트 조정 가이드
- `.claude/agents/*.md` - 개별 에이전트 스펙

**외부 자료:**

### Anthropic
1. [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - 컨텍스트 엔지니어링 원칙
2. [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) - 멀티 에이전트 시스템 사례
3. [Batch processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing) - 배치 처리 API

### 아키텍처 패턴
4. [Multi-Agent Design Patterns (Azure)](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns) - 에이전트 오케스트레이션 패턴
5. [Multi-Agent Systems (Google ADK)](https://google.github.io/adk-docs/agents/multi-agents/) - 병렬 에이전트 구현
6. [Multi-Agent Patterns (LangChain)](https://docs.langchain.com/oss/python/langchain/multi-agent) - 서브에이전트, 라우터 패턴
7. [Agentic AI Patterns (AWS)](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-patterns/introduction.html) - 워크플로우 패턴

### 성능 최적화
8. [Batch Query Processing (arXiv)](https://arxiv.org/html/2509.02121v1) - 배치 최적화 연구
9. [Parallel Processing with Claude](https://codesignal.com/learn/courses/exploring-workflows-with-claude-in-typescript/lessons/parallel-processing-with-claude) - 병렬 처리 실습
10. [AI Agent Performance Optimization](https://www.talktoagent.com/blog/ways-to-optimize-ai-agent-performance) - 9가지 최적화 전략

### 고급 패턴
11. [Fan-Out Fan-In Pattern](https://systemdesignschool.io/fundamentals/fan-out-fan-in) - 분산 처리 패턴
12. [Context Preservation in Multi-Agent](https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/) - 컨텍스트 보존 기법

</references>
