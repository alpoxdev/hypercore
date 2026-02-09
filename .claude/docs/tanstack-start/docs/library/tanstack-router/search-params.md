# TanStack Router - Search Params

> TanStack Router v1.159.4

Search params 검증, 읽기, 쓰기, 직렬화를 다룬다.

---

<why_not_url_search_params>

## 왜 URLSearchParams를 직접 쓰지 않는가

TanStack Router는 JSON-first Search Params를 사용한다. URLSearchParams의 한계:

- 항상 문자열만 지원
- 대부분 flat 구조
- 중첩 객체/배열 지원 미흡
- 매번 파싱 시 참조 무결성 상실 (React 성능 이슈)

TanStack Router의 장점:

- 숫자, boolean 등 원시 타입 보존
- 중첩 객체/배열을 JSON으로 자동 직렬화
- 첫 번째 레벨은 URLSearchParams 호환 유지
- Structural Sharing으로 불필요한 리렌더 방지

```tsx
// 이 네비게이션은:
<Link
  to="/shop"
  search={{
    pageIndex: 3,
    includeCategories: ['electronics', 'gifts'],
    sortBy: 'price',
    desc: true,
  }}
/>

// 이 URL을 생성:
// /shop?pageIndex=3&includeCategories=%5B%22electronics%22%2C%22gifts%22%5D&sortBy=price&desc=true

// 파싱하면 정확히 원래 JSON으로 복원:
// { pageIndex: 3, includeCategories: ["electronics", "gifts"], sortBy: "price", desc: true }
```

</why_not_url_search_params>

---

<zod_basic>

## Zod 스키마: 기본 접근

validateSearch로 search params를 Zod 스키마로 검증. 타입 안전과 기본값 제공.

### 스키마 정의

```tsx
import { z } from 'zod'

const searchSchema = z.object({
  // 기본값 (catch) - 유효하지 않은 값이면 기본값 사용
  page: z.number().catch(1),
  sort: z.enum(['newest', 'price']).catch('newest'),

  // 선택 필드
  search: z.string().optional(),
  category: z.string().optional(),

  // 배열
  tags: z.array(z.string()).catch([]),

  // Boolean
  inStock: z.boolean().catch(true),

  // 날짜 (ISO 형식)
  from: z.string().date().optional(),
  to: z.string().date().optional(),

  // 범위
  minPrice: z.number().min(0).catch(0),
  maxPrice: z.number().max(10000).optional(),
})
```

### 라우트에 적용

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,
  component: ProductsPage,
})

const ProductsPage = () => {
  // 타입 안전: page, sort 타입 추론됨
  const { page, sort, search } = Route.useSearch()

  return <div>Page {page}, Sort: {sort}</div>
}
```

### catch() vs default() 선택

```tsx
// catch(): 검증 실패 시 기본값 (에러 안 남, 권장)
page: z.number().catch(1)

// default(): 값이 undefined일 때 기본값 (검증 실패 시 에러)
page: z.number().default(1)
```

> `catch()`를 권장하는 이유: search params가 잘못되었을 때 사용자 경험을 중단시키지 않기 위함. 에러를 보여줘야 한다면 `default()` 사용.

### 검증 실패 시 에러 처리

`validateSearch`에서 에러가 throw되면 `error.routerCode`가 `VALIDATE_SEARCH`로 설정되고 `errorComponent`가 렌더링됨.

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().min(1),  // catch 없으면 실패 시 에러
  }),
  errorComponent: ({ error }) => {
    if (error.routerCode === 'VALIDATE_SEARCH') {
      return <div>잘못된 검색 파라미터입니다.</div>
    }
    return <div>{error.message}</div>
  },
  component: ProductsPage,
})
```

</zod_basic>

---

<zod_adapter>

## Zod Adapter: 고급 검증

`@tanstack/zod-adapter`의 `zodValidator()`를 사용하면 `input`/`output` 타입이 정확히 추론됨.

### 설치

```bash
npm install @tanstack/zod-adapter zod
```

### 기본 사용 (default와 함께)

```tsx
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  page: z.number().default(1),
  filter: z.string().default(''),
  sort: z.enum(['newest', 'oldest', 'price']).default('newest'),
})

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(searchSchema),
  component: ProductsPage,
})

// Link에서 search가 선택적으로 됨 (default 덕분)
<Link to="/products" />  // search 없어도 됨
```

