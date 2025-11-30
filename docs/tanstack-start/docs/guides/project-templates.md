# Project Templates

TanStack Start 프로젝트 템플릿 및 구조 가이드입니다.

## TanStack Start Project Structure

### Base Structure

```
my-app/
├── src/
│   ├── routes/                     # 파일 기반 라우팅
│   │   ├── __root.tsx              # Root layout
│   │   ├── index.tsx               # Home (/)
│   │   ├── about.tsx               # /about
│   │   ├── users/
│   │   │   ├── index.tsx           # /users
│   │   │   ├── $id.tsx             # /users/:id
│   │   │   ├── -components/        # 페이지 전용 컴포넌트
│   │   │   │   └── user-card.tsx
│   │   │   ├── -sections/          # 섹션 분리
│   │   │   │   ├── user-list-section.tsx
│   │   │   │   └── user-form-section.tsx
│   │   │   └── -hooks/             # 페이지 전용 훅
│   │   │       └── use-users.ts
│   │   └── api/
│   │       └── health.ts           # API route
│   ├── components/                 # 공통 컴포넌트
│   │   └── ui/
│   │       ├── button.tsx
│   │       ├── input.tsx
│   │       └── modal.tsx
│   ├── database/                   # 데이터베이스 관련
│   │   ├── prisma.ts               # Prisma Client 인스턴스
│   │   └── seed.ts                 # 시드 데이터 (선택)
│   ├── services/                   # 도메인별 SDK/서비스 레이어
│   │   ├── user/
│   │   │   ├── index.ts            # 진입점 (re-export)
│   │   │   ├── schemas.ts          # Zod 스키마
│   │   │   ├── queries.ts          # GET 요청
│   │   │   └── mutations.ts        # POST 요청
│   │   ├── auth/
│   │   │   ├── index.ts
│   │   │   ├── schemas.ts
│   │   │   ├── queries.ts
│   │   │   └── mutations.ts
│   │   └── post/
│   │       ├── index.ts
│   │       ├── schemas.ts
│   │       ├── queries.ts
│   │       └── mutations.ts
│   ├── lib/                        # 공통 유틸리티
│   │   ├── query-client.ts
│   │   └── utils.ts
│   ├── hooks/                      # 공통 훅
│   │   ├── use-auth.ts
│   │   └── use-media-query.ts
│   ├── types/                      # 타입 정의
│   │   └── index.ts
│   └── styles/
│       └── app.css
├── generated/
│   └── prisma/                     # Prisma Client 출력
├── prisma/
│   └── schema.prisma
├── public/
├── app.config.ts
├── package.json
├── tsconfig.json
└── tailwind.config.ts
```

## Route Folder Convention

### `-` 접두사 규칙

TanStack Start에서 `-` 접두사가 있는 폴더는 라우트에서 제외됩니다:

```
routes/users/
├── index.tsx           # /users ✅ 라우트
├── $id.tsx             # /users/:id ✅ 라우트
├── route.tsx           # route 설정 (선택)
├── -components/        # ❌ 라우트 아님, 컴포넌트
├── -sections/          # ❌ 라우트 아님, 섹션
└── -hooks/             # ❌ 라우트 아님, 훅
```

### Route with Sections

복잡한 페이지는 섹션으로 분리:

```
routes/dashboard/
├── index.tsx
├── -sections/
│   ├── stats-section.tsx
│   ├── recent-activity-section.tsx
│   └── quick-actions-section.tsx
├── -components/
│   ├── stat-card.tsx
│   └── activity-item.tsx
└── -hooks/
    ├── use-dashboard-stats.ts
    └── use-recent-activity.ts
```

## Route Patterns

### Basic Route

```tsx
// routes/about.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/about')({
  component: AboutPage,
})

const AboutPage = (): JSX.Element => {
  return <h1>About</h1>
}
```

### Route with Sections and Hooks

```tsx
// routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { UserListSection } from './-sections/user-list-section'
import { UserFilterSection } from './-sections/user-filter-section'

export const Route = createFileRoute('/users/')({
  component: UsersPage,
})

const UsersPage = (): JSX.Element => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <UserFilterSection />
      <UserListSection />
    </div>
  )
}
```

### Page Hook

