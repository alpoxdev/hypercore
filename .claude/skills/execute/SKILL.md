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

<parallel_agent_execution>

## 병렬 Agent 실행

**목적:** 독립적인 작업을 여러 Agent가 동시에 실행하여 생산성 향상.

---

### 병렬화 전략

| 전략 | 설명 | 예시 |
|------|------|------|
| **작업 단계별 병렬화** | 계획-구현-테스트를 동시 진행 | 탐색 + 구현 + 문서화 병렬 실행 |
| **다중 파일 동시 구현** | 독립적인 모듈을 병렬로 구현 | API + UI + 스키마 동시 작업 |
| **검증 병렬화** | 여러 검증을 동시 실행 | 보안 + 성능 + 접근성 리뷰 병렬 |
| **Fan-Out Fan-In** | 작업 분산 → 결과 수집 | 3개 기능 병렬 구현 → 통합 검증 |

**병렬화 조건:**

```text
✅ 작업이 독립적 (의존성 없음)
✅ 컨텍스트 분리 가능
✅ 다른 파일/모듈 작업
✅ 결과가 독립적으로 활용 가능

❌ 순차 의존성 있음 (A → B → C)
❌ 같은 파일 동시 수정
❌ 결과가 다음 작업 입력
```

---

### 권장 Agents (티어별)

| 도메인 | Agent | 권장 모델 | 용도 |
|--------|-------|----------|------|
| **계획/분석** | planner | opus | 아키텍처 설계, 검증 |
| **요구사항** | analyst | sonnet | 요구사항 분석, 가정 검증 |
| **실행** | implementation-executor | sonnet | 기능 구현, 버그 수정 |
| **탐색** | explore | haiku | 코드베이스 탐색 |
| **프론트엔드** | designer | sonnet/opus | UI/UX 구현 |
| **문서** | document-writer | haiku/sonnet | 기술 문서 작성 |
| **검증** | code-reviewer | opus | 품질 검토 |
| **린트** | lint-fixer | sonnet | tsc/eslint 오류 수정 |
| **Git** | git-operator | haiku | Git 커밋/푸시 |

---

### Model Routing (Smart 선택)

| 복잡도 | Model | 작업 예시 | 선택 기준 |
|--------|-------|----------|----------|
| **LOW** | haiku | 파일 읽기, 정의 조회, 설정 변경, 문서화 | 단일 파일, 명확한 작업 |
| **MEDIUM** | sonnet | 기능 추가, 컴포넌트 구현, 버그 수정 | 2-3개 파일, 로직 추가 |
| **HIGH** | opus | 아키텍처 설계, 복잡한 디버깅, 보안 분석 | 다중 모듈, 설계 필요 |

**모델 선택 전략:**

```typescript
// 간단 → haiku (빠르고 저렴)
Task({ subagent_type: 'explore', model: 'haiku', ... })
Task({ subagent_type: 'document-writer', model: 'haiku', ... })

// 일반 → sonnet (균형)
Task({ subagent_type: 'implementation-executor', model: 'sonnet', ... })
Task({ subagent_type: 'designer', model: 'sonnet', ... })

// 복잡 → opus (고품질)
Task({ subagent_type: 'planner', model: 'opus', ... })
Task({ subagent_type: 'code-reviewer', model: 'opus', ... })
```

---

### 백그라운드 실행

| 작업 유형 | 실행 모드 | 이유 |
|----------|----------|------|
| 패키지 설치 (`npm install`, `pip install`) | Background | 장기 실행 |
| 빌드 (`npm run build`, `tsc`) | Background | 장기 실행 |
| 테스트 (`npm test`, `pytest`) | Background | 장기 실행 |
| 파일 읽기/쓰기 | Foreground | 즉시 필요 |
| 간단한 명령 (`git status`, `ls`) | Foreground | 빠른 실행 |

**10개 이상 동시 작업 시:** `run_in_background=true` 설정

---

### Agent Delegation (적극 활용)

**위임 조건:**

| 조건 | 예시 | 위임할 Agent |
|------|------|-------------|
| 요구사항 불명확 | 가정 검증, 엣지 케이스 | analyst |
| 독립적인 작업 | 코드 분석 + 리뷰 동시 | implementation-executor + code-reviewer |
| 새 컨텍스트 필요 | 대규모 코드베이스 탐색 | explore |
| 전문 지식 필요 | 린트/타입 오류 수정 | lint-fixer |
| 장기 실행 작업 | 배포 전 전체 검증 | deployment-validator |
| 병렬 처리 가능 | 여러 파일 동시 수정 | implementation-executor (여러 개) |

**위임 원칙:**

```text
✅ 독립적인 작업 → 즉시 위임 (병렬 실행)
✅ 컨텍스트 분리 필요 → 위임
✅ 전문성 필요 → 도메인 Agent
✅ 10분 이상 예상 → 백그라운드 + Agent

❌ 간단한 파일 읽기 → 직접 실행
❌ 순차 의존성 → 직접 실행 후 다음 Agent
❌ 동일 파일 수정 → 순차 실행
```

