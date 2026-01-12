# CLAUDE.md - Next.js

> React Full-stack Framework

<context>

**Purpose:** Next.js App Router-based web application development guidelines

**Scope:** Full-stack React application implementation

**Key Features:**
- App Router (file-based routing)
- Server Actions (type-safe API)
- Server/Client Components
- Route Handlers (REST API)
- Middleware
- Built-in Optimization (images, fonts, scripts)
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

| Category | Forbidden Actions |
|----------|-------------------|
| **Git Commits** | AI markers (`Generated with Claude Code`, `🤖`, `Co-Authored-By:`), multi-line messages, emojis |
| **Prisma** | Auto-running `db push/migrate/generate`, unauthorized `schema.prisma` modifications |
| **Server Actions** | Direct definition in client components, usage without try-catch, missing Zod validation (POST/PUT/PATCH) |
| **Route Handlers** | Creation outside `/app/api/`, creation when Server Actions are suitable |
| **Client** | Direct Server Action calls (use TanStack Query), missing `"use client"` |
| **Code Search** | Bash grep/rg/find commands (use ast-grep or dedicated tools) |

</forbidden>

---

<required>

| Task | Required Actions |
|------|------------------|
| **Before Starting** | Read relevant docs (UI → design, API → nextjs, DB → prisma, auth → next-auth) |
| **Code Search** | Use ast-grep (function/component/pattern search) |
| **Complex Tasks** | Sequential Thinking MCP (5+ step tasks) |
| **Large Changes** | gemini-review (3+ file changes, architectural decisions) |
| **Server Actions** | `"use server"` declaration, Zod validation (POST/PUT/PATCH), try-catch + revalidatePath/redirect |
| **Client API** | Call Server Actions via TanStack Query (`useQuery`/`useMutation`) |
| **Custom Hook Order** | State → Global Hooks (useParams, useRouter, useSearchParams) → React Query → Handlers → Memo → Effect |
| **Code Writing** | UTF-8 encoding, comments per code block, const function declarations |
| **Prisma** | Multi-File structure (`prisma/schema/`), all elements require comments |

</required>

---

<tech_stack>

| Technology | Version | Note |
|------------|---------|------|
| Next.js | **15.x** | App Router only |
| React | **19.x** | Server Components |
| TypeScript | 5.x | strict |
| Tailwind CSS | 4.x | @theme |
| Prisma | **7.x** | `prisma-client`, output required |
| Zod | **4.x** | `z.email()`, `z.url()` |
| NextAuth.js | **5.x** (Auth.js) | App Router support |
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
│   │   └── -components/        # Page-specific Client Components
│   ├── api/
│   │   └── [endpoint]/
│   │       └── route.ts        # Route Handler (REST API)
│   └── _components/            # Shared Client Components
├── actions/                    # Server Actions (shared)
├── components/ui/              # UI components (Server Components)
├── middleware.ts               # Middleware
├── database/prisma.ts
└── lib/
```

**Required Rules:**
- Recommended `-components/` folder per page (page-specific Client Components)
- Server Components by default → use `"use client"` only when necessary
- Server Actions in `actions/` folder or at file top (`"use server"`)
- Route Handlers only in `/app/api/` path
</structure>

---

<conventions>

File names: kebab-case, Routes: `page.tsx`, `layout.tsx`, `[slug]/page.tsx`
TypeScript: const declarations, explicit return types, interface (objects)/type (unions), any→unknown
Import order: external → @/ → relative → type

Prisma Multi-File:
```
prisma/schema/
├── +base.prisma   # datasource, generator
├── +enum.prisma   # enum
└── [model].prisma # per model (with comments!)
```

</conventions>

---

<quick_patterns>

```typescript
// Server Action (file top)
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

// Server Action (with auth)
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

| Principle | Value |
|-----------|-------|
| Color | 60-30-10 (background-secondary-accent) |
| Spacing | 8px grid |
| Accessibility | WCAG AA (contrast 4.5:1+) |
| Fonts | 2-3 types |
| Safe Area | tailwindcss-safe-area |

</ui_ux>

---

<docs_structure>
```
docs/
├── guides/          # Getting started, conventions, patterns
├── library/         # nextjs, prisma, next-auth, tanstack-query, zod
└── design.md        # UI/UX guide
```
</docs_structure>
