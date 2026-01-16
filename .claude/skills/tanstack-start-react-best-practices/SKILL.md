---
name: tanstack-start-react-best-practices
description: TanStack Start and React performance optimization guide. Ensures optimal performance patterns when writing, reviewing, or refactoring TanStack Start pages and React components. Triggers on tasks involving React components, TanStack Router routes, data fetching, bundle optimization, or performance improvements.
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
  adapted_for: tanstack-start
---

# TanStack Start React Best Practices

Performance optimization guide for React and TanStack Start applications. Contains 39 rules across 7 categories, prioritized by impact to guide automated refactoring and code generation.

---

<communication>

## User Communication

**IMPORTANT: Always communicate with the user in Korean (한국어), even though this document is in English.**

When:
- Asking questions
- Providing summaries
- Explaining decisions
- Reporting progress

Use Korean for all user-facing communication while applying these English guidelines internally.

</communication>

---

<when_to_use>

## When to Apply

| Situation | Description |
|-----------|-------------|
| **Writing Components** | Creating new React components or TanStack Start routes |
| **Data Fetching** | Implementing client-side or server-side data fetching |
| **Code Review** | Reviewing code for performance issues |
| **Refactoring** | Improving existing React/TanStack Start code |
| **Optimization** | Optimizing bundle size or load times |

</when_to_use>

---

<categories>

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Eliminating Waterfalls | **CRITICAL** | `async-` |
| 2 | Bundle Size Optimization | **CRITICAL** | `bundle-` |
| 3 | Server-Side Performance | HIGH | `server-` |
| 4 | Client-Side Data Fetching | MEDIUM-HIGH | `client-` |
| 5 | Re-render Optimization | MEDIUM | `rerender-` |
| 6 | Rendering Performance | MEDIUM | `rendering-` |
| 7 | JavaScript Performance | LOW-MEDIUM | `js-` |

</categories>

---

<rules>

## Quick Reference

### 1. Eliminating Waterfalls (CRITICAL)

| Rule | Description |
|------|-------------|
| `async-defer-await` | Move await into branches where actually used |
| `async-parallel` | Use Promise.all() for independent operations |
| `async-dependencies` | Use better-all for partial dependencies |
| `async-loader` | Parallel data fetching in TanStack Router loader |

### 2. Bundle Size Optimization (CRITICAL)

| Rule | Description |
|------|-------------|
| `bundle-barrel-imports` | Import directly, avoid barrel files |
| `bundle-lazy-routes` | Route-based code splitting |
| `bundle-defer-third-party` | Load analytics/logging after hydration |
| `bundle-conditional` | Load modules only when feature is activated |
| `bundle-preload` | Preload on hover/focus for perceived speed |

### 3. Server-Side Performance (HIGH)

| Rule | Description |
|------|-------------|
| `server-cache-lru` | Use LRU cache for cross-request caching |
| `server-serialization` | Minimize data passed to client components |
| `server-parallel-fetching` | Parallel data fetching in loader |
| `server-deferred-data` | Use defer() for non-blocking data loading |

### 4. Client-Side Data Fetching (MEDIUM-HIGH)

| Rule | Description |
|------|-------------|
| `client-tanstack-query` | TanStack Query for automatic caching/deduplication |
| `client-event-listeners` | Deduplicate global event listeners |

### 5. Re-render Optimization (MEDIUM)

| Rule | Description |
|------|-------------|
| `rerender-defer-reads` | Don't subscribe to state only used in callbacks |
| `rerender-memo` | Extract expensive work into memoized components |
| `rerender-dependencies` | Use primitive dependencies in effects |
| `rerender-derived-state` | Subscribe to derived booleans, not raw values |
| `rerender-functional-setstate` | Use functional setState for stable callbacks |
| `rerender-lazy-state-init` | Pass function to useState for expensive values |
| `rerender-transitions` | Use startTransition for non-urgent updates |

### 6. Rendering Performance (MEDIUM)

| Rule | Description |
|------|-------------|
| `rendering-animate-svg-wrapper` | Animate div wrapper, not SVG element |
| `rendering-content-visibility` | Use content-visibility for long lists |
| `rendering-hoist-jsx` | Extract static JSX outside components |
| `rendering-svg-precision` | Reduce SVG coordinate precision |
| `rendering-conditional-render` | Use ternary, not && for conditionals |

### 7. JavaScript Performance (LOW-MEDIUM)

