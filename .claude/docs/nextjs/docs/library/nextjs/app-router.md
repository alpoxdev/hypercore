# App Router

> File-based routing system

---

## File Structure and Routing

### Basic Rules

| File | Route | Description |
|------|-------|-------------|
| `app/page.tsx` | `/` | Home page |
| `app/about/page.tsx` | `/about` | About page |
| `app/blog/[slug]/page.tsx` | `/blog/:slug` | Dynamic route |
| `app/shop/[...slug]/page.tsx` | `/shop/*` | Catch-all |
| `app/docs/[[...slug]]/page.tsx` | `/docs/*` | Optional catch-all |

### Example

```typescript
// app/blog/[slug]/page.tsx
interface PageProps {
  params: { slug: string }
  searchParams: { [key: string]: string | string[] | undefined }
}

export default async function BlogPost({ params, searchParams }: PageProps) {
  const post = await prisma.post.findUnique({ where: { slug: params.slug } })

  if (!post) notFound()

  return <article>{post.content}</article>
}
```

---

## Layouts

### Root Layout (required)

```typescript
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
```

### Nested Layout

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <nav>Dashboard Nav</nav>
      <main>{children}</main>
    </div>
  )
}
```

**Features:**
- Nestable (parent → child order)
- Persists without re-rendering
- Receives `children` as props

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

**Purpose:**
- Group folders without affecting URLs
- Apply different layouts

---

## Dynamic Routes

### Single Parameter

```typescript
// app/posts/[id]/page.tsx
export default async function PostPage({ params }: { params: { id: string } }) {
  const post = await prisma.post.findUnique({ where: { id: params.id } })
  return <article>{post.title}</article>
}

// Static generation (at build time)
export async function generateStaticParams() {
  const posts = await prisma.post.findMany()
  return posts.map(post => ({ id: post.id }))
}
```

### Catch-all

```typescript
// app/docs/[...slug]/page.tsx
export default function DocsPage({ params }: { params: { slug: string[] } }) {
  // /docs/a/b/c → params.slug = ["a", "b", "c"]
  return <div>{params.slug.join("/")}</div>
}
```

---

## Parallel Routes

```
app/
├── @analytics/
│   └── page.tsx
├── @team/
│   └── page.tsx
└── layout.tsx
```

```typescript
// app/layout.tsx
export default function Layout({
  children,
  analytics,
  team,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  team: React.ReactNode
}) {
  return (
    <>
      {children}
      {analytics}
      {team}
    </>
  )
}
```

---

## Intercepting Routes

```
app/
├── feed/
│   └── page.tsx
├── photo/
│   └── [id]/
│       └── page.tsx
└── @modal/
    └── (.)photo/
        └── [id]/
            └── page.tsx
```

**Conventions:**
- `(.)` - same level
- `(..)` - one level up
- `(..)(..)` - two levels up
- `(...)` - from root

---

## Metadata

```typescript
// app/blog/[slug]/page.tsx
import type { Metadata } from "next"

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const post = await prisma.post.findUnique({ where: { slug: params.slug } })

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

## Special Files

| File | Purpose |
|------|---------|
| `loading.tsx` | Suspense fallback |
| `error.tsx` | Error Boundary |
| `not-found.tsx` | 404 page |
| `template.tsx` | Re-rendering Layout |
| `default.tsx` | Parallel route fallback |

### Loading UI

```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return <div>Loading...</div>
}
```

### Error UI

```typescript
// app/dashboard/error.tsx
"use client"

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>An error occurred</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

---

## Navigation

```typescript
"use client"

import { useRouter, usePathname, useSearchParams } from "next/navigation"
import Link from "next/link"

export function Navigation() {
  const router = useRouter()
  const pathname = usePathname() // current path
  const searchParams = useSearchParams() // query parameters

  return (
    <>
      <Link href="/about">About</Link>
      <button onClick={() => router.push("/posts")}>Go to Posts</button>
    </>
  )
}
```

---

## References

- [Next.js App Router Official Docs](https://nextjs.org/docs/app)
