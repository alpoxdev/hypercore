# App Router

> 파일 기반 라우팅 시스템

---

## 파일 구조와 라우팅

### 기본 규칙

| 파일 | 라우트 | 설명 |
|------|--------|------|
| `app/page.tsx` | `/` | 홈 페이지 |
| `app/about/page.tsx` | `/about` | About 페이지 |
| `app/blog/[slug]/page.tsx` | `/blog/:slug` | 동적 라우트 |
| `app/shop/[...slug]/page.tsx` | `/shop/*` | Catch-all |
| `app/docs/[[...slug]]/page.tsx` | `/docs/*` | Optional catch-all |

### 예시

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

### Root Layout (필수)

```typescript
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  )
}
```

### 중첩 Layout

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

**특징:**
- 중첩 가능 (부모 → 자식 순서)
- 리렌더링 없이 유지됨
- props로 `children` 받음

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

**용도:**
- URL에 영향 없이 폴더 그룹화
- 다른 레이아웃 적용

---

## 동적 라우트

### 단일 파라미터

```typescript
// app/posts/[id]/page.tsx
export default async function PostPage({ params }: { params: { id: string } }) {
  const post = await prisma.post.findUnique({ where: { id: params.id } })
  return <article>{post.title}</article>
}

// 정적 생성 (빌드 시)
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

## 병렬 라우트

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

## 인터셉팅 라우트

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

**컨벤션:**
- `(.)` - 같은 레벨
- `(..)` - 한 단계 위
- `(..)(..)` - 두 단계 위
- `(...)` - 루트부터

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

## 특수 파일

| 파일 | 용도 |
|------|------|
| `loading.tsx` | Suspense 폴백 |
| `error.tsx` | Error Boundary |
| `not-found.tsx` | 404 페이지 |
| `template.tsx` | 리렌더링되는 Layout |
| `default.tsx` | 병렬 라우트 폴백 |

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
      <h2>오류 발생</h2>
      <button onClick={reset}>다시 시도</button>
    </div>
  )
}
```

---

## 네비게이션

```typescript
"use client"

import { useRouter, usePathname, useSearchParams } from "next/navigation"
import Link from "next/link"

export function Navigation() {
  const router = useRouter()
  const pathname = usePathname() // 현재 경로
  const searchParams = useSearchParams() // 쿼리 파라미터

  return (
    <>
      <Link href="/about">About</Link>
      <button onClick={() => router.push("/posts")}>Go to Posts</button>
    </>
  )
}
```

---

## 참조

- [Next.js App Router 공식 문서](https://nextjs.org/docs/app)
