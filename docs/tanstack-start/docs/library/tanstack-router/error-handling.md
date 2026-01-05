# TanStack Router - Error Handling

errorComponent, notFoundComponent, 에러 경계.

## errorComponent

loader/beforeLoad에서 에러 발생 시 표시.

```tsx
import { createFileRoute, ErrorComponent } from '@tanstack/react-router'
import type { ErrorComponentProps } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) throw new Error('Post not found')
    return { post }
  },
  errorComponent: PostError,
  component: PostPage,
})

function PostError({ error, reset }: ErrorComponentProps) {
  return (
    <div>
      <h2>Error loading post</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

## notFoundComponent

`notFound()` 호출 시 표시.

```tsx
import { createFileRoute, notFound } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) {
      throw notFound()  // notFoundComponent 렌더링
    }
    return { post }
  },
  notFoundComponent: PostNotFound,
  component: PostPage,
})

function PostNotFound() {
  const { postId } = Route.useParams()

  return (
    <div>
      <h2>Post not found</h2>
      <p>Post with ID "{postId}" does not exist.</p>
    </div>
  )
}
```

### notFound에 데이터 전달

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) {
      throw notFound({
        data: { searchedId: params.postId },
      })
    }
    return { post }
  },
  notFoundComponent: ({ data }) => {
    // data.searchedId 접근 가능
    return <p>Post {data?.searchedId} not found</p>
  },
})
```

## Root 404 페이지

```tsx
// routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: GlobalNotFound,
})

function GlobalNotFound() {
  return (
    <div>
      <h1>404</h1>
      <p>Page not found</p>
      <Link to="/">Go Home</Link>
    </div>
  )
}
```

## pendingComponent

loader 실행 중 표시.

```tsx
export const Route = createFileRoute('/posts')({
  loader: async () => {
    await new Promise(r => setTimeout(r, 1000))  // 느린 로딩
    return { posts: await getPosts() }
  },
  pendingComponent: () => <div>Loading posts...</div>,
  component: PostsPage,
})
```

### pendingMs / pendingMinMs

```tsx
export const Route = createFileRoute('/posts')({
  loader: async () => fetchPosts(),
  pendingComponent: () => <Spinner />,
  pendingMs: 200,     // 200ms 후에 pending 표시
  pendingMinMs: 500,  // 최소 500ms 동안 pending 유지 (깜빡임 방지)
  component: PostsPage,
})
```

## Catch-all Route

```tsx
// routes/$.tsx - 모든 매치되지 않는 경로
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/$')({
  component: CatchAllPage,
})

function CatchAllPage() {
  const params = Route.useParams()
  // params._splat에 전체 경로

  return (
    <div>
      <h1>Page Not Found</h1>
      <p>Path: /{params._splat}</p>
    </div>
  )
}
```

## 에러 타입 구분

```tsx
function CustomError({ error, reset }: ErrorComponentProps) {
  // 네트워크 에러
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return (
      <div>
        <p>Network error. Check your connection.</p>
        <button onClick={reset}>Retry</button>
      </div>
    )
  }

  // 인증 에러
  if (error.message.includes('unauthorized')) {
    return <Navigate to="/login" />
  }

  // 기본 에러
  return (
    <div>
      <p>Something went wrong</p>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

## 컴포넌트 우선순위

| 우선순위 | 컴포넌트 | 조건 |
|---------|---------|------|
| 1 | `errorComponent` | loader/beforeLoad에서 Error throw |
| 2 | `notFoundComponent` | `notFound()` throw |
| 3 | `pendingComponent` | loader 실행 중 (pendingMs 이후) |
| 4 | `component` | 정상 렌더링 |

## 에러 전파

하위 라우트에서 처리 안 된 에러는 상위로 전파.

```
__root.tsx (errorComponent: GlobalError)
└── posts.tsx (errorComponent: PostsError)
    └── $postId.tsx (errorComponent 없음)
        → 에러 발생 시 posts.tsx의 PostsError로 전파
```
