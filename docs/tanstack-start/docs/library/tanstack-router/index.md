# TanStack Router

> **Version**: 1.x | Type-safe React Router

@navigation.md
@search-params.md
@route-context.md
@hooks.md
@error-handling.md

---

## Quick Reference

```tsx
import { createFileRoute, Link, Outlet } from '@tanstack/react-router'

// 기본 라우트
export const Route = createFileRoute('/about')({
  component: AboutPage,
})

// Loader + 동적 파라미터
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    return { post }
  },
  component: PostPage,
})

function PostPage() {
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

function ProductsPage() {
  const { page, sort } = Route.useSearch()
  return <div>Page {page}, Sort: {sort}</div>
}
```

---

## 파일 구조

```
routes/
├── __root.tsx          # Root layout
├── index.tsx           # /
├── about.tsx           # /about
├── posts/
│   ├── index.tsx       # /posts
│   └── $postId.tsx     # /posts/:postId
├── _authed/            # Protected routes (pathless)
│   ├── dashboard.tsx   # /dashboard
│   └── settings.tsx    # /settings
└── $.tsx               # Catch-all (404)
```

| 파일명 패턴 | 설명 |
|------------|------|
| `index.tsx` | 디렉토리 루트 |
| `$param.tsx` | 동적 세그먼트 |
| `_layout/` | Pathless layout |
| `$.tsx` | Catch-all |

---

## Root Route

```tsx
// routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => <div>404 Not Found</div>,
})

function RootLayout() {
  return (
    <div>
      <nav>{/* navigation */}</nav>
      <main>
        <Outlet />
      </main>
    </div>
  )
}
```

---

## Route Options

| 옵션 | 설명 |
|------|------|
| `component` | 렌더링할 컴포넌트 |
| `loader` | 데이터 로드 함수 |
| `beforeLoad` | 로드 전 실행 (인증 체크 등) |
| `validateSearch` | Search params 스키마 |
| `pendingComponent` | 로딩 중 표시 |
| `errorComponent` | 에러 발생 시 표시 |
| `notFoundComponent` | Not found 시 표시 |

---

## Navigation

```tsx
import { Link, useNavigate } from '@tanstack/react-router'

// Link
<Link to="/posts/$postId" params={{ postId: '123' }}>
  Post
</Link>

// Search params
<Link to="/products" search={{ page: 1, sort: 'newest' }}>
  Products
</Link>

// Programmatic
const navigate = useNavigate()
navigate({ to: '/posts/$postId', params: { postId: '123' } })
navigate({ to: '/products', search: prev => ({ ...prev, page: 2 }) })
```

---

## Hooks

| Hook | 용도 |
|------|------|
| `Route.useLoaderData()` | Loader 반환값 |
| `Route.useParams()` | Path 파라미터 |
| `Route.useSearch()` | Search params |
| `Route.useRouteContext()` | Route context |
| `useNavigate()` | 프로그래밍 네비게이션 |
| `useMatch({ from })` | 특정 라우트 매치 정보 |
