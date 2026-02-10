---
name: execute
description: 계획 또는 작업을 Sequential Thinking으로 분석하여 즉시 구현. 옵션 제시 없이 바로 실행.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/context-optimization/phase-based-execution.md
@../../instructions/context-optimization/sub-agent-distribution.md
@../../instructions/validation/scope-completeness.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Execute Skill

> 계획 또는 작업을 Sequential Thinking으로 분석하여 즉시 구현. 옵션 제시 없이 바로 실행.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| 계획 파일 실행 | `.claude/plan/*.md` 계획을 코드로 구현 |
| 기능 추가 | 새 기능을 분석 후 즉시 구현 |
| 버그 수정 | 문제 파악 → 수정 → 검증 |
| 리팩토링 | 코드 구조 개선, 성능 최적화 |
| 간단한 수정 | 스타일 변경, 설정 업데이트 |

**핵심 특징:**
- Sequential Thinking으로 복잡도 자동 판단 (2-5단계)
- Task(Explore)로 코드베이스 자동 탐색
- TaskCreate로 진행 상황 실시간 추적
- 옵션 제시 없이 최적 방법으로 즉시 구현

</when_to_use>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "execute-team", description: "즉시 구현" })
Task(subagent_type="implementation-executor", team_name="execute-team", name="executor", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## 병렬 에이전트 실행

@../../instructions/agent-patterns/delegation-patterns.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md

### Execute 스킬 고유 패턴

- **즉시 구현**: Sequential Thinking으로 분석 후 implementation-executor에게 즉시 위임
- **독립 기능 병렬**: 여러 독립적인 기능을 각각 다른 executor에게 동시 위임
- **구현 + 문서 동시**: 코드 구현과 문서 작성을 병렬로 진행

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (2-5단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore) 병렬 + Read/Grep |
| 3. 최적 접근법 결정 | 가능한 방법 분석 → 최선 선택 (내부적으로) | sequentialthinking |
| 4. 즉시 구현 | TaskCreate → 단계별 구현 (병렬 가능) → 검증 | Task 병렬 + Edit/Write + TaskCreate |

### Agent 선택 기준

| 복잡도 | 조건 | 사용 Agent |
|--------|------|-----------|
| **극도로 복잡** | 전체 시스템 재설계, 완전 자율 | Task (deep-executor) 단일 위임 |
| **매우 복잡** | 다중 시스템, 아키텍처 변경, 불확실성 높음 | Task (implementation-executor) 병렬 위임 |
| **복잡/보통** | 명확한 범위, 3-10 파일 | 직접 처리 (Task Explore 활용) + 병렬 구현 |
| **간단** | 1-2 파일, 명확한 변경 | 직접 처리 |

### Sequential Thinking 가이드

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 2 | 1-2 파일, 명확한 변경 | 복잡도 판단 → 즉시 구현 |
| **보통** | 4 | 3-5 파일, 로직 변경 | 복잡도 판단 → 현재 상태 → 접근 방식 → 구현 |
| **복잡** | 5+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 접근 방식 → 병렬 전략 → 구현 |

</workflow>

---

<examples>

## 실전 예시

### 예시 1: 간단한 작업 (2단계)

```bash
# 사용자: 로그인 버튼 색상을 파란색으로 변경

# Sequential Thinking (2단계)
thought 1: "단순 스타일 변경 - 간단, 1개 파일"
thought 2: "LoginButton 컴포넌트 찾기 → 색상 변경"

# Task 탐색
Glob: **/LoginButton.tsx
→ src/components/LoginButton.tsx 발견

# 구현 (TaskCreate 생략)
- Read: src/components/LoginButton.tsx
- Edit: className 수정 (bg-gray-500 → bg-blue-500)
- 시각적 확인

# 커밋
git commit -m "style: 로그인 버튼 색상 변경"
```

### 예시 2: 보통 복잡도 (4단계)

```bash
# 사용자: 사용자 프로필 편집 기능 추가

# Sequential Thinking (4단계)
thought 1: "프로필 편집 - 보통 복잡도, 3-4개 파일 (컴포넌트, API, 스키마)"
thought 2: "현재 프로필 관련 구조 파악 필요"
thought 3: "접근 방식: 프론트엔드 폼 → Server Function → DB 업데이트"
thought 4: "단계: 폼 컴포넌트 → 검증 스키마 → Server Function → 테스트"

# Task 탐색
Task (Explore): "프로필 관련 코드 구조 분석"
→ src/routes/profile/, src/functions/user.ts 파악

# TaskCreate 생성
- 프로필 편집 폼 컴포넌트
- Zod 검증 스키마
- Server Function (updateProfile)
- 테스트

# 단계별 구현
[in_progress] 프로필 편집 폼 컴포넌트
→ src/routes/profile/-components/EditProfileForm.tsx 작성
→ [completed]

[in_progress] Zod 검증 스키마
→ src/lib/schemas/profile.ts 작성
→ [completed]

[in_progress] Server Function
→ src/functions/user.ts에 updateProfile 추가
→ [completed]

[in_progress] 테스트
→ npm test
→ [completed]

# 커밋
git commit -m "feat: 사용자 프로필 편집 기능 추가"
```

### 예시 3: 복잡한 작업 (5단계)

```bash
# 사용자: 실시간 알림 기능 추가

# Sequential Thinking (5단계)
thought 1: "실시간 알림 - 복잡, 새 기술 스택 추가 (WebSocket)"
thought 2: "현재 통신 구조: REST API만, 실시간 통신 없음"
thought 3: "접근 방식: WebSocket 서버 + 클라이언트 훅 + 알림 UI"
thought 4: "WebSocket이 양방향이라 최적, Socket.io 사용"
thought 5: "단계: Socket.io 설치 → 서버 설정 → 클라이언트 훅 → UI → 테스트"

# Task 탐색
Task (Explore): "현재 서버 구조 및 클라이언트 통신 방식"
→ server.ts, API 구조 파악

# TaskCreate 생성
- Socket.io 설치
- WebSocket 서버 설정
- useNotifications 훅
- 알림 UI 컴포넌트
- 통합 테스트

# 단계별 구현
[in_progress] Socket.io 설치
→ npm install socket.io socket.io-client
→ [completed]

[in_progress] WebSocket 서버 설정
→ src/server/socket.ts 작성
→ server.ts 통합
→ [completed]

[in_progress] useNotifications 훅
→ src/hooks/useNotifications.ts 작성
→ [completed]

[in_progress] 알림 UI 컴포넌트
→ src/components/NotificationBell.tsx 작성
→ [completed]

[in_progress] 통합 테스트
→ 알림 전송 → 클라이언트 수신 확인
→ [completed]

# 커밋
git commit -m "feat: 실시간 알림 기능 추가 (WebSocket)"
```

### 예시 4: 병렬 Agent 실행 (프론트엔드 + 백엔드)

```bash
# 사용자: 사용자 프로필 기능 전체 구현

# Sequential Thinking (5단계)
thought 1: "프로필 기능 - 복잡, 프론트엔드 + 백엔드 + 문서"
thought 2: "현재 프로필 관련 구조 없음 → 새로 구현"
thought 3: "접근 방식: 프론트엔드 (UI + 폼) + 백엔드 (API + DB)"
thought 4: "병렬 실행 가능: 프론트엔드와 백엔드 독립적"
thought 5: "3개 에이전트 병렬: UI, API, 문서"

# Task 탐색
Task (Explore): "현재 User 관련 구조 및 패턴 분석"
→ src/routes/, src/functions/user.ts 파악

# 병렬 구현 (3개 에이전트)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: '프론트엔드 구현',
  prompt: `
    프로필 편집 UI 구현:
    - src/routes/profile/-components/EditProfileForm.tsx
    - Zod 검증 스키마
    - TanStack Query 훅
  `
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: '백엔드 구현',
  prompt: `
    프로필 업데이트 API 구현:
    - src/functions/user.ts (updateProfile)
    - Prisma 쿼리
    - 인증 미들웨어
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'API 문서 작성',
  prompt: 'updateProfile API 문서 및 컴포넌트 사용 가이드'
})

