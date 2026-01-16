---
name: nextjs-react-best-practices
description: React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements.
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
---

# Next.js React Best Practices

Comprehensive performance optimization guide for React and Next.js applications maintained by Vercel. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

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
| **Writing Components** | Creating new React components or Next.js pages |
| **Data Fetching** | Implementing client-side or server-side data fetching |
| **Code Review** | Reviewing code for performance issues |
| **Refactoring** | Improving existing React/Next.js code |
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
| 8 | Advanced Patterns | LOW | `advanced-` |

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
| `async-api-routes` | Start promises early, await late in API routes |
| `async-suspense-boundaries` | Use Suspense to stream content |

### 2. Bundle Size Optimization (CRITICAL)

| Rule | Description |
|------|-------------|
| `bundle-barrel-imports` | Import directly, avoid barrel files |
| `bundle-dynamic-imports` | Use next/dynamic for heavy components |
| `bundle-defer-third-party` | Load analytics/logging after hydration |
| `bundle-conditional` | Load modules only when feature is activated |
| `bundle-preload` | Preload on hover/focus for perceived speed |

### 3. Server-Side Performance (HIGH)

| Rule | Description |
|------|-------------|
| `server-cache-react` | Use React.cache() for per-request deduplication |
| `server-cache-lru` | Use LRU cache for cross-request caching |
| `server-serialization` | Minimize data passed to client components |
| `server-parallel-fetching` | Restructure components to parallelize fetches |
| `server-after-nonblocking` | Use after() for non-blocking operations |

### 4. Client-Side Data Fetching (MEDIUM-HIGH)

| Rule | Description |
|------|-------------|
| `client-swr-dedup` | Use SWR for automatic request deduplication |
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
| `rendering-hydration-no-flicker` | Use inline script for client-only data |
| `rendering-activity` | Use Activity component for show/hide |
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

### 8. Advanced Patterns (LOW)

| Rule | Description |
|------|-------------|
| `advanced-event-handler-refs` | Store event handlers in refs |
| `advanced-use-latest` | useLatest for stable callback refs |

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

### ✅ Bundle Optimization

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
    optimizePackageImports: ['lucide-react']
  }
}
```

### ✅ Server Caching

```typescript
import { cache } from 'react'

// Per-request deduplication
export const getCurrentUser = cache(async () => {
  const session = await auth()
  if (!session?.user?.id) return null
  return await db.user.findUnique({ where: { id: session.user.id } })
})
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

<usage>

## Usage

**Detailed rules and examples:**

```
rules/async-parallel.md
rules/bundle-barrel-imports.md
rules/_sections.md
```

Each rule file contains:
- ❌ Incorrect code example with explanation
- ✅ Correct code example with explanation
- Additional context and references
- Why it matters

**Full compiled document:** `AGENTS.md`

</usage>

---

<references>

## References

1. [React](https://react.dev)
2. [Next.js](https://nextjs.org)
3. [SWR](https://swr.vercel.app)
4. [better-all](https://github.com/shuding/better-all)
5. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
6. [Next.js Package Import Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
7. [How We Made the Vercel Dashboard Twice as Fast](https://vercel.com/blog/how-we-made-the-vercel-dashboard-twice-as-fast)

</references>
