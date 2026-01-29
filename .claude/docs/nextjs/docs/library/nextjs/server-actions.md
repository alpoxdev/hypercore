# Server Actions

> Type-safe server functions (React 19 Server Actions)

---

## Basic Usage

### File-level Declaration

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

### Inline Declaration

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

## Zod Validation

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

## Authentication

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
      userId: session.user.id, // Delete only own posts
    },
  })

  revalidatePath("/posts")
}
```

---

## Error Handling

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
    return { success: false, message: "Update failed" }
  }
}
```

---

## Client Usage

### Form Action

```typescript
"use client"

import { createPost } from "@/actions/posts"

export function CreatePostForm() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Submit</button>
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
        {mutation.isPending ? "Submitting..." : "Submit"}
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
    return { error: "Please enter a title" }
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
      <button type="submit">Submit</button>
    </form>
  )
}
```

---

## Cache Invalidation

### revalidatePath

```typescript
"use server"

import { revalidatePath } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })

  // Invalidate specific path cache
  revalidatePath("/posts")
  revalidatePath(`/posts/${post.id}`)

  // Invalidate all caches including layouts
  revalidatePath("/posts", "layout")

  return post
}
```

### revalidateTag

```typescript
// Set tag when fetching data
const posts = await fetch("https://api.example.com/posts", {
  next: { tags: ["posts"] },
})

// Invalidate tag in Server Action
"use server"

import { revalidateTag } from "next/cache"

export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data })
  revalidateTag("posts") // Invalidate "posts" tag cache
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

  redirect(`/posts/${post.id}`) // Navigate to page
}
```

---

## File Upload

```typescript
"use server"

import { writeFile } from "fs/promises"
import { join } from "path"

export async function uploadFile(formData: FormData) {
  const file = formData.get("file") as File

  if (!file) {
    throw new Error("No file provided")
  }

  const bytes = await file.arrayBuffer()
  const buffer = Buffer.from(bytes)

  const path = join(process.cwd(), "public", "uploads", file.name)
  await writeFile(path, buffer)

  return { url: `/uploads/${file.name}` }
}
```

---

## Best Practices

### ✅ DO

```typescript
"use server"

// 1. Zod validation
const schema = z.object({ title: z.string().min(1) })

// 2. Authentication check
const session = await auth()
if (!session) throw new Error("Unauthorized")

// 3. try-catch
try {
  const post = await prisma.post.create({ data })
  revalidatePath("/posts")
  return { success: true, post }
} catch (error) {
  return { success: false, message: "Creation failed" }
}
```

### ❌ DON'T

```typescript
// 1. Defining Server Action in Client Component
"use client"

async function createPost() {
  "use server" // ❌ Error
}

// 2. Using without validation
export async function createPost(formData: FormData) {
  const title = formData.get("title") // ❌ Missing validation
  await prisma.post.create({ data: { title } })
}

// 3. Using without try-catch
export async function createPost(data: PostInput) {
  const post = await prisma.post.create({ data }) // ❌ Missing error handling
  return post
}
```

---

## References

- [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
