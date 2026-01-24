---
name: execute
description: 계획 실행 또는 간단한 작업을 즉시 구현하는 스킬. 옵션 제시 없이 최적 방법으로 바로 실행.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Execute Skill

> 계획 실행 또는 간단한 작업을 즉시 구현하는 스킬. 옵션 제시 없이 최적 방법으로 바로 실행.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| 계획 파일 실행 | `.claude/plans/*.md` 계획을 코드로 구현 |
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

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (2-5단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore) + Read/Grep |
| 3. 최적 접근법 결정 | 가능한 방법 분석 → 최선 선택 | sequentialthinking |
| 4. 즉시 구현 | TodoWrite → 단계별 구현 → 검증 | Edit/Write + TodoWrite |

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

### 예시 4: 병렬 Agent 실행

```typescript
// ✅ 독립적인 기능을 병렬로 구현
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User Profile UI 구현 (프로필 편집 폼, 프로필 카드)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User API 구현 (GET /users/:id, PATCH /users/:id)'
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: 'User API 문서 및 컴포넌트 가이드 작성'
})

// → 모든 작업 완료 후 통합 검증
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
```

## 스킬별 금지 사항

```text
❌ 옵션 제시 후 사용자 선택 대기 (바로 실행)
❌ TodoWrite 없이 복잡한 작업 수행
❌ 단계별 검증 없이 일괄 구현
```

</validation>
