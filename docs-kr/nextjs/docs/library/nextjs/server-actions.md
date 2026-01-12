# Server Actions

> 타입 안전한 서버 함수 (React 19 Server Actions)

---

## 기본 사용법

### 파일 상단 선언

```typescript
// app/actions.ts
"use server"

import { z } from "zod"
import { revalidatePath } from "next/cache"

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string
  const content = formData.get("content") as string

  const post = await prisma.post.create({
    data: { title, content },
  })

  revalidatePath("/posts")
  return post
}
```

### 인라인 선언

```typescript
// app/posts/page.tsx
export default function PostsPage() {
  async function createPost(formData: FormData) {
    "use server"

    const title = formData.get("title") as string
    await prisma.post.create({ data: { title } })
  }

  return <form action={createPost}>...</form>
}
```

---

## Zod 검증

```typescript
"use server"

import { z } from "zod"

const createPostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
  published: z.boolean().default(false),
})

export async function createPost(formData: FormData) {
  const parsed = createPostSchema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
    published: formData.get("published") === "on",
  })

  const post = await prisma.post.create({ data: parsed })
  revalidatePath("/posts")
  return post
}
```

---

## 인증

```typescript
"use server"

import { auth } from "@/lib/auth"
import { redirect } from "next/navigation"

export async function deletePost(id: string) {
  const session = await auth()

  if (!session?.user) {
    redirect("/login")
  }

  await prisma.post.delete({
    where: {
      id,
      userId: session.user.id, // 본인 게시물만 삭제
    },
  })

  revalidatePath("/posts")
}
```

---

## 에러 처리

```typescript
"use server"

export async function updatePost(id: string, data: PostInput) {
  try {
    const post = await prisma.post.update({ where: { id }, data })
    revalidatePath(`/posts/${id}`)
    return { success: true, post }
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.errors }
    }
    return { success: false, message: "업데이트 실패" }
  }
}
```

---

## 클라이언트에서 사용

### Form Action

```typescript
"use client"

import { createPost } from "@/actions/posts"

export function CreatePostForm() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">등록</button>
    </form>
  )
}
```

### TanStack Query

```typescript
"use client"

import { useMutation, useQueryClient } from "@tanstack/react-query"
import { createPost } from "@/actions/posts"

export function CreatePostForm() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: async (formData: FormData) => {
      return createPost(formData)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["posts"] })
    },
  })

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        const formData = new FormData(e.currentTarget)
        mutation.mutate(formData)
      }}
    >
      <input name="title" required />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? "등록 중..." : "등록"}
      </button>
    </form>
  )
}
```

---

## useFormState (React 19)

```typescript
"use server"

export async function createPost(prevState: any, formData: FormData) {
  const title = formData.get("title") as string

  if (!title) {
    return { error: "제목을 입력하세요" }
  }

  const post = await prisma.post.create({ data: { title } })
  return { success: true, post }
}
```

```typescript
"use client"

import { useFormState } from "react-dom"
import { createPost } from "@/actions/posts"

export function CreatePostForm() {
  const [state, formAction] = useFormState(createPost, null)

  return (
    <form action={formAction}>
      <input name="title" />
      {state?.error && <p>{state.error}</p>}
      <button type="submit">등록</button>
    </form>
  )
}
```

---

## 캐시 무효화

### revalidatePath

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

### revalidateTag

```typescript
// 데이터 페칭 시 태그 설정
const posts = await fetch("https://api.example.com/posts", {
  next: { tags: ["posts"] },
})

// Server Action에서 태그 무효화
"use server"

import { revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })
  revalidateTag("posts") // "posts" 태그 캐시 무효화
  return post
}
```

---

## redirect

```typescript
"use server"

import { redirect } from "next/navigation"

export async function createPost(formData: FormData) {
  const post = await prisma.post.create({
    data: {
      title: formData.get("title") as string,
    },
  })

  redirect(`/posts/${post.id}`) // 페이지 이동
}
```

---

## 파일 업로드

```typescript
"use server"

import { writeFile } from "fs/promises"
import { join } from "path"

export async function uploadFile(formData: FormData) {
  const file = formData.get("file") as File

  if (!file) {
    throw new Error("파일이 없습니다")
  }

  const bytes = await file.arrayBuffer()
  const buffer = Buffer.from(bytes)

  const path = join(process.cwd(), "public", "uploads", file.name)
  await writeFile(path, buffer)

  return { url: `/uploads/${file.name}` }
}
```

---

## 베스트 프랙티스

### ✅ DO

```typescript
"use server"

// 1. Zod 검증
const schema = z.object({ title: z.string().min(1) })

// 2. 인증 체크
const session = await auth()
if (!session) throw new Error("Unauthorized")

// 3. try-catch
try {
  const post = await prisma.post.create({ data })
  revalidatePath("/posts")
  return { success: true, post }
} catch (error) {
  return { success: false, message: "생성 실패" }
}
```

### ❌ DON'T

```typescript
// 1. 클라이언트 컴포넌트에서 Server Action 정의
"use client"

async function createPost() {
  "use server" // ❌ 에러
}

// 2. 검증 없이 사용
export async function createPost(formData: FormData) {
  const title = formData.get("title") // ❌ 검증 누락
  await prisma.post.create({ data: { title } })
}

// 3. try-catch 없이 사용
export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data }) // ❌ 에러 처리 누락
  return post
}
```

---

## 참조

- [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
