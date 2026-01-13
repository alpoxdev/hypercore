# TanStack Query

> v5 | React Data Fetching & State Management

---

<context>

**Purpose:** TanStack Query v5를 사용한 서버 상태 관리

**Scope:** useQuery, useMutation, 캐시 무효화, Optimistic Updates

**Key Features:**
- Automatic caching & background updates
- Request deduplication
- Optimistic updates
- Pagination & infinite queries
- Server state synchronization
- TanStack Start Server Functions 통합

**Version Highlights (v5):**
- `staleTime`: 데이터가 fresh 상태로 유지되는 시간
- `gcTime`: 캐시에서 가비지 컬렉션되기 전 대기 시간 (v4의 `cacheTime`)
- Improved TypeScript inference
- Better DevTools

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **Server Function 호출** | ❌ 클라이언트에서 Server Function 직접 호출 (반드시 useQuery/useMutation 사용) |
| **Query Key** | ❌ 동적 키 없이 파라미터 쿼리, ❌ 객체/배열 직접 비교 |
| **무효화** | ❌ 과도한 전역 무효화 (`invalidateQueries()` 남발) |
| **Optimistic Update** | ❌ `onMutate`에서 `cancelQueries` 누락, ❌ `onError`에서 롤백 누락 |
| **Mutation** | ❌ `mutateAsync`에서 에러 처리 누락 |

</forbidden>

---

<required>

| 작업 | 필수 |
|------|------|
| **Server Function 호출** | ✅ `useQuery`로 GET, `useMutation`로 POST/PUT/PATCH/DELETE |
| **Query Key** | ✅ 계층적 구조 (`['todos', 'list', { filters }]`), ✅ 파라미터 포함 |
| **무효화** | ✅ 관련 쿼리만 무효화 (`{ queryKey: ['todos'] }`), ✅ `onSuccess`/`onSettled`에서 실행 |
| **Optimistic Update** | ✅ `cancelQueries` → `getQueryData` → `setQueryData` → `onError` 롤백 순서 |
| **설정** | ✅ `staleTime`, `gcTime` 적절히 설정 (기본값은 즉시 stale) |

</required>

---

<setup>

## QueryClient 설정

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

// QueryClient 생성
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5분 동안 fresh 유지
      gcTime: 1000 * 60 * 30,     // 30분 후 가비지 컬렉션
      retry: 3,                    // 실패 시 3회 재시도
      refetchOnWindowFocus: true,  // 포커스 시 리페치
    },
    mutations: {
      retry: 1,                    // Mutation은 1회만 재시도
    },
  },
})

// App Provider
export const App = () => (
  <QueryClientProvider client={queryClient}>
    <YourApp />
  </QueryClientProvider>
)
```

### 설정 옵션

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `staleTime` | 데이터가 fresh 상태 유지 시간 (ms) | 0 (즉시 stale) |
| `gcTime` | 비활성 캐시 가비지 컬렉션 대기 시간 (ms) | 5분 |
| `retry` | 실패 시 재시도 횟수 | 3 |
| `refetchOnWindowFocus` | 윈도우 포커스 시 리페치 | true |
| `refetchInterval` | 자동 리페치 간격 (ms) | false |

</setup>

---

<use_query>

## useQuery - 데이터 조회

### 기본 패턴

```tsx
import { useQuery } from '@tanstack/react-query'
import { getUsers } from '@/functions/user'

const UsersPage = () => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

### 옵션 활용

```tsx
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  staleTime: 1000 * 60 * 5,      // 5분 동안 fresh 유지
  gcTime: 1000 * 60 * 30,        // 30분 후 가비지 컬렉션
  refetchOnWindowFocus: true,    // 포커스 시 리페치
  refetchInterval: 1000 * 60,    // 1분마다 자동 리페치
  retry: 3,                      // 재시도 횟수
  enabled: !!userId,             // 조건부 실행
  initialData: [],               // 초기 데이터
  select: (data) => data.filter(t => t.done),  // 데이터 변환
})
```

### 파라미터 쿼리