```typescript
// routes/users/-hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/services/user'
import type { User } from '@/types'

interface UseUsersReturn {
  users: User[] | undefined
  isLoading: boolean
  error: Error | null
  createUser: (data: { email: string; name: string }) => void
  deleteUser: (id: string) => void
  isCreating: boolean
  isDeleting: boolean
}

export const useUsers = (): UseUsersReturn => {
  const queryClient = useQueryClient()

  const { data: users, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUsers(),
  })

  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  return {
    users,
    isLoading,
    error,
    createUser: createMutation.mutate,
    deleteUser: deleteMutation.mutate,
    isCreating: createMutation.isPending,
    isDeleting: deleteMutation.isPending,
  }
}
```

### Section Component

```tsx
// routes/users/-sections/user-list-section.tsx
import { useUsers } from '../-hooks/use-users'
import { UserCard } from '../-components/user-card'

export const UserListSection = (): JSX.Element => {
  const { users, isLoading, error, deleteUser, isDeleting } = useUsers()

  if (isLoading) {
    return <div className="text-center py-8">Loading...</div>
  }

  if (error) {
    return <div className="text-red-600 py-8">Error: {error.message}</div>
  }

  if (!users?.length) {
    return <div className="text-gray-500 py-8">No users found</div>
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {users.map((user) => (
        <UserCard
          key={user.id}
          user={user}
          onDelete={deleteUser}
          isDeleting={isDeleting}
        />
      ))}
    </div>
  )
}
```

### Page Component

```tsx
// routes/users/-components/user-card.tsx
import type { User } from '@/types'
import { Button } from '@/components/ui/button'

interface UserCardProps {
  user: User
  onDelete?: (id: string) => void
  isDeleting?: boolean
}

export const UserCard = ({
  user,
  onDelete,
  isDeleting,
}: UserCardProps): JSX.Element => {
  return (
    <div className="rounded-lg border p-4 shadow-sm">
      <div className="flex items-center gap-4">
        <div className="h-12 w-12 rounded-full bg-gray-200" />
        <div>
          <h3 className="font-semibold">{user.name}</h3>
          <p className="text-sm text-gray-600">{user.email}</p>
        </div>
      </div>

      {onDelete && (
        <div className="mt-4">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onDelete(user.id)}
            disabled={isDeleting}
          >
            {isDeleting ? 'Deleting...' : 'Delete'}
          </Button>
        </div>
      )}
    </div>
  )
}
```

### Dynamic Route

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'
import { UserDetailSection } from './-sections/user-detail-section'
import { UserPostsSection } from './-sections/user-posts-section'

export const Route = createFileRoute('/users/$id')({
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const { id } = Route.useParams()

  return (
    <div className="container mx-auto p-4">
      <UserDetailSection userId={id} />
      <UserPostsSection userId={id} />
    </div>
  )
}
```

### Layout Route

```tsx
// routes/dashboard/_layout.tsx
import { createFileRoute, Outlet } from '@tanstack/react-router'
import { DashboardSidebar } from './-components/dashboard-sidebar'

export const Route = createFileRoute('/dashboard/_layout')({
  component: DashboardLayout,
})

const DashboardLayout = (): JSX.Element => {
  return (
    <div className="flex">
      <DashboardSidebar />
      <main className="flex-1 p-4">
        <Outlet />
      </main>
    </div>
  )
}
```

## Component Templates

### Common UI Component

```tsx
// components/ui/button.tsx
interface ButtonProps {
  children: React.ReactNode
  variant?: 'primary' | 'secondary' | 'outline'
  size?: 'sm' | 'md' | 'lg'
  onClick?: () => void
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
}

export const Button = ({
  children,
  variant = 'primary',
  size = 'md',
  onClick,
  disabled,
  type = 'button',
}: ButtonProps): JSX.Element => {
  const baseStyles = 'rounded font-medium transition-colors disabled:opacity-50'

  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
    outline: 'border border-gray-300 hover:bg-gray-50',
  }

  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  }

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`${baseStyles} ${variants[variant]} ${sizes[size]}`}
    >
      {children}
    </button>
  )
}
```

### Modal Component

```tsx
// components/ui/modal.tsx
import { useCallback, useEffect } from 'react'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  children: React.ReactNode
}

