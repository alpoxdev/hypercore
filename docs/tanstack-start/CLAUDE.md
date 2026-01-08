# CLAUDE.md - TanStack Start

> Full-stack React Framework

<context>

**Purpose:** TanStack Start 프레임워크 개발을 위한 작업 지침

**Scope:** Full-stack React 애플리케이션 구현

**Key Features:**
- File-based routing (TanStack Router)
- Server Functions (타입 안전 API)
- SSR + Streaming
- TanStack Query 통합
- Middleware 체계
- Deployment 유연성 (Vercel, Cloudflare, Nitro)

</context>

---

<instructions>
@../../commands/git.md
@docs/library/tanstack-start/index.md
@docs/library/tanstack-router/index.md
@docs/library/tanstack-query/index.md
@docs/library/prisma/index.md
@docs/library/better-auth/index.md
@docs/library/t3-env/index.md
@docs/library/zod/index.md
@docs/design.md
</instructions>

---

<forbidden>

| 분류 | 금지 행동 |
|------|----------|
| **Git 커밋** | AI 표시 (`Generated with Claude Code`, `🤖`, `Co-Authored-By:`), 여러 줄 메시지, 이모지 |
| **Prisma** | `db push/migrate/generate` 자동 실행, `schema.prisma` 무단 수정 |
| **API 라우터** | `/api` 경로에 라우터 생성 (Server Functions 사용) |
| **Server Fn** | handler 내부에서 수동 검증/인증, `.validator()` 사용 (`.inputValidator()` 사용) |
| **클라이언트** | Server Function 직접 호출 (TanStack Query 사용) |
| **코드 검색** | Bash의 grep/rg/find 명령어 (ast-grep 또는 전용 도구 사용) |

</forbidden>

---

<required>

| 작업 | 필수 행동 |
|------|----------|
| **작업 시작 전** | 관련 docs 읽기 (UI → design, API → tanstack-start, DB → prisma, 인증 → better-auth) |
| **코드 검색** | ast-grep 사용 (함수/컴포넌트/패턴 검색) |
| **복잡한 작업** | Sequential Thinking MCP (5+ 단계 작업) |
| **대규모 수정** | gemini-review (3+ 파일 변경, 아키텍처 결정) |
| **Server Function** | POST/PUT/PATCH → `.inputValidator()` 필수, 인증 필요 시 → `.middleware()` 필수 |
| **클라이언트 API** | TanStack Query (`useQuery`/`useMutation`)로 Server Function 호출 |
| **Custom Hook 순서** | State → Global Hooks (useParams, useNavigate) → React Query → Handlers → Memo → Effect |
| **코드 작성** | UTF-8 인코딩, 코드 묶음별 한글 주석, const 함수 선언 |
| **Prisma** | Multi-File 구조 (`prisma/schema/`), 모든 요소 한글 주석 필수 |

</required>

---

<tech_stack>

| 기술 | 버전 | 주의 |
|------|------|------|
| TanStack Start | 최신 | - |
| TypeScript | 5.x | strict |
| Tailwind CSS | 4.x | @theme |
| Prisma | **7.x** | `prisma-client`, output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` |
| Better Auth | 최신 | - |
| TanStack Query | 5.x | - |

</tech_stack>

---

<structure>
```
src/
├── routes/          # __root.tsx, index.tsx, $slug.tsx
│   └── [path]/
│       ├── -components/  # 페이지 전용
│       └── -functions/   # 페이지 전용 Server Functions
├── functions/       # 공통 Server Functions
├── components/ui/
├── middleware/
├── database/prisma.ts
└── lib/
```

공통 → `@/functions/`, 라우트 전용 → `routes/[경로]/-functions/`
</structure>

---

<conventions>

파일명: kebab-case, Routes: `__root.tsx`, `$param.tsx`
TypeScript: const 선언, 명시적 return type, interface(객체)/type(유니온), any→unknown
Import 순서: 외부 → @/ → 상대경로 → type

Prisma Multi-File:
```
prisma/schema/
├── +base.prisma   # datasource, generator
├── +enum.prisma   # enum
└── [model].prisma # 모델별 (한글 주석!)
```

</conventions>

---

<quick_patterns>

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

</quick_patterns>

---

<ui_ux>

| 원칙 | 값 |
|------|------|
| 색상 | 60-30-10 (배경-보조-강조) |
| 간격 | 8px 그리드 |
| 접근성 | WCAG AA (대비 4.5:1+) |
| 폰트 | 2-3개 |
| Safe Area | tailwindcss-safe-area |

</ui_ux>

---

<docs_structure>
```
docs/
├── guides/          # 시작하기, 규칙, 패턴
├── library/         # tanstack-start/router/query, prisma, better-auth, t3-env, zod
└── design.md        # UI/UX 가이드
```
</docs_structure>
