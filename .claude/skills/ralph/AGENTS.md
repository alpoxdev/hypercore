# Ralph - Agent Coordination

자기참조 루프 스킬에서 에이전트 활용 가이드. 복잡한 작업의 완전한 구현과 검증.

---

<agents_reference>

다중 에이전트 구조:
- 에이전트 목록: @../../instructions/multi-agent/agent-roster.md
- 조정 가이드: @../../instructions/multi-agent/coordination-guide.md
- 실행 패턴: @../../instructions/multi-agent/execution-patterns.md

</agents_reference>

---

<recommended_agents>

## 추천 에이전트

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **planner** | opus | 아키텍처 설계, 완료 검증 (Phase 3 필수) |
| **implementation-executor** | sonnet | 기능 구현, 버그 수정 |
| **designer** | sonnet/opus | UI/UX 구현 |
| **explore** | haiku | 코드베이스 탐색, 기존 패턴 분석 |
| **document-writer** | haiku/sonnet | 상태 문서 작성/업데이트 (TASKS.md, PROCESS.md) |
| **deployment-validator** | sonnet | /pre-deploy 검증 (Phase 2) |
| **lint-fixer** | sonnet | tsc/eslint 에러 자동 수정 |
| **code-reviewer** | opus | 코드 품질 검증 (보안, 성능, 접근성) |

</recommended_agents>

---

<coordination_patterns>

## 조정 패턴

### 패턴 1: 문서 초기화 (병렬)

**용도:** Ralph 시작 시 상태 문서 생성

```typescript
// Phase 1 시작 시 여러 문서 동시 작성
Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="TASKS.md 생성: 요구사항 체크리스트 작성"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="PROCESS.md 생성: Phase 1 시작 기록"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="VERIFICATION.md 생성: 초기 상태"
)
```

**효과:** 순차 실행 대비 3배 빠름, Context compaction 대비 강화

---

### 패턴 2: 탐색 → 병렬 구현

**용도:** 기능 구현 시 탐색 후 병렬 작업

```typescript
// Step 1: 병렬 탐색
Task(
  subagent_type="explore",
  model="haiku",
  prompt="인증 구조 분석: middleware, session, auth 파일"
)

Task(
  subagent_type="explore",
  model="haiku",
  prompt="Prisma 스키마 분석: User, Session 모델"
)

// Step 2: 병렬 구현
Task(
  subagent_type="implementation-executor",
  model="sonnet",
  prompt="백엔드 API 구현: Server Functions"
)

Task(
  subagent_type="designer",
  model="sonnet",
  prompt="프론트엔드 UI 구현: 로그인/회원가입 폼"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="API 문서 작성"
)
```

---

### 패턴 3: 병렬 검증 (Phase 2)

**용도:** /pre-deploy 통과 후 다양한 관점 검토

```typescript
// 병렬 검증
Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="보안 검토: SQL Injection, XSS, CSRF, 인증/인가"
)

Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="성능 검토: N+1 쿼리, 불필요한 리렌더, 번들 크기"
)

Task(
  subagent_type="code-reviewer",
  model="opus",
  prompt="접근성 검토: ARIA, 키보드 네비게이션, 색상 대비"
)
```

---

### 패턴 4: Phase 전환 시 문서 병렬 업데이트

**용도:** Context compaction 대비

```typescript
// Phase 전환 시 여러 문서 동시 업데이트
Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="TASKS.md 업데이트: 요구사항 1-3 완료 체크"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="PROCESS.md 업데이트: Phase 1 완료 → Phase 2 시작 기록"
)

Task(
  subagent_type="document-writer",
  model="haiku",
  prompt="VERIFICATION.md 업데이트: 준비 상태로 초기화"
)
```

**효과:** 문서화 시간 최소화, 상태 복구 강화

---

### 패턴 5: Planner 검증 (Phase 3, 필수)

**용도:** 완료 판단 (우회 불가)

```typescript
// /pre-deploy 통과 + TODO 0개 후에만 호출
Task(
  subagent_type="planner",
  model="opus",
  prompt=`구현 완료 검증 요청

【원본 작업】
{{PROMPT}}

【수행 내용】
- 요구사항 1: 완료 (구체적 설명)
- 요구사항 2: 완료 (구체적 설명)

【검증 결과】
- /pre-deploy: ✅ 통과
- TODO: ✅ 0개

완료 여부를 판단하고, 미흡한 점이 있다면 구체적으로 지적해주세요.`
)
```

**Planner 승인 후에만 `<promise>` 출력.**

</coordination_patterns>

---

<model_routing>

## 모델 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| **상태 문서 작성/업데이트** | haiku | 빠른 문서화 |
| **코드베이스 탐색** | haiku | 빠른 구조 파악 |
| **기능 구현** | sonnet | 일반 구현 |
| **복잡한 구현** | sonnet | 아키텍처 변경 |
| **완료 검증** | opus | 정확한 판단 (Planner) |
| **코드 리뷰** | opus | 보안/성능/접근성 |

</model_routing>

---

<phase_by_phase_agents>

## Phase별 에이전트 활용

### Phase 1: 작업 실행

