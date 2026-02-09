# TanStack Router - Error Handling

> TanStack Router v1.159.4

에러 경계, 404 처리, 로딩 상태를 다룬다.

---

<error_component>

## errorComponent: 일반 에러 처리

Loader나 beforeLoad에서 throw한 Error를 잡는다.

### 기본 사용

```tsx
import { ErrorComponentProps } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    if (!post) {
      // 임의의 Error throw
      throw new Error(`Post ${params.postId} not found`)
    }
    return { post }
  },
  errorComponent: PostError,
  component: PostDetail,
})

const PostError = ({ error, reset }: ErrorComponentProps) => (
  <div className="error-container">
    <h2>Error loading post</h2>
    <p>{error.message}</p>
    <button onClick={reset}>Retry</button>
  </div>
)

const PostDetail = () => {
  const { post } = Route.useLoaderData()
  return <h1>{post.title}</h1>
}
```

### ErrorComponentProps

```tsx
interface ErrorComponentProps {
  error: Error
  reset: () => void  // Retry 버튼: loader와 beforeLoad 재실행
  info?: string
}
```

### 비동기 에러

```tsx
export const Route = createFileRoute('/users')({
  loader: async () => {
    try {
      return await fetchUsers()
    } catch (error) {
      // 에러를 명시적으로 throw
      throw new Error(`Failed to fetch users: ${error.message}`)
    }
  },
  errorComponent: ({ error, reset }) => (
    <div>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  ),
  component: UsersList,
})
```

### 에러 타입 구분

```tsx
const CustomError = ({ error, reset }: ErrorComponentProps) => {
  // Network error
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return (
      <div>
        <p>Network connection error. Please check your internet.</p>
        <button onClick={reset}>Retry</button>
      </div>
    )
  }

  // 인증 에러
  if (error.message.includes('unauthorized') || error.message.includes('401')) {
    return <Navigate to="/login" />
  }

  // Validation 에러
  if (error.message.includes('validation')) {
    return <div>Invalid data provided. Please try again.</div>
  }

  // 기타 에러
  return (
    <div>
      <p>Something went wrong</p>
      <details>
        <summary>Details</summary>
        <pre>{error.message}</pre>
      </details>
      <button onClick={reset}>Retry</button>
    </div>
  )
}

export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    // ...
  },
  errorComponent: CustomError,
  component: Dashboard,
})
```

### DefaultErrorComponent로 폴백

커스텀 에러에서 처리 못하는 에러는 기본 컴포넌트로 위임.

```tsx
import { ErrorComponent } from '@tanstack/react-router'

export const Route = createFileRoute('/posts')({
  loader: () => fetchPosts(),
  errorComponent: ({ error }) => {
    if (error instanceof MyCustomError) {
      return <div>{error.message}</div>
    }

    // 기본 ErrorComponent로 폴백 (항상 추천)
    return <ErrorComponent error={error} />
  },
})
```

### 상위로 에러 전파

errorComponent가 없으면 부모 라우트로 전파.

```tsx
// /src/routes/posts/$postId.tsx (errorComponent 없음)
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    throw new Error('Failed to load post')
  },
  component: PostDetail,
})

// /src/routes/posts.tsx (errorComponent 있음)
export const Route = createFileRoute('/posts')({
  errorComponent: PostsError,  // /posts/$postId의 에러도 여기서 잡힘
  component: () => <Outlet />,
})
```

### onError / onCatch 콜백

```tsx
export const Route = createFileRoute('/posts')({
  loader: () => fetchPosts(),
  // 에러 로깅
  onError: ({ error }) => {
    console.error('Loader error:', error)
  },
  // CatchBoundary에서 잡힌 에러
  onCatch: ({ error, errorInfo }) => {
    console.error('Caught error:', error)
  },
  errorComponent: PostsError,
  component: PostsList,
})
```

</error_component>

---

<not_found_component>

## notFoundComponent: 404 처리

