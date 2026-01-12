# TanStack Router

> 1.x | Type-safe React Router

@navigation.md
@search-params.md
@route-context.md
@hooks.md
@error-handling.md

---

<quick_reference>

```tsx
// Basic route
export const Route = createFileRoute('/about')({ component: AboutPage })

// Loader + dynamic params
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => ({ post: await getPost(params.postId) }),
  component: PostPage,
})
const PostPage = () => {
  const { post } = Route.useLoaderData()
  return <h1>{post.title}</h1>
}

// Search Params (Zod)
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sort: z.enum(['newest', 'price']).catch('newest'),
  }),
  component: ProductsPage,
})
const ProductsPage = () => {
  const { page, sort } = Route.useSearch()
  return <div>Page {page}, Sort: {sort}</div>
}

// Root Route
export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => <div>404</div>,
})
const RootLayout = () => (
  <div>
    <nav>{/* ... */}</nav>
    <main><Outlet /></main>
  </div>
)

// Navigation
<Link to="/posts/$postId" params={{ postId: '123' }}>Post</Link>
<Link to="/products" search={{ page: 1 }}>Products</Link>

const navigate = useNavigate()
navigate({ to: '/posts/$postId', params: { postId: '123' } })
navigate({ to: '/products', search: prev => ({ ...prev, page: 2 }) })
```

</quick_reference>

<structure>

```
routes/
├── __root.tsx          # Root layout
├── index.tsx           # /
├── about.tsx           # /about
├── posts/
│   ├── index.tsx       # /posts
│   └── $postId.tsx     # /posts/:postId
├── _authed/            # Protected (pathless)
│   ├── dashboard.tsx   # /dashboard
│   └── settings.tsx    # /settings
└── $.tsx               # Catch-all (404)
```

| Filename | Path |
|--------|------|
| `index.tsx` | Directory root |
| `$param.tsx` | Dynamic segment |
| `_layout/` | Pathless layout |
| `$.tsx` | Catch-all |

</structure>

<options>

| Option | Description |
|------|------|
| `component` | Component to render |
| `loader` | Data loading function |
| `beforeLoad` | Run before loading (auth, etc) |
| `validateSearch` | Search params schema |
| `pendingComponent` | Loading state component |
| `errorComponent` | Error component |
| `notFoundComponent` | Not found component |

</options>

<hooks>

| Hook | Purpose |
|------|------|
| `Route.useLoaderData()` | Loader return value |
| `Route.useParams()` | Path parameters |
| `Route.useSearch()` | Search params |
| `Route.useRouteContext()` | Route context |
| `useNavigate()` | Programmatic navigation |
| `useMatch({ from })` | Route match info |

</hooks>
