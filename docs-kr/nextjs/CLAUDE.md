# CLAUDE.md - Next.js

> React Full-stack Framework

<context>

**Purpose:** Next.js App Router 기반 웹 애플리케이션 개발 지침

**Scope:** Full-stack React 애플리케이션 구현

**Key Features:**
- App Router (file-based routing)
- Server Actions (타입 안전 API)
- Server/Client Components
- Route Handlers (REST API)
- Middleware
- Built-in Optimization (이미지, 폰트, 스크립트)
- Deployment (Vercel, Docker, Node.js)

</context>

---

<instructions>
@../../commands/git.md
@docs/library/nextjs/index.md
@docs/library/tanstack-query/index.md
@docs/library/prisma/index.md
@docs/library/next-auth/index.md
@docs/library/zod/index.md
@docs/design.md
</instructions>

---

<forbidden>

| 분류 | 금지 행동 |
|------|----------|
| **Git 커밋** | AI 표시 (`Generated with Claude Code`, `🤖`, `Co-Authored-By:`), 여러 줄 메시지, 이모지 |
| **Prisma** | `db push/migrate/generate` 자동 실행, `schema.prisma` 무단 수정 |
| **Server Actions** | 클라이언트 컴포넌트에서 직접 정의, try-catch 없이 사용, Zod 검증 누락 (POST/PUT/PATCH) |
| **Route Handlers** | `/app/api/` 외부에 생성, Server Actions로 대체 가능한 경우 생성 |
| **클라이언트** | Server Action 직접 호출 (TanStack Query 사용), `"use client"` 누락 |
| **코드 검색** | Bash의 grep/rg/find 명령어 (ast-grep 또는 전용 도구 사용) |

</forbidden>

---

<required>

| 작업 | 필수 행동 |
|------|----------|
| **작업 시작 전** | 관련 docs 읽기 (UI → design, API → nextjs, DB → prisma, 인증 → next-auth) |
| **코드 검색** | ast-grep 사용 (함수/컴포넌트/패턴 검색) |
| **복잡한 작업** | Sequential Thinking MCP (5+ 단계 작업) |
| **대규모 수정** | gemini-review (3+ 파일 변경, 아키텍처 결정) |
| **Server Actions** | `"use server"` 선언, Zod 검증 (POST/PUT/PATCH), try-catch + revalidatePath/redirect |
| **클라이언트 API** | TanStack Query (`useQuery`/`useMutation`)로 Server Action 호출 |
| **Custom Hook 순서** | State → Global Hooks (useParams, useRouter, useSearchParams) → React Query → Handlers → Memo → Effect |
| **코드 작성** | UTF-8 인코딩, 코드 묶음별 한글 주석, const 함수 선언 |
| **Prisma** | Multi-File 구조 (`prisma/schema/`), 모든 요소 한글 주석 필수 |

</required>

---

<tech_stack>

| 기술 | 버전 | 주의 |
|------|------|------|
| Next.js | **15.x** | App Router 전용 |
| React | **19.x** | Server Components |
| TypeScript | 5.x | strict |
| Tailwind CSS | 4.x | @theme |
| Prisma | **7.x** | `prisma-client`, output 필수 |
| Zod | **4.x** | `z.email()`, `z.url()` |
| NextAuth.js | **5.x** (Auth.js) | App Router 지원 |
| TanStack Query | 5.x | - |

</tech_stack>

---

<structure>
```
src/
├── app/
│   ├── layout.tsx              # Root layout (required)
│   ├── page.tsx                # Home page
│   ├── [slug]/
│   │   ├── page.tsx            # Dynamic route
│   │   ├── _components/        # 페이지 전용 컴포넌트 (필수)
│   │   ├── _hooks/             # 페이지 전용 훅 (필수)
│   │   └── _actions/           # 페이지 전용 Server Actions (필수)
│   ├── api/
│   │   └── [endpoint]/
│   │       └── route.ts        # Route Handler (REST API)
│   └── _actions/               # 공통 Server Actions
├── components/ui/              # 공통 UI 컴포넌트 (Server Components)
├── middleware.ts               # Middleware
├── database/prisma.ts
└── lib/
```

**필수 규칙:**
- 페이지당 `_components/`, `_hooks/`, `_actions/` 폴더 필수 (줄 수 무관)
- Custom Hook은 페이지 크기와 무관하게 **반드시** `_hooks/` 폴더에 분리
- Server Components가 기본 → `"use client"` 명시 필요 시만 사용
- Server Actions는 글로벌(`app/_actions/`) 또는 페이지 전용(`[route]/_actions/`)에 분리
- Route Handlers는 `/app/api/` 경로에만 생성
</structure>

---

<conventions>

파일명: kebab-case, Routes: `page.tsx`, `layout.tsx`, `[slug]/page.tsx`
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
// Server Action (파일 상단)
"use server"

export async function createPost(formData: FormData) {
  const parsed = createPostSchema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
  })

  const post = await prisma.post.create({ data: parsed })
  revalidatePath("/posts")
  return post
}

// Server Action (인증)
"use server"

import { auth } from "@/lib/auth"

export async function deletePost(id: string) {
  const session = await auth()
  if (!session?.user) throw new Error("Unauthorized")

  await prisma.post.delete({ where: { id } })
  revalidatePath("/posts")
}

// Route Handler (GET)
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const id = searchParams.get("id")

  const posts = await prisma.post.findMany({ where: { id } })
  return Response.json(posts)
}

// Client Component with TanStack Query
"use client"

import { useMutation, useQueryClient } from "@tanstack/react-query"
import { createPost } from "@/actions/posts"

export function CreatePostForm() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createPost,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["posts"] }),
  })

  return <form action={mutation.mutate}>...</form>
}

// Zod v4
const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
  website: z.url().optional(),
})

// Page with Server Component
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
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
├── library/         # nextjs, prisma, next-auth, tanstack-query, zod
└── design.md        # UI/UX 가이드
```
</docs_structure>
