# Redundant Exploration Prevention (중복 탐색 방지)

**목적**: Claude Code 세션에서 중복 파일 탐색을 방지하여 컨텍스트 윈도우 절약 및 Rate Limiting 회피

---

<problem>

## 문제점 (Usage Report 분석 기반)

### 주요 이슈

**"Redundant codebase exploration is your biggest tax"**

- Claude가 이미 분석한 파일을 반복적으로 재탐색
- 컨텍스트 윈도우가 불필요하게 소모
- Rate Limiting 8건의 주요 원인

### 중복 탐색의 영향

| 영향 | 내용 | 손실 규모 |
|------|------|----------|
| **토큰 낭비** | 같은 파일 3-5회 읽기 | 컨텍스트 30-50% 소모 |
| **시간 낭비** | 탐색 루프에 빠짐 | 작업 시간 2-3배 증가 |
| **Rate Limiting** | 과도한 Tool 호출 | 세션 중단 위험 |
| **컨텍스트 압박** | 유용한 정보 밀려남 | Context compaction 조기 발생 |

### 패턴 예시

```typescript
// ❌ 중복 탐색 패턴
Read("src/auth.ts")        // 1회
// ... 작업 ...
Read("src/auth.ts")        // 2회 (변경 없음)
// ... 작업 ...
Read("src/auth.ts")        // 3회 (변경 없음)
Glob("src/**/*.ts")        // 이미 탐색한 디렉토리
```

</problem>

---

<core_rules>

## 핵심 규칙

### 1. 중복 읽기 금지

**같은 파일을 2회 이상 Read 금지 (변경 후 재확인 제외)**

```typescript
// ✅ 허용: 수정 후 재확인
Read("src/auth.ts")  // 1회: 내용 파악
Edit(...)            // 수정
Read("src/auth.ts")  // 2회: 변경 확인 (허용)

// ❌ 금지: 변경 없이 재읽기
Read("src/auth.ts")  // 1회
// ... 다른 작업 ...
Read("src/auth.ts")  // 2회: 변경 없이 재읽기 (금지)
```

### 2. 중복 탐색 금지

**이미 실행한 Glob/Grep 패턴 재실행 금지**

```typescript
// ❌ 금지: 같은 패턴 반복
Glob({ pattern: "**/*.ts" })  // 1회
// ... 작업 ...
Glob({ pattern: "**/*.ts" })  // 2회 (금지)

// ✅ 허용: 다른 목적의 탐색
Glob({ pattern: "**/*.ts" })        // 전체 파일
Glob({ pattern: "**/auth/*.ts" })   // 특정 디렉토리 (허용)
```

### 3. 탐색 전 체크리스트

**탐색 Tool 실행 전 반드시 확인**

- [ ] 이 파일을 이미 읽었는가?
- [ ] 이 디렉토리를 이미 탐색했는가?
- [ ] 파일이 수정되었는가? (Edit/Write 후)
- [ ] 정말 새로운 정보가 필요한가?

### 4. 탐색 루프 즉시 중단

**3회 이상 같은 파일 읽기 시도 시 즉시 중단**

```typescript
// 탐색 루프 감지 시:
1. 즉시 중단
2. 이미 읽은 내용 기반으로 다음 단계 진행
3. 추가 정보 필요 시 explore 에이전트에 위임
```

</core_rules>

---

<context_saving_patterns>

## 컨텍스트 절약 패턴

### 패턴 1: 탐색 결과 압축

**탐색 즉시 핵심 정보만 추출하여 요약**

```typescript
// ✅ 올바른 흐름
Task(subagent_type="explore", model="haiku",
     prompt="[quick] src/auth 디렉토리 구조 확인")
// → 결과 즉시 요약
// "인증: middleware 1개(auth.ts), functions 2개(login.ts, logout.ts), 총 3개 파일"

// ❌ 금지: 요약 없이 추가 탐색
Task(subagent_type="explore", ...)  // 탐색 1
Task(subagent_type="explore", ...)  // 요약 없이 탐색 2
```