```tsx
// Query Key에 파라미터 포함
const TodoDetailPage = () => {
  const { todoId } = useParams()

  const { data: todo } = useQuery({
    queryKey: ['todo', todoId],  // 파라미터 포함
    queryFn: () => getTodoById(todoId),
    enabled: !!todoId,           // todoId 있을 때만 실행
  })

  return <div>{todo?.title}</div>
}
```

### 의존적 쿼리

```tsx
// 첫 번째 쿼리 결과를 두 번째 쿼리에 사용
const UserPostsPage = () => {
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser(userId),
  })

  const { data: posts } = useQuery({
    queryKey: ['posts', user?.id],
    queryFn: () => getPostsByUserId(user!.id),
    enabled: !!user?.id,  // user가 로드된 후에만 실행
  })

  return <PostList posts={posts} />
}
```

### 병렬 쿼리

```tsx
// 여러 쿼리 동시 실행
const DashboardPage = () => {
  const usersQuery = useQuery({ queryKey: ['users'], queryFn: getUsers })
  const postsQuery = useQuery({ queryKey: ['posts'], queryFn: getPosts })
  const statsQuery = useQuery({ queryKey: ['stats'], queryFn: getStats })

  if (usersQuery.isLoading || postsQuery.isLoading || statsQuery.isLoading) {
    return <div>Loading...</div>
  }

  return (
    <div>
      <UserStats users={usersQuery.data} />
      <PostList posts={postsQuery.data} />
      <Analytics stats={statsQuery.data} />
    </div>
  )
}
```

### 동적 병렬 쿼리

```tsx
import { useQueries } from '@tanstack/react-query'

// 여러 ID에 대해 동시 조회
const UserListPage = () => {
  const userIds = [1, 2, 3, 4, 5]

  const userQueries = useQueries({
    queries: userIds.map((id) => ({
      queryKey: ['user', id],
      queryFn: () => getUserById(id),
    })),
  })

  const allLoaded = userQueries.every((query) => query.isSuccess)
  if (!allLoaded) return <div>Loading...</div>

  return (
    <ul>
      {userQueries.map((query, index) => (
        <li key={userIds[index]}>{query.data?.name}</li>
      ))}
    </ul>
  )
}
```

### useQuery 반환값

| 속성 | 타입 | 설명 |
|------|------|------|
| `data` | `TData \| undefined` | 쿼리 결과 데이터 |
| `error` | `TError \| null` | 에러 객체 |
| `isLoading` | `boolean` | 첫 로딩 중 (데이터 없음 + 페칭 중) |
| `isFetching` | `boolean` | 백그라운드 페칭 중 |
| `isError` | `boolean` | 에러 상태 |
| `isSuccess` | `boolean` | 성공 상태 |
| `status` | `'pending' \| 'error' \| 'success'` | 쿼리 상태 |
| `refetch` | `() => Promise<...>` | 수동 리페치 |

</use_query>

---

<use_mutation>

## useMutation - 데이터 변경

### 기본 패턴

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createUser } from '@/functions/user'

