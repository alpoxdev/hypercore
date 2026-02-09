# TanStack Router

> v1 | Type-safe React Router

---

<context>

**Purpose:** File-based routing with full TypeScript type safety for TanStack Start

**Version:** v1

**Key Features:**
- File-based routing (`__root.tsx`, `$param.tsx`, `_layout/`)
- Type-safe hooks (`Route.useLoaderData()`, `Route.useParams()`)
- Data loading with SWR caching (`loader`, `beforeLoad`)
- Search params validation (Zod v4 + `zodValidator()`)
- Route context for auth/state sharing
- Error boundaries and pending states
- Code splitting (automatic + manual `.lazy.tsx`)
- Preloading strategies (intent, viewport, render)
- Deferred data loading with `Await` component
- Advanced path params (prefix/suffix patterns, optional params)

</context>

---

<forbidden>

| 분류 | 금지 행동 | 이유 |
|------|----------|------|
| **Hooks** | `useParams()`/`useSearch()` 타입 수동 지정 | `Route.useParams()`/`Route.useSearch()` 사용 (자동 타입) |
| **Search Params** | validateSearch 없이 search params 사용 | 타입 안전성 보장 불가 |
| **Search Params** | Zod schema `.catch()` 직접 사용 | `fallback()` from `@tanstack/zod-adapter` 사용 |
| **Navigation** | `window.location.href` 사용 | `<Link>` 또는 `useNavigate()` 사용 |
| **Context** | Context 없이 전역 상태 prop drilling | Route context 또는 Zustand 사용 |
| **Error** | try-catch로 에러 처리 | `errorComponent`, `notFoundComponent` 사용 |
| **Lazy Route** | `.lazy.tsx`에 loader/beforeLoad/validateSearch | 크리티컬 옵션은 메인 파일에만 |
| **Code Splitting** | 순환 의존성 발생 시 `Route` import | `getRouteApi()` 사용 |

</forbidden>

---

<required>

