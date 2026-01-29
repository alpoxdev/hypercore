# Architecture

> Next.js App Router 애플리케이션 아키텍처

<instructions>
@library/nextjs/app-router.md
@library/nextjs/server-actions.md
@library/nextjs/middleware.md
@library/prisma/index.md
</instructions>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **라우트** | Flat 파일 라우트 (`app/users.tsx`), Pages Router (`pages/`) |
| **Route Export** | named export (`export const Page`), 잘못된 파일명 (`Users.tsx`) |
| **API** | Pages Router API (`pages/api/`), API Routes 남용 (Server Actions 사용) |
| **레이어** | 비즈니스 로직을 app/ 폴더에 직접 작성 |
| **컴포넌트** | 'use client' 없이 클라이언트 전용 API 사용 |
| **Barrel Export** | `actions/index.ts` 생성 (Tree Shaking 실패) |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **라우트 구조** | 페이지마다 폴더 생성 (`app/users/page.tsx`) |
| **Route Export** | `export default function Page()` 필수 |
| **계층 구조** | app/ → Server Actions → lib/ → Database |
| **Route Group** | 목록 → `(main)/`, 관리자 → `(admin)/` |
| **페이지 전용 폴더** | `_components/`, `_hooks/`, `_actions/` 필수 (줄 수 무관) |
| **페이지 분리** | 100줄+ → `_components/`, 200줄+ → `_sections/` |
| **Server Actions** | mutations는 Server Actions 사용 (`'use server'`) |
| **검증** | Zod 스키마로 입력 검증 |
| **메타데이터** | `generateMetadata` 또는 `metadata` export |
| **에러 처리** | `error.tsx` (라우트), `not-found.tsx` (404), `global-error.tsx` (전역) |
| **타입 안전** | TypeScript strict, Prisma 타입 |

</required>

---

<system_overview>

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client (Browser)                         │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │ Next.js Router │───▶│ TanStack Query │───▶│    React UI   │  │
│  │  (Navigation)  │◀───│   (Caching)    │◀───│  (Components) │  │
│  └────────────────┘    └───────┬────────┘    └───────────────┘  │
└────────────────────────────────┼─────────────────────────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Next.js Server                             │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Server Components (기본)                       │ │
│  │   app/[route]/page.tsx → Server-side rendering             │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Server Actions                           │ │
│  │   'use server' → DB 접근, Mutations, Revalidation          │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Services Layer                           │ │
│  │   Zod Validation | Business Logic | Data Transformation    │ │
│  └────────────────────────────┬───────────────────────────────┘ │
└───────────────────────────────┼──────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                            │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │  Prisma Client │───▶│   PostgreSQL   │    │    Redis      │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

</system_overview>

---

<route_export_rule>

## Route Export 규칙

> ⚠️ **`export default` 필수**
>
> Next.js App Router는 모든 페이지/레이아웃 파일에서 **default export**로 컴포넌트를 내보내야 합니다.
>
> 파일명은 Next.js 규칙을 따라야 합니다: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`

| ❌ 금지 | ✅ 필수 |
|--------|--------|
| `app/users.tsx` | `app/users/page.tsx` |
| `export const Page = () => {}` | `export default function Page() {}` |
| `export default Users` (컴포넌트명 != 파일명 규칙) | `export default function UsersPage() {}` |

```typescript
// ❌ 금지: Flat 파일
// app/users.tsx
export default function Users() {
  return <div>Users</div>
}

// ❌ 금지: named export
// app/users/page.tsx
export const Page = () => {
  return <div>Users</div>
}

