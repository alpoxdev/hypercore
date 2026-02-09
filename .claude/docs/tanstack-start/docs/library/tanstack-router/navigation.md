# TanStack Router - Navigation

> TanStack Router v1.159.4

네비게이션 가이드. Link, useNavigate, Navigate 컴포넌트, router.navigate를 다룬다.

---

<navigation_concepts>

## 네비게이션 기본 개념

TanStack Router의 모든 네비게이션은 **상대적**이다. 항상 **origin**(from)에서 **destination**(to)으로 이동한다.

### 핵심 인터페이스

```typescript
// ToOptions: 모든 네비게이션 API의 기반
type ToOptions = {
  from?: string    // 출발 라우트 (없으면 root `/`로 간주)
  to: string       // 목적지 경로 (절대/상대 모두 가능)
  params: object | ((prev) => object)   // Path params
  search: object | ((prev) => object)   // Search params
  hash?: string | ((prev) => string)    // URL hash
  state?: object | ((prev) => object)   // History state (URL에 안 보임)
}

// NavigateOptions: ToOptions 확장
type NavigateOptions = ToOptions & {
  replace?: boolean           // history.replace 사용 여부
  resetScroll?: boolean       // 스크롤 상단 리셋 (기본 true)
  hashScrollIntoView?: boolean | ScrollIntoViewOptions  // hash 대상 스크롤
  viewTransition?: boolean | ViewTransitionOptions      // View Transition API
  ignoreBlocker?: boolean     // 네비게이션 블로커 무시
  reloadDocument?: boolean    // 전체 페이지 로드 (SPA 우회)
  href?: string               // 외부 URL 지정 (to 대신)
}

// LinkOptions: NavigateOptions 확장 (<a> 태그 전용)
type LinkOptions = NavigateOptions & {
  target?: HTMLAnchorElement['target']  // 새 탭 열기 등
  activeOptions?: ActiveOptions         // Active 조건 설정
  preload?: false | 'intent'            // 사전 로딩 전략
  preloadDelay?: number                 // 사전 로딩 지연 (ms)
  disabled?: boolean                    // href 없이 렌더링
}
```

### 4가지 네비게이션 API

| API | 용도 | 특징 |
|-----|------|------|
| `<Link>` | 선언적 네비게이션 | `<a>` 태그 생성, cmd/ctrl+click 지원 |
| `useNavigate()` | 프로그래매틱 네비게이션 | 사이드이펙트 후 네비게이션 |
| `<Navigate>` | 즉시 리다이렉트 | 컴포넌트 마운트 시 즉시 이동 |
| `router.navigate()` | 어디서든 네비게이션 | 라우터 인스턴스가 있는 곳이면 가능 |

</navigation_concepts>

---

<link_component>

## Link: 선언적 네비게이션

기본 사용법부터 고급 옵션까지 다룬다.

### 기본 예시

```tsx
// 정적 라우트
<Link to="/about">About</Link>

// 동적 파라미터 (타입 안전)
<Link to="/posts/$postId" params={{ postId: '123' }}>
  Post 123
</Link>

// Search params (객체)
<Link to="/products" search={{ page: 1, sort: 'newest' }}>
  Products
</Link>

// Search params (함수: 이전 값 기반)
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>
  Next Page
</Link>

// Hash + Replace
<Link to="/docs" hash="intro" replace>
  Docs
</Link>

// History state (URL에 보이지 않는 데이터 전달)
<Link to="/checkout" state={{ fromCart: true }}>
  Checkout
</Link>
```

### 상대 경로 네비게이션

`from`을 지정하면 상대 경로 사용 가능. 없으면 절대 경로로 간주.

```tsx
// "." = 현재 라우트 리로드
<Link to=".">현재 라우트 리로드</Link>

// ".." = 부모 라우트로 이동
<Link to="..">뒤로 가기</Link>

// from 지정으로 상대 경로 사용
<Link from="/posts/$postId" to="../categories">
  Categories
</Link>

// route.fullPath 참조 (리팩토링 안전)
import { Route as postIdRoute } from './routes/posts.$postId'
<Link from={postIdRoute.fullPath} to="../categories">
  Categories
</Link>
```

### 선택적 파라미터 (Optional Parameters)

`{-$paramName}` 구문으로 선택적 파라미터 사용.

```tsx
// 선택적 파라미터 설정
<Link to="/posts/{-$category}" params={{ category: 'tech' }}>
  Tech Posts
</Link>

// 선택적 파라미터 제거 (undefined로 명시)
<Link to="/posts/{-$category}" params={{ category: undefined }}>
  All Posts
</Link>

// 함수로 조건부 설정
<Link
  to="/posts/{-$category}"
  params={prev => ({
    ...prev,
    category: someCondition ? 'tech' : undefined,
  })}
>
  Conditional Category
</Link>

// 필수 + 선택 혼합
<Link
  to="/users/$id/{-$tab}"
  params={{ id: '123', tab: 'settings' }}
>
  User Settings
</Link>
```

