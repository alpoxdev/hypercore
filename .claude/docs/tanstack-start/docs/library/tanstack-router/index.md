# TanStack Router

> v1 | Type-safe React Router

---

<context>

**Purpose:** File-based routing with full TypeScript type safety for TanStack Start

**Version:** v1

**Key Features:**
- File-based routing (`__root.tsx`, `$param.tsx`, `_layout/`)
- Type-safe hooks (`Route.useLoaderData()`, `Route.useParams()`)
- Data loading (`loader`, `beforeLoad`)
- Search params validation (Zod integration)
- Route context for auth/state sharing
- Error boundaries and pending states

</context>

---

<forbidden>

| 분류 | 금지 행동 | 이유 |
|------|----------|------|
| **Hooks** | `useParams()`/`useSearch()` 타입 수동 지정 | `Route.useParams()`/`Route.useSearch()` 사용 (자동 타입) |
| **Search Params** | validateSearch 없이 search params 사용 | 타입 안전성 보장 불가 |
| **Navigation** | `window.location.href` 사용 | `<Link>` 또는 `useNavigate()` 사용 |
| **Context** | Context 없이 전역 상태 prop drilling | Route context 또는 Zustand 사용 |
| **Error** | try-catch로 에러 처리 | `errorComponent` 사용 |

</forbidden>

---

<required>

| 작업 | 필수 행동 |
|------|----------|
| **Search Params** | Zod 스키마로 `validateSearch` 정의 |
| **Type-safe Hooks** | `Route.useLoaderData()`, `Route.useParams()`, `Route.useSearch()` 사용 |
| **Protected Routes** | `_authed.tsx` + `beforeLoad`에서 인증 체크 |
| **Data Loading** | `loader`에서 데이터 fetch, TanStack Query와 통합 |
| **Error Handling** | `errorComponent`, `notFoundComponent` 정의 |
| **Navigation** | `<Link>`에 `params`, `search` 타입 안전하게 전달 |

</required>

---

<structure>

