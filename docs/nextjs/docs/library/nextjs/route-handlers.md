# Route Handlers

> REST API endpoints (`app/api/`)

---

## Basic Usage

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

## HTTP Methods

```typescript
// app/api/posts/route.ts
export async function GET(request: NextRequest) {}
export async function POST(request: NextRequest) {}
export async function PUT(request: NextRequest) {}
export async function PATCH(request: NextRequest) {}
export async function DELETE(request: NextRequest) {}
export async function HEAD(request: NextRequest) {}
export async function OPTIONS(request: NextRequest) {}
```

---

## Dynamic Routes

```typescript
// app/api/posts/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const post = await prisma.post.findUnique({ where: { id: params.id } })

  if (!post) {
    return NextResponse.json({ error: "Not found" }, { status: 404 })
  }

  return NextResponse.json(post)
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  await prisma.post.delete({ where: { id: params.id } })
  return NextResponse.json({ success: true })
}
```

---

## Request Processing

### Query Parameters

```typescript
// GET /api/posts?page=1&limit=10
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const page = Number(searchParams.get("page") || 1)
  const limit = Number(searchParams.get("limit") || 10)

  const posts = await prisma.post.findMany({
    skip: (page - 1) * limit,
    take: limit,
  })

  return NextResponse.json(posts)
}
```

### JSON Body

```typescript
export async function POST(request: NextRequest) {
  const body = await request.json()

  const post = await prisma.post.create({
    data: {
      title: body.title,
      content: body.content,
    },
  })

  return NextResponse.json(post, { status: 201 })
}
```

### FormData

```typescript
export async function POST(request: NextRequest) {
  const formData = await request.formData()
  const title = formData.get("title") as string
  const file = formData.get("file") as File

  // File processing...

  return NextResponse.json({ success: true })
}
```

### Headers

```typescript
export async function GET(request: NextRequest) {
  const token = request.headers.get("authorization")
  const userAgent = request.headers.get("user-agent")

  // Use headers...

  return NextResponse.json({ data: "..." })
}
```

---

## Response Processing

### JSON Response

```typescript
export async function GET() {
  return NextResponse.json({ message: "Hello" }, { status: 200 })
}
```

### Response Headers

```typescript
export async function GET() {
  return NextResponse.json(
    { data: "..." },
    {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "max-age=3600",
      },
    }
  )
}
```

### Redirect

```typescript
import { redirect } from "next/navigation"

export async function GET() {
  redirect("https://example.com")
}
```

### Cookies

```typescript
import { cookies } from "next/headers"

export async function GET() {
  const cookieStore = cookies()

  // Read cookie
  const token = cookieStore.get("token")

  // Set cookie
  cookieStore.set("token", "value", {
    httpOnly: true,
    secure: true,
    maxAge: 60 * 60 * 24 * 7, // 7 days
  })

  return NextResponse.json({ success: true })
}
```

---

## Zod Validation

```typescript
import { z } from "zod"
import { NextRequest, NextResponse } from "next/server"

const createPostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const parsed = createPostSchema.parse(body)

    const post = await prisma.post.create({ data: parsed })
    return NextResponse.json(post, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { errors: error.errors },
        { status: 400 }
      )
    }
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    )
  }
}
```

---

## Authentication

```typescript
import { auth } from "@/lib/auth"

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth()

  if (!session?.user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
  }

  await prisma.post.delete({
    where: {
      id: params.id,
      userId: session.user.id,
    },
  })

  return NextResponse.json({ success: true })
}
```

---

## CORS

```typescript
export async function GET(request: NextRequest) {
  const data = await fetchData()

  return NextResponse.json(data, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  })
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  })
}
```

---

## Streaming

```typescript
export async function GET() {
  const encoder = new TextEncoder()

  const stream = new ReadableStream({
    async start(controller) {
      for (let i = 0; i < 10; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000))
        controller.enqueue(encoder.encode(`data: ${i}\n\n`))
      }
      controller.close()
    },
  })

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    },
  })
}
```

---

## Error Handling

```typescript
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const post = await prisma.post.findUnique({ where: { id: params.id } })

    if (!post) {
      return NextResponse.json({ error: "Not found" }, { status: 404 })
    }

    return NextResponse.json(post)
  } catch (error) {
    console.error("Error fetching post:", error)
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    )
  }
}
```

---

## Caching

```typescript
// Static response (generated at build time)
export const dynamic = "force-static"

// Dynamic response (every request)
export const dynamic = "force-dynamic"

// Revalidate (regenerate every n seconds)
export const revalidate = 60 // 60 seconds

export async function GET() {
  const posts = await prisma.post.findMany()
  return NextResponse.json(posts)
}
```

---

## Server Actions vs Route Handlers

| Criteria | Server Actions | Route Handlers |
|----------|----------------|----------------|
| **Purpose** | Form submissions, mutations | REST API, external integration |
| **Types** | ✅ Automatic type inference | ❌ Manual type definition |
| **Caching** | revalidatePath | export const revalidate |
| **Auth** | await auth() | await auth() |
| **Recommended** | Internal API | External API, webhooks |

**Recommendation:**
- Internal API → Server Actions
- External API, webhooks, third-party integration → Route Handlers

---

## References

- [Next.js Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