notFound() 함수로 throw하면 notFoundComponent 표시.

### notFoundMode 옵션

| 모드 | 설명 |
|------|------|
| `fuzzy` (기본) | 가장 가까운 부모 라우트의 notFoundComponent 사용. 부모 레이아웃 최대 보존. |
| `root` | 모든 404를 root의 notFoundComponent에서 처리 |

```tsx
const router = createRouter({
  routeTree,
  notFoundMode: 'fuzzy',  // 기본값
})
```

### fuzzy 모드 동작 원리

`/posts/1/edit` 접근 시 (edit 라우트가 없는 경우):

- `__root__` (notFoundComponent 있음)
  - `posts` (notFoundComponent 있음) -> 여기서 처리 (가장 가까운 부모)
    - `$postId`

가장 가까운 적합한 부모 조건:
1. 자식 라우트를 가짐 (Outlet이 있음)
2. notFoundComponent가 설정됨

### 기본 사용

```tsx
import { notFound } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)

    // Post 없으면 404
    if (!post) {
      throw notFound({
        data: { searchedId: params.postId }
      })
    }

    return { post }
  },
  notFoundComponent: PostNotFound,
  component: PostDetail,
})

const PostNotFound = ({ data }: { data?: { searchedId: string } }) => (
  <div>
    <h2>Post not found</h2>
    <p>Could not find post {data?.searchedId}</p>
    <Link to="/posts">Back to posts</Link>
  </div>
)

const PostDetail = () => {
  const { post } = Route.useLoaderData()
  return <h1>{post.title}</h1>
}
```

### Root 404 (전역 핸들링)

```tsx
// /src/routes/__root.tsx
export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: NotFound,  // 모든 404 처리
})

const NotFound = () => (
  <div>
    <h1>404 - Page Not Found</h1>
    <Link to="/">Go Home</Link>
  </div>
)

const RootLayout = () => (
  <div>
    <nav>{/* ... */}</nav>
    <Outlet />
  </div>
)
```

### defaultNotFoundComponent (라우터 수준)

모든 라우트에 기본 404 컴포넌트 적용.

```tsx
const router = createRouter({
  routeTree,
  defaultNotFoundComponent: () => (
    <div>
      <p>Not found!</p>
      <Link to="/">Go home</Link>
    </div>
  ),
})
```

### 특정 라우트로 404 전파 (routeId)

```tsx
import { rootRouteId } from '@tanstack/react-router'

// 특정 부모 라우트의 notFoundComponent 사용
export const Route = createFileRoute('/_pathless/route-a')({
  loader: async () => {
    throw notFound({ routeId: '/_pathlessLayout' })
    //                       ^^^^^^^^^ 자동완성 지원
  },
  // 이 notFoundComponent는 렌더링되지 않음
  notFoundComponent: () => <p>여기는 안 보임</p>,
})

// root 라우트로 직접 전파
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params: { postId } }) => {
    const post = await getPost(postId)
    if (!post) throw notFound({ routeId: rootRouteId })
    return { post }
  },
})
```

### notFound() 사용 패턴

```tsx
// 단순 throw
throw notFound()

// 데이터 전달
throw notFound({
  data: {
    resourceType: 'Post',
    searchedId: params.postId,
  }
})

// 특정 라우트 지정
throw notFound({ routeId: '/_pathlessLayout' })

// throw 옵션
notFound({ throw: true })  // throw 대신 함수 내에서 throw

// beforeLoad에서도 사용 가능 (항상 __root notFoundComponent 사용)
export const Route = createFileRoute('/admin')({
  beforeLoad: async ({ context }) => {
    if (!context.user?.isAdmin) {
      throw notFound()
    }
  },
  component: AdminPanel,
})
```

> 주의: beforeLoad에서 notFound()를 throw하면 항상 `__root`의 notFoundComponent가 사용됨. 이는 beforeLoad가 loader 전에 실행되므로 레이아웃 데이터 로딩이 보장되지 않기 때문.

