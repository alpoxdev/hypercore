# TanStack Router - Hooks

> TanStack Router v1.159.4

모든 라우터 훅 참조. Route-scoped (타입 안전)과 Global (수동 타입).

---

<route_scoped>

## Route-Scoped Hooks: 타입 안전 (권장)

현재 라우트 내에서만 사용. 타입 자동 추론.

### Route.useLoaderData()

Loader에서 반환한 데이터 접근. 타입 안전.

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => ({
    post: await getPost(params.postId),
    relatedPosts: await getRelated(params.postId),
  }),
  component: PostDetail,
})

const PostDetail = () => {
  // ✅ 타입 안전: post, relatedPosts 타입 자동 추론
  const { post, relatedPosts } = Route.useLoaderData()

  return (
    <div>
      <h1>{post.title}</h1>
      <div>{relatedPosts.map(p => <span key={p.id}>{p.title}</span>)}</div>
    </div>
  )
}
```

### Route.useParams()

Path params 접근. 타입 안전.

```tsx
export const Route = createFileRoute('/users/$userId/posts/$postId')({
  component: UserPost,
})

const UserPost = () => {
  // ✅ 타입 안전: userId, postId 타입 추론됨
  const { userId, postId } = Route.useParams()

  return <div>User {userId}, Post {postId}</div>
}
```

### Route.useSearch()

Search params 접근. ValidateSearch 스키마 타입 추론.

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sort: z.enum(['newest', 'price']).catch('newest'),
  }),
  component: Products,
})

const Products = () => {
  // ✅ 타입 안전: page, sort 타입 추론됨
  const { page, sort } = Route.useSearch()

  return <div>Page {page}, Sort {sort}</div>
}
```

### Route.useRouteContext()

현재 라우트나 부모 라우트의 context 접근.

```tsx
// 부모 라우트 (_authed.tsx)
export const Route = createFileRoute('/_authed')({
  beforeLoad: async () => ({
    user: await getCurrentUser(),
    permissions: await getPermissions(),
  }),
  component: () => <Outlet />,
})

// 자식 라우트 (_authed/dashboard.tsx)
export const Route = createFileRoute('/_authed/dashboard')({
  component: Dashboard,
})

const Dashboard = () => {
  // ✅ 부모의 context 접근
  const { user, permissions } = Route.useRouteContext()

  return <h1>Welcome, {user.name}!</h1>
}
```

</route_scoped>

---

<global_hooks>

## Global Hooks: 수동 타입 지정

어디서든 사용 가능. `from` 파라미터로 타입 체크 가능.

### useNavigate()

네비게이션 함수. 자동 타입 지정 (from 선택 사항).

```tsx
// 일반적 사용 (타입 체크 안 함)
const Component = () => {
  const navigate = useNavigate()
  navigate({ to: '/posts/$postId', params: { postId: '123' } })
}

// 타입 안전 (특정 라우트 내에서만 호출)
export const Route = createFileRoute('/posts/$postId')({
  component: PostDetail,
})

const PostDetail = () => {
  const navigate = useNavigate({ from: '/posts/$postId' })
  navigate({ to: '/posts/$postId', params: { postId: '456' } })
}
```

### useMatch()

특정 라우트 매칭 확인. 조건부 렌더링에 활용.

```tsx
const Component = () => {
  // postRoute가 현재 경로와 일치하는지 확인
  const postMatch = useMatch({ from: '/posts/$postId', shouldThrow: false })

  if (postMatch) {
    return <span>Viewing post: {postMatch.params.postId}</span>
  }

  return <span>Not in posts route</span>
}

// shouldThrow=true: 매칭 안 되면 에러 throw (기본값)
const StrictComponent = () => {
  const match = useMatch({ from: '/dashboard', shouldThrow: true })
  // /dashboard가 아니면 에러 발생
}
```

### useParams()

Path params 접근 (Global). from으로 타입 지정 가능.

```tsx
// 타입 지정 없음 (any)
const Component = () => {
  const params = useParams({ strict: false })  // 현재 라우트 params 모두
  return <div>{JSON.stringify(params)}</div>
}

// 특정 라우트 params (타입 지정)
const RelatedComponent = () => {
  const { postId } = useParams({ from: '/posts/$postId' })
  return <div>Post: {postId}</div>
}

// strict=true: 라우트 파라미터만 포함
const StrictParams = () => {
  const params = useParams({ from: '/posts/$postId', strict: true })
  // postId만 포함
}
```

### useSearch()

Search params 접근 (Global). from으로 타입 지정 가능.

```tsx
// 현재 라우트 search params
const Component = () => {
  const search = useSearch({ strict: false })
  return <div>{JSON.stringify(search)}</div>
}

// 특정 라우트 search params (타입 지정)
const FilteredComponent = () => {
  const { page, sort } = useSearch({ from: '/products' })
  return <div>Page {page}, Sort {sort}</div>
}

// strict=true: validateSearch 스키마 타입만 포함
const StrictSearch = () => {
  const search = useSearch({ from: '/products', strict: true })
}
```

