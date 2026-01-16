# Next.js React Best Practices

**Version 1.0.0**
Vercel Engineering
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring React and Next.js codebases. Humans
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

Comprehensive performance optimization guide for React and Next.js applications, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (eliminating waterfalls, reducing bundle size) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

<instructions>

## Document Usage Instructions

@rules/async-defer-await.md
@rules/async-parallel.md
@rules/async-dependencies.md
@rules/async-api-routes.md
@rules/async-suspense-boundaries.md
@rules/bundle-barrel-imports.md
@rules/bundle-conditional.md
@rules/bundle-defer-third-party.md
@rules/bundle-dynamic-imports.md
@rules/bundle-preload.md
@rules/server-cache-react.md
@rules/server-cache-lru.md
@rules/server-serialization.md
@rules/server-parallel-fetching.md
@rules/server-after-nonblocking.md
@rules/client-event-listeners.md
@rules/client-swr-dedup.md
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
@rules/rendering-hydration-no-flicker.md
@rules/rendering-activity.md
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
@rules/advanced-event-handler-refs.md
@rules/advanced-use-latest.md

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
| 8 | Advanced Patterns | LOW | Advanced implementation patterns for specific cases |

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

### Dependency-Based Parallelization

```typescript
// ❌ profile waits for config unnecessarily
const [user, config] = await Promise.all([
  fetchUser(),
  fetchConfig()
])
const profile = await fetchProfile(user.id)

// ✅ config and profile run in parallel with better-all
import { all } from 'better-all'

const { user, config, profile } = await all({
  async user() { return fetchUser() },
  async config() { return fetchConfig() },
  async profile() {
    return fetchProfile((await this.$.user).id)
  }
})
```

### Suspense Boundaries

```tsx
// ❌ Entire layout blocked by data fetching
async function Page() {
  const data = await fetchData()
  return (
    <div>
      <Sidebar />
      <Header />
      <DataDisplay data={data} />
      <Footer />
    </div>
  )
}

// ✅ Wrapper shows immediately, data streams in
function Page() {
  return (
    <div>
      <Sidebar />
      <Header />
      <Suspense fallback={<Skeleton />}>
        <DataDisplay />
      </Suspense>
      <Footer />
    </div>
  )
}

async function DataDisplay() {
  const data = await fetchData()
  return <div>{data.content}</div>
}
```

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

// ✅ Next.js 13.5+ auto-optimization
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@mui/material']
  }
}
```

Affected libraries: `lucide-react`, `@mui/material`, `@mui/icons-material`, `@tabler/icons-react`, `react-icons`, `@headlessui/react`, `@radix-ui/react-*`, `lodash`, `ramda`, `date-fns`, `rxjs`, `react-use`

### Dynamic Imports

```tsx
// ❌ Monaco bundled with main chunk (~300KB)
import { MonacoEditor } from './monaco-editor'

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}

// ✅ Monaco loads on demand
import dynamic from 'next/dynamic'

const MonacoEditor = dynamic(
  () => import('./monaco-editor').then(m => m.MonacoEditor),
  { ssr: false }
)

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}
```

</bundle_optimization>

---

<server_performance>

## 3. Server-Side Performance (HIGH)

### React.cache() - Per-Request Deduplication

```typescript
import { cache } from 'react'

export const getCurrentUser = cache(async () => {
  const session = await auth()
  if (!session?.user?.id) return null
  return await db.user.findUnique({ where: { id: session.user.id } })
})

// Within single request, multiple calls execute query only once
```

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

### Minimize Serialization at RSC Boundaries

```tsx
// ❌ Serializes all 50 fields
async function Page() {
  const user = await fetchUser()  // 50 fields
  return <Profile user={user} />
}

'use client'
function Profile({ user }: { user: User }) {
  return <div>{user.name}</div>  // uses 1 field
}

// ✅ Serializes only 1 field
async function Page() {
  const user = await fetchUser()
  return <Profile name={user.name} />
}

'use client'
function Profile({ name }: { name: string }) {
  return <div>{name}</div>
}
```

### after() for Non-Blocking Operations

```tsx
import { after } from 'next/server'

export async function POST(request: Request) {
  await updateDatabase(request)

  // Log after response is sent
  after(async () => {
    const userAgent = (await headers()).get('user-agent') || 'unknown'
    logUserAction({ userAgent })
  })

  return new Response(JSON.stringify({ status: 'success' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

</server_performance>

---

<client_data_fetching>

## 4. Client-Side Data Fetching (MEDIUM-HIGH)

### SWR for Automatic Deduplication

```tsx
import useSWR from 'swr'

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
  const { data: users } = useSWR('/api/users', fetcher)
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
  const [query, setQuery] = useState('')
}

// ✅ Runs only on initial render
function FilteredList({ items }: { items: Item[] }) {
  const [searchIndex, setSearchIndex] = useState(() => buildSearchIndex(items))
  const [query, setQuery] = useState('')
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
/* Long list optimization */
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

### Prevent Hydration Mismatch

```tsx
// ❌ SSR failure
function ThemeWrapper({ children }: { children: ReactNode }) {
  const theme = localStorage.getItem('theme') || 'light'  // localStorage undefined on server
  return <div className={theme}>{children}</div>
}

// ❌ Flickering
function ThemeWrapper({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState('light')

  useEffect(() => {
    const stored = localStorage.getItem('theme')
    if (stored) setTheme(stored)  // Runs after hydration → flicker
  }, [])

  return <div className={theme}>{children}</div>
}

// ✅ No flicker, no hydration mismatch
function ThemeWrapper({ children }: { children: ReactNode }) {
  return (
    <>
      <div id="theme-wrapper">{children}</div>
      <script
        dangerouslySetInnerHTML={{
          __html: `
            (function() {
              try {
                var theme = localStorage.getItem('theme') || 'light';
                var el = document.getElementById('theme-wrapper');
                if (el) el.className = theme;
              } catch (e) {}
            })();
          `,
        }}
      />
    </>
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

<advanced_patterns>

## 8. Advanced Patterns (LOW)

### useLatest for Stable Callback Refs

```typescript
function useLatest<T>(value: T) {
  const ref = useRef(value)
  useEffect(() => {
    ref.current = value
  }, [value])
  return ref
}
```

```tsx
// ❌ Effect re-runs on every callback change
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')

  useEffect(() => {
    const timeout = setTimeout(() => onSearch(query), 300)
    return () => clearTimeout(timeout)
  }, [query, onSearch])
}

// ✅ Stable effect, fresh callback
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')
  const onSearchRef = useLatest(onSearch)

  useEffect(() => {
    const timeout = setTimeout(() => onSearchRef.current(query), 300)
    return () => clearTimeout(timeout)
  }, [query])
}
```

</advanced_patterns>

---

<references>

## References

1. [React](https://react.dev)
2. [Next.js](https://nextjs.org)
3. [SWR](https://swr.vercel.app)
4. [better-all](https://github.com/shuding/better-all)
5. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
6. [Next.js Package Import Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
7. [Vercel Dashboard Twice as Fast](https://vercel.com/blog/how-we-made-the-vercel-dashboard-twice-as-fast)

</references>
