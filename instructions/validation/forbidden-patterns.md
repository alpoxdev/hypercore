# Forbidden Patterns (Anti-Patterns)

**목적**: 반복되는 실수 방지 및 품질 유지

## 언어 및 표현

### 추측성 표현 금지

| 금지 표현 | 이유 | 올바른 표현 |
|----------|------|-------------|
| "~해야 한다" | 불확실 | "~한다" (단정) |
| "probably" | 추측 | "검증 결과 ~" |
| "seems to" | 모호 | "분석 결과 ~" |
| "아마도" | 추측 | "확인 필요" / "~이다" |
| "~것 같다" | 불확실 | "~이다" |
| "should work" | 추측 | "테스트 통과 확인" |
| "대부분" | 모호 | "90% 케이스에서" |

**원칙**: 확실한 것만 단정. 불확실하면 검증 후 확인.

## 코드 작성

### 금지 1: any 타입 사용

```typescript
// ❌ 금지
function process(data: any) {
  return data.value
}

// ✅ 올바름
function process(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as { value: string }).value
  }
  throw new Error('Invalid data')
}
```

### 금지 2: @ts-ignore 사용

```typescript
// ❌ 금지
// @ts-ignore
const result = getData()

// ✅ 올바름
const result = getData() as ExpectedType
// 또는 타입 정의 수정
```

### 금지 3: 테스트 삭제/수정

```typescript
// ❌ 금지: 실패 테스트 삭제
// describe('login', () => { ... })  // 주석 처리

// ✅ 올바름: 코드 수정으로 테스트 통과
function login(email: string, password: string) {
  // 버그 수정
}
```

### 금지 4: 에러 무시

```typescript
// ❌ 금지
try {
  await dangerousOperation()
} catch (e) {
  // 무시
}

// ✅ 올바름
try {
  await dangerousOperation()
} catch (error) {
  logger.error('Operation failed', error)
  throw new Error('Failed to perform operation')
}
```

## 작업 흐름

### 금지 5: 검증 단계 스킵

```markdown
❌ Phase 1 → Phase 4 (직행)
❌ Phase 1 → Phase 3 (/pre-deploy 스킵)
❌ Phase 2 부분 검증 (lint만 실행)

✅ Phase 1 → 2 → 3 → 4 (순차)
✅ /pre-deploy 전체 실행 (typecheck, lint, build)
```

### 금지 6: 조기 완료 선언

```typescript
// ❌ 금지
// "구현 완료했습니다" (검증 없이)
<promise>DONE</promise>

// ✅ 올바름
Skill("pre-deploy")  // 검증
TaskList()           // TODO 확인
Task(subagent_type="planner", ...)  // Planner 승인
<promise>DONE</promise>
```

### 금지 7: 순차 실행 (병렬 가능한 경우)

```typescript
// ❌ 금지 (순차)
Read({ file_path: "file1.ts" })
// 대기...
Read({ file_path: "file2.ts" })

// ✅ 올바름 (병렬)
Read({ file_path: "file1.ts" })
Read({ file_path: "file2.ts" })
Read({ file_path: "file3.ts" })
```

### 금지 8: 에이전트 미활용

```typescript
// ❌ 금지: 모든 작업 혼자 수행
Glob(...)
Read(...)
Read(...)
Edit(...)
Edit(...)

// ✅ 올바름: 에이전트 위임
Task(subagent_type="explore", model="haiku", ...)
Task(subagent_type="implementation-executor", model="sonnet", ...)
```

## Git 작업

### 금지 9: AI 표시

```bash
# ❌ 금지
git commit -m "feat: 로그인 구현

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# ❌ 금지
git commit -m "🤖 feat: 로그인 구현"

# ✅ 올바름
git commit -m "feat: 로그인 구현"
```

### 금지 10: Bash로 직접 Git 실행

```typescript
// ❌ 금지
Bash({ command: "git add . && git commit -m 'fix' && git push" })

// ✅ 올바름
Task(subagent_type="git-operator", model="haiku",
     prompt="변경사항 커밋 및 푸시")
```

## 데이터베이스

### 금지 11: Prisma 자동 실행

```bash
# ❌ 금지 (자동 실행)
prisma db push
prisma migrate dev
prisma generate

# ✅ 올바름 (사용자 확인 후 실행)
echo "schema.prisma 수정 완료. 'prisma db push' 실행 필요"
```

### 금지 12: schema.prisma 임의 변경

