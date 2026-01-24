# Required Behaviors (필수 행동)

**목적**: 모든 작업에서 반드시 따라야 할 규칙

## 작업 시작

### 필수 1: Sequential Thinking

**복잡도 MEDIUM 이상 작업은 반드시 Sequential Thinking 실행**

| 복잡도 | 최소 단계 | 예시 |
|--------|----------|------|
| LOW | 1-2 | 파일 읽기, 간단한 검색 |
| MEDIUM | 3-5 | 기능 구현, 버그 수정 |
| HIGH | 7-10+ | 아키텍처 설계, 대규모 리팩토링 |

```typescript
// ✅ 필수: 작업 전 Sequential Thinking
mcp__sequential-thinking__sequentialthinking({
  thought: "User API 구현 계획: 요구사항 분석 → 스키마 → 구현 → 검증",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})
```

### 필수 2: 파일 읽기 전 Read 사용

**코드 수정 전 반드시 Read로 파일 읽기**

```typescript
// ✅ 필수 순서
Read({ file_path: "src/functions/auth.ts" })  // 1. 읽기
Edit({ ... })  // 2. 수정

// ❌ 금지
Edit({ ... })  // 읽지 않고 수정
```

### 필수 3: 병렬 읽기

**3개 이상 독립 파일은 반드시 병렬로 읽기**

```typescript
// ✅ 필수: 병렬 읽기
Read({ file_path: "file1.ts" })
Read({ file_path: "file2.ts" })
Read({ file_path: "file3.ts" })
```

## 코드 작성

### 필수 4: UTF-8 인코딩

**모든 파일은 UTF-8 인코딩 사용**

### 필수 5: 코드 묶음 단위 한글 주석

```typescript
// ✅ 필수: 코드 블록 상단에 한글 주석
// 사용자 인증 검증
const isAuthenticated = await checkAuth(session)
if (!isAuthenticated) throw new Error('Unauthorized')

// 사용자 데이터 조회
const user = await prisma.user.findUnique({ where: { id: session.userId } })
```

### 필수 6: TypeScript strict 모드

```typescript
// ✅ 필수: 명시적 타입
function createUser(data: CreateUserInput): Promise<User> {
  return prisma.user.create({ data })
}

// ❌ 금지: any 사용
function createUser(data: any): any {
  return prisma.user.create({ data })
}
```

## API 구현

### 필수 7: Server Function 패턴

**POST/PUT/PATCH는 inputValidator 필수**

```typescript
// ✅ 필수
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)  // 필수
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

**인증 필요 시 middleware 필수**

```typescript
// ✅ 필수
export const getProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])  // 필수
  .handler(async ({ context }) => {
    return prisma.user.findUnique({ where: { id: context.userId } })
  })
```

### 필수 8: TanStack Query 사용

**클라이언트에서 Server Function 호출 시 반드시 TanStack Query 사용**

```typescript
// ✅ 필수: useQuery/useMutation
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: getUsers
})

const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] })
})

// ❌ 금지: 직접 호출
const users = await getUsers()
```

## 검증

### 필수 9: 4-Phase 순차 진행

**Phase 1 → 2 → 3 → 4 순서 엄수**

```markdown
✅ Phase 1: 작업 실행 (모든 요구사항 완료)
✅ Phase 2: 자동 검증 (/pre-deploy + TODO)
✅ Phase 3: Planner 검증 (승인 필수)
✅ Phase 4: 완료 (<promise> 출력)
```

### 필수 10: /pre-deploy 전체 실행

**typecheck, lint, build 모두 통과 필수**

```typescript
// ✅ 필수: 전체 검증
Skill("pre-deploy")

