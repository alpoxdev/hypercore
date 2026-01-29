# TanStack Router - Error Handling

<patterns>

```tsx
// errorComponent
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) throw new Error('Post not found')
    return { post }
  },
  errorComponent: PostError,
  component: PostPage,
})

const PostError = ({ error, reset }: ErrorComponentProps) => (
  <div>
    <h2>Error loading post</h2>
    <p>{error.message}</p>
    <button onClick={reset}>Retry</button>
  </div>
)

// notFoundComponent
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) throw notFound({ data: { searchedId: params.postId } })
    return { post }
  },
  notFoundComponent: ({ data }) => <p>Post {data?.searchedId} not found</p>,
  component: PostPage,
})

// Root 404
export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => (
    <div>
      <h1>404</h1>
      <Link to="/">Go Home</Link>
    </div>
  ),
})

// pendingComponent
export const Route = createFileRoute('/posts')({
  loader: async () => fetchPosts(),
  pendingComponent: () => <Spinner />,
  pendingMs: 200,     // 200ms 후 표시
  pendingMinMs: 500,  // 최소 500ms 유지 (깜빡임 방지)
  component: PostsPage,
})

// Catch-all (routes/$.tsx)
export const Route = createFileRoute('/$')({
  component: () => {
    const { _splat } = Route.useParams()
    return <div>Page Not Found: /{_splat}</div>
  },
})

// 에러 타입 구분
const CustomError = ({ error, reset }: ErrorComponentProps) => {
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return <div><p>Network error</p><button onClick={reset}>Retry</button></div>
  }
  if (error.message.includes('unauthorized')) {
    return <Navigate to="/login" />
  }
  return <div><p>Something went wrong</p><button onClick={reset}>Retry</button></div>
}
```

</patterns>

<priority>

| 우선순위 | 컴포넌트 | 조건 |
|---------|---------|------|
| 1 | `errorComponent` | loader/beforeLoad에서 Error throw |
| 2 | `notFoundComponent` | `notFound()` throw |
| 3 | `pendingComponent` | loader 실행 중 (pendingMs 이후) |
| 4 | `component` | 정상 렌더링 |

에러 전파: 하위 → 상위 (errorComponent 없으면 부모로 전파)

</priority>
