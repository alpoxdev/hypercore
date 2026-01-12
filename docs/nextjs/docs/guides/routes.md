# Routes

> Next.js App Router 라우팅 패턴

---

## 기본 라우팅

| 파일 | 라우트 |
|------|--------|
| `app/page.tsx` | `/` |
| `app/about/page.tsx` | `/about` |
| `app/blog/page.tsx` | `/blog` |
| `app/blog/[slug]/page.tsx` | `/blog/:slug` |

---

## 동적 라우트

### 단일 파라미터

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

// 정적 생성
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

## 레이아웃

### Root Layout (필수)

```typescript
// app/layout.tsx
import { Providers } from "./providers"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

### 중첩 Layout

```typescript
// app/dashboard/layout.tsx
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import { redirect } from "next/navigation"

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  // 인증 체크
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

**용도:** URL에 영향 없이 다른 레이아웃 적용

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
      <h2>오류 발생: {error.message}</h2>
      <button onClick={reset}>다시 시도</button>
    </div>
  )
}
```

### Not Found

```typescript
// app/posts/[id]/not-found.tsx
export default function NotFound() {
  return <div>게시글을 찾을 수 없습니다</div>
}
```

---

## Metadata

### 정적

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

### 동적

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

## 네비게이션

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

## 인증 보호

### Layout에서 체크

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

### Middleware에서 체크

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

## 베스트 프랙티스

### ✅ DO

```typescript
// 1. Server Component에서 직접 데이터 페칭
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}

// 2. 레이아웃에서 인증 체크
export default async function DashboardLayout({ children }) {
  const session = await auth.api.getSession({ headers: headers() })
  if (!session?.user) redirect("/login")
  return <div>{children}</div>
}

// 3. generateStaticParams로 정적 생성
export async function generateStaticParams() {
  const posts = await prisma.post.findMany({ select: { id: true } })
  return posts.map(post => ({ id: post.id }))
}
```

### ❌ DON'T

```typescript
// 1. Client Component에서 async/await
"use client"
export default async function PostsPage() { // ❌
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}

// 2. 페이지마다 인증 체크 반복
export default async function Page1() {
  const session = await auth.api.getSession({ headers: headers() }) // ❌ 중복
  if (!session) redirect("/login")
}

// 3. 하드코딩된 경로
<Link href="/posts/123">Post</Link> // ❌ 하드코딩
```

---

## 참조

- [App Router](../library/nextjs/app-router.md)
- [Server Actions](server-actions.md)
- [Client Components](client-components.md)