### Active 상태 스타일링

현재 경로와 Link가 일치할 때 스타일 적용.

```tsx
// 기본 활성화 체크
<Link
  to="/about"
  activeProps={{ className: 'text-blue-500 font-bold' }}
  inactiveProps={{ className: 'text-gray-500' }}
>
  About
</Link>

// Exact match (자식 라우트 제외)
<Link to="/" activeOptions={{ exact: true }}>
  Home
</Link>

// Search params 포함 매칭
<Link
  to="/posts"
  search={{ page: 1 }}
  activeOptions={{ includeSearch: true }}
>
  Posts Page 1
</Link>

// Hash 포함 매칭
<Link
  to="/docs"
  hash="section-1"
  activeOptions={{ includeHash: true }}
>
  Section 1
</Link>

// data-status 속성 활용 (CSS 스타일링)
// 활성 시 data-status="active", 비활성 시 undefined
<Link to="/about">About</Link>

// isActive를 children 함수로 전달
<Link to="/blog/post">
  {({ isActive }) => (
    <>
      <span>My Blog Post</span>
      <Icon className={isActive ? 'active' : 'inactive'} />
    </>
  )}
</Link>
```

### ActiveOptions 인터페이스

```typescript
interface ActiveOptions {
  exact?: boolean             // pathname 정확 매칭 (기본 false)
  includeHash?: boolean       // hash 포함 매칭 (기본 false)
  includeSearch?: boolean     // search 포함 매칭 (기본 true)
  explicitUndefined?: boolean // undefined 값도 매칭 조건에 포함 (기본 false)
}
```

### Preloading 전략

사전 로딩으로 네비게이션 성능 향상.

```tsx
// intent: 마우스 호버 또는 터치스타트 시 로드 (권장)
<Link to="/posts" preload="intent">
  Posts (빠른 로드)
</Link>

// 지연 시간 커스터마이즈 (기본 50ms)
<Link to="/blog" preload="intent" preloadDelay={100}>
  Blog
</Link>

// 라우터 수준에서 기본 프리로드 설정
const router = createRouter({
  routeTree,
  defaultPreload: 'intent',       // 모든 Link에 intent 적용
  defaultPreloadDelay: 100,        // 기본 지연 100ms
})
```

### 수동 프리로딩 (router.preloadRoute)

```tsx
const Component = () => {
  const router = useRouter()

  useEffect(() => {
    // 특정 라우트를 수동으로 프리로드
    router.preloadRoute({
      to: '/posts/$postId',
      params: { postId: '1' },
    })
  }, [router])

  return <div />
}
```

### Link Props 참조표

| Props | 타입 | 기본값 | 설명 |
|-------|------|--------|------|
| `to` | string | - | 목적지 경로 (필수) |
| `from` | string | - | 출발 라우트 (상대 경로 사용 시) |
| `params` | object \| function | - | Path 파라미터 (타입 안전) |
| `search` | object \| function | - | Search params (함수로 이전 값 접근) |
| `hash` | string \| function | - | URL hash |
| `state` | object \| function | - | History state (URL에 안 보임) |
| `replace` | boolean | false | history.replace 사용 여부 |
| `resetScroll` | boolean | true | 스크롤을 상단으로 리셋 |
| `preload` | false \| 'intent' | - | 사전 로딩 전략 |
| `preloadDelay` | number | 50 | 사전 로딩 지연 (ms) |
| `activeProps` | object \| function | - | Active 상태 시 적용할 props |
| `inactiveProps` | object \| function | - | Inactive 상태 시 적용할 props |
| `activeOptions` | ActiveOptions | - | Active 조건 설정 |
| `disabled` | boolean | false | href 없이 렌더링 |
| `target` | string | - | 새 탭 등 표준 anchor target |
| `viewTransition` | boolean \| ViewTransitionOptions | - | View Transition API |
| `hashScrollIntoView` | boolean \| ScrollIntoViewOptions | - | hash 위치로 스크롤 |

</link_component>

---

<use_navigate>

## useNavigate: 프로그래매틱 네비게이션

이벤트 핸들러나 조건부 로직에서 네비게이션 수행. Link를 쓸 수 없는 사이드이펙트 상황에 사용.

### 기본 사용법