### fallback(): 타입 유지 + 검증 실패 기본값

`catch()`는 타입을 `unknown`으로 만들 수 있어, adapter의 `fallback()`으로 타입 유지.

```tsx
import { fallback, zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  page: fallback(z.number(), 1).default(1),
  filter: fallback(z.string(), '').default(''),
  sort: fallback(z.enum(['newest', 'oldest', 'price']), 'newest').default('newest'),
})

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(searchSchema),
  component: ProductsPage,
})
```

### input/output 타입 커스텀

```tsx
// 네비게이션 시 input 타입과 읽기 시 output 타입을 다르게 설정
export const Route = createFileRoute('/products')({
  validateSearch: zodValidator({
    schema: searchSchema,
    input: 'output',   // 네비게이션 시 output 타입 사용
    output: 'input',   // 읽기 시 input 타입 사용
  }),
})
```

### 에러 처리

```tsx
import { SearchParamError } from '@tanstack/router'

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(searchSchema),
  // 검증 실패 시 처리
  errorComponent: ({ error }) => (
    <div>
      <p>Invalid search params</p>
      <pre>{error.message}</pre>
    </div>
  ),
  component: ProductsPage,
})
```

</zod_adapter>

---

<valibot_support>

## Valibot 지원 (v1.0+)

Valibot은 Standard Schema를 native로 지원. adapter 없이 바로 사용 가능.

### 설치

```bash
npm install valibot
```

### 기본 사용

```tsx
import * as v from 'valibot'

const searchSchema = v.object({
  page: v.optional(v.fallback(v.number(), 1), 1),
  filter: v.optional(v.fallback(v.string(), ''), ''),
  sort: v.optional(
    v.fallback(v.picklist(['newest', 'oldest', 'price']), 'newest'),
    'newest',
  ),
})

export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,  // Standard Schema 자동 인식
  component: ProductsPage,
})
```

</valibot_support>

---

<arktype_support>

## ArkType 지원 (2.0-rc+)

ArkType도 Standard Schema를 구현. adapter 없이 사용 가능.

```tsx
import { type } from 'arktype'

const searchSchema = type({
  page: 'number = 1',
  filter: 'string = ""',
  sort: '"newest" | "oldest" | "price" = "newest"',
})

export const Route = createFileRoute('/products')({
  validateSearch: searchSchema,
  component: ProductsPage,
})
```

</arktype_support>

---

<loader_deps>

## loaderDeps: Search 의존 Loader

search params가 변경될 때 loader를 자동으로 재실행.

중요: **사용하는 deps만 포함해야 한다.** 불필요한 deps 추가 시 불필요한 재실행 발생.

### 기본 예시

```tsx
const postsSchema = z.object({
  page: z.number().catch(1),
  search: z.string().optional(),
  category: z.string().optional(),
})

export const Route = createFileRoute('/posts')({
  validateSearch: postsSchema,
  // loaderDeps: search 변경 시 loader 재실행
  loaderDeps: ({ search }) => ({ search }),
  loader: async ({ deps: { search } }) => {
    // search 변경될 때마다 재실행
    return fetchPosts({
      page: search.page,
      query: search.search,
      category: search.category,
    })
  },
  component: PostsPage,
})
```

### params와 함께 사용

```tsx
export const Route = createFileRoute('/users/$userId/posts')({
  validateSearch: z.object({
    page: z.number().catch(1),
  }),
  // 사용하는 deps만 포함
  loaderDeps: ({ search, params }) => ({
    page: search.page,
    userId: params.userId,
  }),
  loader: async ({ deps: { page, userId } }) => {
    return fetchUserPosts(userId, page)
  },
  component: UserPostsPage,
})

const UserPostsPage = () => {
  const posts = Route.useLoaderData()
  const { page } = Route.useSearch()
  const { userId } = Route.useParams()

  return <div>{posts.length} posts for user {userId}</div>
}
```

### 주의: 불필요한 deps 피하기

```tsx
// 잘못된 예: 전체 search 반환 (안 쓰는 필드 변경에도 리로드)
loaderDeps: ({ search }) => search,
loader: ({ deps }) => fetchPosts({ page: deps.page }),  // page만 쓰는데!

// 올바른 예: 사용하는 것만 포함
loaderDeps: ({ search }) => ({
  page: search.page,
  limit: search.limit,
}),
loader: ({ deps }) => fetchPosts(deps),
```

