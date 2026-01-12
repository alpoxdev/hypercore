---
description: 계획 실행 또는 간단한 작업 수행. ultrathink + sequential thinking 2-5 + TodoWrite 필수.
allowed-tools: Read, Glob, Grep, Bash, Task, Edit, Write, TodoWrite, mcp__sequential-thinking__sequentialthinking
argument-hint: <task to execute or plan filename>
---

# Execute Command

> Command to analyze and implement immediately. Execute directly without presenting options.

**Execution Target**: $ARGUMENTS

---

<argument_validation>

## ARGUMENT Verification Required

```
No $ARGUMENTS → Ask immediately:

"What needs to be executed? Please provide details.

Examples:
- .claude/plans/*.md plan files
- Specific tasks (add feature, fix bug, refactor)
- Simple code changes"

Has $ARGUMENTS → Proceed to next step
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 계획 파일 또는 작업 내용 | - |
| 2. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 3. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore) + Read/Grep |
| 4. 최적 접근법 결정 | 가능한 방법 분석 → 최선 선택 | sequentialthinking (2-4단계) |
| 5. 즉시 구현 | TodoWrite → 단계별 구현 → 검증 | Edit/Write + TodoWrite |

</workflow>

---

<agent_usage>

## @implementation-executor Agent 활용

**언제 사용:**
- 복잡한 기능 구현 (5개 이상 파일)
- 아키텍처 변경 필요
- 백그라운드에서 독립적 구현
- 메인 에이전트가 다른 작업 병행

**호출 방법:**
```bash
@implementation-executor
# 또는 자연어
"사용자 프로필 편집 기능 구현해줘"
"실시간 알림 추가해줘"
```

**장점:**
- Sequential Thinking으로 복잡도 자동 판단 (2-5단계)
- Task(Explore)로 코드베이스 자동 탐색
- TodoWrite로 진행 상황 실시간 추적
- 옵션 제시 없이 최적 방법으로 즉시 구현
- 독립적 context에서 실행 (메인 작업 병렬 가능)

**직접 구현 vs Agent:**

| 상황 | 권장 방법 |
|------|----------|
| 1-2개 파일, 간단한 수정 | 직접 구현 (command) |
| 3-5개 파일, 보통 복잡도 | 직접 구현 또는 agent |
| 5개 이상 파일, 복잡 | @implementation-executor |
| 아키텍처 변경 | @implementation-executor |
| 메인이 다른 작업 중 | @implementation-executor |

**execute command와의 차이:**
- execute: 사용자가 직접 호출하는 command
- @implementation-executor: agent로 백그라운드 실행 가능

</agent_usage>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 복잡도 판단
- 작업 범위: 파일 수, 변경 규모
- 의존성: 다른 코드에 영향, 테스트 필요성
- 리스크: 기존 기능 영향, 롤백 가능성
- 기술적 난이도: 새로운 패턴, 복잡한 로직
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 2 | 1개 파일, 명확한 변경 | 복잡도 판단 → 즉시 구현 |
| **보통** | 3-4 | 2-3개 파일, 로직 추가 | 복잡도 판단 → 현재 상태 → 접근 방식 → 구현 |
| **복잡** | 5+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 접근 방식 → 상세 계획 → 단계별 구현 |

### 보통 복잡도 패턴 (3-4단계)

```
thought 1: 복잡도 판단 및 분석 범위 결정
thought 2: 현재 상태 분석 (코드, 아키텍처)
thought 3: 최적 접근 방식 선택 및 구현 계획
thought 4: 단계별 구현 순서 확정
```

### 복잡한 경우 패턴 (5단계)

```
thought 1: 복잡도 판단
thought 2: 현재 상태 심층 분석
thought 3: 가능한 접근 방식 탐색 및 최선 선택
thought 4: 상세 구현 계획 수립
thought 5: 단계별 실행 순서 및 검증 방법
```

### 핵심 원칙

```text
✅ 사고 과정을 출력해야 실제로 생각이 일어남
✅ 복잡도가 불확실하면 높게 책정 (3→5로 확장 가능)
✅ 각 thought에서 구체적 분석 필요 (추상적 설명 금지)
✅ 최적 접근법을 내부적으로 결정 (옵션 제시 없이)
✅ 필요 시 isRevision으로 이전 사고 수정
```

</thinking_strategy>

---

<codebase_exploration>

## Task Subagent 활용

### Subagent 선택

| subagent_type | 용도 | 예시 |
|---------------|------|------|
| **Explore** | 코드베이스 구조 파악, 관련 파일 탐색 | "현재 인증 구조 분석" |
| **general-purpose** | 복잡한 분석, 다중 시스템 연관 | "여러 모듈 간 의존성 분석" |

### Task 호출 패턴

**단일 탐색:**

```typescript
Task({
  subagent_type: 'Explore',
  description: '현재 인증 구조 분석',
  prompt: `
    현재 인증 관련 코드 구조 파악.
    - 사용 중인 라이브러리
    - 세션 관리 방식
    - 수정이 필요한 파일 목록
  `
})
```

**병렬 탐색 (복잡한 경우):**

```typescript
// 단일 메시지에 다중 Task 호출
Task({
  subagent_type: 'Explore',
  prompt: '프론트엔드 인증 구조 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '백엔드 API 인증 엔드포인트 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '데이터베이스 세션 스키마 분석'
})

