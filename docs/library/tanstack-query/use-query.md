# TanStack Query - useQuery

> **상위 문서**: [TanStack Query](./index.md)

## 기본 사용법

```tsx
import { useQuery } from '@tanstack/react-query'

function Todos() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['todos'],
    queryFn: getTodos,
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((todo) => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  )
}
```

## useQuery 반환 값

```typescript
const {
  data,           // 쿼리 결과 데이터
  error,          // 에러 객체
  isLoading,      // 첫 로딩 중
  isFetching,     // 백그라운드 페칭 중
  isError,        // 에러 상태
  isSuccess,      // 성공 상태
  isPending,      // 데이터 없고 로딩 중
  isStale,        // 데이터가 stale 상태
  refetch,        // 수동 리페치 함수
  status,         // 'pending' | 'error' | 'success'
  fetchStatus,    // 'fetching' | 'paused' | 'idle'
} = useQuery({ queryKey, queryFn })
```

## useQuery 옵션

```tsx
const { data } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,

  // 캐시 관련
  staleTime: 1000 * 60 * 5,     // 5분 동안 fresh
  gcTime: 1000 * 60 * 30,       // 30분 후 가비지 컬렉션

  // 리페치 관련
  refetchOnWindowFocus: true,   // 윈도우 포커스 시 리페치
  refetchOnReconnect: true,     // 네트워크 재연결 시 리페치
  refetchInterval: 1000 * 60,   // 1분마다 리페치

  // 재시도 관련
  retry: 3,                     // 실패 시 재시도 횟수
  retryDelay: 1000,             // 재시도 딜레이

  // 조건부 실행
  enabled: !!userId,            // false면 쿼리 실행 안 함

  // 초기 데이터
  initialData: [],              // 초기 데이터

  // 플레이스홀더
  placeholderData: [],          // 로딩 중 임시 데이터
})
```

## 파라미터가 있는 쿼리

```tsx
function Todo({ todoId }: { todoId: number }) {
  const { data } = useQuery({
    queryKey: ['todo', todoId],
    queryFn: () => fetchTodoById(todoId),
    enabled: !!todoId,
  })

  return <div>{data?.title}</div>
}
```

## 의존적 쿼리

```tsx
function UserPosts({ userId }: { userId: number }) {
  // 먼저 유저 정보를 가져옴
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUserById(userId),
  })

  // 유저 정보가 있어야 포스트를 가져옴
  const { data: posts } = useQuery({
    queryKey: ['posts', user?.id],
    queryFn: () => fetchPostsByUserId(user!.id),
    enabled: !!user?.id,
  })

  return (
    <div>
      <h1>{user?.name}</h1>
      <ul>
        {posts?.map((post) => (
          <li key={post.id}>{post.title}</li>
        ))}
      </ul>
    </div>
  )
}
```

## 병렬 쿼리

```tsx
function Dashboard() {
  const usersQuery = useQuery({ queryKey: ['users'], queryFn: fetchUsers })
  const postsQuery = useQuery({ queryKey: ['posts'], queryFn: fetchPosts })

  if (usersQuery.isLoading || postsQuery.isLoading) {
    return <div>Loading...</div>
  }

  return (
    <div>
      <UserList users={usersQuery.data} />
      <PostList posts={postsQuery.data} />
    </div>
  )
}
```

## useQueries (동적 병렬 쿼리)

```tsx
function UsersList({ userIds }: { userIds: number[] }) {
  const userQueries = useQueries({
    queries: userIds.map((id) => ({
      queryKey: ['user', id],
      queryFn: () => fetchUserById(id),
    })),
  })

  return (
    <ul>
      {userQueries.map((query, index) => (
        <li key={userIds[index]}>
          {query.isLoading ? 'Loading...' : query.data?.name}
        </li>
      ))}
    </ul>
  )
}
```

## Select로 데이터 변환

```tsx
const { data } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  select: (todos) => todos.filter((todo) => todo.completed),
})
```