# 모든 에이전트 완료 후 통합 검증
→ 프론트엔드 + 백엔드 통합 테스트
→ 커밋: "feat: 사용자 프로필 편집 기능 추가"
```

### 예시 5: 대규모 리팩토링 (모듈별 병렬)

```bash
# 사용자: User, Payment, Notification 모듈 리팩토링

# Sequential Thinking (5단계)
thought 1: "3개 모듈 리팩토링 - 매우 복잡"
thought 2: "각 모듈 독립적 → 병렬 실행 가능"
thought 3: "복잡도: User (높음), Payment (높음), Notification (보통)"
thought 4: "모델 선택: User/Payment (sonnet), Notification (haiku)"
thought 5: "병렬 실행 후 통합 검증"

# 병렬 리팩토링 (3개 에이전트)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: 'User 모듈 리팩토링',
  prompt: `
    User 모듈 개선:
    - 복잡도 감소 (함수 분리)
    - 타입 안정성 향상
    - 테스트 커버리지 증대
  `
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: 'Payment 모듈 리팩토링',
  prompt: `
    Payment 모듈 개선:
    - 트랜잭션 안정성
    - 에러 핸들링 개선
    - 로깅 강화
  `
})

Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  description: 'Notification 모듈 리팩토링',
  prompt: `
    Notification 모듈 개선:
    - 템플릿 구조화
    - 다국어 지원
    - 전송 실패 재시도
  `
})

