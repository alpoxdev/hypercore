# Best Practices

TanStack Start 애플리케이션 개발을 위한 모범 사례 가이드입니다.

## File Naming Convention

**모든 파일은 kebab-case**:

```
✅ user-profile.tsx
✅ auth-service.ts
✅ use-user-filter.ts
✅ user-list-section.tsx

❌ UserProfile.tsx
❌ authService.ts
❌ useUserFilter.ts
```

## Route Folder Structure

### 기본 구조

```
routes/<route-name>/
├── index.tsx              # 페이지 컴포넌트
├── route.tsx              # route 설정 (필요시)
├── -components/           # 페이지 전용 컴포넌트
│   ├── user-card.tsx
│   └── user-form.tsx
├── -sections/             # 섹션 분리 (복잡한 경우)
│   ├── user-list-section.tsx
│   └── user-filter-section.tsx
└── -hooks/                # 페이지 전용 훅
    ├── use-users.ts
    └── use-user-filter.ts
```

### TanStack Start `-` 접두사

`-` 접두사가 있는 폴더는 라우트에서 제외됩니다:

```
routes/users/
├── index.tsx          # /users ✅ 라우트
├── $id.tsx            # /users/:id ✅ 라우트
├── -components/       # ❌ 라우트 아님
├── -sections/         # ❌ 라우트 아님
└── -hooks/            # ❌ 라우트 아님
```

## Project Organization

### 전체 폴더 구조

```
src/
├── routes/                 # 파일 기반 라우팅
│   ├── __root.tsx
│   ├── index.tsx
│   └── users/
│       ├── index.tsx
│       ├── -components/
│       ├── -sections/
│       └── -hooks/
├── components/             # 공통 컴포넌트
│   └── ui/
│       ├── button.tsx
│       ├── input.tsx
│       └── modal.tsx
├── database/               # 데이터베이스 관련
│   ├── prisma.ts           # Prisma Client 인스턴스
│   └── seed.ts             # 시드 데이터 (필요시)
├── services/               # 도메인별 SDK/서비스 레이어
│   ├── user/
│   │   ├── index.ts        # 진입점 (re-export)
│   │   ├── schemas.ts      # Zod 스키마
│   │   ├── queries.ts      # GET 요청 (읽기)
│   │   └── mutations.ts    # POST 요청 (쓰기)
│   ├── auth/
│   │   ├── index.ts
│   │   ├── schemas.ts
│   │   ├── queries.ts
│   │   └── mutations.ts
│   └── post/
│       ├── index.ts
│       ├── schemas.ts
│       ├── queries.ts
│       └── mutations.ts
├── lib/                    # 공통 유틸리티
│   ├── query-client.ts
│   ├── utils.ts
│   └── constants.ts
├── hooks/                  # 공통 훅
│   ├── use-auth.ts
│   └── use-media-query.ts
└── types/                  # 타입 정의
    └── index.ts
```

### Database 폴더 구조

```
database/
├── prisma.ts               # Prisma Client 싱글톤
└── seed.ts                 # 시드 스크립트 (선택)
```

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

### Services 폴더 구조

```
services/
├── user/                   # User 도메인
│   ├── index.ts            # 진입점 (re-export)
│   ├── schemas.ts          # Zod 스키마
│   ├── queries.ts          # GET 요청 (읽기)
│   └── mutations.ts        # POST 요청 (쓰기)
├── auth/                   # Auth 도메인
│   ├── index.ts
│   ├── schemas.ts
│   ├── queries.ts
│   └── mutations.ts
└── post/                   # Post 도메인
    ├── index.ts
    ├── schemas.ts
    ├── queries.ts
    └── mutations.ts
```

## TypeScript Standards

### Use `const` for Functions

```typescript
// ✅ Preferred
const getUserById = async (id: string): Promise<User> => {
  return prisma.user.findUnique({ where: { id } })
}

// ❌ Avoid
function getUserById(id: string): Promise<User> {
  return prisma.user.findUnique({ where: { id } })
}
```

### Explicit Return Types

```typescript
// ✅ Always specify return types
const formatDate = (date: Date): string => {
  return date.toISOString()
}

// ✅ Component return types
const UserCard = ({ user }: UserCardProps): JSX.Element => {
  return <div>{user.name}</div>
}
```

### No `any` Types

```typescript
// ✅ Use unknown
const parseJSON = (data: string): unknown => {
  return JSON.parse(data)
}

// ❌ Never use any
const parseJSON = (data: string): any => {
  return JSON.parse(data)
}
```

