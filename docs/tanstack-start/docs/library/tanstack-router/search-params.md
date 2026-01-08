# TanStack Router - Search Params

<patterns>

```tsx
// Zod 스키마 + 라우트
const searchSchema = z.object({
  page: z.number().catch(1),            // 기본값
  search: z.string().optional(),        // 선택
  sort: z.enum(['newest', 'price']).catch('newest'),
  tags: z.array(z.string()).catch([]),  // 배열
  inStock: z.boolean().catch(true),     // Boolean
  from: z.string().date().optional(),   // 날짜
  minPrice: z.number().min(0).catch(0), // 범위
})

export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,
  loaderDeps: ({ search }) => ({ search }),  // search 변경 시 loader 재실행
  loader: async ({ deps: { search } }) => fetchProducts(search),
  component: ProductsPage,
})

const ProductsPage = () => {
  const { page, search, sort } = Route.useSearch()
  return <div>Page: {page}, Sort: {sort}</div>
}

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

// 실전: 필터 + 정렬 + 페이지네이션
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

</patterns>