### 패턴 2: 관련 파일 그룹 탐색

**개별 탐색 대신 한 번에 그룹으로 탐색**

```typescript
// ✅ 올바름: 그룹 탐색
Read("src/auth/middleware.ts")
Read("src/auth/functions.ts")
Read("src/auth/types.ts")
// → 3개 파일을 병렬로 한 번에 읽기

// ❌ 금지: 개별 순차 탐색
Read("src/auth/middleware.ts")
// 분석...
Read("src/auth/functions.ts")
// 분석...
Read("src/auth/types.ts")
// 분석...
```

### 패턴 3: 요약 기록 활용

**핵심 분석 결과를 NOTES.md 또는 문서에 기록**

```markdown
# NOTES.md

## 프로젝트 구조 요약 (2026-02-06 14:30)

### 인증 모듈
- 위치: `src/auth/`
- 파일: middleware.ts (인증 체크), login.ts (로그인), logout.ts (로그아웃)
- 의존성: Prisma User 모델, TanStack Session

### API 라우트
- 위치: `src/routes/api/`
- 파일: 15개 (users, posts, comments 등)
- 패턴: createServerFn + inputValidator + middleware
```

**요약 기록 후 재탐색 불필요 → 기록 참조**

### 패턴 4: 파일 인벤토리 사전 생성

**복잡한 작업 시작 전 TaskCreate로 대상 파일 목록 등록**

```typescript
// ✅ 올바름: 인벤토리 먼저 생성
Glob({ pattern: "src/**/*.ts" })
// → 결과: 50개 파일
TaskCreate({
  subject: "프로젝트 파일 인벤토리",
  description: `
    - src/auth/: 3개
    - src/routes/: 15개
    - src/components/: 25개
    - src/utils/: 7개
    총 50개 파일
  `
})

// → 이후 작업에서 인벤토리 참조 (재탐색 불필요)
```

</context_saving_patterns>

---

<forbidden_patterns>

## 금지 패턴

### ❌ 금지 1: 같은 파일 여러 번 Read

**동일 파일을 변경 없이 2회 이상 읽기**

```typescript
// ❌ 금지
Read("src/auth.ts")  // 1회
// ... 작업 ...
Read("src/auth.ts")  // 2회: 변경 없이 재읽기

// ✅ 올바름: 1회 읽기 → 기억 활용
Read("src/auth.ts")  // 1회
// → 내용 기억 → 다음 단계 진행
```

### ❌ 금지 2: 결과 확인 없이 같은 Glob 재실행

**이미 실행한 Glob 패턴을 결과 확인 없이 재실행**

```typescript
// ❌ 금지
Glob({ pattern: "**/*.md" })  // 1회
// → 결과 무시...
Glob({ pattern: "**/*.md" })  // 2회: 같은 패턴 재실행

// ✅ 올바름: 결과 활용
Glob({ pattern: "**/*.md" })  // 1회
// → 결과: 20개 파일 확인 → 활용
```

### ❌ 금지 3: 이미 분석한 파일 재분석 요청

**explore 에이전트에 이미 분석한 파일 재분석 요청**

```typescript
// ❌ 금지
Task(subagent_type="explore", model="haiku",
     prompt="src/auth/ 분석")  // 1회
Task(subagent_type="explore", model="haiku",
     prompt="src/auth/ 분석")  // 2회: 같은 요청

// ✅ 올바름: 1회 분석 → 다음 단계
Task(subagent_type="explore", model="haiku",
     prompt="src/auth/ 분석")  // 1회
// → 결과 요약 → 구현 시작
```

### ❌ 금지 4: 탐색 루프

**같은 영역을 3회 이상 반복 탐색**