// ✅ 필수: 폴더 + page.tsx + default export
// app/users/page.tsx
export default function UsersPage() {
  return <div>Users</div>
}
```

</route_export_rule>

---

<layers>

## Layer Architecture

### 1. Routes Layer (app/)

> ⚠️ **페이지마다 폴더 생성 필수**
>
> 모든 페이지는 **반드시 폴더 구조**로 만들어야 합니다. Flat 파일 방식(`app/users.tsx`)은 금지됩니다.
>
> **이유:** `_components/`, `_hooks/`, `_actions/` 등 페이지 전용 리소스를 체계적으로 관리하기 위함입니다.
>
> | ❌ 금지 | ✅ 필수 |
> |--------|--------|
> | `app/users.tsx` | `app/users/page.tsx` |
> | `app/posts.tsx` | `app/(main)/posts/page.tsx` |

```
app/<route-name>/
├── (main)/                # route group (목록 페이지, URL에 미포함)
│   ├── page.tsx           # 페이지 컴포넌트
│   ├── _components/       # 페이지 전용 컴포넌트 (필수)
│   ├── _hooks/            # 페이지 전용 훅 (필수)
│   ├── _sections/         # UI 섹션 분리 (200줄+ 페이지)
│   └── _tabs/             # 탭 콘텐츠 분리
├── new/                   # 생성 페이지 (route group 외부)
│   └── page.tsx
├── [id]/                  # Dynamic segment
│   └── page.tsx
├── layout.tsx             # 레이아웃 (하위 경로 공통)
├── loading.tsx            # 로딩 UI (Suspense boundary)
├── error.tsx              # 에러 UI (Error boundary)
└── _actions/              # 페이지 전용 Server Actions (필수)
```

**필수 규칙:**
- 페이지당 `_components/`, `_hooks/`, `_actions/` 폴더 필수 (줄 수 무관)
- Custom Hook은 페이지 크기와 무관하게 **반드시** `_hooks/` 폴더에 분리
- Server Actions는 글로벌(`app/_actions/`) 또는 페이지 전용(`[route]/_actions/`)에 분리
- 공통 컴포넌트 → `components/ui/`, 페이지 전용 → `[route]/_components/`

| 패턴 | 위치 | 용도 |
|------|------|------|
| **Route Group** | `(main)/` | 목록 페이지, URL에 미포함 |
| **Private Folder** | `_components/` | 라우팅 시스템이 무시 |
| **_sections/** | 200줄+ | 논리적 섹션 분리 |
| **_tabs/** | 탭 UI | 탭 콘텐츠 분리 |
| **layout.tsx** | 레이아웃 | 하위 경로 공통 UI |

#### Layout Routes 패턴

> ⚠️ **layout.tsx로 레이아웃 구성**
>
> `layout.tsx`는 하위 경로의 공통 레이아웃 역할을 합니다.
> 목록 페이지는 Route Group `(main)/`으로 묶어야 합니다.
>
> | ❌ 금지 | ✅ 필수 |
> |--------|--------|
| `app/auth.tsx` | `app/(auth)/layout.tsx` + `app/(auth)/(main)/page.tsx` |

```
app/
├── (auth)/
│   ├── layout.tsx            # 레이아웃 (children 렌더링)
│   ├── (main)/
│   │   └── page.tsx          # /auth (메인)
│   ├── login/
│   │   └── page.tsx          # /auth/login
│   └── register/
│       └── page.tsx          # /auth/register
```

```typescript
// ❌ 금지: layout 없이 flat 구조
// app/auth/page.tsx
export default function AuthPage() {
  return <div>Auth</div>
}

// ✅ 필수: layout.tsx로 공통 UI 래핑
// app/(auth)/layout.tsx
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="auth-container">
      <header>Auth Header</header>
      {children}
    </div>
  )
}

// app/(auth)/(main)/page.tsx
export default function AuthMainPage() {
  return <div>Auth Main</div>
}

// app/(auth)/login/page.tsx
export default function LoginPage() {
  return <div>Login Form</div>
}
```

### 2. Server Actions Layer

```
app/_actions/                # 글로벌 (재사용)
├── <action-name>.ts         # 파일당 하나
└── types.ts                 # 공통 타입