### notFound() vs Error throw

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)

    if (!post) {
      // 리소스 없음: notFound() 사용
      throw notFound()
    }

    // API 에러로 실패
    if (!post.data) {
      // 예상치 못한 에러: Error throw
      throw new Error('Invalid post data')
    }

    return { post }
  },
  notFoundComponent: () => <div>Post not found</div>,
  errorComponent: ({ error }) => <div>{error.message}</div>,
  component: PostDetail,
})
```

</not_found_component>

---

<catch_not_found>

## CatchNotFound: 컴포넌트 레벨 404

컴포넌트 내부에서 notFound() throw 가능.

```tsx
import { CatchNotFound } from '@tanstack/react-router'

export const Route = createFileRoute('/products/$productId')({
  component: () => (
    <CatchNotFound fallback={<div>Product not found</div>}>
      <ProductDetail />
    </CatchNotFound>
  ),
})

const ProductDetail = () => {
  const { productId } = Route.useParams()
  const product = useQuery({
    queryKey: ['products', productId],
    queryFn: async () => {
      const res = await getProduct(productId)
      if (!res) throw notFound()  // 컴포넌트에서 throw
      return res
    },
  })

  if (product.isPending) return <Spinner />

  return <h1>{product.data.name}</h1>
}
```

> 권장: 가능하면 loader에서 notFound()를 throw. 컴포넌트에서 throw하면 loader 데이터 타입이 불안정하고 UI 깜빡임이 발생할 수 있음.

</catch_not_found>

---

<pending_component>

## pendingComponent: 로딩 상태

Loader 실행 중일 때 표시. **기본 1000ms** 이후에 노출.

### 기본 사용

```tsx
export const Route = createFileRoute('/posts')({
  loader: async () => {
    // 로딩 시뮬레이션 (1초)
    await new Promise(r => setTimeout(r, 1000))
    return fetchPosts()
  },
  // 1000ms 후 표시
  pendingComponent: () => <Spinner />,
  component: PostsList,
})
```

### pendingMs & pendingMinMs

```tsx
export const Route = createFileRoute('/dashboard')({
  loader: async () => fetchDashboard(),

  // 로딩이 200ms 이상 걸리면 표시
  pendingMs: 200,

  // 최소 500ms 표시 (깜빡임 방지)
  pendingMinMs: 500,

  pendingComponent: () => <LoadingScreen />,
  component: Dashboard,
})
```

### 라우터 수준 기본값

```tsx
const router = createRouter({
  routeTree,
  defaultPendingMs: 200,       // 기본 대기 시간
  defaultPendingMinMs: 300,    // 기본 최소 표시 시간
})
```

### 커스텀 로딩 UI

```tsx
const LoadingSpinner = () => (
  <div className="flex items-center justify-center">
    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" />
    <span>Loading...</span>
  </div>
)

export const Route = createFileRoute('/blog')({
  loader: async () => fetchBlogPosts(),
  pendingComponent: LoadingSpinner,
  pendingMs: 100,
  pendingMinMs: 300,
  component: Blog,
})
```

### 스켈레톤 화면

```tsx
const PostSkeleton = () => (
  <div className="space-y-4">
    {[1, 2, 3].map(i => (
      <div key={i} className="h-20 bg-gray-200 rounded animate-pulse" />
    ))}
  </div>
)

export const Route = createFileRoute('/posts')({
  loader: async () => fetchPosts(),
  pendingComponent: PostSkeleton,
  component: PostsList,
})
```

</pending_component>

---

<catch_all>

## Catch-all Route: 경로 매칭 실패

routes/$.tsx로 존재하지 않는 모든 경로 캐치.

### 기본 설정

```tsx
// /src/routes/$.tsx
export const Route = createFileRoute('/$')({
  component: NotFoundPage,
})

