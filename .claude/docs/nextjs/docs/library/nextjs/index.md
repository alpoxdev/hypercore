# Next.js - Index

> Next.js 15 App Router 핵심 개념

<context>
@app-router.md
@server-actions.md
@route-handlers.md
@middleware.md
@caching.md
</context>

---

## 핵심 개념

| 개념 | 설명 |
|------|------|
| **App Router** | 파일 기반 라우팅 (`app/` 디렉토리) |
| **Server Components** | 기본 컴포넌트 (서버 렌더링) |
| **Client Components** | `"use client"` 선언 필요 |
| **Server Actions** | `"use server"` 함수 (타입 안전 API) |
| **Route Handlers** | REST API 엔드포인트 (`app/api/`) |

---

## 빠른 시작

### 프로젝트 생성

```bash
npx create-next-app@latest my-app --typescript --tailwind --app
cd my-app
npm run dev
```

### 기본 페이지

```typescript
// app/page.tsx (Server Component - 기본)
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

## 파일 구조

```
app/
├── layout.tsx          # Root layout (필수)
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

## 주요 파일

| 파일 | 용도 |
|------|------|
| `layout.tsx` | 공통 레이아웃 (중첩 가능) |
| `page.tsx` | 페이지 컴포넌트 |
| `loading.tsx` | 로딩 UI (Suspense) |
| `error.tsx` | 에러 UI (Error Boundary) |
| `not-found.tsx` | 404 페이지 |
| `route.ts` | API 엔드포인트 |

---

## Server vs Client Components

| 구분 | Server | Client |
|------|--------|--------|
| 선언 | 기본 | `"use client"` |
| 데이터 페칭 | ✅ async/await | ❌ (useQuery 사용) |
| Hooks | ❌ | ✅ useState, useEffect |
| 브라우저 API | ❌ | ✅ window, localStorage |
| Event Handlers | ❌ | ✅ onClick, onChange |

**규칙:**
- Server Component가 기본 → Client Component 필요 시만 `"use client"` 추가
- Server Component 안에 Client Component 포함 가능
- Client Component 안에 Server Component 불가 (props로 전달은 가능)

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

## 데이터 페칭

### Server Component (권장)

```typescript
export default async function PostsPage() {
  const posts = await prisma.post.findMany() // 직접 DB 접근
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

## 캐싱

| 함수 | 용도 |
|------|------|
| `revalidatePath("/posts")` | 특정 경로 캐시 무효화 |
| `revalidateTag("posts")` | 태그 기반 캐시 무효화 |
| `unstable_cache()` | 함수 결과 캐싱 |

```typescript
import { revalidatePath, revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })

  revalidatePath("/posts") // /posts 캐시 무효화
  revalidateTag("posts")   // "posts" 태그 캐시 무효화

  return post
}
```

---

## 환경 변수

```bash
# .env.local
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="..."
NEXTAUTH_URL="http://localhost:3000"
NEXT_PUBLIC_API_URL="https://api.example.com"
```

**규칙:**
- `NEXT_PUBLIC_*`: 클라이언트에서 접근 가능
- 나머지: 서버 전용

---

## 배포

### Vercel (권장)

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

## 참조

- [App Router](app-router.md)
- [Server Actions](server-actions.md)
- [Route Handlers](route-handlers.md)
- [Middleware](middleware.md)
- [Caching](caching.md)