# 모든 에이전트 완료 후 통합 검증
→ 전체 테스트 실행
→ 커밋: "refactor: User/Payment/Notification 모듈 개선"
```

</examples>

---

<validation>

## 실행 전 체크리스트

```text
✅ Sequential Thinking 최소 2단계
✅ Task (Explore)로 코드베이스 탐색 (필요 시)
✅ 최적 접근법 내부적으로 결정
✅ TaskCreate로 구현 단계 추적 (보통 이상)
✅ 단계별 구현 및 검증
✅ 병렬 실행 가능 시 Agent 위임
✅ 적절한 모델 선택 (haiku/sonnet/opus)
✅ 독립적인 작업은 병렬 실행 (3-5개 권장)
✅ 병렬 실행 시 독립성 확인
✅ 결과 통합 후 검증 수행
```

## 금지 사항

```text
❌ 옵션 제시 후 사용자 선택 대기 (바로 실행)
❌ TaskCreate 없이 복잡한 작업 수행
❌ 단계별 검증 없이 일괄 구현
❌ 순차 의존성이 있는 작업을 병렬 실행
❌ 같은 파일을 여러 에이전트가 동시 수정
❌ 병렬 실행 수 5개 초과
❌ 결과 통합 없이 개별 결과만 사용
```

## 병렬 실행 체크리스트

구현 전 확인:

```text
✅ 병렬 실행 가능성
   [ ] 독립적인 모듈/컴포넌트 구현?
   [ ] 프론트엔드 + 백엔드 분리 가능?
   [ ] 기능 + 테스트 + 문서 동시 작업?

✅ 의존성 확인
   [ ] 각 작업이 독립적으로 완료 가능?
   [ ] 같은 파일을 여러 에이전트가 수정하지 않는가?
   [ ] 순차 실행이 필요한 단계는 없는가?

✅ 모델 선택
   [ ] 복잡도 LOW → haiku
   [ ] 복잡도 MEDIUM → sonnet
   [ ] 복잡도 HIGH → opus

✅ 병렬 실행 수
   [ ] 3-5개 권장 (초과 시 복잡도 증가)
   [ ] 각 에이전트에 명확한 범위 전달
   [ ] 결과 통합 계획 수립
```

</validation>
