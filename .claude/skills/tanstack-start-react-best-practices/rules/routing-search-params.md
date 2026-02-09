---
title: Validate Search Params with Zod for Type Safety
impact: HIGH
impactDescription: prevents invalid URL state and runtime errors
tags: routing, search-params, useSearch, zod, validation, type-safety
---

## Zod로 Search Params 타입 안전하게 검증

TanStack Router의 `validateSearch`로 URL search params를 스키마 기반으로 검증하고, `useSearch`로 타입 안전하게 접근합니다.

**❌ 잘못된 예시 (타입 없는 search params):**

```tsx
function PostsPage() {
  const searchParams = new URLSearchParams(window.location.search)
  const page = Number(searchParams.get('page')) || 1  // 타입 안전성 없음
  const sort = searchParams.get('sort') ?? 'date'     // 유효성 검증 없음
}
```

**✅ 올바른 예시 (Zod 스키마 + validateSearch):**

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'
import { zodValidator, fallback } from '@tanstack/zod-adapter'

const postsSearchSchema = z.object({
  page: fallback(z.number().int().positive(), 1),
  sort: fallback(z.enum(['date', 'title', 'author']), 'date'),
  q: fallback(z.string().optional(), undefined),
  limit: fallback(z.number().int().min(1).max(100), 20),
})

export const Route = createFileRoute('/posts')({
  validateSearch: zodValidator(postsSearchSchema),
  component: PostsPage,
})

function PostsPage() {
  // 모든 타입이 스키마에서 자동 추론
  const { page, sort, q, limit } = Route.useSearch()

  return <div>Page {page}, sorted by {sort}</div>
}
```

**useSearch에서 select로 리렌더 최적화:**

```tsx
// ❌ 전체 search 구독 - 아무 param 변경 시 리렌더
function Pagination() {
  const { page, sort, q, limit } = Route.useSearch()
  return <div>Page {page}</div>  // page만 사용하는데 전체 리렌더
}

// ✅ select로 필요한 값만 구독
function Pagination() {
  const page = useSearch({
    from: '/posts',
    select: (search) => search.page,
  })
  return <div>Page {page}</div>  // page 변경 시에만 리렌더
}
```

**네비게이션에서 search params 업데이트:**

```tsx
function PostsFilter() {
  const navigate = useNavigate({ from: '/posts' })
  const { sort, q } = Route.useSearch()

  const handleSortChange = (newSort: string) => {
    navigate({
      search: (prev) => ({ ...prev, sort: newSort, page: 1 }),
    })
  }

  const clearFilters = () => {
    navigate({
      search: { page: 1, sort: 'date', limit: 20 },  // 전체 초기화
    })
  }

  return (
    <div>
      <select value={sort} onChange={(e) => handleSortChange(e.target.value)}>
        <option value="date">Date</option>
        <option value="title">Title</option>
      </select>
      <button onClick={clearFilters}>Clear</button>
    </div>
  )
}
```

**복잡한 스키마 패턴:**

```tsx
const filterSchema = z.object({
  search: z.string().trim().optional(),
  page: z.coerce.number().int().min(1).default(1),
  sort: z.enum(['name', 'date', 'popularity']).default('date'),
  order: z.enum(['asc', 'desc']).default('asc'),
  inStock: z.coerce.boolean().default(true),
  categories: z.array(z.string()).default([]),
})
```

**주의:** `@tanstack/zod-adapter`는 별도 패키지입니다. Valibot 사용 시 `@tanstack/valibot-adapter`.

참고: [Search Params Guide](https://tanstack.com/router/latest/docs/framework/react/guide/search-params)
