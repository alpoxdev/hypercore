# TanStack Start React 베스트 프랙티스

**Version 3.0.0**
TanStack Start v1 + TanStack Router + React 19 최적화 가이드
February 2026

> **참고:**
> 이 문서는 주로 에이전트와 LLM이 React 및 TanStack Start 코드베이스를 유지보수, 생성, 리팩토링할 때 따르기 위한 것입니다. 사람도 유용하게 사용할 수 있지만, AI 지원 워크플로의 자동화 및 일관성을 위해 최적화되어 있습니다.

---

## 요약

AI 에이전트와 LLM을 위한 React 19 및 TanStack Start v1 애플리케이션 종합 성능 최적화 가이드. 8개 카테고리에 걸쳐 55개 규칙을 포함하며, 영향도별로 우선순위를 매겼습니다 (critical: waterfall 제거, 번들 크기 감소 → incremental: JavaScript 성능). TanStack Router 라우팅 패턴(Link, useNavigate, useSearch, useParams, beforeLoad, Outlet, pendingComponent, 프리로딩, 파일 컨벤션), React Compiler 자동 메모이제이션, use() hook, useOptimistic, createMiddleware, inputValidator, 데이터 스트리밍 등 최신 패턴 반영. 각 규칙은 자동 리팩토링 및 코드 생성을 위한 상세한 설명, 올바른 구현 대 잘못된 구현을 비교하는 실제 예시, 구체적인 영향 지표를 포함합니다.

---

<instructions>

## 문서 사용 지침

@rules/async-defer-await.md
@rules/async-parallel.md
@rules/async-dependencies.md
@rules/async-loader.md
@rules/bundle-barrel-imports.md
@rules/bundle-lazy-routes.md
@rules/bundle-conditional.md
@rules/bundle-defer-third-party.md
@rules/bundle-preload.md
@rules/server-cache-lru.md
@rules/server-serialization.md
@rules/server-parallel-fetching.md
@rules/server-deferred-data.md
@rules/server-middleware.md
@rules/server-validator.md
@rules/server-streaming.md
@rules/server-error-boundaries.md
@rules/client-tanstack-query.md
@rules/client-suspense-query.md
@rules/client-optimistic-updates.md
@rules/client-use-hook.md
@rules/client-event-listeners.md
@rules/routing-file-conventions.md
@rules/routing-link-navigation.md
@rules/routing-search-params.md
@rules/routing-path-params.md
@rules/routing-beforeload-auth.md
@rules/routing-nested-layouts.md
@rules/routing-router-context.md
@rules/routing-preload-strategy.md
@rules/routing-pending-component.md
@rules/rerender-defer-reads.md
@rules/rerender-memo.md
@rules/rerender-react-compiler.md
@rules/rerender-dependencies.md
@rules/rerender-derived-state.md
@rules/rerender-functional-setstate.md
@rules/rerender-lazy-state-init.md
@rules/rerender-transitions.md
@rules/rendering-animate-svg-wrapper.md
@rules/rendering-content-visibility.md
@rules/rendering-hoist-jsx.md
@rules/rendering-svg-precision.md
@rules/rendering-conditional-render.md
@rules/js-batch-dom-css.md
@rules/js-index-maps.md
@rules/js-cache-property-access.md
@rules/js-cache-function-results.md
@rules/js-cache-storage.md
@rules/js-combine-iterations.md
@rules/js-length-check-first.md
@rules/js-early-exit.md
@rules/js-hoist-regexp.md
@rules/js-min-max-loop.md
@rules/js-set-map-lookups.md
@rules/js-tosorted-immutable.md