app/<route>/_actions/        # 페이지 전용
└── <action-name>.ts
```

> ⚠️ **`app/_actions/index.ts` 생성 금지**
>
> `app/_actions/` 폴더에 `index.ts` (barrel export) 파일을 만들지 마세요.
>
> **문제점:**
> 1. **Tree Shaking 실패** - 번들러가 사용하지 않는 함수도 포함
> 2. **Client 번들 오염** - `prisma` 등 서버 전용 라이브러리가 클라이언트에 포함되어 빌드 에러
>
> ```typescript
> // ❌ app/_actions/index.ts 만들지 말 것
> export * from './get-users'
> export * from './create-post'  // prisma import → 클라이언트 빌드 실패
>
> // ✅ 개별 파일에서 직접 import
> import { getUsers } from '@/app/_actions/get-users'
> import { createPost } from '@/app/_actions/create-post'
> ```

### 3. Services Layer

```
lib/<domain>/
├── index.ts            # 진입점 (re-export)
├── schemas.ts          # Zod 스키마
├── queries.ts          # GET 요청
└── mutations.ts        # POST/PUT/PATCH
```

### 4. Database Layer

```typescript
// lib/db/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

</layers>

---

<component_types>

## Component Types

### Server Components vs Client Components

| 항목 | Server Components | Client Components |
|------|------------------|-------------------|
| **기본값** | ✅ 기본 (명시 불필요) | ❌ `'use client'` 필수 |
| **실행 위치** | 서버 | 브라우저 |
| **데이터 페칭** | async/await 직접 사용 | TanStack Query/SWR |
| **DB 접근** | ✅ 가능 | ❌ 불가능 (Server Actions 사용) |
| **브라우저 API** | ❌ 불가능 | ✅ 가능 (window, localStorage 등) |
| **상태 관리** | ❌ 불가능 | ✅ 가능 (useState, useEffect 등) |
| **이벤트 핸들러** | ❌ 불가능 | ✅ 가능 (onClick, onChange 등) |

```typescript
// ✅ Server Component (기본)
// app/users/page.tsx
import { prisma } from '@/lib/db/prisma'

export default async function UsersPage() {
  // 서버에서 직접 DB 쿼리
  const users = await prisma.user.findMany()

  return (
    <div>
      {users.map((user) => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  )
}

// ✅ Client Component
// app/users/_components/user-list.tsx
'use client'

import { useState } from 'react'

export default function UserList() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>
        Count: {count}
      </button>
    </div>
  )
}
```

### 컴포넌트 구성 전략

```
Page (Server Component)
  ├─ 데이터 페칭 (async/await)
  └─ Interactive UI (Client Component)
       └─ 상태 관리, 이벤트 핸들러
```

</component_types>

---

<route_lifecycle>

## Route Lifecycle

### Loading & Error Handling

| 파일 | 용도 | 필수 |
|------|------|------|
| **loading.tsx** | 로딩 UI (Suspense boundary) | 선택 |
| **error.tsx** | 에러 UI (Error boundary) | ✅ |
| **not-found.tsx** | 404 UI | ✅ |
| **global-error.tsx** | 전역 에러 UI | 선택 |

```
app/
├── layout.tsx
├── loading.tsx          # 전역 로딩
├── error.tsx            # 전역 에러
├── not-found.tsx        # 전역 404
├── global-error.tsx     # Root 에러 (layout.tsx 에러도 캐치)
└── users/
    ├── page.tsx
    ├── loading.tsx      # /users 로딩
    └── error.tsx        # /users 에러
```

### 코드 패턴

```typescript
// ✅ loading.tsx: 로딩 UI
export default function Loading() {
  return <div>Loading...</div>
}

// ✅ error.tsx: 에러 UI (Client Component 필수)
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>{error.message}</h2>
      <button onClick={reset}>Retry</button>
    </div>
  )
}

// ✅ not-found.tsx: 404 UI
import Link from 'next/link'

export default function NotFound() {
  return (
    <div>
      <h2>Not Found</h2>
      <Link href="/">Home</Link>
    </div>
  )
}
```

