# CLAUDE.md - Claude Code Instructions

> TanStack Start + React 프로젝트 작업 지침

---

## 🚨 STOP - 작업 전 필수 확인

```
┌─────────────────────────────────────────────────────────────┐
│  이 프로젝트에서 작업하기 전에 이 문서를 끝까지 읽으세요.  │
│  특히 ⛔ NEVER DO 섹션의 규칙은 절대 위반하지 마세요.      │
│                                                             │
│  📖 작업 유형별 상세 문서: docs/ 폴더 참조                  │
└─────────────────────────────────────────────────────────────┘
```

---

## ⛔ NEVER DO (절대 금지 - 예외 없음)

### Git 커밋 금지 사항
```
❌ "Generated with Claude Code" 포함 금지
❌ "🤖" 또는 AI 관련 이모지 포함 금지
❌ "Co-Authored-By:" 헤더 포함 금지
❌ AI/봇이 작성했다는 어떤 표시도 금지
❌ 커밋 메시지 여러 줄 작성 금지
❌ 커밋 메시지에 이모지 사용 금지
```

### Prisma 금지 사항
```
❌ prisma db push 자동 실행 금지
❌ prisma migrate 자동 실행 금지
❌ prisma generate 자동 실행 금지
❌ schema.prisma 임의 변경 금지 (요청된 것만)
```

### API 구현 금지 사항
```
❌ /api 라우터에 함수 생성 금지 (사용자 명시 요청 제외)
❌ Server Function에 inputValidator 누락 금지 (POST/PUT/PATCH)
❌ Server Function에 middleware 누락 금지 (인증 필요 시)
❌ handler 내부에서 수동 검증 금지 (inputValidator 사용)
❌ handler 내부에서 수동 인증 체크 금지 (middleware 사용)
❌ 클라이언트에서 Server Function 직접 호출 금지 → TanStack Query 필수
```

### 코드 검색 금지 사항
```
❌ grep, rg 등 기본 검색 도구 사용 금지
❌ find 명령어로 코드 검색 금지
✅ 코드베이스 검색 시 sgrep 사용 필수
```

### Custom Hook 순서 금지 사항
```
❌ Custom Hook 내부 순서 무시 금지
✅ 반드시 아래 순서 준수:
   1. State (useState, zustand store)
   2. Global Hooks (useParams, useNavigate, useQueryClient 등)
   3. React Query (useQuery → useMutation 순서)
   4. Event Handlers & Functions
   5. useMemo
   6. useEffect
```

### 코드 작성 규칙
```
✅ 모든 한글 텍스트는 UTF-8 인코딩 유지
✅ 코드 묶음 단위로 한글 주석 작성 (너무 세세하게 X)
✅ Prisma Multi-File 모든 요소에 한글 주석 필수
```

### Prisma Multi-File 구조 (필수)
```
prisma/
├── schema/
│   ├── +base.prisma      # datasource, generator 설정
│   ├── +enum.prisma      # 모든 enum 정의
│   ├── user.prisma       # User 모델
│   ├── post.prisma       # Post 모델
│   └── ...               # 기타 모델별 파일
```

---

## ✅ ALWAYS DO (필수 실행)

### 1. 작업 전: 관련 문서 읽기
```
UI 작업      → docs/design/ 읽기
API 작업     → docs/library/tanstack-start/ 읽기
DB 작업      → docs/library/prisma/ 읽기
인증 작업    → docs/library/better-auth/ 읽기
```

### 2. MCP 도구 적극 활용
```
코드베이스 검색     → sgrep 사용 (grep/rg 금지)
복잡한 분석/디버깅  → Sequential Thinking 사용
라이브러리 문서     → Context7 사용
```
**상세**: `docs/mcp/` 참고

### 3. 복잡한 작업 시: Gemini Review 실행
```
아키텍처 설계/변경  → gemini-review (architecture)
구현 계획 검증      → gemini-review (plan)
복잡한 코드 리뷰    → gemini-review (code)
```

**실행 조건**:
- 3개 이상 파일 수정하는 기능 구현
- 새로운 아키텍처 패턴 도입
- 보안 관련 코드 (인증, 권한, 암호화)
- 성능 크리티컬 코드

**상세**: `docs/skills/gemini-review/SKILL.md` 참고

### 4. 작업 완료 후: Git 커밋
```bash
git add .
git commit -m "<prefix>: <설명>"
```

**커밋 형식**: `<prefix>: <설명>` (한 줄, 본문 없음)

**Prefix**: `feat` | `fix` | `refactor` | `style` | `docs` | `test` | `chore` | `perf` | `ci`

**예시**:
```bash
feat: 사용자 로그인 기능 추가
fix: 세션 만료 오류 수정
docs: API 문서 업데이트
```

---

## 📚 문서 참조 테이블