```
routes/
├── __root.tsx          # Root layout (createRootRoute)
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

| 파일명 | 경로 | 설명 |
|--------|------|------|
| `__root.tsx` | - | Root layout (필수) |
| `index.tsx` | `/` | 디렉토리 루트 |
| `about.tsx` | `/about` | 정적 라우트 |
| `$postId.tsx` | `/posts/:postId` | 동적 세그먼트 |
| `_authed/dashboard.tsx` | `/dashboard` | Pathless layout (인증 등) |
| `$.tsx` | `/*` | Catch-all (404) |

</structure>

---

<route_options>

| 옵션 | 타입 | 설명 |
|------|------|------|
| `component` | Component | 렌더링할 컴포넌트 |
| `loader` | async function | 데이터 로드 (SSR/CSR 모두) |
| `beforeLoad` | async function | loader 전 실행 (인증, context 추가) |
| `validateSearch` | Zod schema | Search params 검증 + 타입 추론 |
| `loaderDeps` | function | search/params 변경 시 loader 재실행 |
| `errorComponent` | Component | Error throw 시 표시 |
| `notFoundComponent` | Component | notFound() throw 시 표시 |
| `pendingComponent` | Component | loader 실행 중 표시 |
| `pendingMs` | number | pendingComponent 표시 지연 (기본 1000ms) |
| `pendingMinMs` | number | pendingComponent 최소 표시 시간 (깜빡임 방지) |

```tsx
// 기본 라우트
export const Route = createFileRoute('/about')({
  component: AboutPage,
})

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
```

</route_options>

---

<navigation>

## Link Component

```tsx
// 기본 사용법
<Link to="/about">About</Link>
<Link to="/posts/$postId" params={{ postId: '123' }}>Post 123</Link>
<Link to="/products" search={{ page: 1, sort: 'newest' }}>Products</Link>
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>Next</Link>

// Active 스타일
<Link
  to="/about"
  activeProps={{ className: 'text-blue-500 font-bold' }}
  inactiveProps={{ className: 'text-gray-500' }}
>
  About
</Link>
<Link to="/" activeOptions={{ exact: true }}>Home</Link>

// Preloading
<Link to="/posts" preload="intent">Posts</Link>       // hover 시
<Link to="/dashboard" preload="render">Dash</Link>    // 렌더링 시
<Link to="/products" preload="viewport">Prod</Link>   // viewport 진입 시
```

| Link Props | 타입 | 설명 |
|------------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params (함수로 이전 값 접근) |
| `hash` | string | Hash |
| `replace` | boolean | history.replace 사용 |
| `preload` | 'intent' \| 'render' \| 'viewport' | Preload 전략 |
| `activeProps` | object | Active 시 props |
| `inactiveProps` | object | Inactive 시 props |
| `activeOptions` | object | Active 조건 (`exact` 등) |

## useNavigate

```tsx
const Component = () => {
  const navigate = useNavigate()

  const goToAbout = () => navigate({ to: '/about' })
  const goToPost = (id: string) => navigate({ to: '/posts/$postId', params: { postId: id } })
  const updateSearch = () => navigate({ to: '/products', search: prev => ({ ...prev, page: 2 }) })
  const replaceRoute = () => navigate({ to: '/login', replace: true })
  const goUp = () => navigate({ to: '..' })

  return <button onClick={goToAbout}>Go</button>
}

// 조건부 네비게이션
const SubmitButton = () => {
  const navigate = useNavigate()
  const [isPending, startTransition] = useTransition()

  const handleSubmit = async () => {
    const result = await submitForm()
    if (result.success) {
      startTransition(() => navigate({ to: '/success' }))
    }
  }

  return <button onClick={handleSubmit} disabled={isPending}>Submit</button>
}
```

| navigate 옵션 | 타입 | 설명 |
|---------------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | history.replace 사용 |
| `resetScroll` | boolean | 스크롤 리셋 (기본 true) |

</navigation>

---

<search_params>

## Zod 스키마 + validateSearch

```tsx
// Zod 스키마 정의
const searchSchema = z.object({
  page: z.number().catch(1),            // 기본값
  search: z.string().optional(),        // 선택
  sort: z.enum(['newest', 'price']).catch('newest'),
  tags: z.array(z.string()).catch([]),  // 배열
  inStock: z.boolean().catch(true),     // Boolean
  from: z.string().date().optional(),   // 날짜
  minPrice: z.number().min(0).catch(0), // 범위
})

// 라우트에 적용
export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,
  loaderDeps: ({ search }) => ({ search }),  // search 변경 시 loader 재실행
  loader: async ({ deps: { search } }) => fetchProducts(search),
  component: ProductsPage,
})

const ProductsPage = () => {
  const { page, search, sort } = Route.useSearch()  // 타입 안전
  return <div>Page: {page}, Sort: {sort}</div>
}
```

## Search Params 업데이트

```tsx
// Link로 업데이트
<Link to="/products" search={{ page: 1, sort: 'newest' }}>Reset</Link>
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>Next</Link>

// useNavigate로 업데이트
const Pagination = () => {
  const navigate = useNavigate()
  const { page } = Route.useSearch()

  const goToPage = (newPage: number) => {
    navigate({ to: '/products', search: prev => ({ ...prev, page: newPage }) })
  }

  return (
    <div>
      <button onClick={() => goToPage(page - 1)} disabled={page <= 1}>Prev</button>
      <span>Page {page}</span>
      <button onClick={() => goToPage(page + 1)}>Next</button>
    </div>
  )
}
```

## 실전: 필터 + 정렬 + 페이지네이션

```tsx
const PostsPage = () => {
  const { page, search, category, sort } = Route.useSearch()
  const posts = Route.useLoaderData()
  const navigate = useNavigate()

  const updateSearch = (updates: Partial<z.infer<typeof searchSchema>>) => {
    navigate({ to: '/posts', search: prev => ({ ...prev, ...updates, page: 1 }) })
  }

  return (
    <div>
      <input value={search} onChange={e => updateSearch({ search: e.target.value })} />
      <select value={category} onChange={e => updateSearch({ category: e.target.value as any })}>
        <option value="all">All</option>
        <option value="tech">Tech</option>
      </select>
      {posts.map(post => <div key={post.id}>{post.title}</div>)}
    </div>
  )
}
```

</search_params>

---

<route_context>

## beforeLoad + Context

```tsx
// beforeLoad: 인증 체크 + context 추가
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
    return { userPermissions: await fetchPermissions(context.auth.user.id) }
  },
  loader: async ({ context }) => fetchDashboardData(context.userPermissions),
  component: DashboardPage,
})
```

## Protected Routes: _authed.tsx (pathless layout)

```
routes/
├── _authed.tsx           # Protected layout
├── _authed/
│   ├── dashboard.tsx     # /dashboard (protected)
│   ├── settings.tsx      # /settings (protected)
│   └── profile.tsx       # /profile (protected)
├── login.tsx             # /login (public)
└── index.tsx             # / (public)
```

```tsx
// _authed.tsx
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }) => {
    const user = await getCurrentUser()
    if (!user) throw redirect({ to: '/login', search: { redirect: location.href } })
    return { user }
  },
  component: () => <Outlet />,
})

// _authed/dashboard.tsx
export const Route = createFileRoute('/_authed/dashboard')({
  component: DashboardPage,
})
const DashboardPage = () => {
  const { user } = Route.useRouteContext()  // _authed에서 전달된 context
  return <h1>Welcome, {user.name}!</h1>
}
```

## Root Context

```tsx
interface RouterContext {
  queryClient: QueryClient
  auth: { isAuthenticated: boolean; user: User | null }
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
})

const router = createRouter({
  routeTree,
  context: { queryClient, auth: { isAuthenticated: false, user: null } },
})
```

## redirect()

```tsx
throw redirect({ to: '/login' })
throw redirect({ to: '/login', search: { redirect: '/dashboard' } })
throw redirect({ to: '/posts/$postId', params: { postId: '123' } })
throw redirect({ to: '/home', replace: true })
```

## Context 접근

| 위치 | 접근 방법 |
|------|----------|
| `beforeLoad` | `{ context }` 파라미터 |
| `loader` | `{ context }` 파라미터 |
| `component` | `Route.useRouteContext()` |

</route_context>

---

<hooks>

## Route-Scoped Hooks (Type-safe, Recommended)

```tsx
const PostPage = () => {
  const { post } = Route.useLoaderData()      // Loader 반환값
  const { postId } = Route.useParams()        // Path params
  const { page, sort } = Route.useSearch()    // Search params
  const { user } = Route.useRouteContext()    // Route context
  return <h1>{post.title}</h1>
}
```

## Global Hooks (Manual type)

```tsx
// useNavigate
const navigate = useNavigate()
navigate({ to: '/posts/$postId', params: { postId: '123' } })

// useMatch
const postMatch = useMatch({ from: '/posts/$postId', shouldThrow: false })
if (postMatch) return <span>Post: {postMatch.params.postId}</span>

// useParams (Global)
const { postId } = useParams({ from: '/posts/$postId' })
const params = useParams({ strict: false })  // 모든 params

// useSearch (Global)
const { page } = useSearch({ from: '/products' })
const search = useSearch({ strict: false })  // 현재 search

// useRouterState
const pathname = useRouterState({ select: state => state.location.pathname })
const isLoading = useRouterState({ select: state => state.isLoading })

// useLocation
const location = useLocation()
console.log(location.pathname)  // '/posts/123'
console.log(location.search)    // { page: 1 }
```

## Hooks Reference

| Hook | Scope | Type | 용도 |
|------|-------|------|------|
| `Route.useLoaderData()` | Route | Auto | Loader 데이터 |
| `Route.useParams()` | Route | Auto | Path params (타입 안전) |
| `Route.useSearch()` | Route | Auto | Search params (타입 안전) |
| `Route.useRouteContext()` | Route | Auto | Route context |
| `useParams({ from })` | Global | Manual | 다른 라우트 params |
| `useSearch({ from })` | Global | Manual | 다른 라우트 search |
| `useMatch({ from })` | Global | Manual | 라우트 매치 정보 |
| `useNavigate()` | Global | Auto | 네비게이션 |
| `useRouterState()` | Global | Manual | 라우터 상태 (pathname, isLoading) |
| `useLocation()` | Global | Auto | 현재 location (pathname, search, hash) |

</hooks>

---

<error_handling>

## errorComponent

```tsx
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
```

## notFoundComponent

```tsx
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
```

## pendingComponent

```tsx
export const Route = createFileRoute('/posts')({
  loader: async () => fetchPosts(),
  pendingComponent: () => <Spinner />,
  pendingMs: 200,     // 200ms 후 표시
  pendingMinMs: 500,  // 최소 500ms 유지 (깜빡임 방지)
  component: PostsPage,
})
```

## Catch-all (routes/$.tsx)

```tsx
export const Route = createFileRoute('/$')({
  component: () => {
    const { _splat } = Route.useParams()
    return <div>Page Not Found: /{_splat}</div>
  },
})
```

## 에러 타입 구분

```tsx
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

## 우선순위

| 우선순위 | 컴포넌트 | 조건 |
|---------|---------|------|
| 1 | `errorComponent` | loader/beforeLoad에서 Error throw |
| 2 | `notFoundComponent` | `notFound()` throw |
| 3 | `pendingComponent` | loader 실행 중 (pendingMs 이후) |
| 4 | `component` | 정상 렌더링 |

**에러 전파:** 하위 → 상위 (errorComponent 없으면 부모로 전파)

</error_handling>

---

<dos_donts>

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|---------|
| `Route.useParams()` (타입 안전) | `useParams()` (수동 타입) |
| `Route.useSearch()` (타입 안전) | `useSearch()` (수동 타입) |
| `validateSearch`로 Search params 검증 | Search params 검증 없이 사용 |
| `beforeLoad`에서 인증 체크 | `loader`에서 인증 체크 |
| `errorComponent`로 에러 처리 | try-catch로 에러 처리 |
| `<Link>` 또는 `useNavigate()` | `window.location.href` |
| `_authed/` layout으로 Protected Routes | 모든 라우트에 인증 로직 중복 |
| `loaderDeps`로 search 변경 감지 | useEffect로 수동 refetch |
| `pendingComponent`로 로딩 표시 | useQuery의 isLoading |
| `notFound()` throw | Error throw + 문자열 비교 |

</dos_donts>

---

<patterns>

## Quick Reference

```tsx
// ===== 기본 라우트 =====
export const Route = createFileRoute('/about')({ component: AboutPage })

// ===== Loader + 동적 파라미터 =====
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => ({ post: await getPost(params.postId) }),
  component: PostPage,
})
const PostPage = () => {
  const { post } = Route.useLoaderData()
  return <h1>{post.title}</h1>
}

// ===== Search Params (Zod) =====
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

// ===== Root Route =====
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

// ===== Navigation =====
<Link to="/posts/$postId" params={{ postId: '123' }}>Post</Link>
<Link to="/products" search={{ page: 1 }}>Products</Link>

const navigate = useNavigate()
navigate({ to: '/posts/$postId', params: { postId: '123' } })
navigate({ to: '/products', search: prev => ({ ...prev, page: 2 }) })

// ===== Protected Routes =====
// _authed.tsx
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }) => {
    const user = await getCurrentUser()
    if (!user) throw redirect({ to: '/login', search: { redirect: location.href } })
    return { user }
  },
  component: () => <Outlet />,
})

// ===== Error Handling =====
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) throw notFound()
    return { post }
  },
  errorComponent: ({ error, reset }) => <div>{error.message}<button onClick={reset}>Retry</button></div>,
  notFoundComponent: () => <div>Post not found</div>,
  pendingComponent: () => <Spinner />,
  component: PostPage,
})
```

</patterns>
