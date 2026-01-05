# TanStack Router - Search Params

Type-safe URL search params with Zod validation.

## 기본 사용

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'

// 스키마 정의
const productSearchSchema = z.object({
  page: z.number().catch(1),
  filter: z.string().catch(''),
  sort: z.enum(['newest', 'oldest', 'price']).catch('newest'),
})

type ProductSearch = z.infer<typeof productSearchSchema>

// 라우트에 적용
export const Route = createFileRoute('/products')({
  validateSearch: productSearchSchema,
  component: ProductsPage,
})

// 컴포넌트에서 사용
function ProductsPage() {
  const { page, filter, sort } = Route.useSearch()

  return (
    <div>
      <p>Page: {page}</p>
      <p>Filter: {filter}</p>
      <p>Sort: {sort}</p>
    </div>
  )
}
```

## Zod 스키마 패턴

```tsx
import { z } from 'zod'

// 기본값 (.catch)
const schema = z.object({
  page: z.number().catch(1),            // 파싱 실패 시 1
  search: z.string().optional(),        // undefined 허용
  tab: z.enum(['all', 'active']).catch('all'),
})

// 복잡한 타입
const advancedSchema = z.object({
  // 배열
  tags: z.array(z.string()).catch([]),

  // 날짜
  from: z.string().date().optional(),
  to: z.string().date().optional(),

  // 숫자 범위
  minPrice: z.number().min(0).catch(0),
  maxPrice: z.number().max(10000).catch(10000),

  // Boolean
  inStock: z.boolean().catch(true),
})
```

## Search Params 업데이트

### Link로 업데이트

```tsx
import { Link } from '@tanstack/react-router'

// 전체 교체
<Link to="/products" search={{ page: 1, sort: 'newest' }}>
  Reset
</Link>

// 병합
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>
  Next Page
</Link>

// 특정 값만 변경
<Link
  to="/products"
  search={prev => ({ ...prev, sort: 'price' })}
>
  Sort by Price
</Link>
```

### useNavigate로 업데이트

```tsx
import { useNavigate } from '@tanstack/react-router'

function Pagination() {
  const navigate = useNavigate()
  const { page } = Route.useSearch()

  const goToPage = (newPage: number) => {
    navigate({
      to: '/products',
      search: prev => ({ ...prev, page: newPage }),
    })
  }

  return (
    <div>
      <button onClick={() => goToPage(page - 1)} disabled={page <= 1}>
        Prev
      </button>
      <span>Page {page}</span>
      <button onClick={() => goToPage(page + 1)}>
        Next
      </button>
    </div>
  )
}
```

## 실전 예시

### 필터 + 정렬 + 페이지네이션

```tsx
import { createFileRoute, Link, useNavigate } from '@tanstack/react-router'
import { z } from 'zod'

const searchSchema = z.object({
  page: z.number().min(1).catch(1),
  pageSize: z.number().catch(10),
  search: z.string().catch(''),
  category: z.enum(['all', 'tech', 'lifestyle']).catch('all'),
  sort: z.enum(['newest', 'oldest', 'popular']).catch('newest'),
})

export const Route = createFileRoute('/posts')({
  validateSearch: searchSchema,
  loaderDeps: ({ search }) => ({ search }),  // search 변경 시 loader 재실행
  loader: async ({ deps: { search } }) => {
    return fetchPosts(search)
  },
  component: PostsPage,
})

function PostsPage() {
  const { page, search, category, sort } = Route.useSearch()
  const posts = Route.useLoaderData()
  const navigate = useNavigate()

  const updateSearch = (updates: Partial<typeof searchSchema._type>) => {
    navigate({
      to: '/posts',
      search: prev => ({ ...prev, ...updates, page: 1 }),  // 필터 변경 시 1페이지로
    })
  }

  return (
    <div>
      {/* 검색 */}
      <input
        value={search}
        onChange={e => updateSearch({ search: e.target.value })}
        placeholder="Search..."
      />

      {/* 카테고리 필터 */}
      <select
        value={category}
        onChange={e => updateSearch({ category: e.target.value as any })}
      >
        <option value="all">All</option>
        <option value="tech">Tech</option>
        <option value="lifestyle">Lifestyle</option>
      </select>

      {/* 정렬 */}
      <select
        value={sort}
        onChange={e => updateSearch({ sort: e.target.value as any })}
      >
        <option value="newest">Newest</option>
        <option value="oldest">Oldest</option>
        <option value="popular">Popular</option>
      </select>

      {/* 목록 */}
      {posts.map(post => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

## loaderDeps

Search params 변경 시 loader 재실행하려면 `loaderDeps` 필요.

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,
  loaderDeps: ({ search }) => ({ search }),  // 의존성 선언
  loader: async ({ deps: { search } }) => {
    return fetchProducts(search)
  },
})
```
