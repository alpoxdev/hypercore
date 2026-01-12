# Caching

> Next.js caching strategies

---

## Cache Levels

| Level | Description |
|-------|-------------|
| **Request Memoization** | Deduplicate same requests (React) |
| **Data Cache** | Server data cache (persistent) |
| **Full Route Cache** | Static rendering at build time |
| **Router Cache** | Client-side router cache |

---

## Request Memoization

```typescript
// Same requests execute only once
async function getUser(id: string) {
  const res = await fetch(`https://api.example.com/users/${id}`)
  return res.json()
}

export default async function Page() {
  const user1 = await getUser("1") // fetch executes
  const user2 = await getUser("1") // cache used (deduplicated)

  return <div>{user1.name}</div>
}
```

---

## Data Cache (fetch)

### Default (cached)

```typescript
// Cached by default
const res = await fetch("https://api.example.com/posts")
```

### Disable Cache

```typescript
// Fetch fresh data on every request
const res = await fetch("https://api.example.com/posts", {
  cache: "no-store",
})
```

### Revalidate (time-based)

```typescript
// Revalidate every 60 seconds
const res = await fetch("https://api.example.com/posts", {
  next: { revalidate: 60 },
})
```

### Tag-based Cache

```typescript
// Set tag
const res = await fetch("https://api.example.com/posts", {
  next: { tags: ["posts"] },
})

// Invalidate tag in Server Action
"use server"
import { revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  await prisma.post.create({ data })
  revalidateTag("posts") // Invalidate "posts" tag cache
}
```

---

## unstable_cache (function caching)

```typescript
import { unstable_cache } from "next/cache"

const getCachedPosts = unstable_cache(
  async () => {
    return prisma.post.findMany()
  },
  ["posts"], // cache key
  {
    revalidate: 60, // 60 seconds
    tags: ["posts"], // tags
  }
)

export default async function PostsPage() {
  const posts = await getCachedPosts()
  return <PostsList posts={posts} />
}
```

---

## revalidatePath

```typescript
"use server"

import { revalidatePath } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })

  // Invalidate specific path cache
  revalidatePath("/posts")
  revalidatePath(`/posts/${post.id}`)

  // Invalidate all caches including layout
  revalidatePath("/posts", "layout")

  return post
}
```

---

## revalidateTag

```typescript
"use server"

import { revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })

  // Invalidate all caches with "posts" tag
  revalidateTag("posts")

  return post
}
```

---

## Full Route Cache (static rendering)

### Static Page

```typescript
// Generated at build time (default)
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

### Dynamic Page (disable cache)

```typescript
// Render on every request
export const dynamic = "force-dynamic"

export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

### Revalidate (time-based)

```typescript
// Regenerate every 60 seconds
export const revalidate = 60

export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

---

## Route Segment Config

```typescript
// app/posts/page.tsx

// Force dynamic rendering
export const dynamic = "force-dynamic" // "auto" | "force-static" | "error"

// Revalidate interval (seconds)
export const revalidate = 60 // false | 0 | number

// Runtime configuration
export const runtime = "nodejs" // "edge"

// Maximum execution time (seconds)
export const maxDuration = 60

export default async function PostsPage() {
  // ...
}
```

---

## Router Cache (client-side)

```typescript
"use client"

import { useRouter } from "next/navigation"

export function Navigation() {
  const router = useRouter()

  return (
    <button
      onClick={() => {
        router.push("/posts") // Use cached page
        router.refresh() // Force refresh
      }}
    >
      Go to Posts
    </button>
  )
}
```

---

## generateStaticParams (dynamic routes)

```typescript
// app/posts/[id]/page.tsx

// List of pages to generate at build time
export async function generateStaticParams() {
  const posts = await prisma.post.findMany({ select: { id: true } })
  return posts.map(post => ({ id: post.id }))
}

export default async function PostPage({ params }: { params: { id: string } }) {
  const post = await prisma.post.findUnique({ where: { id: params.id } })
  return <article>{post.title}</article>
}
```

---

## Caching Flow

### Static Page

```
1. Render at build time
2. Save to Full Route Cache
3. Subsequent requests use cache
4. Regenerate after revalidate time
```

### Dynamic Page

```
1. Render on every request
2. No cache
3. Update data with Server Actions
4. Invalidate only specific paths with revalidatePath
```

---

## Cache Invalidation Strategies

### Time-based

```typescript
// Regenerate every 60 seconds
export const revalidate = 60

const res = await fetch("...", { next: { revalidate: 60 } })
```

### On-demand (Server Actions)

```typescript
"use server"

import { revalidatePath, revalidateTag } from "next/cache"

export async function updatePost(id: string, data: PostInput) {
  await prisma.post.update({ where: { id }, data })

  // Path invalidation
  revalidatePath(`/posts/${id}`)

  // Tag invalidation
  revalidateTag("posts")
}
```

---

## Best Practices

### ✅ DO

```typescript
// 1. Use default cache for static data
const posts = await fetch("https://api.example.com/posts")

// 2. Use no-store for dynamic data
const user = await fetch("https://api.example.com/user", {
  cache: "no-store",
})

// 3. Tag-based invalidation
const posts = await fetch("...", { next: { tags: ["posts"] } })
revalidateTag("posts")

// 4. Function caching
const getCachedData = unstable_cache(
  async () => prisma.post.findMany(),
  ["posts"],
  { revalidate: 60 }
)
```

### ❌ DON'T

```typescript
// 1. Caching sensitive data
const user = await fetch("/api/user") // ❌ Don't cache personal data

// 2. Excessive revalidatePath
revalidatePath("/") // ❌ Invalidates entire site

// 3. Short revalidate interval
export const revalidate = 1 // ❌ Increases load
```

---

## References

- [Next.js Caching](https://nextjs.org/docs/app/building-your-application/caching)