| 작업 | 문서 경로 | 필독 여부 |
|------|----------|----------|
| **전체 가이드** | `docs/README.md` | 🔴 필수 |
| **Git 규칙** | `docs/git/git.md` | 🔴 필수 |
| **MCP 도구** | `docs/mcp/` | 🔴 필수 |
| **Gemini Review** | `docs/skills/gemini-review/` | 🟡 복잡한 작업 시 |
| **UI 개발** | `docs/design/` | 🟡 해당 시 |
| **API 개발** | `docs/library/tanstack-start/` | 🟡 해당 시 |
| **인증** | `docs/library/better-auth/` | 🟡 해당 시 |
| **DB** | `docs/library/prisma/` | 🟡 해당 시 |
| **데이터 페칭** | `docs/library/tanstack-query/` | 🟡 해당 시 |
| **검증** | `docs/library/zod/` | 🟡 해당 시 |
| **배포** | `docs/deployment/` | 🟡 해당 시 |

---

## 🛠 Tech Stack (버전 주의)

| 기술 | 버전 | 주의사항 |
|------|------|----------|
| TanStack Start | 최신 | Framework |
| TypeScript | 5.x | strict mode |
| Tailwind CSS | 4.x | `@theme` 사용 |
| Prisma | **7.x** | `prisma-client` (js 아님), output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` (string().email() 아님) |
| Better Auth | 최신 | 인증 |
| TanStack Query | 5.x | 데이터 페칭 |

---

## 📁 Directory Structure

```
src/
├── routes/                   # File-based routes
│   ├── __root.tsx            # Root layout
│   ├── index.tsx             # / (Home)
│   ├── $slug.tsx             # Dynamic route
│   └── users/
│       ├── index.tsx         # /users
│       ├── -components/      # 페이지 전용 컴포넌트
│       ├── -hooks/           # 페이지 전용 훅
│       └── -functions/       # 페이지 전용 Server Functions ⭐
├── functions/                # 공통 Server Functions ⭐
│   ├── auth.ts               # 인증 관련
│   └── user.ts               # 사용자 관련
├── components/ui/            # 공통 UI 컴포넌트
├── middleware/               # 공통 미들웨어
│   └── auth.ts               # Better Auth 미들웨어
├── database/prisma.ts        # Prisma Client
└── lib/                      # 유틸리티
```

### Server Functions 위치 규칙 ⭐
```
공통 함수 (여러 라우트에서 사용)  → @/functions/
라우트 전용 함수 (해당 라우트만)  → routes/[경로]/-functions/
```

**`-` prefix**: 라우트에서 제외되는 폴더

---

## 🔧 Code Conventions

### File Naming
- **kebab-case**: `user-profile.tsx`, `auth-service.ts`
- **Routes**: `__root.tsx`, `$param.tsx`

### TypeScript
- `const` 선언 사용 (function 대신)
- 명시적 return type
- `interface` (객체) / `type` (유니온)
- `any` 금지 → `unknown` 사용

### Import
```typescript
// @/* → ./src/*
import { prisma } from '@/database/prisma'
import { getUsers } from '@/services/user'
```

**순서**: 외부 → 내부(@/) → 상대경로 → type imports

---

## 📝 Quick Patterns (복사용)

### Server Function (GET + 인증)
```typescript
// ✅ 올바른 패턴: middleware 사용
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])  // ⭐ 인증 미들웨어 필수
  .handler(async () => prisma.user.findMany())
```

### Server Function (POST + Validation + 인증)
```typescript
// ✅ 올바른 패턴: inputValidator + middleware 모두 사용
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])        // ⭐ 인증 미들웨어 필수
  .inputValidator(createUserSchema)    // ⭐ Zod 스키마 필수
  .handler(async ({ data }) => prisma.user.create({ data }))
```

### ❌ 잘못된 패턴 (금지)
```typescript
// ❌ handler 내부에서 수동 검증 금지
export const createUser = createServerFn({ method: 'POST' })
  .handler(async ({ data }) => {
    // ❌ 이렇게 하지 마세요!
    if (!data.email) throw new Error('Email required')
    const session = await getSession()  // ❌ 수동 인증 체크 금지
    // ...
  })
```

### Zod Schema (v4 문법!)
```typescript
const schema = z.object({
  email: z.email(),           // ✅ v4
  name: z.string().min(1).trim(),
  website: z.url().optional(), // ✅ v4
})
```

### Route with Loader
```tsx
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() }),
})
```

### TanStack Query (서버 연동 시 필수)
```tsx
// ✅ 데이터 조회: useQuery 필수
const { data } = useQuery({
  queryKey: ['posts'],
  queryFn: () => getServerPosts(),
})

// ✅ 데이터 변경: useMutation 필수
const mutation = useMutation({
  mutationFn: createPost,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['posts'] }),
})

// ❌ 금지: Server Function을 TanStack Query 없이 직접 호출
// useEffect(() => { getServerPosts().then(setData) }, [])
```

---

## 🎨 UI/UX Rules

- **색상**: 60-30-10 규칙 (배경-보조-강조)
- **간격**: 8px 그리드 (8의 배수)
- **접근성**: WCAG AA (대비 4.5:1+)
- **폰트**: 최대 2-3개
- **Safe Area**: `tailwindcss-safe-area` 사용

**상세**: `docs/design/` 참고

---

## 🔗 Quick Links

- [문서 가이드](./docs/README.md)
- [Git 규칙](./docs/git/git.md)
- [MCP 가이드](./docs/mcp/index.md)
- [디자인 가이드](./docs/design/index.md)
- [아키텍처](./docs/architecture/architecture.md)
