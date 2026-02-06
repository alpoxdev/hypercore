# Phase-Based Execution

**목적**: 대규모 작업을 Phase로 분리하여 Context Window Exceeded 방지

## 문제 인식

**Usage Report 분석 결과:**

| 문제 | 발생 빈도 | 영향 |
|------|----------|------|
| Context Window Exceeded | 3건 | 작업 실패 |
| Multi-phase 리팩토링 실패 | 높음 | Phase 3-4 진입 전 중단 |
| 병렬 에이전트 오케스트레이션 실패 | 높음 | 컨텍스트 폭발 |

**핵심 원인**: 모든 작업을 단일 세션에서 수행하려는 시도

## Phase 분리 기준

다음 중 **하나라도** 해당하면 Phase 분리 필수:

| 조건 | 임계값 | 조치 |
|------|--------|------|
| **파일 변경 개수** | 10개 이상 | 2-3 Phase로 분할 |
| **예상 컨텍스트** | 50% 초과 | Phase 분리 + 에이전트 위임 |
| **독립 작업 그룹** | 2개 이상 | 별도 Phase 실행 |
| **세션 길이** | 30분 이상 | 체크포인트 설정 |

### 체크리스트

Phase 분리 여부 결정:

- [ ] 10개 이상 파일을 수정하는가?
- [ ] 컨텍스트가 50% 이상 증가할 것 같은가?
- [ ] 서로 독립적인 작업 그룹이 2개 이상인가?
- [ ] 30분 이상 걸릴 것 같은가?

**하나라도 체크되면 Phase 분리 진행**

## Phase 설계 원칙

### 원칙 1: 독립적 완료 가능성

**각 Phase는 독립적으로 완료 및 검증 가능해야 함**

```markdown
✅ Phase 1: 스키마 설계 → 검증 (Prisma validate) → 커밋
✅ Phase 2: API 구현 → 검증 (/pre-deploy) → 커밋
✅ Phase 3: UI 구현 → 검증 (build) → 커밋

❌ Phase 1: 스키마 + API 일부 → 검증 불가능
```

### 원칙 2: 의존성 최소화

**Phase 간 의존성을 최소화하고 명확히 문서화**

```markdown
✅ Phase 1 → Phase 2 의존성: schema.prisma 완성 필요
✅ Phase 2 → Phase 3 의존성: Server Functions 완성 필요

❌ Phase 1과 Phase 3가 서로 의존 (순환 의존성)
```

### 원칙 3: 체크포인트 설정

**각 Phase 끝에 반드시 체크포인트 실행**

```typescript
// Phase N 완료 체크포인트
1. /pre-deploy 실행 (typecheck, lint, build)
2. TaskList() 확인 (pending = 0)
3. git commit (변경사항 저장)
4. 상태 문서 업데이트 (PROCESS.md, VERIFICATION.md)
```

### 원칙 4: 상태 문서화

**다음 세션에서 이어서 진행할 수 있도록 상태 저장**

```markdown
📁 .claude/plan/large-refactor/
├── phase-1-complete.md   # Phase 1 완료 요약
├── phase-2-plan.md       # Phase 2 작업 계획
└── context-summary.md    # 전체 컨텍스트 압축 요약
```

## Phase 간 상태 전달

### 방법 1: TaskCreate/TaskUpdate

**진행 상황을 Task로 추적**

```typescript
// Phase 1 시작
TaskCreate({
  subject: "Phase 1: 스키마 설계",
  description: "User, Post, Comment 모델 정의"
})

// Phase 1 완료
TaskUpdate({
  id: task_id,
  status: "completed",
  result: "3개 모델 완료. schema.prisma 커밋됨"
})

// Phase 2 시작
TaskCreate({
  subject: "Phase 2: API 구현",
  description: "Phase 1의 스키마 기반으로 Server Functions 구현"
})
```

### 방법 2: 파일 기반 상태 저장

**요약 문서로 다음 Phase 컨텍스트 제공**

```markdown
<!-- .claude/plan/refactor/phase-1-summary.md -->
# Phase 1 완료 요약

## 구현 내용
- User, Post, Comment 스키마 정의 완료
- 관계: User 1:N Post, Post 1:N Comment

## 변경 파일
- prisma/schema/user.prisma
- prisma/schema/post.prisma
- prisma/schema/comment.prisma

## 다음 Phase 입력
- schema.prisma 경로: prisma/schema/
- 생성할 API: CRUD for User, Post, Comment
```

### 방법 3: 컨텍스트 압축 요약