</instructions>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 설명 |
|---------|---------|--------|------|
| 1 | Waterfall 제거 | **CRITICAL** | 순차 await를 병렬로 전환. 가장 큰 성능 향상 제공 |
| 2 | 번들 크기 최적화 | **CRITICAL** | TTI와 LCP 개선. 초기 로딩 속도 향상 |
| 3 | TanStack Router 라우팅 | **HIGH** | 타입 안전 네비게이션, 인증 가드, 레이아웃, 프리로딩 |
| 4 | 서버 사이드 성능 | HIGH | 서버 사이드 waterfall 제거, 응답 시간 단축 |
| 5 | 클라이언트 데이터 페칭 | MEDIUM-HIGH | 자동 중복 제거, 효율적 데이터 페칭 |
| 6 | Re-render 최적화 | MEDIUM | 불필요한 re-render 최소화, UI 반응성 향상 |
| 7 | 렌더링 성능 | MEDIUM | 브라우저 렌더링 작업 최적화 |
| 8 | JavaScript 성능 | LOW-MEDIUM | Hot path 마이크로 최적화 |

</categories>

---

<critical_patterns>

## 1. Waterfall 제거 (CRITICAL)

Waterfall은 가장 큰 성능 저해 요소입니다. 순차 await는 전체 네트워크 지연을 추가합니다.

### 병렬 실행

```typescript
// ❌ 순차 실행 (3번 왕복)
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()

// ✅ 병렬 실행 (1번 왕복)
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

### createServerFn + Loader에서 병렬 페칭

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

// Server Functions 정의
const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

const getAuthor = createServerFn().handler(async (authorId: string) => {
  return await db.author.findUnique({ where: { id: authorId } })
})

const getComments = createServerFn().handler(async (postId: string) => {
  return await db.comment.findMany({ where: { postId } })
})

// ❌ 순차 로딩
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    const author = await getAuthor(post.authorId)
    const comments = await getComments(params.postId)
    return { post, author, comments }
  }
})

// ✅ 병렬 로딩 (독립 데이터)
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const [post, comments] = await Promise.all([
      getPost(params.postId),
      getComments(params.postId)
    ])
    return { post, comments }
  }
})
```

### 의존성 기반 병렬화

```typescript
import { all } from 'better-all'

// ✅ better-all로 최대 병렬화
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const { post, author, comments } = await all({
      async post() {
        return fetchPost(params.postId)
      },
      async author() {
        const p = await this.$.post
        return fetchAuthor(p.authorId)
      },
      async comments() {
        return fetchComments(params.postId)
      }
    })
    return { post, author, comments }
  }
})
```

### Deferred Data로 비차단 로딩 (자동 처리)

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

// 빠른 Server Function
const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

// 느린 Server Function
const getComments = createServerFn().handler(async (postId: string) => {
  await new Promise(r => setTimeout(r, 3000)) // 느린 쿼리
  return await db.comment.findMany({ where: { postId } })
})

// ✅ 중요 데이터는 await, 비중요 데이터는 Promise 반환
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // 중요: post는 즉시 로드 (await)
    const post = await getPost(params.postId)

    // 비중요: comments는 Promise 그대로 반환 (자동 deferred)
    const deferredComments = getComments(params.postId)

    return {
      post,
      deferredComments
    }
  }
})

