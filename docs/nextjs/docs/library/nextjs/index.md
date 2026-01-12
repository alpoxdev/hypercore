# Next.js - Index

> Next.js 15 App Router core concepts

<context>
@app-router.md
@server-actions.md
@route-handlers.md
@middleware.md
@caching.md
</context>

---

## Core Concepts

| Concept | Description |
|---------|-------------|
| **App Router** | File-based routing (`app/` directory) |
| **Server Components** | Default components (server rendering) |
| **Client Components** | Requires `"use client"` declaration |
| **Server Actions** | `"use server"` functions (type-safe API) |
| **Route Handlers** | REST API endpoints (`app/api/`) |

---

## Quick Start

### Create Project

```bash
npx create-next-app@latest my-app --typescript --tailwind --app
cd my-app
npm run dev
```

### Basic Page

```typescript
// app/page.tsx (Server Component - default)
export default async function HomePage() {
  const data = await fetch('https://api.example.com/data')
  const json = await data.json()

  return <div>{json.title}</div>
}
```

### Client Component

```typescript
// app/_components/counter.tsx
"use client"

import { useState } from "react"

export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

---

## File Structure

```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Home (/)
├── about/
│   └── page.tsx        # /about
├── blog/
│   ├── page.tsx        # /blog
│   └── [slug]/
│       └── page.tsx    # /blog/:slug
└── api/
    └── posts/
        └── route.ts    # API /api/posts
```

---

## Key Files

| File | Purpose |
|------|---------|
| `layout.tsx` | Shared layout (nestable) |
| `page.tsx` | Page component |
| `loading.tsx` | Loading UI (Suspense) |
| `error.tsx` | Error UI (Error Boundary) |
| `not-found.tsx` | 404 page |
| `route.ts` | API endpoint |

---

## Server vs Client Components

| Aspect | Server | Client |
|--------|--------|--------|
| Declaration | Default | `"use client"` |
| Data Fetching | ✅ async/await | ❌ (use useQuery) |
| Hooks | ❌ | ✅ useState, useEffect |
| Browser API | ❌ | ✅ window, localStorage |
| Event Handlers | ❌ | ✅ onClick, onChange |

**Rules:**
- Server Components are default → add `"use client"` only when needed
- Server Components can contain Client Components
- Client Components cannot contain Server Components (but can receive them as props)

---

## Server Actions

```typescript
// app/actions.ts
"use server"

import { z } from "zod"
import { revalidatePath } from "next/cache"

const schema = z.object({
  title: z.string().min(1),
  content: z.string(),
})

export async function createPost(formData: FormData) {
  const parsed = schema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
  })

  const post = await prisma.post.create({ data: parsed })
  revalidatePath("/posts")
  return post
}
```

---

## Route Handlers

```typescript
// app/api/posts/route.ts
import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  const posts = await prisma.post.findMany()
  return NextResponse.json(posts)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const post = await prisma.post.create({ data: body })
  return NextResponse.json(post, { status: 201 })
}
```

---

## Middleware

```typescript
// middleware.ts
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")

  if (!token) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

---

## Data Fetching

### Server Component (recommended)

```typescript
export default async function PostsPage() {
  const posts = await prisma.post.findMany() // Direct DB access
  return <PostsList posts={posts} />
}
```

### Client Component (TanStack Query)

```typescript
"use client"

import { useQuery } from "@tanstack/react-query"

export function PostsList() {
  const { data } = useQuery({
    queryKey: ["posts"],
    queryFn: () => fetch("/api/posts").then(r => r.json()),
  })

  return <ul>{data?.map(post => <li key={post.id}>{post.title}</li>)}</ul>
}
```

---

## Caching

| Function | Purpose |
|----------|---------|
| `revalidatePath("/posts")` | Invalidate specific path cache |
| `revalidateTag("posts")` | Invalidate tag-based cache |
| `unstable_cache()` | Cache function results |

```typescript
import { revalidatePath, revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })

  revalidatePath("/posts") // Invalidate /posts cache
  revalidateTag("posts")   // Invalidate "posts" tag cache

  return post
}
```

---

## Environment Variables

```bash
# .env.local
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="..."
NEXTAUTH_URL="http://localhost:3000"
NEXT_PUBLIC_API_URL="https://api.example.com"
```

**Rules:**
- `NEXT_PUBLIC_*`: Accessible in client
- Others: Server-only

---

## Deployment

### Vercel (recommended)

```bash
npm i -g vercel
vercel
```

### Docker

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

### Node.js

```bash
npm run build
npm start
```

---

## References

- [App Router](app-router.md)
- [Server Actions](server-actions.md)
- [Route Handlers](route-handlers.md)
- [Middleware](middleware.md)
- [Caching](caching.md)
