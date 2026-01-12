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
  pendingMs: 200,     // Show after 200ms
  pendingMinMs: 500,  // Keep for at least 500ms (prevent flicker)
  component: PostsPage,
})

// Catch-all (routes/$.tsx)
export const Route = createFileRoute('/$')({
  component: () => {
    const { _splat } = Route.useParams()
    return <div>Page Not Found: /{_splat}</div>
  },
})

// Error type discrimination
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

| Priority | Component | Condition |
|---------|---------|------|
| 1 | `errorComponent` | Error thrown in loader/beforeLoad |
| 2 | `notFoundComponent` | `notFound()` thrown |
| 3 | `pendingComponent` | Loader executing (after pendingMs) |
| 4 | `component` | Normal rendering |

Error propagation: Child → Parent (propagates to parent if no errorComponent)

</priority>