</loader_deps>

---

<reading>

## Search Params 읽기

### 컴포넌트에서 읽기 (Route.useSearch)

라우트 내부에서 타입 안전하게 접근.

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sort: z.enum(['newest', 'price']).catch('newest'),
  }),
  component: ProductsPage,
})

const ProductsPage = () => {
  // 타입 안전: page, sort 타입 자동 추론
  const { page, sort } = Route.useSearch()

  return (
    <div>
      <h1>Products</h1>
      <p>Page {page}, Sorted by {sort}</p>
    </div>
  )
}
```

### 부모 라우트의 Search Params 상속

부모 라우트의 search params 타입이 자식 라우트에서도 접근 가능.

```tsx
// /routes/shop/products.tsx
export const Route = createFileRoute('/shop/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sort: z.enum(['newest', 'price']).catch('newest'),
  }),
})

// /routes/shop/products/$productId.tsx
export const Route = createFileRoute('/shop/products/$productId')({
  beforeLoad: ({ search }) => {
    search  // ProductSearch 타입 상속됨
  },
})
```

### Loader에서 읽기 (loaderDeps)

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    category: z.string().optional(),
  }),
  loaderDeps: ({ search }) => ({ search }),
  loader: async ({ deps: { search } }) => {
    // Loader에서 search 접근
    const products = await fetchProducts({
      page: search.page,
      category: search.category,
    })
    return { products }
  },
  component: ProductsPage,
})
```

### 라우트 외부에서 읽기 (useSearch)

헤더, 사이드바 등 다른 라우트의 search params 접근.

```tsx
// `/products` 라우트의 search params를 다른 곳에서 읽기
const Header = () => {
  // from 명시로 타입 안전
  const { search } = useSearch({ from: '/products' })

  return <div>Search: {search}</div>
}

// 현재 라우트의 search params (무조건적)
const Sidebar = () => {
  const search = useSearch({ strict: false })  // 모든 search 접근 가능
  return <div>{JSON.stringify(search)}</div>
}

// getRouteApi로 파일 분리 시 타입 안전
import { getRouteApi } from '@tanstack/react-router'
const routeApi = getRouteApi('/products')

const Filter = () => {
  const { page, sort } = routeApi.useSearch()
  return <div>Page {page}</div>
}
```

</reading>

---

<writing>

## Search Params 쓰기

### Link로 업데이트

```tsx
// 절대값 설정
<Link to="/products" search={{ page: 1, sort: 'newest' }}>
  Reset
</Link>

// 함수로 이전 값 기반 업데이트
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>
  Next Page
</Link>

// from 지정으로 to 생략 (현재 페이지 search 업데이트)
<Link from={Route.fullPath} search={prev => ({ page: prev.page + 1 })}>
  Next Page
</Link>

// to="."으로 느슨한 타입의 search 업데이트 (범용 컴포넌트)
<Link to="." search={prev => ({ ...prev, page: prev.page + 1 })}>
  Next Page
</Link>
```

### useNavigate로 업데이트

```tsx
const Pagination = () => {
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
        Previous
      </button>
      <span>Page {page}</span>
      <button onClick={() => goToPage(page + 1)}>
        Next
      </button>
    </div>
  )
}
```

### router.navigate로 직접 업데이트

```tsx
const Component = () => {
  const router = useRouter()

  const clearFilters = () => {
    router.navigate({
      to: '/products',
      search: { page: 1, sort: 'newest' },
    })
  }

  return <button onClick={clearFilters}>Clear Filters</button>
}
```

</writing>

---

<search_middleware>

## Search Middleware: 자동 변환

Search params를 링크 생성 시 및 네비게이션 후 자동 변환.

### retainSearchParams: search 유지

특정 search params를 모든 하위 링크에서 자동 유지.

```tsx
import { retainSearchParams } from '@tanstack/react-router'
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  rootValue: z.string().optional(),
})

export const Route = createRootRoute({
  validateSearch: zodValidator(searchSchema),
  search: {
    middlewares: [retainSearchParams(['rootValue'])],
  },
})
```

### stripSearchParams: 기본값 제거

기본값과 동일한 search params를 URL에서 자동 제거 (깔끔한 URL).