---

### 병렬 실행 패턴

**패턴 1: 독립적 기능 병렬 구현**

```typescript
// ✅ 독립적인 API 엔드포인트를 각각 구현
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User API 엔드포인트 구현 (GET /users, POST /users, PATCH /users/:id)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Product API 엔드포인트 구현 (GET /products, POST /products, DELETE /products/:id)'
})
```

**패턴 2: 구현 + 문서화 병렬**

```typescript
// ✅ 구현과 문서화 동시 진행
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Payment 통합 (Stripe API 연동, 결제 처리 로직)'
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: 'Payment API 문서 작성 (엔드포인트, 요청/응답 스키마, 에러 코드)'
})
```

**패턴 3: UI + API + 문서 병렬**

```typescript
// ✅ 전체 기능을 역할별로 분산
Task({
  subagent_type: 'designer',
  model: 'sonnet',
  prompt: 'User Profile UI 구현 (프로필 편집 폼, 프로필 카드, 반응형 디자인)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'User API 구현 (GET /users/:id, PATCH /users/:id, 이미지 업로드)'
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: 'User API 문서 및 컴포넌트 사용 가이드 작성'
})
```

**패턴 4: 탐색 + 구현 분리**

```typescript
// 코드베이스 탐색과 구현을 병렬로
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '기존 인증 구조 분석 (middleware, session, auth)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'OAuth 로그인 구현 (Google, GitHub 연동)'
})
```

**패턴 5: 다중 검증 병렬**

```typescript
// 여러 관점에서 동시 검토
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '보안 검토: SQL Injection, XSS, CSRF 취약점'
})

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '성능 검토: N+1 쿼리, 불필요한 리렌더'
})

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '접근성 검토: ARIA, 키보드 네비게이션, 색상 대비'
})
```

**패턴 6: 구현 후 검증**

```typescript
// ✅ 구현 완료 후 코드 리뷰
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Authentication 리팩토링 (Better Auth 마이그레이션)'
})

// 구현 완료 대기 후
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '보안 점검 (인증/인가 로직, XSS/CSRF 방어, 민감 정보 노출)'
})
```

---

### 실전 시나리오

**시나리오 1: 풀스택 기능 구현 (API + UI + 테스트)**

```typescript
// 사용자 관리 기능 구현 (독립적 작업 병렬)
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: `User API CRUD 구현:
- src/functions/user.ts: getUsers, createUser, updateUser, deleteUser
- inputValidator로 Zod 스키마 검증
- middleware로 인증 체크`
})

Task({
  subagent_type: 'designer',
  model: 'sonnet',
  prompt: `User Profile UI 구현:
- src/routes/profile/-components/ProfileCard.tsx
- src/routes/profile/-components/EditProfileForm.tsx
- TanStack Query로 Server Function 호출`
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: `User API 테스트 작성:
- tests/user.test.ts
- 각 CRUD 엔드포인트 검증
- 인증 실패 케이스`
})

Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: 'User API 문서 작성 (docs/api/user.md)'
})

// 모든 작업 완료 후 통합 검증
```

**시나리오 2: 여러 독립 기능 동시 구현**

```typescript
// 3개의 독립적인 기능을 병렬로
Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Posts CRUD Server Functions 구현 (src/functions/posts.ts)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Comments CRUD Server Functions 구현 (src/functions/comments.ts)'
})

Task({
  subagent_type: 'implementation-executor',
  model: 'sonnet',
  prompt: 'Likes 토글 Server Function 구현 (src/functions/likes.ts)'
})

Task({
  subagent_type: 'designer',
  model: 'sonnet',
  prompt: 'Post 목록/상세 UI 구현 (src/routes/posts/)'
})
```

**시나리오 3: 코드베이스 다중 영역 탐색 + 구현**

```typescript
// 초기 분석과 구현을 병렬로
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '인증 구조 분석 (middleware, auth)'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '데이터베이스 스키마 분석 (prisma)'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '라우팅 구조 분석 (routes)'
})

// 탐색과 동시에 문서 초기화
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  prompt: '프로젝트 구조 문서 초안 작성'
})
```

**시나리오 4: 검증 병렬화 (typecheck + lint + 리뷰)**

```typescript
// 구현 완료 후 여러 검증을 동시에
Task({
  subagent_type: 'lint-fixer',
  model: 'sonnet',
  prompt: 'TypeScript 타입 에러 수정 (tsc --noEmit 결과 기반)'
})

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '보안 검토: 인증/인가, 입력 검증, XSS/CSRF'
})

Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  prompt: '성능 검토: DB 쿼리 최적화, 리렌더 최소화'
})
```

**시나리오 5: 계획 수립 전 분석 (analyst + explore)**

```typescript
// 복잡한 기능 구현 전 요구사항 및 코드베이스 분석
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: `결제 시스템 요구사항 분석:
- 가정 검증 (환불, 부분 결제, 구독)
- 엣지 케이스 식별
- 범위 확장 위험 방지`
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '기존 결제 관련 코드 탐색 및 의존성 파악'
})

// 분석 완료 후 구현
```

