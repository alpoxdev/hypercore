---
title: 라우트 기반 코드 스플리팅
impact: CRITICAL
impactDescription: 초기 번들 30-50% 감소
tags: bundle, lazy-loading, code-splitting, routes
---

## 라우트 기반 코드 스플리팅

TanStack Router는 라우트별로 자동 코드 스플리팅. 라우트 내 무거운 컴포넌트는 `lazy()`로 번들 크기를 추가 감소.

**❌ 잘못된 예 (무거운 컴포넌트 선행 로드):**

```tsx
import { createFileRoute } from '@tanstack/react-router'
import HeavyEditor from '@/components/HeavyEditor' // 500KB 번들

export const Route = createFileRoute('/editor')({
  component: () => <HeavyEditor />
})
// 사용자가 /editor를 방문하지 않아도 500KB 전체 로드
```

**✅ 올바른 예 (무거운 컴포넌트 지연 로딩):**

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
// 사용자가 /editor로 이동할 때만 500KB 로드
```

**여러 무거운 의존성의 경우:**

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

지연 로딩을 고려할 무거운 라이브러리: 차트 라이브러리 (recharts, chart.js), 리치 텍스트 에디터 (tiptap, slate), PDF 뷰어, 비디오 플레이어, 3D 렌더러, 데이터 시각화.

초기 번들을 30-50% 감소시키고 Time to Interactive를 개선합니다.