| 작업 | 필수 행동 |
|------|----------|
| **Search Params** | Zod 스키마로 `validateSearch` 정의, `zodValidator()` + `fallback()` 사용 |
| **Type-safe Hooks** | `Route.useLoaderData()`, `Route.useParams()`, `Route.useSearch()` 사용 |
| **Protected Routes** | `_authed.tsx` + `beforeLoad`에서 인증 체크 |
| **Data Loading** | `loader`에서 데이터 fetch, 병렬 로딩은 `Promise.all()` |
| **Error Handling** | `errorComponent`, `notFoundComponent`, `pendingComponent` 정의 |
| **Navigation** | `<Link>`에 `params`, `search` 타입 안전하게 전달 |
| **Preloading** | 일반 링크는 `preload="intent"`, 목록은 `preload="viewport"` |
| **Code Splitting** | 무거운 컴포넌트는 `.lazy.tsx` 또는 `lazy()` 사용 |
| **Deferred Data** | 중요 데이터는 `await`, 비중요 데이터는 Promise 반환 + `Await` 컴포넌트 |

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
│   ├── $postId.tsx     # /posts/:postId
│   └── $postId.lazy.tsx # 코드 스플릿 컴포넌트
├── _authed/            # Protected (pathless)
│   ├── dashboard.tsx   # /dashboard
│   └── settings.tsx    # /settings
├── (marketing)/        # Route group (정리용)
│   ├── pricing.tsx     # /pricing
│   └── features.tsx    # /features
└── $.tsx               # Catch-all (404)
```

| 파일명 | 경로 | 설명 |
|--------|------|------|
| `__root.tsx` | - | Root layout (필수) |
| `index.tsx` | `/` | 디렉토리 루트 |
| `about.tsx` | `/about` | 정적 라우트 |
| `$postId.tsx` | `/posts/:postId` | 동적 세그먼트 |
| `post-{$postId}.tsx` | `/post-123` | Prefix 패턴 |
| `{-$locale}/about.tsx` | `/en/about`, `/about` | Optional param |
| `_authed/dashboard.tsx` | `/dashboard` | Pathless layout (인증 등) |
| `(group)/pricing.tsx` | `/pricing` | Route group (정리용) |
| `-components/` | - | 제외 (라우트 아님) |
| `route.lazy.tsx` | - | 코드 스플릿 컴포넌트 |
| `$.tsx` | `/*` | Catch-all (404) |

</structure>

---

<route_options>

| 옵션 | 타입 | 설명 |
|------|------|------|
| `component` | Component | 렌더링할 컴포넌트 (non-critical, 코드 스플릿 가능) |
| `loader` | async function | 데이터 로드 (SSR/CSR 모두, critical) |
| `beforeLoad` | async function | loader 전 실행 (인증, context 추가, critical) |
| `validateSearch` | Zod schema | Search params 검증 + 타입 추론 (critical) |
| `loaderDeps` | function | search/params 변경 시 loader 재실행 트리거 |
| `errorComponent` | Component | Error throw 시 표시 (non-critical) |
| `notFoundComponent` | Component | notFound() throw 시 표시 (non-critical) |
| `pendingComponent` | Component | loader 실행 중 표시 (non-critical) |
| `pendingMs` | number | pendingComponent 표시 지연 (기본 1000ms) |
| `pendingMinMs` | number | pendingComponent 최소 표시 시간 (깜빡임 방지) |
| `staleTime` | number | 데이터 fresh 유지 시간 (기본 0ms) |
| `gcTime` | number | 미사용 데이터 메모리 유지 (기본 30분) |
| `shouldReload` | boolean \| function | 강제 리로드 조건 |

**Critical vs Non-Critical:**
- **Critical (메인 파일):** `loader`, `beforeLoad`, `validateSearch` → SSR/초기 렌더에 필요
- **Non-Critical (lazy 파일):** `component`, `errorComponent`, `pendingComponent`, `notFoundComponent` → 클라이언트 전용

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

// Search Params (Zod v4)
import { zodValidator, fallback } from '@tanstack/zod-adapter'

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(
    z.object({
      page: fallback(z.number(), 1),
      sort: fallback(z.enum(['newest', 'price']), 'newest'),
    })
  ),
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

<swr_caching>

## SWR 캐싱 시스템

TanStack Router는 내장 SWR(Stale-While-Revalidate) 캐싱으로 빠른 네비게이션 제공.

**캐싱 설정:**

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `staleTime` | 0ms | 데이터가 fresh 상태로 유지되는 시간 (fresh = 리페치 안 함) |
| `preloadStaleTime` | 30s | 프리로드 데이터가 fresh 상태로 유지되는 시간 |
| `gcTime` | 30분 | 미사용 데이터가 메모리에서 제거되기까지 시간 |
| `shouldReload` | `true` | 강제 리로드 조건 (boolean 또는 함수) |

**라우트별 캐싱:**

```tsx
export const Route = createFileRoute('/posts')({
  loader: async () => ({ posts: await getPosts() }),
  staleTime: 10_000, // 10초간 fresh (재방문 시 리페치 안 함)
  gcTime: 60_000, // 1분간 메모리 유지
})
```

**Router 레벨 기본값:**

```tsx
const router = createRouter({
  routeTree,
  defaultStaleTime: 5_000, // 모든 라우트 기본 5초
  defaultPreloadStaleTime: 30_000, // 프리로드 30초
  defaultGcTime: 1_800_000, // 30분
})
```

**수동 무효화:**

```tsx
const router = useRouter()

// 특정 라우트 무효화
router.invalidate({
  filter: (route) => route.fullPath.startsWith('/posts'),
})

// 전체 무효화
router.invalidate()
```

**동작 원리:**
1. 처음 방문: loader 실행 → 데이터 캐싱
2. `staleTime` 이내 재방문: 캐시 사용 (리페치 안 함)
3. `staleTime` 이후 재방문: 캐시 표시 + 백그라운드 리페치
4. `gcTime` 이후: 메모리에서 제거

</swr_caching>

---

<path_params>

## Path Params

**기본 동적 세그먼트:**

```tsx
// $postId.tsx → /posts/123
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const postId: string = params.postId // 자동 타입 추론
    return { post: await getPost(postId) }
  },
})
```

**Prefix/Suffix 패턴:**

```tsx
// post-{$postId}.tsx → /post-123
export const Route = createFileRoute('/post-{$postId}')({
  loader: async ({ params }) => ({ post: await getPost(params.postId) }),
})

// {$category}-products.tsx → /tech-products
export const Route = createFileRoute('/{$category}-products')({
  loader: async ({ params }) => ({ products: await getProducts(params.category) }),
})
```

**Optional Params:**

```tsx
// {-$locale}/about.tsx → /en/about 또는 /about
export const Route = createFileRoute('/{-$locale}/about')({
  loader: async ({ params }) => {
    const locale = params.locale ?? 'en' // undefined 가능
    return { content: await getContent(locale) }
  },
})
```

**Custom 문자 허용:**

```tsx
export const Route = createFileRoute('/user/$userId')({
  // 기본: a-zA-Z0-9_-
  // 커스텀: 점(.) 허용 (이메일 등)
  pathParamsAllowedCharacters: ['a-zA-Z0-9_\\-\\.'],
  loader: async ({ params }) => ({ user: await getUserByEmail(params.userId) }),
})
```

**Type-safe 접근:**

```tsx
// 같은 파일
function PostPage() {
  const { postId } = Route.useParams()
  return <div>{postId}</div>
}

// 다른 파일 (getRouteApi로 순환 의존성 방지)
import { getRouteApi } from '@tanstack/react-router'

const routeApi = getRouteApi('/posts/$postId')

function PostDetail() {
  const { postId } = routeApi.useParams()
  const { post } = routeApi.useLoaderData()
  return <div>{post.title}</div>
}

// select로 리렌더 최적화
const postId = useParams({
  from: '/posts/$postId',
  select: (params) => params.postId,
})
```

</path_params>

---

<code_splitting>

## Code Splitting

**자동 코드 스플리팅:**

```tsx
// tsr.config.json
{
  "autoCodeSplitting": true // 모든 라우트 자동 스플릿
}
```

**수동 코드 스플리팅 (.lazy.tsx):**

```tsx
// posts/$postId.tsx - Critical 옵션만
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => ({ post: await getPost(params.postId) }),
  beforeLoad: async ({ context }) => { /* auth */ },
  validateSearch: zodValidator(searchSchema),
})