```prisma
// ❌ 금지: 명시 요청 없이 스키마 변경
model User {
  id Int @id @default(autoincrement())
  email String @unique  // 임의 추가
}

// ✅ 올바름: 요청된 변경만 수행
```

## API 구현

### 금지 13: 수동 검증/인증

```typescript
// ❌ 금지: handler 내부에서 직접 검증
export const createUser = createServerFn({ method: 'POST' })
  .handler(async ({ data }) => {
    // 수동 검증
    if (!data.email) throw new Error('Email required')

    // 수동 인증 체크
    if (!request.session) throw new Error('Unauthorized')

    return prisma.user.create({ data })
  })

// ✅ 올바름: inputValidator + middleware 사용
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

### 금지 14: 클라이언트에서 Server Function 직접 호출

```typescript
// ❌ 금지
const handleSubmit = async () => {
  const result = await createUser({ data })  // 직접 호출
}

// ✅ 올바름: TanStack Query 사용
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] })
})

const handleSubmit = () => {
  mutation.mutate({ data })
}
```

## 문서화

### 금지 15: 문서 업데이트 누락

```markdown
❌ Phase 전환했는데 PROCESS.md 업데이트 안 함
❌ 요구사항 완료했는데 TASKS.md 체크 안 함
❌ 검증 완료했는데 VERIFICATION.md 기록 안 함

✅ 모든 Phase 전환 시 즉시 문서 업데이트
✅ 주요 의사결정 시 PROCESS.md 기록
✅ 검증 결과는 반드시 VERIFICATION.md에 기록
```

### 금지 16: 불필요한 문서 생성

```markdown
❌ 명시 요청 없이 README.md 생성
❌ 자동으로 CONTRIBUTING.md 생성
❌ 프로액티브하게 .md 파일 추가

✅ 명시적 요청 시에만 문서 생성
✅ 기존 문서 수정 우선
```

## 탐색 및 범위

### 금지 17: 탐색 루프

**같은 파일을 3회 이상 읽기 금지 (변경 후 확인 제외)**

```typescript
// ❌ 금지: 동일 파일 반복 읽기
Read("src/auth.ts")  // 1회
// ... 다른 작업 ...
Read("src/auth.ts")  // 2회
// ... 다른 작업 ...
Read("src/auth.ts")  // 3회 → 금지!

// ✅ 올바름: 1회 읽기 → 결과 활용
Read("src/auth.ts")  // 1회: 내용 파악 후 기억
Edit(...)            // 수정
Read("src/auth.ts")  // 2회: 변경 확인 (허용)
```

**탐색 루프 감지 시:**
1. 즉시 중단
2. 이미 읽은 내용 기반으로 다음 단계 진행
3. 추가 정보 필요 시 explore 에이전트에 위임

### 금지 18: 범위 축소

**"모든 X" / "전체 X" 지시에서 전체 대상 열거 없이 작업 시작 금지**

```typescript
// ❌ 금지: 열거 없이 일부만 처리
// 사용자: "모든 SKILL.md에서 TodoWrite를 TaskCreate로 변경"
Edit("skills/plan/SKILL.md", ...)     // plan만 수정
Edit("skills/ralph/SKILL.md", ...)    // ralph만 수정
// → 나머지 스킬 누락!

// ✅ 올바름: 전체 열거 → 전체 처리
Glob({ pattern: "**/SKILL.md" })      // 전체 대상 확인
// → 결과: 19개 파일
TaskCreate({ subject: "19개 SKILL.md TodoWrite→TaskCreate 교체", ... })
// → 19개 모두 처리
Glob({ pattern: "**/SKILL.md" })      // 재스캔 확인
Grep({ pattern: "TodoWrite", glob: "**/SKILL.md" })  // 누락 0개 확인
```

## 종합 체크리스트

작업 시작 전:

- [ ] 추측성 표현 사용하지 않기
- [ ] any, @ts-ignore 금지 확인
- [ ] 검증 단계 스킵하지 않기
- [ ] 병렬 실행 가능 여부 확인
- [ ] 에이전트 활용 계획
- [ ] "모든 X" 작업: 전체 열거 확인 (금지 18)

작업 중:

- [ ] 테스트 삭제/수정 금지
- [ ] AI 표시 커밋 메시지 금지
- [ ] Prisma 자동 실행 금지
- [ ] 수동 검증/인증 금지
- [ ] 문서 업데이트 누락 방지
- [ ] 탐색 루프 방지: 같은 파일 3회+ 읽기 금지 (금지 17)

**금지 패턴 회피 → 품질 향상 + 안정성 확보**