const NotFoundPage = () => {
  const { _splat } = Route.useParams()

  return (
    <div className="text-center">
      <h1>404 - Not Found</h1>
      <p>The page /{_splat} does not exist.</p>
      <Link to="/">Go Home</Link>
    </div>
  )
}
```

### _splat 파라미터

_splat은 매칭되지 않은 나머지 경로 문자열.

```tsx
// /users/123/settings 요청
// _splat = 'users/123/settings'

const DetailedNotFound = () => {
  const { _splat } = Route.useParams()
  const segments = _splat?.split('/') ?? []

  return (
    <div>
      <h1>Page Not Found</h1>
      <p>Requested path: /{_splat}</p>
      <p>Segments: {segments.join(', ')}</p>
      <Link to="/">Home</Link>
    </div>
  )
}
```

### errorComponent와 함께 사용

```tsx
export const Route = createFileRoute('/$')({
  errorComponent: CatchAllError,
  component: CatchAllNotFound,
})

const CatchAllError = ({ error }: ErrorComponentProps) => (
  <div>
    <h1>Error</h1>
    <p>{error.message}</p>
  </div>
)

const CatchAllNotFound = () => {
  const { _splat } = Route.useParams()
  return <div>Page /{_splat} not found</div>
}
```

</catch_all>

---

<priority>

## 에러 처리 우선순위

여러 상태가 동시에 발생할 때 표시 순서.

| 우선순위 | 컴포넌트 | 조건 | 표시 시기 |
|---------|---------|------|----------|
| 1 | `errorComponent` | loader/beforeLoad에서 Error throw | 에러 즉시 |
| 2 | `notFoundComponent` | `notFound()` throw | 404 즉시 |
| 3 | `pendingComponent` | loader 실행 중 (pendingMs 이후) | 로딩 진행 중 |
| 4 | `component` | 정상 데이터 | 완료 |

### 라우트 로딩 라이프사이클

```
Route Matching (Top-Down)
  route.params.parse
  route.validateSearch
    |
Route Pre-Loading (Serial)
  route.beforeLoad
  route.onError -> errorComponent
    |
Route Loading (Parallel)
  route.component.preload?
  route.loader
    -> pendingComponent (pendingMs 초과 시)
    -> component (완료)
  route.onError -> errorComponent
```

### 부모로 전파

```tsx
// 자식에 errorComponent 없으면 부모로 전파
// /src/routes/posts/$postId.tsx (errorComponent 없음)
export const Route = createFileRoute('/posts/$postId')({
  loader: async () => {
    throw new Error('Failed!')
  },
  component: PostDetail,
})

// /src/routes/posts.tsx (errorComponent 있음)
export const Route = createFileRoute('/posts')({
  errorComponent: PostsError,  // <- 여기서 잡힘
  component: () => <Outlet />,
})
```

</priority>

---

<error_recovery>

## 에러 복구 (router.invalidate)

에러 후 상태 재설정. 인증 갱신, 데이터 재로드 등에 활용.

### reset() vs router.invalidate()

| 방법 | 용도 |
|------|------|
| `reset()` | 에러 바운더리 UI만 리셋 (컴포넌트 렌더링 에러) |
| `router.invalidate()` | loader 재실행 + 에러 바운더리 리셋 (데이터 로딩 에러) |

```tsx
// 데이터 로딩 에러: router.invalidate() 사용 (권장)
const ErrorWithRecovery = ({ error, reset }: ErrorComponentProps) => {
  const router = useRouter()

  return (
    <div>
      <p>{error.message}</p>
      <button onClick={() => router.invalidate()}>
        Retry & Refresh
      </button>
    </div>
  )
}