```typescript
// ❌ 금지: 탐색 루프
Grep({ pattern: "createServerFn", path: "src/" })  // 1회
// ... 작업 ...
Grep({ pattern: "createServerFn", path: "src/" })  // 2회
// ... 작업 ...
Grep({ pattern: "createServerFn", path: "src/" })  // 3회 → 루프!

// ✅ 올바름: 1회 탐색 → 결과 활용
Grep({ pattern: "createServerFn", path: "src/" })  // 1회
// → 결과: 15개 발견 → 작업 진행
```

### ❌ 금지 5: 광범위한 탐색 반복

**전체 코드베이스 스캔을 여러 번 반복**

```typescript
// ❌ 금지
Glob({ pattern: "**/*" })      // 전체 스캔 1회
// ... 작업 ...
Glob({ pattern: "**/*.ts" })   // 전체 스캔 2회 (중복)
// ... 작업 ...
Glob({ pattern: "src/**/*" })  // 전체 스캔 3회 (중복)

// ✅ 올바름: 1회 스캔 → 필터링
Glob({ pattern: "**/*.ts" })   // 1회: 전체 TypeScript 파일
// → 결과 필터링 활용 (재스캔 불필요)
```

</forbidden_patterns>

---

<allowed_patterns>

## 허용 패턴

### ✅ 허용 1: 파일 수정 후 변경 내용 확인

**Edit/Write 후 변경 사항 검증**

```typescript
// ✅ 허용: 수정 후 재확인
Read("src/auth.ts")  // 1회: 내용 파악
Edit({
  file_path: "src/auth.ts",
  old_string: "...",
  new_string: "..."
})
Read("src/auth.ts")  // 2회: 변경 확인 (허용)
```

### ✅ 허용 2: 명시적으로 다른 정보 필요 시

**새로운 관점이나 다른 정보를 찾기 위한 탐색**

```typescript
// ✅ 허용: 다른 목적의 탐색
Grep({ pattern: "function", path: "src/auth.ts" })  // 함수 탐색
Grep({ pattern: "import", path: "src/auth.ts" })    // 의존성 탐색 (허용)
```

### ✅ 허용 3: Context compaction 후 복구 시

**컨텍스트 압축 후 필요한 파일 재로드**

```typescript
// ✅ 허용: Context compaction 후
// → Context compaction 발생
Read("TASKS.md")       // 재로드 (허용)
Read("PROCESS.md")     // 재로드 (허용)
```

### ✅ 허용 4: 전체 작업 완료 후 검증

**"모든 X" 작업 완료 후 누락 확인**

```typescript
// ✅ 허용: 완료 후 재스캔 (검증)
Glob({ pattern: "**/SKILL.md" })  // 1회: 전체 대상 확인
// ... 모든 파일 수정 ...
Glob({ pattern: "**/SKILL.md" })  // 2회: 검증 재스캔 (허용)
Grep({ pattern: "TodoWrite", glob: "**/SKILL.md" })  // 누락 확인 (허용)
```

### ✅ 허용 5: 에이전트 위임 후 결과 확인

**에이전트가 작업한 파일 확인**

```typescript
// ✅ 허용: 에이전트 작업 후 확인
Read("src/feature.ts")  // 1회: 현재 상태
Task(subagent_type="implementation-executor", ...)  // 에이전트 작업
Read("src/feature.ts")  // 2회: 에이전트 작업 결과 확인 (허용)
```

</allowed_patterns>

---

<exploration_checklist>

## 탐색 전 체크리스트

### Read 실행 전

```text
✓ 이 파일을 이미 읽었는가?
  → YES: 기억 활용 (재읽기 금지)
  → NO: Read 실행

✓ 파일이 수정되었는가?
  → YES: 변경 확인 Read 허용
  → NO: 기억 활용

✓ 정말 새로운 정보가 필요한가?
  → YES: Read 실행
  → NO: 기억 활용
```

### Glob 실행 전