// → 결과 취합 후 구현 시작
```

### 탐색 체크리스트

```text
✅ 현재 구현 방식 파악
✅ 사용 중인 라이브러리/프레임워크 버전
✅ 관련 파일 및 디렉토리 위치
✅ 의존성 및 연관 모듈
✅ 기존 제약사항 (보안, 성능, 호환성)
```

</codebase_exploration>

---

<implementation_strategy>

## 즉시 구현 전략

### TodoWrite 필수 사용

**복잡도별 TodoWrite 사용:**

| 복잡도 | TodoWrite | 이유 |
|--------|----------|------|
| **간단** | 선택적 | 1-2개 파일, 명확한 작업 |
| **보통** | 필수 | 3-5개 파일, 여러 단계 |
| **복잡** | 필수 | 다중 모듈, 단계별 추적 필수 |

**TodoWrite 패턴:**

```typescript
TodoWrite({
  todos: [
    { content: '현재 구조 분석', status: 'in_progress', activeForm: '현재 구조 분석 중' },
    { content: 'API 엔드포인트 구현', status: 'pending', activeForm: 'API 엔드포인트 구현 중' },
    { content: '프론트엔드 통합', status: 'pending', activeForm: '프론트엔드 통합 중' },
    { content: '테스트 실행', status: 'pending', activeForm: '테스트 실행 중' },
  ]
})
```

### 단계별 구현 원칙

```text
✅ 한 번에 하나씩: 한 작업 완료 → 다음 작업
✅ 즉시 완료 표시: 작업 완료 시 바로 completed
✅ 검증 후 진행: 각 단계 완료 후 동작 확인
✅ 에러 처리: 실패 시 원인 분석 → 수정 → 재시도
```

### 구현 체크리스트

```text
✅ 코드 작성 전 관련 파일 Read
✅ Edit/Write 도구로 코드 수정
✅ 각 단계 완료 후 검증 (테스트, 빌드)
✅ TodoWrite 상태 실시간 업데이트
✅ 진행 상황 간결하게 보고
```

</implementation_strategy>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 최소 2단계
✅ Task (Explore)로 코드베이스 탐색 (필요 시)
✅ 최적 접근법 내부적으로 결정
✅ TodoWrite로 구현 단계 추적 (보통 이상)
✅ 단계별 구현 및 검증
```

절대 금지:

```text
❌ ARGUMENT 없이 구현 시작
❌ Sequential Thinking 2단계 미만
❌ 코드 탐색 없이 추측으로 구현
❌ 옵션 제시 후 사용자 선택 대기 (바로 실행)
❌ TodoWrite 없이 복잡한 작업 수행
❌ 단계별 검증 없이 일괄 구현
❌ 테스트 실패 상태로 커밋
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: 계획 기반 실행

```bash
사용자: /execute session-auth

1. 입력 확인:
   .claude/plans/session-auth.md 존재 확인 → 계획 파일 읽기

2. Sequential Thinking (4단계):
   thought 1: "계획 파일 기반 실행 - 보통 복잡도, 여러 모듈 수정"
   thought 2: "계획 내용 분석: 세션 스토어 → 미들웨어 → API → 테스트"
   thought 3: "점진적 구현 전략: 각 단계별로 검증하며 진행"
   thought 4: "단계별 실행 순서: 스토어 설정 → 미들웨어 → API 수정 → 테스트"

3. TodoWrite 생성:
   - 세션 스토어 설정 (Redis)
   - 세션 미들웨어 구현
   - API 엔드포인트 수정
   - 테스트 실행 및 검증