### useRouterState()

라우터 전역 상태 접근. Select로 필요한 값만 추출.

```tsx
const Component = () => {
  // 현재 pathname
  const pathname = useRouterState({ select: state => state.location.pathname })

  // 로딩 상태
  const isLoading = useRouterState({ select: state => state.isLoading })

  // 매치된 라우트 정보
  const matchedRoutes = useRouterState({ select: state => state.matches })

  // 전체 라우터 상태
  const status = useRouterState({ select: state => state.status })

  return (
    <div>
      <p>Path: {pathname}</p>
      <p>{isLoading ? 'Loading...' : 'Ready'}</p>
    </div>
  )
}
```

### useLocation()

현재 위치 정보. pathname, search, hash, state.

```tsx
const Component = () => {
  const location = useLocation()

  return (
    <div>
      <p>Pathname: {location.pathname}</p>
      <p>Search: {JSON.stringify(location.search)}</p>
      <p>Hash: {location.hash}</p>
      <p>State: {JSON.stringify(location.state)}</p>
    </div>
  )
}
```

### useRouter()

라우터 인스턴스 접근. invalidate, navigate, 캐시 관리 등.

```tsx
const Component = () => {
  const router = useRouter()

  // loader 재실행 + 캐시 무효화
  const handleRefresh = () => router.invalidate()

  // 라우터 인스턴스로 네비게이션
  const goTo = () => router.navigate({ to: '/posts' })

  return <button onClick={handleRefresh}>Refresh</button>
}
```

### useMatchRoute()

라우트 매칭 확인 함수 반환. pending 상태 체크에 유용.

```tsx
const Component = () => {
  const matchRoute = useMatchRoute()

  // 프로그래매틱 매칭 체크
  const isUsersRoute = matchRoute({ to: '/users' })
  const isUsersPending = matchRoute({ to: '/users', pending: true })

  return (
    <div>
      {isUsersPending && <Spinner />}
    </div>
  )
}
```

### Route.useNavigate()

현재 라우트에서 from이 자동 설정된 네비게이션. useNavigate({ from })의 축약형.

```tsx
export const Route = createFileRoute('/posts/$postId')({
  component: PostDetail,
})

const PostDetail = () => {
  // from: '/posts/$postId'가 자동 설정됨
  const navigate = Route.useNavigate()

  const goToRelated = (id: string) => {
    navigate({
      to: '/posts/$postId',
      params: { postId: id },  // 타입 체크됨
    })
  }

  return <button onClick={() => goToRelated('456')}>Related</button>
}
```

</global_hooks>

---

<get_route_api>

## getRouteApi(): 파일 분리 시 타입 안전

Route-scoped 훅을 파일 분리해서 사용할 때 타입 유지.

### 문제상황

```tsx
// /src/routes/posts/index.tsx에서
export const Route = createFileRoute('/posts')({
  validateSearch: postsSearchSchema,
  component: ProductsPage,
})

// /src/routes/posts/-components/filter.tsx에서
const Filter = () => {
  // 여기서 Route.useSearch()를 쓸 수 없음 (Route가 정의되지 않음)
  // 수동으로 타입 지정해야 함
}
```

### 해결: getRouteApi()

```tsx
// /src/routes/posts/-search-schema.ts
import { z } from 'zod'

export const postsSearchSchema = z.object({
  page: z.number().catch(1),
  sort: z.enum(['newest', 'price']).catch('newest'),
})

// /src/routes/posts/index.tsx
export const Route = createFileRoute('/posts')({
  validateSearch: postsSearchSchema,
  component: ProductsPage,
})

// /src/routes/posts/-components/filter.tsx
import { getRouteApi } from '@tanstack/react-router'
import { postsSearchSchema } from '../-search-schema'

const postsRoute = getRouteApi('/posts')

const Filter = () => {
  // ✅ 타입 안전: postsSearchSchema 타입 자동 적용
  const { page, sort } = postsRoute.useSearch()
  const navigate = useNavigate()

  return (
    <select
      value={sort}
      onChange={e =>
        navigate({
          to: '/posts',
          search: prev => ({ ...prev, sort: e.target.value as any }),
        })
      }
    >
      <option value="newest">Newest</option>
      <option value="price">Price</option>
    </select>
  )
}

export default Filter
```

### 복잡한 예시

```tsx
// /src/lib/route-apis.ts
import { getRouteApi } from '@tanstack/react-router'

// 모든 getRouteApi 한 파일에 정의
export const rootRoute = getRouteApi('/__root')
export const postsRoute = getRouteApi('/posts')
export const postDetailRoute = getRouteApi('/posts/$postId')
export const dashboardRoute = getRouteApi('/_authed/dashboard')

// /src/routes/posts/-components/filter.tsx
import { postsRoute } from '@/lib/route-apis'

const Filter = () => {
  const search = postsRoute.useSearch()
  const loaderData = postsRoute.useLoaderData()

  return <div>{/* ... */}</div>
}
```

