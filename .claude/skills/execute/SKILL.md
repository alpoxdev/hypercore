---
name: execute
description: 계획 또는 작업을 Sequential Thinking으로 분석하여 즉시 구현. 옵션 제시 없이 바로 실행.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
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
- TodoWrite로 진행 상황 실시간 추적
- 옵션 제시 없이 최적 방법으로 즉시 구현

</when_to_use>

---

<parallel_agent_execution>

## 병렬 Agent 실행

### Recommended Agents

| Agent | Model | 용도 | 복잡도 |
|-------|-------|------|--------|
| **@implementation-executor** | sonnet | 즉시 구현, 독립 모듈 개발 | MEDIUM-HIGH |
| **@explore** | haiku/sonnet | 코드베이스 탐색, 구조 파악 | LOW-MEDIUM |
| **@architect** | sonnet/opus | 아키텍처 분석, 설계 검토 (READ-ONLY) | MEDIUM-HIGH |
| **@analyst** | sonnet | 요구사항 분석, 기술 조사, 가정 검증 | MEDIUM |
| **@document-writer** | haiku | 문서 작성 (README, API 문서) | LOW-MEDIUM |

---

### Parallel Execution Patterns

### Read 도구 병렬화

**프로젝트 분석 시 파일 병렬 읽기:**

```typescript
// ❌ 순차 읽기 (느림)
Read({ file_path: "src/file1.ts" })
// 대기...
Read({ file_path: "src/file2.ts" })

// ✅ 병렬 읽기 (빠름)
Read({ file_path: "src/file1.ts" })
Read({ file_path: "src/file2.ts" })
Read({ file_path: "src/file3.ts" })
Read({ file_path: "docs/api.md" })
```

**복잡한 탐색은 explore 에이전트 활용:**

```typescript
// 여러 영역 동시 탐색
Task(subagent_type="explore", model="haiku",
     prompt="영역 1 파일 구조 및 패턴 분석")
Task(subagent_type="explore", model="haiku",
     prompt="영역 2 의존성 및 관계 분석")
```

---

**1. 탐색 + 구현 병렬**

복잡한 시스템에서 여러 영역을 동시에 구현할 때 사용:

```typescript
// 프론트엔드 + 백엔드 동시 구현
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '프론트엔드 프로필 편집 UI 구현 (폼, 검증, 에러 처리)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '백엔드 프로필 업데이트 API 구현 (Server Function, Prisma)'
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: 'API 문서 및 컴포넌트 가이드 작성'
})
```

**2. 독립 모듈 병렬 구현**

독립적인 모듈/컴포넌트를 각각 구현할 때:

```typescript
// 여러 컴포넌트 동시 구현
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User 프로필 카드 컴포넌트 구현'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User 설정 모달 컴포넌트 구현'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User 통계 대시보드 컴포넌트 구현'
})
```

**3. 기능 + 테스트 + 문서 병렬**

기능 구현과 테스트, 문서화를 동시에 처리:

```typescript
// 기능, 테스트, 문서 동시 작업
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '실시간 알림 기능 구현 (WebSocket 서버 + 클라이언트 훅)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: '알림 기능 테스트 작성 (unit + integration)'
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: '알림 API 문서 및 사용 가이드 작성'
})
```

**4. 리팩토링 병렬화**

독립적인 모듈을 각각 리팩토링:

```typescript
// 여러 모듈 동시 리팩토링
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User 모듈 리팩토링 (타입 안정성, 복잡도 감소)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Payment 모듈 리팩토링 (에러 핸들링 개선)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'haiku',
  prompt: 'Notification 모듈 리팩토링 (템플릿 구조화)'
})
```

**5. 탐색 + 분석 병렬**

코드베이스를 여러 관점에서 동시 분석:

```typescript
// 여러 영역 동시 탐색 및 분석
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '인증 관련 파일 구조 및 패턴 분석'
})

Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '현재 인증 아키텍처 평가 및 개선점 도출'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: '인증 보안 취약점 분석 및 완화 방안'
})
```

---

### Model Routing

| 복잡도 | 조건 | 권장 Model | Agent | 예시 |
|--------|------|-----------|-------|------|
| **LOW** | 단순 구현, 파일 1-2개 | haiku | implementation-executor | 스타일 변경, 간단한 컴포넌트 |
| **MEDIUM** | 일반 구현, 파일 3-5개 | sonnet | implementation-executor | 기능 추가, 리팩토링 |
| **HIGH** | 복잡한 구현, 아키텍처 변경 | opus | implementation-executor | 시스템 재설계, 대규모 변경 |

**Model 선택 가이드:**

```text
✅ haiku:
   - 간단한 구현, 1-2 파일 수정
   - 스타일 변경, 설정 업데이트
   - 병렬 실행 시 비용 최적화

✅ sonnet:
   - 일반 기능 구현, 3-5 파일
   - 리팩토링, 버그 수정
   - 균형잡힌 품질/비용

✅ opus:
   - 복잡한 기능, 아키텍처 변경
   - 대규모 리팩토링
   - 최고 품질 필요 시
```

