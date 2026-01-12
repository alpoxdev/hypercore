# Conventions

> Code writing rules

---

## File Names

| Type | Rule | Example |
|------|------|---------|
| Component | kebab-case | `user-profile.tsx` |
| Route | Next.js convention | `page.tsx`, `layout.tsx`, `[id]/page.tsx` |
| Server Actions | kebab-case | `create-post.ts`, `posts.ts` |
| Utilities | kebab-case | `format-date.ts` |

---

## TypeScript

### Variable Declaration

```typescript
// ✅ Prefer const
const user = { name: "Alice" }
const posts = await prisma.post.findMany()

// ❌ Minimize let
let count = 0 // Only when mutation needed
```

### Function Declaration

```typescript
// ✅ const arrow function + explicit return type
const getUser = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// ❌ function keyword (except export default)
function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } })
}
```

### Type Definition

```typescript
// ✅ interface (objects)
interface User {
  id: string
  name: string
  email: string
}

// ✅ type (unions, others)
type Status = "active" | "inactive"
type UserOrNull = User | null

// ❌ No any → use unknown
const data: unknown = JSON.parse(jsonString)
```

---

## Import Order

```typescript
// 1. External libraries
import { useState } from "react"
import { useQuery } from "@tanstack/react-query"

// 2. @/ alias
import { Button } from "@/components/ui/button"
import { prisma } from "@/database/prisma"

// 3. Relative paths
import { UserProfile } from "./-components/user-profile"

// 4. Types (separate)
import type { User } from "@/types"
```

---

## Components

### Server Component (default)

```typescript
// ✅ async function + direct data fetching
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

### Client Component

```typescript
// ✅ "use client" + interactivity
"use client"

import { useState } from "react"

export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

---

## Server Actions

### File Top

```typescript
// ✅ "use server" + multiple functions
"use server"

export async function createPost(formData: FormData) {
  // ...
}

export async function deletePost(id: string) {
  // ...
}
```

### Zod Validation

```typescript
"use server"

import { z } from "zod"

const schema = z.object({
  title: z.string().min(1),
  content: z.string(),
})

export async function createPost(formData: FormData) {
  const parsed = schema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
  })

  // ...
}
```

---

## Comments

```typescript
// ✅ Comments per code block
// Check user authentication
const session = await auth.api.getSession({ headers: headers() })
if (!session?.user) redirect("/login")

// Fetch posts
const posts = await prisma.post.findMany({
  where: { userId: session.user.id },
  orderBy: { createdAt: "desc" },
})

// ❌ Comments on every line
const session = await auth.api.getSession({ headers: headers() }) // Get session
if (!session?.user) redirect("/login") // Redirect to login
```

---

## Prisma

### Multi-File Structure

```
prisma/schema/
├── +base.prisma    # datasource, generator
├── +enum.prisma    # all enums
└── user.prisma     # User model
```

### Required Comments

```prisma
/// User
model User {
  id        String   @id @default(cuid())  /// Unique ID
  email     String   @unique                /// Email (unique)
  name      String?                         /// Name (optional)
  role      Role     @default(USER)         /// Role
  createdAt DateTime @default(now())        /// Created at
  updatedAt DateTime @updatedAt             /// Updated at
}

/// Role
enum Role {
  USER   /// Regular user
  ADMIN  /// Administrator
}
```

---

## Folder Structure

```
app/
├── (auth)/              # Route Group
│   ├── login/
│   │   └── page.tsx
│   └── signup/
│       └── page.tsx
├── dashboard/
│   ├── page.tsx
│   ├── -components/     # Page-specific (required)
│   │   ├── stats.tsx
│   │   └── chart.tsx
│   └── settings/
│       └── page.tsx
└── _components/         # Shared Client Components
```

**Rules:**
- `-components/` - Page-specific (cannot import from outside)
- `_components/` - Shared (not included in routes)

---

## Custom Hook Order

```typescript
"use client"

export function useExample() {
  // 1. State (useState, zustand)
  const [count, setCount] = useState(0)

  // 2. Global Hooks
  const router = useRouter()
  const params = useParams()
  const searchParams = useSearchParams()

  // 3. React Query
  const { data: posts } = useQuery({ queryKey: ["posts"], queryFn: getPosts })
  const mutation = useMutation({ mutationFn: createPost })

  // 4. Event Handlers
  const handleClick = () => {
    setCount(count + 1)
  }

  // 5. useMemo
  const total = useMemo(() => posts?.length || 0, [posts])

  // 6. useEffect
  useEffect(() => {
    console.log(count)
  }, [count])

  return { count, handleClick, total }
}
```

---

## Best Practices

### ✅ DO

```typescript
// 1. Explicit types
const getUser = async (id: string): Promise<User> => { /* ... */ }

// 2. Zod validation
const schema = z.object({ email: z.email() })
const parsed = schema.parse(data)

// 3. Error handling
try {
  await prisma.post.create({ data })
} catch (error) {
  console.error("Error creating post:", error)
  throw error
}

// 4. revalidatePath
await prisma.post.create({ data })
revalidatePath("/posts")
```

### ❌ DON'T

```typescript
// 1. Using any
const data: any = await fetchData() // ❌

// 2. Missing validation
const email = formData.get("email") // ❌ Need Zod validation
await createUser({ email })

// 3. Ignoring errors
await prisma.post.create({ data }) // ❌ Need try-catch

// 4. Missing cache invalidation
await prisma.post.create({ data }) // ❌ Need revalidatePath
```

---

## Git Commits

```bash
# ✅ Single line, with prefix
git commit -m "feat: add post creation feature"
git commit -m "fix: resolve login bug"

# ❌ Multiple lines, emojis, AI markers
git commit -m "feat: add post creation feature

Detailed description...

Co-Authored-By: Claude Code <noreply@anthropic.com>"  # ❌
```

**Prefixes:**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Refactoring
- `style` - Code style
- `docs` - Documentation
- `test` - Tests
- `chore` - Others

---

## References

- [Next.js Official Docs](https://nextjs.org/docs)
- [TypeScript Official Docs](https://www.typescriptlang.org/)