// React Query와 함께 사용
const ErrorWithQueryRecovery = ({ error, reset }: ErrorComponentProps) => {
  const router = useRouter()
  const queryClient = useQueryClient()

  const handleRetry = () => {
    // 1. React Query 캐시 정리
    queryClient.clear()

    // 2. 라우터 상태 갱신 (loader 재실행 + 에러 바운더리 리셋)
    router.invalidate()
  }

  return (
    <div>
      <p>{error.message}</p>
      <button onClick={handleRetry}>Retry & Refresh</button>
    </div>
  )
}
```

### 인증 에러 후 로그인으로 리다이렉트

```tsx
const AuthError = ({ error, reset }: ErrorComponentProps) => {
  const router = useRouter()
  const navigate = useNavigate()

  const handleLogin = () => {
    // 인증 상태 갱신
    router.invalidate()

    // 로그인 페이지로 리다이렉트
    navigate({
      to: '/login',
      search: { redirect: location.href },
    })
  }

  if (error.message.includes('unauthorized')) {
    return (
      <div>
        <p>Session expired. Please log in again.</p>
        <button onClick={handleLogin}>Go to Login</button>
      </div>
    )
  }

  return <div>{error.message}</div>
}
```

</error_recovery>

---

<default_error>

## Default ErrorComponent

기본 에러 컴포넌트 import. 빠른 프로토타이핑용.

```tsx
import { DefaultErrorComponent } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  loader: async () => fetchDashboard(),
  errorComponent: DefaultErrorComponent,
  component: Dashboard,
})
```

</default_error>

---

<data_access_in_error>

## 에러 상황에서 데이터 접근

각 에러 컴포넌트에서 접근 가능한 데이터.

### errorComponent

Loader 데이터 접근 불가 (에러 발생했으므로).

```tsx
const ErrorHandler = ({ error, reset }: ErrorComponentProps) => {
  // loader 데이터 없음
  // const data = Route.useLoaderData()  // 에러 발생

  // params, search, context는 접근 가능
  const params = Route.useParams()
  const search = Route.useSearch()
  const context = Route.useRouteContext()

  return (
    <div>
      <p>Error on route: {params}</p>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

### notFoundComponent

Loader 데이터 없음. params/search/context만 접근. data 옵션으로 불완전한 데이터 전달 가능.

```tsx
const NotFoundHandler = ({ data }: { data?: any }) => {
  // Loader 데이터 없음
  // const { item } = Route.useLoaderData()

  // params, search, context는 접근 가능
  const { itemId } = Route.useParams()
  const search = Route.useSearch()
  const context = Route.useRouteContext()

  return (
    <div>
      <p>Item {itemId} not found</p>
      <p>You searched for: {search}</p>
    </div>
  )
}
```

| 컴포넌트 | useLoaderData | useParams | useSearch | useRouteContext | data 옵션 |
|----------|---------------|-----------|-----------|----------------|-----------|
| errorComponent | 불가 | 가능 | 가능 | 가능 | - |
| notFoundComponent | 불가 | 가능 | 가능 | 가능 | 가능 |
| pendingComponent | 불가 | 가능 | 가능 | 가능 | - |
| component | 가능 | 가능 | 가능 | 가능 | - |

</data_access_in_error>

---

<dos_donts>

## Do's & Don'ts

| Do | Don't |
|-------|---------|
| `throw new Error()` for server errors | Error throw 하지 말고 데이터 반환 |
| `throw notFound()` for missing resources | 404를 Error로 throw |
| `errorComponent`로 에러 처리 | try-catch in component |
| `pendingComponent`로 로딩 표시 | useQuery isLoading |
| `router.invalidate()`로 loader 에러 복구 | `reset()`만 호출 (loader 재실행 안 됨) |
| `ErrorComponent`로 폴백 처리 | 모든 에러를 커스텀 처리 |
| Catch-all `$` 라우트로 404 | 모든 라우트에 notFoundComponent |
| `notFoundMode: 'fuzzy'`로 레이아웃 보존 | root에서만 404 처리 |
| Root notFoundComponent 정의 | 기본 not found 그대로 사용 |
| `onError`로 에러 로깅 | 에러 무시 |
| `defaultNotFoundComponent` 라우터 설정 | 각 라우트별로 다른 404 UI |

</dos_donts>