```tsx
const Component = () => {
  const navigate = useNavigate()

  // 정적 네비게이션
  const handleNavigate = () => navigate({ to: '/about' })

  // 동적 파라미터
  const goToPost = (id: string) => {
    navigate({ to: '/posts/$postId', params: { postId: id } })
  }

  // Search params 업데이트 (함수)
  const nextPage = () => {
    navigate({
      to: '/products',
      search: prev => ({ ...prev, page: (prev.page ?? 1) + 1 }),
    })
  }

  // History replace
  const redirect = () => {
    navigate({ to: '/login', replace: true })
  }

  // 상대 경로
  const goUp = () => navigate({ to: '..' })

  return (
    <div>
      <button onClick={handleNavigate}>Go to About</button>
      <button onClick={() => goToPost('123')}>View Post</button>
      <button onClick={nextPage}>Next</button>
    </div>
  )
}
```

### startTransition과 함께 사용

비동기 작업 완료 후 네비게이션. 폼 제출, API 호출 등에 활용.

```tsx
const SubmitButton = () => {
  const navigate = useNavigate()
  const [isPending, startTransition] = useTransition()

  const handleSubmit = async (formData: FormData) => {
    // 비동기 작업 (폼 제출, 데이터 저장 등)
    const result = await submitForm(formData)

    if (result.success) {
      // startTransition으로 감싸서 네비게이션
      startTransition(() => {
        navigate({ to: '/success', search: { id: result.id } })
      })
    }
  }

  return (
    <button onClick={() => handleSubmit(new FormData())} disabled={isPending}>
      {isPending ? 'Saving...' : 'Submit'}
    </button>
  )
}
```

### 타입 안전 네비게이션 (from 파라미터)

현재 라우트를 명시해 타입 체크 활성화.

```tsx
// 타입 안전: `/posts/$postId`에서만 호출 가능
const navigate = useNavigate({ from: '/posts/$postId' })

const goToRelated = (relatedId: string) => {
  navigate({
    to: '/posts/$postId',
    params: { postId: relatedId },  // 타입 체크됨
  })
}

// Route.useNavigate()도 동일 (from 자동 지정)
const navigate = Route.useNavigate()
```

### navigate() 옵션 참조표

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `to` | string | - | 목적지 경로 (필수) |
| `from` | string | - | 출발 라우트 |
| `params` | object \| function | - | Path 파라미터 |
| `search` | object \| function | - | Search params |
| `hash` | string \| function | - | URL hash |
| `state` | object \| function | - | History state |
| `replace` | boolean | false | history.replace 사용 여부 |
| `resetScroll` | boolean | true | 스크롤을 상단으로 리셋 |
| `viewTransition` | boolean \| ViewTransitionOptions | - | View Transition API |
| `ignoreBlocker` | boolean | false | 네비게이션 블로커 무시 |

</use_navigate>

---

<navigate_component>

## Navigate 컴포넌트: 즉시 리다이렉트

컴포넌트 마운트 시 즉시 네비게이션. 클라이언트 전용 리다이렉트에 사용.

```tsx
import { Navigate } from '@tanstack/react-router'

// useNavigate + useEffect 대신 사용
const Component = () => {
  return <Navigate to="/posts/$postId" params={{ postId: 'my-first-post' }} />
}

// 조건부 리다이렉트
const ProtectedPage = () => {
  const { isAuthenticated } = useAuth()

  if (!isAuthenticated) {
    return <Navigate to="/login" />
  }

  return <div>Protected Content</div>
}
```

> 주의: Navigate 컴포넌트는 클라이언트 전용. 서버 사이드 리다이렉트가 필요하면 beforeLoad에서 `redirect()` throw 사용.

</navigate_component>

---

<match_route>

## useMatchRoute / MatchRoute: 라우트 매칭 확인

현재 경로가 특정 라우트와 매칭되는지 확인. 낙관적 UI에 유용.

```tsx
import { MatchRoute, useMatchRoute } from '@tanstack/react-router'

// 컴포넌트 방식: pending 상태 표시
const NavItem = () => (
  <Link to="/users">
    Users
    <MatchRoute to="/users" pending>
      <Spinner />
    </MatchRoute>
  </Link>
)

// 함수 children 방식
const NavItem2 = () => (
  <Link to="/users">
    Users
    <MatchRoute to="/users" pending>
      {(match) => <Spinner show={match} />}
    </MatchRoute>
  </Link>
)

// 훅 방식: 프로그래매틱 체크
const Component = () => {
  const matchRoute = useMatchRoute()

  useEffect(() => {
    if (matchRoute({ to: '/users', pending: true })) {
      console.info('/users 라우트가 매칭되고 전환 중')
    }
  })

  return <div />
}
```

</match_route>

---

<programmatic_patterns>

## 실전 패턴

### 조건부 네비게이션

