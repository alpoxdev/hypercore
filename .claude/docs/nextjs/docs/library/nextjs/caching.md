# Caching

> Next.js 캐싱 전략

---

## 캐시 레벨

| 레벨 | 설명 |
|------|------|
| **Request Memoization** | 같은 요청 중복 제거 (React) |
| **Data Cache** | 서버 데이터 캐시 (영구) |
| **Full Route Cache** | 빌드 시 정적 렌더링 |
| **Router Cache** | 클라이언트 라우터 캐시 |

---

## Request Memoization

```typescript
// 같은 요청은 한 번만 실행됨
async function getUser(id: string) {
  const res = await fetch(`https://api.example.com/users/${id}`)
  return res.json()
}

export default async function Page() {
  const user1 = await getUser("1") // fetch 실행
  const user2 = await getUser("1") // 캐시 사용 (중복 제거)

  return <div>{user1.name}</div>
}
```

---

## Data Cache (fetch)

### 기본 (캐시 사용)

```typescript
// 기본적으로 캐시됨
const res = await fetch("https://api.example.com/posts")
```

### 캐시 비활성화

```typescript
// 매 요청마다 새로 가져옴
const res = await fetch("https://api.example.com/posts", {
  cache: "no-store",
})
```

### Revalidate (시간 기반)

```typescript
// 60초마다 재검증
const res = await fetch("https://api.example.com/posts", {
  next: { revalidate: 60 },
})
```

### Tag 기반 캐시

```typescript
// 태그 설정
const res = await fetch("https://api.example.com/posts", {
  next: { tags: ["posts"] },
})

// Server Action에서 태그 무효화
"use server"
import { revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  await prisma.post.create({ data })
  revalidateTag("posts") // "posts" 태그 캐시 무효화
}
```

---

## unstable_cache (함수 캐싱)

```typescript
import { unstable_cache } from "next/cache"

const getCachedPosts = unstable_cache(
  async () => {
    return prisma.post.findMany()
  },
  ["posts"], // 캐시 키
  {
    revalidate: 60, // 60초
    tags: ["posts"], // 태그
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

  // 특정 경로 캐시 무효화
  revalidatePath("/posts")
  revalidatePath(`/posts/${post.id}`)

  // 레이아웃 포함 모든 캐시 무효화
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

  // "posts" 태그가 붙은 모든 캐시 무효화
  revalidateTag("posts")

  return post
}
```

---

## Full Route Cache (정적 렌더링)

### 정적 페이지

```typescript
// 빌드 시 생성 (기본)
export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

### 동적 페이지 (캐시 비활성화)

```typescript
// 매 요청마다 렌더링
export const dynamic = "force-dynamic"

export default async function PostsPage() {
  const posts = await prisma.post.findMany()
  return <PostsList posts={posts} />
}
```

### Revalidate (시간 기반)

```typescript
// 60초마다 재생성
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

// 동적 렌더링 강제
export const dynamic = "force-dynamic" // "auto" | "force-static" | "error"

// Revalidate 주기 (초)
export const revalidate = 60 // false | 0 | number

// 런타임 설정
export const runtime = "nodejs" // "edge"

// 최대 실행 시간 (초)
export const maxDuration = 60

export default async function PostsPage() {
  // ...
}
```

---

## Router Cache (클라이언트)

```typescript
"use client"

import { useRouter } from "next/navigation"

export function Navigation() {
  const router = useRouter()

  return (
    <button
      onClick={() => {
        router.push("/posts") // 캐시된 페이지 사용
        router.refresh() // 강제 새로고침
      }}
    >
      Go to Posts
    </button>
  )
}
```

---

## generateStaticParams (동적 라우트)

```typescript
// app/posts/[id]/page.tsx

// 빌드 시 생성할 페이지 목록
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

## 캐싱 플로우

### 정적 페이지

```
1. 빌드 시 렌더링
2. Full Route Cache 저장
3. 이후 요청은 캐시 사용
4. revalidate 시간 후 재생성
```

### 동적 페이지

```
1. 매 요청마다 렌더링
2. 캐시 없음
3. Server Actions로 데이터 업데이트
4. revalidatePath로 특정 경로만 무효화
```

---

## 캐시 무효화 전략

### 시간 기반

```typescript
// 60초마다 재생성
export const revalidate = 60

const res = await fetch("...", { next: { revalidate: 60 } })
```

### 온디맨드 (Server Actions)

```typescript
"use server"

import { revalidatePath, revalidateTag } from "next/cache"

export async function updatePost(id: string, data: PostInput) {
  await prisma.post.update({ where: { id }, data })

  // 경로 무효화
  revalidatePath(`/posts/${id}`)

  // 태그 무효화
  revalidateTag("posts")
}
```

---

## 베스트 프랙티스

### ✅ DO

```typescript
// 1. 정적 데이터는 기본 캐시 사용
const posts = await fetch("https://api.example.com/posts")

// 2. 동적 데이터는 no-store
const user = await fetch("https://api.example.com/user", {
  cache: "no-store",
})

// 3. 태그 기반 무효화
const posts = await fetch("...", { next: { tags: ["posts"] } })
revalidateTag("posts")

// 4. 함수 캐싱
const getCachedData = unstable_cache(
  async () => prisma.post.findMany(),
  ["posts"],
  { revalidate: 60 }
)
```

### ❌ DON'T

```typescript
// 1. 민감한 데이터 캐싱
const user = await fetch("/api/user") // ❌ 개인정보 캐싱 금지

// 2. 과도한 revalidatePath
revalidatePath("/") // ❌ 전체 사이트 무효화

// 3. 짧은 revalidate
export const revalidate = 1 // ❌ 부하 증가
```

---

## 참조

- [Next.js Caching](https://nextjs.org/docs/app/building-your-application/caching)
