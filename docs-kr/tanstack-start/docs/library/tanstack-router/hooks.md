# TanStack Router - Hooks

<patterns>

```tsx
// Route-Scoped (Type-safe)
const PostPage = () => {
  const { post } = Route.useLoaderData()      // Loader 반환값
  const { postId } = Route.useParams()        // Path params
  const { page, sort } = Route.useSearch()    // Search params
  const { user } = Route.useRouteContext()    // Route context
  return <h1>{post.title}</h1>
}

// Global (Manual type)
const navigate = useNavigate()
navigate({ to: '/posts/$postId', params: { postId: '123' } })

const postMatch = useMatch({ from: '/posts/$postId', shouldThrow: false })
if (postMatch) return <span>Post: {postMatch.params.postId}</span>

const { postId } = useParams({ from: '/posts/$postId' })
const params = useParams({ strict: false })  // 모든 params

const { page } = useSearch({ from: '/products' })
const search = useSearch({ strict: false })  // 현재 search

const pathname = useRouterState({ select: state => state.location.pathname })
const isLoading = useRouterState({ select: state => state.isLoading })

const location = useLocation()
console.log(location.pathname)  // '/posts/123'
console.log(location.search)    // { page: 1 }
```

</patterns>

<reference>

| Hook | Scope | Type | 용도 |
|------|-------|------|------|
| `Route.useLoaderData()` | Route | Auto | Loader 데이터 |
| `Route.useParams()` | Route | Auto | Path params |
| `Route.useSearch()` | Route | Auto | Search params |
| `Route.useRouteContext()` | Route | Auto | Route context |
| `useParams({ from })` | Global | Manual | 다른 라우트 params |
| `useSearch({ from })` | Global | Manual | 다른 라우트 search |
| `useMatch({ from })` | Global | Manual | 라우트 매치 정보 |
| `useNavigate()` | Global | Auto | 네비게이션 |
| `useRouterState()` | Global | Manual | 라우터 상태 |
| `useLocation()` | Global | Auto | 현재 location |

</reference>
