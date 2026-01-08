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
// 기본 라우트
export const Route = createFileRoute('/about')({ component: AboutPage })

// Loader + 동적 파라미터
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

| 파일명 | 경로 |
|--------|------|
| `index.tsx` | 디렉토리 루트 |
| `$param.tsx` | 동적 세그먼트 |
| `_layout/` | Pathless layout |
| `$.tsx` | Catch-all |

</structure>

<options>

| 옵션 | 설명 |
|------|------|
| `component` | 렌더링할 컴포넌트 |
| `loader` | 데이터 로드 함수 |
| `beforeLoad` | 로드 전 실행 (인증 등) |
| `validateSearch` | Search params 스키마 |
| `pendingComponent` | 로딩 중 표시 |
| `errorComponent` | 에러 발생 시 표시 |
| `notFoundComponent` | Not found 시 표시 |

</options>

<hooks>

| Hook | 용도 |
|------|------|
| `Route.useLoaderData()` | Loader 반환값 |
| `Route.useParams()` | Path 파라미터 |
| `Route.useSearch()` | Search params |
| `Route.useRouteContext()` | Route context |
| `useNavigate()` | 프로그래밍 네비게이션 |
| `useMatch({ from })` | 라우트 매치 정보 |

</hooks>