</route_lifecycle>

---

<data_flow>

## Data Flow

### Query Flow (읽기)

```
Page (Server Component) → Prisma → Database
          ↓
    자동 캐싱 (fetch cache)
```

```typescript
// ✅ Server Component에서 직접 데이터 페칭
// app/users/page.tsx
import { prisma } from '@/lib/db/prisma'

export default async function UsersPage() {
  const users = await prisma.user.findMany()

  return (
    <div>
      {users.map((user) => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  )
}

// ✅ fetch with cache (기본: 'force-cache')
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 3600 }, // 1시간 캐시
  })
  return res.json()
}
```

### Mutation Flow (쓰기)

```
Form (Client) → Server Action → Prisma → Database
                     ↓
              revalidatePath/revalidateTag
```

```typescript
// ✅ Server Action
// app/_actions/create-user.ts
'use server'

import { prisma } from '@/lib/db/prisma'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.email(),
})

export async function createUser(formData: FormData) {
  // 검증
  const parsed = createUserSchema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
  })

  if (!parsed.success) {
    return { error: parsed.error.errors }
  }

  // DB 저장
  const user = await prisma.user.create({
    data: parsed.data,
  })

  // 캐시 무효화
  revalidatePath('/users')

  return { success: true, user }
}

// ✅ Client Component에서 사용
// app/users/_components/user-form.tsx
'use client'

import { createUser } from '@/app/_actions/create-user'

export default function UserForm() {
  async function handleSubmit(formData: FormData) {
    const result = await createUser(formData)

    if (result.error) {
      console.error(result.error)
    } else {
      console.log('User created:', result.user)
    }
  }

  return (
    <form action={handleSubmit}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create</button>
    </form>
  )
}
```

</data_flow>

---

<server_actions_advanced>

## Server Actions (Advanced)

### Server Actions 패턴

| 패턴 | 설명 | 사용 시점 |
|------|------|----------|
| **Form Actions** | `<form action={...}>` | 폼 제출 |
| **Programmatic** | `onClick={() => action()}` | 버튼 클릭 |
| **Progressive Enhancement** | JS 없이도 동작 | 접근성 중시 |

```typescript
// ✅ Form Action (Progressive Enhancement)
// app/_actions/delete-user.ts
'use server'

import { prisma } from '@/lib/db/prisma'
import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'

export async function deleteUser(formData: FormData) {
  const id = formData.get('id') as string

  await prisma.user.delete({
    where: { id },
  })

  revalidatePath('/users')
  redirect('/users')
}

// app/users/[id]/_components/delete-button.tsx
'use client'

import { deleteUser } from '@/app/_actions/delete-user'

export default function DeleteButton({ id }: { id: string }) {
  return (
    <form action={deleteUser}>
      <input type="hidden" name="id" value={id} />
      <button type="submit">Delete</button>
    </form>
  )
}

// ✅ Programmatic Action
// app/users/_components/user-list.tsx
'use client'

import { useState, useTransition } from 'react'
import { deleteUser } from '@/app/_actions/delete-user'

export default function UserList({ users }) {
  const [isPending, startTransition] = useTransition()

  function handleDelete(id: string) {
    startTransition(async () => {
      const formData = new FormData()
      formData.append('id', id)
      await deleteUser(formData)
    })
  }

  return (
    <div>
      {users.map((user) => (
        <div key={user.id}>
          {user.name}
          <button
            onClick={() => handleDelete(user.id)}
            disabled={isPending}
          >
            Delete
          </button>
        </div>
      ))}
    </div>
  )
}
```

### 인증 패턴