| 작업 | 에이전트 | 모델 | 병렬 |
|------|---------|------|------|
| 문서 초기화 | document-writer | haiku | ✅ (3개 문서) |
| 코드베이스 탐색 | explore | haiku | ✅ (여러 영역) |
| 백엔드 구현 | implementation-executor | sonnet | ✅ (독립 기능) |
| 프론트엔드 구현 | designer | sonnet | ✅ (여러 컴포넌트) |
| 문서 작성 | document-writer | haiku | ✅ (API 문서 등) |
| 문서 업데이트 | document-writer | haiku | ✅ (Phase 전환 시) |

---

### Phase 2: 검증

| 작업 | 에이전트 | 모델 | 병렬 |
|------|---------|------|------|
| /pre-deploy 실행 | deployment-validator | sonnet | ❌ (순차) |
| 린트 수정 | lint-fixer | sonnet | ❌ (순차) |
| 보안 검토 | code-reviewer | opus | ✅ (병렬) |
| 성능 검토 | code-reviewer | opus | ✅ (병렬) |
| 접근성 검토 | code-reviewer | opus | ✅ (병렬) |
| 문서 업데이트 | document-writer | haiku | ✅ (검증 결과) |

---

### Phase 3: Planner 검증

| 작업 | 에이전트 | 모델 | 병렬 |
|------|---------|------|------|
| 완료 검증 | planner | opus | ❌ (필수) |
| 문서 업데이트 | document-writer | haiku | ❌ (Planner 후) |

---

### Phase 4: 완료

| 작업 | 에이전트 | 모델 | 병렬 |
|------|---------|------|------|
| 최종 문서 | document-writer | haiku | ❌ (순차) |
| `<promise>` 출력 | - | - | - |

</phase_by_phase_agents>

---

<practical_examples>

## 실전 예시

### 예시 1: 사용자 인증 기능 구현

```typescript
// Phase 1: 탐색 + 문서 초기화 (병렬)
Task(subagent_type="explore", model="haiku",
     prompt="기존 인증 구조 분석")
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md 생성: 요구사항 체크리스트")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md 생성: Phase 1 시작")

// Phase 1: 병렬 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User 인증 API: login, logout, signup Server Functions")
Task(subagent_type="designer", model="sonnet",
     prompt="로그인/회원가입 UI: Form 컴포넌트")
Task(subagent_type="document-writer", model="haiku",
     prompt="인증 API 문서 작성")

// Phase 2: /pre-deploy
Task(subagent_type="deployment-validator", model="sonnet",
     prompt="/pre-deploy 실행")

// Phase 2: 병렬 검증
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 검토: 인증/인가, SQL Injection")
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토: 쿼리 최적화")

// Phase 3: Planner 검증
Task(subagent_type="planner", model="opus",
     prompt="구현 완료 검증 요청")
```

---

### 예시 2: 여러 독립 기능 동시 구현

```typescript
// Phase 1: 병렬 구현 (Posts, Comments, Likes)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Posts CRUD Server Functions")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Comments CRUD Server Functions")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Likes 토글 Server Function")
Task(subagent_type="designer", model="sonnet",
     prompt="Post 목록/상세 UI")

// Phase 1: 문서 업데이트 (병렬)
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md: 요구사항 1-3 완료 체크")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md: Phase 1 → Phase 2 전환")
```

---

### 예시 3: Context Compaction 후 복구

```text
1. pwd → 작업 디렉토리 확인
2. ls .claude/ralph/ → 최신 세션 폴더 찾기
3. TASKS.md 읽기 → 요구사항 및 완료 상태
4. PROCESS.md 읽기 → 현재 Phase 및 다음 단계
5. VERIFICATION.md 읽기 → 검증 결과
6. git log --oneline -10 → 최근 커밋 확인
7. 중단 지점부터 계속
```

**문서화 덕분에 세션 복구 가능.**

</practical_examples>

---

<best_practices>

## 모범 사례

### 작업 시작 전 체크

- [ ] 복잡한 작업인가? → Ralph 스킬 사용
- [ ] 여러 독립 작업? → 병렬 executor/designer
- [ ] 문서화 필요? → document-writer (병렬)
- [ ] 검증 중요? → code-reviewer (병렬)
- [ ] 완료 판단? → planner (Phase 3 필수)

### 금지 사항 (조기 탈출 방지)

**절대 금지:**
- Planner 검증 없이 `<promise>` 출력
- /pre-deploy 스킵
- TODO 확인 생략
- 추측 기반 완료 ("아마도", "~것 같다")

**대신 사용:**
- `/pre-deploy` 실행
- `TaskList` 조회
- `Task(subagent_type="planner", model="opus", ...)`

### 에이전트 활용 원칙

**DO:**
- 문서 초기화 → document-writer (병렬)
- 독립 구현 → executor/designer (병렬)
- 검증 → code-reviewer (병렬)
- Planner 검증 (Phase 3 필수)
- Context compaction 대비 문서화

**DON'T:**
- 혼자 모든 작업 수행
- 순차 실행 (병렬 가능한 경우)
- 문서화 생략
- Planner 스킵

### 완료 프로토콜 (4단계)

| # | 단계 | 검증 방법 | 통과 기준 |
|---|------|----------|----------|
| 1 | 작업 완료 | 체크리스트 | 100% 충족 |
| 2 | 코드 검증 | /pre-deploy | typecheck/lint/build 통과 |
| 3 | TODO 확인 | TaskList | pending/in_progress = 0 |
| 4 | Planner 검증 | planner 에이전트 | "승인" 응답 |

**모든 4단계 통과 후에만 `<promise>` 출력.**

</best_practices>