```tsx
import { stripSearchParams } from '@tanstack/react-router'
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const defaultValues = {
  one: 'abc',
  two: 'xyz',
}

const searchSchema = z.object({
  one: z.string().default(defaultValues.one),
  two: z.string().default(defaultValues.two),
})

export const Route = createFileRoute('/hello')({
  validateSearch: zodValidator(searchSchema),
  search: {
    middlewares: [stripSearchParams(defaultValues)],
  },
})
```

### 여러 미들웨어 체이닝

```tsx
export const Route = createFileRoute('/search')({
  validateSearch: zodValidator(
    z.object({
      retainMe: z.string().optional(),
      arrayWithDefaults: z.string().array().default(['foo', 'bar']),
      required: z.string(),
    }),
  ),
  search: {
    middlewares: [
      retainSearchParams(['retainMe']),
      stripSearchParams({ arrayWithDefaults: ['foo', 'bar'] }),
    ],
  },
})
```

### 커스텀 미들웨어

```tsx
export const Route = createRootRoute({
  validateSearch: zodValidator(searchSchema),
  search: {
    middlewares: [
      ({ search, next }) => {
        const result = next(search)
        return {
          rootValue: search.rootValue,  // 항상 유지
          ...result,
        }
      },
    ],
  },
})
```

### beforeLoad에서 search 정규화

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().catch(1),
    sortBy: z.enum(['asc', 'desc']).catch('asc'),
  }),
  // beforeLoad에서 search 정규화
  beforeLoad: async ({ search }) => {
    // search.page가 음수면 1로 고정
    const sanitized = {
      ...search,
      page: Math.max(1, search.page),
    }
    return { sanitized }
  },
  loader: async ({ context }) => {
    // context.sanitized 사용
    return fetchProducts(context.sanitized)
  },
  component: ProductsPage,
})
```

</search_middleware>

---

<custom_serialization>

## 커스텀 직렬화

기본 JSON.stringify/JSON.parse 대신 다른 직렬화 라이브러리 사용 가능.

### Base64 인코딩

```tsx
import { parseSearchWith, stringifySearchWith } from '@tanstack/react-router'

const router = createRouter({
  routeTree,
  parseSearch: parseSearchWith(value => JSON.parse(decodeFromBinary(value))),
  stringifySearch: stringifySearchWith(value => encodeToBinary(JSON.stringify(value))),
})

// 안전한 바이너리 인코딩/디코딩
function encodeToBinary(str: string): string {
  return btoa(
    encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, (_, p1) =>
      String.fromCharCode(parseInt(p1, 16)),
    ),
  )
}

function decodeFromBinary(str: string): string {
  return decodeURIComponent(
    Array.prototype.map
      .call(atob(str), (c) =>
        '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2),
      )
      .join(''),
  )
}
```

### JSURL2 (압축 + 가독성)

```tsx
import { parse, stringify } from 'jsurl2'

const router = createRouter({
  parseSearch: parseSearchWith(parse),
  stringifySearch: stringifySearchWith(stringify),
})
// 결과: ?filters=(author~tanner~min*_words~800)~
```

### query-string

```tsx
import qs from 'query-string'

const router = createRouter({
  stringifySearch: stringifySearchWith(value => qs.stringify(value)),
  parseSearch: parseSearchWith(value => qs.parse(value)),
})
```

</custom_serialization>

---

<error_handling>

## 에러 처리

### routerCode 활용

```tsx
export const Route = createFileRoute('/products')({
  validateSearch: z.object({
    page: z.number().min(1).catch(1),
  }),
  errorComponent: ({ error }) => {
    // routerCode로 에러 타입 구분
    if (error.routerCode === 'VALIDATE_SEARCH') {
      return <div>Invalid search parameters. Using defaults.</div>
    }
    return <div>{error.message}</div>
  },
  component: ProductsPage,
})
```

### 유효하지 않은 값 처리

```tsx
const searchSchema = z.object({
  page: z
    .number()
    .int()
    .positive()
    .catch(1),  // 유효하지 않으면 1로 설정

  sort: z
    .enum(['newest', 'price'])
    .catch('newest'),  // 유효하지 않은 enum 값이면 기본값
})

// 또는 명시적 검증
const strictSearchSchema = z.object({
  page: z.number().int().positive(),  // 실패 시 에러
  sort: z.enum(['newest', 'price']),
}).catch({ page: 1, sort: 'newest' })
```

</error_handling>

---

<practical_example>

## 실전: 필터 + 정렬 + 페이지네이션

완전한 구현 예시.

### 스키마 정의

```tsx
// /src/routes/posts/-search-schema.ts
import { z } from 'zod'