```text
✓ 이 패턴을 이미 실행했는가?
  → YES: 결과 재활용 (재실행 금지)
  → NO: Glob 실행

✓ 더 구체적인 패턴으로 필터링 가능한가?
  → YES: 메모리 결과 필터링
  → NO: Glob 실행

✓ explore 에이전트에 위임 가능한가?
  → YES: Task 위임
  → NO: Glob 실행
```

### Grep 실행 전

```text
✓ 같은 패턴을 이미 검색했는가?
  → YES: 결과 재활용 (재검색 금지)
  → NO: Grep 실행

✓ 이전 검색 결과를 다시 필터링 가능한가?
  → YES: 메모리 결과 활용
  → NO: Grep 실행

✓ 정말 다른 정보를 찾는가?
  → YES: Grep 실행
  → NO: 기억 활용
```

### Explore 에이전트 호출 전

```text
✓ 같은 영역을 이미 분석했는가?
  → YES: 이전 결과 활용 (재분석 금지)
  → NO: Task 실행

✓ 이전 분석 요약이 있는가?
  → YES: 요약 참조
  → NO: Task 실행 + 요약 생성

✓ thoroughness 레벨이 적절한가?
  → quick: 간단 확인
  → thorough: 상세 분석
  → very thorough: 완전 분석
```

</exploration_checklist>

---

<recovery_strategies>

## 탐색 루프 복구 전략

### 탐색 루프 감지 시

**같은 파일/패턴 3회 이상 접근 시 즉시 중단**

```typescript
// 감지: Read("src/auth.ts") 3회 호출

// 복구 단계:
1. 즉시 중단
2. 이미 읽은 내용 기억 활용
3. 추가 정보 필요 시 explore 에이전트 위임
4. 요약 생성 → NOTES.md 기록
```

### 복구 프로세스

```text
Phase 1: 중단
✓ 탐색 Tool 호출 중단
✓ 현재까지 수집한 정보 정리

Phase 2: 분석
✓ 왜 재탐색이 필요했는가?
✓ 정보가 부족한가? → 다른 접근 필요
✓ 정보는 충분한가? → 다음 단계 진행

Phase 3: 대안 선택
✓ 기억 활용: 이미 읽은 내용으로 진행
✓ 에이전트 위임: explore 에이전트에 맡김
✓ 요약 참조: NOTES.md 또는 문서 확인

Phase 4: 문서화
✓ 요약 생성: 핵심 정보 압축
✓ NOTES.md 기록: 향후 참조용
✓ TaskCreate: 파일 인벤토리 등록
```

### 복구 예시

```typescript
// ❌ 탐색 루프 발생
Read("src/auth.ts")  // 1회
Read("src/auth.ts")  // 2회
Read("src/auth.ts")  // 3회 → 감지!

// ✅ 복구 프로세스
// 1. 즉시 중단
// 2. 기억 활용
//    "src/auth.ts: authMiddleware 함수, checkAuth 함수, Session 타입"
// 3. 다음 단계 진행
//    Edit({ file_path: "src/auth.ts", ... })
// 4. 요약 기록
Write(".claude/NOTES.md", `
## 인증 모듈 (src/auth.ts)
- authMiddleware: 세션 검증 미들웨어
- checkAuth: 인증 상태 확인 함수
- Session 타입: userId, role 포함
`)
```

</recovery_strategies>

---

<monitoring>

## 모니터링 및 추적

### 탐색 횟수 추적

**세션 내 Tool 호출 패턴 모니터링**

```markdown
# 탐색 통계 (세션 내)

## Read 호출
- src/auth.ts: 2회 (수정 후 재확인 1회 포함)
- src/routes/index.tsx: 1회
- TASKS.md: 3회 (Context compaction 후 재로드 2회)

## Glob 호출
- **/*.ts: 1회 (50개 발견)
- **/SKILL.md: 2회 (전체 작업 후 검증 1회 포함)

## Grep 호출
- "createServerFn": 1회 (15개 발견)
- "TodoWrite": 1회 (0개 발견 - 완료 확인)

## 경고
⚠️ 없음
```