function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()

  return (
    <div>
      {/* post는 즉시 렌더링 */}
      <PostContent post={post} />

      {/* comments는 스트리밍 */}
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

**중요:** TanStack Start에서는 `defer()` 함수를 명시적으로 호출할 필요가 없습니다. Promise를 그대로 반환하면 자동으로 deferred 처리됩니다.

</critical_patterns>

---

<bundle_optimization>

## 2. 번들 크기 최적화 (CRITICAL)

### Barrel Import 회피

```tsx
// ❌ 전체 라이브러리 import (1583개 모듈, ~2.8초)
import { Check, X, Menu } from 'lucide-react'

// ✅ 직접 import (3개 모듈만)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
```

영향 받는 라이브러리: `lucide-react`, `@mui/material`, `@mui/icons-material`, `@tabler/icons-react`, `react-icons`, `@headlessui/react`, `@radix-ui/react-*`, `lodash`, `ramda`, `date-fns`, `rxjs`, `react-use`

### 라우트 기반 코드 스플리팅

```typescript
import { lazy } from 'react'
import { createFileRoute } from '@tanstack/react-router'

// ❌ 모든 컴포넌트가 메인 번들에 포함
import { HeavyEditor } from './components/HeavyEditor'
import { ComplexChart } from './components/ComplexChart'

export const Route = createFileRoute('/dashboard')({
  component: DashboardPage
})

function DashboardPage() {
  return (
    <div>
      <HeavyEditor />
      <ComplexChart />
    </div>
  )
}

// ✅ 무거운 컴포넌트는 lazy load
const HeavyEditor = lazy(() => import('./components/HeavyEditor'))
const ComplexChart = lazy(() => import('./components/ComplexChart'))

export const Route = createFileRoute('/dashboard')({
  component: DashboardPage
})

function DashboardPage() {
  return (
    <div>
      <Suspense fallback={<EditorSkeleton />}>
        <HeavyEditor />
      </Suspense>
      <Suspense fallback={<ChartSkeleton />}>
        <ComplexChart />
      </Suspense>
    </div>
  )
}
```

### 조건부 모듈 로딩

```tsx
// ❌ 항상 로드
import { AnimationFrames } from './animation-frames'

function AnimationPlayer({ enabled }: { enabled: boolean }) {
  if (!enabled) return null
  return <Canvas frames={AnimationFrames} />
}

// ✅ 활성화 시에만 로드
function AnimationPlayer({ enabled }: { enabled: boolean }) {
  const [frames, setFrames] = useState<Frame[] | null>(null)

  useEffect(() => {
    if (enabled && !frames) {
      import('./animation-frames')
        .then(mod => setFrames(mod.frames))
        .catch(() => setEnabled(false))
    }
  }, [enabled, frames])

  if (!frames) return <Skeleton />
  return <Canvas frames={frames} />
}
```

</bundle_optimization>

---

<server_performance>

## 3. 서버 사이드 성능 (HIGH)

### LRU 캐시 - 요청 간 캐싱

```typescript
import { LRUCache } from 'lru-cache'

const cache = new LRUCache<string, any>({
  max: 1000,
  ttl: 5 * 60 * 1000  // 5분
})

export async function getUser(id: string) {
  const cached = cache.get(id)
  if (cached) return cached

  const user = await db.user.findUnique({ where: { id } })
  cache.set(id, user)
  return user
}

// 요청 1: DB 쿼리, 결과 캐싱
// 요청 2: 캐시 히트, DB 쿼리 없음
```

### 직렬화 최소화

```typescript
// ❌ 50개 필드 모두 직렬화
export const Route = createFileRoute('/profile')({
  loader: async () => {
    const user = await fetchUser()  // 50개 필드
    return { user }
  }
})

function ProfilePage() {
  const { user } = Route.useLoaderData()
  return <div>{user.name}</div>  // 1개 필드만 사용
}

// ✅ 필요한 필드만 직렬화
export const Route = createFileRoute('/profile')({
  loader: async () => {
    const user = await fetchUser()
    return {
      userName: user.name,
      userEmail: user.email
    }
  }
})

function ProfilePage() {
  const { userName, userEmail } = Route.useLoaderData()
  return (
    <div>
      <div>{userName}</div>
      <div>{userEmail}</div>
    </div>
  )
}
```

### Loader에서 병렬 페칭 + createServerFn

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

// Server Functions 정의
const getUser = createServerFn().handler(async () => {
  return await db.user.findMany()
})

const getStats = createServerFn().handler(async () => {
  return await db.stats.findMany()
})

const getNotifications = createServerFn().handler(async () => {
  return await db.notification.findMany()
})

// ❌ 순차 페칭
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getUser()
    const stats = await getStats()
    const notifications = await getNotifications()
    return { user, stats, notifications }
  }
})