export const postsSearchSchema = z.object({
  page: z.number().int().positive().catch(1),
  search: z.string().optional(),
  category: z.enum(['tech', 'lifestyle', 'business']).optional(),
  sort: z.enum(['newest', 'oldest', 'popular']).catch('newest'),
  tags: z.array(z.string()).catch([]),
})

export type PostsSearch = z.infer<typeof postsSearchSchema>
```

### 라우트 정의

```tsx
// /src/routes/posts/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { postsSearchSchema } from './-search-schema'

export const Route = createFileRoute('/posts')({
  validateSearch: postsSearchSchema,
  loaderDeps: ({ search }) => ({ search }),
  loader: async ({ deps: { search } }) => {
    const posts = await fetchPosts({
      page: search.page,
      query: search.search,
      category: search.category,
      sort: search.sort,
      tags: search.tags,
    })
    return posts
  },
  component: PostsPage,
})

const PostsPage = () => {
  const posts = Route.useLoaderData()
  const { page, search, category, sort } = Route.useSearch()
  const navigate = useNavigate()

  const updateSearch = (updates: Partial<PostsSearch>) => {
    navigate({
      to: '/posts',
      search: prev => ({ ...prev, ...updates, page: 1 }),
    })
  }

  return (
    <div className="space-y-6">
      {/* 검색 입력 */}
      <input
        type="text"
        value={search ?? ''}
        onChange={e => updateSearch({ search: e.target.value })}
        placeholder="Search posts..."
      />

      {/* 카테고리 필터 */}
      <select
        value={category ?? ''}
        onChange={e => updateSearch({ category: e.target.value as any })}
      >
        <option value="">All Categories</option>
        <option value="tech">Tech</option>
        <option value="lifestyle">Lifestyle</option>
        <option value="business">Business</option>
      </select>

      {/* 정렬 선택 */}
      <select
        value={sort}
        onChange={e => updateSearch({ sort: e.target.value as any })}
      >
        <option value="newest">Newest</option>
        <option value="oldest">Oldest</option>
        <option value="popular">Popular</option>
      </select>

      {/* 태그 필터 (여러 선택) */}
      <div>
        {['react', 'typescript', 'design'].map(tag => (
          <label key={tag}>
            <input
              type="checkbox"
              checked={tags.includes(tag)}
              onChange={e => {
                const newTags = e.target.checked
                  ? [...tags, tag]
                  : tags.filter(t => t !== tag)
                updateSearch({ tags: newTags })
              }}
            />
            {tag}
          </label>
        ))}
      </div>

      {/* 포스트 목록 */}
      <div>
        {posts.map(post => (
          <Link key={post.id} to={`/posts/${post.id}`}>
            <h3>{post.title}</h3>
          </Link>
        ))}
      </div>

      {/* 페이지네이션 */}
      <div className="flex gap-2">
        <button
          onClick={() => updateSearch({ page: page - 1 })}
          disabled={page <= 1}
        >
          Previous
        </button>
        <span>Page {page}</span>
        <button onClick={() => updateSearch({ page: page + 1 })}>
          Next
        </button>
      </div>
    </div>
  )
}
```

</practical_example>

---

<dos_donts>

## Do's & Don'ts

| Do | Don't |
|-------|---------|
| `validateSearch` 스키마 정의 | 검증 없이 search params 사용 |
| `Route.useSearch()` (타입 안전) | `useSearch()` + 수동 타입 지정 |
| `catch()` 또는 `.optional()` 사용 | 필수 필드만 넣기 (URL 없을 수 있음) |
| `loaderDeps`에 사용하는 값만 포함 | 모든 search 포함 (불필요한 재실행) |
| 함수로 이전 값 기반 업데이트 | 값을 하드코딩해서 다른 params 덮어쓰기 |
| `z.enum()` 또는 `z.picklist()` | 문자열 비교로 유효성 확인 |
| Zod adapter (`zodValidator`) + `fallback()` | raw Zod의 `catch()`로 타입 손실 |
| `retainSearchParams` / `stripSearchParams` 미들웨어 | search params 수동 전파 |
| Standard Schema 라이브러리 (Valibot, ArkType) | adapter 없는 복잡한 타입 조작 |

</dos_donts>