// posts/$postId.lazy.tsx - Non-critical (컴포넌트)
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/posts/$postId')({
  component: PostDetail,
  errorComponent: PostError,
  pendingComponent: PostSkeleton,
  notFoundComponent: PostNotFound,
})

function PostDetail() {
  const { post } = Route.useLoaderData() // 타입 안전
  return <div>{post.title}</div>
}
```

**React.lazy()로 수동 스플릿:**

```tsx
import { lazy, Suspense } from 'react'

const HeavyEditor = lazy(() => import('./components/HeavyEditor'))

export const Route = createFileRoute('/editor')({
  component: () => (
    <Suspense fallback={<EditorSkeleton />}>
      <HeavyEditor />
    </Suspense>
  ),
})
```

**getRouteApi로 타입 안전 유지:**

```tsx
// components/PostDetail.tsx (별도 파일)
import { getRouteApi } from '@tanstack/react-router'

const routeApi = getRouteApi('/posts/$postId')

export function PostDetail() {
  const { postId } = routeApi.useParams()
  const { post } = routeApi.useLoaderData()
  const search = routeApi.useSearch()
  const context = routeApi.useRouteContext()

  return <div>{post.title}</div>
}
```

**Critical vs Non-Critical 정리:**

| Critical (메인 파일) | Non-Critical (lazy 파일) |
|---------------------|-------------------------|
| `loader` | `component` |
| `beforeLoad` | `errorComponent` |
| `validateSearch` | `pendingComponent` |
| - | `notFoundComponent` |

</code_splitting>

---

<external_data_loading>

## External Data Loading

**TanStack Query 통합:**

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { useSuspenseQuery, queryOptions } from '@tanstack/react-query'
import { getQueryClient } from '@/lib/query-client'

// Query Options 정의
const postQueryOptions = (postId: string) =>
  queryOptions({
    queryKey: ['posts', postId],
    queryFn: () => getPost(postId),
  })

// Loader에서 ensureQueryData로 SSR 지원
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params, context }) => {
    const queryClient = context.queryClient
    await queryClient.ensureQueryData(postQueryOptions(params.postId))
  },
  component: PostPage,
})

function PostPage() {
  const { postId } = Route.useParams()

  // useSuspenseQuery로 캐시된 데이터 접근
  const { data: post } = useSuspenseQuery(postQueryOptions(postId))

  return <div>{post.title}</div>
}
```

**SSR Hydration:**

