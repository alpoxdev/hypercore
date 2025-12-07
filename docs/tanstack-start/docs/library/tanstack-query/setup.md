# TanStack Query - 설치 및 설정

## 설치

```bash
yarn add @tanstack/react-query
```

## QueryClient 옵션

```tsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5분
      gcTime: 1000 * 60 * 30,     // 30분 (이전 cacheTime)
      retry: 3,
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
    },
    mutations: { retry: 1 },
  },
})
```

## Query Keys 패턴

```typescript
['todos']                          // 단순
['todo', { id: 5 }]                // 파라미터
['todos', 'list', { filters }]     // 계층적
['todos', 'detail', todoId]
```

## DevTools

```bash
yarn add @tanstack/react-query-devtools
```

```tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

<QueryClientProvider client={queryClient}>
  <YourApp />
  <ReactQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```