4. 단계별 구현:
   - [in_progress] 세션 스토어 설정
     → src/lib/session.ts 작성
     → [completed]

   - [in_progress] 세션 미들웨어 구현
     → src/middleware/session.ts 작성
     → [completed]

   - [in_progress] API 엔드포인트 수정
     → src/api/auth/*.ts 수정
     → [completed]

   - [in_progress] 테스트 실행
     → npm test
     → [completed]

5. 커밋:
   git commit -m "feat: 세션 기반 인증 구현"
```

### 예시 2: 직접 실행 (간단)

```bash
사용자: /execute 로그인 버튼 색상을 파란색으로 변경

1. Sequential Thinking (2단계):
   thought 1: "단순 스타일 변경 - 간단, 1개 파일"
   thought 2: "LoginButton 컴포넌트 찾기 → 색상 변경"

2. Task 탐색:
   Glob: **/LoginButton.tsx
   → src/components/LoginButton.tsx 발견

3. 구현 (TodoWrite 생략):
   - Read: src/components/LoginButton.tsx
   - Edit: className 수정 (bg-gray-500 → bg-blue-500)
   - 시각적 확인

4. 커밋:
   git commit -m "style: 로그인 버튼 색상 변경"
```

### 예시 3: 직접 실행 (보통)

```bash
사용자: /execute 사용자 프로필 편집 기능 추가

1. Sequential Thinking (4단계):
   thought 1: "프로필 편집 - 보통 복잡도, 3-4개 파일 (컴포넌트, API, 스키마)"
   thought 2: "현재 프로필 관련 구조 파악 필요"
   thought 3: "접근 방식: 프론트엔드 폼 → Server Function → DB 업데이트"
   thought 4: "단계: 폼 컴포넌트 → 검증 스키마 → Server Function → 테스트"

2. Task 탐색:
   Task (Explore): "프로필 관련 코드 구조 분석"
   → src/routes/profile/, src/functions/user.ts 파악

3. TodoWrite 생성:
   - 프로필 편집 폼 컴포넌트
   - Zod 검증 스키마
   - Server Function (updateProfile)
   - 테스트

4. 단계별 구현:
   - [in_progress] 프로필 편집 폼 컴포넌트
     → src/routes/profile/-components/EditProfileForm.tsx 작성
     → [completed]

   - [in_progress] Zod 검증 스키마
     → src/lib/schemas/profile.ts 작성
     → [completed]

   - [in_progress] Server Function
     → src/functions/user.ts에 updateProfile 추가
     → [completed]

   - [in_progress] 테스트
     → npm test
     → [completed]

5. 커밋:
   git commit -m "feat: 사용자 프로필 편집 기능 추가"
```

### 예시 4: 직접 실행 (복잡)

```bash
사용자: /execute 실시간 알림 기능 추가

1. Sequential Thinking (5단계):
   thought 1: "실시간 알림 - 복잡, 새 기술 스택 추가 (WebSocket)"
   thought 2: "현재 통신 구조: REST API만, 실시간 통신 없음"
   thought 3: "접근 방식: WebSocket 서버 + 클라이언트 훅 + 알림 UI"
   thought 4: "WebSocket이 양방향이라 최적, Socket.io 사용"
   thought 5: "단계: Socket.io 설치 → 서버 설정 → 클라이언트 훅 → UI → 테스트"

2. Task 탐색:
   Task (Explore): "현재 서버 구조 및 클라이언트 통신 방식"
   → server.ts, API 구조 파악

3. TodoWrite 생성:
   - Socket.io 설치
   - WebSocket 서버 설정
   - useNotifications 훅
   - 알림 UI 컴포넌트
   - 통합 테스트

4. 단계별 구현:
   - [in_progress] Socket.io 설치
     → npm install socket.io socket.io-client
     → [completed]

   - [in_progress] WebSocket 서버 설정
     → src/server/socket.ts 작성
     → server.ts 통합
     → [completed]

   - [in_progress] useNotifications 훅
     → src/hooks/useNotifications.ts 작성
     → [completed]

   - [in_progress] 알림 UI 컴포넌트
     → src/components/NotificationBell.tsx 작성
     → [completed]

   - [in_progress] 통합 테스트
     → 알림 전송 → 클라이언트 수신 확인
     → [completed]

5. 커밋:
   git commit -m "feat: 실시간 알림 기능 추가 (WebSocket)"
```

</examples>
