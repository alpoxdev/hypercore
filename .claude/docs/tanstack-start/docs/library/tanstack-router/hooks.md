# TanStack Router - Hooks

<patterns>

```tsx
// Route-Scoped (Type-safe)
const PostPage = () => {
  const { post } = Route.useLoaderData()      // Loader return value
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
const params = useParams({ strict: false })  // All params

const { page } = useSearch({ from: '/products' })
const search = useSearch({ strict: false })  // Current search

const pathname = useRouterState({ select: state => state.location.pathname })
const isLoading = useRouterState({ select: state => state.isLoading })

const location = useLocation()
console.log(location.pathname)  // '/posts/123'
console.log(location.search)    // { page: 1 }
```

</patterns>

<reference>

| Hook | Scope | Type | Purpose |
|------|-------|------|------|
| `Route.useLoaderData()` | Route | Auto | Loader data |
| `Route.useParams()` | Route | Auto | Path params |
| `Route.useSearch()` | Route | Auto | Search params |
| `Route.useRouteContext()` | Route | Auto | Route context |
| `useParams({ from })` | Global | Manual | Other route params |
| `useSearch({ from })` | Global | Manual | Other route search |
| `useMatch({ from })` | Global | Manual | Route match info |
| `useNavigate()` | Global | Auto | Navigation |
| `useRouterState()` | Global | Manual | Router state |
| `useLocation()` | Global | Auto | Current location |

</reference>