// ❌ 금지: 부분 검증
Bash({ command: "tsc --noEmit" })  // typecheck만
```

### 필수 11: Planner 검증

**Phase 3에서 Planner 승인 필수**

```typescript
// ✅ 필수
Task(
  subagent_type="planner",
  model="opus",
  prompt=`구현 완료 검증 요청

【원본 작업】
${PROMPT}

【검증 결과】
- /pre-deploy: ✅
- TODO: ✅ 0개

완료 여부 판단 요청`
)
```

## 문서화

### 필수 12: Ralph 세션 문서

**Ralph 스킬 사용 시 반드시 문서화**

```
.claude/ralph/{YYYY-MM-DD_HH-MM}/
├── TASKS.md          # 필수
├── PROCESS.md        # 필수
├── VERIFICATION.md   # 필수
└── NOTES.md          # 선택
```

### 필수 13: 문서 업데이트 시점

| 시점 | 업데이트 파일 | 내용 |
|------|--------------|------|
| Phase 전환 | PROCESS.md | Phase N 완료 → Phase N+1 시작 |
| 요구사항 완료 | TASKS.md | 체크박스 체크 |
| 검증 실행 | VERIFICATION.md | /pre-deploy 결과, TODO 개수 |
| 주요 의사결정 | PROCESS.md | 결정 내용 및 이유 |

### 필수 14: Prisma Multi-File

**Prisma Multi-File 구조 사용 시 모든 요소에 한글 주석 필수**

```prisma
// ✅ 필수: 모든 모델/필드/enum에 주석

/// 사용자
model User {
  /// 고유 식별자
  id        Int      @id @default(autoincrement())
  /// 이메일 (고유)
  email     String   @unique
  /// 이름
  name      String
  /// 생성 시각
  createdAt DateTime @default(now())
}

/// 사용자 역할
enum UserRole {
  /// 관리자
  ADMIN
  /// 일반 사용자
  USER
}
```

## Git 작업

### 필수 15: git-operator 사용

**Git 작업은 반드시 git-operator 에이전트 사용**

```typescript
// ✅ 필수
Task(subagent_type="git-operator", model="haiku",
     prompt="변경사항 커밋 및 푸시")

// ❌ 금지
Bash({ command: "git add . && git commit -m 'feat: ...' && git push" })
```

### 필수 16: 커밋 메시지 형식

**`<prefix>: <설명>` 형식 필수 (한 줄)**

```bash
# ✅ 필수
feat: 로그인 API 구현
fix: 타입 에러 수정
refactor: auth 모듈 리팩토링

# ❌ 금지
로그인 기능 추가  # prefix 없음
feat: 로그인 API 구현\n\nCo-Authored-By: ...  # 여러 줄
🤖 feat: 로그인  # 이모지
```

**Prefix 종류:**
- feat, fix, refactor, style, docs, test, chore, perf, ci

## 에이전트 활용

### 필수 17: 에이전트 위임

**다음 조건 시 반드시 에이전트 위임:**

- [ ] 독립적인 작업
- [ ] 새 컨텍스트 필요
- [ ] 전문 지식 필요
- [ ] 10분 이상 소요 예상

```typescript
// ✅ 필수: 적절한 에이전트 위임
Task(subagent_type="implementation-executor", model="sonnet", ...)
Task(subagent_type="designer", model="sonnet", ...)
Task(subagent_type="code-reviewer", model="opus", ...)
```

### 필수 18: 모델 선택

**에이전트 호출 시 model 파라미터 필수**

| 모델 | 사용 시점 |
|------|----------|
| haiku | 탐색, 문서, Git |
| sonnet | 구현, 수정, 분석 (기본) |
| opus | 아키텍처, 보안, 검증 |

```typescript
// ✅ 필수: model 명시
Task(subagent_type="explore", model="haiku", ...)
Task(subagent_type="planner", model="opus", ...)

// ❌ 금지: model 누락
Task(subagent_type="explore", ...)
```

## 종합 체크리스트

작업 시작 전:

- [ ] Sequential Thinking 실행 (MEDIUM 이상)
- [ ] 파일 읽기 계획 (병렬 여부)
- [ ] 에이전트 활용 계획

코드 작성 시:

- [ ] UTF-8 인코딩
- [ ] 한글 주석 (코드 블록 단위)
- [ ] TypeScript strict 모드
- [ ] Server Function 패턴 준수
- [ ] TanStack Query 사용

검증 시:

- [ ] Phase 1 → 2 → 3 → 4 순서
- [ ] /pre-deploy 전체 실행
- [ ] Planner 승인 확인

문서화:

- [ ] Ralph 세션 폴더 생성
- [ ] Phase 전환 시 업데이트
- [ ] 검증 결과 기록

Git:

- [ ] git-operator 사용
- [ ] 커밋 메시지 형식 준수

**모든 필수 항목 준수 → 품질 보장**
