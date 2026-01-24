# Verification Checklist

**목적**: 작업 완료 전 표준 검증 절차

## Phase별 검증

### Phase 1: 작업 실행 검증

**완료 조건:**

- [ ] 모든 요구사항 구현 완료
- [ ] TASKS.md 체크리스트 100% 완료
- [ ] 주요 의사결정 PROCESS.md 기록
- [ ] 독립 작업 병렬 실행 확인

**검증 방법:**

```typescript
// TASKS.md 읽기
Read({ file_path: ".claude/ralph/{timestamp}/TASKS.md" })

// 모든 체크박스가 [x]인지 확인
// 진행률이 100%인지 확인
```

### Phase 2: 자동 검증

**완료 조건:**

- [ ] typecheck 통과 (tsc --noEmit)
- [ ] lint 통과 (eslint, 0 에러)
- [ ] build 통과 (프로젝트 빌드 성공)
- [ ] pending/in_progress TODO = 0개
- [ ] VERIFICATION.md 업데이트 완료

**검증 방법:**

```typescript
// 1. /pre-deploy 실행
Skill("pre-deploy")

// 2. 결과 확인
// - typecheck: ✅ (에러 없음)
// - lint: ✅ (warning/error 0개)
// - build: ✅ (성공)

// 3. TODO 확인
TaskList()
// pending: 0
// in_progress: 0

// 4. VERIFICATION.md 업데이트
Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md에 검증 결과 기록")
```

### Phase 3: Planner 검증

**완료 조건:**

- [ ] Planner 에이전트 호출 완료
- [ ] Planner 응답: "승인" 또는 "완료"
- [ ] VERIFICATION.md에 Planner 응답 기록
- [ ] Phase 2 검증 결과 포함하여 전달

**검증 방법:**

```typescript
// 1. Planner 호출
Task(
  subagent_type="planner",
  model="opus",
  prompt=`구현 완료 검증 요청

【원본 작업】
${ORIGINAL_PROMPT}

【수행 내용】
- 요구사항 1: ✅ (구체적 설명)
- 요구사항 2: ✅ (구체적 설명)
- 요구사항 3: ✅ (구체적 설명)

【검증 결과】
- /pre-deploy: ✅ typecheck/lint/build 통과
- TODO: ✅ 0개

완료 여부를 판단하고, 미흡한 점이 있다면 구체적으로 지적해주세요.`
)

// 2. 응답 확인
// "승인", "완료", "문제없음" → Phase 4 진행
// "수정 필요", "미흡" → Phase 2 복귀

// 3. VERIFICATION.md 업데이트
Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md: Planner 응답 기록")
```

### Phase 4: 완료

**완료 조건:**

- [ ] TASKS.md 최종 확인 (모든 항목 체크)
- [ ] PROCESS.md 완료 시각 기록
- [ ] VERIFICATION.md 모든 검증 통과 확인
- [ ] `<promise>` 태그 출력

**검증 방법:**

```typescript
// 1. 최종 문서 확인
Read({ file_path: ".claude/ralph/{timestamp}/TASKS.md" })
Read({ file_path: ".claude/ralph/{timestamp}/PROCESS.md" })
Read({ file_path: ".claude/ralph/{timestamp}/VERIFICATION.md" })

// 2. PROCESS.md 완료 기록
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md: 완료 시각 및 총 소요 시간 기록")

// 3. <promise> 출력
<promise>작업 완료</promise>
```

## 코드 품질 검증

### TypeScript 검증

```bash
# typecheck 실행
tsc --noEmit

# 예상 출력
# (에러 없음)
```

**확인 사항:**

- [ ] 타입 에러 0개
- [ ] any 타입 사용 없음
- [ ] @ts-ignore 주석 없음
- [ ] 모든 함수에 명시적 return type

### ESLint 검증

```bash
# lint 실행
eslint .

# 예상 출력
# ✔ No problems
```

**확인 사항:**

