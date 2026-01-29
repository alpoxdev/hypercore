# Architecture

> Next.js App Router Application Architecture

<instructions>
@library/nextjs/app-router.md
@library/nextjs/server-actions.md
@library/nextjs/middleware.md
@library/prisma/index.md
</instructions>

---

<forbidden>

| Category | Forbidden |
|----------|-----------|
| **Routes** | Flat file routes (`app/users.tsx`), Pages Router (`pages/`) |
| **Route Export** | Named export (`export const Page`), incorrect file names (`Users.tsx`) |
| **API** | Pages Router API (`pages/api/`), API Routes overuse (use Server Actions) |
| **Layers** | Writing business logic directly in app/ folder |
| **Components** | Using client-only APIs without 'use client' |
| **Barrel Export** | Creating `actions/index.ts` (Tree Shaking fails) |

</forbidden>

---

<required>

| Category | Required |
|----------|----------|
| **Route Structure** | Create folder per page (`app/users/page.tsx`) |
| **Route Export** | `export default function Page()` required |
| **Layer Structure** | app/ → Server Actions → lib/ → Database |
| **Route Group** | List pages → `(main)/`, Admin → `(admin)/` |
| **Page-specific Folders** | `_components/`, `_hooks/`, `_actions/` required (regardless of line count) |
| **Page Separation** | 100+ lines → `_components/`, 200+ lines → `_sections/` |
| **Server Actions** | Use Server Actions for mutations (`'use server'`) |
| **Validation** | Validate input with Zod schemas |
| **Metadata** | Export `generateMetadata` or `metadata` |
| **Error Handling** | `error.tsx` (route), `not-found.tsx` (404), `global-error.tsx` (global) |
| **Type Safety** | TypeScript strict, Prisma types |

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
│  │              Server Components (default)                    │ │
│  │   app/[route]/page.tsx → Server-side rendering             │ │
│  └────────────────────────────┬───────────────────────────────┘ │
│  ┌────────────────────────────▼───────────────────────────────┐ │
│  │                    Server Actions                           │ │
│  │   'use server' → DB access, Mutations, Revalidation        │ │
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

## Route Export Rules

> ⚠️ **`export default` required**
>
> Next.js App Router requires all page/layout files to export components as **default export**.
>
> File names must follow Next.js conventions: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`

| ❌ Forbidden | ✅ Required |
|--------------|-------------|
| `app/users.tsx` | `app/users/page.tsx` |
| `export const Page = () => {}` | `export default function Page() {}` |
| `export default Users` (component name != file convention) | `export default function UsersPage() {}` |

```typescript
// ❌ Forbidden: Flat file
// app/users.tsx
export default function Users() {
  return <div>Users</div>
}

// ❌ Forbidden: named export
// app/users/page.tsx
export const Page = () => {
  return <div>Users</div>
}

// ✅ Required: folder + page.tsx + default export
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

> ⚠️ **Create folder per page (required)**
>
> Every page MUST be created using **folder structure**. Flat file approach (`app/users.tsx`) is forbidden.
>
> **Reason:** To systematically manage page-specific resources like `_components/`, `_hooks/`, `_actions/`.
>
> | ❌ Forbidden | ✅ Required |
> |--------------|-------------|
> | `app/users.tsx` | `app/users/page.tsx` |
> | `app/posts.tsx` | `app/(main)/posts/page.tsx` |

```
app/<route-name>/
├── (main)/                # route group (list page, not in URL)
│   ├── page.tsx           # page component
│   ├── _components/       # page-specific components (required)
│   ├── _hooks/            # page-specific hooks (required)
│   ├── _sections/         # UI section separation (200+ line pages)
│   └── _tabs/             # tab content separation
├── new/                   # creation page (outside route group)
│   └── page.tsx
├── [id]/                  # Dynamic segment
│   └── page.tsx
├── layout.tsx             # layout (shared across child routes)
├── loading.tsx            # loading UI (Suspense boundary)
├── error.tsx              # error UI (Error boundary)
└── _actions/              # page-specific Server Actions (required)
```

**Required Rules:**
- Each page MUST have `_components/`, `_hooks/`, `_actions/` folders (regardless of line count)
- Custom Hooks MUST be separated into `_hooks/` folder regardless of page size
- Server Actions: global (`app/_actions/`) or page-specific (`[route]/_actions/`)
- Shared components → `components/ui/`, page-specific → `[route]/_components/`