**장황한 탐색 결과를 압축된 표로 변환**

```markdown
<!-- 장황한 탐색 결과 (수백 줄) → 압축 요약 -->

## 인증 관련 파일 맵

| 카테고리 | 파일 | 역할 |
|---------|------|------|
| 미들웨어 | src/middleware/auth.ts | 인증 체크 |
| Server Function | src/functions/auth.ts | login, signup, logout |
| 라우트 | src/routes/login/index.tsx | 로그인 UI |
| 라우트 | src/routes/signup/index.tsx | 회원가입 UI |
| 스키마 | prisma/schema/user.prisma | User 모델 |
| 타입 | src/types/auth.ts | AuthSession, AuthUser |

**총 6개 파일 → Phase 2에서 수정 대상**
```

## Sub-Agent 활용

### 패턴 1: Phase 내 병렬 분산

**각 Phase 내에서도 Task 에이전트로 작업 분산**

```typescript
// Phase 2: API 구현 (병렬)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User CRUD Server Functions 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Post CRUD Server Functions 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Comment CRUD Server Functions 구현")
```

**장점**: 컨텍스트를 3개 에이전트로 분산 → Main Agent 컨텍스트 절약

### 패턴 2: 에이전트 결과 압축

**에이전트 응답을 즉시 요약하여 Main Agent 컨텍스트 유지**

```typescript
// ❌ 금지: 에이전트 전체 응답 보관
const result1 = await Task(...) // 5000 토큰
const result2 = await Task(...) // 5000 토큰
const result3 = await Task(...) // 5000 토큰
// → Main Agent 컨텍스트 15000 토큰 증가

// ✅ 권장: 즉시 압축
const result1 = await Task(...)
// → 요약: "User CRUD 완료. 4개 함수 생성. ✅ typecheck 통과"

const result2 = await Task(...)
// → 요약: "Post CRUD 완료. 4개 함수 생성. ✅ typecheck 통과"

// → Main Agent 컨텍스트 200 토큰만 증가
```

## Phase 실행 템플릿

### 소규모 리팩토링 (10-20 파일)

```markdown
Phase 1: 분석 및 계획 (30분)
- 파일 탐색 및 의존성 맵 생성
- 요약 문서 작성 (context-summary.md)
- 작업 목록 생성 (TaskCreate)

Phase 2: 구현 Part 1 (1시간)
- 핵심 파일 수정 (5-10개)
- 검증 (typecheck, lint)
- 커밋 (git-operator)

Phase 3: 구현 Part 2 (1시간)
- 나머지 파일 수정 (5-10개)
- 검증 (typecheck, lint)
- 커밋 (git-operator)

Phase 4: 통합 테스트 (30분)
- 전체 빌드 테스트
- Planner 검증
- 완료 문서화
```

### 대규모 리팩토링 (20+ 파일)

```markdown
Phase 1: 탐색 및 요약 (1시간)
- 전체 파일 목록 생성 (Glob)
- 카테고리별 분류 (표 형식)
- 압축 요약 문서 생성
- Phase 2-4 계획 수립

Phase 2: 핵심 모듈 (2시간)
- 가장 중요한 10개 파일 수정
- Sub-agent 병렬 실행 (3-5개)
- 검증 + 커밋
- Phase 3 입력 문서 생성

Phase 3: 주변 모듈 (2시간)
- 나머지 10개 파일 수정
- Sub-agent 병렬 실행
- 검증 + 커밋
- Phase 4 입력 문서 생성

Phase 4: 통합 및 검증 (1시간)
- 전체 빌드 테스트
- Planner 검증
- 문서 업데이트
- 완료 선언
```

## Phase 전환 체크리스트

Phase N 완료 전 반드시 확인:

```markdown
- [ ] 현재 Phase 작업 모두 완료?
  - [ ] TASKS.md 체크박스 모두 체크?
  - [ ] TaskList() 확인 (pending = 0)?

- [ ] 검증 통과?
  - [ ] typecheck: ✅
  - [ ] lint: ✅
  - [ ] build: ✅ (최종 Phase만)

- [ ] 상태 문서 업데이트?
  - [ ] PROCESS.md: Phase N 완료 기록
  - [ ] VERIFICATION.md: 검증 결과 기록
  - [ ] phase-N-summary.md: 요약 생성

- [ ] 변경사항 커밋?
  - [ ] git-operator로 커밋 완료
  - [ ] 커밋 메시지: "feat(phase-N): ..."
```

**모든 항목 체크 후 다음 Phase 시작**