```tsx
// __root.tsx
import { dehydrate, hydrate, QueryClient } from '@tanstack/react-query'

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  beforeLoad: () => {
    const queryClient = new QueryClient()
    return { queryClient }
  },
  component: RootLayout,
})

function RootLayout() {
  const { queryClient } = Route.useRouteContext()

  return (
    <html>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `window.__REACT_QUERY_STATE__ = ${JSON.stringify(
              dehydrate(queryClient)
            )}`,
          }}
        />
      </head>
      <body>
        <Outlet />
      </body>
    </html>
  )
}
```

</external_data_loading>

---

<search_params>

## Search Params

**Zod v4 + zodValidator:**

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'
import { zodValidator, fallback } from '@tanstack/zod-adapter'

// Zod 스키마 정의 (fallback으로 기본값)
const searchSchema = z.object({
  page: fallback(z.number().int().positive(), 1),
  search: fallback(z.string().optional(), undefined),
  sort: fallback(z.enum(['newest', 'price', 'rating']), 'newest'),
  tags: fallback(z.array(z.string()), []),
  inStock: fallback(z.boolean(), true),
  from: fallback(z.string().datetime().optional(), undefined),
  minPrice: fallback(z.number().min(0), 0),
})

// 라우트에 적용
export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(searchSchema),
  loaderDeps: ({ search }) => ({ search }), // search 변경 시 loader 재실행
  loader: async ({ deps: { search } }) => fetchProducts(search),
  component: ProductsPage,
})

const ProductsPage = () => {
  const { page, search, sort } = Route.useSearch() // 타입 안전
  return <div>Page: {page}, Sort: {sort}</div>
}
```

**Valibot 지원:**

```tsx
import { valibotValidator } from '@tanstack/valibot-adapter'
import * as v from 'valibot'

const searchSchema = v.object({
  page: v.fallback(v.number(), 1),
  sort: v.fallback(v.picklist(['newest', 'price']), 'newest'),
})

export const Route = createFileRoute('/products')({
  validateSearch: valibotValidator(searchSchema),
})
```

**Search Middleware:**

```tsx
// search params 전처리
const searchMiddleware = (search: Record<string, unknown>) => {
  return {
    ...search,
    page: Math.max(1, search.page as number), // page >= 1 보장
  }
}

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(searchSchema),
  searchMiddleware: [searchMiddleware],
})
```

**Search Params 업데이트:**

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

**select로 리렌더 최적화:**

```tsx
// ❌ 전체 search 구독 - 아무 param 변경 시 리렌더
const { page, sort, q } = Route.useSearch()

// ✅ select로 page만 구독
const page = useSearch({
  from: '/products',
  select: (search) => search.page,
})
```

</search_params>

---

<virtual_file_routes>

## Virtual File Routes

`@tanstack/virtual-file-routes`로 프로그래밍 방식 라우트 정의.

```bash
npm install @tanstack/virtual-file-routes
```

**기본 사용법:**

```tsx
// tsr.config.json
{
  "virtualFileRoutes": true
}

// __virtual.ts
import { rootRoute, route, index, layout, physical } from '@tanstack/virtual-file-routes'

export default rootRoute('__root.tsx', [
  index('index.tsx'),
  route('/about', 'about.tsx'),
  route('/posts', 'posts.tsx', [
    index('posts/index.tsx'),
    route('/$postId', 'posts/$postId.tsx'),
  ]),
  layout('_authenticated', '_authenticated.tsx', [
    route('/dashboard', 'dashboard.tsx'),
    route('/settings', 'settings.tsx'),
  ]),
  physical('/blog/*'), // 물리 파일 그대로 사용
])
```

**장점:**
- 중앙화된 라우트 구조
- 동적 라우트 생성
- 물리 파일과 혼합 가능

</virtual_file_routes>

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
<Link to="/posts" preload="intent">Posts</Link>       // hover 50ms 후
<Link to="/dashboard" preload="render">Dash</Link>    // 렌더링 시
<Link to="/products" preload="viewport">Prod</Link>   // viewport 진입 시
<Link to="/settings" preload={false}>Settings</Link>  // 비활성
```