| Pattern | Location | Purpose |
|---------|----------|---------|
| **Route Group** | `(main)/` | List page, not in URL |
| **Private Folder** | `_components/` | Ignored by routing system |
| **_sections/** | 200+ lines | Logical section separation |
| **_tabs/** | Tab UI | Tab content separation |
| **layout.tsx** | Layout | Shared UI for child routes |

#### Layout Routes Pattern

> ⚠️ **Compose layouts with layout.tsx**
>
> `layout.tsx` serves as the common layout for child routes.
> List pages should be wrapped in Route Group `(main)/`.
>
> | ❌ Forbidden | ✅ Required |
> |--------------|-------------|
> | `app/auth.tsx` | `app/(auth)/layout.tsx` + `app/(auth)/(main)/page.tsx` |

```
app/
├── (auth)/
│   ├── layout.tsx            # layout (renders children)
│   ├── (main)/
│   │   └── page.tsx          # /auth (main)
│   ├── login/
│   │   └── page.tsx          # /auth/login
│   └── register/
│       └── page.tsx          # /auth/register
```

```typescript
// ❌ Forbidden: flat structure without layout
// app/auth/page.tsx
export default function AuthPage() {
  return <div>Auth</div>
}

// ✅ Required: wrap common UI with layout.tsx
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
app/_actions/                # global (reusable)
├── <action-name>.ts         # one per file
└── types.ts                 # shared types

app/<route>/_actions/        # page-specific
└── <action-name>.ts
```

> ⚠️ **Do NOT create `app/_actions/index.ts`**
>
> Do not create `index.ts` (barrel export) file in `app/_actions/` folder.
>
> **Problems:**
> 1. **Tree Shaking fails** - bundler includes unused functions
> 2. **Client bundle pollution** - server-only libraries like `prisma` get included in client bundle causing build errors
>
> ```typescript
> // ❌ Do NOT create app/_actions/index.ts
> export * from './get-users'
> export * from './create-post'  // prisma import → client build failure
>
> // ✅ Import directly from individual files
> import { getUsers } from '@/app/_actions/get-users'
> import { createPost } from '@/app/_actions/create-post'
> ```

### 3. Services Layer

```
lib/<domain>/
├── index.ts            # entry point (re-export)
├── schemas.ts          # Zod schemas
├── queries.ts          # GET requests
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

| Item | Server Components | Client Components |
|------|------------------|-------------------|
| **Default** | ✅ Default (no declaration needed) | ❌ `'use client'` required |
| **Execution** | Server | Browser |
| **Data Fetching** | async/await direct usage | TanStack Query/SWR |
| **DB Access** | ✅ Possible | ❌ Impossible (use Server Actions) |
| **Browser API** | ❌ Impossible | ✅ Possible (window, localStorage, etc.) |
| **State Management** | ❌ Impossible | ✅ Possible (useState, useEffect, etc.) |
| **Event Handlers** | ❌ Impossible | ✅ Possible (onClick, onChange, etc.) |

```typescript
// ✅ Server Component (default)
// app/users/page.tsx
import { prisma } from '@/lib/db/prisma'

export default async function UsersPage() {
  // Direct DB query on server
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

### Component Composition Strategy

```
Page (Server Component)
  ├─ Data fetching (async/await)
  └─ Interactive UI (Client Component)
       └─ State management, event handlers
```

</component_types>

---

<route_lifecycle>

## Route Lifecycle

### Loading & Error Handling

| File | Purpose | Required |
|------|---------|----------|
| **loading.tsx** | Loading UI (Suspense boundary) | Optional |
| **error.tsx** | Error UI (Error boundary) | ✅ |
| **not-found.tsx** | 404 UI | ✅ |
| **global-error.tsx** | Global error UI | Optional |

```
app/
├── layout.tsx
├── loading.tsx          # global loading
├── error.tsx            # global error
├── not-found.tsx        # global 404
├── global-error.tsx     # root error (catches layout.tsx errors too)
└── users/
    ├── page.tsx
    ├── loading.tsx      # /users loading
    └── error.tsx        # /users error
```

### Code Patterns

```typescript
// ✅ loading.tsx: loading UI
export default function Loading() {
  return <div>Loading...</div>
}

// ✅ error.tsx: error UI (Client Component required)
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

### Query Flow (Read)

```
Page (Server Component) → Prisma → Database
          ↓
    Auto caching (fetch cache)
```

```typescript
// ✅ Direct data fetching in Server Component
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

// ✅ fetch with cache (default: 'force-cache')
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 3600 }, // 1 hour cache
  })
  return res.json()
}
```

### Mutation Flow (Write)

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
  // Validation
  const parsed = createUserSchema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
  })

  if (!parsed.success) {
    return { error: parsed.error.errors }
  }

  // DB save
  const user = await prisma.user.create({
    data: parsed.data,
  })

  // Cache invalidation
  revalidatePath('/users')

  return { success: true, user }
}

// ✅ Usage in Client Component
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

### Server Actions Patterns

| Pattern | Description | When to Use |
|---------|-------------|-------------|
| **Form Actions** | `<form action={...}>` | Form submission |
| **Programmatic** | `onClick={() => action()}` | Button click |
| **Progressive Enhancement** | Works without JS | Accessibility focus |

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

### Authentication Pattern

```typescript
// ✅ lib/auth/session.ts
import { cookies } from 'next/headers'

export async function getSession() {
  const cookieStore = await cookies()
  const session = cookieStore.get('session')
  // Session validation logic
  return session
}

// ✅ Authentication check in Server Action
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

### fetch() Caching

| Option | Description |
|--------|-------------|
| `{ cache: 'force-cache' }` | Default, cache indefinitely |
| `{ cache: 'no-store' }` | No caching |
| `{ next: { revalidate: 3600 } }` | Revalidate every 3600 seconds |
| `{ next: { tags: ['users'] } }` | Tag-based invalidation |

```typescript
// ✅ fetch with cache
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 3600, tags: ['users'] },
  })
  return res.json()
}

// ✅ Cache invalidation
// app/_actions/create-user.ts
'use server'

import { revalidateTag, revalidatePath } from 'next/cache'

export async function createUser(data: any) {
  // ...

  // Tag-based invalidation
  revalidateTag('users')

  // Path-based invalidation
  revalidatePath('/users')
}
```

### unstable_cache (Prisma, etc.)

```typescript
// ✅ Prisma query caching
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
