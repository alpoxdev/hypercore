# TanStack Router - Hooks

라우터 Hooks 레퍼런스.

## Route-Scoped Hooks

라우트 컴포넌트 내에서 사용. Type-safe.

### Route.useLoaderData()

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    return { post }
  },
  component: PostPage,
})

function PostPage() {
  const { post } = Route.useLoaderData()
  //      ^? { post: Post }
  return <h1>{post.title}</h1>
}
```

### Route.useParams()

```tsx
export const Route = createFileRoute('/posts/$postId')({
  component: PostPage,
})

function PostPage() {
  const { postId } = Route.useParams()
  //      ^? string
  return <div>Post ID: {postId}</div>
}
```

### Route.useSearch()

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sort: z.string().catch('newest'),
  }),
  component: ProductsPage,
})

function ProductsPage() {
  const { page, sort } = Route.useSearch()
  //      ^? number, string
  return <div>Page: {page}, Sort: {sort}</div>
}
```

### Route.useRouteContext()

```tsx
// _authed.tsx에서 beforeLoad로 user 전달 가정
export const Route = createFileRoute('/_authed/dashboard')({
  component: DashboardPage,
})

function DashboardPage() {
  const { user } = Route.useRouteContext()
  return <h1>Welcome, {user.name}</h1>
}
```

## Global Hooks

어디서든 사용 가능. 타입 안전성 직접 지정.

### useNavigate()

```tsx
import { useNavigate } from '@tanstack/react-router'

function Component() {
  const navigate = useNavigate()

  const handleClick = () => {
    navigate({
      to: '/posts/$postId',
      params: { postId: '123' },
    })
  }
}
```

### useMatch()

특정 라우트 매치 정보 접근.

```tsx
import { useMatch } from '@tanstack/react-router'

function Breadcrumb() {
  // 특정 라우트가 현재 매치되면 정보 반환
  const postMatch = useMatch({
    from: '/posts/$postId',
    shouldThrow: false,  // 매치 안 되면 undefined
  })

  if (postMatch) {
    return <span>Post: {postMatch.params.postId}</span>
  }

  return null
}
```

### useParams() (Global)

```tsx
import { useParams } from '@tanstack/react-router'

// 타입 지정 필요
const { postId } = useParams({ from: '/posts/$postId' })

// strict: false로 모든 params
const params = useParams({ strict: false })
```

### useSearch() (Global)

```tsx
import { useSearch } from '@tanstack/react-router'

// 타입 지정 필요
const { page } = useSearch({ from: '/products' })

// strict: false로 현재 라우트 search
const search = useSearch({ strict: false })
```

### useRouterState()

라우터 전체 상태 접근.

```tsx
import { useRouterState } from '@tanstack/react-router'

function CurrentPath() {
  const pathname = useRouterState({
    select: state => state.location.pathname,
  })

  return <span>Current: {pathname}</span>
}

// 전체 location
const location = useRouterState({
  select: state => state.location,
})

// pending 상태
const isLoading = useRouterState({
  select: state => state.isLoading,
})
```

### useLocation()

현재 location 정보.

```tsx
import { useLocation } from '@tanstack/react-router'

function Component() {
  const location = useLocation()

  console.log(location.pathname)  // '/posts/123'
  console.log(location.search)    // { page: 1 }
  console.log(location.hash)      // '#section'
}
```

## Hook 비교

| Hook | Scope | Type Safety | 용도 |
|------|-------|-------------|------|
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
