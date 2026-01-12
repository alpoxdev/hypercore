# CLAUDE.md - TanStack Start

> Full-stack React Framework

<context>

**Purpose:** Work guidelines for TanStack Start framework development

**Scope:** Full-stack React application implementation

**Key Features:**
- File-based routing (TanStack Router)
- Server Functions (type-safe API)
- SSR + Streaming
- TanStack Query integration
- Middleware system
- Deployment flexibility (Vercel, Cloudflare, Nitro)

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

| Category | Forbidden Actions |
|----------|-------------------|
| **Git Commits** | AI markers (`Generated with Claude Code`, `🤖`, `Co-Authored-By:`), multi-line messages, emojis |
| **Prisma** | Auto-running `db push/migrate/generate`, unauthorized `schema.prisma` modifications |
| **API Routes** | Creating routes in `/api` path (use Server Functions instead) |
| **Server Fn** | Manual validation/auth inside handler, using `.validator()` (use `.inputValidator()` instead) |
| **Client** | Direct Server Function calls (use TanStack Query) |
| **Code Search** | Bash grep/rg/find commands (use ast-grep or dedicated tools) |

</forbidden>

---

<required>

| Task | Required Actions |
|------|-----------------|
| **Before Starting** | Read related docs (UI → design, API → tanstack-start, DB → prisma, Auth → better-auth) |
| **Code Search** | Use ast-grep (function/component/pattern search) |
| **Complex Tasks** | Sequential Thinking MCP (5+ step tasks) |
| **Large Changes** | gemini-review (3+ file changes, architecture decisions) |
| **Server Function** | POST/PUT/PATCH → `.inputValidator()` required, Auth needed → `.middleware()` required |
| **Client API** | Call Server Functions via TanStack Query (`useQuery`/`useMutation`) |
| **Custom Hook Order** | State → Global Hooks (useParams, useNavigate) → React Query → Handlers → Memo → Effect |
| **Code Writing** | UTF-8 encoding, Korean comments per code block, const function declarations |
| **Prisma** | Multi-File structure (`prisma/schema/`), Korean comments on all elements required |

</required>

---

<tech_stack>

| Tech | Version | Notes |
|------|---------|-------|
| TanStack Start | Latest | - |
| TypeScript | 5.x | strict |
| Tailwind CSS | 4.x | @theme |
| Prisma | **7.x** | `prisma-client`, output required |
| Zod | **4.x** | `z.email()`, `z.url()` |
| Better Auth | Latest | - |
| TanStack Query | 5.x | - |

</tech_stack>

---

<structure>
```
src/
├── routes/          # __root.tsx, index.tsx, $slug.tsx
│   └── [path]/
│       ├── -components/  # Page-specific (required)
│       ├── -hooks/       # Page-specific Custom Hooks (required)
│       └── -functions/   # Page-specific Server Functions (required)
├── functions/       # Shared Server Functions
├── components/ui/
├── middleware/
├── database/prisma.ts
└── lib/
```

**Required Rules:**
- Each page must have `-components/`, `-hooks/`, `-functions/` folders (regardless of line count)
- Custom Hooks **must always** be separated into `-hooks/` folder regardless of page size
- Shared functions → `@/functions/`, Route-specific → `routes/[path]/-functions/`
</structure>

---

<conventions>

Filenames: kebab-case, Routes: `__root.tsx`, `$param.tsx`
TypeScript: const declarations, explicit return types, interface (objects)/type (unions), any→unknown
Import order: external → @/ → relative → type

Prisma Multi-File:
```
prisma/schema/
├── +base.prisma   # datasource, generator
├── +enum.prisma   # enums
└── [model].prisma # per model (Korean comments!)
```

</conventions>

---

<quick_patterns>

```typescript
// Server Function (GET + Auth)
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => prisma.user.findMany())

// Server Function (POST + Validation + Auth)
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

| Principle | Value |
|-----------|-------|
| Colors | 60-30-10 (background-secondary-accent) |
| Spacing | 8px grid |
| Accessibility | WCAG AA (4.5:1+ contrast) |
| Fonts | 2-3 fonts |
| Safe Area | tailwindcss-safe-area |

</ui_ux>

---

<docs_structure>
```
docs/
├── guides/          # Getting started, conventions, patterns
├── library/         # tanstack-start/router/query, prisma, better-auth, t3-env, zod
└── design.md        # UI/UX guide
```
</docs_structure>
