# Routes

> Next.js App Router routing patterns

---

## Basic Routing

| File | Route |
|------|-------|
| `app/page.tsx` | `/` |
| `app/about/page.tsx` | `/about` |
| `app/blog/page.tsx` | `/blog` |
| `app/blog/[slug]/page.tsx` | `/blog/:slug` |

---

## Dynamic Routes

### Single Parameter

```typescript
// app/posts/[id]/page.tsx
interface PageProps {
  params: { id: string }
}

export default async function PostPage({ params }: PageProps) {
  const post = await prisma.post.findUnique({ where: { id: params.id } })

  if (!post) notFound()

  return <article>{post.title}</article>
}

// Static generation
export async function generateStaticParams() {
  const posts = await prisma.post.findMany({ select: { id: true } })
  return posts.map(post => ({ id: post.id }))
}
```

### Catch-all

```typescript
// app/docs/[...slug]/page.tsx
interface PageProps {
  params: { slug: string[] }
}

export default function DocsPage({ params }: PageProps) {
  // /docs/a/b/c → params.slug = ["a", "b", "c"]
  const path = params.slug.join("/")
  return <div>{path}</div>
}
```

---

## Layouts

### Root Layout (required)

```typescript
// app/layout.tsx
import { Providers } from "./providers"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

### Nested Layout

```typescript
// app/dashboard/layout.tsx
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  // Auth check
  const session = await auth.api.getSession({ headers: headers() })
  if (!session?.user) redirect("/login")

  return (
    <div>
      <nav>Dashboard Nav</nav>
      <main>{children}</main>
    </div>
  )
}
```

---

## Route Groups

```
app/
├── (marketing)/
│   ├── layout.tsx      # Marketing layout
│   ├── page.tsx        # /
│   └── about/
│       └── page.tsx    # /about
└── (shop)/
    ├── layout.tsx      # Shop layout
    └── products/
        └── page.tsx    # /products
```

**Purpose:** Apply different layouts without affecting URLs

---

## Loading & Error

### Loading UI

```typescript
// app/posts/loading.tsx
export default function Loading() {
  return <div>Loading posts...</div>
}
```

### Error UI

```typescript
// app/posts/error.tsx
"use client"

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>Error: {error.message}</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

### Not Found

```typescript
// app/posts/[id]/not-found.tsx
export default function NotFound() {
  return <div>Post not found</div>
}
```

---

## Metadata

### Static

```typescript
// app/about/page.tsx
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "About Us",
  description: "Learn more about our company",
}

export default function AboutPage() {
  return <div>About</div>
}
```

### Dynamic

```typescript
// app/posts/[id]/page.tsx
import type { Metadata } from "next"

export async function generateMetadata({ params }: { params: { id: string } }): Promise<Metadata> {
  const post = await prisma.post.findUnique({ where: { id: params.id } })

  if (!post) {
    return {
      title: "Post Not Found",
    }
  }

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.image],
    },
  }
}
```

---

## Navigation

### Link

```typescript
import Link from "next/link"

export function Navigation() {
  return (
    <nav>
      <Link href="/">Home</Link>
      <Link href="/about">About</Link>
      <Link href="/posts">Posts</Link>
    </nav>
  )
}
```

### useRouter

```typescript
"use client"

import { useRouter } from "next/navigation"

export function LoginButton() {
  const router = useRouter()

  return (
    <button onClick={() => router.push("/login")}>
      Login
    </button>
  )
}
```

---

## Auth Protection

### Check in Layout

```typescript
// app/dashboard/layout.tsx
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const session = await auth.api.getSession({ headers: headers() })

  if (!session?.user) {
    redirect("/login")
  }

  return <div>{children}</div>
}
```

### Check in Middleware

```typescript
// middleware.ts
import { auth } from "@/lib/auth"
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({ headers: request.headers })

  if (!session?.user) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

---

## Best Practices

### ✅ DO

```typescript
// 1. Direct data fetching in Server Components
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}

// 2. Auth check in layout
export default async function DashboardLayout({ children }) {
  const session = await auth.api.getSession({ headers: headers() })
  if (!session?.user) redirect("/login")
  return <div>{children}</div>
}

// 3. Static generation with generateStaticParams
export async function generateStaticParams() {
  const posts = await prisma.post.findMany({ select: { id: true } })
  return posts.map(post => ({ id: post.id }))
}
```

### ❌ DON'T

```typescript
// 1. async/await in Client Components
"use client"
export default async function PostsPage() { // ❌
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}

// 2. Repeated auth checks per page
export default async function Page1() {
  const session = await auth.api.getSession({ headers: headers() }) // ❌ Duplicate
  if (!session) redirect("/login")
}

// 3. Hardcoded paths
<Link href="/posts/123">Post</Link> // ❌ Hardcoded
```

---

## References

- [App Router](../library/nextjs/app-router.md)
- [Server Actions](server-actions.md)
- [Client Components](client-components.md)
