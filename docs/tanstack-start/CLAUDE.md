# CLAUDE.md - TanStack Start + React 작업 지침

## Instructions
@../../commands/git.md
@docs/library/tanstack-start/index.md
@docs/library/prisma/index.md
@docs/library/better-auth/index.md
@docs/library/tanstack-query/index.md
@docs/library/zod/index.md
@docs/design/index.md

---

## ⛔ NEVER DO

### Git 커밋
- AI 표시 금지: "Generated with Claude Code", "🤖", "Co-Authored-By:" 포함 불가
- 커밋 메시지: 한 줄만, 이모지 금지

### Prisma
- 자동 실행 금지: `prisma db push/migrate/generate`
- `schema.prisma` 임의 변경 금지

### API 구현
- `/api` 라우터 생성 금지 (명시 요청 제외)
- Server Function: POST/PUT/PATCH → `inputValidator` 필수, 인증 필요 시 → `middleware` 필수
- handler 내부에서 수동 검증/인증 체크 금지
- 클라이언트에서 Server Function 직접 호출 금지 → TanStack Query 필수

### 코드 검색
- `grep`/`rg`/`find` 금지 → `sgrep` 사용

### Custom Hook 순서
1. State (useState, zustand)
2. Global Hooks (useParams, useNavigate, useQueryClient)
3. React Query (useQuery → useMutation)
4. Event Handlers
5. useMemo
6. useEffect

### 코드 작성
- UTF-8 인코딩, 코드 묶음 단위 한글 주석
- Prisma Multi-File: 모든 요소에 한글 주석 필수

### Prisma Multi-File 구조
```
prisma/schema/
├── +base.prisma   # datasource, generator
├── +enum.prisma   # 모든 enum
└── [model].prisma # 모델별 파일
```

---

## ✅ ALWAYS DO

### 작업 전 문서 읽기
| 작업 | 문서 |
|------|------|
| UI | docs/design/ |
| API | docs/library/tanstack-start/ |
| DB | docs/library/prisma/ |
| 인증 | docs/library/better-auth/ |

### MCP 도구
- 코드 검색: sgrep
- 분석/디버깅: Sequential Thinking
- 라이브러리 문서: Context7

### Gemini Review (3개+ 파일 수정, 아키텍처 변경, 보안/성능 코드)
- architecture/plan/code 타입 선택

### Git 커밋
`<prefix>: <설명>` (한 줄)
- prefix: feat|fix|refactor|style|docs|test|chore|perf|ci

---

## Tech Stack

| 기술 | 버전 | 주의 |
|------|------|------|
| TanStack Start | 최신 | - |
| TypeScript | 5.x | strict |
| Tailwind CSS | 4.x | @theme |
| Prisma | **7.x** | `prisma-client`, output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` |
| Better Auth | 최신 | - |
| TanStack Query | 5.x | - |

---

## Directory Structure
```
src/
├── routes/             # File-based routes
│   ├── __root.tsx
│   ├── index.tsx
│   ├── $slug.tsx
│   └── [path]/
│       ├── -components/ # 페이지 전용
│       ├── -hooks/
│       └── -functions/  # 페이지 전용 Server Functions
├── functions/          # 공통 Server Functions
├── components/ui/
├── middleware/
├── database/prisma.ts
└── lib/
```
- 공통 함수 → `@/functions/`, 라우트 전용 → `routes/[경로]/-functions/`

---

## Code Conventions
- 파일명: kebab-case, Routes: `__root.tsx`, `$param.tsx`
- TypeScript: const 선언, 명시적 return type, interface(객체)/type(유니온), any 금지→unknown
- Import 순서: 외부 → @/ → 상대경로 → type

---

## Quick Patterns

```typescript
// Server Function (GET + 인증)
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())

// Server Function (POST + Validation + 인증)
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// Zod v4
const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional(),
})

// Route with Loader
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() }),
})

// TanStack Query
const { data } = useQuery({ queryKey: ['posts'], queryFn: getServerPosts })
const mutation = useMutation({
  mutationFn: createPost,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['posts'] }),
})
```

---

## UI/UX
- 색상: 60-30-10 (배경-보조-강조)
- 간격: 8px 그리드
- 접근성: WCAG AA (대비 4.5:1+)
- 폰트: 2-3개
- Safe Area: tailwindcss-safe-area