// ✅ 병렬 페칭
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const [user, stats, notifications] = await Promise.all([
      getUser(),
      getStats(),
      getNotifications()
    ])
    return { user, stats, notifications }
  }
})
```

**중요:** TanStack Start의 loader는 isomorphic입니다. 서버와 클라이언트 둘 다에서 실행될 수 있으므로, 서버 전용 코드는 `createServerFn()`으로 분리하세요.

</server_performance>

---

<client_data_fetching>

## 4. 클라이언트 데이터 페칭 (MEDIUM-HIGH)

### TanStack Query로 자동 캐싱

```tsx
import { useQuery } from '@tanstack/react-query'

// ❌ 중복 제거 없음, 각 인스턴스가 fetch
function UserList() {
  const [users, setUsers] = useState([])
  useEffect(() => {
    fetch('/api/users')
      .then(r => r.json())
      .then(setUsers)
  }, [])
}

// ✅ 여러 인스턴스가 하나의 요청 공유
function UserList() {
  const { data: users } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers
  })
}
```

### TanStack Query Mutations

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'

function UpdateButton() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: updateUser,
    onSuccess: () => {
      // 캐시 무효화로 자동 재페칭
      queryClient.invalidateQueries({ queryKey: ['users'] })
    }
  })

  return (
    <button onClick={() => mutation.mutate()}>
      Update
    </button>
  )
}
```

</client_data_fetching>

---

<rerender_optimization>

## 5. Re-render 최적화 (MEDIUM)

### 함수형 setState

```tsx
// ❌ items가 의존성, 매번 재생성
function TodoList() {
  const [items, setItems] = useState(initialItems)

  const addItems = useCallback((newItems: Item[]) => {
    setItems([...items, ...newItems])
  }, [items])  // items 변경마다 재생성
}

// ✅ 안정적 콜백, 재생성 없음
function TodoList() {
  const [items, setItems] = useState(initialItems)

  const addItems = useCallback((newItems: Item[]) => {
    setItems(curr => [...curr, ...newItems])
  }, [])  // 의존성 없음, 항상 최신 상태 사용
}
```

### Lazy 상태 초기화

```tsx
// ❌ 매 렌더마다 실행
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(buildSearchIndex(items))
}

// ✅ 초기 렌더 시에만 실행
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(() => buildSearchIndex(items))
}
```

### 파생 상태 구독

```tsx
// ❌ 픽셀 변경마다 re-render
function Sidebar() {
  const width = useWindowWidth()  // 연속 업데이트
  const isMobile = width < 768
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}

// ✅ boolean 변경 시에만 re-render
function Sidebar() {
  const isMobile = useMediaQuery('(max-width: 767px)')
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}
```

</rerender_optimization>

---

<rendering_performance>

## 6. 렌더링 성능 (MEDIUM)

### SVG 래퍼 애니메이션

```tsx
// ❌ SVG 직접 애니메이션 - 하드웨어 가속 없음
function LoadingSpinner() {
  return (
    <svg className="animate-spin" width="24" height="24">
      <circle cx="12" cy="12" r="10" />
    </svg>
  )
}

// ✅ 래퍼 div 애니메이션 - 하드웨어 가속
function LoadingSpinner() {
  return (
    <div className="animate-spin">
      <svg width="24" height="24">
        <circle cx="12" cy="12" r="10" />
      </svg>
    </div>
  )
}
```

### content-visibility

```css
.message-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 80px;
}
```

```tsx
function MessageList({ messages }: { messages: Message[] }) {
  return (
    <div className="overflow-y-auto h-screen">
      {messages.map(msg => (
        <div key={msg.id} className="message-item">
          <Avatar user={msg.author} />
          <div>{msg.content}</div>
        </div>
      ))}
    </div>
  )
}
```

1000개 메시지 기준, 브라우저가 ~990개 오프스크린 항목의 레이아웃/페인트 스킵 (초기 렌더 10배 빠름)

### JSX Hoisting

```tsx
// ❌ 매 렌더마다 재생성
function Container() {
  return (
    <div>
      {loading && <div className="animate-pulse h-20 bg-gray-200" />}
    </div>
  )
}

// ✅ 한 번만 생성
const loadingSkeleton = (
  <div className="animate-pulse h-20 bg-gray-200" />
)

function Container() {
  return (
    <div>
      {loading && loadingSkeleton}
    </div>
  )
}
```