---

### 병렬 실행 체크리스트

작업 시작 전 확인:

```text
- [ ] 작업이 독립적인가? (의존성 없음)
- [ ] 새 컨텍스트가 필요한가? (Agent 위임 고려)
- [ ] 전문 지식이 필요한가? (도메인 Agent 선택)
- [ ] 10분 이상 소요될까? (백그라운드 실행)
- [ ] 여러 파일/영역 동시 작업? (여러 Agent 병렬 실행)
- [ ] 적절한 모델 선택? (haiku/sonnet/opus)
```

**적극적으로 Agent 활용. 혼자 하지 말 것.**

---

### 병렬 실행 시 주의

```text
✅ DO:
- 독립적인 작업만 병렬 실행
- Model 복잡도에 맞게 선택 (haiku/sonnet/opus)
- 각 Agent는 Sequential Thinking으로 자율 실행
- 결과 취합 후 통합 검증 (테스트, 빌드)
- API + UI + 문서 동시 구현
- 여러 파일/모듈 독립 작업
- 다양한 관점의 코드 리뷰

❌ DON'T:
- 의존성 있는 작업 병렬 실행 (A → B → C)
- 동일 파일 동시 수정
- 결과가 다음 작업 입력인 경우
- 과도한 병렬화 (5개 이상 → 관리 복잡)
```

---

### 간단한 예시 (복잡도별)

**간단한 작업 (haiku):**

```typescript
// 설정 파일 수정 + 문서화
Task({ subagent_type: 'implementation-executor', model: 'haiku',
      prompt: 'ESLint 설정 업데이트 (.eslintrc.json)' })
Task({ subagent_type: 'document-writer', model: 'haiku',
      prompt: 'Linting 규칙 문서화 (docs/linting.md)' })
```

**보통 작업 (sonnet):**

```typescript
// 독립적인 컴포넌트 구현
Task({ subagent_type: 'designer', model: 'sonnet',
      prompt: 'Header 컴포넌트 (로고, 네비게이션, 사용자 메뉴)' })
Task({ subagent_type: 'designer', model: 'sonnet',
      prompt: 'Footer 컴포넌트 (링크, 소셜 미디어, 저작권)' })
```

**복잡한 작업 (opus):**

```typescript
// 아키텍처 변경
Task({ subagent_type: 'implementation-executor', model: 'opus',
      prompt: 'Monorepo 구조 변경 (apps/, packages/ 분리, Turborepo)' })
```

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (2-5단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore) + Read/Grep |
| 3. 최적 접근법 결정 | 가능한 방법 분석 → 최선 선택 | sequentialthinking |
| 4. 즉시 구현 | TodoWrite → 단계별 구현 → 검증 | Edit/Write + TodoWrite |

### Sequential Thinking 가이드

**복잡도별 전략:**

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 2 | 1개 파일, 명확한 변경 | 복잡도 판단 → 즉시 구현 |
| **보통** | 3-4 | 2-3개 파일, 로직 추가 | 복잡도 판단 → 현재 상태 → 접근 방식 → 구현 |
| **복잡** | 5+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 접근 방식 → 상세 계획 → 단계별 구현 |

**보통 복잡도 패턴 (3-4단계):**

```
thought 1: 복잡도 판단 및 분석 범위 결정
thought 2: 현재 상태 분석 (코드, 아키텍처)
thought 3: 최적 접근 방식 선택 및 구현 계획
thought 4: 단계별 구현 순서 확정
```

**복잡한 경우 패턴 (5단계):**

```
thought 1: 복잡도 판단
thought 2: 현재 상태 심층 분석
thought 3: 가능한 접근 방식 탐색 및 최선 선택
thought 4: 상세 구현 계획 수립
thought 5: 단계별 실행 순서 및 검증 방법
```

### Task Subagent 활용

| subagent_type | 용도 | 예시 |
|---------------|------|------|
| **Explore** | 코드베이스 구조 파악, 관련 파일 탐색 | "현재 인증 구조 분석" |
| **general-purpose** | 복잡한 분석, 다중 시스템 연관 | "여러 모듈 간 의존성 분석" |

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
Task({ subagent_type: 'Explore', prompt: '프론트엔드 인증 구조 분석' })
Task({ subagent_type: 'Explore', prompt: '백엔드 API 인증 엔드포인트 분석' })
Task({ subagent_type: 'Explore', prompt: '데이터베이스 세션 스키마 분석' })
```

### TodoWrite 활용

**복잡도별 사용:**

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
```

## 절대 금지

```text
❌ Sequential Thinking 2단계 미만
❌ 코드 탐색 없이 추측으로 구현
❌ 옵션 제시 후 사용자 선택 대기 (바로 실행)
❌ TodoWrite 없이 복잡한 작업 수행
❌ 단계별 검증 없이 일괄 구현
❌ 테스트 실패 상태로 커밋
```

</validation>