| Link Props | 타입 | 설명 |
|------------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params (함수로 이전 값 접근) |
| `hash` | string | Hash |
| `replace` | boolean | history.replace 사용 |
| `preload` | 'intent' \| 'render' \| 'viewport' \| false | Preload 전략 |
| `preloadDelay` | number | intent 모드 지연 (기본 50ms) |
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

<preloading>

## Preloading

**Link 프리로딩 모드:**

| 모드 | 트리거 | 사용 시점 |
|------|--------|---------|
| `'intent'` | hover/touch 50ms 후 | 일반적인 네비게이션 링크 (권장) |
| `'viewport'` | 뷰포트 진입 시 (IntersectionObserver) | 목록 페이지, 무한 스크롤 |
| `'render'` | 컴포넌트 마운트 시 | 확실히 이동할 링크 |
| `false` | 비활성 | 인증/외부 링크 |

**Router 레벨 기본값:**

```tsx
const router = createRouter({
  routeTree,
  defaultPreload: 'intent', // 전역 기본값
  defaultPreloadDelay: 50, // intent 모드 지연 (ms)
  defaultPreloadStaleTime: 30_000, // 프리로드 데이터 30초간 fresh
})
```

**Link별 오버라이드:**

```tsx
// 목록 아이템은 viewport 프리로딩
{posts.map(post => (
  <Link
    key={post.id}
    to="/posts/$postId"
    params={{ postId: post.id }}
    preload="viewport"
  >
    {post.title}
  </Link>
))}

// 특정 링크는 프리로딩 비활성
<Link to="/settings" preload={false}>Settings</Link>
```

**프로그래밍 방식 프리로딩:**

```tsx
const router = useRouter()

// 검색 결과 hover 시 수동 프리로드
const handleMouseEnter = (postId: string) => {
  router.preloadRoute({
    to: '/posts/$postId',
    params: { postId },
  })
}
```

**커스텀 프리로드 지연:**

```tsx
<Link to="/posts" preload="intent" preloadDelay={100}>
  Posts (100ms 지연)
</Link>
```

</preloading>

---

<route_loading_lifecycle>

## Route Loading Lifecycle

**로딩 단계:**

1. **Route Matching:** URL과 라우트 매칭
2. **Route Pre-Loading (순차):** 매칭된 라우트의 `beforeLoad` 순차 실행 (부모 → 자식)
3. **Route Loading (병렬):**
   - `component.preload()` (lazy component)
   - `loader()` (data fetching)
   - **병렬 실행** → 가장 긴 작업이 완료되면 렌더링

**Loader Params:**

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({
    abortController, // AbortController for fetch cancellation
    cause, // 'enter' | 'preload' | 'stay' (로딩 원인)
    context, // Router context + beforeLoad context
    deps, // loaderDeps 반환값
    location, // Current location object
    params, // Path params { postId: string }
    preload, // boolean (프리로드 여부)
    route, // Route metadata
  }) => {
    // cause로 로딩 원인 구분
    if (cause === 'preload') {
      // 프리로드 시 가벼운 데이터만
      return { post: await getPostPreview(params.postId) }
    }

    // abortController로 취소 가능한 fetch
    const post = await fetch(`/api/posts/${params.postId}`, {
      signal: abortController.signal,
    })

    return { post }
  },
})
```

**Loader 최적화 (병렬):**

```tsx
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    // ❌ 순차 실행 (느림)
    const user = await getUser()
    const stats = await getStats()
    const posts = await getPosts()

    // ✅ 병렬 실행 (빠름)
    const [user, stats, posts] = await Promise.all([
      getUser(),
      getStats(),
      getPosts(),
    ])

    return { user, stats, posts }
  },
})
```

</route_loading_lifecycle>

---

<deferred_data>

## Deferred Data Loading

중요한 데이터는 `await`, 비중요 데이터는 Promise 반환 → `Await` 컴포넌트로 처리.

```tsx
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // 중요: 즉시 await (페이지 렌더 차단)
    const post = await getPost(params.postId) // 50ms

    // 비중요: Promise 그대로 반환 (차단 안 함)
    const deferredComments = getComments(params.postId) // 3초
    const deferredRecommendations = getRecommendations(params.postId) // 2초

    return { post, deferredComments, deferredRecommendations }
  },
  component: PostPage,
})