| Rule | Description |
|------|-------------|
| `js-batch-dom-css` | Group CSS changes via classes or cssText |
| `js-index-maps` | Build Map for repeated lookups |
| `js-cache-property-access` | Cache object properties in loops |
| `js-cache-function-results` | Cache function results in module-level Map |
| `js-cache-storage` | Cache localStorage/sessionStorage reads |
| `js-combine-iterations` | Combine multiple filter/map into one loop |
| `js-length-check-first` | Check array length before expensive comparison |
| `js-early-exit` | Return early from functions |
| `js-hoist-regexp` | Hoist RegExp creation outside loops |
| `js-min-max-loop` | Use loop for min/max instead of sort |
| `js-set-map-lookups` | Use Set/Map for O(1) lookups |
| `js-tosorted-immutable` | Use toSorted() for immutability |

</rules>

---

<patterns>

## Core Patterns

### ✅ Eliminate Waterfalls

```typescript
// ❌ Sequential execution, 3 round trips
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()

// ✅ Parallel execution, 1 round trip
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

### ✅ TanStack Router Loader + createServerFn

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

// Define Server Functions
const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

const getComments = createServerFn().handler(async (postId: string) => {
  return await db.comment.findMany({ where: { postId } })
})

// ❌ Sequential loading
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await getPost(params.postId)
    const comments = await getComments(params.postId)
    return { post, comments }
  }
})

// ✅ Parallel loading
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

### ✅ Bundle Optimization

```tsx
// ❌ Import entire library (1583 modules, ~2.8s)
import { Check, X, Menu } from 'lucide-react'

// ✅ Direct imports (3 modules only)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
```

### ✅ TanStack Query for Caching

```typescript
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

### ✅ Re-render Optimization

```tsx
// ❌ items as dependency, recreated every time
const addItems = useCallback((newItems: Item[]) => {
  setItems([...items, ...newItems])
}, [items])

// ✅ Stable callback, never recreated
const addItems = useCallback((newItems: Item[]) => {
  setItems(curr => [...curr, ...newItems])
}, [])
```

</patterns>

---

<tanstack_specific>

## TanStack Start Specific Patterns

### createServerFn for Server Functions

```typescript
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'

// ✅ Basic Server Function
const getUser = createServerFn().handler(async () => {
  // Only runs on server
  return await db.user.findMany()
})

// ✅ POST + Validation
const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email()
})

const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    // data is fully typed and validated
    return await db.user.create({ data })
  })
```

### Loader Optimization

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute } from '@tanstack/react-router'

const getUser = createServerFn().handler(async () => {
  return await db.user.findMany()
})

const getStats = createServerFn().handler(async () => {
  return await db.stats.findMany()
})

// ✅ Parallel data fetching
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const [user, stats] = await Promise.all([
      getUser(),
      getStats()
    ])
    return { user, stats }
  }
})
```

### Deferred Data (Automatic Handling)

```typescript
import { createServerFn } from '@tanstack/react-start'
import { createFileRoute, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

const getPost = createServerFn().handler(async (postId: string) => {
  return await db.post.findUnique({ where: { id: postId } })
})

const getComments = createServerFn().handler(async (postId: string) => {
  await new Promise(r => setTimeout(r, 3000)) // Slow query simulation
  return await db.comment.findMany({ where: { postId } })
})

// ✅ Await important data, defer non-critical data
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    // Fast data: await
    const post = await getPost(params.postId)

    // Slow data: return Promise (automatically deferred)
    const deferredComments = getComments(params.postId)

    return {
      post,
      deferredComments
    }
  }
})

// Handle with Await in component
function PostPage() {
  const { post, deferredComments } = Route.useLoaderData()

  return (
    <div>
      <PostContent post={post} />
      <Suspense fallback={<CommentsSkeleton />}>
        <Await promise={deferredComments}>
          {(comments) => <Comments comments={comments} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

### Route-Based Code Splitting

```typescript
import { lazy } from 'react'
import { createFileRoute } from '@tanstack/react-router'

// ✅ Heavy components lazy loaded
const HeavyEditor = lazy(() => import('./components/HeavyEditor'))

export const Route = createFileRoute('/editor')({
  component: () => (
    <Suspense fallback={<EditorSkeleton />}>
      <HeavyEditor />
    </Suspense>
  )
})
```

</tanstack_specific>

---

<usage>

## Usage

**Detailed rules and examples:**

```
rules/async-parallel.md
rules/bundle-barrel-imports.md
rules/client-tanstack-query.md
rules/server-deferred-data.md
```

Each rule file contains:
- Why it matters
- ❌ Incorrect code example with explanation
- ✅ Correct code example with explanation
- Additional context and references

**Full compiled document:** `AGENTS.md`

</usage>

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
