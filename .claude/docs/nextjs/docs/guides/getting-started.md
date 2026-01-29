# Getting Started

> Start with Next.js 15

---

## Create Project

```bash
npx create-next-app@latest my-app \
  --typescript \
  --tailwind \
  --app \
  --src-dir \
  --import-alias "@/*"

cd my-app
npm run dev
```

---

## Required Dependencies

```bash
# Database
npm install prisma @prisma/client
npm install -D prisma

# Validation
npm install zod

# Auth
npm install better-auth

# Data Fetching
npm install @tanstack/react-query
```

---

## Folder Structure

```
src/
├── app/
│   ├── layout.tsx              # Root layout
│   ├── page.tsx                # Home
│   ├── (auth)/
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── signup/
│   │       └── page.tsx
│   ├── dashboard/
│   │   ├── page.tsx
│   │   └── -components/        # Page-specific
│   └── api/
│       └── auth/
│           └── [...all]/
│               └── route.ts
├── actions/                    # Server Actions (shared)
│   ├── posts.ts
│   └── users.ts
├── components/
│   └── ui/                     # UI components
├── lib/
│   ├── auth.ts                 # Better Auth setup
│   ├── auth-client.ts          # Auth Client
│   ├── prisma.ts               # Prisma Client
│   └── query-client.ts         # React Query Client
├── database/
│   └── prisma.ts
└── middleware.ts
```

---

## Environment Variables

```bash
# .env.local
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"
BETTER_AUTH_SECRET="your-secret-key"
BETTER_AUTH_URL="http://localhost:3000"

# Social login (optional)
GOOGLE_CLIENT_ID="..."
GOOGLE_CLIENT_SECRET="..."
GITHUB_CLIENT_ID="..."
GITHUB_CLIENT_SECRET="..."

# Public client variables
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

---

## Prisma Setup

```bash
# Initialize
npx prisma init

# Create schema
mkdir -p prisma/schema
```

```prisma
// prisma/schema/+base.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
  output   = "../node_modules/.prisma/client"
}
```

```prisma
// prisma/schema/+enum.prisma
enum Role {
  USER
  ADMIN
}
```

```prisma
// prisma/schema/user.prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  role      Role     @default(USER)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

```bash
# Sync database
npx prisma db push

# Generate client
npx prisma generate
```

---

## Prisma Client

```typescript
// src/database/prisma.ts
import { PrismaClient } from "@prisma/client"

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma
```

---

## Better Auth Setup

```typescript
// src/lib/auth.ts
import { betterAuth } from "better-auth"
import { prismaAdapter } from "better-auth/adapters/prisma"
import { prisma } from "@/database/prisma"

export const auth = betterAuth({
  database: prismaAdapter(prisma, { provider: "postgresql" }),
  emailAndPassword: { enabled: true },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
})
```

```typescript
// src/lib/auth-client.ts
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL!,
})
```

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth"

export const GET = (request: Request) => auth.handler(request)
export const POST = (request: Request) => auth.handler(request)
```

---

## React Query Setup

```typescript
// src/lib/query-client.ts
import { QueryClient } from "@tanstack/react-query"

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minute
      },
    },
  })
}

let browserQueryClient: QueryClient | undefined = undefined

export function getQueryClient() {
  if (typeof window === "undefined") {
    return makeQueryClient()
  } else {
    if (!browserQueryClient) browserQueryClient = makeQueryClient()
    return browserQueryClient
  }
}
```

```typescript
// app/providers.tsx
"use client"

import { QueryClientProvider } from "@tanstack/react-query"
import { getQueryClient } from "@/lib/query-client"

export function Providers({ children }: { children: React.ReactNode }) {
  const queryClient = getQueryClient()

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )
}
```

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

---

## First Server Action

```typescript
// actions/posts.ts
"use server"

import { z } from "zod"
import { prisma } from "@/database/prisma"
import { revalidatePath } from "next/cache"

const createPostSchema = z.object({
  title: z.string().min(1),
  content: z.string(),
})

export async function createPost(formData: FormData) {
  const parsed = createPostSchema.parse({
    title: formData.get("title"),
    content: formData.get("content"),
  })

  const post = await prisma.post.create({ data: parsed })
  revalidatePath("/posts")
  return post
}
```

---

## First Page (Server Component)

```typescript
// app/posts/page.tsx
import { prisma } from "@/database/prisma"

export default async function PostsPage() {
  const posts = await prisma.post.findMany()

  return (
    <div>
      <h1>Posts</h1>
      <ul>
        {posts.map(post => (
          <li key={post.id}>{post.title}</li>
        ))}
      </ul>
    </div>
  )
}
```

---

## First Form (Client Component)

```typescript
// app/posts/_components/create-post-form.tsx
"use client"

import { useMutation, useQueryClient } from "@tanstack/react-query"
import { createPost } from "@/actions/posts"

export function CreatePostForm() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createPost,
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
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? "Creating..." : "Create Post"}
      </button>
    </form>
  )
}
```

---

## Next Steps

- [Conventions](conventions.md) - Code conventions
- [Routes](routes.md) - Routing patterns
- [Server Actions](server-actions.md) - Server Actions patterns
- [Client Components](client-components.md) - Client Components patterns