```typescript
// ✅ lib/auth/session.ts
import { cookies } from 'next/headers'

export async function getSession() {
  const cookieStore = await cookies()
  const session = cookieStore.get('session')
  // 세션 검증 로직
  return session
}

// ✅ Server Action에서 인증 체크
// app/_actions/create-post.ts
'use server'

import { getSession } from '@/lib/auth/session'
import { prisma } from '@/lib/db/prisma'
import { redirect } from 'next/navigation'

export async function createPost(formData: FormData) {
  const session = await getSession()

  if (!session?.user) {
    redirect('/login')
  }

  const post = await prisma.post.create({
    data: {
      title: formData.get('title') as string,
      authorId: session.user.id,
    },
  })

  return { success: true, post }
}
```

</server_actions_advanced>

---

<metadata>

## Metadata

### Static Metadata

```typescript
// ✅ Static metadata export
// app/users/page.tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Users',
  description: 'User list page',
}

export default function UsersPage() {
  return <div>Users</div>
}
```

### Dynamic Metadata

```typescript
// ✅ Dynamic metadata with generateMetadata
// app/users/[id]/page.tsx
import { Metadata } from 'next'
import { prisma } from '@/lib/db/prisma'

type Props = {
  params: Promise<{ id: string }>
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params
  const user = await prisma.user.findUnique({ where: { id } })

  return {
    title: user?.name ?? 'User',
    description: `Profile of ${user?.name}`,
  }
}

export default async function UserPage({ params }: Props) {
  const { id } = await params
  const user = await prisma.user.findUnique({ where: { id } })

  return <div>{user?.name}</div>
}
```

</metadata>

---

<caching>

## Caching

### fetch() 캐싱

| 옵션 | 설명 |
|------|------|
| `{ cache: 'force-cache' }` | 기본값, 무기한 캐시 |
| `{ cache: 'no-store' }` | 캐시 사용 안 함 |
| `{ next: { revalidate: 3600 } }` | 3600초마다 재검증 |
| `{ next: { tags: ['users'] } }` | 태그 기반 무효화 |

```typescript
// ✅ fetch with cache
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 3600, tags: ['users'] },
  })
  return res.json()
}

// ✅ 캐시 무효화
// app/_actions/create-user.ts
'use server'

import { revalidateTag, revalidatePath } from 'next/cache'

export async function createUser(data: any) {
  // ...

  // 태그 기반 무효화
  revalidateTag('users')

  // 경로 기반 무효화
  revalidatePath('/users')
}
```

### unstable_cache (Prisma 등)

```typescript
// ✅ Prisma 쿼리 캐싱
import { unstable_cache } from 'next/cache'
import { prisma } from '@/lib/db/prisma'

const getUsers = unstable_cache(
  async () => prisma.user.findMany(),
  ['users'],
  {
    revalidate: 3600,
    tags: ['users'],
  }
)

export default async function UsersPage() {
  const users = await getUsers()
  return <div>{/* ... */}</div>
}
```

</caching>

---

<tech_stack>

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Next.js | 15+ |
| Router | App Router | - |
| Data | TanStack Query | 5.x |
| ORM | Prisma | 7.x |
| Validation | Zod | 4.x |
| Database | PostgreSQL | - |
| UI | React 19+ | - |

</tech_stack>

---

## Sources

- [Next.js App Router Documentation](https://nextjs.org/docs/app)
- [Next.js Project Structure Guide](https://nextjs.org/docs/app/getting-started/project-structure)
- [Next.js 15 App Router Best Practices (Medium)](https://medium.com/better-dev-nextjs-react/inside-the-app-router-best-practices-for-next-js-file-and-directory-structure-2025-edition-ed6bc14a8da3)
- [Mastering Next.js App Router (Medium)](https://thiraphat-ps-dev.medium.com/mastering-next-js-app-router-best-practices-for-structuring-your-application-3f8cf0c76580)
- [Modern Full Stack Architecture with Next.js 15+](https://softwaremill.com/modern-full-stack-application-architecture-using-next-js-15/)