export const Modal = ({
  isOpen,
  onClose,
  title,
  children,
}: ModalProps): JSX.Element | null => {
  const handleEscape = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    },
    [onClose]
  )

  useEffect(() => {
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [handleEscape])

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div
        className="absolute inset-0 bg-black/50"
        onClick={onClose}
      />
      <div className="relative z-10 w-full max-w-md rounded-lg bg-white p-6 shadow-lg">
        <h2 className="text-xl font-semibold mb-4">{title}</h2>
        {children}
      </div>
    </div>
  )
}
```

## Service Templates

### Database Setup

```typescript
// database/prisma.ts
import { PrismaClient } from '../../generated/prisma'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

### Service 폴더 구조

```
services/
├── user/
│   ├── index.ts            # 진입점 (re-export)
│   ├── schemas.ts          # Zod 스키마
│   ├── queries.ts          # GET 요청 (읽기)
│   └── mutations.ts        # POST 요청 (쓰기)
├── auth/
│   ├── index.ts
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
└── post/
    ├── index.ts
    ├── schemas.ts
    ├── queries.ts
    └── mutations.ts
```

### Schemas 파일

```typescript
// services/user/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1).max(100).trim(),
})

export const updateUserSchema = z.object({
  id: z.string(),
  email: z.email().optional(),
  name: z.string().min(1).max(100).trim().optional(),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

### Queries 파일

```typescript
// services/user/queries.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'

export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
    })
  })

export const getUserById = createServerFn({ method: 'GET' })
  .handler(async ({ data: id }: { data: string }) => {
    const user = await prisma.user.findUnique({ where: { id } })
    if (!user) throw new Error('User not found')
    return user
  })

export const getUserByEmail = createServerFn({ method: 'GET' })
  .handler(async ({ data: email }: { data: string }) => {
    return prisma.user.findUnique({ where: { email } })
  })
```

### Mutations 파일

```typescript
// services/user/mutations.ts
import { createServerFn } from '@tanstack/react-start'
import { prisma } from '@/database/prisma'
import { createUserSchema, updateUserSchema } from './schemas'

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })

export const updateUser = createServerFn({ method: 'POST' })
  .inputValidator(updateUserSchema)
  .handler(async ({ data }) => {
    const { id, ...updateData } = data
    return prisma.user.update({ where: { id }, data: updateData })
  })

export const deleteUser = createServerFn({ method: 'POST' })
  .handler(async ({ data: id }: { data: string }) => {
    return prisma.user.delete({ where: { id } })
  })
```

### Service 진입점

```typescript
// services/user/index.ts
export * from './schemas'
export * from './queries'
export * from './mutations'
```

## Common Hook Templates

### Auth Hook

```typescript
// hooks/use-auth.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getCurrentUser, login, logout } from '@/services/auth'
import type { User, LoginInput } from '@/types'

interface UseAuthReturn {
  user: User | null | undefined
  isLoading: boolean
  isAuthenticated: boolean
  login: (data: LoginInput) => void
  logout: () => void
  isLoggingIn: boolean
}

export const useAuth = (): UseAuthReturn => {
  const queryClient = useQueryClient()

  const { data: user, isLoading } = useQuery({
    queryKey: ['auth', 'user'],
    queryFn: () => getCurrentUser(),
    retry: false,
  })

  const loginMutation = useMutation({
    mutationFn: login,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['auth'] })
    },
  })

  const logoutMutation = useMutation({
    mutationFn: logout,
    onSuccess: () => {
      queryClient.setQueryData(['auth', 'user'], null)
      queryClient.invalidateQueries({ queryKey: ['auth'] })
    },
  })

  return {
    user,
    isLoading,
    isAuthenticated: !!user,
    login: loginMutation.mutate,
    logout: logoutMutation.mutate,
    isLoggingIn: loginMutation.isPending,
  }
}
```

## Database Schema Template

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum Role {
  USER
  ADMIN
}
```

## Configuration Templates

### Tailwind Config

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

export default {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },
    },
  },
  plugins: [],
} satisfies Config
```

### TypeScript Config

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*", "*.config.ts"]
}
```

### Environment Schema

```typescript
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.url(),
  API_SECRET: z.string().min(32),
})

export const env = envSchema.parse(process.env)
```
