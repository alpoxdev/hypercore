# TanStack Query - 설치 및 설정

> **상위 문서**: [TanStack Query](./index.md)

## 설치

```bash
yarn add @tanstack/react-query
```

## QueryClient 설정

```tsx
import {
  QueryClient,
  QueryClientProvider,
} from '@tanstack/react-query'

// QueryClient 생성
const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

## QueryClient 옵션

```tsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5분
      gcTime: 1000 * 60 * 30, // 30분 (이전의 cacheTime)
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
    },
    mutations: {
      retry: 1,
    },
  },
})
```

## TanStack Start와 함께 사용

```tsx
import { useQuery } from '@tanstack/react-query'
import { getServerPosts } from '@/lib/server-functions'

function PostList() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['posts'],
    queryFn: () => getServerPosts(),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

## Query Keys 패턴

```typescript
// 간단한 키
['todos']

// 파라미터가 있는 키
['todo', { id: 5 }]

// 계층적 키
['todos', 'list', { filters: 'all' }]
['todos', 'detail', todoId]
```

## DevTools (개발용)

```bash
yarn add @tanstack/react-query-devtools
```

```tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```