### 탐색 효율성 지표

| 지표 | 목표 | 현재 | 상태 |
|------|------|------|------|
| **Read 중복률** | < 10% | 8% | ✅ 우수 |
| **Glob 재실행** | 0-1회 | 1회 | ✅ 정상 |
| **탐색 루프** | 0회 | 0회 | ✅ 정상 |
| **토큰 절약** | 30%+ | 42% | ✅ 목표 초과 |

</monitoring>

---

<best_practices>

## 모범 사례

### 1. 탐색 결과 즉시 요약

```typescript
// ✅ 모범 사례
Task(subagent_type="explore", model="haiku",
     prompt="[quick] src/routes/ 디렉토리 구조 확인")
// → 즉시 요약
// "15개 라우트, 패턴 확인: createServerFn + inputValidator"
// → 재탐색 불필요
```

### 2. 파일 인벤토리 사전 생성

```typescript
// ✅ 모범 사례
Glob({ pattern: "src/**/*.ts" })
TaskCreate({
  subject: "프로젝트 파일 목록",
  description: "50개 TypeScript 파일 (auth 3, routes 15, components 25, utils 7)"
})
// → 이후 작업에서 인벤토리 참조
```

### 3. 요약 문서화

```markdown
# NOTES.md

## 프로젝트 구조 (2026-02-06)
- src/auth/: 인증 (3개 파일)
- src/routes/: API 라우트 (15개)
- src/components/: UI 컴포넌트 (25개)

## 패턴
- Server Function: createServerFn + inputValidator + middleware
- 클라이언트: TanStack Query (useQuery/useMutation)
```

### 4. 병렬 그룹 탐색

```typescript
// ✅ 모범 사례: 관련 파일 한 번에
Read("src/auth/middleware.ts")
Read("src/auth/functions.ts")
Read("src/auth/types.ts")
// → 3개 파일 병렬 읽기 (개별 순차 읽기 대신)
```

### 5. 에이전트 위임 활용

```typescript
// ✅ 모범 사례: 복잡한 탐색 위임
Task(subagent_type="explore", model="haiku",
     prompt="[thorough] 인증 관련 모든 파일 및 의존성 완전 분석")
// → 에이전트가 탐색 + 요약 제공
// → 재탐색 불필요
```

</best_practices>

---

<summary>

## 핵심 요약

### 3가지 원칙

| 원칙 | 내용 | 효과 |
|------|------|------|
| **1회 탐색** | 같은 파일/패턴 1회만 탐색 | 토큰 30-50% 절약 |
| **즉시 요약** | 탐색 결과 즉시 압축 | 재탐색 불필요 |
| **루프 중단** | 3회 이상 접근 시 즉시 중단 | Rate Limiting 회피 |

### 허용/금지 요약

#### ✅ 허용

- 파일 수정 후 변경 내용 확인
- 명시적으로 다른 정보 필요 시
- Context compaction 후 복구
- 전체 작업 완료 후 검증
- 에이전트 작업 후 결과 확인

#### ❌ 금지

- 같은 파일 여러 번 Read (변경 없이)
- 결과 확인 없이 같은 Glob 재실행
- 이미 분석한 파일 재분석 요청
- 같은 영역 3회 이상 반복 탐색
- 광범위한 전체 스캔 반복

### 탐색 전 필수 체크

```text
1. 이미 읽었는가? → YES: 기억 활용 / NO: Read
2. 수정되었는가? → YES: 재확인 / NO: 기억 활용
3. 새 정보 필요? → YES: 탐색 / NO: 다음 단계
```

### 복구 전략

```text
탐색 루프 감지 → 즉시 중단 → 기억 활용 → 에이전트 위임 → 요약 기록
```

### 효과

- **토큰 절약:** 30-50%
- **시간 단축:** 2-3배 빠른 작업
- **Rate Limiting 회피:** 8건 → 0건
- **컨텍스트 효율:** Context compaction 지연

</summary>