function PostPage() {
  const { post, deferredComments, deferredRecommendations } = Route.useLoaderData()

  return (
    <div>
      {/* 즉시 렌더링 (50ms) */}
      <PostContent post={post} />

      {/* 스트리밍 (3초) */}
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>

      {/* 스트리밍 (2초) */}
      <Suspense fallback={<RecommendationsSkeleton />}>
        <Await promise={deferredRecommendations}>
          {(recommendations) => <Recommendations items={recommendations} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

**장점:**
- 초기 페이지 렌더: 3초 → 50ms
- 비중요 데이터는 백그라운드 스트리밍
- 사용자는 즉시 핵심 콘텐츠 확인 가능

**사용 시점:** 분석, 추천, 사용자 활동, 소셜 기능, 댓글

</deferred_data>

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
  const { user } = Route.useRouteContext() // _authed에서 전달된 context
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

## router.invalidate()로 Context 재계산

```tsx
const router = useRouter()

// 로그인 후 context 재계산
const handleLogin = async () => {
  await login()
  router.invalidate() // 모든 beforeLoad 재실행 → context 업데이트
}
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
  const { post } = Route.useLoaderData() // Loader 반환값
  const { postId } = Route.useParams() // Path params
  const { page, sort } = Route.useSearch() // Search params
  const { user } = Route.useRouteContext() // Route context
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
const params = useParams({ strict: false }) // 모든 params

// useSearch (Global)
const { page } = useSearch({ from: '/products' })
const search = useSearch({ strict: false }) // 현재 search

// useRouterState
const pathname = useRouterState({ select: state => state.location.pathname })
const isLoading = useRouterState({ select: state => state.isLoading })

// useLocation
const location = useLocation()
console.log(location.pathname) // '/posts/123'
console.log(location.search) // { page: 1 }

// useRouter
const router = useRouter()
router.invalidate() // 캐시 무효화
router.preloadRoute({ to: '/posts/$postId', params: { postId: '123' } })
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
| `useRouter()` | Global | Auto | Router 인스턴스 (invalidate, preloadRoute) |

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

**에러 타입 구분:**

```tsx
import { ErrorComponent } from '@tanstack/react-router'

const CustomError = ({ error, reset }: ErrorComponentProps) => {
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return <div><p>Network error</p><button onClick={reset}>Retry</button></div>
  }
  if (error.message.includes('unauthorized')) {
    return <Navigate to="/login" />
  }
  return <ErrorComponent error={error} />
}
```

**Router 레벨 onError:**

```tsx
const router = createRouter({
  routeTree,
  onError: (error) => {
    console.error('Router error:', error)
    // 에러 로깅 서비스에 전송
  },
})
```

## notFoundComponent

**Fuzzy Mode (기본):** 가장 가까운 `notFoundComponent` 표시

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
```

**Root Mode:** Root의 `notFoundComponent` 표시

```tsx
export const Route = createRootRoute({
  notFoundMode: 'root', // fuzzy (기본) 또는 root
  notFoundComponent: () => (
    <div>
      <h1>404</h1>
      <Link to="/">Go Home</Link>
    </div>
  ),
  component: RootLayout,
})
```

**특정 라우트 타겟팅:**

```tsx
throw notFound({
  routeId: '/posts/$postId', // 특정 라우트의 notFoundComponent 사용
  data: { searchedId: '123' },
})
```

**CatchNotFound 컴포넌트:**

```tsx
import { CatchNotFound } from '@tanstack/react-router'

function PostsLayout() {
  return (
    <div>
      <CatchNotFound>
        <Outlet />
      </CatchNotFound>
    </div>
  )
}
```

## pendingComponent

```tsx
export const Route = createFileRoute('/posts')({
  loader: async () => fetchPosts(),
  pendingComponent: () => <Spinner />,
  pendingMs: 200, // 200ms 후 표시
  pendingMinMs: 500, // 최소 500ms 유지 (깜빡임 방지)
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

## 우선순위

| 우선순위 | 컴포넌트 | 조건 |
|---------|---------|------|
| 1 | `errorComponent` | loader/beforeLoad에서 Error throw |
| 2 | `notFoundComponent` | `notFound()` throw |
| 3 | `pendingComponent` | loader 실행 중 (pendingMs 이후) |
| 4 | `component` | 정상 렌더링 |

**에러 전파:** 하위 → 상위 (errorComponent 없으면 부모로 전파)

**onCatch:** 에러 발생 시 실행할 콜백

```tsx
export const Route = createFileRoute('/posts/$postId')({
  onCatch: (error) => {
    console.error('Route error:', error)
  },
})
```

</error_handling>

---

<dos_donts>

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|---------|
| `Route.useParams()` (타입 안전) | `useParams()` (수동 타입) |
| `Route.useSearch()` (타입 안전) | `useSearch()` (수동 타입) |
| `zodValidator()` + `fallback()` | Zod schema `.catch()` 직접 |
| `validateSearch`로 Search params 검증 | Search params 검증 없이 사용 |
| `beforeLoad`에서 인증 체크 | `loader`에서 인증 체크 |
| `errorComponent`로 에러 처리 | try-catch로 에러 처리 |
| `<Link>` 또는 `useNavigate()` | `window.location.href` |
| `_authed/` layout으로 Protected Routes | 모든 라우트에 인증 로직 중복 |
| `loaderDeps`로 search 변경 감지 | useEffect로 수동 refetch |
| `pendingComponent`로 로딩 표시 | useQuery의 isLoading |
| `notFound()` throw | Error throw + 문자열 비교 |
| `preload="intent"` (일반 링크) | preload 없이 사용 |
| `preload="viewport"` (목록) | 모든 링크에 render preload |
| `Promise.all()` (병렬 loader) | 순차 await (waterfall) |
| 중요 데이터 `await`, 비중요 Promise 반환 | 모든 데이터 await (차단) |
| `.lazy.tsx` (코드 스플릿) | 모든 컴포넌트 메인 파일에 |
| `getRouteApi()` (순환 의존성 방지) | Route import (순환 의존성) |
| `router.invalidate()` (캐시 무효화) | 수동 상태 관리 |
| `staleTime` 설정 (캐싱) | 매번 리페치 |

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

// ===== Search Params (Zod v4) =====
import { zodValidator, fallback } from '@tanstack/zod-adapter'

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(
    z.object({
      page: fallback(z.number(), 1),
      sort: fallback(z.enum(['newest', 'price']), 'newest'),
    })
  ),
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
<Link to="/posts/$postId" params={{ postId: '123' }} preload="intent">Post</Link>
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
  errorComponent: ({ error, reset }) => (
    <div>
      {error.message}
      <button onClick={reset}>Retry</button>
    </div>
  ),
  notFoundComponent: () => <div>Post not found</div>,
  pendingComponent: () => <Spinner />,
  component: PostPage,
})

// ===== Code Splitting =====
// posts/$postId.tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => ({ post: await getPost(params.postId) }),
})

// posts/$postId.lazy.tsx
export const Route = createLazyFileRoute('/posts/$postId')({
  component: PostDetail,
})

// getRouteApi (순환 의존성 방지)
import { getRouteApi } from '@tanstack/react-router'
const routeApi = getRouteApi('/posts/$postId')

function PostDetail() {
  const { postId } = routeApi.useParams()
  const { post } = routeApi.useLoaderData()
  return <div>{post.title}</div>
}

// ===== Deferred Data =====
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId) // 중요: await
    const deferredComments = getComments(params.postId) // 비중요: Promise
    return { post, deferredComments }
  },
})

function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()
  return (
    <div>
      <PostContent post={post} />
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}

// ===== Preloading =====
const router = createRouter({
  routeTree,
  defaultPreload: 'intent', // hover 50ms 후 프리로드
  defaultPreloadDelay: 50,
  defaultPreloadStaleTime: 30_000, // 30초간 fresh
})

// ===== SWR Caching =====
export const Route = createFileRoute('/posts')({
  loader: async () => ({ posts: await getPosts() }),
  staleTime: 10_000, // 10초간 fresh
  gcTime: 60_000, // 1분간 메모리 유지
})

const router = useRouter()
router.invalidate() // 캐시 무효화

// ===== TanStack Query 통합 =====
const postQueryOptions = (postId: string) =>
  queryOptions({
    queryKey: ['posts', postId],
    queryFn: () => getPost(postId),
  })

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params, context }) => {
    await context.queryClient.ensureQueryData(postQueryOptions(params.postId))
  },
})

function PostPage() {
  const { postId } = Route.useParams()
  const { data: post } = useSuspenseQuery(postQueryOptions(postId))
  return <div>{post.title}</div>
}
```

</patterns>