const CreateUserForm = () => {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      // 성공 시 users 쿼리 무효화 (리페치 유도)
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  const handleSubmit = (formData) => {
    mutation.mutate(formData)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" />
      <button disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating...' : 'Create User'}
      </button>
      {mutation.isError && <div>Error: {mutation.error.message}</div>}
    </form>
  )
}
```

### 콜백 활용

```tsx
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Mutation 시작 전 (Optimistic Update용)
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previousTodos = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old) => [...old, newTodo])
    return { previousTodos }  // context로 전달
  },
  onSuccess: (data, variables, context) => {
    // 성공 시 실행
    console.log('Created:', data)
  },
  onError: (error, variables, context) => {
    // 실패 시 롤백
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: (data, error, variables, context) => {
    // 성공/실패 무관하게 실행
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### mutate vs mutateAsync

```tsx
// mutate: 콜백 방식
mutation.mutate(data, {
  onSuccess: (result) => {
    console.log('Success:', result)
  },
  onError: (error) => {
    console.error('Error:', error)
  },
})

// mutateAsync: Promise 방식
try {
  const result = await mutation.mutateAsync(data)
  console.log('Success:', result)
} catch (error) {
  console.error('Error:', error)
}
```

### 캐시 직접 업데이트

```tsx
useMutation({
  mutationFn: updateTodo,
  onSuccess: (data) => {
    // 전체 목록 무효화
    queryClient.invalidateQueries({ queryKey: ['todos'] })

    // 개별 항목 캐시 직접 업데이트 (리페치 불필요)
    queryClient.setQueryData(['todo', data.id], data)
  },
})
```

### useMutation 반환값

| 속성 | 타입 | 설명 |
|------|------|------|
| `data` | `TData \| undefined` | Mutation 결과 데이터 |
| `error` | `TError \| null` | 에러 객체 |
| `isPending` | `boolean` | 실행 중 |
| `isSuccess` | `boolean` | 성공 상태 |
| `isError` | `boolean` | 에러 상태 |
| `mutate` | `(variables, options?) => void` | Mutation 실행 (콜백 방식) |
| `mutateAsync` | `(variables) => Promise<TData>` | Mutation 실행 (Promise 방식) |
| `reset` | `() => void` | 상태 초기화 |
| `variables` | `TVariables \| undefined` | 전달된 변수 |

</use_mutation>

---

<invalidation>

## 캐시 무효화

### 기본 무효화

```typescript
import { useQueryClient } from '@tanstack/react-query'

const Component = () => {
  const queryClient = useQueryClient()

  // 단일 쿼리 무효화
  queryClient.invalidateQueries({ queryKey: ['todos'] })

  // 다중 쿼리 무효화
  await Promise.all([
    queryClient.invalidateQueries({ queryKey: ['todos'] }),
    queryClient.invalidateQueries({ queryKey: ['reminders'] }),
  ])

  // 전체 무효화 (주의: 과도한 리페치 발생 가능)
  queryClient.invalidateQueries()
}
```

### 무효화 옵션

```typescript
queryClient.invalidateQueries({
  queryKey: ['posts'],
  exact: true,           // 정확한 키 매칭만
  refetchType: 'active', // 'active' | 'inactive' | 'all' | 'none'
})
```

| refetchType | 설명 |
|-------------|------|
| `'active'` | 현재 렌더링 중인 쿼리만 재조회 (기본값) |
| `'inactive'` | 비활성 쿼리만 재조회 |
| `'all'` | 모든 매칭 쿼리 재조회 |
| `'none'` | 무효화만, 재조회 안함 |

### Query Key 매칭

```typescript
// Prefix 매칭 (기본)
queryClient.invalidateQueries({ queryKey: ['todos'] })
// 매칭: ['todos'], ['todos', 'list'], ['todos', 1]

// 정확한 매칭
queryClient.invalidateQueries({ queryKey: ['todos', 'list'], exact: true })
// 매칭: ['todos', 'list']만
```

### Mutation과 함께 사용

```tsx
useMutation({
  mutationFn: createTodo,
  onSuccess: () => {
    // 성공 시 무효화
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
  onSettled: () => {
    // 성공/실패 무관하게 무효화
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### 직접 업데이트 vs 무효화

| 방법 | 장점 | 단점 | 사용 시점 |
|------|------|------|----------|
| **setQueryData** | 빠름, 서버 요청 없음 | 서버 동기화 안됨 | 클라이언트 로직으로 결과 예측 가능 |
| **invalidateQueries** | 서버 데이터 보장 | 네트워크 요청 발생 | 서버 데이터 정확성 중요 |

```typescript
// 직접 업데이트 (더 빠름)
queryClient.setQueryData(['todos'], (old) => [...old, newTodo])

// 무효화 (서버 데이터 보장)
queryClient.invalidateQueries({ queryKey: ['todos'] })
```

</invalidation>

---

<optimistic_updates>

## Optimistic Updates

### 추가 패턴

```tsx
useMutation({
  mutationFn: addTodo,
  onMutate: async (newTodo) => {
    // 1. 진행 중인 쿼리 취소 (충돌 방지)
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // 2. 이전 데이터 백업
    const previousTodos = queryClient.getQueryData(['todos'])

    // 3. 낙관적 업데이트
    queryClient.setQueryData(['todos'], (old) => [...old, newTodo])

    // 4. context로 반환 (롤백용)
    return { previousTodos }
  },
  onError: (err, newTodo, context) => {
    // 실패 시 롤백
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => {
    // 성공/실패 무관하게 서버 데이터로 동기화
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### 삭제 패턴

```tsx
useMutation({
  mutationFn: deleteTodo,
  onMutate: async (todoId) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previousTodos = queryClient.getQueryData(['todos'])

    // 즉시 UI에서 제거
    queryClient.setQueryData(['todos'], (old) =>
      old.filter((todo) => todo.id !== todoId)
    )

    return { previousTodos }
  },
  onError: (err, todoId, context) => {
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### 토글 패턴

```tsx
useMutation({
  mutationFn: toggleTodo,
  onMutate: async (todoId) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previousTodos = queryClient.getQueryData(['todos'])

    // 즉시 토글
    queryClient.setQueryData(['todos'], (old) =>
      old.map((todo) =>
        todo.id === todoId ? { ...todo, completed: !todo.completed } : todo
      )
    )

    return { previousTodos }
  },
  onError: (err, todoId, context) => {
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### 단일 항목 업데이트

```tsx
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // 목록과 개별 항목 모두 취소
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    await queryClient.cancelQueries({ queryKey: ['todo', newTodo.id] })

    const previousTodo = queryClient.getQueryData(['todo', newTodo.id])
    const previousTodos = queryClient.getQueryData(['todos'])

    // 개별 항목 업데이트
    queryClient.setQueryData(['todo', newTodo.id], newTodo)

    // 목록에서도 업데이트
    queryClient.setQueryData(['todos'], (old) =>
      old.map((todo) => (todo.id === newTodo.id ? newTodo : todo))
    )

    return { previousTodo, previousTodos, newTodo }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todo', context.newTodo.id], context.previousTodo)
    queryClient.setQueryData(['todos'], context.previousTodos)
  },
  onSettled: (newTodo) => {
    queryClient.invalidateQueries({ queryKey: ['todo', newTodo.id] })
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### Optimistic Updates 체크리스트

| 단계 | 필수 작업 |
|------|----------|
| 1. **cancelQueries** | ✅ 진행 중인 쿼리 취소 (충돌 방지) |
| 2. **getQueryData** | ✅ 이전 데이터 백업 (롤백용) |
| 3. **setQueryData** | ✅ 낙관적 업데이트 |
| 4. **return context** | ✅ context로 이전 데이터 반환 |
| 5. **onError 롤백** | ✅ 실패 시 이전 데이터로 복원 |
| 6. **onSettled 동기화** | ✅ 서버 데이터로 최종 동기화 |

</optimistic_updates>

---

<query_keys>

## Query Keys

### 계층적 구조

```typescript
// 단순
['todos']

// 파라미터 포함
['todo', { id: 5 }]
['todo', todoId]

// 계층적
['todos', 'list']
['todos', 'list', { filters: 'completed' }]
['todos', 'detail', { id: 5 }]

// 복잡한 필터
['projects', 'list', { type: 'owned', filters: { status: 'active' } }]
```

### Query Key 패턴

| 패턴 | 예시 | 사용 시점 |
|------|------|----------|
| **단일 리소스 목록** | `['users']` | 전체 목록 |
| **단일 리소스 상세** | `['user', userId]` | 개별 항목 |
| **계층적 목록** | `['users', 'list']` | 명시적 목록 구분 |
| **필터링** | `['users', { role: 'admin' }]` | 필터 조건 포함 |
| **관계형** | `['user', userId, 'posts']` | 관계 데이터 |
| **복합** | `['posts', 'list', { page, filters }]` | 페이지네이션 + 필터 |

### Query Key 무효화 전략

```typescript
// 모든 users 관련 쿼리 무효화
queryClient.invalidateQueries({ queryKey: ['users'] })
// 매칭: ['users'], ['users', 'list'], ['user', 1]

// 특정 user만 무효화
queryClient.invalidateQueries({ queryKey: ['user', userId] })
// 매칭: ['user', userId], ['user', userId, 'posts']

// 정확한 키만 무효화
queryClient.invalidateQueries({ queryKey: ['users', 'list'], exact: true })
// 매칭: ['users', 'list']만
```

</query_keys>

---

<tanstack_start_integration>

## TanStack Start 통합

### Server Function과 함께 사용

```typescript
// src/functions/user.ts
import { createServerFn } from '@tanstack/start'
import { authMiddleware } from '@/middleware/auth'
import { createUserSchema } from '@/lib/schemas/user'

// GET - 인증 필요
export const getUsers = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async () => {
    return prisma.user.findMany()
  })

// GET - 파라미터
export const getUserById = createServerFn({ method: 'GET' })
  .inputValidator((data: unknown) => {
    const id = Number(data)
    if (isNaN(id)) throw new Error('Invalid ID')
    return id
  })
  .handler(async ({ data: userId }) => {
    return prisma.user.findUnique({ where: { id: userId } })
  })

// POST - 검증 + 인증
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })

// PUT - 수정
export const updateUser = createServerFn({ method: 'PUT' })
  .middleware([authMiddleware])
  .inputValidator(updateUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.update({
      where: { id: data.id },
      data,
    })
  })

// DELETE - 삭제
export const deleteUser = createServerFn({ method: 'DELETE' })
  .middleware([authMiddleware])
  .inputValidator((data: unknown) => {
    const id = Number(data)
    if (isNaN(id)) throw new Error('Invalid ID')
    return id
  })
  .handler(async ({ data: userId }) => {
    return prisma.user.delete({ where: { id: userId } })
  })
```

### 클라이언트에서 사용

```tsx
// src/routes/users/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUsers, createUser, deleteUser } from '@/functions/user'

export const Route = createFileRoute('/users')({
  component: UsersPage,
})

function UsersPage() {
  const queryClient = useQueryClient()

  // GET - useQuery
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: getUsers,
  })

  // POST - useMutation
  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  // DELETE - useMutation
  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onMutate: async (userId) => {
      // Optimistic Update
      await queryClient.cancelQueries({ queryKey: ['users'] })
      const previousUsers = queryClient.getQueryData(['users'])
      queryClient.setQueryData(['users'], (old) =>
        old.filter((user) => user.id !== userId)
      )
      return { previousUsers }
    },
    onError: (err, userId, context) => {
      queryClient.setQueryData(['users'], context.previousUsers)
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  if (isLoading) return <div>Loading...</div>

  return (
    <div>
      <button onClick={() => createMutation.mutate({ name: 'New User', email: 'new@example.com' })}>
        Create User
      </button>
      <ul>
        {users?.map((user) => (
          <li key={user.id}>
            {user.name}
            <button onClick={() => deleteMutation.mutate(user.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  )
}
```

### Route Loader와 함께 사용

```tsx
// src/routes/users/$userId.tsx
import { createFileRoute } from '@tanstack/react-router'
import { useQuery } from '@tanstack/react-query'
import { getUserById } from '@/functions/user'

export const Route = createFileRoute('/users/$userId')({
  component: UserDetailPage,
  loader: async ({ params }) => {
    // SSR에서 prefetch
    const user = await getUserById(Number(params.userId))
    return { user }
  },
})

function UserDetailPage() {
  const { userId } = Route.useParams()

  // 클라이언트에서는 캐시된 데이터 사용, 없으면 재조회
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => getUserById(Number(userId)),
  })

  return <div>{user?.name}</div>
}
```

### TanStack Start 패턴

| 패턴 | Server Function | TanStack Query |
|------|----------------|----------------|
| **조회** | `createServerFn({ method: 'GET' })` | `useQuery({ queryFn: serverFn })` |
| **생성** | `createServerFn({ method: 'POST' })` | `useMutation({ mutationFn: serverFn })` |
| **수정** | `createServerFn({ method: 'PUT' })` | `useMutation({ mutationFn: serverFn })` |
| **삭제** | `createServerFn({ method: 'DELETE' })` | `useMutation({ mutationFn: serverFn })` |
| **SSR Prefetch** | `loader: async () => await serverFn()` | 캐시된 데이터 활용 |

</tanstack_start_integration>

---

<dos_and_donts>

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|----------|
| `useQuery`로 Server Function GET 호출 | 클라이언트에서 Server Function 직접 호출 |
| `useMutation`로 POST/PUT/PATCH/DELETE | `mutateAsync` 사용 시 try-catch 누락 |
| Query Key에 파라미터 포함 (`['user', userId]`) | 동적 키 없이 파라미터 쿼리 |
| `onSuccess`/`onSettled`에서 관련 쿼리만 무효화 | 전역 `invalidateQueries()` 남발 |
| Optimistic Update 시 `cancelQueries` 먼저 | `cancelQueries` 누락하고 `setQueryData` |
| `onError`에서 이전 데이터로 롤백 | Optimistic Update 후 롤백 로직 누락 |
| `staleTime`, `gcTime` 적절히 설정 | 기본값(0)으로 즉시 stale 허용 |
| 계층적 Query Key (`['todos', 'list', { filters }]`) | 평면적 Query Key (`['todos-list-completed']`) |
| `refetchType: 'active'`로 현재 화면만 리페치 | 모든 쿼리 리페치 (`refetchType: 'all'`) |
| `enabled: !!dependency`로 조건부 실행 | 의존성 없이 쿼리 실행 후 에러 처리 |

</dos_and_donts>

---

<reference>

## Quick Reference

### useQuery 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `queryKey` | `unknown[]` | (필수) | 쿼리 식별 키 |
| `queryFn` | `() => Promise<TData>` | (필수) | 데이터 조회 함수 |
| `staleTime` | `number \| Infinity` | 0 | fresh 상태 유지 시간 (ms) |
| `gcTime` | `number \| Infinity` | 5분 | 가비지 컬렉션 대기 시간 (ms) |
| `enabled` | `boolean` | true | 쿼리 실행 여부 |
| `retry` | `boolean \| number \| (count, error) => boolean` | 3 | 재시도 횟수 |
| `refetchOnWindowFocus` | `boolean` | true | 포커스 시 리페치 |
| `refetchInterval` | `number \| false` | false | 자동 리페치 간격 (ms) |
| `select` | `(data) => TResult` | - | 데이터 변환 |
| `initialData` | `TData` | - | 초기 데이터 |

### useMutation 옵션

| 옵션 | 타입 | 설명 |
|------|------|------|
| `mutationFn` | `(variables: TVariables) => Promise<TData>` | Mutation 함수 (필수) |
| `onMutate` | `(variables) => Promise<TContext>` | Mutation 시작 전 |
| `onSuccess` | `(data, variables, context) => void` | 성공 시 |
| `onError` | `(error, variables, context) => void` | 실패 시 |
| `onSettled` | `(data, error, variables, context) => void` | 성공/실패 무관 |
| `retry` | `boolean \| number` | 재시도 횟수 |

### QueryClient 메서드

| 메서드 | 설명 |
|--------|------|
| `invalidateQueries({ queryKey })` | 쿼리 무효화 (리페치 유도) |
| `refetchQueries({ queryKey })` | 즉시 리페치 |
| `cancelQueries({ queryKey })` | 진행 중인 쿼리 취소 |
| `getQueryData(queryKey)` | 캐시 데이터 조회 |
| `setQueryData(queryKey, data)` | 캐시 데이터 직접 설정 |
| `removeQueries({ queryKey })` | 캐시에서 제거 |
| `resetQueries({ queryKey })` | 초기 상태로 리셋 |

### 상태 플래그

| 플래그 | useQuery | useMutation | 설명 |
|--------|----------|-------------|------|
| `isPending` | ✅ | ✅ | 대기 중 |
| `isLoading` | ✅ | - | 첫 로딩 중 (데이터 없음 + 페칭) |
| `isFetching` | ✅ | - | 백그라운드 페칭 중 |
| `isSuccess` | ✅ | ✅ | 성공 |
| `isError` | ✅ | ✅ | 에러 |
| `data` | ✅ | ✅ | 결과 데이터 |
| `error` | ✅ | ✅ | 에러 객체 |

</reference>
