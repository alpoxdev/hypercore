# 라우트 구조

> TanStack Start 파일 기반 라우팅

<instructions>
@../library/tanstack-router/index.md
</instructions>

---

<route_structure>

## 라우트 폴더 구조

```
routes/
├── __root.tsx           # Root Layout
├── index.tsx            # / (Home)
├── users/
│   ├── index.tsx        # /users (List)
│   ├── $id.tsx          # /users/:id (Detail)
│   ├── -components/     # 페이지 전용 컴포넌트 (필수)
│   ├── -hooks/          # 페이지 전용 Hook (필수)
│   ├── -functions/      # 페이지 전용 Server Functions (필수)
│   └── -sections/       # 섹션 분리 (선택, 복잡한 경우만)
└── posts/
    ├── index.tsx
    ├── $slug.tsx
    ├── -components/     # 필수
    ├── -hooks/          # 필수
    └── -functions/      # 필수
```

| 접두사 | 용도 | 라우트 생성 |
|--------|------|-----------|
| `-` | 라우트 제외 폴더 | ❌ 제외 |
| `$` | 동적 파라미터 | ✅ 생성 |
| `_` | Pathless Layout | ✅ 생성 (경로 없음) |

**⚠️ 필수 규칙:**
- 모든 페이지에 `-components/`, `-hooks/`, `-functions/` 폴더 **필수**
- 페이지 크기(줄 수)와 **무관**하게 Custom Hook은 반드시 `-hooks/` 폴더에 분리
- `-sections/`는 200줄 이상 복잡한 페이지에서만 선택적 사용

</route_structure>

---

<file_naming>

## 라우트 파일명 규칙

| 경로 | 파일명 | 설명 |
|------|--------|------|
| `/` | `index.tsx` | 인덱스 라우트 |
| `/users` | `users/index.tsx` | 목록 페이지 |
| `/users/:id` | `users/$id.tsx` | 동적 파라미터 |
| `/posts/:slug` | `posts/$slug.tsx` | URL 파라미터 |
| `/dashboard/*` | `dashboard/$.tsx` | Catch-all 라우트 |
| Layout | `__root.tsx` | Root 레이아웃 |
| Pathless | `_layout.tsx` | 경로 없는 레이아웃 |

</file_naming>

---

<patterns>

## 기본 라우트 패턴

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

## 동적 라우트 + Loader

```tsx
// routes/users/$id.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getUserById } from '@/services/user'

export const Route = createFileRoute('/users/$id')({
  loader: ({ params: { id } }) => getUserById({ data: id }),
  component: UserDetailPage,
})

const UserDetailPage = (): JSX.Element => {
  const user = Route.useLoaderData()

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

## Loader with Dependencies

```tsx
// routes/posts/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPosts } from '@/services/post'
import { z } from 'zod'

const postsSearchSchema = z.object({
  offset: z.number().default(0),
  limit: z.number().default(10),
})

export const Route = createFileRoute('/posts/')({
  validateSearch: postsSearchSchema,
  loaderDeps: ({ search: { offset, limit } }) => ({ offset, limit }),
  loader: ({ deps: { offset, limit } }) => getPosts({ data: { offset, limit } }),
  component: PostsPage,
})

const PostsPage = (): JSX.Element => {
  const posts = Route.useLoaderData()
  const { offset, limit } = Route.useSearch()

  return (
    <div>
      <h1>Posts (offset: {offset}, limit: {limit})</h1>
      {posts.map((post) => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

## Deferred Data Loading

```tsx
// routes/dashboard/index.tsx
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'
import { getFastData, getSlowData } from '@/services/dashboard'

export const Route = createFileRoute('/dashboard/')({
  loader: async () => {
    const slowDataPromise = getSlowData()
    const fastData = await getFastData()

    return {
      fastData,
      deferredSlowData: slowDataPromise,
    }
  },
  component: DashboardPage,
})

const DashboardPage = (): JSX.Element => {
  const { fastData, deferredSlowData } = Route.useLoaderData()

  return (
    <div>
      <h1>Fast Data</h1>
      <pre>{JSON.stringify(fastData, null, 2)}</pre>

      <h1>Slow Data (Deferred)</h1>
      <Suspense fallback={<div>Loading slow data...</div>}>
        <Await promise={deferredSlowData}>
          {(slowData) => <pre>{JSON.stringify(slowData, null, 2)}</pre>}
        </Await>
      </Suspense>
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

</patterns>

---

<folder_structure_rules>

## 폴더 구조 규칙

**⚠️ 모든 페이지에 필수:**
- `-components/`: 페이지 전용 컴포넌트
- `-hooks/`: 페이지 전용 Custom Hook (줄 수 무관)
- `-functions/`: 페이지 전용 Server Functions

**선택적 사용:**
- `-sections/`: 200줄+ 복잡한 페이지에서만 사용

| 페이지 크기 | 필수 | 선택 |
|------------|------|------|
| ~100줄 | `-components/`, `-hooks/`, `-functions/` | - |
| 100-200줄 | `-components/`, `-hooks/`, `-functions/` | - |
| 200줄+ | `-components/`, `-hooks/`, `-functions/` | `-sections/` |

</folder_structure_rules>

---

<loader_execution>

## Loader 실행 순서

| 단계 | 실행 방식 | 설명 |
|------|----------|------|
| 1. `beforeLoad` | 순차 (outermost → innermost) | 인증 체크, 컨텍스트 설정 |
| 2. `loader` | 병렬 (모든 loader 동시) | 데이터 페칭 |

```tsx
// Parent Route
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async () => {
    // 1. 먼저 실행 (순차)
    const auth = await checkAuth()
    return { auth }
  },
  loader: async () => {
    // 2. 나중에 실행 (병렬)
    return getDashboardData()
  },
})

// Child Route
export const Route = createFileRoute('/dashboard/users')({
  beforeLoad: async () => {
    // 1. Parent beforeLoad 다음 실행
    return {}
  },
  loader: async () => {
    // 2. Parent loader와 병렬 실행
    return getUsers()
  },
})
```

</loader_execution>

---

<sources>

- [TanStack Router Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
- [TanStack Router Deferred Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/deferred-data-loading)
- [TanStack Router File-Based Routing](https://tanstack.com/router/latest/docs/framework/react/guide/file-based-routing)

</sources>
