# TanStack Patterns

**목적**: TanStack Start, Router, Query 사용 패턴

## TanStack Start

### Server Functions

**기본 패턴:**

```typescript
import { createServerFn } from '@tanstack/start'

// GET 메서드
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => {
    return prisma.user.findMany()
  })

// POST 메서드 + inputValidator
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })

// 인증 + inputValidator
export const updateUser = createServerFn({ method: 'PUT' })
  .middleware([authMiddleware])
  .inputValidator(updateUserSchema)
  .handler(async ({ data, context }) => {
    return prisma.user.update({
      where: { id: context.userId },
      data
    })
  })
```

**필수 규칙:**

- [ ] POST/PUT/PATCH는 `inputValidator` 필수
- [ ] 인증 필요 시 `middleware` 필수
- [ ] handler 내부에서 수동 검증/인증 금지

### Route 구조

```typescript
// routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => {
    const users = await getUsers()
    return { users }
  }
})

function UsersPage() {
  const { users } = Route.useLoaderData()
  return <UserList users={users} />
}
```

**필수 규칙:**

- [ ] loader로 초기 데이터 로드
- [ ] `Route.useLoaderData()` 사용

## TanStack Router

### File-based Routing

```
src/routes/
├── __root.tsx          # Root layout
├── index.tsx           # /
├── $slug.tsx           # /:slug
└── users/
    ├── index.tsx       # /users
    ├── $id.tsx         # /users/:id
    ├── -components/    # 페이지 전용 컴포넌트
    └── -hooks/         # 페이지 전용 훅
```

**파일명 규칙:**

- `__root.tsx`: Root layout
- `index.tsx`: Index route
- `$param.tsx`: Dynamic parameter
- `-folder/`: Private (번들 제외)

### Navigation

```typescript
import { useNavigate, useParams } from '@tanstack/react-router'

function Component() {
  const navigate = useNavigate()
  const params = useParams({ from: '/users/$id' })

  const handleClick = () => {
    navigate({ to: '/users/$id', params: { id: '123' } })
  }

  return <div>{params.id}</div>
}
```

**필수 규칙:**

- [ ] `useNavigate` 사용 (Link 컴포넌트도 가능)
- [ ] `useParams`로 경로 파라미터 접근

## TanStack Query

### useQuery

```typescript
import { useQuery } from '@tanstack/react-query'

function Users() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return <UserList users={data} />
}
```

**필수 규칙:**

- [ ] `queryKey` 배열 형식
- [ ] `queryFn`에 Server Function 사용
- [ ] 로딩/에러 상태 처리

### useMutation

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query'

function CreateUserForm() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      // 캐시 무효화
      queryClient.invalidateQueries({ queryKey: ['users'] })
    }
  })

  const handleSubmit = (data) => {
    mutation.mutate(data)
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**필수 규칙:**

- [ ] `onSuccess`에서 `invalidateQueries` 호출
- [ ] `mutationFn`에 Server Function 사용
- [ ] 직접 Server Function 호출 금지

### Optimistic Updates

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onMutate: async (newData) => {
    // 진행 중인 쿼리 취소
    await queryClient.cancelQueries({ queryKey: ['users'] })

    // 이전 데이터 백업
    const previous = queryClient.getQueryData(['users'])

    // 낙관적 업데이트
    queryClient.setQueryData(['users'], (old) => {
      return old.map((user) =>
        user.id === newData.id ? { ...user, ...newData } : user
      )
    })

    return { previous }
  },
  onError: (err, newData, context) => {
    // 롤백
    queryClient.setQueryData(['users'], context.previous)
  },
  onSettled: () => {
    // 재검증
    queryClient.invalidateQueries({ queryKey: ['users'] })
  }
})
```

## 통합 예시

### 전체 흐름

```typescript
// 1. Server Function 정의 (src/functions/users.ts)
export const getUsers = createServerFn({ method: 'GET' })
  .handler(async () => prisma.user.findMany())

export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => prisma.user.create({ data }))

// 2. Route 정의 (src/routes/users/index.tsx)
export const Route = createFileRoute('/users')({
  component: UsersPage,
  loader: async () => ({ users: await getUsers() })
})

// 3. 컴포넌트 (src/routes/users/-components/UserList.tsx)
function UsersPage() {
  const { users: initialUsers } = Route.useLoaderData()
  const queryClient = useQueryClient()

  // useQuery로 실시간 데이터
  const { data: users } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
    initialData: initialUsers  // loader 데이터를 초기값으로
  })

  // useMutation으로 생성
  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    }
  })

  return (
    <div>
      <UserList users={users} />
      <CreateUserForm onSubmit={(data) => createMutation.mutate(data)} />
    </div>
  )
}
```

## 체크리스트

### Server Function

- [ ] 메서드 명시 (GET/POST/PUT/DELETE)
- [ ] POST/PUT/PATCH는 inputValidator 사용
- [ ] 인증 필요 시 middleware 사용
- [ ] handler 내부에서 수동 검증 금지

### Route

- [ ] loader로 초기 데이터 로드
- [ ] `Route.useLoaderData()` 사용
- [ ] 파일명 규칙 준수

### TanStack Query

- [ ] useQuery로 조회
- [ ] useMutation으로 변경
- [ ] onSuccess에서 invalidateQueries
- [ ] 로딩/에러 상태 처리
- [ ] 직접 Server Function 호출 금지

**TanStack 패턴 준수 → 타입 안전 + 성능 최적화**
