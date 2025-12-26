# 라우트 구조

TanStack Start 파일 기반 라우팅 패턴.

## Route 폴더 구조

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

## `-` 접두사

`-` 접두사가 있는 폴더는 라우트에서 제외:

```
routes/users/
├── index.tsx          # /users ✅ 라우트
├── $id.tsx            # /users/:id ✅ 라우트
├── -components/       # ❌ 라우트 아님
├── -sections/         # ❌ 라우트 아님
└── -hooks/            # ❌ 라우트 아님
```

## 기본 Route 패턴

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

## Section 패턴

```tsx
// routes/users/-sections/user-list-section.tsx
import { useUsers } from '../-hooks/use-users'
import { UserCard } from '../-components/user-card'

export const UserListSection = (): JSX.Element => {
  const { users, isLoading, error, deleteUser, isDeleting } = useUsers()

  if (isLoading) return <div className="text-center py-8">Loading...</div>
  if (error) return <div className="text-red-600 py-8">Error: {error.message}</div>
  if (!users?.length) return <div className="text-gray-500 py-8">No users found</div>

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

## Filter Section 패턴

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

## 컴포넌트 패턴

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
