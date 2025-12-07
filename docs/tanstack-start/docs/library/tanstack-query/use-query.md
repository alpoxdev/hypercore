# TanStack Query - useQuery

## 기본 사용법

```tsx
const { data, isLoading, error } = useQuery({
  queryKey: ['todos'],
  queryFn: getTodos,
})

if (isLoading) return <div>Loading...</div>
if (error) return <div>Error: {error.message}</div>
```

## 반환값

| 속성 | 설명 |
|------|------|
| data | 쿼리 결과 |
| error | 에러 객체 |
| isLoading | 첫 로딩 중 |
| isFetching | 백그라운드 페칭 중 |
| isError/isSuccess | 상태 |
| refetch | 수동 리페치 |
| status | 'pending' \| 'error' \| 'success' |

## 주요 옵션

```tsx
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  staleTime: 1000 * 60 * 5,      // fresh 유지 시간
  gcTime: 1000 * 60 * 30,        // 가비지 컬렉션 시간
  refetchOnWindowFocus: true,    // 포커스 시 리페치
  refetchInterval: 1000 * 60,    // 자동 리페치 간격
  retry: 3,                      // 재시도 횟수
  enabled: !!userId,             // 조건부 실행
  initialData: [],               // 초기 데이터
  select: (data) => data.filter(t => t.done),  // 데이터 변환
})
```

## 패턴

```tsx
// 파라미터 쿼리
useQuery({
  queryKey: ['todo', todoId],
  queryFn: () => fetchTodoById(todoId),
  enabled: !!todoId,
})

// 의존적 쿼리
const { data: user } = useQuery({ queryKey: ['user', userId], queryFn: ... })
const { data: posts } = useQuery({
  queryKey: ['posts', user?.id],
  queryFn: () => fetchPostsByUserId(user!.id),
  enabled: !!user?.id,  // user 로드 후 실행
})

// 병렬 쿼리
const usersQuery = useQuery({ queryKey: ['users'], queryFn: fetchUsers })
const postsQuery = useQuery({ queryKey: ['posts'], queryFn: fetchPosts })

// 동적 병렬 쿼리
const userQueries = useQueries({
  queries: userIds.map((id) => ({
    queryKey: ['user', id],
    queryFn: () => fetchUserById(id),
  })),
})
```