</rendering_performance>

---

<javascript_performance>

## 7. JavaScript 성능 (LOW-MEDIUM)

### 반복 조회용 Map

```typescript
// ❌ O(n) per lookup
function processOrders(orders: Order[], users: User[]) {
  return orders.map(order => ({
    ...order,
    user: users.find(u => u.id === order.userId)
  }))
}

// ✅ O(1) per lookup
function processOrders(orders: Order[], users: User[]) {
  const userById = new Map(users.map(u => [u.id, u]))
  return orders.map(order => ({
    ...order,
    user: userById.get(order.userId)
  }))
}
```

1000 orders × 1000 users: 1M ops → 2K ops

### 배열 비교 시 길이 체크

```typescript
// ❌ 항상 비싼 비교 실행
function hasChanges(current: string[], original: string[]) {
  return current.sort().join() !== original.sort().join()
}

// ✅ O(1) 길이 체크 먼저
function hasChanges(current: string[], original: string[]) {
  if (current.length !== original.length) return true

  const currentSorted = current.toSorted()
  const originalSorted = original.toSorted()
  for (let i = 0; i < currentSorted.length; i++) {
    if (currentSorted[i] !== originalSorted[i]) return true
  }
  return false
}
```

### toSorted()로 불변성 유지

```typescript
// ❌ 원본 배열 변경
function UserList({ users }: { users: User[] }) {
  const sorted = useMemo(
    () => users.sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
}

// ✅ 새 배열 생성
function UserList({ users }: { users: User[] }) {
  const sorted = useMemo(
    () => users.toSorted((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
}
```

</javascript_performance>

---

<references>

## 참고 자료

### TanStack 공식 문서
1. [React](https://react.dev)
2. [TanStack Start Overview](https://tanstack.com/start/latest/docs/framework/react/overview)
3. [TanStack Start Quick Start](https://tanstack.com/start/latest/docs/framework/react/quick-start)
4. [TanStack Router](https://tanstack.com/router)
5. [TanStack Router Deferred Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/deferred-data-loading)
6. [TanStack Query](https://tanstack.com/query/latest/docs/framework/react/overview)
7. [Server Functions Guide](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
8. [Middleware Guide](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)
9. [Streaming Data Guide](https://tanstack.com/start/latest/docs/framework/react/guide/streaming-data-from-server-functions)

### TanStack Router
10. [Navigation Guide](https://tanstack.com/router/latest/docs/framework/react/guide/navigation)
11. [Link Options](https://tanstack.com/router/latest/docs/framework/react/guide/link-options)
12. [Search Params](https://tanstack.com/router/latest/docs/framework/react/guide/search-params)
13. [Path Params](https://tanstack.com/router/latest/docs/framework/react/guide/path-params)
14. [Authenticated Routes](https://tanstack.com/router/latest/docs/framework/react/guide/authenticated-routes)
15. [Outlets](https://tanstack.com/router/latest/docs/framework/react/guide/outlets)
16. [Route Trees](https://tanstack.com/router/latest/docs/framework/react/guide/route-trees)
17. [File-Based Routing](https://tanstack.com/router/latest/docs/framework/react/routing/file-based-routing)
18. [Router Context](https://tanstack.com/router/latest/docs/framework/react/guide/router-context)
19. [Preloading](https://tanstack.com/router/latest/docs/framework/react/guide/preloading)
20. [Data Loading](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)

### React 19
21. [React 19 Blog](https://react.dev/blog/2024/12/05/react-19)
22. [React use() API](https://react.dev/reference/react/use)
23. [React useOptimistic](https://react.dev/reference/react/useOptimistic)
24. [React Compiler](https://react.dev/learn/react-compiler)

### 외부 자료
25. [better-all](https://github.com/shuding/better-all)
26. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
27. [Using Server Functions and TanStack Query](https://www.brenelz.com/posts/using-server-functions-and-tanstack-query/)

</references>
