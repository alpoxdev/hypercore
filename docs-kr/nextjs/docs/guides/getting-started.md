# Getting Started

> Next.js 15 프로젝트 시작하기

---

## 프로젝트 생성

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

## 필수 의존성

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

## 폴더 구조

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
│   │   └── -components/        # 페이지 전용
│   └── api/
│       └── auth/
│           └── [...all]/
│               └── route.ts
├── actions/                    # Server Actions (공통)
│   ├── posts.ts
│   └── users.ts
├── components/
│   └── ui/                     # UI 컴포넌트
├── lib/
│   ├── auth.ts                 # Better Auth 설정
│   ├── auth-client.ts          # Auth Client
│   ├── prisma.ts               # Prisma Client
│   └── query-client.ts         # React Query Client
├── database/
│   └── prisma.ts
└── middleware.ts
```

---

## 환경 변수

```bash
# .env.local
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"
BETTER_AUTH_SECRET="your-secret-key"
BETTER_AUTH_URL="http://localhost:3000"

# 소셜 로그인 (옵션)
GOOGLE_CLIENT_ID="..."
GOOGLE_CLIENT_SECRET="..."
GITHUB_CLIENT_ID="..."
GITHUB_CLIENT_SECRET="..."

# 클라이언트 공개 변수
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

---

## Prisma 설정

```bash
# 초기화
npx prisma init

# 스키마 생성
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
# DB 동기화
npx prisma db push

# Client 생성
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

## Better Auth 설정

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

## React Query 설정

```typescript
// src/lib/query-client.ts
import { QueryClient } from "@tanstack/react-query"

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1분
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
    <html lang="ko">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

---

## 첫 Server Action

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

## 첫 페이지 (Server Component)

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

## 첫 폼 (Client Component)

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

## 다음 단계

- [Conventions](conventions.md) - 코드 컨벤션
- [Routes](routes.md) - 라우팅 패턴
- [Server Actions](server-actions.md) - Server Actions 패턴
- [Client Components](client-components.md) - Client Components 패턴
