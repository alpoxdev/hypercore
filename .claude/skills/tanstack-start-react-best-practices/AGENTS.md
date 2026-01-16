# TanStack Start React Best Practices

**Version 1.0.0**
TanStack Start Optimization Guide
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring React and TanStack Start codebases. Humans
> may also find it useful, but guidance here is optimized for automation
> and consistency by AI-assisted workflows.

---

<communication>

## User Communication Protocol

**CRITICAL: Always communicate with the user in Korean (한국어).**

This applies to:
- Questions and clarifications
- Progress updates and summaries
- Explaining decisions and trade-offs
- Reporting errors or blockers

Internal processing and code comments remain in English. Only user-facing messages must be in Korean.

</communication>

---

## Abstract

Comprehensive performance optimization guide for React and TanStack Start applications, designed for AI agents and LLMs. Contains 38 rules across 7 categories, prioritized by impact from critical (eliminating waterfalls, reducing bundle size) to incremental (JavaScript performance). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

<instructions>

## Document Usage Instructions

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
@rules/client-tanstack-query.md
@rules/client-event-listeners.md
@rules/rerender-defer-reads.md
@rules/rerender-memo.md
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

## Categories by Priority

| Priority | Category | Impact | Description |
|----------|----------|--------|-------------|
| 1 | Eliminating Waterfalls | **CRITICAL** | Convert sequential awaits to parallel. Biggest gains |
| 2 | Bundle Size Optimization | **CRITICAL** | Improve TTI and LCP. Faster initial loads |
| 3 | Server-Side Performance | HIGH | Eliminate server-side waterfalls, reduce response times |
| 4 | Client-Side Data Fetching | MEDIUM-HIGH | Automatic deduplication, efficient data fetching |
| 5 | Re-render Optimization | MEDIUM | Minimize unnecessary re-renders, improve UI responsiveness |
| 6 | Rendering Performance | MEDIUM | Optimize browser rendering work |
| 7 | JavaScript Performance | LOW-MEDIUM | Hot path micro-optimizations |

</categories>

---

<critical_patterns>

## 1. Eliminating Waterfalls (CRITICAL)

Waterfalls are the #1 performance killer. Each sequential await adds full network latency.

### Parallel Execution

```typescript
// ❌ Sequential execution (3 round trips)
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()

// ✅ Parallel execution (1 round trip)
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

### createServerFn + Loader Parallel Fetching

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

// Define Server Functions
const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

const getAuthor = createServerFn().handler(async (authorId: string) => {
  return await db.author.findUnique({ where: { id: authorId } })
})

const getComments = createServerFn().handler(async (postId: string) => {
  return await db.comment.findMany({ where: { postId } })
})

// ❌ Sequential loading
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    const author = await getAuthor(post.authorId)
    const comments = await getComments(params.postId)
    return { post, author, comments }
  }
})

// ✅ Parallel loading (independent data)
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

### Dependency-Based Parallelization

```typescript
import { all } from 'better-all'

// ✅ Maximum parallelization with better-all
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

### Deferred Data for Non-Blocking Loading (Automatic)

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

// Fast Server Function
const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

// Slow Server Function
const getComments = createServerFn().handler(async (postId: string) => {
  await new Promise(r => setTimeout(r, 3000)) // Slow query
  return await db.comment.findMany({ where: { postId } })
})

// ✅ Await important data, defer non-critical data
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // Important: post loads immediately (await)
    const post = await getPost(params.postId)

    // Non-critical: comments returns Promise (automatically deferred)
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
      {/* post renders immediately */}
      <PostContent post={post} />

      {/* comments stream in */}
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

**Important:** TanStack Start doesn't require calling `defer()` explicitly. Simply return a Promise and it's automatically deferred.

</critical_patterns>

---

<bundle_optimization>

## 2. Bundle Size Optimization (CRITICAL)

### Avoid Barrel File Imports

```tsx
// ❌ Import entire library (1583 modules, ~2.8s)
import { Check, X, Menu } from 'lucide-react'

// ✅ Direct imports (3 modules only)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
```

Affected libraries: `lucide-react`, `@mui/material`, `@mui/icons-material`, `@tabler/icons-react`, `react-icons`, `@headlessui/react`, `@radix-ui/react-*`, `lodash`, `ramda`, `date-fns`, `rxjs`, `react-use`

### Route-Based Code Splitting

```typescript
import { lazy } from 'react'
import { createFileRoute } from '@tanstack/react-router'

// ❌ All components bundled in main chunk
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

// ✅ Heavy components lazy loaded
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

### Conditional Module Loading

```tsx
// ❌ Always loaded
import { AnimationFrames } from './animation-frames'

function AnimationPlayer({ enabled }: { enabled: boolean }) {
  if (!enabled) return null
  return <Canvas frames={AnimationFrames} />
}

// ✅ Load only when activated
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

## 3. Server-Side Performance (HIGH)

### LRU Cache - Cross-Request Caching