</get_route_api>

---

<complete_reference>

## 완전 참조표

| Hook | Scope | 타입 | 반환값 | 용도 |
|------|-------|------|--------|------|
| `Route.useLoaderData()` | Route | Auto | Loader 반환값 | 데이터 로드 결과 |
| `Route.useParams()` | Route | Auto | Path params | URL 파라미터 접근 |
| `Route.useSearch()` | Route | Auto | Search params | Query string 접근 |
| `Route.useRouteContext()` | Route | Auto | Route context | 라우트 context 공유 |
| `useNavigate()` | Global | Manual | function | 네비게이션 함수 |
| `useMatch({ from })` | Global | Manual | match object \| null | 라우트 매칭 확인 |
| `useParams({ from })` | Global | Manual | object | 특정 라우트 params |
| `useSearch({ from })` | Global | Manual | object | 특정 라우트 search |
| `useRouterState({ select })` | Global | Manual | state value | 라우터 전역 상태 |
| `useLocation()` | Global | Auto | location object | 현재 위치 정보 |
| `useRouter()` | Global | Auto | router instance | 라우터 인스턴스 접근 |
| `useMatchRoute()` | Global | Manual | function | 라우트 매칭 확인 함수 |
| `Route.useNavigate()` | Route | Auto | function | from 자동 설정된 네비게이션 |
| `getRouteApi(path)` | Any | Manual | route API object | 파일 분리 시 타입 지정 |

</complete_reference>

---

<examples>

## 실전 예시

### Route-Scoped: 상세 페이지

```tsx
// /src/routes/posts/$postId.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => ({
    post: await getPost(params.postId),
    relatedPosts: await getRelated(params.postId),
  }),
  component: PostDetail,
})

const PostDetail = () => {
  // ✅ 모두 타입 안전
  const { post, relatedPosts } = Route.useLoaderData()
  const { postId } = Route.useParams()

  return (
    <div>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <h2>Related Posts</h2>
      {relatedPosts.map(p => (
        <Link key={p.id} to={`/posts/${p.id}`}>
          {p.title}
        </Link>
      ))}
    </div>
  )
}
```

### Global: 탭 네비게이션

```tsx
const TabNavigation = () => {
  const location = useLocation()
  const navigate = useNavigate()

  const tabs = [
    { label: 'Home', to: '/' },
    { label: 'Posts', to: '/posts' },
    { label: 'Dashboard', to: '/dashboard' },
  ]

  return (
    <nav>
      {tabs.map(tab => (
        <button
          key={tab.to}
          onClick={() => navigate({ to: tab.to })}
          className={location.pathname === tab.to ? 'active' : ''}
        >
          {tab.label}
        </button>
      ))}
    </nav>
  )
}
```

### 조건부 렌더링: useMatch

```tsx
const Header = () => {
  // /posts/$postId 라우트 확인
  const postMatch = useMatch({ from: '/posts/$postId', shouldThrow: false })

  return (
    <header>
      <h1>My Site</h1>
      {postMatch && <p>Viewing post {postMatch.params.postId}</p>}
    </header>
  )
}
```

### 파일 분리: getRouteApi

```tsx
// /src/lib/route-apis.ts
import { getRouteApi } from '@tanstack/react-router'

export const dashboardRoute = getRouteApi('/_authed/dashboard')

// /src/routes/_authed/dashboard/-components/stats.tsx
import { dashboardRoute } from '@/lib/route-apis'

const Stats = () => {
  // ✅ 파일 분리되어도 타입 안전
  const { stats } = dashboardRoute.useLoaderData()
  const { userId } = dashboardRoute.useParams()

  return <div>{/* ... */}</div>
}
```

</examples>

---

<dos_donts>

## Do's & Don'ts

| ✅ Do | ❌ Don't |
|-------|---------|
| `Route.useLoaderData()` | `useLoaderData()`로 수동 타입 |
| `Route.useParams()` | `useParams()`로 수동 타입 |
| `Route.useSearch()` | `useSearch()`로 수동 타입 |
| `getRouteApi(path).useSearch()` | 파일 분리 후 type annotation |
| `from` 파라미터 사용 | `any` 타입 사용 |
| `select` 함수로 필요한 값만 | `useRouterState()` 전체 구독 |
| `useMatch({ shouldThrow: false })` | 에러 날 수 있게 shouldThrow 생략 |
| `getRouteApi()` 파일 분리 | Route import로 순환 참조 발생 |
| `Route.useNavigate()` 사용 | `useNavigate()` + from 수동 지정 |
| `useRouter()` + `invalidate()` | 수동 상태 동기화 |

</dos_donts>