### Import Order

```typescript
// 1. External libraries
import { createFileRoute } from '@tanstack/react-router'
import { useQuery } from '@tanstack/react-query'

// 2. Internal packages
import { Button } from '@/components/ui/button'
import { prisma } from '@/lib/prisma'

// 3. Relative imports (route-specific)
import { UserCard } from './-components/user-card'
import { useUsers } from './-hooks/use-users'

// 4. Type imports
import type { User } from '@/types'
```

## Route Patterns

### Basic Route with Hook

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

### Section with Hook

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

### Filter Section with Hook

```tsx
// routes/users/-sections/user-filter-section.tsx
import { useUserFilter } from '../-hooks/use-user-filter'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export const UserFilterSection = (): JSX.Element => {
  const { search, setSearch, role, setRole, clearFilters } = useUserFilter()

  return (
    <div className="flex gap-4 mb-6">
      <Input
        placeholder="Search users..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="max-w-xs"
      />
      <select
        value={role}
        onChange={(e) => setRole(e.target.value)}
        className="border rounded px-3 py-2"
      >
        <option value="">All Roles</option>
        <option value="USER">User</option>
        <option value="ADMIN">Admin</option>
      </select>
      <Button variant="outline" onClick={clearFilters}>
        Clear
      </Button>
    </div>
  )
}
```

### Filter Hook

```typescript
// routes/users/-hooks/use-user-filter.ts
import { useState, useCallback } from 'react'

interface UseUserFilterReturn {
  search: string
  setSearch: (value: string) => void
  role: string
  setRole: (value: string) => void
  clearFilters: () => void
}

export const useUserFilter = (): UseUserFilterReturn => {
  const [search, setSearch] = useState('')
  const [role, setRole] = useState('')

  const clearFilters = useCallback(() => {
    setSearch('')
    setRole('')
  }, [])

  return {
    search,
    setSearch,
    role,
    setRole,
    clearFilters,
  }
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

## Service Layer

### Service 폴더 구조

도메인별로 폴더를 분리하고, 파일을 용도에 따라 구분합니다:

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

### Service 진입점 파일

```typescript
// services/user/index.ts
export * from './schemas'
export * from './queries'
export * from './mutations'
```

### 사용 예시

```typescript
// routes/users/-hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/services/user'
```

## Common UI Components

### Button Component

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

### Input Component

```tsx
// components/ui/input.tsx
interface InputProps {
  placeholder?: string
  value: string
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void
  type?: 'text' | 'email' | 'password'
  className?: string
  disabled?: boolean
}

export const Input = ({
  placeholder,
  value,
  onChange,
  type = 'text',
  className = '',
  disabled,
}: InputProps): JSX.Element => {
  return (
    <input
      type={type}
      placeholder={placeholder}
      value={value}
      onChange={onChange}
      disabled={disabled}
      className={`border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 ${className}`}
    />
  )
}
```

## Error Handling

### Custom Error Classes

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR'
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND')
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}
```

## Testing

### Test Structure

```typescript
// __tests__/services/user-service.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'

describe('UserService', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('createUser', () => {
    it('creates a user with valid input', async () => {
      const input = { email: 'test@example.com', name: 'Test' }
      const result = await createUser(input)

      expect(result).toMatchObject({
        email: input.email,
        name: input.name,
      })
    })

    it('throws on invalid email', async () => {
      const input = { email: 'invalid', name: 'Test' }

      await expect(createUser(input)).rejects.toThrow()
    })
  })
})
```

## Performance

### React Optimization

```tsx
import { useMemo, useCallback, memo } from 'react'

// Memoize expensive computations
const sortedUsers = useMemo(
  () => users.sort((a, b) => a.name.localeCompare(b.name)),
  [users]
)

// Memoize callbacks
const handleClick = useCallback(() => {
  setIsOpen(true)
}, [])

// Memoize components
export const UserCard = memo(({ user }: { user: User }): JSX.Element => {
  return <div>{user.name}</div>
})
```

## Security

### Environment Variables

- `.env` 파일은 절대 커밋하지 않음
- `.env.example` 제공
- 시작 시 환경변수 검증

### Input Validation

```typescript
import { z } from 'zod'

// Zod v4 API
const userInputSchema = z.object({
  name: z.string().min(1).max(100).trim(),
  email: z.email().toLowerCase(),  // v4: z.email()
})

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.url(),  // v4: z.url()
})

export const env = envSchema.parse(process.env)
```