## 실전 예시

### 예시 1: Context Window Exceeded 회피

```markdown
【초기 계획】
- 모든 19개 SKILL.md 파일을 한 번에 수정
- 예상 컨텍스트: 80% (위험)

【Phase 분리 후】
Phase 1: 탐색 및 계획 (10분)
- Glob → 19개 파일 발견
- 카테고리 분류: core (5개), utility (14개)
- 요약 문서 생성

Phase 2: Core 스킬 (30분)
- 5개 core 스킬 수정 (병렬 에이전트)
- 검증 + 커밋
- 예상 컨텍스트: 30%

Phase 3: Utility 스킬 (30분)
- 14개 utility 스킬 수정 (병렬 에이전트)
- 검증 + 커밋
- 예상 컨텍스트: 30%

【결과】
✅ Context Window Exceeded 회피
✅ 각 Phase 독립적으로 검증 및 커밋
✅ 중간에 중단되어도 재개 가능
```

### 예시 2: Multi-Phase 리팩토링 성공

```markdown
【문제 상황】
- 인증 시스템 전면 리팩토링
- 15개 파일 영향
- Phase 3-4에서 컨텍스트 폭발 예상

【Phase 설계】
Phase 1: 분석 (30분)
- 파일 의존성 맵 생성
- 리팩토링 전략 수립
- 압축 요약 문서 작성 (3페이지 → 1페이지)

Phase 2: Schema + Middleware (1시간)
- Prisma 스키마 수정
- auth 미들웨어 리팩토링
- typecheck 검증 + 커밋
- Phase 3 입력 문서 생성

Phase 3: Server Functions (1시간)
- login, signup, logout 함수 재구현
- inputValidator + middleware 적용
- /pre-deploy 검증 + 커밋
- Phase 4 입력 문서 생성

Phase 4: UI + 통합 (1시간)
- 로그인/회원가입 UI 수정
- TanStack Query 연동
- 전체 빌드 테스트
- Planner 검증 + 완료

【결과】
✅ 모든 Phase 성공적 완료
✅ 컨텍스트 사용률: 각 Phase 40% 미만
✅ 각 Phase 체크포인트로 안전성 확보
```

## 안티패턴

### ❌ 금지 1: Phase 분리 없이 진행

```markdown
// 20개 파일 수정 → 한 번에 진행
→ Context Window Exceeded
→ 작업 실패 + 재시도 필요
```

### ❌ 금지 2: Phase 간 의존성 복잡화

```markdown
Phase 1: A, B 파일 수정
Phase 2: C, D 파일 수정 (A, B 의존)
Phase 3: A 파일 재수정 (C, D 의존) ← 순환 의존성!
```

### ❌ 금지 3: 체크포인트 생략

```markdown
Phase 1 완료 → 커밋 없이 Phase 2 시작
→ Phase 2 실패 시 Phase 1부터 재작업 필요
```

### ❌ 금지 4: 상태 문서화 누락

```markdown
Phase 1 완료 → 요약 문서 없음
→ Phase 2 시작 시 Phase 1 전체 재탐색 필요
→ 컨텍스트 낭비
```

## 베스트 프랙티스

| 원칙 | 구현 |
|------|------|
| **조기 분리** | 작업 시작 전 Phase 분리 여부 판단 |
| **독립성 우선** | 각 Phase는 독립적으로 완료 가능하게 설계 |
| **체크포인트 필수** | Phase 끝마다 검증 + 커밋 |
| **상태 압축** | 장황한 내용은 표/목록으로 압축 |
| **에이전트 활용** | Phase 내에서도 Sub-agent로 병렬 처리 |
| **재개 가능성** | 다음 세션에서 이어서 실행 가능하도록 문서화 |

## 체크리스트

작업 시작 전:

- [ ] Phase 분리 기준 확인 (10개+ 파일, 50%+ 컨텍스트)
- [ ] Phase 설계 (독립성, 의존성, 체크포인트)
- [ ] 상태 문서 폴더 생성 (.claude/plan/)

각 Phase 시작 시:

- [ ] 이전 Phase 요약 문서 읽기
- [ ] 현재 Phase 작업 목록 TaskCreate
- [ ] Sub-agent 활용 계획

각 Phase 완료 시:

- [ ] Phase 전환 체크리스트 실행
- [ ] 요약 문서 생성 (다음 Phase 입력)
- [ ] 검증 + 커밋
- [ ] PROCESS.md 업데이트

**Phase 분리로 Context Window Exceeded 방지 + 작업 성공률 향상**
