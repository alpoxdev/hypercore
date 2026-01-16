---
title: Route-Based Code Splitting
impact: CRITICAL
impactDescription: 30-50% smaller initial bundle
tags: bundle, lazy-loading, code-splitting, routes
---

## Route-Based Code Splitting

TanStack Router automatically code-splits by route. Use `lazy()` for heavy components within routes to reduce bundle size further.

**Incorrect (heavy component loaded upfront):**

```tsx
import { createFileRoute } from '@tanstack/react-router'
import HeavyEditor from '@/components/HeavyEditor' // 500KB bundle

export const Route = createFileRoute('/editor')({
  component: () => <HeavyEditor />
})
// Entire 500KB loads even if user never visits /editor
```

**Correct (lazy load heavy components):**

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { lazy, Suspense } from 'react'

const HeavyEditor = lazy(() => import('@/components/HeavyEditor'))

export const Route = createFileRoute('/editor')({
  component: () => (
    <Suspense fallback={<EditorSkeleton />}>
      <HeavyEditor />
    </Suspense>
  )
})
// 500KB only loads when user navigates to /editor
```

**For multiple heavy dependencies:**

```tsx
import { lazy, Suspense } from 'react'

const ChartComponent = lazy(() => import('@/components/ChartComponent'))
const PDFViewer = lazy(() => import('@/components/PDFViewer'))
const VideoPlayer = lazy(() => import('@/components/VideoPlayer'))

export const Route = createFileRoute('/dashboard')({
  component: () => (
    <div>
      <Suspense fallback={<ChartSkeleton />}>
        <ChartComponent />
      </Suspense>
      <Suspense fallback={<PDFSkeleton />}>
        <PDFViewer />
      </Suspense>
    </div>
  )
})
```

Heavy libraries to consider lazy loading: chart libraries (recharts, chart.js), rich text editors (tiptap, slate), PDF viewers, video players, 3D renderers, data visualization.

This reduces initial bundle by 30-50% and improves Time to Interactive.