```typescript
import { LRUCache } from 'lru-cache'

const cache = new LRUCache<string, any>({
  max: 1000,
  ttl: 5 * 60 * 1000  // 5 minutes
})

export async function getUser(id: string) {
  const cached = cache.get(id)
  if (cached) return cached

  const user = await db.user.findUnique({ where: { id } })
  cache.set(id, user)
  return user
}

// Request 1: DB query, result cached
// Request 2: cache hit, no DB query
```

### Minimize Serialization

```typescript
// ❌ Serializes all 50 fields
export const Route = createFileRoute('/profile')({
  loader: async () => {
    const user = await fetchUser()  // 50 fields
    return { user }
  }
})

function ProfilePage() {
  const { user } = Route.useLoaderData()
  return <div>{user.name}</div>  // uses 1 field
}

// ✅ Serializes only needed fields
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

### Parallel Fetching in Loader + createServerFn

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

// Define Server Functions
const getUser = createServerFn().handler(async () => {
  return await db.user.findMany()
})

const getStats = createServerFn().handler(async () => {
  return await db.stats.findMany()
})

const getNotifications = createServerFn().handler(async () => {
  return await db.notification.findMany()
})

// ❌ Sequential fetching
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getUser()
    const stats = await getStats()
    const notifications = await getNotifications()
    return { user, stats, notifications }
  }
})

// ✅ Parallel fetching
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

**Important:** TanStack Start loaders are isomorphic. They run on both server and client, so separate server-only code with `createServerFn()`.

</server_performance>

---

<client_data_fetching>

## 4. Client-Side Data Fetching (MEDIUM-HIGH)

### TanStack Query for Automatic Caching

```tsx
import { useQuery } from '@tanstack/react-query'

// ❌ No deduplication, each instance fetches
function UserList() {
  const [users, setUsers] = useState([])
  useEffect(() => {
    fetch('/api/users')
      .then(r => r.json())
      .then(setUsers)
  }, [])
}

// ✅ Multiple instances share one request
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
      // Invalidate cache for automatic refetch
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

## 5. Re-render Optimization (MEDIUM)

### Functional setState

```tsx
// ❌ items as dependency, recreated every time
function TodoList() {
  const [items, setItems] = useState(initialItems)

  const addItems = useCallback((newItems: Item[]) => {
    setItems([...items, ...newItems])
  }, [items])  // Recreated on items change
}

// ✅ Stable callback, never recreated
function TodoList() {
  const [items, setItems] = useState(initialItems)

  const addItems = useCallback((newItems: Item[]) => {
    setItems(curr => [...curr, ...newItems])
  }, [])  // No dependencies, always uses latest state
}
```

### Lazy State Initialization

```tsx
// ❌ Runs on every render
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(buildSearchIndex(items))
}

// ✅ Runs only on initial render
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(() => buildSearchIndex(items))
}
```

### Subscribe to Derived State

```tsx
// ❌ Re-renders on every pixel change
function Sidebar() {
  const width = useWindowWidth()  // continuous updates
  const isMobile = width < 768
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}

// ✅ Re-renders only when boolean changes
function Sidebar() {
  const isMobile = useMediaQuery('(max-width: 767px)')
  return <nav className={isMobile ? 'mobile' : 'desktop'}>
}
```

</rerender_optimization>

---

<rendering_performance>

## 6. Rendering Performance (MEDIUM)

### Animate SVG Wrapper

```tsx
// ❌ Animating SVG directly - no hardware acceleration
function LoadingSpinner() {
  return (
    <svg className="animate-spin" width="24" height="24">
      <circle cx="12" cy="12" r="10" />
    </svg>
  )
}

// ✅ Animating wrapper div - hardware accelerated
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

For 1000 messages, browser skips layout/paint for ~990 off-screen items (10× faster initial render)

### JSX Hoisting

```tsx
// ❌ Recreated every render
function Container() {
  return (
    <div>
      {loading && <div className="animate-pulse h-20 bg-gray-200" />}
    </div>
  )
}

// ✅ Created once
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

## 7. JavaScript Performance (LOW-MEDIUM)

### Build Index Maps for Repeated Lookups

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

### Early Length Check for Array Comparisons

```typescript
// ❌ Always runs expensive comparison
function hasChanges(current: string[], original: string[]) {
  return current.sort().join() !== original.sort().join()
}

// ✅ O(1) length check first
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

### Use toSorted() for Immutability

```typescript
// ❌ Mutates original array
function UserList({ users }: { users: User[] }) {
  const sorted = useMemo(
    () => users.sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
}

// ✅ Creates new array
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

## References

### TanStack Official Documentation
1. [React](https://react.dev)
2. [TanStack Start Overview](https://tanstack.com/start/latest/docs/framework/react/overview)
3. [TanStack Start Quick Start](https://tanstack.com/start/latest/docs/framework/react/quick-start)
4. [TanStack Router](https://tanstack.com/router)
5. [TanStack Router Deferred Data Loading](https://tanstack.com/router/v1/docs/framework/react/guide/deferred-data-loading)
6. [TanStack Query](https://tanstack.com/query)
7. [Server Functions Guide](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)

### External Resources
8. [better-all](https://github.com/shuding/better-all)
9. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
10. [Using Server Functions and TanStack Query](https://www.brenelz.com/posts/using-server-functions-and-tanstack-query/)

</references>