- [ ] ESLint 에러 0개
- [ ] ESLint 경고 0개 (또는 정당한 이유)
- [ ] Prettier 포맷 일치

### Build 검증

```bash
# 빌드 실행
npm run build
# 또는
vite build

# 예상 출력
# ✓ built in XXXms
```

**확인 사항:**

- [ ] 빌드 성공
- [ ] 번들 크기 적절
- [ ] 빌드 경고 없음

## 기능 검증

### API 검증

- [ ] Server Function 올바른 메서드 (GET/POST/PUT/DELETE)
- [ ] POST/PUT/PATCH는 inputValidator 사용
- [ ] 인증 필요 시 middleware 사용
- [ ] 에러 처리 적절

```typescript
// ✅ 검증 예시
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])        // 인증 확인
  .inputValidator(createUserSchema)    // 입력 검증 확인
  .handler(async ({ data }) => {       // 핸들러 확인
    return prisma.user.create({ data })
  })
```

### UI 검증

- [ ] TanStack Query 사용 (useQuery/useMutation)
- [ ] 에러 상태 처리
- [ ] 로딩 상태 처리
- [ ] 낙관적 업데이트 (필요 시)

```typescript
// ✅ 검증 예시
const { data, isLoading, error } = useQuery({
  queryKey: ['users'],
  queryFn: getUsers
})

const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
  }
})
```

### Database 검증

- [ ] Prisma 스키마 일관성
- [ ] 관계 올바름 (1:N, N:N)
- [ ] Index 적절
- [ ] 한글 주석 (Multi-File 사용 시 필수)

## 문서 검증

### TASKS.md

```markdown
- [x] 요구사항 1: 완료
- [x] 요구사항 2: 완료
- [x] 요구사항 3: 완료

완료: 3 / 총 3
진행률: 100%
```

### PROCESS.md

```markdown
## Phase 4: 완료

**완료 시각:** 2026-01-24 17:00
**총 소요 시간:** 30분

모든 요구사항 구현 및 검증 완료
```

### VERIFICATION.md

```markdown
## /pre-deploy 검증

**실행 시각:** 2026-01-24 16:50

**결과:**
- Typecheck: ✅ 통과
- Lint: ✅ 0 에러
- Build: ✅ 성공

## TODO 확인

**실행 시각:** 2026-01-24 16:52

**결과:** pending/in_progress = 0

## Planner 검증

**실행 시각:** 2026-01-24 16:55

**응답:** "구현 완료 승인. 요구사항 모두 충족."
```

## Git 검증

### 커밋 메시지

```bash
# ✅ 올바른 형식
feat: 로그인 API 구현
fix: 타입 에러 수정

# ❌ 잘못된 형식
로그인 기능  # prefix 없음
feat: 로그인\n\nCo-Authored-By: ...  # 여러 줄
```

### 커밋 내용

- [ ] 논리적 단위로 분리
- [ ] 관련 없는 변경 혼재 없음
- [ ] AI 표시 없음 (Co-Authored-By, 🤖 등)

## 실패 시 조치

| 실패 항목 | 조치 |
|----------|------|
| typecheck 실패 | lint-fixer 에이전트로 수정 |
| lint 실패 | lint-fixer 에이전트로 수정 |
| build 실패 | 에러 로그 분석 후 수정 |
| Planner 거절 | 피드백 반영 → Phase 2부터 재실행 |
| TODO 미완료 | 남은 작업 완료 |

**절대 검증 스킵하지 않음. 실패 시 수정 → 재검증 반복.**

## 최종 체크리스트

작업 완료 전 확인:

- [ ] Phase 1-4 순차 진행 완료
- [ ] /pre-deploy 전체 통과
- [ ] TODO 리스트 0개
- [ ] Planner 승인 획득
- [ ] 문서 업데이트 완료
- [ ] Git 커밋 형식 준수
- [ ] 코드 품질 기준 충족

**모든 항목 체크 완료 후 `<promise>` 출력**