**Agent별 모델 추천:**

| Agent | 기본 모델 | 복잡한 경우 | 이유 |
|-------|----------|------------|------|
| **implementation-executor** | sonnet | opus | 일반 구현은 sonnet, 복잡한 경우 opus |
| **explore** | haiku | sonnet | 탐색은 빠르게, 복잡한 분석은 sonnet |
| **analyst** | sonnet | opus | 일반 조사는 sonnet, 전략적 결정은 opus |
| **architect** | sonnet | opus | 일반 분석은 sonnet, 설계는 opus |
| **document-writer** | haiku | sonnet | 문서는 haiku, 복잡한 기술 문서는 sonnet |

---

### Practical Examples

**예시 1: 프로필 기능 구현 (탐색 + 구현 병렬)**

```typescript
// 1단계: 현재 상태 탐색 (병렬)
Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '프로필 UI 분석',
  prompt: '프로필 관련 컴포넌트, 라우트 분석'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '프로필 API 분석',
  prompt: 'User 관련 Server Function, DB 스키마 분석'
})

// 2단계: 기능 구현 (병렬)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: '프론트엔드 구현',
  prompt: `
    프로필 편집 기능 구현:
    - EditProfileForm 컴포넌트
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
    - updateProfile Server Function
    - Prisma 쿼리
    - 미들웨어 (인증)
  `
})
```

**예시 2: 실시간 기능 구현 (기능 + 테스트 + 문서 병렬)**

```typescript
// 기능, 테스트, 문서 동시 작업
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: '실시간 알림 구현',
  prompt: `
    실시간 알림 기능:
    - Socket.io 서버 설정
    - useNotifications 훅
    - NotificationBell 컴포넌트
  `
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  description: '테스트 작성',
  prompt: `
    알림 기능 테스트:
    - WebSocket 연결 테스트
    - 알림 수신 테스트
    - UI 통합 테스트
  `
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'API 문서 작성',
  prompt: `
    알림 API 문서:
    - WebSocket 이벤트 목록
    - 클라이언트 사용 예시
    - 에러 처리 가이드
  `
})
```

**예시 3: 대규모 리팩토링 (모듈별 병렬)**

```typescript
// 여러 모듈 동시 리팩토링
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
```

---

### 병렬 실행 시 고려사항

```text
✅ DO:
   - 독립적인 작업만 병렬 실행 (의존성 없는 경우)
   - 결과 통합 후 검증 수행
   - 모델 선택 시 복잡도 고려 (haiku/sonnet/opus)
   - 병렬 실행 수는 3-5개 권장 (너무 많으면 복잡)
   - 각 에이전트에게 명확한 범위 전달

❌ DON'T:
   - 순차 의존성이 있는 작업 병렬화 금지
   - 결과 통합 없이 개별 결과만 사용
   - 모든 작업에 opus 사용 (비용/시간 낭비)
   - 병렬 실행 수 너무 많음 (5개 초과)
   - 같은 파일을 여러 에이전트가 동시 수정
```

---

### 병렬 에이전트 체크리스트

구현 전 확인:

```text
✅ 탐색 단계
   [ ] 여러 영역 동시 탐색 가능? → explore (haiku) 병렬 실행
   [ ] 요구사항 불명확? → analyst (sonnet) 병렬 분석

✅ 구현 단계
   [ ] 독립 모듈 구현 가능? → implementation-executor (sonnet) 병렬
   [ ] 프론트엔드 + 백엔드? → 각각 병렬 구현
   [ ] 기능 + 테스트 + 문서? → 동시 작업

✅ 리팩토링 단계
   [ ] 여러 모듈 리팩토링? → implementation-executor 병렬
   [ ] 독립적인 개선 작업? → 병렬 실행

✅ 모델 선택
   [ ] 복잡도 LOW → haiku
   [ ] 복잡도 MEDIUM → sonnet
   [ ] 복잡도 HIGH → opus

✅ 병렬 실행 수
   [ ] 3-5개 권장
   [ ] 독립성 확인
   [ ] 결과 통합 계획
```

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (2-5단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore) 병렬 + Read/Grep |
| 3. 최적 접근법 결정 | 가능한 방법 분석 → 최선 선택 (내부적으로) | sequentialthinking |
| 4. 즉시 구현 | TodoWrite → 단계별 구현 (병렬 가능) → 검증 | Task 병렬 + Edit/Write + TodoWrite |

### Agent 선택 기준

| 복잡도 | 조건 | 사용 Agent |
|--------|------|-----------|
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

# 구현 (TodoWrite 생략)
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

# TodoWrite 생성
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

# TodoWrite 생성
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
✅ TodoWrite로 구현 단계 추적 (보통 이상)
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
❌ TodoWrite 없이 복잡한 작업 수행
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