```tsx
const Form = () => {
  const navigate = useNavigate()
  const [errors, setErrors] = useState<Record<string, string>>({})

  const handleSubmit = async (data: FormData) => {
    const result = await validate(data)

    if (!result.success) {
      setErrors(result.errors)
      return  // 에러 있으면 네비게이션 안 함
    }

    navigate({ to: '/confirmation', search: { orderId: result.id } })
  }

  return <form onSubmit={handleSubmit}>{/* ... */}</form>
}
```

### 뒤로 가기 (검증 필수)

```tsx
const BackButton = () => {
  const navigate = useNavigate()

  return (
    <button onClick={() => navigate({ to: '..' })}>
      Back
    </button>
  )
}
```

### 폼 제출 후 상세 페이지로 이동

```tsx
const CreatePost = () => {
  const navigate = useNavigate()
  const createMutation = useMutation({
    mutationFn: createPost,
    onSuccess: (newPost) => {
      // 생성된 post ID로 상세 페이지로 이동
      navigate({
        to: '/posts/$postId',
        params: { postId: newPost.id },
      })
    },
  })

  return (
    <button onClick={() => createMutation.mutate({ title: 'New Post' })}>
      Create
    </button>
  )
}
```

### Search params로 필터 상태 유지

```tsx
const FilterableList = () => {
  const navigate = useNavigate()
  const { category, sort } = Route.useSearch()

  const handleFilter = (newCategory: string) => {
    navigate({
      to: '/items',
      search: prev => ({
        ...prev,
        category: newCategory,
        page: 1,  // 필터 변경 시 페이지 1로 리셋
      }),
    })
  }

  return (
    <select value={category} onChange={e => handleFilter(e.target.value)}>
      <option value="all">All</option>
      <option value="electronics">Electronics</option>
    </select>
  )
}
```

### 선택적 파라미터로 필터 네비게이션

```tsx
const FilterNav = () => {
  const navigate = useNavigate()

  // 필터 초기화
  const clearFilters = () => {
    navigate({
      to: '/posts/{-$category}/{-$tag}',
      params: { category: undefined, tag: undefined },
    })
  }

  // 특정 카테고리 설정
  const setCategory = (category: string) => {
    navigate({
      to: '/posts/{-$category}/{-$tag}',
      params: prev => ({ ...prev, category }),
    })
  }

  return (
    <div>
      <button onClick={() => setCategory('tech')}>Tech</button>
      <button onClick={clearFilters}>Clear</button>
    </div>
  )
}
```

</programmatic_patterns>

---

<type_safe_routing>

## 타입 안전 라우팅

TanStack Router는 경로와 파라미터를 타입 체크한다.

### Link 타입 체크

```tsx
// 올바른 예시
<Link to="/posts/$postId" params={{ postId: '123' }}>
  // 타입 체크: postId 필수
</Link>

<Link to="/about">
  // params 불필요
</Link>

// route.to로 타입 안전 참조
import { Route as aboutRoute } from './routes/about'
<Link to={aboutRoute.to}>About</Link>

// 오류 예시
<Link to="/posts/$postId">
  // TS Error: params 필수
</Link>

<Link to="/posts" params={{ postId: '123' }}>
  // TS Error: /posts는 파라미터 없음
</Link>
```

### useNavigate 타입 체크 (from 파라미터)

```tsx
// `/posts/$postId` 라우트 내부
export const Route = createFileRoute('/posts/$postId')({
  component: PostDetail,
})

const PostDetail = () => {
  // from 명시: 이 라우트 내에서만 호출 가능
  const navigate = useNavigate({ from: '/posts/$postId' })

  const goRelated = (id: string) => {
    navigate({
      to: '/posts/$postId',
      params: { postId: id },  // 타입 체크됨
    })
  }
}
```

</type_safe_routing>

---

<comparison>

## Link vs useNavigate vs Navigate vs router.navigate

| 상황 | 추천 | 이유 |
|------|------|------|
| HTML 선언 | `<Link>` | 자동 타입 체크, 접근성 (href), cmd/ctrl+click |
| 이벤트 핸들러 | `useNavigate()` | 조건부 로직 가능 |
| 호버 preload | `<Link preload="intent">` | 자동으로 효율적 |
| 비동기 후 네비게이션 | `useNavigate()` + startTransition | 상태 동기화 |
| 마운트 시 즉시 리다이렉트 | `<Navigate>` | useEffect 불필요 |
| 프레임워크 외부 | `router.navigate()` | 어디서든 사용 가능 |
| 동적 파라미터 | 모두 가능 | 문맥에 따라 |
| 낙관적 pending UI | `<MatchRoute pending>` | 전환 중 스피너 |

</comparison>
